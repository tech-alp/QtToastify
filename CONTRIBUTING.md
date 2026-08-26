# Contributing to QtToastify

Contributions are welcome. Keep changes focused, testable, and compatible with
C++17 and Qt 6.10 or newer.

## Before You Start

- Search existing issues before opening a new one.
- Open an issue before large API or architecture changes.
- Keep unrelated refactoring out of the same pull request.
- Follow the project [Code of Conduct](CODE_OF_CONDUCT.md).

## Build and Test

```bash
git clone https://github.com/tech-alp/QtToastify.git
cd QtToastify
cmake -S . -B build -DBUILD_TESTS=ON -DBUILD_PLAYGROUND=ON
cmake --build build
ctest --test-dir build --output-on-failure
```

For a headless Linux or macOS session, run tests with
`QT_QPA_PLATFORM=offscreen`.

## Pull Requests

1. Create a focused branch from `main`.
2. Add or update tests for behavior changes.
3. Update documentation and `CHANGELOG.md` when user-visible behavior changes.
4. Use a clear commit message, preferably Conventional Commits.
5. Explain the problem, solution, trade-offs, and verification in the pull request.

## Reporting Bugs

Use the GitHub bug report template. Include:

- Qt, compiler, CMake, and operating system versions
- Minimal reproduction steps
- Expected and actual behavior
- Relevant logs or screenshots

Report vulnerabilities through [SECURITY.md](SECURITY.md), never through a
public issue.
