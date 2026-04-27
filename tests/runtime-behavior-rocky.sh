#!/usr/bin/env sh
# Copyright (c) 2026 SnowdreamTech. All rights reserved.
# Licensed under the MIT License. See LICENSE file in the project root for full license information.
#
# Purpose: Runtime behavior test for Rocky Docker container
# Usage: sh tests/runtime-behavior-rocky.sh
#
# Requirements: 3.2, 4.4, 5.1-5.9
# Validates:
#   - Default root user configuration
#   - Custom user creation with PUID/PGID/USER
#   - Environment variables are set correctly
#   - DEBUG mode produces expected output

set -eu

# ── Color Output ─────────────────────────────────────────────────────────────
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  NC=''
fi

# ── Logging Functions ────────────────────────────────────────────────────────
log_info() {
  printf "${BLUE}[INFO]${NC} %s\n" "$*"
}

log_success() {
  printf "${GREEN}[✓]${NC} %s\n" "$*"
}

log_warn() {
  printf "${YELLOW}[!]${NC} %s\n" "$*"
}

log_error() {
  printf "${RED}[✗]${NC} %s\n" "$*"
}

# ── Configuration ────────────────────────────────────────────────────────────
TEST_IMAGE_NAME="base-rocky-runtime-test"
DEFAULT_IMAGE_TAG="default"
CUSTOM_USER_IMAGE_TAG="custom-user"
DOCKERFILE_PATH="docker/rocky/Dockerfile"

# Expected environment variables
EXPECTED_ENV_VARS="
KEEPALIVE=0
CAP_NET_BIND_SERVICE=0
LANG=C.UTF-8
UMASK=022
DEBUG=false
PGID=0
PUID=0
USER=root
WORKDIR=/root
"

# Custom user configuration
CUSTOM_PUID=1000
CUSTOM_PGID=1000
CUSTOM_USER="testuser"

# ── Cleanup Function ─────────────────────────────────────────────────────────
cleanup() {
  log_info "Cleaning up test images and containers..."

  # Remove containers
  docker ps -a --filter "ancestor=${TEST_IMAGE_NAME}:${DEFAULT_IMAGE_TAG}" -q | xargs -r docker rm -f >/dev/null 2>&1 || true
  docker ps -a --filter "ancestor=${TEST_IMAGE_NAME}:${CUSTOM_USER_IMAGE_TAG}" -q | xargs -r docker rm -f >/dev/null 2>&1 || true

  # Remove images
  docker rmi "${TEST_IMAGE_NAME}:${DEFAULT_IMAGE_TAG}" >/dev/null 2>&1 || true
  docker rmi "${TEST_IMAGE_NAME}:${CUSTOM_USER_IMAGE_TAG}" >/dev/null 2>&1 || true

  log_success "Cleanup completed"
}

# ── Test Functions ───────────────────────────────────────────────────────────

# Purpose: Verify Docker is available
test_docker_available() {
  log_info "Checking Docker availability..."

  if ! command -v docker >/dev/null 2>&1; then
    log_error "Docker is not installed or not in PATH"
    return 1
  fi

  if ! docker info >/dev/null 2>&1; then
    log_error "Docker daemon is not running"
    return 1
  fi

  log_success "Docker is available"
  return 0
}

# Purpose: Build default configuration image
test_build_default_image() {
  log_info "Building Rocky Docker image with default configuration..."

  if ! docker build -t "${TEST_IMAGE_NAME}:${DEFAULT_IMAGE_TAG}" -f "${DOCKERFILE_PATH}" docker/rocky/ >/dev/null 2>&1; then
    log_error "Docker build failed for default configuration"
    return 1
  fi

  log_success "Default configuration image built successfully"
  return 0
}

# Purpose: Build custom user configuration image
test_build_custom_user_image() {
  log_info "Building Rocky Docker image with custom user configuration..."

  if ! docker build \
    --build-arg PUID="${CUSTOM_PUID}" \
    --build-arg PGID="${CUSTOM_PGID}" \
    --build-arg USER="${CUSTOM_USER}" \
    -t "${TEST_IMAGE_NAME}:${CUSTOM_USER_IMAGE_TAG}" \
    -f "${DOCKERFILE_PATH}" \
    docker/rocky/ >/dev/null 2>&1; then
    log_error "Docker build failed for custom user configuration"
    return 1
  fi

  log_success "Custom user configuration image built successfully"
  return 0
}

# Purpose: Test default root user configuration
test_default_root_user() {
  log_info "Testing default root user configuration..."

  local user_info
  user_info=$(docker run --rm "${TEST_IMAGE_NAME}:${DEFAULT_IMAGE_TAG}" id 2>&1)

  if ! echo "${user_info}" | grep -q "uid=0(root)"; then
    log_error "Default user is not root"
    log_info "  Expected: uid=0(root)"
    log_info "  Actual:   ${user_info}"
    return 1
  fi

  if ! echo "${user_info}" | grep -q "gid=0(root)"; then
    log_error "Default group is not root"
    log_info "  Expected: gid=0(root)"
    log_info "  Actual:   ${user_info}"
    return 1
  fi

  log_success "Default root user configuration is correct"
  return 0
}

# Purpose: Test custom user creation with PUID/PGID/USER
test_custom_user_creation() {
  log_info "Testing custom user creation with PUID/PGID/USER..."

  local user_info
  user_info=$(docker run --rm "${TEST_IMAGE_NAME}:${CUSTOM_USER_IMAGE_TAG}" id 2>&1)

  if ! echo "${user_info}" | grep -q "uid=${CUSTOM_PUID}(${CUSTOM_USER})"; then
    log_error "Custom user UID is incorrect"
    log_info "  Expected: uid=${CUSTOM_PUID}(${CUSTOM_USER})"
    log_info "  Actual:   ${user_info}"
    return 1
  fi

  if ! echo "${user_info}" | grep -q "gid=${CUSTOM_PGID}(${CUSTOM_USER})"; then
    log_error "Custom user GID is incorrect"
    log_info "  Expected: gid=${CUSTOM_PGID}(${CUSTOM_USER})"
    log_info "  Actual:   ${user_info}"
    return 1
  fi

  log_success "Custom user creation is correct (uid=${CUSTOM_PUID}, gid=${CUSTOM_PGID}, user=${CUSTOM_USER})"
  return 0
}

# Purpose: Test environment variables are set correctly
test_environment_variables() {
  log_info "Testing environment variables..."

  local errors=0
  local env_output
  env_output=$(docker run --rm "${TEST_IMAGE_NAME}:${DEFAULT_IMAGE_TAG}" env 2>&1)

  # Check each expected environment variable
  while IFS='=' read -r key value; do
    # Skip empty lines
    [ -z "${key}" ] && continue

    if ! echo "${env_output}" | grep -q "^${key}=${value}$"; then
      log_error "Environment variable '${key}' is missing or incorrect"
      log_info "  Expected: ${key}=${value}"

      # Try to find what value it actually has
      local actual_value
      actual_value=$(echo "${env_output}" | grep "^${key}=" | cut -d'=' -f2- || echo "NOT_FOUND")
      log_info "  Actual:   ${key}=${actual_value}"

      errors=$((errors + 1))
      continue
    fi

    log_success "Environment variable '${key}' is correct: ${value}"
  done <<EOF
${EXPECTED_ENV_VARS}
EOF

  if [ "${errors}" -gt 0 ]; then
    return 1
  fi

  log_success "All environment variables are set correctly"
  return 0
}

# Purpose: Test DEBUG mode produces expected output
test_debug_mode() {
  log_info "Testing DEBUG mode output..."

  local debug_output
  debug_output=$(docker run --rm -e DEBUG=true "${TEST_IMAGE_NAME}:${DEFAULT_IMAGE_TAG}" 2>&1)

  # Check for expected debug messages
  if ! echo "${debug_output}" | grep -q "\[ENTRYPOINT\] Executing all scripts in /usr/local/bin/entrypoint.d"; then
    log_error "DEBUG mode does not show entrypoint execution message"
    log_info "Output:"
    echo "${debug_output}"
    return 1
  fi

  if ! echo "${debug_output}" | grep -q "Running /usr/local/bin/entrypoint.d/10-base-init.sh"; then
    log_error "DEBUG mode does not show script execution message"
    log_info "Output:"
    echo "${debug_output}"
    return 1
  fi

  if ! echo "${debug_output}" | grep -q "\[ENTRYPOINT\] Done"; then
    log_error "DEBUG mode does not show completion message"
    log_info "Output:"
    echo "${debug_output}"
    return 1
  fi

  log_success "DEBUG mode produces expected output"
  return 0
}

# Purpose: Test entrypoint script execution
test_entrypoint_execution() {
  log_info "Testing entrypoint script execution..."

  # Test that entrypoint scripts are executable
  local script_perms
  script_perms=$(docker run --rm "${TEST_IMAGE_NAME}:${DEFAULT_IMAGE_TAG}" \
    ls -la /usr/local/bin/entrypoint.d/10-base-init.sh 2>&1)

  if ! echo "${script_perms}" | grep -q "^-rwxr-xr-x"; then
    log_error "Entrypoint script is not executable"
    log_info "Permissions: ${script_perms}"
    return 1
  fi

  log_success "Entrypoint scripts are executable"
  return 0
}

# Purpose: Test container runs without errors
test_container_runs() {
  log_info "Testing container runs without errors..."

  if ! docker run --rm "${TEST_IMAGE_NAME}:${DEFAULT_IMAGE_TAG}" echo "Container test" >/dev/null 2>&1; then
    log_error "Container failed to run"
    return 1
  fi

  log_success "Container runs without errors"
  return 0
}

# Purpose: Test custom environment variable override
test_env_override() {
  log_info "Testing environment variable override at runtime..."

  local keepalive_value
  keepalive_value=$(docker run --rm -e KEEPALIVE=1 "${TEST_IMAGE_NAME}:${DEFAULT_IMAGE_TAG}" \
    sh -c 'echo $KEEPALIVE' 2>&1)

  if [ "${keepalive_value}" != "1" ]; then
    log_error "Environment variable override failed"
    log_info "  Expected: KEEPALIVE=1"
    log_info "  Actual:   KEEPALIVE=${keepalive_value}"
    return 1
  fi

  log_success "Environment variable override works correctly"
  return 0
}

# ── Main Test Execution ──────────────────────────────────────────────────────
main() {
  local errors=0

  log_info "=== Rocky Docker Container Runtime Behavior Test ==="
  echo ""

  # Set up cleanup trap
  trap cleanup EXIT INT TERM

  # Run tests
  test_docker_available || errors=$((errors + 1))
  echo ""

  test_build_default_image || errors=$((errors + 1))
  echo ""

  test_build_custom_user_image || errors=$((errors + 1))
  echo ""

  test_default_root_user || errors=$((errors + 1))
  echo ""

  test_custom_user_creation || errors=$((errors + 1))
  echo ""

  test_environment_variables || errors=$((errors + 1))
  echo ""

  test_debug_mode || errors=$((errors + 1))
  echo ""

  test_entrypoint_execution || errors=$((errors + 1))
  echo ""

  test_container_runs || errors=$((errors + 1))
  echo ""

  test_env_override || errors=$((errors + 1))
  echo ""

  # Summary
  log_info "=== Test Summary ==="
  if [ "${errors}" -eq 0 ]; then
    log_success "All tests passed! Rocky Docker container runtime behavior verification successful."
    echo ""
    log_info "Verified:"
    printf "  ✓ Default root user configuration\n"
    printf "  ✓ Custom user creation (PUID=%s, PGID=%s, USER=%s)\n" "${CUSTOM_PUID}" "${CUSTOM_PGID}" "${CUSTOM_USER}"
    printf "  ✓ Environment variables are set correctly\n"
    printf "  ✓ DEBUG mode produces expected output\n"
    printf "  ✓ Entrypoint scripts are executable\n"
    printf "  ✓ Container runs without errors\n"
    printf "  ✓ Environment variable override works\n"
    echo ""
    return 0
  else
    log_error "${errors} test(s) failed"
    echo ""
    return 1
  fi
}

# ── Entry Point ──────────────────────────────────────────────────────────────
main "$@"
