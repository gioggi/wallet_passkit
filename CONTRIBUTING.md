### Contributing to this project

Thanks for your interest in contributing! To keep the project organized and stable, please follow the workflow below. These rules are simple but **mandatory**.

- **Prerequisites**
  - Ensure you can run the project and tests locally.
  - Follow the existing code style (linting, formatting, conventions).

### Mandatory workflow

1. **Open an Issue**
   - First, search for existing issues to avoid duplicates.
   - If none exist, open a new one describing: context, problem, proposed solution, and impact.
2. **Create a dedicated branch**
   - Use a descriptive name, e.g., `feature/short-name` or `fix/bug-description`.
3. **Open a Pull Request (PR)**
   - Link the PR to the Issue (use keywords like "Closes #<number>").
   - Explain what changes were made, why, and how they were tested.
   - Keep PRs small and focused.
4. **Ensure tests pass**
   - Run tests locally before submitting.
   - CI must be green. PRs with failing tests will not be merged.
5. **Review and merge**
   - The maintainer reviews the PR and, if everything looks good and tests pass, **approves and merges** it.
   - The maintainer may request changes; please address comments and update the PR.

### Commit and PR guidelines

- **Commits**
  - Use clear, descriptive messages (imperative mood, e.g., "Add email validation").
  - Keep commits logically scoped; avoid unrelated changes in the same commit.
- **PRs**
  - Provide a complete description (what, why, how to test).
  - Suggested checklist:
    - [ ] Linked Issue
    - [ ] Tests updated/added
    - [ ] Lint/format run
    - [ ] Breaking changes documented

### Running tests

- Run all tests locally before opening/updating a PR.
- If the project provides scripts (e.g., `make test`, `npm test`, `pytest`, etc.), please use them.

### Questions

If you have questions, open a **Discussion** or ask in the Issue before implementing.