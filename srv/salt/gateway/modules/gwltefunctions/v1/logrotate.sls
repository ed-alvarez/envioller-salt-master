{% from slspath + "/map.jinja" import gwltefunctions with context %}

ethppp_networkswitch_logrotate_file:
  file.managed:
    - name: /etc/logrotate.d/ethppp_networkswitch
    - source: salt://{{ slspath }}/files/logrotate.tpl
    - user: root
    - group: root
    - mode: "0550"
    - template: jinja
    - context:
        config: {{ gwltefunctions | yaml }}
