[general]
server_url: https://status.eng.envio.systems/external
target_id: {{ grains['id'] }}
poll_frequency_seconds: 180
secret_access_key: {{ config.commons.status_server.access_token|default }}