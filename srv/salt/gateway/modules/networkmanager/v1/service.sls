networkmanager-service:
  service.running:
    - name: NetworkManager
    - enable: True

/etc/NetworkManager/NetworkManager.conf:
  file.managed:
    - name:
    - user: root
    - group: root
    - mode: "0644"
    - source: salt://gateway/modules/networkmanager/v1/files/NetworkManager_conf
