{% from slspath + "/map.jinja" import bacnet_stack with context %}

include:
  - gateway.modules.supervisor.v1

bacnet_stack_supervisor_conf:
  file.managed:
    - name: /etc/supervisor/conf.d/bacnet_stack.conf
    - user: root
    - group: root
    - mode: "0644"
    - source: salt://{{ slspath }}/files/supervisor_bacnet_stack.conf.tpl
    - template: jinja
    - context:
        user: {{ bacnet_stack.user | yaml_encode }}
        install_dir: {{ bacnet_stack.install_dir | yaml_encode }}
    - watch_in:
      - service: supervisor
#    - require:
#      - pkg: supervisor

bacnet_stack_supervisor_running:
  supervisord.running:
    - name: bacserv
    - restart: false
    - update: true
    - watch:
      - file: bacnet_stack_supervisor_conf
