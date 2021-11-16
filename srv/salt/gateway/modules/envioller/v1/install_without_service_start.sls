{% from slspath + "/map.jinja" import envioller_versions with context %}

include:
  - apt

envioller-old-log-move:
  cmd.run:
    - name: 'mv /var/log/envio/envioller /var/log/envio/envioller.bak'

fix-apt-issues-envioller_withoutservicestart:
  cmd.run:
    - name: 'dpkg --configure -a'

envioller_package:
  pkg.installed:
    - pkgs:
      - envioller: {{ envioller_versions.envioller }}

#DO not start service yet...
#envioller:
#  service.running:
#    - enable: True