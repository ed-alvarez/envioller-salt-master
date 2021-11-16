{% from slspath + "/map.jinja" import gateway with context %}

evgw_config_file:
  file.managed:
{%- if gateway.old_version %}
    - name: {{ salt.file.join(gateway.install_dir, 'example.cfg') | yaml_encode }}
    - source: salt://{{ slspath }}/files/evgw-old-example.cfg.tpl
{%- else %}
    - name: {{ salt.file.join(gateway.install_dir, 'config', 'local.cfg') | yaml_encode }}
    - source: salt://{{ slspath }}/files/evgw-new-local.cfg.tpl
{%- endif %}
    - user:  {{ gateway.user | yaml_encode }}
    - group: {{ gateway.group | yaml_encode }}
    - mode:  644
    - template: jinja
    - context:
        config: {{ gateway.config | yaml }}

evgw_link_cfgs_config:
  file.symlink:
    - name: {{ gateway.install_dir }}/config/local.cfg
    - target: {{ gateway.install_dir }}/config/gateway.cfg


