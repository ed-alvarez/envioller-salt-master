{% from slspath + "/map.jinja" import gateway with context %}
{%- set osmajorrelease = salt.grains.get('osmajorrelease') %}

{%- set envio_distro_version = salt.grains.get('envio_distro_version') %}

{%- set gw_installdir = salt['file.find'](gateway.install_dir,type='f',name='*.sls') %}

include:
  - gateway.modules.supervisor.v1
  - gateway.modules.git.v1
  - gateway.modules.snaptoolbelt.v1

evgw_service_dead:
  supervisord.dead:
    - name: evgw

evgw_ssh_dir:
  file.directory:
    - name:  {{ salt.file.dirname(gateway.deploy_key_file) | yaml_encode }}
    - user:  {{ gateway.user | yaml_encode }}
    - group: {{ gateway.group | yaml_encode }}
    - dir_mode: "0700"
    - makedirs: true


evgw_install_dir:
  file.directory:
    - name: {{ gateway.install_dir | yaml_encode }}
    - user: {{ gateway.user | yaml_encode }}
    - group: {{ gateway.group | yaml_encode }}
    - dir_mode: "0755"
    - makedirs: True

evgw_deploy_key:
  file.managed:
    - name:  {{ gateway.deploy_key_file | yaml_encode }}
    - user:  {{ gateway.user | yaml_encode }}
    - group: {{ gateway.group | yaml_encode }}
    - contents_pillar: envio:gateway:commons:gateway:deploy_key
    - mode: "0600"
    - show_diff: false
    - require:
      - file: evgw_ssh_dir

evgw_backup_old_gw_stuff:
  module.run:
    - file.move:
      - src: {{ gateway.install_dir }}/config
      - dst: /tmp/config_backup

evgw_backup_old_json_db:
  module.run:
    - file.move:
      - src: {{ gateway.install_dir }}/database
      - dst: /tmp/database_backup

{% for file in gw_installdir %}
{% if file.startswith('.') not true %}
evgw_erase_old_gw_stuff_{{ file }}:
  file.absent:
    - name: {{ file }}
{% endif %}
{% endfor %}

evgw_repo:
  git.latest:
    - name:     git@github.com:enviosystems/envio-gateway-app-binary.git
    - identity: {{ gateway.deploy_key_file | yaml_encode }}
    - target:   {{ gateway.install_dir | yaml_encode }}
    - user:     {{ gateway.user | yaml_encode }}
    - force_reset: true
    - depth: 1
{# Some bbbs are running debian 7.11, and can't upgrade salt ... #}
{%- set saltver = salt['grains.get']('saltversioninfo') %}
{%- if saltver[0] < 2015 or (saltver[0] == 2015 and saltver[1] < 8) %}
    - force: true
{%- else %}
    - force_clone: true
{%- endif %}
{%- if gateway.git_rev is defined %}
#    - rev: {{ gateway.git_rev }}
    - rev: master
{%- else %}
  {%- if gateway.old_version %}
    - rev: master
  {%- else %}
    - rev: master
  {%- endif %}
{%- endif %}
    - require:
      - pkg: git
      - file: evgw_install_dir
      - file: evgw_deploy_key
      - supervisord: evgw_service_dead

evgw_restore_old_json_db:
  file.copy:
    - name: {{ gateway.install_dir }}/database
    - source: /tmp/database_backup

evgw_restore_old_gw_stuff:
  file.copy:
    - name: {{ gateway.install_dir }}/config/
    - source: /tmp/config_backup/cube_configs_storage.json

evgw_clean_old_database:
  file.absent:
    - name: /tmp/database_backup

evgw_clean_old_gw_stuff:
  file.absent:
    - name: /tmp/config_backup

#evgw_link_cfgs:
#  cmd.run:
#    - cwd: {{ gateway.install_dir }}/config/
#    - name: '/bin/ln -s local.cfg gateway.cfg'

evgw_adjust_debian_gw_app_version:
  module.run:
    - file.move:
      - src: {{ gateway.install_dir }}/{{ osmajorrelease == 10 and 'GatewayAPP_Secured_buster' or 'GatewayAPP_Secured_stretch' }}
      - dst: {{ gateway.install_dir }}/GatewayAPP_Secured

evgw_remove_unadjusted_app_version:
  file.absent:
    - name: {{ gateway.install_dir }}/{{ osmajorrelease == 10 and 'GatewayAPP_Secured_buster' or 'GatewayAPP_Secured_stretch' }}

evgw_add_permissions:
  file.managed:
    - name: {{ gateway.install_dir }}/GatewayAPP_Secured
    - mode: "0755"

evgw_log_directory:
  file.directory:
    - name: /var/log/envio
    - user: root
    - group: root
    - dir_mode: "0755"

{%- if envio_distro_version == "2020.7.1" or envio_distro_version == "2021.2.9" %}
evgw_apt_packages:
  pkg.installed:
    - pkgs:
      - build-essential
      - libffi-dev
      - libssl-dev
      - python-dev
      - sqlite3
      - libsqlite3-dev
{%- endif %}

