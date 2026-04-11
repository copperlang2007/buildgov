# Skill: Dependency Update

## Context
This skill automates the process of keeping project dependencies up to date, including vulnerability patching and compatibility validation.

## Triggers
- A scheduled weekly job runs on Mondays at 08:00 UTC.
- A new CVE is published affecting a dependency in use.
- A maintainer explicitly requests a dependency refresh.

## Execution Steps
1. **Audit current dependencies**: Run the package manager's audit command (e.g., `npm audit`, `pip-audit`, `govulncheck`) to identify outdated or vulnerable packages.
2. **Categorize updates**: Separate updates into patch, minor, and major version bumps.
3. **Apply patch and minor updates**: Automatically update patch and minor versions that pass audit checks.
4. **Test compatibility**: Run the full test suite to confirm no regressions are introduced.
5. **Open pull request**: Create a pull request titled `chore: update dependencies [YYYY-MM-DD]` with a changelog of all updated packages.
6. **Flag major updates**: For major version bumps, open a separate issue with migration notes and assign it to the relevant team.
7. **Notify on critical CVE**: If a critical or high-severity CVE is patched, post an alert to the `#security` channel.

## Outputs
- Pull request with applied updates.
- Issue(s) for major updates requiring manual migration.
- Security channel notification for critical CVE patches.

## Escalation
If the test suite fails after applying updates, revert all changes and open an issue with the failure log attached, assigning it to the engineering lead.
