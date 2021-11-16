
gw_status_service_config_file:
  file.managed:
    - name: /etc/systemd/system/gateway-status.service
    - source: salt://{{ slspath }}/files/gateway-status.service
    - user:  debian
    - group: debian
    - mode:  755

gateway-status:
  service.running:
    - enable: True