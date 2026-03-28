# Claude Code

## High Level Approach
1. Follow a TDD approach - always think about how you're going to validate something before implementing it
2. When making an involved change outline in the plan which commits you plan to make, and the validation steps you'll do before committing

## Code
1. Only add comments if they are necessary for explaining **why** something needs done a certain way, not **what** is being done
2. Only skip linting rules if you've thought carefully about alternatives, and can articulate why disabling is the best option in a comment

## Dependencies
1. When bringing in a dependency, consider whether:
    1. There are alternatives with similar functionality, if so consider presenting the alternatives in a plan
    2. I strongly perfer typed interfaces, prefer these if there is similar functionality
    3. Try not to bring in poorly maintained or deprecated dependencies
    4. Check for documentation for dependencies, whether that's part of the package, or online. Prefer those which have clear documentation
2. Dependency versions should be pinned wherever possible

## PRs

### GitHub
1. After raising a PR ensure that the checks are passing (use a `CronCreate` to check every 10s), use `CronDelete` to delete it once we know what the status is. Investigate any failures by looking at the logs with `gh run view`
2. PRs should include links to any GH issues they address

## Shell/Bash commands
1. Prefer composition of tools with chaining over custom scripts / complex arguments
2. For parsing data formats prefer purpose-built tools (e.g. `jq`, `yq`) over custom scripts

## Investigation
1. When summarising your findings include references, and double check these!

## Git
1. When making markups, make them as `--fixup` commits (no need to specify a message for these), so they can be autosquashed