#######################################
# MANAGED BY SALT DO NOT EDIT BY HAND #
#######################################
[evgw]
clientid:   {{ config.client_id }}
buildingid: {{ config.building_id }}
mqtt_username: {{ config.mqtt_username|default }}
mqtt_password: {{ config.mqtt_password|default }}
mqtt_host: {{ config.mqtt_host|default }}
mqtt_port: {{ config.mqtt_port|default }}
mqtt_ca_cert: {{ config.mqtt_ca_cert|default }}
enviodebug: True
snap_radio_type: 1
snap_radio: /dev/ttyUSB0
