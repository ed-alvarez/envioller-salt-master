{%- set envio_distro_version = salt.grains.get('envio_distro_version') %}

{%- if envio_distro_version == "2020.7.1" or envio_distro_version == "2021.2.9" %}


{%- else %}

ifmetric:
  pkg.installed

{%- endif %}
