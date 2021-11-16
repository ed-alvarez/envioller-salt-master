{% from "./map.jinja" import logrotate with context %}

logrotate-config:
  file.managed:
    - name: {{ logrotate.conf_file }}
    - source: salt://gateway/modules/logrotate/v1/templates/logrotate.conf.tmpl
    - template: jinja
    - user: {{ salt['pillar.get']('logrotate:config:user', logrotate.user) }}
    - group: {{ salt['pillar.get']('logrotate:config:group', logrotate.group) }}
    - mode: {{ salt['pillar.get']('logrotate:config:mode', '644') }}
    - context:
        logrotate: {{ logrotate|tojson }}

logrotate-directory:
  file.directory:
    - name: {{ logrotate.include_dir }}
    - user: {{ salt['pillar.get']('logrotate:config:user', logrotate.user) }}
    - group: {{ salt['pillar.get']('logrotate:config:group', logrotate.group) }}
    - mode: "0755"
    - makedirs: True

logrotate-cron:
  file.managed:
    - name: {{ logrotate.cron_file }}
    - source: salt://gateway/modules/logrotate/v1/templates/logrotate.cron.tmpl
    - template: jinja
    - user: {{ salt['pillar.get']('logrotate:config:user', logrotate.user) }}
    - group: {{ salt['pillar.get']('logrotate:config:group', logrotate.group) }}
    - mode: {{ salt['pillar.get']('logrotate:config:mode', '755') }}
    - context:
        logrotate: {{ logrotate|tojson }}

logrotate-cron-remove:
  file.absent:
    - name: {{ logrotate.absent_cron_file }}
