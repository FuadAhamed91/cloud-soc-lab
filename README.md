# cloud-soc-lab

A hands-on **SOC + cloud detection-engineering lab**. The goal is not to run tools — it is to
simulate attacker techniques, find the gaps in default detection, and **write and test my own
detection rules**, measuring coverage against MITRE ATT&CK.

Everything here is reproducible: infrastructure as code, versioned detection rules, and a written
record of every technique tested and whether it fired.

## Why this repo exists

Most home labs stop at "I installed a SIEM." This one is built to answer the question a SOC
interviewer actually asks: *"Show me a detection you wrote, and how you know it works."*

## Projects

| # | Project | Focus | Status |
|---|---------|-------|--------|
| 1 | [Endpoint detection lab](docs/PLAN.md#project-1) | Wazuh + Sysmon + Atomic Red Team, custom rules mapped to ATT&CK | 🟡 In progress |
| 2 | [Cloud detection lab](docs/PLAN.md#project-2) | AWS CloudTrail/GuardDuty → SIEM, Stratus Red Team, Terraform, Prowler | ⚪ Planned |
| 3 | [Serverless phishing triage](docs/PLAN.md#project-3) | Lambda + threat-intel enrichment, reuses my phishing-detector extension | ⚪ Planned |

## Repository layout

```
wazuh/          # Wazuh manager provisioning (Vagrant / config)
endpoints/      # Endpoint provisioning (Sysmon config, agent enrolment)
detections/
  sigma/        # Portable Sigma rules (the source of truth)
  wazuh-rules/  # Wazuh-specific local rules
attack-logs/    # Per-technique test records: what was run, what fired
docs/           # Plan, ATT&CK coverage matrix, write-ups
```

## Detection workflow

Every detection in this repo follows the same loop:

1. **Detonate** a technique (Atomic Red Team / Stratus Red Team).
2. **Collect** the raw telemetry it produced.
3. **Analyse** the events and decide the detection logic.
4. **Write** the rule (Sigma first, then the SIEM-native version).
5. **Re-detonate** and confirm the alert fires — and check it does *not* fire on benign activity.
6. **Record** the result in `attack-logs/` and update the coverage matrix.

## Coverage

ATT&CK coverage matrix lives in [`docs/coverage.md`](docs/coverage.md) and is updated as rules land.

---

*Lab environment only. All attack simulation is performed against disposable VMs and a personal
cloud account that I own.*
