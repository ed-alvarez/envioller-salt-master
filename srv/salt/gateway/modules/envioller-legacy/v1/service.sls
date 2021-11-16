{% from slspath + "/map.jinja" import envioller with context %}
include:
  - gateway.modules.supervisor.v1

envioller_supervisor_conf:
  file.managed:
    - name: /etc/supervisor/conf.d/envioller.conf
    - user: root
    - group: root
    - mode: "0644"
    - source: salt://{{ slspath }}/files/supervisor_envioller.conf.tpl
    - template: jinja
    - context:
        user: {{ envioller.user | yaml_encode }}
        install_dir: {{ envioller.install_dir | yaml_encode }}
        venv_dir: {{ envioller.venv_dir | yaml_encode }}
    - watch_in:
      - service: supervisor
#    - require:
#      - pkg: supervisor

envioller_supervisor_running:
  supervisord.running:
    - name: envioller
    - restart: false
    - update: true
    - watch:
      - file: envioller_supervisor_conf
