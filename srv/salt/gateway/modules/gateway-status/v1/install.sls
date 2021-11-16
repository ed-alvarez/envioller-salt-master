
gw_status_install_dir:
  file.directory:
    - names:
      - /home/debian/gateway-status
    - user: debian
    - group: debian
    - dir_mode: "0755"
    - makedirs: True

gw_status_install_files:
  file.managed:
    - name: /home/debian/gateway-status/run.py
    - source: salt://{{ slspath }}/files/run.py
    - user: debian
    - group: debian
    - mode: "0755"
    - template: jinja

gw_status_install_requirements:
  file.managed:
    - name: /home/debian/gateway-status/requirements.txt
    - source: salt://{{ slspath }}/files/requirements.txt
    - user:  debian
    - group: debian
    - mode: "0755"
    - template: jinja

gw_status_virtualenv_pkg:
  pkg.installed:
    - name: virtualenv

gw_status_virtualenv:
  virtualenv.managed:
    - python: python3.7
    - cwd: /home/debian/gateway-status
    - user: debian
    - name: /home/debian/gateway-status/venv
    - requirements: /home/debian/gateway-status/requirements.txt
    - require:
      - gw_status_virtualenv_pkg

source_gw-status:
  cmd.run:
    - name: bin/bash -c 'source /home/debian/gateway-status/venv/bin/activate'

install_pip_pippkg:
  pip.install:
    - pkgs: ['requests~=2.25.1', 'pydantic~=1.8.2', 'fastapi~=0.65.2']
#
# not nice but I could find a straight solution to install
# requirements.txt for python3.x
#
# workaround_to_install_pip3_packages:
#   cmd.run:
#     - name: /bin/bash -c 'source /home/debian/gateway-status/venv/bin/activate && pip3 install -r /home/debian/gateway-status/requirements.txt'
#     - cwd: /home/debian/gateway-status
#     - runas: debian
#     - require:
#       - gw_status_virtualenv
#       - gw_status_install_requirements

