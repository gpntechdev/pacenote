<!-- Printed by toolsmith step 6, never saved. Fill from skill-fetch, audit-static and the
     skill-auditor answer only; never from reading the quarantined files. Matches are
     printed as audit-static escaped them. Drop empty lines. -->
## Audit: {{folder name}} for {{layer}} · {{need}}

Source: {{repo}} @ {{commit, 12 chars}} · {{folder}} · {{files}} files, {{bytes}} bytes
Not extracted (links): {{list, or "none"}}

### Stage 1 · static · {{block | warn | clean}}
{{one line per category: category (severity) × count}}
{{every block finding, then up to 10 warn findings: severity · category · file:line · match}}

### Stage 2 · skill-auditor · {{pass | refuse}}
Purpose: {{Purpose line}}
{{every Flagged line as the agent gave it, or "Flagged: none"}}
Verdict: {{verdict line}}

### Decision
{{refused — <reason per line> | install? — recommended | install? — accept the warnings above}}
