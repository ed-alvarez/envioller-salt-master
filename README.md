# Envioller SaltStack

This repository is a complete rework of the current deployment environment whose main purpose is
to completely improve deployment times, reducing redundancy,
code repetition, and other non-standard states/formulas that could be considered harmful
to any deployment of this software.

With this approach, we can also guarantee more complexity in our deployments such as
upgrading software while keeping old, already deployed, configurations files intact and
even upgrade user data to work with future software updates.

# What has changed

This project removes 99% of all unnecessary `cmd.run` states that are not considered idempotent
for counterparts that are available as either native SaltStack modules or states.

This guarantees a flawless deployment process that avoids repetition with data that already
exists and doesn't need to be taken into account while running certain states.

Several examples of bad practices can be found in the following state files:

`/srv/salt/gateway/modules/bacnet_stack/v1/install.sls:53`

```yaml
bacnet_stack_extract_binaries:
  cmd.run:
    - name: '/bin/tar -xvpf bin.tar.gz'
    - cwd: {{ bacnet_stack.install_dir }}
```

Replaced for:

```yaml
bacnet_stack_extract_binaries:
  archive.extracted:
    - name: {{ bacnet_stack.install_dir }}
    - source: {{ bacnet_stack.install_dir }}/bin.tar.gz
```

`/srv/salt/gateway/modules/bacnet_stack/v1/install.sls:63`

```yaml
bacnet_stack_delete_folders:
  cmd.run:
    - name: 'rm -rf src'
    - cwd: {{ bacnet_stack.install_dir }}
    - runas:  {{ bacnet_stack.user | yaml_encode }}
```

Replaced for:

```yaml
bacnet_stack_delete_folders:
  file.absent:
    - name: { bacnet_stack.install_dir }}/src
```

`/srv/salt/gateway/modules/envioller-legacy/v1/install.sls:171`

```yaml
envioller_erase_old_gw_stuff:
  cmd.run:
    - name: 'sudo find . -not -name "." -and -not -name ".." -maxdepth 1 -exec rm -rf {} +'
    - cwd: {{ envioller.install_dir }}
```

Replaced for:

```jinja
{%- set gw_stuff = salt['file.find'](envioller.install_dir,type='f',name='*.sls') %}

{% for file in gw_stuff %}
{% if file.startswith('.') not true %}
envioller_erase_old_gw_stuff_{{ file }}:
  file.absent:
    - name: {{ file }}
{% endif %}
{% endfor %}
```

Several basic blocks have also been replaced for a more native way. For example,
we can make our files executable by setting their `mode` flag to `0755` without
having to run a `cmd.run` state to run `chmod +x`

Before:

```yaml
envioller_executable:
  cmd.run:
    - name: 'chmod +x Envioller_Secured'
    - cwd: {{ envioller.install_dir }}/bin/
```

After:

```yaml
envioller_executable:
  file.managed:
    - source: {{ envioller.install_dir }}/bin/Envioller_Secured
    - mode: "0755"
```

If the file already is managed as `0755` there is no need to run `chmod +x` again.
This makes it completely idempotent.

Other state files contain countless `cmd.run` states using conditionals to
make sure a directory exists and then execute `rm -rf` if the conditional is true.
This approach defeats the main purpose of SaltStack, which is being idempotent.

We can achieve the same goal, with far better performance and avoid repetition by using the following code:

Before:

```yaml
envioller_erase_backup_envioller_configs:
  cmd.run:
    - name: 'if test -d /tmp/config_backup; then rm -rf /tmp/config_backup; fi'
```

After:

```yaml
envioller_erase_backup_envioller_configs:
  file.absent:
    - name: /tmp/config_backup
```

This philosophy has been implemented throughout the entire project and all of the `cmd.run` states that are 100% unnecessary have been removed and replaced for SaltStack's idempotent state and module executions.

# Points to consider

Code repetition has also been minimized. Files that use jinja's if-else blocks to manipulate how these files are interpreted use a bad code analogy. Example:

`/srv/salt/gateway/modules/envioller-legacy/v1/install.sls`

Before:

```jinja
{%- if envio_distro_version == "2020.7.1" or envio_distro_version == "2021.2.9" %}

include:
  - gateway.modules.supervisor.v1
  - gateway.modules.git.v1

envioscheduler_service_dead:
  supervisord.dead:
    - name: envioscheduler

envioscheduler_ssh_dir:
  file.directory:
    - name:  {{ salt.file.dirname(envioscheduler.deploy_key_file) | yaml_encode }}
    - user:  {{ envioscheduler.user | yaml_encode }}
    - group: {{ envioscheduler.group | yaml_encode }}
    - dir_mode: 700
    - makedirs: true
{%- else %}

{#
    Same code all over again
    but with a small difference.
#}

include:
  - gateway.modules.supervisor.v1
  - gateway.modules.git.v1

envioscheduler_service_dead:
  supervisord.dead:
    - name: envioscheduler

envioscheduler_ssh_dir:
  file.directory:
    - name:  {{ salt.file.dirname(envioscheduler.deploy_key_file) | yaml_encode }}
    - user:  {{ envioscheduler.user | yaml_encode }}
    - group: {{ envioscheduler.group | yaml_encode }}
    - dir_mode: 700
    - makedirs: true

envioscheduler_apt_packages:
  pkg.installed:
    - pkgs:
      - libevent-dev
      - python-all-dev
      - python3-venv
      - python3-dev
      - libxml2
      - libxml2-dev
      - python3-lxml
      - libxml2-dev
      - libxslt1-dev
      - zlib1g-dev
      - python3-pip
      - sqlite3
      - libsqlite3-dev
{%- endif %}
```

After:

```jinja
include:
  - gateway.modules.supervisor.v1
  - gateway.modules.git.v1

envioller_service_dead:
  supervisord.dead:
    - name: envioller

envioller_ssh_dir:
  file.directory:
    - name: {{ salt.file.dirname(envioller.deploy_key_file) | yaml_encode }}
    - user: {{ envioller.user | yaml_encode }}
    - group: {{ envioller.group | yaml_encode }}
    - dir_mode: "0700"
    - makedirs: true

{% if envio_distro_version == "2020.7.1" or envio_distro_version == "2021.2.9" %}
envioscheduler_apt_packages:
  pkg.installed:
    - pkgs:
      - libevent-dev
      - python-all-dev
      - python3-venv
      - python3-dev
      - libxml2
      - libxml2-dev
      - python3-lxml
      - libxml2-dev
      - libxslt1-dev
      - zlib1g-dev
      - python3-pip
      - sqlite3
      - libsqlite3-dev
{% endif %}
```

Systemd units management has also been replaced in favor of `salt.modules.systemd_service`.

`/srv/salt/gateway/modules/networkmanager/v1/install.sls`

Before:

```yaml
networkmanager_unmask:
  cmd.run:
    - name: '/bin/systemctl unmask NetworkManager'
```

After:

```yaml
networkmanager_unmask:
  module.run:
    - systemd_service.unmask:
      - name: NetworkManager
```

As well as multiple file deletion replacing `rm -rf`:

`/srv/salt/gateway/modules/snaptoolbelt/v1/install.sls`

Before:

```yaml
snaptoolbelt_remove_oldenv:
  cmd.run:
    - name: 'sudo rm -rf env wheels requirements.txt requirements-to-freeze.txt'
    - cwd: {{ snaptoolbelt.install_dir }}
```

After:

```yaml
{% for file in ['env', 'wheels', 'requirements.txt', 'requirements-to-freeze.txt'] %}
snaptoolbelt_remove_oldenv_{{ file }}:
  file.absent:
    - name: {{ snaptoolbelt.install_dir }}/{{ file }}
{%- endif %}
```

# HTTP-less deploy

A previously showcased HTTP-less deployment has also been implemented in this project. The main structure is located in `/srv/salt/gateway/modules/envioller/v1/`

Files located in `/srv/salt/gateway/modules/envioller/v1/files/packages/` are used to install
all of the dependencies required and the packages themselves using the SaltStack transport layer. This solution avoids APT completely.

You can read more [here](/srv/salt/gateway/modules/envioller/v1/README.md).

# Migrating the master

This project also takes into consideration the usage of SaltStack states directly on the master. This can be achieved by installing a minion in the same server the master is running.

With this, we can work with states and modules in our very own configured minion using our out-of-reach folder structure for states dedicated to deployments into minions only. This means we can also guarantee SaltStack's idempotency even in our very own master.

The script we've used to demonstrate this usage is located in `/migration/migrate.sh`.

This script contains many `rm -rf`, `mkdir`, `cp`, and `find` calls. We can replace all of this with states, simplifying the process a ton and also saving time, and guaranteeing our approach completely even if it fails. Example:

Before:

```bash
rm -rf "../srv/salt/mqtt-regional-broker" && mkdir -p "../srv/salt/mqtt-regional-broker"  && cp -r ${states_path}/mqtt-hub/*                "../srv/salt/mqtt-regional-broker"
rm -rf "../srv/salt/apt"                  && mkdir -p "../srv/salt/apt"                   && cp -r ${states_path}/apt/*                     "../srv/salt/apt"

rm -rf ${modules_path}/supervisor            && mkdir -p "${modules_path}/supervisor/v1"            && cp -r ${states_path}/supervisor.sls                ${modules_path}/supervisor/v1/init.sls
rm -rf ${modules_path}/bacnet_stack          && mkdir -p "${modules_path}/bacnet_stack/v1"          && cp -r ${states_path}/envio/bacnet_stack/*          ${modules_path}/bacnet_stack/v1
rm -rf ${modules_path}/blinkledinternet      && mkdir -p "${modules_path}/blinkledinternet/v1"      && cp -r ${states_path}/envio/blinkledinternet/*      ${modules_path}/blinkledinternet/v1
rm -rf ${modules_path}/git                   && mkdir -p "${modules_path}/git/v1"                   && cp -r ${states_path}/git.sls                       ${modules_path}/git/v1/init.sls
rm -rf ${modules_path}/logging               && mkdir -p "${modules_path}/logging/v1/"              && cp -r ${states_path}/envio/logging.sls             ${modules_path}/logging/v1/init.sls
rm -rf ${modules_path}/net_checker           && mkdir -p "${modules_path}/net_checker/v1"           && cp -r ${states_path}/envio/net_checker/*           ${modules_path}/net_checker/v1
rm -rf ${modules_path}/opcdaclassic          && mkdir -p "${modules_path}/opcdaclassic/v1"          && cp -r ${states_path}/envio/opcdaclassic/*          ${modules_path}/opcdaclassic/v1
rm -rf ${modules_path}/swapfile              && mkdir -p "${modules_path}/swapfile/v1"              && cp -r ${states_path}/envio/swapfile/*              ${modules_path}/swapfile/v1
rm -rf ${modules_path}/snaptoolbelt          && mkdir -p "${modules_path}/snaptoolbelt/v1"          && cp -r ${states_path}/envio/snaptoolbelt/*          ${modules_path}/snaptoolbelt/v1
rm -rf ${modules_path}/ifmetric              && mkdir -p "${modules_path}/ifmetric/v1"              && cp -r ${states_path}/ifmetric.sls                  ${modules_path}/ifmetric/v1/init.sls
rm -rf ${modules_path}/networkmanager        && mkdir -p "${modules_path}/networkmanager/v1"        && cp -r ${states_path}/networkmanager/*              ${modules_path}/networkmanager/v1
rm -rf ${modules_path}/mqtt-bridge/v1        && mkdir -p "${modules_path}/mqtt-bridge/v1"           && cp -r ${states_path}/mqtt-bridge/*                 ${modules_path}/mqtt-bridge/v1
rm -rf ${modules_path}/envioller             && mkdir -p "${modules_path}/envioller/v1"             && cp -r ${states_path}/envio/envioller/*             ${modules_path}/envioller/v1
rm -rf ${modules_path}/envioller-legacy      && mkdir -p "${modules_path}/envioller-legacy/v1"      && cp -r ${states_path}/envio/envioller-legacy/*      ${modules_path}/envioller-legacy/v1
rm -rf ${modules_path}/envioscheduler-legacy && mkdir -p "${modules_path}/envioscheduler-legacy/v1" && cp -r ${states_path}/envio/envioscheduler-legacy/* ${modules_path}/envioscheduler-legacy/v1
rm -rf ${modules_path}/gw-scheduler          && mkdir -p "${modules_path}/gw-scheduler/v1"          && cp -r ${states_path}/envio/gw-scheduler/*          ${modules_path}/gw-scheduler/v1
rm -rf ${modules_path}/gateway               && mkdir -p "${modules_path}/gateway/v1"               && cp -r ${states_path}/envio/gateway/*               ${modules_path}/gateway/v1
rm -rf ${modules_path}/gwheartbeat           && mkdir -p "${modules_path}/gwheartbeat/v1"           && cp -r ${states_path}/envio/gwheartbeat/*           ${modules_path}/gwheartbeat/v1
rm -rf ${modules_path}/gwltefunctions        && mkdir -p "${modules_path}/gwltefunctions/v1"        && cp -r ${states_path}/envio/gwltefunctions/*        ${modules_path}/gwltefunctions/v1
rm -rf ${modules_path}/gwlogsclear           && mkdir -p "${modules_path}/gwlogsclear/v1"           && cp -r ${states_path}/envio/gwlogsclear/*           ${modules_path}/gwlogsclear/v1
rm -rf ${modules_path}/gateway-status        && mkdir -p "${modules_path}/gateway-status/v1"        && cp -r ${states_path}/envio/gateway-status/*        ${modules_path}/gateway-status/v1
rm -rf ${modules_path}/logrotate             && mkdir -p "${modules_path}/logrotate/v1"             && cp -r ${states_path}/logrotate/*                   ${modules_path}/logrotate/v1
```

After:

```jinja
{%- import_yaml "./defaults.yaml" as defaults %}

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
```

Then we can call this state by simply running:

```bash
$ salt-call "masters-minion" migrate
```

# Final notes

This concept can be improved even beyond with SaltStack's Python API and add even more native support and complexity for our software deployments, as well as handling software upgrades that deprecate or drop features completely and change configuration files and user data without losing anything.
