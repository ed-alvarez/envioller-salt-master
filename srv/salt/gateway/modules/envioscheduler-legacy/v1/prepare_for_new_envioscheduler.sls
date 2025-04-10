{% from slspath + "/map.jinja" import envioscheduler with context %}

envioscheduler_backup_old_gw_stuff:
  file.copy:
    - name: {{ envioscheduler.install_dir }}/config
    - source: /tmp/config_backup

envioscheduler_config_directory:
  file.directory:
    - names:
        - /etc/envio/gw-scheduler
    - user: debian
    - group: debian
    - dir_mode: "0755"
    - makedirs: True

envioscheduler_restore_old_envioscheduler_configs:
  file.copy:
    - name: /etc/envio/gw-scheduler
    - source: /tmp/config_backup/

envioscheduler_move_old_logs:
  module.run:
    - file.move:
      - src: /var/log/envio/envioscheduler
      - dst: /var/log/envio/envioscheduler.bak

envioscheduler_relink_old_logs:
  file.absent:
    - name: /home/debian/logs/envioscheduler
