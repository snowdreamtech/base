# Implementation Plan: Docker Base Template Migration

## Overview

This implementation plan breaks down the migration of the Docker base template project into discrete, actionable coding tasks. The migration will align the target "base" project with proven patterns from the reference "base0" project while updating to the latest base images (Alpine 3.23.4, Debian 13.4.0, Rocky 10.1.0) and ensuring consistency across all distribution variants.

The implementation follows an incremental approach: foundation setup → Alpine migration → Debian migration → Rocky migration → documentation → validation. Each phase builds on the previous one, with checkpoints to ensure quality and correctness.

## Tasks

- [x] 1. Set up project foundation and configuration
  - [x] 1.1 Configure .gitattributes for line ending normalization
    - Create or update .gitattributes file
    - Set `* text=auto` for automatic line ending normalization
    - Set `*.sh text eol=lf` to enforce LF line endings for shell scripts
    - Set `*.md text eol=lf` for markdown files
    - _Requirements: 11.3, 11.4_

  - [x] 1.2 Update .release-please-config.json for three distribution variants
    - Add "alpine", "debian", and "rocky" as separate components in packages section
    - Set release-type as "simple" for all variants
    - Set include-v-in-tag to true for semantic version tags
    - Set debian as default variant (listed first or marked as primary)
    - Preserve existing extra-files, changelog-sections, and pull-request configuration
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 13.3_

  - [x] 1.3 Create .release-please-manifest.json with initial versions
    - Set alpine version to "3.23.4"
    - Set debian version to "13.4.0"
    - Set rocky version to "10.1.0"
    - _Requirements: 8.2, 8.6_

  - [x] 1.4 Update package.json with project metadata
    - Update name field to reflect base template project
    - Update description field to describe Docker base template purpose
    - Set version field to align with Release Please initial version
    - Preserve all devDependencies for commitlint
    - Preserve packageManager field specifying pnpm version
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [x] 2. Checkpoint - Verify foundation configuration
  - Validate all JSON files are syntactically correct
  - Ensure .gitattributes is properly configured
  - Ask the user if questions arise

- [x] 3. Implement Alpine distribution variant
  - [x] 3.1 Create alpine/Dockerfile with base image and OCI annotations
    - Set FROM to snowdreamtech/alpine:3.23.4
    - Add all OCI annotation LABELs from Base0_Project
    - Update org.opencontainers.image.version to "3.23.4"
    - Set USER root and WORKDIR /root
    - _Requirements: 2.1, 2.4, 2.5, 3.1_

  - [x] 3.2 Add ARG and ENV declarations to alpine/Dockerfile
    - Define KEEPALIVE as ARG and ENV with default 0
    - Define CAP_NET_BIND_SERVICE as ARG and ENV with default 0
    - Define LANG as ARG and ENV with default C.UTF-8
    - Define UMASK as ARG and ENV with default 022
    - Define DEBUG as ARG and ENV with default false
    - Define PGID as ARG and ENV with default 0
    - Define PUID as ARG and ENV with default 0
    - Define USER as ARG and ENV with default root
    - Define WORKDIR as ARG and ENV with default /root
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9_

  - [x] 3.3 Implement user creation logic in alpine/Dockerfile
    - Use addgroup and adduser commands (Alpine-specific)
    - Implement conditional logic: only create user if USER≠root, PUID≠0, PGID≠0
    - Match Base0_Project user creation pattern exactly
    - _Requirements: 3.2, 3.4_

  - [x] 3.4 Add package installation to alpine/Dockerfile
    - Use apk package manager commands
    - Install vim package
    - Match Base0_Project package installation pattern
    - _Requirements: 3.3, 3.4_

  - [x] 3.5 Create alpine/entrypoint.d directory and 10-base-init.sh script
    - Create entrypoint.d directory structure
    - Copy 10-base-init.sh content from base0/alpine/entrypoint.d/10-base-init.sh
    - Ensure script uses POSIX-compliant shell syntax (#!/bin/sh)
    - Preserve all comments and documentation from Base0_Project
    - _Requirements: 4.2, 4.5, 4.7, 14.3, 14.4_

  - [x] 3.6 Create alpine/docker-entrypoint.sh script
    - Copy docker-entrypoint.sh content from base0/alpine/docker-entrypoint.sh
    - Ensure POSIX-compliant shell syntax (#!/bin/sh)
    - Ensure set -e for error handling
    - Implement iteration through /usr/local/bin/entrypoint.d scripts
    - Implement DEBUG mode output
    - Preserve all comments and documentation from Base0_Project
    - _Requirements: 4.1, 4.3, 4.4, 4.5, 4.6, 14.2, 14.4_

  - [x] 3.7 Add entrypoint system setup to alpine/Dockerfile
    - COPY entrypoint.d directory to /usr/local/bin/entrypoint.d
    - COPY docker-entrypoint.sh to /usr/local/bin/docker-entrypoint.sh
    - RUN chmod +x on docker-entrypoint.sh and all entrypoint.d scripts
    - Set ENTRYPOINT to ["docker-entrypoint.sh"]
    - _Requirements: 3.7, 3.8, 14.5_

  - [x] 3.8 Write build verification test for Alpine
    - Create test script to build alpine/Dockerfile
    - Verify build completes without errors
    - Verify base image is snowdreamtech/alpine:3.23.4
    - Verify OCI labels are present and correct
    - _Requirements: 2.1, 2.4, 2.5_

  - [x] 3.9 Write runtime behavior test for Alpine
    - Test default root user configuration
    - Test custom user creation with PUID/PGID/USER
    - Test environment variables are set correctly
    - Test DEBUG mode produces expected output
    - _Requirements: 3.2, 4.4, 5.1-5.9_

- [x] 4. Checkpoint - Verify Alpine implementation
  - Build Alpine image and verify it runs successfully
  - Test with default configuration (root user)
  - Test with custom user (PUID=1000, PGID=1000, USER=testuser)
  - Ensure all tests pass, ask the user if questions arise

- [x] 5. Implement Debian distribution variant
  - [x] 5.1 Create debian/Dockerfile with base image and OCI annotations
    - Set FROM to snowdreamtech/debian:13.4.0
    - Add all OCI annotation LABELs from Base0_Project
    - Update org.opencontainers.image.version to "13.4.0"
    - Set USER root and WORKDIR /root
    - _Requirements: 2.2, 2.4, 2.5, 3.1_

  - [x] 5.2 Add ARG and ENV declarations to debian/Dockerfile
    - Define all standard variables (KEEPALIVE, CAP_NET_BIND_SERVICE, LANG, UMASK, DEBUG, PGID, PUID, USER, WORKDIR)
    - Additionally define DEBIAN_FRONTEND as ARG and ENV with default noninteractive
    - _Requirements: 5.1-5.10_

  - [x] 5.3 Implement user creation logic in debian/Dockerfile
    - Use addgroup and adduser commands (Debian-specific)
    - Implement conditional logic: only create user if USER≠root, PUID≠0, PGID≠0
    - Match Base0_Project user creation pattern exactly
    - _Requirements: 3.2, 3.5_

  - [x] 5.4 Add package installation to debian/Dockerfile
    - Use apt-get package manager commands
    - Install vim package
    - Set DEBIAN_FRONTEND=noninteractive for non-interactive installation
    - Match Base0_Project package installation pattern
    - _Requirements: 3.3, 3.5_

  - [x] 5.5 Create debian/entrypoint.d directory and 10-base-init.sh script
    - Create entrypoint.d directory structure
    - Copy 10-base-init.sh content from base0/debian/entrypoint.d/10-base-init.sh
    - Ensure script uses POSIX-compliant shell syntax (#!/bin/sh)
    - Preserve all comments and documentation from Base0_Project
    - _Requirements: 4.2, 4.5, 4.7, 14.3, 14.4_

  - [x] 5.6 Create debian/docker-entrypoint.sh script
    - Copy docker-entrypoint.sh content from base0/debian/docker-entrypoint.sh
    - Ensure POSIX-compliant shell syntax (#!/bin/sh)
    - Ensure set -e for error handling
    - Implement iteration through /usr/local/bin/entrypoint.d scripts
    - Implement DEBUG mode output
    - Preserve all comments and documentation from Base0_Project
    - _Requirements: 4.1, 4.3, 4.4, 4.5, 4.6, 14.2, 14.4_

  - [x] 5.7 Add entrypoint system setup to debian/Dockerfile
    - COPY entrypoint.d directory to /usr/local/bin/entrypoint.d
    - COPY docker-entrypoint.sh to /usr/local/bin/docker-entrypoint.sh
    - RUN chmod +x on docker-entrypoint.sh and all entrypoint.d scripts
    - Set ENTRYPOINT to ["docker-entrypoint.sh"]
    - _Requirements: 3.7, 3.8, 14.5_

  - [x] 5.8 Write build verification test for Debian
    - Create test script to build debian/Dockerfile
    - Verify build completes without errors
    - Verify base image is snowdreamtech/debian:13.4.0
    - Verify OCI labels are present and correct
    - _Requirements: 2.2, 2.4, 2.5_

  - [x] 5.9 Write runtime behavior test for Debian
    - Test default root user configuration
    - Test custom user creation with PUID/PGID/USER
    - Test environment variables are set correctly (including DEBIAN_FRONTEND)
    - Test DEBUG mode produces expected output
    - _Requirements: 3.2, 4.4, 5.1-5.10_

- [x] 6. Checkpoint - Verify Debian implementation
  - Build Debian image and verify it runs successfully
  - Test with default configuration (root user)
  - Test with custom user (PUID=1000, PGID=1000, USER=testuser)
  - Ensure all tests pass, ask the user if questions arise

- [x] 7. Implement Rocky distribution variant
  - [x] 7.1 Create rocky/Dockerfile with base image and OCI annotations
    - Set FROM to snowdreamtech/rocky:10.1.0
    - Add all OCI annotation LABELs from Base0_Project
    - Update org.opencontainers.image.version to "10.1.0"
    - Set USER root and WORKDIR /root
    - _Requirements: 2.3, 2.4, 2.5, 3.1_

  - [x] 7.2 Add ARG and ENV declarations to rocky/Dockerfile
    - Define all standard variables (KEEPALIVE, CAP_NET_BIND_SERVICE, LANG, UMASK, DEBUG, PGID, PUID, USER, WORKDIR)
    - _Requirements: 5.1-5.9_

  - [x] 7.3 Implement user creation logic in rocky/Dockerfile
    - Use groupadd and useradd commands (Rocky-specific)
    - Implement conditional logic: only create user if USER≠root, PUID≠0, PGID≠0
    - Match Base0_Project user creation pattern exactly
    - _Requirements: 3.2, 3.6_

  - [x] 7.4 Add package installation to rocky/Dockerfile
    - Use dnf package manager commands
    - Install vim package
    - Match Base0_Project package installation pattern
    - _Requirements: 3.3, 3.6_

  - [x] 7.5 Create rocky/entrypoint.d directory and 10-base-init.sh script
    - Create entrypoint.d directory structure
    - Copy 10-base-init.sh content from base0/rocky/entrypoint.d/10-base-init.sh
    - Ensure script uses POSIX-compliant shell syntax (#!/bin/sh)
    - Preserve all comments and documentation from Base0_Project
    - _Requirements: 4.2, 4.5, 4.7, 14.3, 14.4_

  - [x] 7.6 Create rocky/docker-entrypoint.sh script
    - Copy docker-entrypoint.sh content from base0/rocky/docker-entrypoint.sh
    - Ensure POSIX-compliant shell syntax (#!/bin/sh)
    - Ensure set -e for error handling
    - Implement iteration through /usr/local/bin/entrypoint.d scripts
    - Implement DEBUG mode output
    - Preserve all comments and documentation from Base0_Project
    - _Requirements: 4.1, 4.3, 4.4, 4.5, 4.6, 14.2, 14.4_

  - [x] 7.7 Add entrypoint system setup to rocky/Dockerfile
    - COPY entrypoint.d directory to /usr/local/bin/entrypoint.d
    - COPY docker-entrypoint.sh to /usr/local/bin/docker-entrypoint.sh
    - RUN chmod +x on docker-entrypoint.sh and all entrypoint.d scripts
    - Set ENTRYPOINT to ["docker-entrypoint.sh"]
    - _Requirements: 3.7, 3.8, 14.5_

  - [x] 7.8 Write build verification test for Rocky
    - Create test script to build rocky/Dockerfile
    - Verify build completes without errors
    - Verify base image is snowdreamtech/rocky:10.1.0
    - Verify OCI labels are present and correct
    - _Requirements: 2.3, 2.4, 2.5_

  - [x] 7.9 Write runtime behavior test for Rocky
    - Test default root user configuration
    - Test custom user creation with PUID/PGID/USER
    - Test environment variables are set correctly
    - Test DEBUG mode produces expected output
    - _Requirements: 3.2, 4.4, 5.1-5.9_

- [x] 8. Checkpoint - Verify Rocky implementation
  - Build Rocky image and verify it runs successfully
  - Test with default configuration (root user)
  - Test with custom user (PUID=1000, PGID=1000, USER=testuser)
  - Ensure all tests pass, ask the user if questions arise

- [x] 9. Create comprehensive documentation
  - [x] 9.1 Create README.md in English
    - Write project overview describing the Docker base template purpose
    - Add quick start guide (< 5 commands)
    - Document build instructions with docker buildx for multi-architecture
    - Document environment variable configuration options
    - Document semantic versioning tag format (e.g., 8-v8.0.0)
    - Provide usage examples for each distribution variant (alpine, debian, rocky)
    - List debian first as the default variant
    - Include architecture support information
    - _Requirements: 12.1, 12.3, 12.4, 12.5, 12.6, 12.7, 13.1, 13.2_

  - [x] 9.2 Create README_zh-CN.md in Simplified Chinese
    - Translate all content from README.md to Simplified Chinese
    - Ensure consistency with English version
    - Maintain same structure and examples
    - _Requirements: 12.2, 13.4_

  - [x] 9.3 Verify documentation accuracy
    - Test all commands in quick start guide
    - Verify all examples work correctly
    - Ensure both language versions are consistent
    - _Requirements: 12.1, 12.2, 12.7_

- [x] 10. Validate and test complete implementation
  - [x] 10.1 Run build verification tests for all variants
    - Execute build tests for Alpine, Debian, and Rocky
    - Verify all images build successfully
    - Verify base image versions are correct
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 10.2 Run runtime behavior tests for all variants
    - Test default configuration (root user) for all variants
    - Test custom user creation for all variants
    - Test environment variables for all variants
    - Test DEBUG mode for all variants
    - _Requirements: 3.2, 4.4, 5.1-5.10_

  - [x] 10.3 Test multi-architecture builds
    - Test docker buildx build for Alpine with multiple architectures
    - Test docker buildx build for Debian with multiple architectures
    - Test docker buildx build for Rocky with multiple architectures
    - Verify architecture support matches base image capabilities
    - _Requirements: 6.1, 6.2, 6.3, 6.5_

  - [x] 10.4 Validate configuration files
    - Validate .release-please-config.json syntax and structure
    - Validate .release-please-manifest.json syntax and structure
    - Validate package.json syntax and structure
    - Test commitlint configuration with sample commits
    - _Requirements: 8.1-8.6, 9.1-9.5_

  - [x] 10.5 Validate shell scripts with ShellCheck
    - Run shellcheck on alpine/docker-entrypoint.sh
    - Run shellcheck on debian/docker-entrypoint.sh
    - Run shellcheck on rocky/docker-entrypoint.sh
    - Run shellcheck on all entrypoint.d scripts
    - Ensure POSIX compliance (--shell=sh)
    - _Requirements: 4.5, 11.2_

  - [x] 10.6 Verify cross-platform compatibility
    - Verify .gitattributes enforces LF line endings for .sh files
    - Test that scripts work on Linux, macOS, and Windows (via WSL or Git Bash)
    - Verify no CRLF line endings in shell scripts
    - _Requirements: 11.1, 11.2, 11.3, 11.4_

- [x] 11. Final checkpoint - Complete migration validation
  - Review all 15 requirements for completeness
  - Verify all 73 acceptance criteria are met
  - Ensure all three distribution variants build and run successfully
  - Verify documentation is complete in both English and Simplified Chinese
  - Confirm Release Please configuration is correct
  - Ensure all commits follow atomic commit strategy and conventional commit format
  - Ask the user if questions arise or if they want to proceed with any additional changes

## Notes

- Tasks marked with `*` are optional testing and validation tasks that can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation and provide opportunities for user feedback
- All file operations target the `base/` workspace root
- All reference file reads target the `base0/` workspace root (read-only)
- The implementation follows atomic commit strategy: each logical change should be committed separately with conventional commit messages
- Testing focuses on build verification, runtime behavior, and configuration validation (no property-based testing for IaC)
- Multi-architecture support depends on the capabilities of the base images (snowdreamtech/alpine, snowdreamtech/debian, snowdreamtech/rocky)
- Debian is designated as the default distribution variant throughout documentation and configuration
