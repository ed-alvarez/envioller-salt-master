{% from slspath + "/map.jinja" import envioller with context %}

{%- set envio_distro_version = salt.grains.get('envio_distro_version') %}
{%- set gw_stuff = salt['file.find'](envioller.install_dir,type='f',name='*.sls') %}

include:
  - gateway.modules.supervisor.v1
  - gateway.modules.git.v1

envioller_service_dead:
  supervisord.dead:
    - name: envioller

envioller_ssh_dir:
  file.directory:
    - name: {{ salt.file.dirname(envioller.deploy_key_file) | yaml_encode }}
    - user: {{ envioller.user | yaml_encode }}
    - group: {{ envioller.group | yaml_encode }}
    - dir_mode: "0700"
    - makedirs: true

envioller_install_dir:
  file.directory:
    - names:
      - {{ envioller.install_dir | yaml_encode }}
      - {{ envioller.venv_dir | yaml_encode }}
      - {{ envioller.dir_cfg_modbus | yaml_encode }}
      - {{ envioller.dir_cfg_bacnet | yaml_encode }}
      - {{ envioller.dir_cfg_mbus | yaml_encode }}
      - {{ envioller.dir_logs_symlinks | yaml_encode }}
    - user: {{ envioller.user | yaml_encode }}
    - group: {{ envioller.group | yaml_encode }}
    - dir_mode: "0755"
    - makedirs: True

/home/debian/logs/envioller:
  file.symlink:
    - target: /var/log/envio/envioller
    - require:
      - file: envioller_install_dir

envioller_deploy_key:
  file.managed:
    - name:  {{ envioller.deploy_key_file | yaml_encode }}
    - user:  {{ envioller.user | yaml_encode }}
    - group: {{ envioller.group | yaml_encode }}
    - contents_pillar: envio:gateway:commons:envioller:deploy_key
    - mode: "0600"
    - show_diff: false
    - require:
      - file: envioller_ssh_dir

{% if envio_distro_version == "2020.7.1" or envio_distro_version == "2021.2.9" %}

envioller_backup_old_gw_stuff:
  module.run:
    - file.move:
      - src: {{ envioller.install_dir }}/config
      - dst: /tmp/config_backup

{% for file in gw_stuff %}
{% if file.startswith('.') not true %}
envioller_erase_old_gw_stuff_{{ file }}:
  file.absent:
    - name: {{ file }}
{% endif %}
{% endfor %}

{% endif %}

envioller_repo:
  git.latest:
    - name: git@github.com:enviosystems/envio-envioller-app-binary.git
    - identity: {{ envioller.deploy_key_file | yaml_encode }}
    - target: {{ envioller.install_dir | yaml_encode }}
    - user: {{ envioller.user | yaml_encode }}
    - force_reset: true
    - force_clone: true
    - force_fetch: true
    - force_checkout: true
    - depth: 1
    - rev: {{ envioller.version | yaml_encode }}
    - require:
      - pkg: git
      - file: envioller_install_dir
      - file: envioller_deploy_key
      - supervisord: envioller_service_dead

envioller_extract_binaries:
  archive.extracted:
    - name: {{ envioller.install_dir }}
    - source: {{ envioller.install_dir }}/bin.tar.gz

envioller_delete_zipbinaries:
  file.absent:
    - name: {{ envioller.install_dir }}/bin.tar.gz

envioller_restore_old_gw_stuff:
  file.copy:
    - name: {{ envioller.install_dir }}/config
    - source: /tmp/config_backup

envioller_erase_backup_gw_stuff:
  file.absent:
    - name: /tmp/config_backup

envioller_executable:
  file.managed:
    - source: {{ envioller.install_dir }}/bin/Envioller_Secured
    - mode: "0755"

envioller_log_directory:
  file.directory:
    - name: /var/log/envio
    - user: root
    - group: root
    - dir_mode: "0755"
