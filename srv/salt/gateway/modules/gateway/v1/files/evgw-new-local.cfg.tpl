#######################################
# MANAGED BY SALT DO NOT EDIT BY HAND #
#######################################
[config]
prefix_id:   {{ config.prefix_id }}
client_id:   {{ config.client_id }}
building_id: {{ config.building_id }}
timezone:    {{ config.timezone }}
gw_local_id:    {{ config.gw_local_id }}

snap_serial_type: 1
snap_port: {{ config.snap_port }}
snap_address: 00003f
snap_tcp_port: 48625
snap_license_file: ./config/license.dat

mqtt_broker_url:  {{ config.mqtt_host|default }}
mqtt_broker_port: {{ config.mqtt_port|default }}
mqtt_username:    {{ config.mqtt_username|default }}
mqtt_password:    {{ config.mqtt_password|default }}
mqtt_broker_keepalive: 60
mqtt_certificate: {{ config.mqtt_ca_cert|default }}

lpc_broadcast_period: 3600

modbus_poller_config_module: config.modbus_poller

log_file_path: ./logs/gateway.log
log_file_count: 1
log_file_max_size: 52428800
log_file_level: INFO
log_console_level: INFO
log_root_level: INFO

local_db_store_enabled: True
local_db_store_only_when_offline: True
local_db_republish_enabled: False

snap_aes_encryption_enabled: {{ config.snap_aes_encryption_enabled|default }}
cube_ping_interval: {{ config.cube_ping_interval|default }}

cube_updater_timeout: {{ config.cube_updater_timeout|default }}
cube_updater_max_attempts: {{ config.cube_updater_max_attempts|default }}
cube_stdin_timeout:  {{ config.cube_stdin_timeout|default }}
