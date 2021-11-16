{% from slspath + "/map.jinja" import envioller with context %}
#
#include:
#  - supervisor

#need to stop new envioller service

envioller_service_dead:
  supervisord.dead:
    - name: envioller

envioller_service_remove:
  cmd.run:
    - name: supervisorctl remove envioller

envioller_erase_old_envioller_binaries:
  file.absent:
    - name: /home/debian/Envioller/bin
    - require:
      - sls: envio.envioller.install_without_service_start

envioller_erase_old_envioller_service:
  file.absent:
    - name: /etc/supervisor/conf.d/envioller.conf
