[program:envioscheduler]
user={{ user }}
directory={{ install_dir }}
command=bash -c 'mkdir -p /tmp/EnvioScheduler_Secured/ && rm -rf /tmp/EnvioScheduler_Secured/_MEI* && sleep 10 && {{ install_dir }}/EnvioScheduler_Secured -c {{ install_dir }}/config'

stdout_logfile=/var/log/envio/envioscheduler
redirect_stderr=true
stdout_logfile_maxbytes=10MB
stdout_logfile_backups=5

autostart=true
