{%- set gateway_config = salt.pillar.get('envio:gateway') %}

gw_status_etc_dir:
  file.directory:
    - names:
      - /etc/envio/gateway-status/client
    - user: debian
    - group: debian
    - dir_mode: "0755"
    - makedirs: True

gw_status_config_file:
  file.managed:
    - name: /etc/envio/gateway-status/client/local.cfg
    - source: salt://{{ slspath }}/files/local.cfg.tpl
    - user: debian
    - group: debian
    - mode: "0400"
    - template: jinja
    - context:
        config: {{ gateway_config | yaml }}
