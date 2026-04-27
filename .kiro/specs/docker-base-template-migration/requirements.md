# Requirements Document

<!-- markdownlint-disable MD024 -->

## Introduction

This document defines the requirements for migrating and standardizing the Docker base template project. The base project serves as a foundational template for other Docker container projects, providing standardized Dockerfiles, entrypoint scripts, and configuration patterns across Alpine, Debian, and Rocky Linux distributions.

The migration will align the target "base" project with the proven standards established in the reference "base0" project, while updating base images to their latest versions and ensuring consistency across all distribution variants.

## Glossary

- **Base_Project**: The target Docker template project repository that requires migration and standardization
- **Base0_Project**: The reference Docker template project containing proven, working implementations
- **Distribution_Variant**: A specific Linux distribution implementation (Alpine, Debian, or Rocky)
- **Entrypoint_System**: The docker-entrypoint.sh script and associated entrypoint.d directory structure
- **Base_Image**: The FROM image specified in a Dockerfile (e.g., snowdreamtech/alpine:3.23.4)
- **Semantic_Version_Tag**: A Docker image tag following semantic versioning with three digits (e.g., 8-v8.0.0)
- **Release_Please_System**: The automated release management tooling using .release-please-config.json and .release-please-manifest.json
- **Architecture_Support**: The set of CPU architectures supported by a Docker image (e.g., amd64, arm64, arm32v7)
- **Configuration_Manifest**: The collection of JSON configuration files (package.json, .release-please-config.json, .release-please-manifest.json)
- **Atomic_Commit**: A single Git commit containing one logical, complete change
- **Conventional_Commit**: A commit message following the Conventional Commits specification

## Requirements

### Requirement 1: Project Structure Initialization

**User Story:** As a developer, I want the Base_Project to be initialized with the correct foundation structure, so that subsequent migration work can proceed systematically.

#### Acceptance Criteria

1. THE Base_Project SHALL establish its foundation on the dev branch
2. THE Base_Project SHALL contain three Distribution_Variant directories: alpine, debian, and rocky
3. WHEN analyzing the Base0_Project, THE Base_Project SHALL identify all standard files and directory structures for each Distribution_Variant
4. THE Base_Project SHALL preserve the existing .kiro/specs directory structure
5. THE Base_Project SHALL maintain compatibility with the multi-root workspace configuration (base and base0)

### Requirement 2: Base Image Standardization

**User Story:** As a container maintainer, I want all Dockerfiles to use the specified base images, so that the template provides consistent and up-to-date foundations.

#### Acceptance Criteria

1. WHEN creating the alpine Dockerfile, THE Base_Project SHALL use FROM snowdreamtech/alpine:3.23.4
2. WHEN creating the debian Dockerfile, THE Base_Project SHALL use FROM snowdreamtech/debian:13.4.0
3. WHEN creating the rocky Dockerfile, THE Base_Project SHALL use FROM snowdreamtech/rocky:10.1.0
4. THE Base_Project SHALL update the org.opencontainers.image.version LABEL to match the base image version for each Distribution_Variant
5. THE Base_Project SHALL preserve all other OCI annotation LABELs from the Base0_Project standard

### Requirement 3: Dockerfile Content Alignment

**User Story:** As a template user, I want all Dockerfiles to follow the proven Base0_Project patterns, so that I inherit battle-tested container configurations.

#### Acceptance Criteria

1. THE Base_Project SHALL replicate the USER, WORKDIR, ARG, and ENV declarations from Base0_Project for each Distribution_Variant
2. THE Base_Project SHALL implement the user creation logic with PUID and PGID support matching Base0_Project patterns
3. THE Base_Project SHALL include the package installation commands (vim) appropriate for each Distribution_Variant
4. WHEN implementing Alpine, THE Base_Project SHALL use apk package manager commands matching Base0_Project
5. WHEN implementing Debian, THE Base_Project SHALL use apt-get package manager commands matching Base0_Project
6. WHEN implementing Rocky, THE Base_Project SHALL use dnf package manager commands matching Base0_Project
7. THE Base_Project SHALL copy entrypoint.d directory and docker-entrypoint.sh with correct permissions
8. THE Base_Project SHALL set ENTRYPOINT to ["docker-entrypoint.sh"]

### Requirement 4: Entrypoint System Migration

**User Story:** As a container operator, I want the Entrypoint_System to be consistent across all Distribution_Variants, so that container initialization behavior is predictable.

#### Acceptance Criteria

1. THE Base_Project SHALL create docker-entrypoint.sh for each Distribution_Variant matching Base0_Project implementation
2. THE Base_Project SHALL create entrypoint.d/10-base-init.sh for each Distribution_Variant matching Base0_Project implementation
3. THE docker-entrypoint.sh SHALL iterate through all executable scripts in /usr/local/bin/entrypoint.d
4. WHEN DEBUG environment variable is true, THE docker-entrypoint.sh SHALL output execution progress messages
5. THE docker-entrypoint.sh SHALL use POSIX-compliant shell syntax (#!/bin/sh)
6. THE docker-entrypoint.sh SHALL set -e to exit on errors
7. THE entrypoint.d/10-base-init.sh SHALL be executable and contain minimal initialization logic

### Requirement 5: Environment Variable Configuration

**User Story:** As a container user, I want standardized environment variables across all Distribution_Variants, so that I can configure containers consistently.

#### Acceptance Criteria

1. THE Base_Project SHALL define KEEPALIVE as both ARG and ENV with default value 0
2. THE Base_Project SHALL define CAP_NET_BIND_SERVICE as both ARG and ENV with default value 0
3. THE Base_Project SHALL define LANG as both ARG and ENV with default value C.UTF-8
4. THE Base_Project SHALL define UMASK as both ARG and ENV with default value 022
5. THE Base_Project SHALL define DEBUG as both ARG and ENV with default value false
6. THE Base_Project SHALL define PGID as both ARG and ENV with default value 0
7. THE Base_Project SHALL define PUID as both ARG and ENV with default value 0
8. THE Base_Project SHALL define USER as both ARG and ENV with default value root
9. THE Base_Project SHALL define WORKDIR as both ARG and ENV with default value /root
10. WHEN implementing Debian, THE Base_Project SHALL additionally define DEBIAN_FRONTEND as both ARG and ENV with default value noninteractive

### Requirement 6: Architecture Support Specification

**User Story:** As a platform engineer, I want each Distribution_Variant to support the architectures available in its base image, so that the template works across diverse hardware platforms.

#### Acceptance Criteria

1. WHEN determining Architecture_Support for Alpine, THE Base_Project SHALL reference the snowdreamtech/alpine:3.23.4 supported architectures
2. WHEN determining Architecture_Support for Debian, THE Base_Project SHALL reference the snowdreamtech/debian:13.4.0 supported architectures
3. WHEN determining Architecture_Support for Rocky, THE Base_Project SHALL reference the snowdreamtech/rocky:10.1.0 supported architectures
4. THE Base_Project SHALL document the supported architectures in the org.opencontainers.image.description LABEL for each Distribution_Variant
5. THE Base_Project SHALL ensure build commands support multi-architecture builds using docker buildx

### Requirement 7: Docker Tag Specification

**User Story:** As a release manager, I want Docker images to use semantic versioning tags, so that version management is clear and consistent.

#### Acceptance Criteria

1. THE Base_Project SHALL use Semantic_Version_Tag format with three digits (e.g., 8-v8.0.0)
2. THE Base_Project SHALL document the tagging convention in README documentation
3. THE Base_Project SHALL configure Release_Please_System to generate tags with include-v-in-tag set to true
4. THE Base_Project SHALL ensure version tags are compatible with docker buildx multi-platform builds

### Requirement 8: Release Please Configuration

**User Story:** As a maintainer, I want automated release management configured correctly, so that version bumps and changelogs are generated automatically.

#### Acceptance Criteria

1. THE Base_Project SHALL update .release-please-config.json to include alpine, debian, and rocky as separate components
2. THE Base_Project SHALL update .release-please-manifest.json with initial versions for alpine, debian, and rocky Distribution_Variants
3. THE Base_Project SHALL set debian as the default Distribution_Variant in configuration
4. THE Base_Project SHALL configure release-type as "simple" for all Distribution_Variants
5. THE Base_Project SHALL preserve all extra-files, changelog-sections, and pull-request configuration from existing .release-please-config.json
6. THE Base_Project SHALL set initial-version appropriately for new Distribution_Variants

### Requirement 9: Package.json Configuration

**User Story:** As a developer, I want package.json to reflect the base template project identity, so that the project metadata is accurate.

#### Acceptance Criteria

1. THE Base_Project SHALL update the name field in package.json to reflect the base template project
2. THE Base_Project SHALL update the description field in package.json to describe the Docker base template purpose
3. THE Base_Project SHALL preserve all devDependencies for commitlint from existing package.json
4. THE Base_Project SHALL preserve the packageManager field specifying pnpm version
5. THE Base_Project SHALL set version field to align with Release_Please_System initial version

### Requirement 10: Atomic Commit Strategy

**User Story:** As a code reviewer, I want each logical change committed atomically, so that the project history is clear and auditable.

#### Acceptance Criteria

1. WHEN implementing a logical change, THE Base_Project SHALL create one Atomic_Commit
2. THE Base_Project SHALL use Conventional_Commit format for all commit messages
3. THE Base_Project SHALL commit changes in English following the format: type(scope): description
4. THE Base_Project SHALL ensure each Atomic_Commit leaves the repository in a consistent, working state
5. THE Base_Project SHALL NOT combine unrelated changes (e.g., Dockerfile updates and configuration file updates) in a single commit
6. THE Base_Project SHALL run lint and format validation before each commit
7. THE Base_Project SHALL NOT automatically push commits to remote repository without explicit user request

### Requirement 11: Cross-Platform Development Standards

**User Story:** As a developer on any operating system, I want the development workflow to work consistently, so that I can contribute regardless of my platform.

#### Acceptance Criteria

1. THE Base_Project SHALL ensure all scripts work on Linux, macOS, and Windows
2. THE Base_Project SHALL use POSIX-compliant shell syntax in docker-entrypoint.sh
3. THE Base_Project SHALL configure .gitattributes to normalize line endings with text=auto
4. THE Base_Project SHALL set .sh files to use LF line endings (eol=lf)
5. THE Base_Project SHALL follow the AI rules defined in .agent/rules/ directory
6. THE Base_Project SHALL pass all lint validation defined in project linting configuration
7. THE Base_Project SHALL pass all format validation defined in project formatting configuration

### Requirement 12: Documentation Standards

**User Story:** As a template user, I want clear documentation in both English and Simplified Chinese, so that I can understand how to use the template effectively.

#### Acceptance Criteria

1. THE Base_Project SHALL provide README.md in English as the canonical technical reference
2. THE Base_Project SHALL provide README_zh-CN.md in Simplified Chinese for accessibility
3. THE Base_Project SHALL document usage examples for each Distribution_Variant
4. THE Base_Project SHALL document the docker buildx build command with multi-architecture support
5. THE Base_Project SHALL document environment variable configuration options
6. THE Base_Project SHALL document the semantic versioning tag format
7. THE Base_Project SHALL include quick start instructions requiring fewer than 5 commands

### Requirement 13: Default Distribution Variant

**User Story:** As a new user, I want debian to be the default Distribution_Variant, so that I get a widely-compatible starting point.

#### Acceptance Criteria

1. THE Base_Project SHALL designate debian as the default Distribution_Variant in documentation
2. THE Base_Project SHALL list debian first in usage examples
3. THE Base_Project SHALL configure Release_Please_System to prioritize debian in release notes
4. WHEN a user follows quick start instructions without specifying a variant, THE Base_Project SHALL guide them to debian

### Requirement 14: Source Code Migration Completeness

**User Story:** As a project maintainer, I want all effective code from Base0_Project migrated to Base_Project, so that no proven patterns are lost.

#### Acceptance Criteria

1. THE Base_Project SHALL migrate all Dockerfile content from Base0_Project for alpine, debian, and rocky
2. THE Base_Project SHALL migrate all docker-entrypoint.sh content from Base0_Project for alpine, debian, and rocky
3. THE Base_Project SHALL migrate all entrypoint.d scripts from Base0_Project for alpine, debian, and rocky
4. THE Base_Project SHALL preserve comments and documentation from Base0_Project source files
5. THE Base_Project SHALL maintain the same file permissions (executable bits) as Base0_Project
6. WHEN system-specific differences exist between Distribution_Variants, THE Base_Project SHALL preserve those differences (e.g., package manager commands)

### Requirement 15: Workspace Path Resolution

**User Story:** As a developer in a multi-root workspace, I want all file operations to resolve paths correctly, so that the migration works seamlessly.

#### Acceptance Criteria

1. THE Base_Project SHALL correctly resolve paths relative to the base workspace root
2. THE Base_Project SHALL correctly resolve paths relative to the base0 workspace root when reading reference files
3. THE Base_Project SHALL handle the multi-root workspace configuration (base and base0) without path errors
4. THE Base_Project SHALL create all new files in the base workspace, not base0
5. THE Base_Project SHALL read reference files from base0 without modifying them
