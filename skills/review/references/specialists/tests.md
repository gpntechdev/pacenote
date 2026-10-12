# Lens: tests

Read by the `specialist` agent for a test-quality pass. The base reviewer already asked
whether each AC has a test; this pass asks whether those tests would catch a regression.

## Check

- A test that cannot fail: asserts on a mock it configured, on the input it passed, or on
  nothing; `expect(true)`-style placeholders; swallowed exceptions.
- Implementation coupling: assertions on private calls, call counts or internal state where
  an observable result exists; snapshots as the only assertion on behaviour.
- The unit under test mocked, or so much mocked that the test checks the wiring only.
- Missing cases the spec names: error paths, empty and boundary inputs, permissions, the
  edge cases listed in ACs; a bug fix without a test that fails before it.
- Flakiness: real time, randomness, network or ordering without control; sleeps instead of
  waiting on a condition; shared state between tests.
- Placement and naming against `conventions.md`: where tests live, how they are named,
  which helpers and fixtures the project already has.

## Severity

Blocker: an AC's only test cannot fail. Major: an AC edge case the spec names is untested,
or a test is flaky by construction. Minor: the rest.
