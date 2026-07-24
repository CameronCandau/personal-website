# OpIndex Agent Skill Spec

Use this spec when you want an AI agent to turn a solved task or useful chat into durable `OpIndex` notes.

## Trigger

Use this workflow when:

- a task is complete
- the AI output included commands worth reusing
- you want the knowledge kept in your notes for future lookup

## Agent Objective

Convert ephemeral chat output into compact, reusable markdown that follows the `OpIndex` note standard.

## Input

The agent should expect:

- the relevant chat or command history
- the target workspace or destination file
- any existing note file content if the file already exists

## Output

The agent should produce:

- either a new markdown file or an update to an existing file
- content that follows [opindex-note-standard.md](./opindex-note-standard.md)
- command entries ready to lint with `opindex --lint-files`

## Required Behaviors

1. Preserve only reusable commands or short command sequences.
2. Write each `##` heading as a plain-English lookup phrase.
3. Put commands in fenced code blocks using a parseable shell language where possible.
4. Keep placeholders explicit and consistent.
5. Preserve only the shortest useful caveat in comments.
6. Avoid storing AI explanation unless it directly affects execution.
7. Merge into existing files without rewriting unrelated entries.

## Snippet UX Principles

When turning commands into durable snippets, optimize for fast reuse and low-friction editing:

- Prefer the shortest version that is still clear and safe enough to reuse.
- Do not introduce placeholder variables when a value is used only once and the variable adds no clarity.
- Use literal placeholder values directly in one-liners or very short examples.
- Introduce variables only when they reduce repetition, simplify loops, or make a longer example easier to modify.
- Avoid generic templating that makes a snippet longer without making it easier to understand.
- Keep the common case short. If an advanced version is meaningfully longer, separate it into its own snippet instead of folding both into one example.
- Keep related snippets stylistically consistent so users can context-switch quickly between them.
- Prefer one filtering style or matching model within a group of related snippets when practical.
- Let tools surface obvious errors naturally when that output is already clear enough.
- Add explicit warnings or error handling only when a longer script may partially fail and continue, and the failure would otherwise be easy to miss.
- Avoid defensive boilerplate that is obvious from the tool itself unless it materially improves the snippet's usability.
- Favor examples that can be copied and edited immediately over highly abstract or maximally generic examples.

## Heading Style

Good heading patterns:

- `## Login with device code`
- `## Enumerate SMB shares anonymously`
- `## Create a SOCKS proxy with SSH`
- `## Download blobs from a container`

Avoid:

- `## Notes`
- `## Random commands`
- `## Stuff from chat`
- `## Misc`

## Review Gate

Before finalizing, the agent should check:

- does every command live under a `##` heading?
- will `OpIndex` parse the chosen fenced language?
- is the heading searchable in plain English?
- is the command still understandable without reopening the chat?
- is there redundant prose that should be removed?

## Suggested Operator Prompt

```text
Take the useful reusable commands from this task and update the appropriate OpIndex markdown file.
Follow the OpIndex note standard exactly.
Do not save narrative chat output.
Prefer action-oriented ## headings, parseable fenced code blocks, and explicit placeholders.
Keep only minimal caveats in comments.
After editing, ensure the file would pass OpIndex linting.
```
