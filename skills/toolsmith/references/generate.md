# Generating a project skill

Read by `toolsmith` step 9, when no allowlisted skill was installed for a need. The result
describes how *this* codebase does things, with pointers, plus the few library facts that
are easy to get wrong. It is the project's own text, so it is not audited by an agent, but
the static script still runs on it.

## Explorer run (`models.cheap`)

```
Root: <code_root>. Read: the folders of layer <layer> (<globs from the overview or
detection>). Skip: node_modules, vendor, build output, generated files, .env*, sources/.
Topic: <need> in this codebase.
Checklist:
1. Which files show the pattern best? (3 to 5, path:line)
2. Naming and folder conventions for this kind of code.
3. How errors, validation or state are handled here (whichever the need is about).
4. How this kind of code is tested here (runner, location, helpers).
5. What a newcomer would most likely get wrong.
Answer in your fixed shape, at most 80 lines.
```

## Researcher run (`models.judgment`)

One bounded question for the library facts the explorer cannot give: "For <library>
<version from the manifest>, what is the current recommended way to <need>? Note anything
deprecated since <version>." Context7 first; official docs otherwise. Its findings carry
URLs and dates.

## Writing the skill

- Name: `<layer>-<topic>` in kebab case (`frontend-components`, `backend-errors`). Run
  `skill-lock where --workspace <workspace_root> --code-root <code_root> --name <name>`;
  `exists` true and `locked` false means the folder belongs to the user: pick another
  name. It prints an empty `draft` folder.
- Copy `../templates/project-skill.md` to `<draft>/SKILL.md` and fill it. The draft sits
  in the gitignored `<workspace_root>/.drafts/`, outside every folder Claude Code loads
  skills from; it reaches the skill home only through `skill-lock record` after approval.
- Only pointers and rules the explorer found, plus researcher facts with their URL. No
  code blocks longer than five lines; the codebase is the example.
- At most 120 lines. No `allowed-tools`, no scripts, no hooks, no setup steps.
- Run `audit-static --dir <draft>`. A `block` is a mistake in the draft (a pasted secret
  name, an install line): fix the text and run it again. `warn` for documentation URLs is
  expected; the report lists them.

## Approval

Print the path, the description line and a summary of at most ten lines (sections, the
pointers it relies on, the researcher facts it states). Ask approve, edit, or drop. On
approve run `skill-lock record ... --from <draft> --name <name> --layer <layer> --verdict
<clean|warn>` (it moves the draft into the home) and `config-set --add
layers.<layer>=<layer_path>`. On drop run `skill-lock discard --name <name>`.
