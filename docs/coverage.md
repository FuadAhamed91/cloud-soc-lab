# ATT&CK coverage matrix

Updated as detections land. "Default" = fired with stock Wazuh/Sysmon rules. "Custom" = fired
after a rule written in this repo.

| Technique | ID | Tactic | Platform | Default | Custom rule | Status |
|-----------|----|--------|----------|:-------:|-------------|--------|
| Create Account: Local Account | T1136.001 | Persistence | Linux | ✅ (5902/5901) | — | Caught by default |
| OS Credential Dumping: /etc/shadow | T1003.008 | Credential Access | Linux | ❌ | ✅ 100010 (lvl 12) | Gap closed by custom rule |
| Disable or Modify System Firewall | T1562.004 | Defense Evasion | Linux | ❌ | ✅ 100020 (lvl 10) | Gap closed by custom rule |
| Create Account: Local Account | T1136.001 | Persistence | Windows | ✅ (60110/4720) | — | Caught by default |
| PowerShell (base64 encoded) | T1059.001 | Execution | Windows | ✅ (92057, lvl 12) | — | Caught by default (needs Sysmon) |

## Summary

- Techniques tested: 5
- Caught by default: 3
- Custom rules written: 2
- Platforms: Linux + Windows
- Total coverage: 5 / 5
