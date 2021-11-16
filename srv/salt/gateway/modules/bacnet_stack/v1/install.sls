{% from slspath + "/map.jinja" import bacnet_stack with context %}

include:
  - gateway.modules.git.v1

#bacnet_stack_service_dead:
#  supervisord.dead:
#    - name: bacserv

bacnet_stack_ssh_dir:
  file.directory:
    - name: {{ salt.file.dirname(bacnet_stack.deploy_key_file) | yaml_encode }}
    - user: {{ bacnet_stack.user | yaml_encode }}
    - group: {{ bacnet_stack.group | yaml_encode }}
    - dir_mode: "0700"
    - makedirs: true

bacnet_stack_install_dir:
  file.directory:
    - name: {{ bacnet_stack.install_dir | yaml_encode }}
    - user: {{ bacnet_stack.user | yaml_encode }}
    - group: {{ bacnet_stack.group | yaml_encode }}
    - dir_mode: "0755"
    - makedirs: True

bacnet_stack_deploy_key:
  file.managed:
    - name: {{ bacnet_stack.deploy_key_file | yaml_encode }}
    - user: {{ bacnet_stack.user | yaml_encode }}
    - group: {{ bacnet_stack.group | yaml_encode }}
    - contents_pillar: envio:gateway:commons:bacnet_stack:deploy_key
    - mode: "0600"
    - show_diff: false
    - require:
      - file: bacnet_stack_ssh_dir

bacnet_stack_repo:
  git.latest:
    - name: git@github.com:enviosystems/bacnet-stack.git
    - identity: {{ bacnet_stack.deploy_key_file | yaml_encode }}
    - target: {{ bacnet_stack.install_dir | yaml_encode }}
    - user: {{ bacnet_stack.user | yaml_encode }}
    - force_reset: true
    - force_clone: true
    - rev: master
    - depth: 1
    - require:
      - pkg: git
      - file: bacnet_stack_install_dir
      - file: bacnet_stack_deploy_key
#     - supervisord: bacnet_stack_service_dead

bacnet_stack_extract_binaries:
  archive.extracted:
    - name: {{ bacnet_stack.install_dir }}
    - source: {{ bacnet_stack.install_dir }}/bin.tar.gz

bacnet_stack_delete_folders:
  file.abstent:
    - {{ bacnet_stack.install_dir }}/src
