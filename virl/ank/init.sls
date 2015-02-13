{% set ank = salt['pillar.get']('virl:ank', salt['grains.get']('ank', '19401')) %}
{% set ank_live = salt['pillar.get']('virl:ank_live', salt['grains.get']('ank_live', '19402')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy-wsa.esl.cisco.com:80/')) %}
{% set virltype = salt['grains.get']('virl_type', 'stable') %}
{% set cml = salt['grains.get']('cml', False ) %}
{% set venv = salt['pillar.get']('behave:environment', 'stable') %}
{% set ank_ver_fixed = salt['pillar.get']('virl:ank_ver_fixed', salt['grains.get']('ank_ver_fixed', False)) %}
{% set ank_ver = salt['pillar.get']('virl:ank_ver', salt['grains.get']('ank_ver', '0.10.8')) %}
{% set ank_cisco_ver = salt['pillar.get']('virl:ank_cisco_ver', salt['grains.get']('ank_cisco_ver', '0.10.8')) %}
{% set ank_webui = salt['pillar.get']('virl:ank_webui', salt['grains.get']('ank_webui', '0.10.8')) %}
{% set ank_collector = salt['pillar.get']('virl:ank_collector', salt['grains.get']('ank_collector', '0.10.8')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

{% if not masterless %}

/var/cache/virl/ank files:
  file.recurse:
    {% if ank_ver_fixed %}
    - source: "salt://fixed/ank"
    - name: /var/cache/virl/fixed/ank
    {% else %}
    - name: /var/cache/virl/ank
    - source: "salt://ank/{{ venv }}/"
    {% endif %}
    - order: 1
    - user: virl
    - group: virl
    - file_mode: 755

{% endif %}

/etc/init.d/ank-cisco-webserver:
  {% if not masterless %}
  file.managed:
    - source: "salt://virl/ank/files/ank-cisco-webserver.init"
  {% else %}
  file.copy:
    - force: true
    - source: /srv/salt/virl/ank/files/ank-cisco-webserver.init
  {% endif %}
    - mode: 0755
    - unless:
      - grep {{ ank }} /etc/init.d/ank-cisco-webserver

/etc/init.d/virl-vis:
  file.absent

/etc/rc2.d/S98virl-vis:
  file.absent

/etc/rc2.d/S98ank-webserver:
  file.absent

/etc/init.d/ank-webserver:
  file.absent

/etc/rc2.d/S98live-vis-webserver:
  file.absent

/etc/init.d/live-vis-webserver:
  file.absent

/etc/init.d/virl-vis-processor:
  {% if not masterless %}
  file.managed:
    - source: "salt://virl/ank/files/virl-vis-processor.init"
  {% else %}
  file.copy:
    - force: true
    - source: /srv/salt/virl/ank/files/virl-vis-processor.init
  {% endif %}
    - mode: 0755

/etc/init.d/virl-vis-mux:
  {% if not masterless %}
  file.managed:
    - source: "salt://virl/ank/files/virl-vis-mux.init"
  {% else %}
  file.copy:
    - force: true
    - source: /srv/salt/virl/ank/files/virl-vis-mux.init
  {% endif %}
    - mode: 0755


/etc/init.d/virl-vis-webserver:
  {% if not masterless %}
  file.managed:
    - source: "salt://virl/ank/files/virl-vis-webserver.init"
  {% else %}
  file.copy:
    - force: true
    - source: /srv/salt/virl/ank/files/virl-vis-webserver.init
  {% endif %}
    - mode: 0755


/etc/init.d/ank-cisco-webserver port change:
  file.replace:
    - order: last
    - name: /etc/init.d/ank-cisco-webserver
    - pattern: '.*--port.*"'
    - repl: 'RUNNING_CMD="/usr/local/bin/ank_cisco_webserver --multi_user --port {{ ank }}"'
    - unless:
      - grep {{ ank }} /etc/init.d/ank-cisco-webserver
      - 'test ! -e /etc/init.d/ank-cisco-webserver'


virl-vis-webserver port change:
  file.replace:
    - order: last
    - name: /etc/init.d/virl-vis-webserver
    - pattern: '.*--port.*"'
    - repl: 'RUNNING_CMD="/usr/local/bin/virl_live_vis_webserver --port {{ ank_live }}"'
    - unless:
      - grep {{ ank }} /etc/init.d/virl-vis-webserver
      - 'test ! -e  /etc/init.d/virl-vis-webserver'

/root/.autonetkit/autonetkit.cfg:
  file.managed:
    - makedirs: True
    - mode: 0755
    - unless: grep {{ ank }} /root/.autonetkit/autonetkit.cfg
    - contents:  |
        [Http Post]
        port={{ ank }}


/etc/rc2.d/S98ank-cisco-webserver:
  file.symlink:
    - target: /etc/init.d/ank-cisco-webserver
    - onlyif: ls /usr/local/bin/ank_cisco_webserver
    - mode: 0755
    - require:
      - pip: autonetkit_cisco

/etc/rc2.d/S98ank-webserver absent:
  file.absent:
    - name: /etc/init.d/ank-webserver
    - onlyif: ls /usr/local/bin/ank_cisco_webserver



/etc/rc2.d/S98virl-vis-processor:
  file.symlink:
    - target: /etc/init.d/virl-vis-processor
    - require:
      - file: /etc/init.d/virl-vis-processor
    - mode: 0755

/etc/rc2.d/S98virl-vis-mux:
  file.symlink:
    - target: /etc/init.d/virl-vis-mux
    - require:
      - file: /etc/init.d/virl-vis-mux
    - mode: 0755

/etc/rc2.d/S98virl-vis-webserver:
  file.symlink:
    - order: last
    - target: /etc/init.d/virl-vis-webserver
    - onlyif: 'test -e /etc/init.d/virl-vis-webserver'
    - mode: 0755

ank_prereq:
  pip.installed:
    {% if proxy == true %}
    - proxy: {{ http_proxy }}
    {% endif %}
    - names:
      - lxml
      - configobj
      - six
      - Mako
      - MarkupSafe
      - certifi
      - backports.ssl_match_hostname
      - netaddr
      - networkx
      - PyYAML
      - tornado >= 3.2.2, < 4.0.0

autonetkit check:
  pip.installed:
    - order: 2
    {% if ank_ver_fixed == false %}
    - name: autonetkit
    - upgrade: True
    - find_links: "file:///var/cache/virl/ank"
    {% else %}
    - name: autonetkit == {{ ank_ver }}
    - find_links: "file:///var/cache/virl/fixed/ank"
    {% endif %}
    - no_deps: True
    - use_wheel: True
    - no_index: True
    - require:
      - pip: ank_prereq
  cmd.wait:
    - names:
      - wheel install-scripts autonetkit
      - service ank-webserver start
    - onchanges:
      - pip: autonetkit check



autonetkit_cisco:
  pip.installed:
    {% if ank_ver_fixed %}
    - name: autonet_cisco == {{ ank_cisco }}
    - find_links: "file:///var/cache/virl/fixed/ank"
    {% else %}
    - name: autonetkit_cisco
    - upgrade: True
    - find_links: "file:///var/cache/virl/ank"
    {% endif %}
    - order: 3
    - use_wheel: True
    - no_deps: True
    - pre_releases: True
    - no_index: True
    - require:
      - pip: autonetkit check

autonetkit_cisco.so remove:
  file.absent:
    - name: /usr/local/lib/python2.7/dist-packages/autonetkit_cisco.so


autonetkit_cisco_webui:
  pip.installed:
    {% if ank_ver_fixed %}
    - name: autonetkit_cisco_webui == {{ ank_webui }}
    - find_links: "file:///var/cache/virl/fixed/ank"
    - onlyif: ls /var/cache/virl/fixed/ank/autonetkit_cisco_webui*
    {% else %}
    - name: autonetkit_cisco_webui
    - find_links: "file:///var/cache/virl/ank"
    - onlyif: ls /var/cache/virl/ank/autonetkit_cisco_webui*
    - upgrade: True
    {% endif %}
    - no_deps: True
    - use_wheel: True
    - no_index: True
    - require:
      - pip: autonetkit check
      - pip: autonetkit_cisco
  cmd.wait:
    - names:
      - wheel install-scripts autonetkit-cisco
      - service ank-cisco-webserver start
      - rm -f /etc/init.d/ank-webserver
    - onchanges:
      - pip: autonetkit_cisco_webui

textfsm:
  pip.installed:
    - name: textfsm
    - find_links: "file:///var/cache/virl/ank"
    - onlyif: ls /var/cache/virl/ank/textfsm*
    - upgrade: True
    - order: 4
    - no_deps: True
    - use_wheel: True
    - no_index: True

virl_collection:
  pip.installed:
    {% if ank_ver_fixed %}
    - name: virl_collection == {{ ank_collector }}
    - find_links: "file:///var/cache/virl/fixed/ank"
    - onlyif: ls /var/cache/virl/fixed/ank/virl_collection*
    {% else %}
    - name: virl_collection
    - find_links: "file:///var/cache/virl/ank"
    - onlyif: ls /var/cache/virl/ank/virl_collection*
    - upgrade: True
    {% endif %}
    - no_deps: True
    - use_wheel: True
    - no_index: True
    - order: 4
    - require:
      - pip: autonetkit check
  cmd.wait:
    - names:
      - wheel install-scripts virl-collection
      - service ank-cisco-webserver start
      - service virl-vis-webserver start
      - service virl-vis-processor start
      - service virl-vis-mux start
      - rm -f /etc/init.d/ank-webserver
      - rm -f /etc/rc2.d/S98ank-webserver
    - onchanges:
      - pip: virl_collection

ank-cisco-webserver:
  service:
    - running
    - enable: True
    - restart: True
    - onchanges:
      - pip: autonetkit_cisco_webui
      - file: /etc/init.d/ank-cisco-webserver port change

virl-vis-webserver:
  service:
    - running
    - enable: True
    - restart: True
    - onchanges:
      - pip: virl_collection
      - file: virl-vis-webserver port change

virl-vis-processor:
  service:
    - running
    - enable: True
    - restart: True
    - onchanges:
      - pip: virl_collection

virl-vis-mux:
  service:
    - running
    - enable: True
    - restart: True
    - onchanges:
      - pip: virl_collection
