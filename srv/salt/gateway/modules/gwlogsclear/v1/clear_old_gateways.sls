dpkg_reconfigure_step:
  cmd.run:
    - name: 'dpkg --configure -a'

{% for unit in ['apache2.service', 'bonescript.socket', 'bonescript.service',
  'bonescript-autorun.service', 'nginx'] %}
stop_service_{{ unit }}:
  - module.run:
    - systemd_service.stop:
      - name: {{ unit }}

disable_service_{{ unit }}:
  - module.run:
      - systemd_service.disable:
        - name: {{ unit }}
{% endfor %}

{% for pkgname in ['nginx', 'nginx-common', 'nginx-full', 'alsa-utils',
  'bb-node-red-installer', 'uwsgi', 'uwsgi-core', 'uwsgi-plugin-python3',
  'pastebinit', 'libmatheval1', 'bone101', 'c9-core-installer', 'bonescript',
  'ardupilot-copter-3.6-bbbmini', 'ardupilot-copter-3.6-blu', 'ardupilot-copter-3.6-pocket',
  'ardupilot-rover-3.4-bbbmini', 'ardupilot-rover-3.4-blue', 'ardupilot-rover-3.4-pocket',
  'doc-beaglebone-getting-started', 'adwaita-icon-theme', 'x11-common', 'x11proto-core-dev',
  'x11proto-input-dev', 'x11proto-kb-dev'] %}
pkg_remove_{{ pkgname }}:
  pkg.removed:
    - name: {{ pkgname }}

pkg_purge_{{ pkgname }}:
  pkg.purged:
    - name: {{ pkgname }}
{% endfor %}

{% for dir in [ '/var/cache/doc-beaglebone-getting-started', '/var/cache/doc-beaglebone-getting-started',
'/var/lib/cloud9', '/var/lib/cloud9_backup_examples/', '/opt/cloud9'] %}
delete_dir_{{ dir }}:
  file.absent:
    - name: {{ dir }}
{% endfor %}

install_supervisor:
  pip.installed:
    - name: supervisor

supervisor_service_config:
  file.managed:
    - name: /etc/init.d/supervisor
    - source: salt://{{ slspath }}/files/initd_supervisor.conf
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja

restart_supervisor:
  - module.run:
    - systemd_service.restart:
      - name: supervisor

{% for pkg in ['libpython-dev', 'libpython-stdlib',
  'libpython-stdlib', 'libpython2-dev', 'libpython2-stdlib',
  'libpython2.7', 'libpython2.7-dev', 'libpython2.7-minimal', 'libpython2.7-stdlib',
  'python-minimal', 'python2-minimal', 'python2.7-minimal',
  'automake', 'autotools-dev', 'build-essential', 'dpkg-dev' 'g++', 'g++-8', 'gcc',
  'gcc-8', 'libc6-dev', 'libdbus-1-dev', 'libevent-dev', 'libexpat1-dev', 'libffi-dev', 'libgcc-8-dev',
  'libicu-dev', 'libncurses-dev', 'libncurses5-dev', 'libpython3-dev', 'libpython3.7-dev',
  'libsqlite3-dev', 'libssl-dev', 'libstdc++-8-dev', 'libtool', 'libusb-1.0-0-dev',
  'libxml2-dev', 'libxslt1-dev', 'linux-libc-dev',
  'manpages-dev', 'python3-dev', 'python3.7-dev', 'zlib1g-dev',
  'icu-devtools', 'libevent-extra-2.1-6', 'libevent-openssl-2.1-6', 'nodejs',
  'nodejs-doc', 'icu-devtools', 'libbrotli1', 'libc-ares2', 'libevent-extra-2.1-6',
  'libevent-openssl-2.1-6', 'libnode64', 'librobotcontrol', 'uwsgi', 'uwsgi-core', 'uwsgi-plugin-python3',
  'libmatheval1', 'apt-transport-https', 'iptraf', 'libasan5', 'libatomic1', 'libcc1-0', 'libfftw3-single3', 'libiio-utils',
  'libsamplerate0', 'libubsan1', 'netcat', 'libgomp1', 'libiio0', 'python2'] %}
remove_pkg_{{ pkg }}:
  pkg.removed:
    - name: {{ pkg }}

purge_pkg_{{ pkg }}:
  pkg.purged:
    - name: {{ pkg }}
{% endfor %}
