{% from slspath + "/map.jinja" import envioller with context %}

envioller_backup_old_gw_stuff:
  cmd.run:
    - name: 'if test -d config; then cp -rfp config /tmp/config_backup; fi'
    - cwd: {{ envioller.install_dir }}

envioller_config_directory:
  file.directory:
    - names:
        - /etc/envio/envioller
    - user: debian
    - group: debian
    - dir_mode: "0755"
    - makedirs: True

envioller_restore_old_envioller_configs:
  file.copy:
    - name: /etc/envio/envioller
    - source: /tmp/config_backup

envioller_move_old_logs:
  module.run:
    - file.move:
      - src: /var/log/envio/envioller
      - dst: /var/log/envio/envioller.bak

envioller_relink_old_logs:
  file.absent:
    - name: /home/debian/logs/envioller

#do not erase old configs
#envioller_erase_backup_envioller_configs:
#  cmd.run:
#    - name: 'if test -d /tmp/config_backup && test -d /etc/envio/envioller/; then rm -rf /tmp/config_backup; fi'


#need to restart new envioller service
