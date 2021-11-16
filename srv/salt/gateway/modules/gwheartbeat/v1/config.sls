{% from slspath + "/map.jinja" import gwheartbeat with context %}
{% from slspath + "/map.jinja" import gateway with context %}

gwheartbeat_config_file:
  file.managed:
    - name: {{ salt.file.join(gwheartbeat.install_dir, 'local.cfg') | yaml_encode }}
    - source: salt://{{ slspath }}/files/gwheartbeat-local.cfg.tpl
    - user:  {{ gwheartbeat.user | yaml_encode }}
    - group: {{ gwheartbeat.group | yaml_encode }}
    - mode:  644
    - template: jinja
    - context:
        config: {{ gateway.config | yaml }}
