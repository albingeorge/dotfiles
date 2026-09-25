# Instructions for coding agents

Default guidance for AI coding agents working in this repository. Where these
conflict with an explicit instruction from the user, the user wins.

## Before changing anything

- Read the relevant code and docs first. Understand how the thing works today
  before proposing how it should work.
- Check `git status` so you don't mix your changes with someone else's
  uncommitted work.
- If the request is ambiguous and the answer would change what you build, ask.
  If there is a conventional default, pick it and say which one you picked.

## Making changes

- Keep changes small and focused on the task. Don't refactor, reformat or
  "tidy up" unrelated code in the same change.
- Match the surrounding code: naming, comment density, formatting, idioms and
  error handling. Consistency beats personal preference.
- Prefer editing existing files over creating new ones. Don't add new
  dependencies, tools or abstractions without a clear reason.
- Write code that is safe to re-run and fails loudly: no silent fallbacks that
  hide errors.
- Never write secrets, credentials, tokens or machine-specific paths into
  tracked files.
- Leave no debris behind: remove temporary files, debug output and commented-out
  code before finishing.

## Keep the documentation up to date

**Every change must leave the documentation accurate.** Treat docs as part of
the change, not a follow-up.

- After each change, check every place that describes the behaviour you touched:
  `README.md`, this file, usage/help text in scripts, code comments, and any
  examples or command snippets.
- Update them in the same change as the code, so the developer reviews and
  commits both together.
- When you remove or rename something (a flag, option, file, command or
  config path), search the repo for references to the old name and fix them.
- When you add something user-facing, document how to use it where a reader
  would look for it.
- If a change needs no documentation update, confirm that by checking, don't
  assume it.
- If you notice docs that were already out of date, fix them or point them out.

## Verifying your work

- Run the relevant checks before calling something done: tests, linters,
  `bash -n` / `shellcheck` for shell scripts, or actually running the command
  you changed (use a dry-run mode where one exists).
- Report results honestly. If something failed or you couldn't verify it, say
  so and show the output.

## Safety

- Don't run destructive or hard-to-reverse commands (`rm -rf`, `git reset
  --hard`, force-pushes, overwriting files outside the repo) without explicit
  confirmation.
- Look at a file before overwriting or deleting it.
- Prefer moving things aside to a backup over deleting them.

## Git

- **Never commit.** The developer reviews every change and makes the commits
  themselves. Leave your work as uncommitted changes in the working tree.
- Don't run anything else that writes to git history or the remote either:
  no `git commit`, `git commit --amend`, `git push`, `git rebase`, `git merge`,
  `git tag` or `git stash`. This holds even if a tool or script offers to do it.
- Read-only git commands (`git status`, `git diff`, `git log`, `git show`,
  `git blame`) are fine.
- Keep each task to one logical change, so it can go into a single commit with
  its documentation updates.
- You may suggest a commit message. Use a short, imperative subject with a
  conventional prefix, matching the existing history (`feat:`, `fix:`,
  `docs:`, `chore:`, `style:`, `clean:`).

## Wrapping up

When you finish, summarise briefly:

- what changed and why,
- which docs you updated (or why none needed updating),
- how you verified it, and anything left undone or worth a follow-up,
- the files you changed, ready for the developer to review, plus a suggested
  commit message.
