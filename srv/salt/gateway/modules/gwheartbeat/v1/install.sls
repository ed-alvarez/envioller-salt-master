{% from slspath + "/map.jinja" import gwheartbeat with context %}

include:
  - gateway.modules.supervisor.v1
  - gateway.modules.git.v1

gwheartbeat_service_dead:
  supervisord.dead:
    - name: gwheartbeat

gwheartbeat_ssh_dir:
  file.directory:
    - name:  {{ salt.file.dirname(gwheartbeat.deploy_key_file) | yaml_encode }}
    - user:  {{ gwheartbeat.user | yaml_encode }}
    - group: {{ gwheartbeat.group | yaml_encode }}
    - dir_mode: "0700"
    - makedirs: true

gwheartbeat_install_dir:
  file.directory:
    - names:
      - {{ gwheartbeat.install_dir | yaml_encode }}
      - {{ gwheartbeat.dir_logs_symlinks | yaml_encode }}
    - user: {{ gwheartbeat.user | yaml_encode }}
    - group: {{ gwheartbeat.group | yaml_encode }}
    - dir_mode: "0755"
    - makedirs: True

/home/debian/logs/gwheartbeat:
  file.symlink:
    - target: /var/log/envio/gwheartbeat
    - require:
      - file: gwheartbeat_install_dir

gwheartbeat_deploy_key:
  file.managed:
    - name:  {{ gwheartbeat.deploy_key_file | yaml_encode }}
    - user:  {{ gwheartbeat.user | yaml_encode }}
    - group: {{ gwheartbeat.group | yaml_encode }}
    - contents_pillar: envio:gateway:commons:gwheartbeat:deploy_key
    - mode: "0600"
    - show_diff: false
    - require:
      - file: gwheartbeat_ssh_dir

gwheartbeat_repo:
  git.latest:
    - name: git@github.com:enviosystems/gwheartbeat.git
    - identity: {{ gwheartbeat.deploy_key_file | yaml_encode }}
    - target: {{ gwheartbeat.install_dir | yaml_encode }}
    - user: {{ gwheartbeat.user | yaml_encode }}
    - force_reset: true
    - depth: 1
    - force_clone: true
    - force_fetch: true
    - force_checkout: true
    - rev: {{ gwheartbeat.version | yaml_encode }}
    - require:
      - pkg: git
      - file: gwheartbeat_install_dir
      - file: gwheartbeat_deploy_key
      - supervisord: gwheartbeat_service_dead

gwheartbeat_add_permissions:
  file.managed:
    - name: {{ gwheartbeat.install_dir }}/GWHeartBeat_Secured
    - mode: "0755"

{% for file in ['src', 'wheels', 'build_binary.sh', 'HowTo-BuildBinary.md', 'pyarmor-regfile-1.zip',
  'requirements.txt', 'requirements-to-freeze.txt', '.gitignore'] %}
gwheartbeat_delete_folders:
  file.absent:
    - name: {{ gwheartbeat.install_dir }}/file
{% endfor %}

gwheartbeat_log_directory:
  file.directory:
    - name: /var/log/envio
    - user: root
    - group: root
    - dir_mode: "0755"
