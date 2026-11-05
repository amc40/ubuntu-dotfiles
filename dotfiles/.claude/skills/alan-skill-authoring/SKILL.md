---
name: alan-skill-authoring
description: How to create or change a skill so it fits with the owner's other skills. Use when asked to write, add, edit, split, merge or review a skill, or when a task would be better captured as a skill. Requires a pass over the existing skills so they compose instead of overlapping.
---

# Authoring skills

Skills are a set, not a pile. A new or changed skill has to fit with the ones
already in the harness: no duplicated guidance, no contradictions, and clear
hand-offs between them.

This skill covers how a skill fits with the others. For the mechanics of
drafting one, running evals and tuning its description, use the
`skill-creator` skill alongside it rather than repeating that here.

## Pass over existing skills first

Before writing anything, find every skill that is available in the harness:
the skills listed in the session, the user's `~/.claude/skills`, the skills in
this dotfiles repo (`dotfiles/.claude/skills/`) and the current project's
`.claude/skills`. Read the ones that touch the same topic, not just their
descriptions.

Then decide, in this order:

1. **Extend** an existing skill if the new guidance belongs to its purpose.
2. **Compose** if it needs behaviour another skill already defines: write the
   new skill to point at that one.
3. **Create** a new skill only for a purpose nothing covers.

Do the same pass when changing an existing skill, and again when you finish,
because the change may create overlaps or stale references elsewhere.

## Compose, don't repeat

- Every rule has one home. If another skill states it, refer to that skill by
  name ("follow the `repo-scaffolding` skill") instead of restating it.
- Say what is delegated and when. A skill that relies on another names it at
  the step where it applies.
- Refer by skill name, never by file path: install locations differ between
  machines and sessions.
- Keep references one-directional. If two skills each need the other, the
  shared part belongs in a third skill, or in one of them.
- When a new skill makes part of an existing one redundant, replace that part
  with a reference in the same change.
- If two skills conflict, reconcile them in the change rather than leaving the
  agent to pick. Surface the choice to the owner if it is a matter of
  preference.

## Write the skill

- **Description:** says what the skill does and when to use it, specific enough
  not to collide with a neighbouring skill's triggers. This is what decides
  whether it loads, so write it with the neighbours in view.
- **Principles over mechanics.** State what must be true and why. Name tools or
  exact steps only where the owner has standardised on them.
- **Short.** One focused purpose. Put detail that is only sometimes needed in a
  separate file in the skill's directory, linked from `SKILL.md`, so it loads
  only when needed.
- **Repo conventions:** a skill lives at
  `dotfiles/.claude/skills/<name>/SKILL.md`, its `name` matches its directory,
  and the `claude` component of `install.sh` installs it. `test/consistency.sh`
  checks the name, the description and that relative links resolve.

## Check it

Run the repo's tests, then re-read the neighbouring skills once more with the
new one in mind: does anything now repeat, contradict or fail to point at it?
