# This formula is meant to replace the bash script located in
# master/migration/migrate.sh using a complete SaltStack solution.
#
# This way we can guarantee our process can be completed without
# interruptions or any risk of losing data.
#
# This formula is a proof-of-concept. DO NOT run in production
# environments.

{%- import_yaml "./defaults.yaml" as defaults %}

# First, we create the folder structure if it doesn't exist.
# Then we delete old files and we copy everything from the old master
# to the new one.

{% for mod in defaults.current_modules %}
module_{{ mod }}:
  file.absent:
    - name: {{ defaults.modules_path }}/{{ mod }}

create_module_{{ mod }}_folder:
  file.directory:
    - name: {{ defaults.modules_path }}/{{ mod }}/v1
{% endfor %}

# We have two states that do not fall into our `modules_path`.

{% for mfolder in defaults.stateless_folders %}
delete_folder_{{ mfolder }}:
  file.absent:
    - name: {{ defaults.sls_path }}/{{ mfolder }}

copy_{{ mfolder == 'mqtt-regional-broken' and 'mqtt-hub' or 'apt' }}_contents:
  file.copy:
    - name: {{ defaults.sls_path }}/{{ mfolder }}
    - source: {{ defaults.states_path }}/{{ mfolder == 'mqtt-regional-broken' and 'mqtt-hub' or 'apt' }}
    - mode: "0644"
    - makedirs: True
{% endfor %}

# Create main state structure

{% for mstate in defaults.main_states %}
create_{{ mstate }}_state:
  file.copy:
    {% if mstate.endswith('.sls') %}
    - name: {{ defaults.modules_path }}/{{ mstate.startswith('envio/') and mstate[6:-4] or mstate[:-4] }}/v1/init.sls
    {% else %}
    - name: {{ defaults.modules_path }}/{{ mstate.startswith('envio/') and mstate[6:] or mstate }}/v1
    {% endif %}
    - source: {{ defaults.states_path }}/{{ mstate }}
    - mode: "0644"
    - makedirs: True
{% endfor %}
