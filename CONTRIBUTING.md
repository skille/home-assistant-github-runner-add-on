# Contributing to GitHub Actions Runner Add-on

Thank you for your interest in contributing to this project! We welcome contributions from the community.

## Table of Contents

- [Getting Started](#getting-started)
- [Version Bump Requirement](#version-bump-requirement)
- [Development Workflow](#development-workflow)
- [Pull Request Guidelines](#pull-request-guidelines)
- [Code Style](#code-style)
- [Testing](#testing)
- [Documentation](#documentation)

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes thoroughly
6. Submit a pull request

## Version Bump Requirement

**🚨 CRITICAL: Every commit to the main branch MUST include a version bump in `config.yaml`**

### Why This Matters

The version number in `config.yaml` controls how Home Assistant users receive updates. If the version is not bumped:
- Users won't receive the update
- The add-on update process will fail
- Deployment and release cycles will be disrupted

### Enforcement

1. **Automated Check**: A GitHub Actions workflow automatically verifies that PRs to `main` include a version bump
2. **PR Review**: All PRs must pass the version bump check before merging
3. **Version Format**: Follow semantic versioning (MAJOR.MINOR.PATCH)

### Version Bump Guidelines

The current version is defined in `config.yaml`:

```yaml
name: GitHub Actions Runner
version: "1.0.5"
```

Follow [Semantic Versioning](https://semver.org/):

- **PATCH version** (e.g., 1.0.5 → 1.0.6): Bug fixes, documentation updates, small changes
- **MINOR version** (e.g., 1.0.5 → 1.1.0): New features, backward-compatible changes
- **MAJOR version** (e.g., 1.0.5 → 2.0.0): Breaking changes, incompatible API changes

### How to Bump the Version

1. **Check the current version on main**:
   ```bash
   git fetch origin main
   git show origin/main:config.yaml | grep version
   ```

2. **Update `config.yaml`** with the new version:
   ```yaml
   version: "1.0.6"  # Increment appropriately
   ```

3. **Update `CHANGELOG.md`** with your changes:
   ```markdown
   ## [1.0.6] - YYYY-MM-DD
   
   ### Added
   - New feature description
   
   ### Fixed
   - Bug fix description
   
   ### Changed
   - Change description
   ```

4. **Commit your changes**:
   ```bash
   git add config.yaml CHANGELOG.md
   git commit -m "Bump version to 1.0.6: <brief description>"
   ```

### Examples

#### Bug Fix (PATCH)
```yaml
# Before
version: "1.0.5"

# After
version: "1.0.6"
```

#### New Feature (MINOR)
```yaml
# Before
version: "1.0.5"

# After
version: "1.1.0"
```

#### Breaking Change (MAJOR)
```yaml
# Before
version: "1.0.5"

# After
version: "2.0.0"
```

## Development Workflow

### For Bug Fixes

1. Create a branch: `git checkout -b fix/bug-description`
2. Make your fix
3. **Bump the PATCH version** in `config.yaml`
4. Update `CHANGELOG.md` under a new version section
5. Test thoroughly
6. Submit PR with descriptive title and description

### For New Features

1. Create a branch: `git checkout -b feature/feature-name`
2. Implement your feature
3. **Bump the MINOR version** in `config.yaml`
4. Update `CHANGELOG.md` under a new version section
5. Update documentation (README.md, DOCS.md)
6. Test thoroughly
7. Submit PR with descriptive title and description

### For Breaking Changes

1. Create a branch: `git checkout -b breaking/change-description`
2. Implement your changes
3. **Bump the MAJOR version** in `config.yaml`
4. Update `CHANGELOG.md` under a new version section
5. Update all affected documentation
6. Include migration guide if applicable
7. Test thoroughly across all architectures
8. Submit PR with clear explanation of breaking changes

## Pull Request Guidelines

### Before Submitting

- [ ] Version bumped in `config.yaml` (greater than current main branch version)
- [ ] `CHANGELOG.md` updated with your changes
- [ ] Documentation updated (if applicable)
- [ ] Code follows existing style and conventions
- [ ] Changes tested locally
- [ ] Commit messages are clear and descriptive

### PR Title Format

Use clear, descriptive titles:
- ✅ `Bump to v1.0.6: Fix runner token validation`
- ✅ `Bump to v1.1.0: Add support for custom runner labels`
- ❌ `Fix bug`
- ❌ `Update code`

### PR Description

Include:
1. **Summary**: What does this PR do?
2. **Motivation**: Why is this change needed?
3. **Version**: New version number (e.g., `1.0.6`)
4. **Changes**: List of changes made
5. **Testing**: How was this tested?
6. **Screenshots**: If UI/output changed

### Example PR Description

```markdown
## Summary
Fixes runner token validation to properly handle expired tokens.

## Motivation
Users were experiencing unclear error messages when tokens expired. This PR adds better validation and user-friendly error messages.

## Version
Bumped to v1.0.6 (PATCH - bug fix)

## Changes
- Added token expiration validation
- Improved error messages for token-related issues
- Updated documentation with troubleshooting steps

## Testing
- Tested with expired token - shows clear error message
- Tested with valid token - runner registers successfully
- Tested on amd64 and aarch64 architectures
```

## Code Style

### Bash Scripts

- Use `#!/usr/bin/env bashio` for Home Assistant scripts
- Enable strict error checking: `set -e`
- Quote variables: `"${VARIABLE}"`
- Use bashio logging functions:
  ```bash
  bashio::log.info "Info message"
  bashio::log.warning "Warning message"
  bashio::log.error "Error message"
  ```
- Add comments for complex logic
- Use meaningful variable names

### Dockerfile

- Use `ARG BUILD_FROM` for base images
- Combine `RUN` commands to reduce layers
- Clean up in the same layer
- Specify package versions when possible
- Use multi-stage builds if appropriate

### YAML Files

- Use 2-space indentation
- Follow existing file structure
- Quote string values consistently
- Include comments for complex configurations

## Testing

### Local Testing

1. **Build the Docker image**:
   ```bash
   docker build -t test-runner .
   ```

2. **Test in Home Assistant**:
   - Install locally modified add-on
   - Configure with test repository
   - Verify runner registers successfully
   - Test workflow execution

3. **Check logs**:
   - Enable `debug_logging: true`
   - Review output for errors
   - Verify all functionality works

### Multi-Architecture Testing

If changes affect architecture-specific code:
- Test on multiple architectures (amd64, aarch64)
- Use Home Assistant build system for validation
- Check compatibility with all supported architectures

## Documentation

### Files to Update

When making changes, update relevant documentation:

- **README.md**: User-facing quick start and overview
- **DOCS.md**: Detailed configuration and usage guide
- **CHANGELOG.md**: Version history (always required)
- **COPILOT_GUIDELINES.md**: Developer guidelines (if process changes)

### Documentation Style

- Use clear, concise language
- Include code examples
- Provide both repository and organization examples
- Keep README concise, details in DOCS
- Use markdown formatting consistently

## Getting Help

If you need help:

1. Check existing documentation (README.md, DOCS.md, COPILOT_GUIDELINES.md)
2. Search existing issues on GitHub
3. Open a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (HA version, architecture)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to make this add-on better! 🎉
