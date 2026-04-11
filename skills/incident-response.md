# Skill: Incident Response

## Context
This skill provides a structured playbook for the autonomous agent to assist in detecting, triaging, and coordinating responses to production incidents.

## Triggers
- A Prometheus alert fires with severity `critical` or `high`.
- An error rate exceeds the defined SLO threshold.
- A manual incident declaration is made by an on-call engineer.

## Execution Steps
1. **Acknowledge alert**: Mark the alert as acknowledged in the alerting system to prevent duplicate notifications.
2. **Gather context**: Collect recent logs, metrics, and traces from the affected service(s) within the incident window.
3. **Classify incident**: Determine severity (P1–P4) based on user impact, service scope, and SLO breach.
4. **Notify on-call**: Page the on-call engineer and post a structured incident thread in `#incidents`.
5. **Identify root cause candidates**: Correlate recent deployments, configuration changes, and anomalous metrics to surface probable causes.
6. **Apply automated mitigations**: If a known remediation exists in the runbook, execute it (e.g., restart a crashed pod, rollback a bad deployment).
7. **Escalate if unresolved**: If the incident is not resolved within the SLA window, escalate to the engineering manager and VP of Engineering.
8. **Post-incident report**: After resolution, generate a preliminary post-mortem draft with timeline, root cause, and action items.

## Outputs
- Acknowledged alert in the alerting system.
- Structured incident thread with context in `#incidents`.
- Automated mitigation actions (if applicable).
- Post-mortem draft document.

## Escalation
P1 incidents require immediate human involvement. The agent must page the on-call engineer, the engineering manager, and notify leadership within 15 minutes of declaration.
