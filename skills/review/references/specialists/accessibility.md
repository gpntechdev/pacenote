# Lens: accessibility

Read by the `specialist` agent for an accessibility pass over changed UI. WCAG 2.2 AA is
the bar unless `conventions.md` names another.

## Check

- Semantics: clickable `div`s and `span`s instead of buttons and links; headings out of
  order; lists and tables built from generic elements.
- Names: controls, icons-only buttons and images without an accessible name; form fields
  without a label tied to them; placeholder used as the label.
- Keyboard: anything reachable by mouse but not by Tab; focus lost or not moved into and
  back out of dialogs, menus and drawers; `tabindex` above 0.
- State: expanded, selected, checked, busy and invalid states not exposed (`aria-*` or
  native attributes); errors not tied to their field or not announced.
- Visual: colour as the only signal; contrast below 4.5:1 for text (3:1 for large text and
  UI parts) when tokens or hard-coded colours make it checkable; motion without a
  reduced-motion path.
- Tests: when the project has an accessibility test helper, new components without it.

## Severity

Blocker: a flow in the spec cannot be completed by keyboard or screen reader. Major: a
control without a name, a dialog that traps or loses focus. Minor: the rest.
