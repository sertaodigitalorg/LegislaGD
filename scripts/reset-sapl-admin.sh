#!/usr/bin/env bash
set -euo pipefail

password="${SAPL_ADMIN_PASSWORD:-interlegis}"
email="${SAPL_ADMIN_EMAIL:-admin@legislagd.localhost}"

docker exec -i \
  -e SAPL_ADMIN_PASSWORD="$password" \
  -e SAPL_ADMIN_EMAIL="$email" \
  sapl-dev \
  python3 - <<'PY'
import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "sapl.settings")

import django
django.setup()

from django.contrib.auth.models import User

password = os.environ["SAPL_ADMIN_PASSWORD"]
email = os.environ["SAPL_ADMIN_EMAIL"]

for username in ("admin", "interlegis"):
    user, _ = User.objects.get_or_create(username=username, defaults={"email": email})
    user.email = user.email or email
    user.is_active = True
    user.is_staff = True
    user.is_superuser = True
    user.set_password(password)
    user.save()
    print(f"{username}: senha atualizada")
PY
