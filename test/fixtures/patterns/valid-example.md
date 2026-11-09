---
name: valid-example
applies_when: Fixture used to prove the validator accepts a well-formed pattern
principle: A well-formed pattern has every required field.
smells:
  - A signal a reviewer can look for
not_a_violation:
  - A case a reviewer must not flag
finding_format: Name the change that fixes the violation.
---

Body text is free-form.
