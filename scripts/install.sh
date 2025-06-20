#!/usr/bin/env bash
set -euo pipefail

STACK_REPO="https://github.com/HouseOfAgile/dockerized-wordpress.git"
VENDOR_DIR="vendor/dockerized-wordpress"
STACK_REF="main"

# If user passed a ref/tag
if [[ $1 =~ ^[a-zA-Z0-9._-]+$ && ! -f "$1" ]]; then
  STACK_REF="$1"
  shift
fi

# If user passed a project name as first positional
PROJECT_ARG="${1-}"

echo "Installing/updating stack @$STACK_REF → $VENDOR_DIR"
if [ -d "$VENDOR_DIR/.git" ]; then
  git -C "$VENDOR_DIR" fetch --all
  git -C "$VENDOR_DIR" checkout "$STACK_REF"
  git -C "$VENDOR_DIR" pull
else
  git clone --depth 1 --branch "$STACK_REF" \
    "$STACK_REPO" "$VENDOR_DIR"
fi

mapfile -t ENVFILES < <(ls -1 .env.* 2>/dev/null || true)

if [ ${#ENVFILES[@]} -eq 0 ]; then
  echo "No .env.<project> files found in $(pwd)." >&2
  echo "Please create one based on $VENDOR_DIR/.env.example:"  
  echo "  cp $VENDOR_DIR/.env.example .env.myproject"  
  exit 1
fi

# If user passed project name, look for that file
if [ -n "$PROJECT_ARG" ]; then
  TARGET_ENV=".env.$PROJECT_ARG"
  if [[ ! " ${ENVFILES[*]} " =~ " $TARGET_ENV " ]]; then
    echo ".env file for '$PROJECT_ARG' not found." >&2
    exit 1
  fi
else
  # If there is exactly one, pick it; otherwise ask
  if [ ${#ENVFILES[@]} -eq 1 ]; then
    TARGET_ENV="${ENVFILES[0]}"
  else
    echo "Multiple .env files detected:"
    for f in "${ENVFILES[@]}"; do echo "  - $f"; done
    echo
    echo "Please specify the project name, e.g.:"
    echo "  $0 <tag> <project>"  
    echo "or"
    echo "  $0 <project>"
    exit 1
  fi
fi

# Validate PROJECT_NAME inside the env file
ENV_PROJECT_NAME=$(grep -E '^PROJECT_NAME=' "$TARGET_ENV" | cut -d= -f2-)
if [ "${ENV_PROJECT_NAME}" != "${TARGET_ENV#.env.}" ]; then
  echo "   Warning: PROJECT_NAME in $TARGET_ENV is '$ENV_PROJECT_NAME',"  
  echo "    but filename implies '${TARGET_ENV#.env.}'."
  echo "    These should match."
fi

echo
echo "Using '$TARGET_ENV' (PROJECT_NAME=$ENV_PROJECT_NAME)"

COMPOSE_ENV=".env"
cp "$TARGET_ENV" "$COMPOSE_ENV"

if [ ! -f "$COMPOSE_ENV" ]; then
  echo "Created $COMPOSE_ENV from $TARGET_ENV - please review it."
  exit 0
fi

echo
echo "Ready! To build & start:"
cat <<EOF

docker compose \\
  -f $VENDOR_DIR/docker-compose.yml \\
  --env-file $COMPOSE_ENV \\
  up -d --build

# (you can pass any extra flags after --build)

# To show status:
docker compose -f $VENDOR_DIR/docker-compose.yml ps

# To stop:
docker compose -f $VENDOR_DIR/docker-compose.yml down

EOF
