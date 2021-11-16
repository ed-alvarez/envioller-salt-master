{% from slspath + "/map.jinja" import gateway with context %}
include:
  - gateway.modules.supervisor.v1

evgw_supervisor_conf:
  file.managed:
    - name: /etc/supervisor/conf.d/evgw.conf
    - user: root
    - group: root
    - mode: "0644"
    - source: salt://{{ slspath }}/files/supervisor_evgw.conf.tpl
    - template: jinja
    - context:
        user: {{ gateway.user | yaml_encode }}
        install_dir: {{ gateway.install_dir | yaml_encode }}
        venv_dir: { gateway.venv_dir | yaml_encode }}
    - watch_in:
      - service: supervisor
#    - require:
#      - pkg: supervisor

evgw_supervisor_running:
  supervisord.running:
    - name:    evgw
    - restart: false
    - update: true
    - watch:
      - file: evgw_supervisor_conf
