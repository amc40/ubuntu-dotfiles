---
name: given-when-then-tests
applies_when: Any new or changed automated test, test name, fixture or test helper.
principle: Structure each test as given, when, then, and name it with those words so the name alone states the context, the action and the expected outcome.
smells:
  - A test name that does not state context, action and outcome, such as test_checkout, works, test_edge_case or test1.
  - A name that uses given, when and then but a body that does not follow that order, or that interleaves the phases.
  - More than one action in a single test, or assertions on outcomes that the test name could not state as one behaviour, so a failure does not identify what broke. Several assertions that together describe the one outcome of the single action are fine.
  - A given hidden in shared fixtures or setup, so the test cannot be understood without reading elsewhere.
  - A name that describes the implementation, such as calls_repository_save, instead of the behaviour observed.
  - Conditionals or loops in the test body, or a test with no assertion.
  - A phase not marked with a `# given`, `# when` or `# then` comment, or phases not separated by blank lines. A marker may be left out only for a phase that is genuinely empty, such as a test that needs no given.
not_a_violation:
  - Parameterised or table-driven tests, where the name template and each case description together carry given, when and then.
  - Property-based tests, where the given is a generated domain; the name should state the property.
  - A trivial test whose phases collapse into one expression, which needs no markers as long as the name still has all three parts.
  - Tests the diff does not add or change.
finding_format: Give the test a renamed given, when, then form, and say which step is out of order or which extra action or outcome should move to its own test.
---

## Prefer

Name the test as a sentence, in the style the language uses for test names:
`given_<context>_when_<action>_then_<outcome>` with underscores, or a string
such as `"given an expired coupon, when it is applied, then the total is unchanged"`.

Keep the body in the same order, mark each phase with a lowercase comment and
separate the phases with a blank line:

```python
def test_given_expired_coupon_when_applied_then_total_is_unchanged():
    # given
    order = an_order(total=100)
    coupon = an_expired_coupon(percent_off=10)

    # when
    order.apply(coupon)

    # then
    assert order.total == 100
```

These markers are the one exception to the rule that comments explain why and
not what. They label structure, so the rule that code should not carry "what"
comments does not apply to them.

One action per test. When a second behaviour needs checking, write a second
test with its own name rather than adding a second `when`.

## Enforce the name with a linter

In a JavaScript or TypeScript project using Jest, make the naming a lint
failure rather than a review comment, with `jest/valid-title` from
`eslint-plugin-jest` (pin its version). For flat test titles:

```js
"jest/valid-title": ["error", {
  mustMatch: {
    it: [
      "^given .+, when .+, then .+$",
      "Test names must read: given <context>, when <action>, then <outcome>",
    ],
  },
}],
```

For nested blocks, where `describe("given …")` contains `describe("when …")`
containing `it("then …")`:

```js
"jest/valid-title": ["error", {
  mustMatch: {
    describe: ["^(given|when) .+", "describe blocks must start with given or when"],
    it: ["^then .+", "it blocks must start with then"],
  },
}],
```

Both configurations were run against passing and failing test files with
eslint 9 and eslint-plugin-jest 29. The rule checks titles only, so the
markers and the one-action rule still depend on review. In other languages,
look for a linter rule on test names, and check that a badly named test fails
the build rather than being silently left out of the run.
