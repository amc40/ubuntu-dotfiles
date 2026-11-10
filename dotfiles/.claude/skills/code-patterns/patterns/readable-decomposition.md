---
name: readable-decomposition
applies_when: Any new or changed function, method or class, and the naming of functions, variables and predicates, especially where a function has several steps, nested branching or section comments.
principle: Write code that reads top to bottom like sentences, with each function doing one thing at one level of abstraction and named for what it achieves, so a high-level function reads as a short summary of its steps.
smells:
  - A function that mixes levels of abstraction, such as orchestration next to string slicing, index arithmetic or raw I/O.
  - A comment that says what a block does, or a section comment inside a function body such as "# validate input" or "# build the query"; the block should be a named function instead.
  - A vague or generic name such as process, handle, data, tmp, util or do_thing, or a name that needs a comment to explain it.
  - A function whose steps cannot be summarised in one sentence, or whose name needs "and" or hides a side effect.
  - Conditionals or loops nested three or more levels deep where early returns or named helpers would flatten them.
  - A compound boolean written inline with several clauses instead of a named predicate.
  - A boolean flag parameter that switches the function between two behaviours.
  - A call site that has to be read alongside the callee's definition to be understood, for example positional literals such as `send(user, True, 3)`.
not_a_violation:
  - A short function where extracting a step would only rename a one-liner or scatter a linear sequence into helpers used once, so the reader has to jump around to follow it.
  - A deliberately inlined hot path, where the reason is stated in a comment.
  - Long but flat declarative content such as tables, configuration or test data.
  - Established domain terms or conventions in the codebase, including short names with a standard meaning such as i or x in a mathematical routine.
  - Shell pipelines, which are composed from small tools by design.
  - The given, when and then markers in tests, which the given-when-then-tests pattern requires.
finding_format: Name the step to extract and a verb-phrase name for it, and show how the calling function reads afterwards.
---

## Prefer

A reader should be able to understand a function by reading its calls in
order, without opening any of them. Extract a block when you can name what it
achieves, not merely what it does, and extract a condition when you can say
what it means.

```python
# Avoid: the reader decodes every step, and comments carry the meaning.
def checkout(cart, user):
    # apply discount
    total = sum(i.price * i.qty for i in cart.items)
    if user.orders > 5 and not user.flagged or user.is_staff:
        total *= 0.9
    # charge
    ...

# Prefer: the body is a summary, and each name carries its meaning.
def checkout(cart, user):
    total = discounted(cart.total(), user) if is_eligible_for_discount(user) else cart.total()
    charge(user, total)
```

Names carry the meaning that a "what" comment would otherwise carry, which is
how this pattern follows the repository rule that comments explain why, not
what. Make call sites read as sentences too: prefer a keyword argument,
a named type or two small functions to a bare `True` or a magic number.

Do not decompose for its own sake. Several tiny functions each called once can
read worse than ten linear lines, and the exceptions above exist to stop that.
