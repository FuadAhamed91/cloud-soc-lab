# ATT&CK coverage matrix

Updated as detections land. "Default" = fired with stock Wazuh/Sysmon rules. "Custom" = fired
after a rule written in this repo.

| Technique | ID | Tactic | Platform | Default | Custom rule | Status |
|-----------|----|--------|----------|:-------:|-------------|--------|
| Create Account: Local Account | T1136.001 | Persistence | Linux | ✅ (5902/5901) | — | Caught by default |
| OS Credential Dumping: /etc/shadow | T1003.008 | Credential Access | Linux | ❌ | ✅ 100010 (lvl 12) | Gap closed by custom rule |

## Summary

- Techniques tested: 2
- Caught by default: 1
- Custom rules written: 1
- Total coverage: 2 / 2
