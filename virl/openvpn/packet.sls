{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set openvpn_enable = salt['pillar.get']('virl:openvpn_enable', salt['grains.get']('openvpn_enable', False)) %}
{% set l2_gateway = salt['pillar.get']('virl:l2_network_gateway', salt['grains.get']('l2_network_gateway', '172.16.1.254' )) %}

{% if openvpn_enable %}

vpn maximize:
  cmd.run:
    - names:
      - crudini --set /etc/virl.ini DEFAULT l2_network_gateway {{ l2_gateway }}
      - crudini --set /etc/virl.ini DEFAULT l2_network_gateway2 172.16.2.254
      - crudini --set /etc/virl.ini DEFAULT l3_network_gateway 172.16.3.254
      - crudini --set /etc/virl/virl.cfg env virl_local_ip {{ l2_gateway }}
      - crudini --set /etc/nova/nova.conf serial_console proxyclient_address {{ l2_gateway }}
      - crudini --set /etc/nova/nova.conf DEFAULT serial_port_proxyclient_address {{ l2_gateway }}
      - neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://127.0.1.1:5000/v2.0 subnet-update flat --gateway_ip {{ l2_gateway }}
      - neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://127.0.1.1:5000/v2.0 subnet-update flat1 --gateway_ip 172.16.2.254
      - neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://127.0.1.1:5000/v2.0 subnet-update ext-net --gateway_ip 172.16.3.254

ufw accepted ports:
  cmd.run:
    - unless: "/usr/sbin/ufw status | grep 1194/tcp"
    - names:
      - ufw allow in on bond0 to any port 22 proto tcp
      - ufw allow in on bond0 to any port 443 proto tcp
      - ufw allow in on bond0 to any port 4505 proto tcp
      - ufw allow in on bond0 to any port 4506 proto tcp      
      - ufw allow in on bond0 to any port 1194 proto tcp
      - ufw allow from 10.0.0.0/8

ufw deny bond0:
  cmd.run:
    - require:
      - cmd: ufw accepted ports
    - name: ufw deny in on bond0 to any

ufw accept all:
  cmd.run:
    - require:
      - cmd: ufw deny bond0
    - names: 
      - ufw allow from any to any
      - ufw default allow routed


adding local route to openvpn:
  file.append:
    - name: /etc/openvpn/server.conf
    - text: push "route 172.16.0.0 255.255.224.0 {{ l2_gateway }}"

adding nat to ufw:
  file.prepend:
    - name: /etc/ufw/before.rules
    - text:  |
        *nat
        :POSTROUTING ACCEPT [0:0]
        # translate outbound traffic from internal networks
        -A POSTROUTING -s 172.16.0.0/19 -o bond0 -j MASQUERADE
        # don't delete the 'COMMIT' line or these nat table rules won't
        # be processed
        COMMIT

ufw force enable:
  cmd.run:
    - order: last
    - names:
      - service neutron-l3-agent restart
      - service nova-serialproxy restart
      - service virl-std restart
      - service virl-uwm restart
      - service openvpn restart
      - ufw --force enable
      - ufw status verbose

{% endif %}