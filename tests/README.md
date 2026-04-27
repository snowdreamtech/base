# Test Suite

This directory contains tests for the Docker base template project, including build verification tests and property-based tests for bugfixes.

## Test Files

### Docker Build Verification Tests

#### Alpine Build Verification Test

**File**: `tests/build-verification-alpine.sh`

**Purpose**: Verify Alpine Docker image builds correctly with expected base image and OCI annotations

**Requirements**: 2.1, 2.4, 2.5

**What it tests**:

- Docker is available and running
- alpine/Dockerfile exists
- Base image is snowdreamtech/alpine:3.23.4
- Docker image builds without errors
- OCI labels are present and correct:
  - org.opencontainers.image.authors=Snowdream Tech
  - org.opencontainers.image.title=Base Image Based On Alpine
  - org.opencontainers.image.version=3.23.4
  - org.opencontainers.image.licenses=MIT
  - org.opencontainers.image.vendor=Snowdream Tech
- Version label matches expected version (3.23.4)
- Entrypoint is configured correctly (docker-entrypoint.sh)

**Run**:

```bash
sh tests/build-verification-alpine.sh
```

**Expected Outcome**: All tests pass when Docker is running and Alpine Dockerfile is correctly configured

**Cleanup**: Automatically removes test image on completion

---

#### Alpine Runtime Behavior Test

**File**: `tests/runtime-behavior-alpine.sh`

**Purpose**: Verify Alpine Docker container runtime behavior including user creation, environment variables, and DEBUG mode

**Requirements**: 3.2, 4.4, 5.1-5.9

**What it tests**:

- Docker is available and running
- Default root user configuration (uid=0, gid=0)
- Custom user creation with PUID/PGID/USER build arguments
  - Builds image with PUID=1000, PGID=1000, USER=testuser
  - Verifies user is created with correct UID and GID
- Environment variables are set correctly:
  - KEEPALIVE=0
  - CAP_NET_BIND_SERVICE=0
  - LANG=C.UTF-8
  - UMASK=022
  - DEBUG=false
  - PGID=0
  - PUID=0
  - USER=root
  - WORKDIR=/root
- DEBUG mode produces expected output:
  - Shows entrypoint execution message
  - Shows script execution messages
  - Shows completion message
- Entrypoint scripts are executable
- Container runs without errors
- Environment variable override works at runtime

**Run**:

```bash
sh tests/runtime-behavior-alpine.sh
```

**Expected Outcome**: All tests pass when Docker is running and Alpine container is correctly configured

**Cleanup**: Automatically removes test images and containers on completion

---

### Scripts Version Centralization Tests

### 1. Bug Condition Exploration Test

**File**: `tests/bug-condition-exploration.sh`

**Purpose**: Detect hardcoded provider values across the codebase (Task 1)

**Expected Outcome on UNFIXED code**: FAIL with 36 hardcoded instances found

**Expected Outcome on FIXED code**: PASS with 0 hardcoded instances found

**What it tests**:

- Searches for `local _PROVIDER="github:*"` patterns
- Searches for `local _PROVIDER="npm:*"` patterns
- Searches for `local _PROVIDER="pipx:*"` patterns
- Searches for `local _PROVIDER="gem:*"` patterns
- Counts total instances across all `scripts/lib/langs/*.sh` files

**Run**:

```bash
./tests/bug-condition-exploration.sh
```

### 2. Preservation Property Test

**File**: `tests/preservation-property.sh`

**Purpose**: Verify existing functionality is preserved (Task 2)

**Expected Outcome on UNFIXED code**: PASS (confirms baseline behavior)

**Expected Outcome on FIXED code**: PASS (confirms no regressions)

**What it tests**:

- Centralized provider variables exist in versions.sh
- Provider variables follow expected format (github:, npm:, pipx:, gem:)
- Scripts already using centralized pattern (security.sh, java.sh, kotlin.sh) work correctly
- Fallback pattern `${VAR:-}` works correctly
- Version variables are defined alongside provider variables
- Scripts using centralized pattern have NO hardcoded providers
- Centralized provider variables are non-empty
- Multiple scripts use the centralized pattern consistently
- Provider variables exist for expected tools
- Provider variables follow VER\_\*\_PROVIDER naming convention

**Run**:

```bash
./tests/preservation-property.sh
```

## Test Workflow

### Phase 1: Before Fix (Observation)

1. **Run Bug Condition Test** (Task 1):

   ```bash
   ./tests/bug-condition-exploration.sh
   ```

   - Expected: FAIL with 36 hardcoded instances
   - This confirms the bug exists

2. **Run Preservation Test** (Task 2):

   ```bash
   ./tests/preservation-property.sh
   ```

   - Expected: PASS
   - This confirms baseline behavior to preserve

### Phase 2: After Fix (Validation)

1. **Implement Fix** (Task 3):
   - Add missing variables to versions.sh
   - Replace hardcoded providers with centralized variables
   - Update all 36 instances across 20+ scripts

2. **Re-run Bug Condition Test** (Task 3.21):

   ```bash
   ./tests/bug-condition-exploration.sh
   ```

   - Expected: PASS with 0 hardcoded instances
   - This confirms the bug is fixed

3. **Re-run Preservation Test** (Task 3.22):

   ```bash
   ./tests/preservation-property.sh
   ```

   - Expected: PASS
   - This confirms no regressions

## Test Design Philosophy

These tests follow the **observation-first methodology** for bugfix testing:

1. **Exploratory Phase**: Write tests that detect the bug condition on unfixed code
2. **Preservation Phase**: Write tests that validate baseline behavior on unfixed code
3. **Fix Phase**: Implement the fix
4. **Validation Phase**: Re-run the same tests to confirm the fix and no regressions

This approach ensures:

- The bug is properly understood before fixing
- Baseline behavior is documented and preserved
- The fix is validated by the same tests that detected the bug
- No regressions are introduced

## Why Shell Scripts Instead of Bats?

The original preservation test was written using the bats testing framework but encountered hanging issues when sourcing `scripts/lib/versions.sh`. After investigation, we replaced it with a standalone shell script because:

1. **No External Dependencies**: Pure POSIX shell scripts work everywhere
2. **No Hanging Issues**: Direct execution without complex framework setup
3. **Simpler Logic**: Pattern matching with grep instead of function stubbing
4. **Clear Output**: Colored output with clear pass/fail indicators
5. **Easy to Run**: Just `./test-name.sh` without special setup

See `tests/PRESERVATION_TEST_SOLUTION.md` for details on the solution.

## Test Results

### Current Status (Unfixed Code)

**Bug Condition Test**: ✓ PASSED (36 hardcoded instances found - bug confirmed)

**Preservation Test**: ✓ PASSED (29 assertions passed - baseline validated)

This confirms:

- The bug exists as documented (36 hardcoded providers)
- Scripts using centralized variables work correctly
- Baseline behavior is properly documented and ready to preserve
