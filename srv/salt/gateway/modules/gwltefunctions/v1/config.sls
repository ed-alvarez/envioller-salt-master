{% from slspath + "/map.jinja" import gwltefunctions with context %}

include:
  - gateway.modules.gwltefunctions.v1.qmi-network
  - .logrotate

gwltefunctions_stop_service_ethppp_networkswitch:
  cmd.run:
    - name: 'sudo systemctl stop ethppp_networkswitch'
#    - require:
#        - sls: gateway.modules.gwltefunctions.v1.install

/etc/envio:
  file.directory:
    - name:
    - user: root
    - group: root
    - mode:  "0755"

/etc/envio/ethppp_networkswitch.conf:
  file.managed:
    - name:
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - source: salt://{{ slspath }}/files/ethppp_networkswitch_conf
    - makedirs: true
    - create: true
    - context:
        slspath: {{ slspath }}

/etc/dhcp/dhclient.conf:
  file.managed:
    - name:
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - source: salt://{{ slspath }}/files/dhclient_conf
    - context:
        slspath: {{ slspath }}

/etc/ntp.conf:
  file.managed:
    - name:
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - source: salt://{{ slspath }}/files/ntp_conf
    - context:
        slspath: {{ slspath }}

/etc/network/interfaces:
  file.managed:
    - name:
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - source: salt://{{ slspath }}/files/interfaces
    - context:
        slspath: {{ slspath }}

/etc/ppp/peers/quectel-ppp:
  file.managed:
    - name:
    - user: debian
    - group: debian
    - mode: "0644"
    - template: jinja
    - source: salt://{{ slspath }}/files/quectel-ppp
    - context:
        slspath: {{ slspath }}

/etc/envio/qmi-network.conf:
  file.managed:
    - name:
    - user: debian
    - group: debian
    - mode: "0644"
    - template: jinja
    - source: salt://{{ slspath }}/files/qmi-network_conf
    - context:
        slspath: {{ slspath }}

/etc/envio/default.script:
  file.managed:
    - name:
    - user: debian
    - group: debian
    - mode: "0644"
    - template: jinja
    - source: salt://{{ slspath }}/files/default_script
    - context:
        slspath: {{ slspath }}

psmisc-pkg:
  pkg.installed:
    - name: psmisc

ifmetric-pkg:
  pkg.installed:
    - name: ifmetric

nmap-pkg:
  pkg.installed:
    - name: nmap

gwltefunctions_reload_config:
  module.run:
    - systemd_service.systemctl_reload:

gwltefunctions_restart_service_ethppp_networkswitch:
  module.run:
    - systemd_service.restart:
      - name: ethppp_networkswitch
