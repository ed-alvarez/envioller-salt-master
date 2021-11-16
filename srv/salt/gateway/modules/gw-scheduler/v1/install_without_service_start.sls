{% from slspath + "/map.jinja" import gw_scheduler_versions with context %}

include:
  - apt

gw-scheduler-old-log-move:
  cmd.run:
    - name: 'mv /var/log/envio/envioscheduler /var/log/envio/envioscheduler.bak'

fix-apt-issues:
  cmd.run:
    - name: 'dpkg --configure -a'

gw-scheduler_package:
  pkg.installed:
    - pkgs:
      - gw-scheduler: {{ gw_scheduler_versions.gwscheduler }}

#DO not start service yet...
#gw-scheduler:
#  service.running:
#    - enable: True