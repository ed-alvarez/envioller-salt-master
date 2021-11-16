{%- import_yaml "./defaults.yaml" as defaults %}

{%- set pkgspath = 'salt://files/packages' %}

envioller-dependencies:
  pkg.installed:
    - sources:
      - envioller-dependencies: |
        '{{ pkgspath }}/envioller-dependencies-
        {{ defaults.envio.gateway.envioller.versions.dependencies }}.deb'

envioller:
  pkg.installed:
    - sources:
      - envioller: |
        '{{ pkgspath }}/envioller-
        {{ defaults.envio.gateway.envioller.versions.envioller }}.deb'
    - require:
      - envioller-dependencies

