{% from "gateway/modules/networkmanager/v1/map.jinja" import networkmanager with context %}

include:
  {%- if networkmanager.install %}
  - gateway.modules.networkmanager.v1.install
  {%- endif %}
  - gateway.modules.networkmanager.v1.service
