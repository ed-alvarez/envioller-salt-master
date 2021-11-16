#######################################
# MANAGED BY SALT DO NOT EDIT BY HAND #
#######################################
[general]
prefix_id:   {{ config.prefix_id }}
client_id:   {{ config.client_id }}
building_id: {{ config.building_id }}
timezone:    {{ config.timezone }}
gw_local_id: {{ config.gw_local_id }}
minion_id:   {{ grains['id'] }}


[mqtt]
client_id: gw-scheduler
host:        {{ config.mqtt_host|default }}
port:        {{ config.mqtt_port|default }}
username:    {{ config.mqtt_username|default }}
password:    {{ config.mqtt_password|default }}
keepalive:   60
certificate: {{ config.mqtt_ca_cert|default }}
clean_session: false

[database]
location: /var/lib/envio/gw-scheduler.db

[event-state-machine]
retention_period_minutes = 360
sleep_in_seconds = 10

