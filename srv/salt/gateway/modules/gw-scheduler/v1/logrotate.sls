{% from slspath + "/map.jinja" import gw_scheduler_config with context %}

gw-scheduler_logrotate_file:
  file.managed:
    - name: /etc/logrotate.d/gw-scheduler
    - source: salt://{{ slspath }}/files/logrotate.tpl
    - user:  root
    - group: root
    - mode:  "0550"
    - template: jinja
    - context:
        config: {{ gw_scheduler_config | yaml }}
