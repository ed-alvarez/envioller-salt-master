{% from slspath + "/map.jinja" import envioller_config with context %}

envioller_logrotate_file:
  file.managed:
    - name: /etc/logrotate.d/envioller
    - source: salt://{{ slspath }}/files/logrotate.tpl
    - user:  root
    - group: root
    - mode:  550
    - template: jinja
    - context:
        config: {{ envioller_config | yaml }}