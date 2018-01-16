#!/bin/sh

echo -n aplicando redes de firewall

# flush de reglas
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

#politicas por defecto 
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

##REGLAS
#REGLA 1: PERMITE CONEXIONES LOCALES SIN LIMITES
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT 


#BIT FORWARD
echo 1 > /proc/sys/net/ipv4/ip_forward
       

#REGLA 2: PERMITE QUE LA MZ PUEDA SALIR A INTERNET 
iptables -t nat -A POSTROUTING -s 192.168.3.0/24 -o eth3 -j MASQUERADE

#REGLA 3: NAVEGACION  HTTP (PAGINAS WEB) DE LA MZ
iptables -t filter -A FORWARD -s 192.168.3.0/24 -o eth3 -p tcp --dport 80 -j ACCEPT
iptables -t filter -A FORWARD -d 192.168.3.0/24 -i eth3 -p tcp --sport 80 -j ACCEPT

#REGLA 4: NAVEGACION HTTPS (PAGINAS WEB SEGURAS) DE LA MZ
iptables -t filter -A FORWARD -s 192.168.3.0/24 -o eth3 -p tcp --dport 443 -j ACCEPT
iptables -t filter -A FORWARD -d 192.168.3.0/24 -i eth3 -p tcp --sport 443 -j ACCEPT

#REGLA 5: SE PERMITEN LOS DNS PARA PODER ACCEDER A SITIOS WEB DESDE LA MZ  
iptables -t filter -A FORWARD -s 192.168.3.0/24 -o eth3 -p udp --dport 53 -j ACCEPT
iptables -t filter -A FORWARD -d 192.168.3.0/24 -i eth3 -p udp --sport 53 -j ACCEPT
iptables -t filter -A FORWARD -s 192.168.3.0/24 -o eth3 -p tcp --dport 53 -j ACCEPT
iptables -t filter -A FORWARD -d 192.168.3.0/24 -i eth3 -p tcp --sport 53 -j ACCEPT

#REGLA 6: PERMITE LA COMUNICACION ENTRE EL FIREWALL Y LA MZ
iptables -A INPUT -s 192.168.3.0/24 -i eth2 -j ACCEPT
iptables -A OUTPUT -d 192.168.3.0/24 -j ACCEPT

#REGLA 7: HABILITA EL SERVICIO SSH DESDE UN HOST DE LA MZ HACIA EL SERVIDOR WEB DE LA DMZ
iptables -A FORWARD -s 192.168.3.2 -d 192.168.2.2 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -s 192.168.2.2 -d 192.168.3.2 -p tcp --sport 22 -j ACCEPT


#REGLA 8: PERMITE PING DESDE LA MZ AL EXTERIOR
iptables -A FORWARD -s 192.168.3.0/24 -o eth3 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -d 192.168.3.0/24 -i eth3 -p icmp --icmp-type echo-reply -j ACCEPT

#REGLA 9: PERMITE QUE LA DMZ SALGA A INTERNET
iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -o eth3 -j MASQUERADE

#REGLA 10:PERMITE CONEXIONES ENTRANTES DESDE EL SERVIDOR
iptables -t nat -A PREROUTING -i eth3 -p tcp --dport 80 -j DNAT --to 192.168.2.2:80

#REGLA 11: NAVEGACION  HTTP (PAGINAS WEB) DE LA MZ
iptables -t filter -A FORWARD -s 192.168.2.0/24 -o eth3 -p tcp --dport 80 -j ACCEPT
iptables -t filter -A FORWARD -d 192.168.2.0/24 -i eth3 -p tcp --sport 80 -j ACCEPT

#REGLA 12: NAVEGACION HTTPS (PAGINAS WEB SEGURAS) DE LA MZ
iptables -t filter -A FORWARD -s 192.168.2.0/24 -o eth3 -p tcp --dport 443 -j ACCEPT
iptables -t filter -A FORWARD -d 192.168.2.0/24 -i eth3 -p tcp --sport 443 -j ACCEPT

#REGLA 13: SE PERMITEN LOS DNS PARA PODER ACCEDER A SITIOS WEB DESDE LA MZ  
iptables -t filter -A FORWARD -s 192.168.2.0/24 -o eth3 -p udp --dport 53 -j ACCEPT
iptables -t filter -A FORWARD -d 192.168.2.0/24 -i eth3 -p udp --sport 53 -j ACCEPT
iptables -t filter -A FORWARD -s 192.168.2.0/24 -o eth3 -p tcp --dport 53 -j ACCEPT
iptables -t filter -A FORWARD -d 192.168.2.0/24 -i eth3 -p tcp --sport 53 -j ACCEPT

#REGLA 14: PERMITE PING DESDE LA DMZ AL EXTERIOR
iptables -A FORWARD -s 192.168.2.0/24 -o eth3 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -d 192.168.2.0/24 -i eth3 -p icmp --icmp-type echo-reply -j ACCEPT

#REGLA 15: PERMITE QUE LA MZ PUEDA ACCEDER A LA DMZ
iptables -A FORWARD -s 192.168.3.0/24 -d 192.168.2.0/24 -j ACCEPT
iptables -A FORWARD -s 192.168.2.0/24 -d 192.168.3.0/24 -j ACCEPT



