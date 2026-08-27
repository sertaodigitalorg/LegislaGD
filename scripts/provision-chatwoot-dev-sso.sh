#!/usr/bin/env sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

if [ -f "$ENV_FILE" ]; then
  set -a
  . "$ENV_FILE"
  set +a
fi

cd "$ROOT_DIR"

CHATWOOT_SSO_EMAIL="${CHATWOOT_SSO_EMAIL:-john@acme.inc}"
CHATWOOT_SSO_PASSWORD="${CHATWOOT_SSO_PASSWORD:-}"
CHATWOOT_SSO_NAME="${CHATWOOT_SSO_NAME:-Agente Chatwoot}"
CHATWOOT_SSO_ACCOUNT_NAME="${CHATWOOT_SSO_ACCOUNT_NAME:-Acme Inc}"
CHATWOOT_SSO_ACCOUNT_ROLE="${CHATWOOT_SSO_ACCOUNT_ROLE:-agent}"

if [ -z "$CHATWOOT_SSO_PASSWORD" ]; then
  echo "CHATWOOT_SSO_PASSWORD deve ser definido no ambiente local." >&2
  exit 1
fi

docker compose \
  -p sigi \
  -f modules/SIGI-SD/docker-compose.yml \
  -f infrastructure/compose/overrides/sigi.legislagd.yml \
  exec -T \
  -e "CHATWOOT_SSO_EMAIL=${CHATWOOT_SSO_EMAIL}" \
  -e "CHATWOOT_SSO_PASSWORD=${CHATWOOT_SSO_PASSWORD}" \
  -e "CHATWOOT_SSO_NAME=${CHATWOOT_SSO_NAME}" \
  -e "CHATWOOT_SSO_ACCOUNT_NAME=${CHATWOOT_SSO_ACCOUNT_NAME}" \
  -e "CHATWOOT_SSO_ACCOUNT_ROLE=${CHATWOOT_SSO_ACCOUNT_ROLE}" \
  chatwoot bundle exec rails runner '
email = ENV.fetch("CHATWOOT_SSO_EMAIL").downcase
raw_password = ENV.fetch("CHATWOOT_SSO_PASSWORD")
password = raw_password.match?(/[A-Z]/) &&
           raw_password.match?(/[a-z]/) &&
           raw_password.match?(/[0-9]/) &&
           raw_password.match?(/[^A-Za-z0-9]/) ? raw_password : "#{raw_password}Aa1!"
account_id = ENV.fetch("CHATWOOT_OIDC_ACCOUNT_ID", "").presence
account = if account_id
            Account.find_by(id: account_id) || Account.create!(id: account_id, name: ENV.fetch("CHATWOOT_SSO_ACCOUNT_NAME"))
          else
            Account.find_or_create_by!(name: ENV.fetch("CHATWOOT_SSO_ACCOUNT_NAME"))
          end
user = User.from_email(email) || User.new(
  email: email,
  name: ENV.fetch("CHATWOOT_SSO_NAME"),
  password: password,
  password_confirmation: password,
  type: "SuperAdmin"
)

user.name = ENV.fetch("CHATWOOT_SSO_NAME", user.name.presence || "Agente Chatwoot")
if user.new_record?
  user.password = password
  user.password_confirmation = password
end
user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
user.save!

account_user = AccountUser.find_or_initialize_by(account: account, user: user)
account_user.role = ENV.fetch("CHATWOOT_SSO_ACCOUNT_ROLE")
account_user.save!

puts "Usuario Chatwoot SSO pronto: #{email} / conta #{account.id}"
'
