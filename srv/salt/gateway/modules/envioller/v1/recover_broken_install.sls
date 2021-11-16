{% from slspath + "/map.jinja" import envioller_versions with context %}

envioller_install_dir:
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

/home/debian/logs/envioller:
  file.symlink:
    - target: /var/log/envio/envioller
    - require:
      - file: envioller_install_dir

fix-apt-issues:
  cmd.run:
    - name: 'dpkg --configure -a'

envioller_dependencies_package:
  pkg.installed:
    - pkgs:
        #      - envioller
        - {{ envioller_versions.dependencies }}

envioller-dependencies_package_removal:
  cmd.run:
    - name: 'apt remove -yq envioller-dependencies* && apt purge -yq envioller-dependencies* '

envioller_package:
  pkg.installed:
    - pkgs:
#      - envioller
      - {{ envioller_versions.envioller }}
    - require:
        - pkg: envioller_dependencies_package

envioller:
  service.running:
    - enable: True


#
#  check for installed envioller
#  if envioller installed
#    check is envioller at curr version
#    if curr version
#      done
#    if (else) older version
#      check for installed dependencies
#      if dep installed
#        check dep version
#        if curr dep version
#          uninstall envioller
#          install newest envioller version
#        if older dep version
#          uninstall dependencies
#          install newest dependencies
#          install newest envioller
#      if dep not installed
#        uninstall dep
#        install newest dep
#        install newest envioller
#  if (else) envioller is not installed
#    check for installed dependencies
#    if dependencies installed
#      check dep version
#      if curr dependencies version
#        uninstall envioller
#        install newest envioller version
#      if (else) older dependencies version
#        uninstall dependencies
#        install newest dependencies
#        install newest envioller
#    if dependencies not installed
#      uninstall dependencies
#      install newest dependencies
#      install newest envioller
