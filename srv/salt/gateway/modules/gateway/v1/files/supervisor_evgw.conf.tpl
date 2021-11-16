{%- set envio_distro_version = salt.grains.get('envio_distro_version') %}
[program:evgw]
user={{ user }}
directory={{ install_dir }}
command=bash -c 'mkdir -p /tmp/GatewayAPP_Secured/ && rm -rf /tmp/GatewayAPP_Secured/_MEI* && sleep 30 && {{ install_dir }}/GatewayAPP_Secured'
{%- if envio_distro_version == "2021.2.9" %}
autostart=false
{%- endif %}

stdout_logfile=/var/log/envio/gateway
redirect_stderr=true
stdout_logfile_maxbytes=10MB
stdout_logfile_backups=10
