include:
  - gateway.modules.supervisor.v1

/usr/sbin/net-checker:
  file.managed:
    - user: root
    - group: root
    - mode: "0755"
    - source: salt://gateway/modules/net_checker/v1/files/net-checker
    - watch_in:
      - supervisord: net_checker_supervisor_service

/etc/supervisor/conf.d/net_checker.conf:
  file.managed:
    - name:
    - user: root
    - group: root
    - mode: "0644"
    - source: salt://gateway/modules/net_checker/v1/files/supervisor_conf
    - require:
      - file: /usr/sbin/net-checker
    - watch_in:
      - supervisord: net_checker_supervisor_service

net_checker_supervisor_service:
  supervisord.running:
    - name: net_checker
    - restart: true
    - update: true
    - require:
      - file: /etc/supervisor/conf.d/net_checker.conf
