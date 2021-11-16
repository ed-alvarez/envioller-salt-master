/usr/local/bin/logclear.sh:
  file.managed:
    - name:
    - user: root
    - group: root
    - mode: "0500"
    - template: jinja
    - source: salt://{{ slspath }}/files/logclear.sh
    - context:
        slspath: {{ slspath }}

gwlogsclear_clear_logs_every_day:
  cron.present:
    - name: '/usr/local/bin/logclear.sh'
    - minute: 30
    - hour: 20

gwlogsclear_clear_logs_now:
  cmd.run:
    - name: 'sudo /usr/local/bin/logclear.sh'
