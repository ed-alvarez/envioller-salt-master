{% from slspath + "/map.jinja" import gohttptunnel with context %}

#
# this will create the folder to install gohttptunnel
#

gohttptunnel_install_dir:
  file.directory:
    - names:
      - {{ gohttptunnel.home | yaml_encode }}
    - user: {{ gohttptunnel.user  | yaml_encode }}
    - group: {{ gohttptunnel.group | yaml_encode }}
    - dir_mode: "0755"
    - makedirs: True

#
# this will create the folder to install gohttptunnel's certificates
#

gohttptunnel_install_cert_dir:
  file.directory:
    - names:
      - '{{ gohttptunnel.home }}/certs'
    - user: {{ gohttptunnel.user  | yaml_encode }}
    - group: {{ gohttptunnel.group | yaml_encode }}
    - dir_mode: "0700"
    - makedirs: True

#
# this will copy the executable file to its folder
#

gohttptunnel_install_bin:
  file.managed:
    - user: {{ gohttptunnel.user | yaml_encode }}
    - group: {{ gohttptunnel.user | yaml_encode }}
    - mode:  "0555"
    - names:
      - '{{ gohttptunnel.home }}/tunnel':
        - source: salt://{{ slspath }}/files/tunnel

#
# this will create client.crt and client.key
#

# This will be generated in /etc/pki/ by default.
# It can be changed in /etc/salt/minion.
generate_client_crt:
  module.run:
    - create_self_signed_cert:
      - tls_dir: EnvioSystemsClient
      - CN: EnvioSystems
      - C: DE
      - ST: Berlin
      - L: Berlin
      - O: Envio Systems GmbH
      - OU: Hardware Team
      - emailAddress: hardware@enviosystems.com

{% for cfile in ['EnvioSystemsClient.crt', 'EnvioSystemsClient.key'] %}
copy_generated_certs:
  file.copy:
    - name: {{ gohttptunnel.home }}/certs/client{{ cfile[18:] }}
    - source: {{ cfile }}
{% endfor %}

#
# this will copy the gohttptunnel configuration file
#

gohttptunnel_install_conf:
  file.managed:
    - user: {{ gohttptunnel.user | yaml_encode }}
    - group: {{ gohttptunnel.user | yaml_encode }}
    - mode: "0644"
    - names:
      - '{{ gohttptunnel.home }}/tunnel.conf':
        - source: salt://{{ slspath }}/files/tunnel.conf
    - template: jinja
    - context:
        tunnel_home: {{ gohttptunnel.home | yaml_encode }}
        tunnels: {{ gohttptunnel.tunnels }}

#
# this will register gohttptunnel as a service
#

gohttptunnel_install_service:
  file.managed:
    - user: root
    - group: root
    - mode: "0644"
    - names:
      - '/etc/systemd/system/gohttptunnel.service':
        - source: salt://{{ slspath }}/files/gohttptunnel-service.conf
    - template: jinja
    - context:
        user: {{ gohttptunnel.user | yaml_encode }}
        bin: {{ gohttptunnel.home }}/tunnel
        conf: {{ gohttptunnel.home }}/tunnel.conf

#
# this will enable service gohttptunnel and will force service to reload if
# configuration changes
#

gohttptunnel_service_running:
  service.running:
    - name: gohttptunnel
    - enable: True
    - watch:
      - file: {{ gohttptunnel.home }}/tunnel.conf
