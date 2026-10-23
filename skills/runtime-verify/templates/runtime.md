<!-- Written by /specd:runtime-verify to <spec_root>/<feature>/runtime.md, replaced whole on
     every run; read by deliver (how to verify) and by the user. One section per AC that ran,
     in AC order; excerpts come from runtime-check (redacted, at most 400 characters) or the
     runtime-verifier's `saw`, never typed by hand. At most 150 lines. Leaves with the spec
     folder at close. -->
# Runtime verification: {{feature}}

Run {{YYYY-MM-DD}} · {{serve_url}} · started with `{{commands.serve}}` | already running

## AC{{n}} · {{http|browser}} · {{pass|fail|blocked|accepted}}

{{http: one line per request}}
- `{{METHOD path}}` → {{status}} in {{elapsed_ms}} ms{{; failures: …}}

  ```
  {{excerpt}}
  ```

{{browser}}
- Steps: {{start path}} → {{step}} → {{step}}
- Saw: "{{saw}}"
- Console: {{errors, or none}}

## Not run

- AC{{n}} · {{none|skipped}} · {{reason}}
