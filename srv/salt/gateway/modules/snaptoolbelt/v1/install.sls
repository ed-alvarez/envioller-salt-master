{% from slspath + "/map.jinja" import snaptoolbelt with context %}
{%- set cpuarch = salt.grains.get('cpuarch') %}

{%- if cpuarch == "armv7l" %}
include:
  - gateway.modules.git.v1

snaptoolbelt_ssh_dir:
  file.directory:
    - name:  {{ salt.file.dirname(snaptoolbelt.deploy_key_file) | yaml_encode }}
    - user:  {{ snaptoolbelt.user | yaml_encode }}
    - group: {{ snaptoolbelt.group | yaml_encode }}
    - dir_mode: "0700"
    - makedirs: true

snaptoolbelt_install_dir:
  file.directory:
    - name: {{ snaptoolbelt.install_dir | yaml_encode }}
    - user: {{ snaptoolbelt.user | yaml_encode }}
    - group: {{ snaptoolbelt.group | yaml_encode }}
    - dir_mode: "0755"
    - makedirs: True

snaptoolbelt_deploy_key:
  file.managed:
    - name: {{ snaptoolbelt.deploy_key_file | yaml_encode }}
    - user: {{ snaptoolbelt.user | yaml_encode }}
    - group: {{ snaptoolbelt.group | yaml_encode }}
    - contents_pillar: envio:gateway:commons:snaptoolbelt:deploy_key
    - mode: "0600"
    - show_diff: false
    - require:
      - file: snaptoolbelt_ssh_dir

snaptoolbelt_repo:
  git.latest:
    - name: git@github.com:enviosystems/envio-snaptoolbelt.git
    - identity: {{ snaptoolbelt.deploy_key_file | yaml_encode }}
    - target: {{ snaptoolbelt.install_dir | yaml_encode }}
    - user: {{ snaptoolbelt.user | yaml_encode }}
    - force_reset: true
    - depth: 1
    - force_clone: true
    - rev: master
    - require:
      - pkg: git
      - file: snaptoolbelt_install_dir
      - file: snaptoolbelt_deploy_key

snaptoolbelt_executable:
  file.managed:
    - name: {{ snaptoolbelt.install_dir }}/snaptoolbeltbin/snaptoolbelt
    - mode: "0755"

{% for file in ['env', 'wheels', 'requirements.txt', 'requirements-to-freeze.txt'] %}
snaptoolbelt_remove_oldenv_{{ file }}:
  file.absent:
    - name: {{ snaptoolbelt.install_dir }}/{{ file }}
{%- endif %}
