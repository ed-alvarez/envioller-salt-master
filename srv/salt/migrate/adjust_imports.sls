{%- set gateway_modules = salt['file.find']('/srv/salt/gateway/modules',type='f',name='*.sls') %}

{% set queries = [
  (' - git', ' - gateway.modules.git.v1'),
  (' - supervisor', ' - gateway.modules.supervisor.v1'),
  (' - envio.gwltefunctions.qmi-network', ' - gateway.modules.gwltefunctions.v1.qmi-network'),
  ('envio.gwltefunctions.install', 'gateway.modules.gwltefunctions.v1.install'),
  ('salt:\/\/logrotate\/templates', 'salt:\/\/gateway\/modules\/logrotate\/v1\/templates'),
  ('salt:\/\/envio\/net_checker\/files', 'salt:\/\/gateway\/modules\/net_checker\/v1\/files'),
  ('- networkmanager.', '- gateway.modules.networkmanager.v1.'),
  ('salt:\/\/networkmanager\/files', 'salt:\/\/gateway\/modules\/networkmanager\/v1\/files'),
  ('envio:apt-repository:url', 'envio:gateway:apt-repository:url'),
  ('envio:apt-repository:auth:user', 'envio:gateway:apt-repository:auth:user'),
  ('envio:apt-repository:auth:password', 'envio:gateway:apt-repository:auth:password')
] %}

{% for file in gateway_modules %}
{% for p, r in queries %}
replace {{ p }} in {{ file }}:
  file.replace:
    - name: {{ file }}
    - flags: ['IGNORECASE', 'MULTILINE']
    - pattern: "{{ p }}"
    - repl: "{{ r }}"
{% endfor %}
{% endfor %}
