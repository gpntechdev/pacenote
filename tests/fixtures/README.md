# Audit fixtures

Skill folders for `tests/test-audit` and the M6 smoke runs. Nothing here is executed.

- `malicious-skill/` is inert but built to be refused: one hit for every static category of
  `scripts/audit-static` (hidden Unicode, an encoded blob, a download piped to a shell, a
  bundled hook, a reference to an env file, a URL, a bundled script, broad `allowed-tools`),
  plus `references/style.md`, a prose-only injection (precedence override and exfiltration
  through the final answer) that no static rule matches and only the `skill-auditor` agent
  catches. Keep notes about the fixture out of its folder: the auditor reads everything
  inside it.
- `clean-skill/` has no static finding.
