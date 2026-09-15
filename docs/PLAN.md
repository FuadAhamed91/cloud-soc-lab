# Lab plan

Three projects, built in order. Projects 1 and 2 share one SIEM; project 3 is independent code.

Hardware note: this lab runs on a 16 GB laptop, so the operating rule is **Wazuh manager runs
continuously; an endpoint VM is powered on only while its techniques are being tested.**

---

## Project 1 — Endpoint detection lab

**Goal:** Detect endpoint attacker techniques that default Wazuh/Sysmon miss, and prove the
detections work.

**Build**
- Wazuh manager (single-node) in a dedicated VM, JVM heap tuned for a low-RAM host.
- Windows endpoint: Sysmon (sysmon-modular config) + Wazuh agent.
- Linux endpoint: auditd + Wazuh agent.

**Attack**
- Atomic Red Team, 20–30 techniques across execution, persistence, credential access,
  defence evasion, discovery.

**Detect**
- For each technique default rules miss, write a Sigma rule + the Wazuh local rule.
- Map every rule to MITRE ATT&CK; maintain the coverage matrix.

**Deliverable / CV line**
> Built a detection lab (Wazuh, Sysmon, Atomic Red Team); authored N custom rules mapped to
> MITRE ATT&CK, raising coverage from X% to Y% across N simulated techniques.

---

## Project 2 — Cloud detection lab

**Goal:** Extend detection engineering into AWS.

**Build (Terraform)**
- Disposable AWS account, billing alarm created first, auto-stop schedule.
- CloudTrail (management events), GuardDuty (trial), VPC Flow Logs → S3.
- Wazuh AWS module ingesting those buckets — same SIEM as project 1.

**Attack**
- Stratus Red Team: IAM backdoor, CloudTrail tampering, EBS snapshot exfiltration, IMDS
  credential theft. `stratus cleanup` after every run.

**Posture**
- Prowler scan → remediate findings in Terraform.
- Small boto3 checker for the handful of misconfigs that actually matter.

**Stretch:** Cowrie honeypot on a t3.micro forwarding into Wazuh — real attacker data.

**Deliverable / CV line**
> Deployed an AWS detection pipeline (CloudTrail, GuardDuty, VPC Flow Logs → SIEM) with
> Terraform; simulated N cloud techniques with Stratus Red Team and wrote detections for the
> N that GuardDuty missed.

---

## Project 3 — Serverless phishing triage

**Goal:** Automate the highest-volume SOC ticket — phishing — reusing my phishing-detector
extension's detection logic.

**Build (Terraform)**
- `.eml` dropped in S3 → Lambda parses headers, SPF/DKIM/DMARC, URLs, attachment hashes.
- Enrich: VirusTotal, URLhaus, AbuseIPDB, WHOIS domain age.
- Run URLs through the extension's detection logic → score → verdict to output bucket.

**Measure**
- Labelled set (PhishTank + own spam vs. newsletters); report verdict accuracy and median
  triage time.

**Deliverable / CV line**
> Automated phishing triage with a serverless pipeline (Lambda, S3, threat-intel enrichment);
> N% verdict accuracy on N labelled samples, median triage under N seconds.

---

## Division of labour

- **Automated (Claude Code from the host):** IaC, provisioning, running detonations, pulling raw
  telemetry, testing whether rules fire, drafting docs.
- **Mine to own:** deciding the detection logic for each rule, and the narrative in every
  write-up — these are the parts an interviewer will probe.
