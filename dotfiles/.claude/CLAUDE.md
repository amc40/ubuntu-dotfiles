# Claude Code

## High Level Approach
1. Follow a TDD approach - always think about how you're going to validate something before implementing it
2. When making an involved change outline in the plan which commits you plan to make, and the validation steps you'll do before committing

## Code
1. Only add comments if they are necessary for explaining **why** something needs done a certain way, not **what** is being done
2. Only skip linting rules if you've thought carefully about alternatives, and can articulate why disabling is the best option in a comment

## Shell/Bash commands
1. Prefer composition of tools with chaining over custom scripts / complex arguments
2. For parsing data formats prefer purpose-built tools (e.g. `jq`, `yq`) over custom scripts

## Investigation
1. When summarising your findings include references, and double check these!

## Git
1. When making markups, make them as `--fixup` commits (no need to specify a message for these), so they can be autosquashed