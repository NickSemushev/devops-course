#!/usr/bin/env bash
set -uo pipefail
PASS=0; FAIL=0
check() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$actual" == "$expected" ]]; then echo " [OK]  $desc"; ((PASS++)); else echo " [FAIL] $desc"; ((FAIL++)); fi
}
echo "Аудит конфигурации: $(hostname -f)"
check "Root запрещён" "no" "$(sudo sshd -T | awk '/^permitrootlogin/{print $2}')"
check "Пароли отключены" "no" "$(sudo sshd -T | awk '/^passwordauthentication/{print $2}')"
check "Порт SSH отличен от 22" "yes" "$([ "$(sudo sshd -T | awk '/^port/{print $2}')" != "22" ] && echo yes || echo no)"
check "MaxAuthTries = 3" "3" "$(sudo sshd -T | awk '/^maxauthtries/{print $2}')"
check "UFW активен" "active" "$(sudo ufw status | awk '/^Status:/{print $2}')"
check "Политика deny incoming" "deny" "$(sudo ufw status verbose | awk '/^Default:/{print $2}')"
echo "Пройдено: $PASS, не пройдено: $FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
