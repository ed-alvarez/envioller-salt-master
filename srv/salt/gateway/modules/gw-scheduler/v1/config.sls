{% from slspath + "/map.jinja" import gw_scheduler_config with context %}
include:
  - .logrotate


gw-scheduler_install_dir:
  file.directory:
    - names:
      - /home/debian/logs
    - user: debian
    - group: debian
    - dir_mode: 755
    - makedirs: True

envio_log_directory:
  file.directory:
    - name: /var/log/envio
    - user: root
    - group: root
    - dir_mode: 755

gw-scheduler_log_directory:
  file.directory:
    - name: /var/log/envio/gw-scheduler
    - user: root
    - group: root
    - dir_mode: 755

/home/debian/logs/gw-scheduler:
  file.symlink:
    - target: /var/log/envio/gw-scheduler
    - require:
      - file: gw-scheduler_install_dir

gw-scheduler_etc_dir:
  file.directory:
    - names: 
      - /etc/envio/gw-scheduler
    - user: debian
    - group: debian
    - dir_mode: 755
    - makedirs: True

gw_scheduler_config_file:
  file.managed:
    - name: /etc/envio/gw-scheduler/local.cfg
    - source: salt://{{ slspath }}/files/gw-scheduler-local.cfg.tpl
    - user:  debian
    - group: debian
    - mode:  644
    - template: jinja
    - context:
        config: {{ gw_scheduler_config | yaml }}
