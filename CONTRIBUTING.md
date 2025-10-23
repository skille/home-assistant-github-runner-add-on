# Contributing to GitHub Actions Runner Add-on

We welcome contributions! Please follow these guidelines.

## Quick Start

1. Fork and clone the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. **Bump version in `config.yaml`** (required)
5. Update `CHANGELOG.md`
6. Test thoroughly
7. Submit a pull request

## 🚨 Version Bump (Required)

**Every PR to main must bump version in `config.yaml`**

### Semantic Versioning

- **PATCH** (1.0.X): Bug fixes, documentation updates
- **MINOR** (1.X.0): New features, backward-compatible changes
- **MAJOR** (X.0.0): Breaking changes

### Steps

1. Check current version:
   ```bash
   git show origin/main:config.yaml | grep version
   ```

2. Update `config.yaml` with new version

3. Update `CHANGELOG.md`:
   ```markdown
   ## [1.0.6] - 2025-10-23
   - Fixed token validation
   - Added error messages
   ```

## Documentation Style

Follow the simplified pattern in this repository:

- Keep descriptions concise and focused
- Use bullet points, not verbose paragraphs
- Avoid AI-generated verbose explanations
- No redundant information across files

**Example (Good):**
```markdown
## [1.4.0] - 2025-10-23
- Added configurable runner labels via `runner_labels` option
```

**Example (Bad):**
```markdown
## [1.4.0] - 2025-10-23

### Added
- Configurable runner labels via `runner_labels` configuration option
- Support for comma-separated multiple labels
- Ability to customize runner labels for better workflow targeting
```

## PR Checklist

Before submitting:

- [ ] Version bumped in `config.yaml`
- [ ] `CHANGELOG.md` updated with simple bullet points
- [ ] Documentation follows concise pattern
- [ ] Changes tested locally
- [ ] No hardcoded secrets

## Code Style

### Bash
- Use `#!/usr/bin/env bashio`
- Quote variables: `"${VARIABLE}"`
- Use bashio logging: `bashio::log.info`, `bashio::log.error`

### Docker
- Combine RUN commands to reduce layers
- Clean up in the same layer

### Documentation
- Keep concise (follow README.md pattern)
- Use bullet points
- No verbose AI-generated text

## Testing

1. Build Docker image: `docker build -t test-runner .`
2. Test in Home Assistant
3. Enable `debug_logging: true` for troubleshooting

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
