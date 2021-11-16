{% from slspath + "/map.jinja" import envioller_config with context %}

include:
  - .logrotate

envioller_install_dir:
  file.directory:
    - names:
      - /home/debian/logs
    - user: debian
    - group: debian
    - dir_mode: "0755"
    - makedirs: True

envio_log_directory_envioller:
  file.directory:
    - name: /var/log/envio
    - user: root
    - group: root
    - dir_mode: "0755"

envioller_log_directory:
  file.directory:
    - name: /var/log/envio/envioller
    - user: root
    - group: root
    - dir_mode: "0755"

/home/debian/logs/envioller:
  file.symlink:
    - target: /var/log/envio/envioller
    - require:
      - file: envioller_install_dir

envioller_etc_dir:
  file.directory:
    - names:
      - /etc/envio/envioller
    - user: debian
    - group: debian
    - dir_mode: "0755"
    - makedirs: True

envioller_config_file:
  file.managed:
    - name: /etc/envio/envioller/local.cfg
    - source: salt://{{ slspath }}/files/envioller-local.cfg.tpl
    - user: debian
    - group: debian
    - mode: "0644"
    - template: jinja
    - context:
        config: {{ envioller_config | yaml }}
