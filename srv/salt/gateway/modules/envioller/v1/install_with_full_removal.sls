{% from slspath + "/map.jinja" import envioller_versions with context %}

include:
  - apt
  - .config

fix-apt-issues_fullremoval:
  cmd.run:
    - name: 'dpkg --configure -a'

envioller-dependencies_package_removal:
  cmd.run:
    - name: 'apt remove -yq envioller*'

envioller_package:
  pkg.installed:
    - pkgs:
      - envioller: {{ envioller_versions.envioller }}

envioller:
  service.running:
    - enable: True
