{% from slspath + "/map.jinja" import envioscheduler with context %}
include:
  - gateway.modules.supervisor.v1

envioscheduler_supervisor_conf:
  file.managed:
    - name: /etc/supervisor/conf.d/envioscheduler.conf
    - user: root
    - group: root
    - mode: "0644"
    - source: salt://{{ slspath }}/files/supervisor_envioscheduler.conf.tpl
    - template: jinja
    - context:
        user: {{ envioscheduler.user | yaml_encode }}
        install_dir: {{ envioscheduler.install_dir | yaml_encode }}
        venv_dir: {{ envioscheduler.venv_dir | yaml_encode }}
    - watch_in:
      - service: supervisor
#    - require:
#      - pkg: supervisor

envioscheduler_supervisor_running:
  supervisord.running:
    - name: envioscheduler
    - restart: false
    - update: true
    - watch:
      - file: envioscheduler_supervisor_conf
