#!/bin/bash

# Force UTF-8 locale so bash counts characters (not bytes) in cyrillic
# text — fixes column alignment for printf "%-Ns" and ${#string}.
export LC_ALL=C.UTF-8 2>/dev/null || export LC_ALL=en_US.UTF-8 2>/dev/null || true
export LANG=C.UTF-8 2>/dev/null || true

# =============================================================================
#  Caddy + Xray CDN bypass setup + User Management
#  Поддержка: Ubuntu / Debian
#  CDN: Timeweb CDN / Beget CDN
#  Repo: github.com/SpecFlowdev/Cdn-Whitelist
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

XRAY_CONFIG="/usr/local/etc/xray/config.json"
CADDY_CONFIG="/etc/caddy/Caddyfile"
USERS_DB="/usr/local/etc/xray/users.db"
PARAMS_FILE="/root/xray-cdn-params.txt"
BACKUP_DIR="/root/xcdn-backup"
CMD_PATH="/usr/local/bin/xcdn"
INSTALL_DIR="/opt/xcdn"
CRON_SCRIPT="/opt/xcdn/expire-check.sh"
REPO_URL="https://raw.githubusercontent.com/SpecFlowdev/Cdn-Whitelist/main/install.sh"
VERSION="1.2.0"
XRAY_PORT=""
LANG_SET=""
UI_WIDTH=58
UI_RULE="$(printf '─%.0s' $(seq 1 "$UI_WIDTH"))"

# =============================================================================
# ЯЗЫК / LANGUAGE
# =============================================================================

set_lang() {
    if [[ "$LANG_SET" == "en" ]]; then
        L_BANNER_TITLE="Caddy + Xray  ·  CDN Bypass Setup"
        L_BANNER_SUB="Timeweb CDN / Beget CDN  ·  VLESS/XHTTP"
        L_ROOT_ERR="Run as root: sudo bash install.sh"
        L_OS_ERR="Only Ubuntu and Debian are supported"
        L_STEP_PARAMS="Installation parameters"
        L_ASK_NODE="Node domain"
        L_ASK_NODE_EX="e.g.: node.example.com"
        L_ASK_CDN="CDN technical domain"
        L_ASK_CDN_EX="e.g.: cdn.example.com"
        L_ASK_PORT="Internal Xray port"
        L_ASK_PORT_DEF="default: 10085"
        L_ASK_FP="TLS Fingerprint:"
        L_FP_REC="(recommended)"
        L_ASK_FP_CHOOSE="Choice"
        L_ASK_FP_DEF="Enter = chrome"
        L_BAD_PORT="Invalid port, using 10085"
        L_EMPTY="Cannot be empty"
        L_BAD_DOMAIN="Invalid domain — use letters, digits, dots and hyphens only (e.g. cdn.example.com)"
        L_NAME_LABEL="Name"
        L_CADDY_FAIL_HINT="failed to start — check the domain is correct and DNS points to this server. Run: journalctl -u caddy -n 30"
        L_CMD_DOWNLOAD_FAIL="Could not download install.sh — check your internet connection and try again later, or re-run this script manually with 'xcdn' once network is available."
        L_CONFIRM_TITLE="Check parameters before installation"
        L_CONFIRM_NODE="Node domain:"
        L_CONFIRM_CDN="CDN domain:"
        L_CONFIRM_PORT="Xray port:"
        L_CONFIRM_FP="Fingerprint:"
        L_CONFIRM_OK="All correct? [Y/n]:"
        L_STEP_DEPS="Installing dependencies"
        L_DEPS_OK="Dependencies installed"
        L_DEPS_FAIL="Failed to install required packages — missing"
        L_STEP_CADDY="Installing Caddy"
        L_CADDY_EXISTS="Caddy already installed, skipping"
        L_CADDY_OK="Caddy installed"
        L_CADDY_FAIL="Caddy installation failed — package did not install. Check: apt-get install caddy"
        L_STEP_CADDY_CFG="Configuring Caddy"
        L_STEP_XRAY="Installing Xray"
        L_XRAY_EXISTS="Xray already installed, updating config"
        L_XRAY_OK="Xray ready"
        L_XRAY_FAIL="Xray installation failed — binary not found after install"
        L_STEP_FW="Configuring UFW"
        L_FW_OPEN="open"
        L_FW_CLOSED="blocked externally (localhost only)"
        L_STEP_CMD="Installing xcdn command"
        L_CMD_OK="Command installed → xcdn"
        L_STEP_CRON="Auto-block expired users"
        L_CRON_OK="Cron: checks expiry and traffic every hour"
        L_STEP_DNS="DNS check"
        L_DNS_IP="Server IP:"
        L_DNS_FAIL="Could not resolve DNS for"
        L_DNS_ENSURE="Make sure the A-record is configured"
        L_DNS_MISMATCH="A-record doesn't match server IP"
        L_DNS_OK="DNS OK:"
        L_DNS_SKIP="No dig/host to check DNS, skipping"
        L_CONTINUE="Continue? [y/N]:"
        L_STEP_VERIFY="Verification"
        L_VERIFY_LISTEN="Xray listening on port"
        L_VERIFY_NO_LISTEN="Xray not responding on port"
        L_VERIFY_CADDY_OK="Caddy running"
        L_VERIFY_CADDY_FAIL="Caddy not running"
        L_VERIFY_XRAY_OK="Xray running"
        L_VERIFY_XRAY_FAIL="Xray not running"
        L_FINISH_TITLE="Installation completed successfully"
        L_FINISH_CDN_TITLE="CDN setup (Timeweb / Beget):"
        L_FINISH_ORIGIN="Origin:"
        L_FINISH_HTTPS="HTTPS to origin:"
        L_FINISH_CACHE="Caching:"
        L_FINISH_HTTP="HTTP methods:"
        L_FINISH_ENABLED="enabled"
        L_FINISH_CHECK="Verification:"
        L_FINISH_MANAGE="Management:  xcdn"
        L_FINISH_UPDATE="Update:      xcdn update"
        L_FINISH_PARAMS="Parameters:"
        L_FINISH_CRON_NOTE="Auto-block expired users: cron every hour"
        L_OPEN_MENU="Open management menu? [Y/n]:"
        L_ALREADY_INSTALLED="Already installed. Opening menu..."
        L_MENU_USERS="Users"
        L_MENU_ADD="Add user"
        L_MENU_DEL="Delete user"
        L_MENU_LIST="List users"
        L_MENU_LINK="Show link / QR"
        L_MENU_TRAFFIC="Update traffic"
        L_MENU_RESET="Reset traffic"
        L_MENU_EXPIRY="Change expiry"
        L_MENU_SYS="System"
        L_MENU_RESTART_XRAY="Restart Xray"
        L_MENU_RESTART_CADDY="Restart Caddy"
        L_MENU_LOGS_XRAY="Xray logs"
        L_MENU_LOGS_CADDY="Caddy logs"
        L_MENU_MAINT="Maintenance"
        L_MENU_BACKUP="Backup configs"
        L_MENU_RESTORE="Restore from backup"
        L_MENU_UPDATE="Update script from GitHub"
        L_MENU_UNINSTALL="Full uninstall"
        L_MENU_EXIT="Exit"
        L_MENU_CHOICE="Choice:"
        L_MENU_BAD="Invalid choice"
        L_ENTER="Press Enter to continue..."
        L_STATUS_RUN="running"
        L_STATUS_STOP="stopped"
        L_STATUS_NODE="Node:"
        L_STATUS_CDN="CDN:"
        L_STATUS_PORT="Port:"
        L_USER_NAME="Username:"
        L_USER_EXPIRY="Expiry"
        L_USER_EXPIRY_DAYS="days, 0 = unlimited"
        L_USER_TRAFFIC="Traffic limit"
        L_USER_TRAFFIC_GB="GB, 0 = no limit"
        L_USER_ADDED="User added"
        L_USER_EXISTS="User already exists"
        L_USER_NOT_FOUND="User not found"
        L_USER_DEL_NAME="Username to delete:"
        L_USER_DEL_CONFIRM="Delete? [y/N]:"
        L_USER_DELETED="User deleted"
        L_USER_NO_USERS="No users. Add one via option 1."
        L_USER_NAME_HEADER="NAME"
        L_USER_EXPIRY_HEADER="EXPIRY"
        L_USER_LIMIT_HEADER="LIMIT"
        L_USER_USED_HEADER="USED"
        L_USER_STATUS_HEADER="STATUS"
        L_USER_ACTIVE="active"
        L_USER_EXPIRED="expired"
        L_USER_OVERLIMIT="limit"
        L_USER_UNLIMITED="∞ (no limit)"
        L_USER_TRAFFIC_USED="Traffic used (GB):"
        L_USER_TRAFFIC_SET="Traffic"
        L_USER_TRAFFIC_ALL="Name (or 'all'):"
        L_USER_TRAFFIC_RESET_ALL="Traffic reset for all"
        L_USER_TRAFFIC_RESET_ONE="Traffic reset"
        L_USER_EXPIRY_NEW="New expiry (days, 0 = unlimited):"
        L_USER_EXPIRY_SET="Expiry"
        L_VLESS_LINK="VLESS link:"
        L_QR_CODE="QR code:"
        L_QR_ONLINE="QR online:"
        L_BACKUP_CREATED="Backup created:"
        L_BACKUP_NONE="No backups in"
        L_BACKUP_LIST="Available backups:"
        L_BACKUP_CHOOSE="Choose number:"
        L_BACKUP_BAD="Invalid choice"
        L_BACKUP_RESTORED="Restored from"
        L_UPDATE_TITLE="Updating script"
        L_UPDATE_DONE="Updated:"
        L_UPDATE_LATEST="Already latest version:"
        L_UPDATE_FAIL="Failed to download update"
        L_UPDATE_RESTART="Restart: xcdn"
        L_UNINSTALL_TITLE="Full removal of Caddy + Xray + configs"
        L_UNINSTALL_DESC="Will remove: Caddy, Xray, UFW rules, configs, users.db"
        L_UNINSTALL_CONFIRM="Type YES to confirm:"
        L_UNINSTALL_CANCEL="Cancelled"
        L_UNINSTALL_BACKUP="Creating backup before removal"
        L_UNINSTALL_STOP="Stopping services"
        L_UNINSTALL_XRAY="Removing Xray"
        L_UNINSTALL_CADDY="Removing Caddy"
        L_UNINSTALL_CLEAN="Cleanup"
        L_UNINSTALL_UFW="Resetting UFW"
        L_UNINSTALL_DONE="Everything removed. Backup saved in"
        L_UNINSTALL_SSH="SSH (22) left open"
        L_RESTARTED="restarted"
        L_ERROR="Error"
    else
        L_BANNER_TITLE="Caddy + Xray  ·  CDN Bypass Setup"
        L_BANNER_SUB="Timeweb CDN / Beget CDN  ·  VLESS/XHTTP"
        L_ROOT_ERR="Запусти от root: sudo bash install.sh"
        L_OS_ERR="Поддерживаются только Ubuntu и Debian"
        L_STEP_PARAMS="Параметры установки"
        L_ASK_NODE="Домен ноды"
        L_ASK_NODE_EX="например: node.example.com"
        L_ASK_CDN="Технический домен CDN"
        L_ASK_CDN_EX="например: cdn.example.com"
        L_ASK_PORT="Внутренний порт Xray"
        L_ASK_PORT_DEF="по умолчанию: 10085"
        L_ASK_FP="TLS Fingerprint:"
        L_FP_REC="(рекомендуется)"
        L_ASK_FP_CHOOSE="Выбор"
        L_ASK_FP_DEF="Enter = chrome"
        L_BAD_PORT="Некорректный порт, использую 10085"
        L_EMPTY="Не может быть пустым"
        L_BAD_DOMAIN="Некорректный домен — допустимы только буквы, цифры, точки и дефисы (например: cdn.example.com)"
        L_NAME_LABEL="Имя"
        L_CADDY_FAIL_HINT="не запустился — проверь правильность домена и что DNS указывает на этот сервер. Выполни: journalctl -u caddy -n 30"
        L_CMD_DOWNLOAD_FAIL="Не удалось скачать install.sh — проверь интернет-соединение и попробуй позже, или перезапусти этот скрипт вручную когда появится сеть."
        L_CONFIRM_TITLE="Проверь параметры перед установкой"
        L_CONFIRM_NODE="Домен ноды:"
        L_CONFIRM_CDN="Домен CDN:"
        L_CONFIRM_PORT="Порт Xray:"
        L_CONFIRM_FP="Fingerprint:"
        L_CONFIRM_OK="Всё верно? [Y/n]:"
        L_STEP_DEPS="Установка зависимостей"
        L_DEPS_OK="Зависимости установлены"
        L_DEPS_FAIL="Не удалось установить нужные пакеты — отсутствуют"
        L_STEP_CADDY="Установка Caddy"
        L_CADDY_EXISTS="Caddy уже установлен, пропускаю"
        L_CADDY_OK="Caddy установлен"
        L_CADDY_FAIL="Установка Caddy не удалась — пакет не установился. Проверь: apt-get install caddy"
        L_STEP_CADDY_CFG="Настройка Caddy"
        L_STEP_XRAY="Установка Xray"
        L_XRAY_EXISTS="Xray уже установлен, обновляю конфиг"
        L_XRAY_OK="Xray готов"
        L_XRAY_FAIL="Установка Xray не удалась — бинарник не найден после установки"
        L_STEP_FW="Настройка UFW"
        L_FW_OPEN="открыты"
        L_FW_CLOSED="закрыт снаружи (только localhost)"
        L_STEP_CMD="Установка команды xcdn"
        L_CMD_OK="Команда → xcdn"
        L_STEP_CRON="Автоблок истёкших пользователей"
        L_CRON_OK="Cron: каждый час проверяет срок и трафик"
        L_STEP_DNS="Проверка DNS"
        L_DNS_IP="IP сервера:"
        L_DNS_FAIL="Не удалось получить DNS для"
        L_DNS_ENSURE="Убедись что A-запись настроена"
        L_DNS_MISMATCH="A-запись не совпадает с IP сервера"
        L_DNS_OK="DNS OK:"
        L_DNS_SKIP="Нет dig/host для проверки DNS, пропускаю"
        L_CONTINUE="Продолжить? [y/N]:"
        L_STEP_VERIFY="Проверка"
        L_VERIFY_LISTEN="Xray слушает порт"
        L_VERIFY_NO_LISTEN="Xray не отвечает на порту"
        L_VERIFY_CADDY_OK="Caddy работает"
        L_VERIFY_CADDY_FAIL="Caddy не запущен"
        L_VERIFY_XRAY_OK="Xray работает"
        L_VERIFY_XRAY_FAIL="Xray не запущен"
        L_FINISH_TITLE="Установка завершена успешно"
        L_FINISH_CDN_TITLE="Настройка CDN (Timeweb / Beget):"
        L_FINISH_ORIGIN="Источник (Origin):"
        L_FINISH_HTTPS="HTTPS к источнику:"
        L_FINISH_CACHE="Кэширование:"
        L_FINISH_HTTP="HTTP методы:"
        L_FINISH_ENABLED="включено"
        L_FINISH_CHECK="Проверка:"
        L_FINISH_MANAGE="Управление:  xcdn"
        L_FINISH_UPDATE="Обновление:  xcdn update"
        L_FINISH_PARAMS="Параметры:"
        L_FINISH_CRON_NOTE="Автоблок истёкших юзеров: cron каждый час"
        L_OPEN_MENU="Открыть меню управления? [Y/n]:"
        L_ALREADY_INSTALLED="Установка выполнена. Открываю меню..."
        L_MENU_USERS="Пользователи"
        L_MENU_ADD="Добавить пользователя"
        L_MENU_DEL="Удалить пользователя"
        L_MENU_LIST="Список пользователей"
        L_MENU_LINK="Показать ссылку / QR"
        L_MENU_TRAFFIC="Обновить трафик"
        L_MENU_RESET="Сбросить трафик"
        L_MENU_EXPIRY="Изменить срок действия"
        L_MENU_SYS="Система"
        L_MENU_RESTART_XRAY="Перезапустить Xray"
        L_MENU_RESTART_CADDY="Перезапустить Caddy"
        L_MENU_LOGS_XRAY="Логи Xray"
        L_MENU_LOGS_CADDY="Логи Caddy"
        L_MENU_MAINT="Обслуживание"
        L_MENU_BACKUP="Бэкап конфигов"
        L_MENU_RESTORE="Восстановить из бэкапа"
        L_MENU_UPDATE="Обновить скрипт из GitHub"
        L_MENU_UNINSTALL="Полное удаление (uninstall)"
        L_MENU_EXIT="Выйти"
        L_MENU_CHOICE="Выбор:"
        L_MENU_BAD="Неверный выбор"
        L_ENTER="Enter для продолжения..."
        L_STATUS_RUN="запущен"
        L_STATUS_STOP="стоп"
        L_STATUS_NODE="Нода:"
        L_STATUS_CDN="CDN:"
        L_STATUS_PORT="Порт:"
        L_USER_NAME="Имя пользователя:"
        L_USER_EXPIRY="Срок действия"
        L_USER_EXPIRY_DAYS="дней, 0 = бессрочно"
        L_USER_TRAFFIC="Лимит трафика"
        L_USER_TRAFFIC_GB="GB, 0 = без лимита"
        L_USER_ADDED="Пользователь добавлен"
        L_USER_EXISTS="Пользователь уже существует"
        L_USER_NOT_FOUND="Не найден"
        L_USER_DEL_NAME="Имя пользователя для удаления:"
        L_USER_DEL_CONFIRM="Удалить? [y/N]:"
        L_USER_DELETED="Пользователь удалён"
        L_USER_NO_USERS="Нет пользователей. Добавь через пункт 1."
        L_USER_NAME_HEADER="ИМЯ"
        L_USER_EXPIRY_HEADER="СРОК"
        L_USER_LIMIT_HEADER="ЛИМИТ"
        L_USER_USED_HEADER="ИСПОЛЬЗ"
        L_USER_STATUS_HEADER="СТАТУС"
        L_USER_ACTIVE="активен"
        L_USER_EXPIRED="истёк"
        L_USER_OVERLIMIT="лимит"
        L_USER_UNLIMITED="∞ (без лимита)"
        L_USER_TRAFFIC_USED="Использовано трафика (GB):"
        L_USER_TRAFFIC_SET="Трафик"
        L_USER_TRAFFIC_ALL="Имя (или 'all'):"
        L_USER_TRAFFIC_RESET_ALL="Трафик сброшен для всех"
        L_USER_TRAFFIC_RESET_ONE="Трафик сброшен"
        L_USER_EXPIRY_NEW="Новый срок (дней, 0 = бессрочно):"
        L_USER_EXPIRY_SET="Срок"
        L_VLESS_LINK="VLESS ссылка:"
        L_QR_CODE="QR-код:"
        L_QR_ONLINE="QR онлайн:"
        L_BACKUP_CREATED="Бэкап создан:"
        L_BACKUP_NONE="Нет бэкапов в"
        L_BACKUP_LIST="Доступные бэкапы:"
        L_BACKUP_CHOOSE="Выбери номер:"
        L_BACKUP_BAD="Неверный выбор"
        L_BACKUP_RESTORED="Восстановлено из"
        L_UPDATE_TITLE="Обновление скрипта"
        L_UPDATE_DONE="Обновлено:"
        L_UPDATE_LATEST="Уже последняя версия:"
        L_UPDATE_FAIL="Не удалось скачать обновление"
        L_UPDATE_RESTART="Перезапусти: xcdn"
        L_UNINSTALL_TITLE="Полное удаление Caddy + Xray + конфигов"
        L_UNINSTALL_DESC="Будут удалены: Caddy, Xray, UFW правила, конфиги, users.db"
        L_UNINSTALL_CONFIRM="Введи YES для подтверждения:"
        L_UNINSTALL_CANCEL="Отменено"
        L_UNINSTALL_BACKUP="Создаю бэкап перед удалением"
        L_UNINSTALL_STOP="Остановка сервисов"
        L_UNINSTALL_XRAY="Удаление Xray"
        L_UNINSTALL_CADDY="Удаление Caddy"
        L_UNINSTALL_CLEAN="Очистка"
        L_UNINSTALL_UFW="Сброс UFW"
        L_UNINSTALL_DONE="Всё удалено. Бэкап сохранён в"
        L_UNINSTALL_SSH="SSH (22) оставлен открытым"
        L_RESTARTED="перезапущен"
        L_ERROR="Ошибка"
    fi
}

ask_language() {
    clear
    echo ""
    echo -e "  ${CYAN}${BOLD}${UI_RULE}${NC}"
    echo -e "  ${CYAN}${BOLD}Select language / Выбери язык${NC}"
    echo -e "  ${CYAN}${BOLD}${UI_RULE}${NC}"
    echo ""
    echo -e "  ${BOLD}1)${NC}  English"
    echo -e "  ${BOLD}2)${NC}  Русский"
    echo ""
    echo -ne "  ${BOLD}[1/2]:${NC} "
    read -r lang_choice
    case "$lang_choice" in
        1) LANG_SET="en" ;;
        *) LANG_SET="ru" ;;
    esac
    set_lang
}

# =============================================================================
# УТИЛИТЫ
# =============================================================================

info()  { echo -e "  ${GREEN}✓${NC}  $1"; }
warn()  { echo -e "  ${YELLOW}⚠${NC}  $1"; }
error() { echo -e "  ${RED}✗${NC}  $1"; exit 1; }
step()  { echo -e "\n${BOLD}${CYAN}  ▸ $1${NC}"; }

print_block() {
    local title="$1"; shift
    echo -e "  ${CYAN}${BOLD}${title}${NC}"
    echo -e "  ${CYAN}${UI_RULE}${NC}"
    local row label value
    for row in "$@"; do
        label="${row%%|*}"
        value="${row#*|}"
        echo -e "  ${DIM}${label}${NC} ${BOLD}${value}${NC}"
    done
    echo -e "  ${CYAN}${UI_RULE}${NC}"
}

print_banner() {
    clear
    echo ""
    echo -e "  ${CYAN}${BOLD}${UI_RULE}${NC}"
    echo -e "  ${CYAN}${BOLD}${L_BANNER_TITLE}${NC}"
    echo -e "  ${CYAN}${DIM}${L_BANNER_SUB}${NC}"
    echo -e "  ${CYAN}${DIM}v${VERSION}${NC}"
    echo -e "  ${CYAN}${BOLD}${UI_RULE}${NC}"
    echo ""
}

check_root() { [[ $EUID -ne 0 ]] && error "$L_ROOT_ERR"; }
check_os()   { [[ ! -f /etc/debian_version ]] && error "$L_OS_ERR"; }

gen_uuid() {
    if command -v uuidgen &>/dev/null; then uuidgen | tr '[:upper:]' '[:lower:]'
    else cat /proc/sys/kernel/random/uuid; fi
}

get_server_ip() { curl -s4 ifconfig.me 2>/dev/null || curl -s4 api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}'; }

is_installed() { [[ -f "$XRAY_CONFIG" && -f "$CADDY_CONFIG" && -f "$PARAMS_FILE" ]]; }

load_params() {
    if [[ -f "$PARAMS_FILE" ]]; then
        CDN_DOMAIN=$(grep "^CDN_DOMAIN="   "$PARAMS_FILE" | cut -d= -f2)
        NODE_DOMAIN=$(grep "^NODE_DOMAIN=" "$PARAMS_FILE" | cut -d= -f2)
        FINGERPRINT=$(grep "^FINGERPRINT=" "$PARAMS_FILE" | cut -d= -f2)
        XRAY_PORT=$(grep   "^XRAY_PORT="  "$PARAMS_FILE" | cut -d= -f2)
        LANG_SET=$(grep    "^LANG_SET="    "$PARAMS_FILE" | cut -d= -f2)
        [[ -z "$LANG_SET" ]] && LANG_SET="ru"
        set_lang
    fi
}

# =============================================================================
# DNS
# =============================================================================

check_dns() {
    step "$L_STEP_DNS"
    local server_ip; server_ip=$(get_server_ip)
    info "${L_DNS_IP} ${server_ip}"
    local dns_ip=""
    if command -v dig &>/dev/null; then
        dns_ip=$(dig +short "$NODE_DOMAIN" 2>/dev/null | head -1)
    elif command -v host &>/dev/null; then
        dns_ip=$(host "$NODE_DOMAIN" 2>/dev/null | awk '/has address/ {print $4}' | head -1)
    fi
    if [[ -z "$dns_ip" ]]; then
        if command -v dig &>/dev/null || command -v host &>/dev/null; then
            warn "${L_DNS_FAIL} ${NODE_DOMAIN}"
            warn "$L_DNS_ENSURE"
            echo -ne "  ${YELLOW}${L_CONTINUE}${NC} "; read -r c; [[ ! "$c" =~ ^[Yy]$ ]] && exit 0
        else
            warn "$L_DNS_SKIP"
        fi
    elif [[ "$dns_ip" != "$server_ip" ]]; then
        warn "DNS ${NODE_DOMAIN} → ${dns_ip}, IP → ${server_ip}"
        warn "$L_DNS_MISMATCH"
        echo -ne "  ${YELLOW}${L_CONTINUE}${NC} "; read -r c; [[ ! "$c" =~ ^[Yy]$ ]] && exit 0
    else
        info "${L_DNS_OK} ${NODE_DOMAIN} → ${dns_ip}"
    fi
}

# =============================================================================
# ВВОД ПАРАМЕТРОВ
# =============================================================================

is_valid_domain() {
    local d="$1"
    # only letters, digits, dots, hyphens; must have at least one dot; no leading/trailing dot or hyphen
    [[ "$d" =~ ^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$ ]]
}

ask_input() {
    step "$L_STEP_PARAMS"
    echo ""
    while true; do
        echo -ne "  ${BOLD}${L_ASK_NODE}${NC} ${DIM}(${L_ASK_NODE_EX})${NC}: "
        read -r NODE_DOMAIN
        if [[ -z "$NODE_DOMAIN" ]]; then warn "$L_EMPTY"; continue; fi
        if ! is_valid_domain "$NODE_DOMAIN"; then warn "$L_BAD_DOMAIN"; continue; fi
        break
    done
    while true; do
        echo -ne "  ${BOLD}${L_ASK_CDN}${NC} ${DIM}(${L_ASK_CDN_EX})${NC}: "
        read -r CDN_DOMAIN
        if [[ -z "$CDN_DOMAIN" ]]; then warn "$L_EMPTY"; continue; fi
        if ! is_valid_domain "$CDN_DOMAIN"; then warn "$L_BAD_DOMAIN"; continue; fi
        break
    done
    echo -ne "  ${BOLD}${L_ASK_PORT}${NC} ${DIM}(${L_ASK_PORT_DEF})${NC}: "
    read -r port_input
    if [[ -n "$port_input" && "$port_input" =~ ^[0-9]+$ && "$port_input" -ge 1024 && "$port_input" -le 65535 ]]; then
        XRAY_PORT="$port_input"
    else
        XRAY_PORT="10085"; [[ -n "$port_input" ]] && warn "$L_BAD_PORT"
    fi
    echo ""
    echo -e "  ${BOLD}${L_ASK_FP}${NC}"
    echo -e "    ${DIM}1)${NC} chrome   ${GREEN}${L_FP_REC}${NC}"
    echo -e "    ${DIM}2)${NC} firefox"
    echo -e "    ${DIM}3)${NC} safari"
    echo -e "    ${DIM}4)${NC} ios"
    echo -e "    ${DIM}5)${NC} android"
    echo -e "    ${DIM}6)${NC} random"
    echo -ne "  ${L_ASK_FP_CHOOSE} ${DIM}[1-6, ${L_ASK_FP_DEF}]${NC}: "
    read -r FP_CHOICE
    case "$FP_CHOICE" in
        2) FINGERPRINT="firefox" ;; 3) FINGERPRINT="safari"  ;;
        4) FINGERPRINT="ios"     ;; 5) FINGERPRINT="android" ;;
        6) FINGERPRINT="random"  ;; *) FINGERPRINT="chrome"  ;;
    esac
    echo ""
    print_block "$L_CONFIRM_TITLE" \
        "$L_CONFIRM_NODE|$NODE_DOMAIN" \
        "$L_CONFIRM_CDN|$CDN_DOMAIN" \
        "$L_CONFIRM_PORT|$XRAY_PORT" \
        "$L_CONFIRM_FP|$FINGERPRINT"
    echo ""
    echo -ne "  ${YELLOW}${L_CONFIRM_OK}${NC} "
    read -r CONFIRM; [[ "$CONFIRM" =~ ^[Nn]$ ]] && ask_input
}

# =============================================================================
# УСТАНОВКА (без изменений в логике, только строки)
# =============================================================================

install_deps() {
    step "$L_STEP_DEPS"
    apt-get update -qq -o DPkg::Lock::Timeout=300
    apt-get install -y -qq -o DPkg::Lock::Timeout=300 \
        debian-keyring debian-archive-keyring apt-transport-https \
        curl ufw uuid-runtime lsb-release gnupg qrencode jq bc dnsutils
    local missing=""
    for bin in curl gpg uuidgen qrencode; do
        command -v "$bin" &>/dev/null || missing="${missing}${bin} "
    done
    if [[ -n "$missing" ]]; then
        error "$L_DEPS_FAIL: $missing"
    fi
    info "$L_DEPS_OK"
}

install_caddy() {
    step "$L_STEP_CADDY"
    if command -v caddy &>/dev/null; then warn "$L_CADDY_EXISTS"; return; fi
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list > /dev/null
    apt-get update -qq -o DPkg::Lock::Timeout=300
    apt-get install -y -qq -o DPkg::Lock::Timeout=300 caddy
    if ! command -v caddy &>/dev/null; then
        error "$L_CADDY_FAIL"
    fi
    info "$L_CADDY_OK"
}

configure_caddy() {
    step "$L_STEP_CADDY_CFG"
    mkdir -p /var/www/html
    [[ ! -f /var/www/html/index.html ]] && echo "<html><body><h1>OK</h1></body></html>" > /var/www/html/index.html
    cat > "$CADDY_CONFIG" <<EOF
${NODE_DOMAIN} {
    handle /xhttp/* {
        header {
            Cache-Control "private, proxy-revalidate, no-store, no-cache, must-revalidate, max-age=0"
            Accept "application/vnd.api+json, application/json, text/plain, */*"
            Pragma "no-cache"
            Accept-Language "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7"
        }
        reverse_proxy 127.0.0.1:${XRAY_PORT} { flush_interval -1 }
    }
    handle { root * /var/www/html; file_server }
}
EOF
    systemctl enable caddy --quiet 2>/dev/null || true
    systemctl reload caddy 2>/dev/null || systemctl restart caddy 2>/dev/null
    sleep 1
    if systemctl is-active --quiet caddy; then
        info "Caddyfile → /xhttp/* → 127.0.0.1:${XRAY_PORT}"
    else
        warn "Caddy: $L_CADDY_FAIL_HINT"
    fi
}

install_xray() {
    step "$L_STEP_XRAY"
    if ! command -v xray &>/dev/null; then
        bash <(curl -fsSL https://github.com/XTLS/Xray-install/raw/main/install-release.sh) install
    else warn "$L_XRAY_EXISTS"; fi
    if ! command -v xray &>/dev/null; then
        error "$L_XRAY_FAIL"
    fi
    info "$L_XRAY_OK"
}

write_xray_config() {
    mkdir -p /usr/local/etc/xray; touch "$USERS_DB"
    local clients="[]"
    if [[ -s "$USERS_DB" ]]; then
        clients="["; local first=true
        while IFS='|' read -r name uuid expiry tl tu; do
            [[ -z "$uuid" ]] && continue; $first || clients+=","
            clients+="{\"id\":\"${uuid}\",\"email\":\"${name}\",\"flow\":\"\"}"; first=false
        done < "$USERS_DB"; clients+="]"
    fi
    cat > "$XRAY_CONFIG" <<EOF
{
  "log":{"loglevel":"warning"},
  "dns":{"servers":["https://1.1.1.1/dns-query","https://8.8.8.8/dns-query"]},
  "inbounds":[{"tag":"xhttp-cdn","port":${XRAY_PORT},"listen":"127.0.0.1","protocol":"vless",
    "settings":{"clients":${clients},"decryption":"none"},
    "sniffing":{"enabled":true,"destOverride":["http","tls","quic"]},
    "streamSettings":{"network":"xhttp","security":"none","xhttpSettings":{
      "mode":"packet-up","path":"/xhttp",
      "extra":{"path":"/xhttp","xmux":{"cMaxLifetimeMs":0,"cMaxReuseTimes":0,"maxConcurrency":"16-32","maxConnections":0},
        "seqKey":"page","sessionKey":"X-Auth-Token","xPaddingKey":"_dc","seqPlacement":"query",
        "xPaddingHeader":"X-Cache","xPaddingMethod":"tokenish","sessionPlacement":"header",
        "uplinkHTTPMethod":"GET","xPaddingObfsMode":true,"xPaddingPlacement":"header"},
      "channels":4,"uploadPath":"/xhttp/up","noSSEHeader":false,"downloadPath":"/xhttp/dl","scavengeWindow":10}}}],
  "outbounds":[{"tag":"DIRECT","protocol":"freedom"},{"tag":"BLOCK","protocol":"blackhole"}],
  "routing":{"rules":[{"ip":["geoip:private"],"type":"field","outboundTag":"BLOCK"}],"domainStrategy":"IPIfNonMatch"}
}
EOF
    systemctl restart xray 2>/dev/null || true
}

configure_firewall() {
    step "$L_STEP_FW"
    ufw --force reset > /dev/null 2>&1 || true
    ufw default deny incoming > /dev/null 2>&1 || true; ufw default allow outgoing > /dev/null 2>&1 || true
    ufw allow 22/tcp > /dev/null 2>&1 || true; ufw allow 80/tcp > /dev/null 2>&1 || true
    ufw allow 443/tcp > /dev/null 2>&1 || true; ufw deny "${XRAY_PORT}"/tcp > /dev/null 2>&1 || true
    ufw --force enable > /dev/null 2>&1 || true
    info "22, 80, 443 — ${L_FW_OPEN}"; info "${XRAY_PORT} — ${L_FW_CLOSED}"
}

install_command() {
    step "$L_STEP_CMD"; mkdir -p "$INSTALL_DIR"
    local src; src="$(realpath "$0" 2>/dev/null || echo "")"
    if [[ -f "$src" && "$src" != "/dev/stdin" && "$src" != /proc/* && "$src" != /dev/fd/* ]]; then
        cp "$src" "${INSTALL_DIR}/install.sh"
    else
        if ! curl -fsSL "$REPO_URL" -o "${INSTALL_DIR}/install.sh"; then
            warn "$L_CMD_DOWNLOAD_FAIL"
            return
        fi
    fi
    if [[ ! -s "${INSTALL_DIR}/install.sh" ]]; then
        warn "$L_CMD_DOWNLOAD_FAIL"
        return
    fi
    chmod +x "${INSTALL_DIR}/install.sh"
    cat > "$CMD_PATH" << 'XCMD'
#!/bin/bash
exec bash /opt/xcdn/install.sh "$@"
XCMD
    chmod +x "$CMD_PATH"; hash -r 2>/dev/null || true; info "$L_CMD_OK"
}

save_params() {
    cat > "$PARAMS_FILE" <<EOF
NODE_DOMAIN=${NODE_DOMAIN}
CDN_DOMAIN=${CDN_DOMAIN}
FINGERPRINT=${FINGERPRINT}
XRAY_PORT=${XRAY_PORT}
LANG_SET=${LANG_SET}
VERSION=${VERSION}
INSTALLED=$(date +%Y-%m-%d)
EOF
}

# =============================================================================
# CRON
# =============================================================================

install_cron() {
    step "$L_STEP_CRON"
    cat > "$CRON_SCRIPT" << 'CRONEOF'
#!/bin/bash
USERS_DB="/usr/local/etc/xray/users.db"
[[ ! -f "$USERS_DB" ]] && exit 0
changed=false; now=$(date +%s); tmpfile=$(mktemp)
while IFS='|' read -r name uuid expiry tlimit tused; do
    [[ -z "$uuid" ]] && continue; remove=false
    if [[ "$expiry" != "never" ]]; then
        exp_ts=$(date -d "$expiry" +%s 2>/dev/null || echo 0); [[ $exp_ts -lt $now ]] && remove=true; fi
    if [[ "$tlimit" -gt 0 ]]; then ui=${tused%%.*}; ui=${ui:-0}; [[ $ui -ge $tlimit ]] && remove=true; fi
    if $remove; then logger "xcdn: blocked ${name}"; changed=true
    else echo "${name}|${uuid}|${expiry}|${tlimit}|${tused}" >> "$tmpfile"; fi
done < "$USERS_DB"
if $changed; then mv "$tmpfile" "$USERS_DB"; bash /opt/xcdn/install.sh --rebuild-config 2>/dev/null
else rm -f "$tmpfile"; fi
CRONEOF
    chmod +x "$CRON_SCRIPT"
    (crontab -l 2>/dev/null | grep -v "$CRON_SCRIPT"; echo "0 * * * * ${CRON_SCRIPT}") | crontab - 2>/dev/null || true
    info "$L_CRON_OK"
}

# =============================================================================
# VLESS / QR
# =============================================================================

make_vless_link() {
    local name="$1" uuid="$2"
    echo "vless://${uuid}@${CDN_DOMAIN}:443?type=xhttp&path=%2Fxhttp&security=tls&sni=${CDN_DOMAIN}&fp=${FINGERPRINT}&mode=packet-up#${name}"
}

show_qr() {
    local link="$1"; echo ""
    echo -e "  ${BOLD}${L_VLESS_LINK}${NC}"; echo -e "  ${CYAN}${link}${NC}"; echo ""
    if command -v qrencode &>/dev/null; then
        echo -e "  ${BOLD}${L_QR_CODE}${NC}"; qrencode -t ANSIUTF8 -m 2 "$link"
    else
        echo -e "  ${BOLD}${L_QR_ONLINE}${NC}"
        local safe; safe=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${link}', safe=':/?=&#'))" 2>/dev/null || echo "$link")
        echo -e "  ${YELLOW}https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${safe}${NC}"
    fi; echo ""
}

# =============================================================================
# ПОЛЬЗОВАТЕЛИ
# =============================================================================

user_add() {
    load_params; echo ""
    echo -ne "  ${BOLD}${L_USER_NAME}${NC} "; read -r name
    [[ -z "$name" ]] && warn "$L_EMPTY" && return
    grep -q "^${name}|" "$USERS_DB" 2>/dev/null && warn "'${name}' — $L_USER_EXISTS" && return
    echo -ne "  ${BOLD}${L_USER_EXPIRY}${NC} ${DIM}(${L_USER_EXPIRY_DAYS})${NC}: "; read -r days; days=${days:-0}
    local expiry; [[ "$days" -gt 0 ]] && expiry=$(date -d "+${days} days" +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d) || expiry="never"
    echo -ne "  ${BOLD}${L_USER_TRAFFIC}${NC} ${DIM}(${L_USER_TRAFFIC_GB})${NC}: "; read -r tl; tl=${tl:-0}
    local uuid; uuid=$(gen_uuid)
    echo "${name}|${uuid}|${expiry}|${tl}|0" >> "$USERS_DB"; write_xray_config
    echo ""
    local ts="${tl} GB"; [[ "$tl" == "0" ]] && ts="$L_USER_UNLIMITED"
    print_block "$L_USER_ADDED" \
        "${L_NAME_LABEL}|$name" \
        "UUID|$uuid" \
        "${L_USER_EXPIRY}|$expiry" \
        "${L_USER_TRAFFIC}|$ts"
    show_qr "$(make_vless_link "$name" "$uuid")"
}

user_delete() {
    echo ""; echo -ne "  ${BOLD}${L_USER_DEL_NAME}${NC} "; read -r name; [[ -z "$name" ]] && return
    grep -q "^${name}|" "$USERS_DB" 2>/dev/null || { warn "'${name}' — $L_USER_NOT_FOUND"; return; }
    echo -ne "  ${YELLOW}'${name}' — ${L_USER_DEL_CONFIRM}${NC} "; read -r c; [[ ! "$c" =~ ^[Yy]$ ]] && return
    sed -i "/^${name}|/d" "$USERS_DB"; write_xray_config; info "'${name}' — $L_USER_DELETED"
}

user_list() {
    load_params; echo ""
    if [[ ! -s "$USERS_DB" ]]; then warn "$L_USER_NO_USERS"; return; fi
    local now; now=$(date +%s)
    echo -e "  ${BOLD}$(printf '%-18s %-36s %-12s %-10s %-10s %s' "$L_USER_NAME_HEADER" UUID "$L_USER_EXPIRY_HEADER" "$L_USER_LIMIT_HEADER" "$L_USER_USED_HEADER" "$L_USER_STATUS_HEADER")${NC}"
    echo -e "  $(printf '%.0s─' {1..100})"
    while IFS='|' read -r name uuid expiry tl tu; do
        [[ -z "$uuid" ]] && continue
        local status="${GREEN}${L_USER_ACTIVE}${NC}"
        if [[ "$expiry" != "never" ]]; then
            local et; et=$(date -d "$expiry" +%s 2>/dev/null || echo 0); [[ $et -lt $now ]] && status="${RED}${L_USER_EXPIRED}${NC}"; fi
        if [[ "$tl" -gt 0 ]]; then local ui=${tu%%.*}; ui=${ui:-0}; [[ $ui -ge $tl ]] && status="${RED}${L_USER_OVERLIMIT}${NC}"; fi
        local ls="${tl} GB"; [[ "$tl" == "0" ]] && ls="∞"
        printf "  %-18s %-36s %-12s %-10s %-10s " "$name" "$uuid" "$expiry" "$ls" "${tu:-0} GB"; echo -e "$status"
    done < "$USERS_DB"; echo ""
}

user_show_link() { load_params; echo ""; echo -ne "  ${BOLD}${L_USER_NAME}${NC} "; read -r name; [[ -z "$name" ]] && return
    local l; l=$(grep "^${name}|" "$USERS_DB" 2>/dev/null); [[ -z "$l" ]] && warn "$L_USER_NOT_FOUND" && return
    show_qr "$(make_vless_link "$name" "$(echo "$l"|cut -d'|' -f2)")"; }

user_update_traffic() { echo ""; echo -ne "  ${BOLD}${L_USER_NAME}${NC} "; read -r name; [[ -z "$name" ]] && return
    grep -q "^${name}|" "$USERS_DB" 2>/dev/null || { warn "$L_USER_NOT_FOUND"; return; }
    echo -ne "  ${BOLD}${L_USER_TRAFFIC_USED}${NC} "; read -r used
    sed -i "s/^${name}|\([^|]*\)|\([^|]*\)|\([^|]*\)|.*/${name}|\1|\2|\3|${used}/" "$USERS_DB"
    info "${L_USER_TRAFFIC_SET} '${name}': ${used} GB"; }

user_reset_traffic() { echo ""; echo -ne "  ${BOLD}${L_USER_TRAFFIC_ALL}${NC} "; read -r name; [[ -z "$name" ]] && return
    if [[ "$name" == "all" ]]; then sed -i 's/|\([^|]*\)$/|0/' "$USERS_DB"; info "$L_USER_TRAFFIC_RESET_ALL"
    else grep -q "^${name}|" "$USERS_DB" 2>/dev/null || { warn "$L_USER_NOT_FOUND"; return; }
        sed -i "s/^${name}|\([^|]*\)|\([^|]*\)|\([^|]*\)|.*/${name}|\1|\2|\3|0/" "$USERS_DB"
        info "${L_USER_TRAFFIC_RESET_ONE} '${name}'"; fi; }

user_change_expiry() { echo ""; echo -ne "  ${BOLD}${L_USER_NAME}${NC} "; read -r name; [[ -z "$name" ]] && return
    grep -q "^${name}|" "$USERS_DB" 2>/dev/null || { warn "$L_USER_NOT_FOUND"; return; }
    echo -ne "  ${BOLD}${L_USER_EXPIRY_NEW}${NC} "; read -r days
    local expiry; [[ "$days" -gt 0 ]] && expiry=$(date -d "+${days} days" +%Y-%m-%d) || expiry="never"
    sed -i "s/^${name}|\([^|]*\)|[^|]*|\([^|]*\)|\([^|]*\)$/${name}|\1|${expiry}|\2|\3/" "$USERS_DB"
    write_xray_config; info "${L_USER_EXPIRY_SET} '${name}': ${expiry}"; }

# =============================================================================
# БЭКАП / ВОССТАНОВЛЕНИЕ / ОБНОВЛЕНИЕ / УДАЛЕНИЕ
# =============================================================================

do_backup() { local ts; ts=$(date +%Y%m%d_%H%M%S); local bd="${BACKUP_DIR}/${ts}"; mkdir -p "$bd"
    [[ -f "$XRAY_CONFIG" ]] && cp "$XRAY_CONFIG" "$bd/"; [[ -f "$CADDY_CONFIG" ]] && cp "$CADDY_CONFIG" "$bd/"
    [[ -f "$USERS_DB" ]] && cp "$USERS_DB" "$bd/"; [[ -f "$PARAMS_FILE" ]] && cp "$PARAMS_FILE" "$bd/"
    info "${L_BACKUP_CREATED} ${bd}"; }

do_restore() { echo ""
    [[ ! -d "$BACKUP_DIR" ]] && warn "${L_BACKUP_NONE} ${BACKUP_DIR}" && return
    echo -e "  ${BOLD}${L_BACKUP_LIST}${NC}"; local i=1; local -a dirs=()
    for d in $(ls -1d "${BACKUP_DIR}"/*/ 2>/dev/null | sort -r); do
        echo -e "    ${DIM}${i})${NC} $(basename "$d")"; dirs+=("$d"); i=$((i+1)); done
    [[ ${#dirs[@]} -eq 0 ]] && warn "${L_BACKUP_NONE}" && return
    echo -ne "  ${BOLD}${L_BACKUP_CHOOSE}${NC} "; read -r num; num=$((num-1))
    [[ $num -lt 0 || $num -ge ${#dirs[@]} ]] && warn "$L_BACKUP_BAD" && return
    local s="${dirs[$num]}"
    [[ -f "${s}/config.json" ]] && cp "${s}/config.json" "$XRAY_CONFIG"
    [[ -f "${s}/Caddyfile" ]] && cp "${s}/Caddyfile" "$CADDY_CONFIG"
    [[ -f "${s}/users.db" ]] && cp "${s}/users.db" "$USERS_DB"
    [[ -f "${s}/xray-cdn-params.txt" ]] && cp "${s}/xray-cdn-params.txt" "$PARAMS_FILE"
    systemctl restart xray 2>/dev/null || true; systemctl reload caddy 2>/dev/null || true; load_params
    info "${L_BACKUP_RESTORED} $(basename "$s")"; }

do_update() { step "$L_UPDATE_TITLE"; local tmp; tmp=$(mktemp)
    if curl -fsSL "$REPO_URL" -o "$tmp" 2>/dev/null; then
        local nv; nv=$(grep '^VERSION=' "$tmp" | head -1 | cut -d'"' -f2)
        if [[ -n "$nv" && "$nv" != "$VERSION" ]]; then
            cp "$tmp" "${INSTALL_DIR}/install.sh"; chmod +x "${INSTALL_DIR}/install.sh"
            info "${L_UPDATE_DONE} v${VERSION} → v${nv}"; info "$L_UPDATE_RESTART"
        else info "${L_UPDATE_LATEST} v${VERSION}"; fi
    else warn "$L_UPDATE_FAIL"; fi; rm -f "$tmp"; }

do_uninstall() { echo ""
    echo -e "  ${RED}${BOLD}${L_UNINSTALL_TITLE}${NC}"
    echo -e "  ${DIM}${L_UNINSTALL_DESC}${NC}"; echo ""
    echo -ne "  ${RED}${L_UNINSTALL_CONFIRM}${NC} "; read -r c; [[ "$c" != "YES" ]] && warn "$L_UNINSTALL_CANCEL" && return
    step "$L_UNINSTALL_BACKUP"; do_backup
    step "$L_UNINSTALL_STOP"
    systemctl stop xray 2>/dev/null || true; systemctl disable xray 2>/dev/null || true
    systemctl stop caddy 2>/dev/null || true; systemctl disable caddy 2>/dev/null || true
    step "$L_UNINSTALL_XRAY"
    bash <(curl -fsSL https://github.com/XTLS/Xray-install/raw/main/install-release.sh) remove 2>/dev/null || true
    rm -rf /usr/local/etc/xray
    step "$L_UNINSTALL_CADDY"
    apt-get remove -y caddy 2>/dev/null || true; apt-get purge -y caddy 2>/dev/null || true
    rm -f /etc/apt/sources.list.d/caddy-stable.list; rm -f /usr/share/keyrings/caddy-stable-archive-keyring.gpg; rm -rf /etc/caddy
    step "$L_UNINSTALL_CLEAN"
    rm -f "$CMD_PATH"; rm -rf "$INSTALL_DIR"; rm -f "$PARAMS_FILE"
    crontab -l 2>/dev/null | grep -v "$CRON_SCRIPT" | crontab - 2>/dev/null || true
    step "$L_UNINSTALL_UFW"
    ufw --force reset > /dev/null 2>&1 || true; ufw allow 22/tcp > /dev/null 2>&1 || true; ufw --force enable > /dev/null 2>&1 || true
    echo ""; info "${L_UNINSTALL_DONE} ${BACKUP_DIR}"; info "$L_UNINSTALL_SSH"; echo ""; exit 0; }

# =============================================================================
# МЕНЮ
# =============================================================================

show_status() { load_params
    local cs xs cnt
    systemctl is-active --quiet caddy 2>/dev/null && cs="${GREEN}● ${L_STATUS_RUN}${NC}" || cs="${RED}● ${L_STATUS_STOP}${NC}"
    systemctl is-active --quiet xray  2>/dev/null && xs="${GREEN}● ${L_STATUS_RUN}${NC}" || xs="${RED}● ${L_STATUS_STOP}${NC}"
    if [[ -f "$USERS_DB" ]]; then cnt=$(grep -c '.' "$USERS_DB"); else cnt=0; fi
    echo -e "  ${CYAN}${UI_RULE}${NC}"
    echo -e "  ${DIM}${L_STATUS_NODE}${NC} ${BOLD}${NODE_DOMAIN:-n/a}${NC}"
    echo -e "  ${DIM}${L_STATUS_CDN}${NC}  ${BOLD}${CDN_DOMAIN:-n/a}${NC}"
    echo -e "  ${DIM}${L_STATUS_PORT}${NC} ${BOLD}${XRAY_PORT:-n/a}${NC}   ${DIM}v${VERSION}${NC}"
    echo -e "  ${CYAN}${UI_RULE}${NC}"
    echo -e "  Caddy $(echo -e "$cs")    Xray $(echo -e "$xs")    Users: ${BOLD}${cnt}${NC}"
    echo -e "  ${CYAN}${UI_RULE}${NC}"; echo ""; }

main_menu() { while true; do print_banner; show_status
    echo -e "  ${BOLD}${L_MENU_USERS}${NC}"
    echo -e "  ${DIM} 1)${NC} ${L_MENU_ADD}";      echo -e "  ${DIM} 2)${NC} ${L_MENU_DEL}"
    echo -e "  ${DIM} 3)${NC} ${L_MENU_LIST}";     echo -e "  ${DIM} 4)${NC} ${L_MENU_LINK}"
    echo -e "  ${DIM} 5)${NC} ${L_MENU_TRAFFIC}";  echo -e "  ${DIM} 6)${NC} ${L_MENU_RESET}"
    echo -e "  ${DIM} 7)${NC} ${L_MENU_EXPIRY}";   echo ""
    echo -e "  ${BOLD}${L_MENU_SYS}${NC}"
    echo -e "  ${DIM} 8)${NC} ${L_MENU_RESTART_XRAY}";  echo -e "  ${DIM} 9)${NC} ${L_MENU_RESTART_CADDY}"
    echo -e "  ${DIM}10)${NC} ${L_MENU_LOGS_XRAY}";     echo -e "  ${DIM}11)${NC} ${L_MENU_LOGS_CADDY}"; echo ""
    echo -e "  ${BOLD}${L_MENU_MAINT}${NC}"
    echo -e "  ${DIM}12)${NC} ${L_MENU_BACKUP}";   echo -e "  ${DIM}13)${NC} ${L_MENU_RESTORE}"
    echo -e "  ${DIM}14)${NC} ${L_MENU_UPDATE}";   echo -e "  ${DIM}15)${NC} ${RED}${L_MENU_UNINSTALL}${NC}"
    echo -e "  ${DIM} 0)${NC} ${L_MENU_EXIT}";     echo ""
    echo -ne "  ${BOLD}${L_MENU_CHOICE}${NC} "; read -r ch
    case "$ch" in
        1) user_add;; 2) user_delete;; 3) user_list;; 4) user_show_link;;
        5) user_update_traffic;; 6) user_reset_traffic;; 7) user_change_expiry;;
        8) systemctl restart xray 2>/dev/null && info "Xray $L_RESTARTED" || warn "$L_ERROR";;
        9) systemctl restart caddy 2>/dev/null && info "Caddy $L_RESTARTED" || warn "$L_ERROR";;
        10) journalctl -u xray -n 60 --no-pager 2>/dev/null || true;;
        11) journalctl -u caddy -n 60 --no-pager 2>/dev/null || true;;
        12) do_backup;; 13) do_restore;; 14) do_update;; 15) do_uninstall;;
        0) echo ""; exit 0;; *) warn "$L_MENU_BAD";; esac
    echo ""; echo -ne "  ${DIM}${L_ENTER}${NC}"; read -r; done; }

# =============================================================================
# ФИНАЛ
# =============================================================================

verify_setup() { step "$L_STEP_VERIFY"
    ss -tlnp 2>/dev/null | grep -q ":${XRAY_PORT}" && info "${L_VERIFY_LISTEN} ${XRAY_PORT}" || warn "${L_VERIFY_NO_LISTEN} ${XRAY_PORT}"
    systemctl is-active --quiet caddy 2>/dev/null && info "$L_VERIFY_CADDY_OK" || warn "$L_VERIFY_CADDY_FAIL"
    systemctl is-active --quiet xray  2>/dev/null && info "$L_VERIFY_XRAY_OK"  || warn "$L_VERIFY_XRAY_FAIL"; }

print_finish() { echo ""
    echo -e "${GREEN}${BOLD}  ✓ ${L_FINISH_TITLE} ✓${NC}"
    print_block "$L_CONFIRM_TITLE" \
        "$L_CONFIRM_NODE|$NODE_DOMAIN" \
        "$L_CONFIRM_CDN|$CDN_DOMAIN" \
        "$L_CONFIRM_PORT|$XRAY_PORT" \
        "$L_CONFIRM_FP|$FINGERPRINT"
    echo ""
    print_block "$L_FINISH_CDN_TITLE" \
        "$L_FINISH_ORIGIN|$NODE_DOMAIN" \
        "$L_FINISH_HTTPS|$L_FINISH_ENABLED" \
        "$L_FINISH_CACHE|$L_FINISH_ENABLED" \
        "$L_FINISH_HTTP|GET, POST"
    echo ""
    echo -e "  ${BOLD}${CYAN}${L_FINISH_MANAGE}${NC}"
    echo -e "  ${BOLD}${CYAN}${L_FINISH_UPDATE}${NC}"
    echo ""
    echo -e "  ${DIM}${L_FINISH_PARAMS} ${PARAMS_FILE}${NC}"
    echo -e "  ${DIM}${L_FINISH_CRON_NOTE}${NC}"; echo ""; }

# =============================================================================
# ТОЧКА ВХОДА
# =============================================================================

[[ "$1" == "--rebuild-config" ]] && { load_params; write_xray_config; exit 0; }
[[ "$1" == "update" ]] && { check_root; load_params; do_update; exit 0; }

check_root; check_os

if is_installed; then
    load_params; main_menu
else
    ask_language
    ask_input; check_dns; install_deps; install_caddy; configure_caddy
    install_xray; touch "$USERS_DB"; write_xray_config
    configure_firewall; install_command; install_cron; save_params
    verify_setup; print_finish
    echo -ne "  ${YELLOW}${L_OPEN_MENU}${NC} "; read -r gm; [[ ! "$gm" =~ ^[Nn]$ ]] && main_menu
fi
