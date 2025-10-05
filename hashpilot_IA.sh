#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# HashPilot - Versão corrigida / educativa
# Uso: fins educacionais e testes autorizados apenas.
# Autor: CyberSecurity0000

# Configuração do tipo de Hash a ser analisado (padrão)
# 0    -> MD5
# 22000-> WPA-PBKDF2-PMKID+EAPOL
HASH_TYPE=${HASH_TYPE:-0}   # pode sobrescrever com variável de ambiente

# Paths configuráveis
POTFILE="${POTFILE:-${HOME}/.local/share/hashcat/hashcat.potfile}"
SESSIONS_DIR="${SESSIONS_DIR:-${HOME}/.local/share/hashcat/sessions}"
LOG_DIR="${LOG_DIR:-./reports}"
HASHCAT_CMD="$(command -v hashcat || true)"

# Utilitários
timestamp(){ date +%Y%m%dT%H%M%S; }

usage_short(){
  cat <<EOF
HashPilot (clean) - wrapper leve para hashcat (modo interativo)
Uso: execute ./hashpilot-clean.sh
Nota: esta ferramenta é educacional. Teste apenas em ambientes autorizados.
EOF
}

check_requirements(){
  if [[ -z "$HASHCAT_CMD" ]]; then
    echo "Erro: hashcat não encontrado no PATH. Instale hashcat antes." >&2
    exit 1
  fi
  mkdir -p "$(dirname "$POTFILE")"
  mkdir -p "$SESSIONS_DIR"
  mkdir -p "$LOG_DIR"
}

trap 'echo; echo "Interrompido. Saindo..."; exit 1' INT TERM

# Apresentação (mantida estética)
apresentacao(){
  clear
  printf "     \e[1;92m.-\"\"\"\"-. \e[0m\n"
  printf "    \e[1;92m/        \\ \e[0m\n"
  printf " \e[1;77m  \e[0m\e[1;92m/_        _\\ \e[0m\n"
  printf "\e[1;77m  \e[0m\e[1;92m// \\      / \\\\ \e[0m\n"
  printf "\e[1;77m  \e[0m\e[1;92m|\\__\\    /__/ \e[0m\n"
  printf "\e[1;77m  \e[0m\e[1;92m\\    ||    / \e[0m\n"
  printf "\e[1;77m   \e[0m\e[1;92m\\        / \e[0m\n"
  printf "\e[1;92m \e[0m   \e[1;92m\\  __  / \e[0m\n"
  printf "     \e[1;92m'.__.' \e[0m\n\n"

  echo -e "\033[01;33m ################################### \033[01;37m"
  echo -e "\033[01;32m  Desenvolvido por CyberSecurity0000 (HashPilot) \033[01;37m"
  echo -e "\033[01;33m ################################### \033[01;37m\n"

  echo -e "\033[01;34m ----------------- \033[01;37m"
  echo -e "\033[01;31m      HashCat Edu  \033[01;37m"
  echo -e "\033[01;34m ----------------- \033[01;37m"
  echo -e "\033[01;32m # Sessions: $SESSIONS_DIR \033[01;37m"
  echo -e "\033[01;32m # Potfile:  $POTFILE \033[01;37m"
  echo -e -n "\033[01;34m # Converter HandShake -> https://hashcat.net/cap2hashcat/ \033[00;00m"
  echo ""
}

#############################
# Funções de ataque (limpas)
#############################

read_file_prompt(){
  local file=""
  read -r -p $'\033[01;33m\n # Arquivo (Ex: hash.txt | hash.hc22000): \033[01;37m' file
  if [[ -z "$file" ]]; then
    echo "Nenhum arquivo informado."
    return 1
  fi
  if [[ ! -f "$file" ]]; then
    echo "Arquivo não encontrado: $file"
    return 2
  fi
  ARQ="$file"
  return 0
}

brute_default(){
  clear
  echo -e "\033[01;35m  Teste de Hash - Default  \033[01;37m"
  echo ""
  echo -e "\033[01;31m [1] Executar"
  echo -e "\033[01;32m [2] Restaurar sessão"
  echo -e "\033[01;33m [3] Resultados"
  echo ""
  read -r -p $'\033[01;36m # Opc: \033[01;37m' opc

  kernel="-S -O -w 4 -n 64 -u 256 -T 64 --force"
  session="--session=hashpilot_default"
  mode="-a 3 -m ${HASH_TYPE}"

  case "$opc" in
    1)
      read_file_prompt || return
      "$HASHCAT_CMD" $kernel $session $mode "$ARQ"
      ;;
    2)
      "$HASHCAT_CMD" $kernel --session hashpilot_default --restore
      ;;
    3)
      show_results
      ;;
    *)
      ;;
  esac
}

brute_allchars(){
  clear
  echo -e "\033[01;35m  Teste de Hash - Todos Caracteres  \033[01;37m"
  echo ""
  echo -e "\033[01;31m [1] Executar"
  echo -e "\033[01;32m [2] Restaurar sessão"
  echo -e "\033[01;33m [3] Resultados"
  echo ""
  read -r -p $'\033[01;36m # Opc: \033[01;37m' opc

  kernel="-S -O -w 4 -n 64 -u 256 -T 64 --force"
  session="--session=hashpilot_all"
  mode="-a 3 -m ${HASH_TYPE}"

  case "$opc" in
    1)
      read_file_prompt || return
      read -r -p $'\033[01;33m\n # Quantidade de caracteres (ex: ?1?1?1?1): \033[01;37m' qtd
      "$HASHCAT_CMD" $kernel $session $mode -1 ?a "$ARQ" "$qtd"
      ;;
    2)
      "$HASHCAT_CMD" $kernel --session hashpilot_all --restore
      ;;
    3)
      show_results
      ;;
    *)
      ;;
  esac
}

wordlist_attack(){
  clear
  echo -e "\033[01;35m  Lista de Hashes (Wordlist)  \033[01;37m"
  echo ""
  echo -e "\033[01;31m [1] Executar"
  echo -e "\033[01;32m [2] Restaurar sessão"
  echo -e "\033[01;33m [3] Resultados"
  echo ""
  read -r -p $'\033[01;36m # Opc: \033[01;37m' opc

  kernel="-S -O -w 4 -n 64 -u 256 -T 64 --force"
  session="--session=hashpilot_wordlist"
  mode="-a 0 -m ${HASH_TYPE}"

  case "$opc" in
    1)
      read_file_prompt || return
      read -r -p $'\033[01;33m\n # Caminho da WordList: \033[01;37m' path
      if [[ ! -f "$path" ]]; then
        echo "Wordlist não encontrada: $path"
        return 1
      fi
      "$HASHCAT_CMD" $kernel $session "$ARQ" $mode "$path"
      ;;
    2)
      "$HASHCAT_CMD" $kernel --session hashpilot_wordlist --restore
      ;;
    3)
      show_results
      ;;
    *)
      ;;
  esac
}

numbers_attack(){
  clear
  echo -e "\033[01;35m  Numbers  \033[01;37m"
  echo ""
  echo -e "\033[01;31m [1] Executar"
  echo -e "\033[01;32m [2] Restaurar sessão"
  echo -e "\033[01;33m [3] Resultados"
  echo ""
  read -r -p $'\033[01;36m # Opc: \033[01;37m' opc

  kernel="-S -O -w 4 -n 64 -u 256 -T 64 --force"
  session="--session=hashpilot_numbers"
  mode="-a 3 -m ${HASH_TYPE}"

  case "$opc" in
    1)
      read_file_prompt || return
      read -r -p $'\033[01;33m\n # Quantidade de caracteres (ex: ?1?1?1?1): \033[01;37m' qtd
      "$HASHCAT_CMD" $kernel $session -1 ?d $mode "$ARQ" "$qtd"
      ;;
    2)
      "$HASHCAT_CMD" $kernel --session hashpilot_numbers --restore
      ;;
    3)
      show_results
      ;;
    *)
      ;;
  esac
}

letters_attack(){
  clear
  echo -e "\033[01;35m  Letters  \033[01;37m"
  read -r -p $'\033[01;36m # Opc: \033[01;37m' opc

  kernel="-S -O -w 4 -n 64 -u 256 -T 64 --force"
  session="--session=hashpilot_letters"
  mode="-a 3 -m ${HASH_TYPE}"

  case "$opc" in
    1)
      read_file_prompt || return
      read -r -p $'\033[01;33m\n # Quantidade de caracteres (ex: ?1?1?1?1): \033[01;37m' qtd
      "$HASHCAT_CMD" $kernel $session -1 ?l?u $mode "$ARQ" "$qtd"
      ;;
    2)
      "$HASHCAT_CMD" $kernel --session hashpilot_letters --restore
      ;;
    3)
      show_results
      ;;
    *)
      ;;
  esac
}

minuscule_letters_attack(){
  clear
  echo -e "\033[01;35m  Minuscule Letters  \033[01;37m"
  read -r -p $'\033[01;36m # Opc: \033[01;37m' opc

  kernel="-S -O -w 4 -n 64 -u 256 -T 64 --force"
  session="--session=hashpilot_minuscule"
  mode="-a 3 -m ${HASH_TYPE}"

  case "$opc" in
    1)
      read_file_prompt || return
      read -r -p $'\033[01;33m\n # Quantidade de caracteres (ex: ?1?1?1?1): \033[01;37m' qtd
      "$HASHCAT_CMD" $kernel $session -1 ?l $mode "$ARQ" "$qtd"
      ;;
    2)
      "$HASHCAT_CMD" $kernel --session hashpilot_minuscule --restore
      ;;
    3)
      show_results
      ;;
    *)
      ;;
  esac
}

letters_numbers_attack(){
  clear
  echo -e "\033[01;35m  Letters + Numbers  \033[01;37m"
  read -r -p $'\033[01;36m # Opc: \033[01;37m' opc

  kernel="-S -O -w 4 -n 64 -u 256 -T 64 --force"
  session="--session=hashpilot_lettersnumbers"
  mode="-a 3 -m ${HASH_TYPE}"

  case "$opc" in
    1)
      read_file_prompt || return
      read -r -p $'\033[01;33m\n # Quantidade de caracteres (ex: ?1?1?1?1): \033[01;37m' qtd
      "$HASHCAT_CMD" $kernel $session -1 ?l?d?u $mode "$ARQ" "$qtd"
      ;;
    2)
      "$HASHCAT_CMD" $kernel --session hashpilot_lettersnumbers --restore
      ;;
    3)
      show_results
      ;;
    *)
      ;;
  esac
}

custom_attack(){
  clear
  echo -e "\033[01;35m  Custom  \033[01;37m"
  echo ""
  echo -e "\033[01;31m [1] Executar"
  echo -e "\033[01;32m [2] Restaurar sessão"
  echo -e "\033[01;33m [3] Resultados"
  echo ""
  read -r -p $'\033[01;36m # Opc: \033[01;37m' opc

  kernel="-S -O -w 4 -n 64 -u 256 -T 64 --force"
  session="--session=hashpilot_custom"
  mode="-a 3 -m ${HASH_TYPE}"

  case "$opc" in
    1)
      read_file_prompt || return
      read -r -p $'\033[01;31m\n # Caracteres (ex: abc123): \033[01;37m' caracteres
      read -r -p $'\033[01;33m\n # Quantidade (ex: ?1?1?1?1): \033[01;37m' qtd
      "$HASHCAT_CMD" $kernel $session -1 "$caracteres" $mode "$ARQ" "$qtd"
      ;;
    2)
      "$HASHCAT_CMD" $kernel --session hashpilot_custom --restore
      ;;
    3)
      show_results
      ;;
    *)
      ;;
  esac
}

# Mostrar resultado das senhas (safe)
show_results(){
  if [[ -f "$POTFILE" ]]; then
    clear
    echo "=== Conteúdo do potfile: $POTFILE ==="
    sort "$POTFILE" || true
    echo -e "\n\033[01;33m<<< ENTER >>>\033[01;37m"
    read -r
  else
    echo "Nenhum potfile encontrado em $POTFILE"
    sleep 1
  fi
}

imprimir_senhas(){
  if [[ -f "$POTFILE" ]]; then
    linhas=$(sort "$POTFILE" | wc -l)
    echo -e "\033[01;31m # Senhas no potfile: $linhas \033[01;37m"
    sort "$POTFILE" | uniq > "${LOG_DIR}/Relatorio-$(timestamp).txt"
    echo "Relatório gravado em ${LOG_DIR}/Relatorio-$(timestamp).txt"
  else
    echo "Nenhum potfile encontrado."
  fi
  read -r -p $'\n[ENTER] Retornar' _
}

# Menu
montagem_menu(){
  declare -a arr=("Teste de Hash - Default"
                  "Teste de Hash - Todos caracteres"
                  "Lista de Hashes (Wordlist)"
                  "Numbers"
                  "Letters"
                  "Minuscule letters"
                  "Letters + Numbers"
                  "Custom")
  echo -e "\n\033[01;33m # Main Menu  \n\033[01;37m"
  for (( i=0; i<${#arr[@]}; i++ )); do
    echo -e "\033[01;3$((i+1))m # [$((i+1))]: ${arr[$i]} \033[01;37m"
  done
  echo ""
  echo -e "\033[01;32m # [i]: Press Passwords  \033[01;37m"
  echo -e "\033[01;31m # [0]: Exit 	     \n\033[01;37m"
  read -r -p $'\033[01;37m # Opc.: \033[01;37m' opc
}

escolha(){
  case "$opc" in
    1) brute_default ;;
    2) brute_allchars ;;
    3) wordlist_attack ;;
    4) numbers_attack ;;
    5) letters_attack ;;
    6) minuscule_letters_attack ;;
    7) letters_numbers_attack ;;
    8) custom_attack ;;
    i|I) imprimir_senhas ;;
    0) exit 0 ;;
    *) ;;
  esac
}

# Controle de fluxo
programa_main(){
  check_requirements
  while true; do
    apresentacao
    montagem_menu
    escolha
  done
}

# Início
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  usage_short
  programa_main
fi
