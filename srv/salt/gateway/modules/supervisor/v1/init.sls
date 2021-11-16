{%- set envio_distro_version = salt.grains.get('envio_distro_version') %}

{%- if envio_distro_version == "2020.7.1" or envio_distro_version == "2021.2.9" %}

supervisor:
  pip.installed:
    - names:
      - supervisor
  service.running:
    - enable: True

supervisor_service_enable:
  module.run:
    - systemd_service.enable:
      - name: supervisor.service

{%- else %}

supervisor:
  pkg.installed: []
  service.running:
    - enable: True
    - require:
      - pkg: supervisor

{%- endif %}

