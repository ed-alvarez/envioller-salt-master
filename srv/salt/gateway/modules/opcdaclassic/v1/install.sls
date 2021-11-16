{% from slspath + "/map.jinja" import opcdaclassic with context %}

include:
  - gateway.modules.git.v1

opcdaclassic_ssh_dir:
  file.directory:
    - name:  {{ salt.file.dirname(opcdaclassic.deploy_key_file) | yaml_encode }}
    - user:  {{ opcdaclassic.user | yaml_encode }}
    - group: {{ opcdaclassic.group | yaml_encode }}
    - dir_mode: "0700"
    - makedirs: true

opcdaclassic_install_dir:
  file.directory:
    - name: {{ opcdaclassic.install_dir | yaml_encode }}
    - user: {{ opcdaclassic.user | yaml_encode }}
    - group: {{ opcdaclassic.group | yaml_encode }}
    - dir_mode: "0755"
    - makedirs: True

opcdaclassic_deploy_key:
  file.managed:
    - name:  {{ opcdaclassic.deploy_key_file | yaml_encode }}
    - user:  {{ opcdaclassic.user | yaml_encode }}
    - group: {{ opcdaclassic.group | yaml_encode }}
    - contents_pillar: envio:gateway:commons:opcdaclassic:deploy_key
    - mode: "0600"
    - show_diff: false
    - require:
      - file: opcdaclassic_ssh_dir

opcdaclassic_repo:
  git.latest:
    - name: git@github.com:enviosystems/envio-opc-da-client.git
    - identity: {{ opcdaclassic.deploy_key_file | yaml_encode }}
    - target: {{ opcdaclassic.install_dir | yaml_encode }}
    - user: {{ opcdaclassic.user | yaml_encode }}
    - force_reset: true
    - force_clone: true
    - rev: master
    - depth: 1
    - require:
      - pkg: git
      - file: opcdaclassic_install_dir
      - file: opcdaclassic_deploy_key

opcdaclassic_add_permissions:
  file.managed:
    - name: {{ opcdaclassic.install_dir }}/bin/EnvioOPCClient
    - mode: "0755"
