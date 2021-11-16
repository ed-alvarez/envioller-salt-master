configsbackup-create-dir:
  file.directory:
    - names:
        - /home/debian/configsbackup/
    - user: debian
    - group: debian
    - mode: "0755"
    - clean: True
    - makedirs: True

/usr/local/bin/configsbackup.sh:
  file.managed:
    - name: '/usr/local/bin/configsbackup.sh'
    - user: root
    - group: root
    - mode: "0500"
    - template: jinja
    - source: salt://{{ slspath }}/files/configsbackup_sh

#    - context:
#        slspath: {{ slspath }}

#THIS TAKES BACKUPS ON A RANDOM DAY OF THE WEEK, EVERY WEEK
configsbackup_cronjob_backup_weekly:
  cron.present:
    - name: '/usr/local/bin/configsbackup.sh'
    - minute: random
    - hour: random
    - daymonth: '*'
    - month: '*'
    - dayweek: random
