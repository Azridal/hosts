#!/bin/bash

while IFS= read -r linie || [[ -n "$linie" ]]; do
    # Eliminăm comentariile și separăm IP-ul de nume.
    read -r -a campuri <<< "${linie%%#*}"
    (( ${#campuri[@]} >= 2 )) || continue

    ip=${campuri[0]}
    tip=A
    if [[ $ip == *:* ]]; then
        tip=AAAA
    fi

    for nume in "${campuri[@]:1}"; do
                adrese_dns=$(LC_ALL=C nslookup -type="$tip" "$nume" 8.8.8.8 2>/dev/null |
            awk '/^Name:/ { raspuns = 1 } raspuns && /^Address:/ { print $2 }')

        if [[ -n "$adrese_dns" ]] && ! grep -Fxq -- "$ip" <<< "$adrese_dns"; then
            printf 'Bogus IP for %s in /etc/hosts!\n' "$nume"
        fi
    done
done < /etc/hosts
