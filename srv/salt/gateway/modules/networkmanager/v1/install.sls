networkmanager_unmask:
  module.run:
    - systemd_service.unmask:
      - name: NetworkManager

networkmanager-pkg:
  pkg.installed:
    - name: network-manager
