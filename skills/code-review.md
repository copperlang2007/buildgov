# Skill: Code Review

## Context
This skill enables the autonomous agent to perform structured code reviews on pull requests, enforcing style guides, security checks, and architectural compliance.

## Triggers
- A new pull request is opened or updated.
- A developer requests a review from the agent.
- A commit is pushed to a feature branch.

## Execution Steps
1. **Fetch PR diff**: Retrieve the full diff of the pull request from the version control system.
2. **Run linters**: Execute configured linters (e.g., ESLint, Pylint, golangci-lint) against changed files.
3. **Check style compliance**: Validate that code conforms to the project's style guide.
4. **Detect security anti-patterns**: Scan for known insecure patterns (e.g., hardcoded credentials, SQL injection vectors).
5. **Architectural review**: Ensure new code follows the project's architectural blueprints and doesn't introduce circular dependencies.
6. **Generate review comments**: Post inline comments on the pull request highlighting issues found.
7. **Summarize findings**: Post a summary comment with counts of errors, warnings, and informational items.
8. **Approve or request changes**: Approve the PR if no blocking issues exist; otherwise, request changes.

## Outputs
- Inline PR review comments.
- Summary comment with severity breakdown.
- PR approval or change-request status.

## Escalation
If a critical security finding is detected, immediately notify the `#security` channel and tag the security team for manual review.
