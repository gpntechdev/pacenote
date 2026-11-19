# Conventions

- Standard library only; no third-party packages.
- One module per concern; functions raise `ValueError` on bad input.
- Every public function has a unittest in `tests/test_<module>.py`.
