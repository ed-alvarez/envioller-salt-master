{% from slspath + "/map.jinja" import envioller with context %}

envioller_backup_old_gw_stuff:
  file.copy:
    - name: /tmp/config_backup
    - source: {{ envioller.install_dir }}/config

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
