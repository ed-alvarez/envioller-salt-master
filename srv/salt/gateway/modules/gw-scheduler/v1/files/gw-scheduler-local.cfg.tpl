{%- macro gw_scheduler_conf(gw_scheduler_config) %}
    {%- for key, value in gw_scheduler_config.items() %}

[{{ key }}]
        {%- if value is mapping %}
            {%- for key2, value2 in value.items() %}
                        {%- if value2 is number %}
{{ key2 }}: {{ value2 }}
                        {%- elif value2 is string %}
{{ key2 }}: {{ value2 }}
                        {%- elif value2 is undefined or value2 is none%}
{{ key2 }}:
                        {%- endif -%}
            {%- endfor -%}
        {%- endif -%}
    {%- endfor -%}
{%- endmacro -%}
# GW-SCHEDULER configuration file.
#
# **** DO NOT EDIT THIS FILE ****
#
# This file is managed by Salt via {{ source }}
{{ gw_scheduler_conf(config) }}
