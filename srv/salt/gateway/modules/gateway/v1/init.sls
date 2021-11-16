{% from slspath + "/map.jinja" import gateway with context %}
{% if gateway.install %}
include:
  - .install
  - .config
  - .service
{% endif %}
