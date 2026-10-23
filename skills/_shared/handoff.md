# Handoff block

**Reference-only.** Not a skill. Written by every step as the last thing it prints; read by the
user and by the next step's author. It replaces a summary of the conversation: after `/clear`,
this block and the files on disk are all that carry over.

## Format

```
## Handoff

Produced:
- <path>            one line per file written or changed
Review:
- <what to look at>  one line each, most important first; never a restatement of the file
State: <feature> · <step> · gates approved: <G1, G2 …> or none
Next: /pacenote:<command> [args]   after `/clear`
```

## Rules

- Print it once, at the end, after every write and commit has happened. Nothing follows it.
- `Produced` lists paths only, named by root (`<docs_root>/project.md`), never contents.
- `Review` tells the user where their judgement is needed: an assumption made, a gap left, a
  choice that could go another way. At most five lines.
- `State` repeats what `state.yml` says (feature, `step`, approved gates) when the step has
  one, or the step name otherwise.
- `Next` is one exact command. When the flow forks (for example greenfield after `onboard`),
  give the default first and the alternative on a second line.
- A step that stops early (gate rejected, refusal, bounded retry exhausted) still ends with
  the block; `Next` then names the command that unblocks it.
