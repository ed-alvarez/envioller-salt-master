{% from slspath + "/map.jinja" import gw_scheduler_versions with context %}

include:
  - apt
  - .config

gw-scheduler_install_dir:
  file.directory:
    - names:
      - /home/debian/logs
    - user: debian
    - group: debian
    - dir_mode: "0755"
    - makedirs: True

envio_log_directory:
  file.directory:
    - name: /var/log/envio
    - user: root
    - group: root
    - dir_mode: "0755"

gw-scheduler_log_directory:
  file.directory:
    - name: /var/log/envio/gw-scheduler
    - user: root
    - group: root
    - dir_mode: "0755"

/home/debian/logs/gw-scheduler:
  file.symlink:
    - target: /var/log/envio/gw-scheduler
    - require:
      - file: gw-scheduler_install_dir

gw-scheduler_package:
  pkg.installed:
    - pkgs:
#      - gw-scheduler
      - {{ gw_scheduler_versions.gwscheduler }}

gw-scheduler:
  service.running:
    - enable: True
