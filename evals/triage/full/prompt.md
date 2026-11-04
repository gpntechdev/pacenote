---
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

/pacenote:start persistent-items Store items in a SQLite database with a schema migration instead of memory, expose them through a new HTTP JSON API (GET and POST /items) built with Flask, and require an API key on every endpoint.
