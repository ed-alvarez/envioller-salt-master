#######################################
# MANAGED BY SALT DO NOT EDIT BY HAND #
#######################################
[general]
prefix_id:   {{ config.prefix_id }}
client_id:   {{ config.client_id }}
building_id: {{ config.building_id }}
gw_local_id: {{ config.gw_local_id }}
gw_bbb_id:   {{ grains['id'] }}

[loop]
enabled: true
sleep_seconds: 60

[mqtt]
host: localhost
port: 1883
