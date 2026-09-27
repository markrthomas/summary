# Workspace instructions (~/proj)

This directory is the root of the RTL/DV workspace; every repo under it
inherits these instructions (Claude Code loads parent-directory CLAUDE.md
files). Repo-specific guidance lives in each repo's own CLAUDE.md.

## Standard operating procedures

- **Pull requests: open them ready for review, not as drafts.** When you push
  a branch and open a PR in any repo in this workspace, create it with
  "Ready for review" (draft = false). Only open a draft if the user asks for
  one or the work is explicitly unfinished; say so in the PR body if you do.
- **Finish what you open: review, merge, delete the branch.** For branches
  and PRs you create in this workspace, don't stop at "PR opened". Once CI is
  green and there are no merge conflicts or open review threads, review the
  full diff yourself (correctness, scope, no stray or generated files, docs and
  help text in sync), then merge the PR and delete its branch (remote and
  local). Stop and leave the PR open for the user instead when there is a high
  probability of a mistake. That covers RTL/DUT behaviour changes, changes
  to what a regression checks or its default stimulus, anything you could
  not verify end to end (e.g. a toolchain unavailable in your environment),
  CI that is red or was not run, or a reviewer who asked for changes. Say
  why in the PR and to the user.
