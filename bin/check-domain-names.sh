#!/bin/bash
[ -z "$TLD" ] && TLD=".biz .co .com .com.co .company .consulting .online .world";

check_tld() {
  local domain="$1";
  for tld in $TLD; do
    local dig="";
    echo -n "$domain$tld ";
    dig="$(dig "$domain$tld" +short | head -n1)";
    [ -n "$dig" ] && echo "taken" || echo "available";
  done
}

while read -r domain; do
  check_tld "$(echo "$domain" | sed 's/ /-/g')";
  check_tld "$(echo "$domain" | sed 's/ //g')";
done
