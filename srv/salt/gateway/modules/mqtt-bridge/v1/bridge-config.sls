{% from "gateway/modules/mqtt-bridge/v1/map.jinja" import mosquitto with context %}

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


