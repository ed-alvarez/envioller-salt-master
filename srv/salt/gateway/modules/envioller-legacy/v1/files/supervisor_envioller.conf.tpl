[program:envioller]
user={{ user }}
directory={{ install_dir }}
command=bash -c 'mkdir -p /tmp/Envioller_Secured/ && rm -rf /tmp/Envioller_Secured/_MEI* && sleep 10 && {{ install_dir }}/bin/Envioller_Secured -c {{ install_dir }}/config'
environment=BACNET_IFACE="eth0"

stdout_logfile=/var/log/envio/envioller
redirect_stderr=true
stdout_logfile_maxbytes=10MB
stdout_logfile_backups=5
