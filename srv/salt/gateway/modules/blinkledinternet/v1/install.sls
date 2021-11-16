{% from slspath + "/map.jinja" import blinkledinternet with context %}
{%- set cpuarch = salt.grains.get('cpuarch') %}
{%- set envio_distro_version = salt.grains.get('envio_distro_version') %}

{%- if cpuarch == "armv7l" %}

{%- if envio_distro_version == "2020.7.1" or envio_distro_version == "2021.2.9" %}

include:
  - gateway.modules.git.v1

blinkledinternet_ssh_dir:
  file.directory:
    - name:  {{ salt.file.dirname(blinkledinternet.deploy_key_file) | yaml_encode }}
    - user:  {{ blinkledinternet.user | yaml_encode }}
    - group: {{ blinkledinternet.group | yaml_encode }}
    - dir_mode: 700
    - makedirs: true

blinkledinternet_install_dir:
  file.directory:
    - name: {{ blinkledinternet.install_dir | yaml_encode }}
    - user: {{ blinkledinternet.user | yaml_encode }}
    - group: {{ blinkledinternet.group | yaml_encode }}
    - dir_mode: 755
    - makedirs: True

blinkledinternet_deploy_key:
  file.managed:
    - name:  {{ blinkledinternet.deploy_key_file | yaml_encode }}
    - user:  {{ blinkledinternet.user | yaml_encode }}
    - group: {{ blinkledinternet.group | yaml_encode }}
    - contents_pillar: envio:gateway:commons:blinkledinternet:deploy_key
    - mode: 600
    - show_diff: false
    - require:
      - file: blinkledinternet_ssh_dir

blinkledinternet_repo:
  git.latest:
    - name:     git@github.com:enviosystems/envio-blinkledinternet-binary.git
    - identity: {{ blinkledinternet.deploy_key_file | yaml_encode }}
    - target:   {{ blinkledinternet.install_dir | yaml_encode }}
    - user:     {{ blinkledinternet.user | yaml_encode }}
    - force_reset: true
    - force_clone: true
    - rev: master
    - depth: 1
    - require:
      - pkg: git
      - file: blinkledinternet_install_dir
      - file: blinkledinternet_deploy_key

blinkledinternet_add_permissions:
  file.copy:
    - name: {{ blinkledinternet.install_dir }}/BlinkLEDInternet
    - source: {{ blinkledinternet.install_dir }}/BlinkLEDInternet10x
    - mode: 777

{%- else %}

include:
  - gateway.modules.git.v1

blinkledinternet_ssh_dir:
  file.directory:
    - name:  {{ salt.file.dirname(blinkledinternet.deploy_key_file) | yaml_encode }}
    - user:  {{ blinkledinternet.user | yaml_encode }}
    - group: {{ blinkledinternet.group | yaml_encode }}
    - dir_mode: 700
    - makedirs: true

blinkledinternet_install_dir:
  file.directory:
    - name: {{ blinkledinternet.install_dir | yaml_encode }}
    - user: {{ blinkledinternet.user | yaml_encode }}
    - group: {{ blinkledinternet.group | yaml_encode }}
    - dir_mode: 755
    - makedirs: True

blinkledinternet_deploy_key:
  file.managed:
    - name:  {{ blinkledinternet.deploy_key_file | yaml_encode }}
    - user:  {{ blinkledinternet.user | yaml_encode }}
    - group: {{ blinkledinternet.group | yaml_encode }}
    - contents_pillar: envio:gateway:commons:blinkledinternet:deploy_key
    - mode: 600
    - show_diff: false
    - require:
      - file: blinkledinternet_ssh_dir

blinkledinternet_repo:
  git.latest:
    - name:  git@github.com:enviosystems/envio-blinkledinternet-binary.git
    - identity: {{ blinkledinternet.deploy_key_file | yaml_encode }}
    - target: {{ blinkledinternet.install_dir | yaml_encode }}
    - user: {{ blinkledinternet.user | yaml_encode }}
    - force_reset: true
    - force_clone: true
    - rev: master
    - depth: 1
    - require:
      - pkg: git
      - file: blinkledinternet_install_dir
      - file: blinkledinternet_deploy_key

blinkledinternet_add_permissions:
  file.managed:
    - name: {{ blinkledinternet.install_dir }}/BlinkLEDInternet
    - mode: 777
    - replace: false

{%- endif %}

{% for file in ['HowTo-BuildBinary.md', 'pyarmor-regfile-1.zip',
  'build_binary.sh', 'env', 'src', 'binary'] %}
blinkledinternet_remove_{{ file }}:
  file.absent:
    - name: {{ blinkledinternet.install_dir }}/{{ file }}
{% endofr %}

{%- endif %}
