{% from slspath + "/map.jinja" import envioller with context %}
{% from slspath + "/map.jinja" import gateway with context %}

envioller_config_file:
  file.managed:
    - name: {{ salt.file.join(envioller.install_dir, 'config', 'local.cfg') | yaml_encode }}
    - source: salt://{{ slspath }}/files/envioller-local.cfg.tpl
    - user:  {{ envioller.user | yaml_encode }}
    - group: {{ envioller.group | yaml_encode }}
    - mode:  644
    - template: jinja
    - context:
        config: {{ gateway.config | yaml }}
