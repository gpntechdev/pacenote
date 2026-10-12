# Lens: security

Read by the `specialist` agent for a security pass. Only what the diff adds or changes, and
what it now reaches.

## Check

- Input reaching a sink unvalidated: SQL or query builders with string concatenation, shell
  commands, file paths, redirects, templates rendered without escaping, deserialisation.
- Authentication and authorisation: a new route, handler or action without the checks its
  neighbours have; checks done on the client only; object access by id without an owner
  check.
- Secrets: credentials, tokens or keys in code, config, logs, error messages or test
  fixtures; secrets passed in URLs.
- Data exposure: responses or logs carrying more fields than the caller needs; personal
  data written where the spec does not say.
- Crypto and randomness: home-made crypto, weak hashes for passwords, predictable tokens.
- Dependencies: a new package that is unmaintained, typo-squatted-looking or far heavier
  than the need; a version range that admits majors.
- Web specifics when present: CSRF on state-changing requests, CORS widened, cookies
  without `HttpOnly`/`Secure`/`SameSite`, missing output encoding.

## Severity

Blocker: exploitable by a user or an outsider as written. Major: exploitable with one more
mistake elsewhere, or a secret in the repo. Minor: hardening worth a line.
