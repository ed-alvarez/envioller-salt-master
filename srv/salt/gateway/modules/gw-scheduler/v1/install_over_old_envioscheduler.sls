{% from slspath + "/map.jinja" import gw_scheduler_config with context %}

include:
  - gateway.modules.envioscheduler-legacy.v1.prepare_for_new_envioscheduler
  - .install_without_service_start
  - gateway.modules.envioscheduler-legacy.v1.stop_old_envioscheduler
  - .config

gw-scheduler:
  service.running:
    - enable: True