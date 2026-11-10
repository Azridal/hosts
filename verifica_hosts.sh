#!/bin/bash

verifica_ip() {
    local nume=$1 ip=$2 server_dns=$3
    local tip=A adrese_dns

    if [[ $ip == *:* ]]; then
        tip=AAAA
    fi

    adrese_dns=$(LC_ALL=C nslookup -type="$tip" "$nume" "$server_dns" 2>/dev/null |
        awk '/^Name:/ { raspuns = 1 } raspuns && /^Address:/ { print $2 }')

    if [[ -n "$adrese_dns" ]] && ! grep -Fxq -- "$ip" <<< "$adrese_dns"; then
        printf 'Bogus IP for %s in /etc/hosts!\n' "$nume"
    fi
}

server_dns=8.8.8.8

while IFS= read -r linie || [[ -n "$linie" ]]; do
    # Eliminăm comentariile și separăm IP-ul de nume.
    read -r -a campuri <<< "${linie%%#*}"
    (( ${#campuri[@]} >= 2 )) || continue

    ip=${campuri[0]}
    for nume in "${campuri[@]:1}"; do
        verifica_ip "$nume" "$ip" "$server_dns"
    done
done < /etc/hosts
