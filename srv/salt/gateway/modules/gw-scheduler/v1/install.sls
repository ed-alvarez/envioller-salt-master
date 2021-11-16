{% from slspath + "/map.jinja" import gw_scheduler_versions with context %}

include:
  - apt
  - .config


fix-apt-issues:
  cmd.run:
    - name: 'dpkg --configure -a'


gw-scheduler_package:
  pkg.installed:
    - pkgs:
      - gw-scheduler: {{ gw_scheduler_versions.gwscheduler }}

gw-scheduler:
  service.running:
    - enable: True