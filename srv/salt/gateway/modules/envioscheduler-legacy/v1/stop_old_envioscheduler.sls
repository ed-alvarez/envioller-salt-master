{% from slspath + "/map.jinja" import envioscheduler with context %}
#
#include:
#  - supervisor

#need to stop old envioscheduler service

envioscheduler_service_dead:
  supervisord.dead:
    - name: envioscheduler

envioscheduler_service_remove:
  cmd.run:
    - name: supervisorctl remove envioscheduler

envioscheduler_erase_old_renvioschedule_binaries:
  file.absent:
    - name: /home/debian/EnvioScheduler_Secured/EnvioScheduler_Secured
    - require:
      - sls: envio.gw-scheduler.install_without_service_start

envioller_erase_old_envioschedule_service:
  file.absent:
    - name: /etc/supervisor/conf.d/envioscheduler.conf
