{% from slspath + "/map.jinja" import envioscheduler with context %}

{%- set envio_distro_version = salt.grains.get('envio_distro_version') %}

include:
  - gateway.modules.supervisor.v1
  - gateway.modules.git.v1

envioscheduler_service_dead:
  supervisord.dead:
    - name: envioscheduler

envioscheduler_ssh_dir:
  file.directory:
    - name: {{ salt.file.dirname(envioscheduler.deploy_key_file) | yaml_encode }}
    - user: {{ envioscheduler.user | yaml_encode }}
    - group: {{ envioscheduler.group | yaml_encode }}
    - dir_mode: "0700"
    - makedirs: true

envioscheduler_install_dir:
  file.directory:
    - names:
      - {{ envioscheduler.install_dir | yaml_encode }}
      - {{ envioscheduler.dir_logs_symlinks | yaml_encode }}
    - user: {{ envioscheduler.user | yaml_encode }}
    - group: {{ envioscheduler.group | yaml_encode }}
    - dir_mode: "0755"
    - makedirs: True

/home/debian/logs/envioscheduler:
  file.symlink:
    - target: /var/log/envio/envioscheduler
    - require:
      - file: envioscheduler_install_dir

envioscheduler_deploy_key:
  file.managed:
    - name:  {{ envioscheduler.deploy_key_file | yaml_encode }}
    - user:  {{ envioscheduler.user | yaml_encode }}
    - group: {{ envioscheduler.group | yaml_encode }}
    - contents_pillar: envio:gateway:commons:envioscheduler:deploy_key
    - mode: "0600"
    - show_diff: false
    - require:
      - file: envioscheduler_ssh_dir

envioscheduler_repo:
  git.latest:
    - name: git@github.com:enviosystems/gw-scheduler-binary.git
    - identity: {{ envioscheduler.deploy_key_file | yaml_encode }}
    - target: {{ envioscheduler.install_dir | yaml_encode }}
    - user: {{ envioscheduler.user | yaml_encode }}
    - force_reset: true
    - force_clone: true
    - force_fetch: true
    - force_checkout: true
    - depth: 1
    - rev: {{ envioscheduler.version | yaml_encode }}
    - require:
      - pkg: git
      - file: envioscheduler_install_dir
      - file: envioscheduler_deploy_key
      - supervisord: envioscheduler_service_dead

envioscheduler_add_permissions:
  file.managed:
    - name: '{{ envioscheduler.install_dir }}/EnvioScheduler_Secured'
    - mode: "0755"

{% if envio_distro_version == "2020.7.1" or envio_distro_version == "2021.2.9" %}
envioscheduler_apt_packages:
  pkg.installed:
    - pkgs:
      - libevent-dev
      - python-all-dev
      - python3-venv
      - python3-dev
      - libxml2
      - libxml2-dev
      - python3-lxml
      - libxml2-dev
      - libxslt1-dev
      - zlib1g-dev
      - python3-pip
      - sqlite3
      - libsqlite3-dev
{% endif %}

envioscheduler_log_directory:
  file.directory:
    - name: /var/log/envio
    - user: root
    - group: root
    - dir_mode: "0755"

envioscheduler_db_directory:
  file.directory:
    - name: /var/lib/envio
    - user: root
    - group: root
    - dir_mode: "0777"
