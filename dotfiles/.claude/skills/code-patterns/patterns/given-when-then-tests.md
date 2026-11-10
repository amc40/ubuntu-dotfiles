---
name: given-when-then-tests
applies_when: Any new or changed automated test, test name, fixture or test helper.
principle: Structure each test as given, when, then, and name it with those words so the name alone states the context, the action and the expected outcome.
smells:
  - A test name that does not state context, action and outcome, such as test_checkout, works, test_edge_case or test1.
  - A name that uses given, when and then but a body that does not follow that order, or that interleaves the phases.
  - More than one action in a single test, or assertions on several unrelated outcomes, so a failure does not identify the behaviour that broke.
  - A given hidden in shared fixtures or setup, so the test cannot be understood without reading elsewhere.
  - A name that describes the implementation, such as calls_repository_save, instead of the behaviour observed.
  - Conditionals or loops in the test body, or a test with no assertion.
  - Phases not visibly separated in a test long enough to need it.
not_a_violation:
  - Parameterised or table-driven tests, where the name template and each case description together carry given, when and then.
  - Property-based tests, where the given is a generated domain; the name should state the property.
  - A trivial test whose phases collapse into one expression, as long as the name still has all three parts.
  - Tests the diff does not add or change.
finding_format: Give the test a renamed given, when, then form, and say which step is out of order or which extra action or outcome should move to its own test.
---

## Prefer

Name the test as a sentence, in the style the language uses for test names:
`given_<context>_when_<action>_then_<outcome>` with underscores, or a string
such as `"given an expired coupon, when it is applied, then the total is unchanged"`.

Keep the body in the same order and separate the phases with blank lines:

```python
def test_given_expired_coupon_when_applied_then_total_is_unchanged():
    order = an_order(total=100)
    coupon = an_expired_coupon(percent_off=10)

    order.apply(coupon)

    assert order.total == 100
```

Phase comments are not needed; the name and the blank lines carry the
structure, and this repository's rule is that comments explain why.

One action per test. When a second behaviour needs checking, write a second
test with its own name rather than adding a second `when`.
