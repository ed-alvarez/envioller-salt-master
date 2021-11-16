[program:gwheartbeat]
user={{ user }}
directory={{ install_dir }}
command=bash -c 'mkdir -p /tmp/GWHeartBeat_Secured/ && rm -rf /tmp/GWHeartBeat_Secured/_MEI* && sleep 5 && {{ install_dir }}/GWHeartBeat_Secured'

stdout_logfile=/var/log/envio/gwheartbeat
redirect_stderr=true
stdout_logfile_maxbytes=5MB
stdout_logfile_backups=1

autostart=true
