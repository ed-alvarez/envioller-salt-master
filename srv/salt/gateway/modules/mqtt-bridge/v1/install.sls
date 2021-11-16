{%- set os = salt.grains.get('os') %}
{%- set codename = salt.grains.get('oscodename') %}
{%- set osmajorrelease = salt.grains.get('osmajorrelease') %}
{%- set osrelease = salt.grains.get('osrelease') %}

{%- set envio_distro_version = salt.grains.get('envio_distro_version') %}

{%- if envio_distro_version == "2020.7.1" or envio_distro_version == "2021.2.9" %}

mosquitto-apt-transport-https:
  pkg.installed:
    - name: apt-transport-https

mosquitto-pkg:
  pkg.installed:
    - name: mosquitto

mosquitto-clients:
  pkg.installed:
    - name: mosquitto-clients

{%- else %}

{# %- if os != 'Debian' % #}
#  {# { raise('current salt state supports only Debian os') } #}
{# %- endif % #}

mosquitto-apt-transport-https:
  pkg.installed:
    - name: apt-transport-https

mosquitto-ppa:
  pkgrepo.managed:
    - humanname: Mosquitto PPA
    - name: deb https://repo.mosquitto.org/debian {{ codename }} main
    - file: /etc/apt/sources.list.d/mosquitto-{{ codename }}.list
    - key_url: https://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
    - require:
      - pkg: mosquitto-apt-transport-https
    - require_in:
      - pkg: mosquitto-pkg

# Available versions of Mosquitto for Debian are listed at
# https://packages.debian.org/search?keywords=mosquitto

mosquitto-pkg:
  pkg.installed:
    - name: mosquitto
{%- if osrelease == "9.11" %}
    - version: 1.6.7-0mosquitto1~stretch1
{%- elif osmajorrelease == 9 %}
    - version: 1.4.10-3+deb9u4
{%- elif osmajorrelease == 8 %}
    - version: 1.3.4-2+deb8u3
{# %- else % #}
  {# { raise('No suitable version found for current osmajorrelease: ' + osmajorrelease) } #}
{%- endif %}
{%- endif %}

