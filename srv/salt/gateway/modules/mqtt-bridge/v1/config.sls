{% from "gateway/modules/mqtt-bridge/v1/map.jinja" import mosquitto with context %}

{%- do salt.test.assertion(mosquitto.bridge.psk|length) %}

mosquitto-conf-create-dir:
  file.directory:
    - names:
      - {{ mosquitto.config_dir   | yaml_encode }}
      - {{ mosquitto.include_dir  | yaml_encode }}
    - user: root
    - group: root
    - mode: "0755"
    - clean: true
    - makedirs: True

mosquitto-conf-include-warning:
  file.managed:
    - name: {{ salt.file.join(mosquitto.config_dir, 'MANAGED-BY-SALT') | yaml_encode }}
    - user: root
    - group: root
    - mode: "0644"
    - contents: "WARNING: This directory is managed by Salt!"
    - clean: true
    - require:
      - file: mosquitto-conf-create-dir

mosquitto-conf-file-default:
  file.managed:
    - name: {{ mosquitto.conf_file | yaml_encode }}
    - user: root
    - group: root
    - mode: "0644"
    - source: salt://gateway/modules/mqtt-bridge/v1/files/mosquitto.conf.tpl
    - template: jinja
    - context:
      mosquitto: {{ mosquitto | yaml }}
    - require:
      - file: mosquitto-conf-create-dir
    - watch_in:
      - service: mosquitto

mosquitto-conf-file-bridge:
  file.managed:
    - name: {{ mosquitto.conf_file_bridge | yaml_encode }}
    - user: root
    - group: root
    - mode: "0644"
    - source: salt://gateway/modules/mqtt-bridge/v1/files/bridge.conf.tpl
    - template: jinja
    - context:
      mosquitto: {{ mosquitto | yaml }}
    - require:
      - file: mosquitto-conf-create-dir
    - watch_in:
      - service: mosquitto

mosquitto-persistence-dir:
  file.directory:
    - name: {{ mosquitto.persistence_location | yaml_encode }}
    - user: mosquitto
    - group: root
    - dir_mode: "0755"
    - require_in:
      - service: mosquitto

