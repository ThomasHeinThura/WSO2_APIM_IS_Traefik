#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$ROOT_DIR/.env"
ACME_FILE="$ROOT_DIR/data/letsencrypt/acme.json"
APIM_TEMPLATE="$ROOT_DIR/templates/apim/repository/conf/deployment.toml.tpl"
APIM_TARGET="$ROOT_DIR/conf/apim/repository/conf/deployment.toml"
IS_TEMPLATE="$ROOT_DIR/templates/is/repository/conf/deployment.toml.tpl"
IS_TARGET="$ROOT_DIR/conf/is/repository/conf/deployment.toml"

prompt() {
  local var_name="$1"
  local message="$2"
  local default_value="$3"
  local value=""
  read -rp "$message [$default_value]: " value
  if [[ -z "$value" ]]; then
    value="$default_value"
  fi
  printf -v "$var_name" '%s' "$value"
}

prompt_secret() {
  local var_name="$1"
  local message="$2"
  local default_value="$3"
  local value=""
  read -rsp "$message [$default_value]: " value
  echo
  if [[ -z "$value" ]]; then
    value="$default_value"
  fi
  printf -v "$var_name" '%s' "$value"
}

render_apim_config() {
  python3 - "$APIM_TEMPLATE" "$APIM_TARGET" <<'PY'
import os, sys, pathlib
from string import Template

template_path = pathlib.Path(sys.argv[1])
target_path = pathlib.Path(sys.argv[2])
text = template_path.read_text()
replacements = {
    "__APIM_HOSTNAME__": os.environ["TPL_APIM_HOSTNAME"],
    "__APIM_GATEWAY_HOST__": os.environ["TPL_APIM_GATEWAY_HOST"],
    "__APIM_WS_HOST__": os.environ["TPL_APIM_WS_HOST"],
    "__APIM_WEBSUB_HOST__": os.environ["TPL_APIM_WEBSUB_HOST"],
    "__MYSQL_HOST__": os.environ["TPL_MYSQL_HOST"],
    "__MYSQL_USER__": os.environ["TPL_MYSQL_USER"],
    "__MYSQL_PASSWORD__": os.environ["TPL_MYSQL_PASSWORD"],
    "__APIM_DB__": os.environ["TPL_APIM_DB"],
    "__APIM_SHARED_DB__": os.environ["TPL_APIM_SHARED_DB"],
}
for key, value in replacements.items():
    text = text.replace(key, value)
target_path.parent.mkdir(parents=True, exist_ok=True)
target_path.write_text(text)
PY
}

render_is_config() {
  python3 - "$IS_TEMPLATE" "$IS_TARGET" <<'PY'
import os, sys, pathlib

template_path = pathlib.Path(sys.argv[1])
target_path = pathlib.Path(sys.argv[2])
text = template_path.read_text()
replacements = {
    "__IS_HOSTNAME__": os.environ["TPL_IS_HOSTNAME"],
    "__MYSQL_HOST__": os.environ["TPL_MYSQL_HOST"],
    "__MYSQL_USER__": os.environ["TPL_MYSQL_USER"],
    "__MYSQL_PASSWORD__": os.environ["TPL_MYSQL_PASSWORD"],
    "__IS_IDENTITY_DB__": os.environ["TPL_IS_IDENTITY_DB"],
    "__IS_SHARED_DB__": os.environ["TPL_IS_SHARED_DB"],
}
for key, value in replacements.items():
    text = text.replace(key, value)
target_path.parent.mkdir(parents=True, exist_ok=True)
target_path.write_text(text)
PY
}

info() {
  echo -e "\033[1;34m[INFO]\033[0m $1"
}

warn() {
  echo -e "\033[1;33m[WARN]\033[0m $1"
}

main() {
  echo "--- WSO2 APIM + IS + Traefik installer ---"

  prompt BASE_DOMAIN "Primary domain" "example.com"
  prompt LETS_ENCRYPT_EMAIL "Let's Encrypt notification email" "admin@${BASE_DOMAIN}"

  local default_apim_host="am.${BASE_DOMAIN}"
  local default_gateway_host="api.${BASE_DOMAIN}"
  local default_ws_host="ws.${BASE_DOMAIN}"
  local default_websub_host="events.${BASE_DOMAIN}"
  local default_is_host="iam.${BASE_DOMAIN}"
  local default_dashboard_host="traefik.${BASE_DOMAIN}"

  prompt APIM_HOSTNAME "WSO2 API Manager (Publisher/DevPortal) hostname" "$default_apim_host"
  prompt APIM_GATEWAY_HOST "API Gateway hostname" "$default_gateway_host"
  prompt APIM_WS_HOST "Websocket hostname" "$default_ws_host"
  prompt APIM_WEBSUB_HOST "WebSub receiver hostname" "$default_websub_host"
  prompt IS_HOSTNAME "WSO2 Identity Server hostname" "$default_is_host"
  prompt TRAEFIK_DASHBOARD_HOST "Traefik dashboard hostname" "$default_dashboard_host"

  prompt APIM_IMAGE "API Manager image" "wso2/wso2am:4.5.0"
  prompt IS_IMAGE "Identity Server image" "wso2/wso2is:7.1.0"
  prompt NODE_IP "Internal node IP" "127.0.0.1"

  prompt_secret MYSQL_ROOT_PASSWORD "MySQL root password" "ChangeMeRoot!"
  prompt_secret MYSQL_PASSWORD "Shared MySQL app password" "wso2carbon"

  local MYSQL_USER="wso2carbon"
  local MYSQL_HOST="mysql"
  local APIM_DB="WSO2AM_DB"
  local APIM_SHARED_DB="WSO2AM_SHARED_DB"
  local IS_IDENTITY_DB="WSO2IS_IDENTITY_DB"
  local IS_SHARED_DB="WSO2IS_SHARED_DB"

  umask 077
  cat > "$ENV_FILE" <<EOF
BASE_DOMAIN=$BASE_DOMAIN
LETS_ENCRYPT_EMAIL=$LETS_ENCRYPT_EMAIL
APIM_HOSTNAME=$APIM_HOSTNAME
APIM_GATEWAY_HOST=$APIM_GATEWAY_HOST
APIM_WS_HOST=$APIM_WS_HOST
APIM_WEBSUB_HOST=$APIM_WEBSUB_HOST
IS_HOSTNAME=$IS_HOSTNAME
TRAEFIK_DASHBOARD_HOST=$TRAEFIK_DASHBOARD_HOST
APIM_IMAGE=$APIM_IMAGE
IS_IMAGE=$IS_IMAGE
NODE_IP=$NODE_IP
MYSQL_HOST=$MYSQL_HOST
MYSQL_PORT=3306
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_USER=$MYSQL_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD
APIM_DB=$APIM_DB
APIM_SHARED_DB=$APIM_SHARED_DB
IS_IDENTITY_DB=$IS_IDENTITY_DB
IS_SHARED_DB=$IS_SHARED_DB
TRAEFIK_HTTP_PORT=80
TRAEFIK_HTTPS_PORT=443
EOF
  info "Wrote environment file to $ENV_FILE"

  export TPL_APIM_HOSTNAME="$APIM_HOSTNAME"
  export TPL_APIM_GATEWAY_HOST="$APIM_GATEWAY_HOST"
  export TPL_APIM_WS_HOST="$APIM_WS_HOST"
  export TPL_APIM_WEBSUB_HOST="$APIM_WEBSUB_HOST"
  export TPL_MYSQL_HOST="$MYSQL_HOST"
  export TPL_MYSQL_USER="$MYSQL_USER"
  export TPL_MYSQL_PASSWORD="$MYSQL_PASSWORD"
  export TPL_APIM_DB="$APIM_DB"
  export TPL_APIM_SHARED_DB="$APIM_SHARED_DB"
  export TPL_IS_HOSTNAME="$IS_HOSTNAME"
  export TPL_IS_IDENTITY_DB="$IS_IDENTITY_DB"
  export TPL_IS_SHARED_DB="$IS_SHARED_DB"

  render_apim_config
  info "Rendered API Manager deployment.toml"
  render_is_config
  info "Rendered Identity Server deployment.toml"

  mkdir -p "$(dirname "$ACME_FILE")"
  if [[ ! -f "$ACME_FILE" ]]; then
    touch "$ACME_FILE"
  fi
  chmod 600 "$ACME_FILE"
  info "Prepared ACME storage at $ACME_FILE"

  warn "Review .env and conf/* files before running docker compose up -d"
}

main "$@"
