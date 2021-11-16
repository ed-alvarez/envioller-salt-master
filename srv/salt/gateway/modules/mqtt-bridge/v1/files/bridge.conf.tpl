connection {{ mosquitto.bridge.id }}
address {{ mosquitto.bridge.address }}
cleansession true
clientid {{ mosquitto.bridge.id }}
topic {{ mosquitto.bridge.prefix_id }}/{{ mosquitto.bridge.client_id }}/{{ mosquitto.bridge.building_id }}/# both
bridge_identity {{ mosquitto.bridge.client_id }}
bridge_psk {{ mosquitto.bridge.psk }}
