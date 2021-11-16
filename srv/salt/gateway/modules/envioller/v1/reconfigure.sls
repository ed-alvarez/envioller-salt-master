{% from slspath + "/map.jinja" import envioller_versions with context %}

include:
  - apt
  - .config

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

envioller_log_directory:
  file.directory:
    - name: /var/log/envio/envioller
    - user: root
    - group: root
    - dir_mode: "0755"

/home/debian/logs/envioller:
  file.symlink:
    - target: /var/log/envio/envioller
    - require:
      - file: envioller_install_dir

envioller_package:
  pkg.installed:
    - pkgs:
#      - envioller
      - {{ envioller_versions.envioller }}

envioller:
  service.running:
    - enable: True
