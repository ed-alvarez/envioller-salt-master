{% from slspath + "/map.jinja" import gw_scheduler_versions with context %}

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

/home/debian/logs/gw-scheduler:
  file.symlink:
    - target: /var/log/envio/gw-scheduler
    - require:
      - file: gw-scheduler_install_dir

fix-apt-issues:
  cmd.run:
    - name: 'dpkg --configure -a'

gw-scheduler_dependencies_package:
  pkg.installed:
    - pkgs:
        #      - gw-scheduler
        - {{ gw_scheduler_versions.dependencies }}

gw-scheduler_package:
  pkg.installed:
    - pkgs:
#      - gw-scheduler
      - {{ gw_scheduler_versions.gwscheduler }}

gw-scheduler:
  service.running:
    - enable: True


#
#  check for installed gw-scheduler
#  if gw-scheduler installed
#    check is gw-scheduler at curr version
#    if curr version
#      done
#    if (else) older version
#      check for installed dependencies
#      if dep installed
#        check dep version
#        if curr dep version
#          uninstall gw-scheduler
#          install newest gw-scheduler version
#        if older dep version
#          uninstall dependencies
#          install newest dependencies
#          install newest gw-scheduler
#      if dep not installed
#        uninstall dep
#        install newest dep
#        install newest gw-scheduler
#  if (else) gw-scheduler is not installed
#    check for installed dependencies
#    if dependencies installed
#      check dep version
#      if curr dependencies version
#        uninstall gw-scheduler
#        install newest gw-scheduler version
#      if (else) older dependencies version
#        uninstall dependencies
#        install newest dependencies
#        install newest gw-scheduler
#    if dependencies not installed
#      uninstall dependencies
#      install newest dependencies
#      install newest gw-scheduler
