{% from slspath + "/map.jinja" import gwltefunctions with context %}

gwltefunctions_stop_service_ethppp_networkswitch_qmi:
  module.run:
    - systemd_service.stop:
      - name: ethppp_networkswitch

/usr/bin:
  file.directory:
    - user: root
    - group: root
    - mode: "0755"

/usr/bin/qmi-network:
  file.managed:
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - source: salt://{{ slspath }}/files/qmi-network
    - context:
        slspath: {{ slspath }}
