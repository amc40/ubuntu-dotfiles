---
name: some-other-name
applies_when: Fixture whose name differs from its filename
principle: Patterns are referenced by name, so it must match the file.
smells:
  - A signal a reviewer can look for
not_a_violation:
  - A case a reviewer must not flag
finding_format: Name the change that fixes the violation.
---
