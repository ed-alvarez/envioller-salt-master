{% from slspath + "/map.jinja" import blinkledinternet with context %}
{%- set cpuarch = salt.grains.get('cpuarch') %}

{%- if cpuarch == "armv7l" %}
include:
  - gateway.modules.supervisor.v1

blinkledinternet_supervisor_conf:
  file.managed:
    - name:     /etc/supervisor/conf.d/blinkledinternet.conf
    - user:     root
    - group:    root
    - mode:     644
    - source:   salt://{{ slspath }}/files/supervisor_blinkledinternet.conf.tpl
    - template: jinja
    - context:
        user:        {{ blinkledinternet.user | yaml_encode }}
        install_dir: {{ blinkledinternet.install_dir | yaml_encode }}
    - watch_in:
      - service: supervisor
#    - require:
#      - pkg: supervisor

blinkledinternet_supervisor_running:
  supervisord.running:
    - name:    blinkledinternet
    - restart: true
    - update: true
    - watch:
      - file: blinkledinternet_supervisor_conf
{%- endif %}
