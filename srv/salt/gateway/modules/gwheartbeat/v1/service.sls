{% from slspath + "/map.jinja" import gwheartbeat with context %}
include:
  - gateway.modules.supervisor.v1

gwheartbeat_supervisor_conf:
  file.managed:
    - name: /etc/supervisor/conf.d/gwheartbeat.conf
    - user: root
    - group: root
    - mode: "0644"
    - source: salt://{{ slspath }}/files/supervisor_gwheartbeat.conf.tpl
    - template: jinja
    - context:
        user: {{ gwheartbeat.user | yaml_encode }}
        install_dir: {{ gwheartbeat.install_dir | yaml_encode }}
        venv_dir: {{ gwheartbeat.venv_dir | yaml_encode }}
    - watch_in:
      - service: supervisor
#    - require:
#      - pkg: supervisor

gwheartbeat_supervisor_running:
  supervisord.running:
    - name: gwheartbeat
    - restart: false
    - update: true
    - watch:
      - file: gwheartbeat_supervisor_conf
