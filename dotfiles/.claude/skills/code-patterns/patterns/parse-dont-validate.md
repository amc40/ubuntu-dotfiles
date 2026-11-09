---
name: parse-dont-validate
applies_when: Code at an input boundary, such as config, environment variables, CLI arguments, HTTP bodies, file contents or database rows, and code that passes such values onward.
principle: Convert untrusted input once, at the boundary, into a type that cannot represent invalid states, instead of checking it and carrying the raw value onward.
smells:
  - A validate or is_valid function whose result is discarded or only throws, followed by code that still uses the raw value.
  - The same string, number or dict re-checked for emptiness, format or presence in several places.
  - Optional or nullable fields that downstream code assumes are set, via non-null assertions or unchecked access.
  - A primitive standing in for a domain concept such as an email, port, path or ID, passed through several layers.
  - A parser that returns a loose type such as a dict, map or any that later code must trust.
  - Configuration, environment variables or arguments read and used directly in business logic without being converted at the edge.
not_a_violation:
  - Throwaway scripts and one-off commands with no downstream consumers of the value.
  - Shell scripts, which have no way to express a parsed type; flag only a missing check at the point of use.
  - A check that guards a single use and where introducing a type would add more code than it removes.
  - Validation of a relationship between several values that no single type can capture.
finding_format: Name the type to introduce and the function at the boundary that should return it, and say which downstream checks it makes unnecessary.
---

## Prefer

Make the parse step the only way to obtain the valid type, and make the
function's return type carry the guarantee.

```python
# Avoid: callers must remember to validate, and the value is still a str.
def is_valid_port(raw: str) -> bool: ...

# Prefer: success yields a Port, failure raises or returns an error.
def parse_port(raw: str) -> Port: ...
```

Downstream code takes `Port`, not `str`, so it needs no further checks and
cannot be handed an unvalidated value.
