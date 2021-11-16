{% from slspath + "/map.jinja" import envioller_config with context %}

include:
  - gateway.modules.envioller-legacy.v1.prepare_for_new_envioller
  - .install_without_service_start
  - gateway.modules.envioller-legacy.v1.stop_old_envioller
  - .config

envioller:
  service.running:
    - enable: True
