#
# This state file is used to configure the envio apt repository
#
# this is done in 3 steps:
#
# 1.- install de TLS certificate as the repository url is HTTPS using a self-signed certificate
# 2.- install de auth.conf as the repository is protected with user and password
# 3.- install the source.list in order to be able to install the packages located at that repository
#

{%- set oscodename = salt.grains.get('oscodename') %}

{%- if oscodename == "buster" %}

envio-apt-ca-cert-copy:
  file.managed:
    - user: root
    - group: root
    - mode: '0744'
    - names:
      - /usr/local/share/ca-certificates/repo.infra.eu.envio.systems.crt:
        - source: salt://apt/files/repo.infra.eu.envio.systems.crt

/usr/local/share/keyrings/:
  file.directory:
    - user: root
    - group: root
    - file_mode: '0744'
    - dir_mode: '0744'
    - makedirs: True

envio-envioller-gpg-key:
  file.managed:
    - user: root
    - group: root
    - mode: '0744'
    - names:
        - /usr/local/share/keyrings/envioller.gpg.key:
            - source: salt://apt/files/envioller.gpg.key
              #required by envio-buster.list.tpl

envio-apt-ca-cert-install:
  cmd.run:
    - name: update-ca-certificates
    - onchanges:
      - file: /usr/local/share/ca-certificates/repo.infra.eu.envio.systems.crt

envio-apt-auth-conf:
  file.managed:
    - user: root
    - group: root
    - mode: '0400'
    - names:
      - /etc/apt/auth.conf.d/repo.infra.eu.envio.systems.conf:
        - source: salt://apt/files/auth.conf.d/repo.infra.eu.envio.systems.conf.tpl
    - template: jinja
    - context:
        user: {{ salt.pillar.get('envio:gateway:apt-repository:auth:user') | yaml_encode }}
        password: {{ salt.pillar.get('envio:gateway:apt-repository:auth:password') | yaml_encode }}

envio-apt-source-list:
  file.managed:
    - user: root
    - group: root
    - mode: '0744'
    - require:
      - envio-apt-auth-conf
    - names:
      - /etc/apt/sources.list.d/envio.list:
        - source: salt://apt/files/envio-buster.list.tpl
    - template: jinja
    - context:
        url_base: {{ salt.pillar.get('envio:gateway:apt-repository:url') | yaml_encode }}

envio-envioller-gpg-key-add-key:
  pkgrepo.managed:
    - file: /etc/apt/sources.list.d/envio.list
    - key_url: /usr/local/share/keyrings/envioller.gpg.key

{%- endif %}
