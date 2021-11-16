{% from slspath + "/map.jinja" import gwltefunctions with context %}

{%- set envio_distro_version = salt.grains.get('envio_distro_version') %}

include:
  - gateway.modules.git.v1

gwltefunctions_remove_old_stuff:
  file.absent:
    - name: /home/debian/gwltefunctions

gwltefunctions_ssh_dir:
  file.directory:
    - name:  {{ salt.file.dirname(gwltefunctions.deploy_key_file) | yaml_encode }}
    - user:  {{ gwltefunctions.user | yaml_encode }}
    - group: {{ gwltefunctions.group | yaml_encode }}
    - dir_mode: "0700"
    - makedirs: true

gwltefunctions_install_dir:
  file.directory:
    - name: {{ gwltefunctions.install_dir | yaml_encode }}
    - user: {{ gwltefunctions.user | yaml_encode }}
    - group: {{ gwltefunctions.group | yaml_encode }}
    - dir_mode: "0755"
    - makedirs: True

gwltefunctions_deploy_key:
  file.managed:
    - name:  {{ gwltefunctions.deploy_key_file | yaml_encode }}
    - user:  {{ gwltefunctions.user | yaml_encode }}
    - group: {{ gwltefunctions.group | yaml_encode }}
    - contents_pillar: envio:gateway:commons:gwltefunctions:deploy_key
    - mode: "0600"
    - show_diff: false
    - require:
      - file: gwltefunctions_ssh_dir

gwltefunctions_repo:
  git.latest:
    - name: git@github.com:enviosystems/GW-LTE-functions.git
    - identity: {{ gwltefunctions.deploy_key_file | yaml_encode }}
    - target: {{ gwltefunctions.install_dir | yaml_encode }}
    - user: {{ gwltefunctions.user | yaml_encode }}
    - force_reset: true
    - force_clone: true
    - force_fetch: true
    - force_checkout: true
    - rev: master
    - depth: 1
    - require:
      - pkg: git
      - file: gwltefunctions_install_dir
      - file: gwltefunctions_deploy_key


gwltefunctions_extract_binaries:
  archive.extracted:
    - name: /
    - source: {{ gwltefunctions.install_dir }}/usblte_scripts.tar.gz

{%- if envio_distro_version == "2021.2.9" %}

gwltefunctions_install_service_lte_reset_init:
  cmd.run:
    - name: 'sudo update-rc.d multisim_lte_reset_init defaults'
    - cwd: {{ gwltefunctions.install_dir }}

gwltefunctions_install_service_ethppp_networkswitch:
  cmd.run:
    - name: 'sudo update-rc.d ethppp_networkswitch defaults'
    - cwd: {{ gwltefunctions.install_dir }}

gwltefunctions_enable_service_lte_reset_init:
  module.run:
    - systemd_service.enable:
      - name: multisim_lte_reset_init

gwltefunctions_start_service_lte_reset_init:
  module.run:
    - systemd_service.start:
      - name: multisim_lte_reset_init

{%- elif envio_distro_version == "2020.7.1" %}

gwltefunctions_install_service_lte_reset_init:
  cmd.run:
    - name: 'sudo update-rc.d lte_reset_init defaults'
    - cwd: {{ gwltefunctions.install_dir }}

gwltefunctions_install_service_ethppp_networkswitch:
  cmd.run:
    - name: 'sudo update-rc.d ethppp_networkswitch defaults'
    - cwd: {{ gwltefunctions.install_dir }}

gwltefunctions_enable_service_lte_reset_init:
  module.run:
    - systemd_service.enable:
      - name: lte_reset_init

gwltefunctions_start_service_lte_reset_init:
  module.run:
    - systemd_service.start:
      - name: lte_reset_init

{%- else %}

gwltefunctions_stop_old_service_lte_reset_init:
  module.run:
    - systemd_service.stop:
      - name: lte_reset_init

gwltefunctions_disable_old_service_lte_reset_init:
  module.run:
    - systemd_service.disable:
      - name: lte_reset_init

gwltefunctions_uninstall_old_service_lte_reset_init:
  cmd.run:
    - name: 'sudo update-rc.d lte_reset_init remove'
    - cwd: {{ gwltefunctions.install_dir }}

gwltefunctions_install_service_ppp_lte_reset_init:
  cmd.run:
    - name: 'sudo update-rc.d ppp_lte_reset_init defaults'
    - cwd: {{ gwltefunctions.install_dir }}

gwltefunctions_enable_service_ppp_lte_reset_init:
  module.run:
    - systemd_service.enable:
      - name: ppp_lte_reset_init

gwltefunctions_start_service_ppp_lte_reset_init:
  module.run:
    - systemd_service.start:
      - name: ppp_lte_reset_init

gwltefunctions_start_service_lte_reset_init:
  module.run:
    - systemd_service.start:
      - name: lte_reset_init

{%- endif %}

gwltefunctions_enable_service_ethppp_networkswitch:
  module.run:
    - systemd_service.enable:
      - name: ethppp_networkswitch

gwltefunctions_remove_old_stuff_post:
  file.absent:
    - name: /home/debian/gwltefunctions
