[program:bacserv]
user={{ user }}
directory={{ install_dir }}
command={{ install_dir }}/bin/bacserv 123
autostart=false
