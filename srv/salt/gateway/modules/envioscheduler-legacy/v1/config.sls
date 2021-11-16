{% from slspath + "/map.jinja" import envioscheduler with context %}
{% from slspath + "/map.jinja" import gateway with context %}

envioscheduler_config_file:
  file.managed:
    - name: {{ salt.file.join(envioscheduler.install_dir, 'config', 'local.cfg') | yaml_encode }}
    - source: salt://{{ slspath }}/files/envioscheduler-local.cfg.tpl
    - user: {{ envioscheduler.user | yaml_encode }}
    - group: {{ envioscheduler.group | yaml_encode }}
    - mode: "0644"
    - template: jinja
    - context:
        config: {{ gateway.config | yaml }}
