---
name: domain-driven-hexagonal
applies_when: Code that adds or changes modules, packages or the dependencies between them in an application with business logic, new I/O used by that logic (databases, HTTP, files, queues, clocks), and the naming of domain concepts.
principle: Model the business domain in a pure core named in the business's own language, and reach the outside world only through ports the core defines and adapters implement, so dependencies point inwards.
smells:
  - Domain or application code importing a framework, ORM, HTTP client, vendor SDK, filesystem or environment access directly.
  - A dependency pointing outwards, such as the domain importing from an adapter or infrastructure module, or using a concrete adapter class where a port belongs.
  - Business rules living in controllers, route handlers, ORM models, CLI commands or queries instead of in domain objects or domain services.
  - An anemic domain, where entities are bags of fields and callers enforce the invariants from outside.
  - A port shaped around the technology, such as SqlUserTable or HttpClient, instead of what the domain needs, such as UserRepository, or a port that hands persistence or transport types (rows, DTOs, responses) to the domain.
  - Names taken from the technology or from generic words such as Manager, Helper, Data or Util instead of the ubiquitous language, or one concept named differently in different places.
  - One model shared across bounded contexts, or a context reaching into another's internals instead of its public interface.
  - Time, randomness or identifiers obtained inside domain code from global sources instead of being passed in.
not_a_violation:
  - Small scripts, CLIs and glue code with no real business logic, where ports and adapters would be ceremony.
  - The composition root, which imports both core and adapters because wiring them together is its job.
  - Standard-library types and pure value libraries used by the domain, such as dates, decimals and collections.
  - Shell, configuration and dotfiles repositories.
  - Code in a repository whose agreed structure already enforces the layering differently; follow that structure.
finding_format: Name the misplaced rule or dependency and the layer it belongs in, then the port to introduce, named in domain terms, and the adapter that implements it.
---

## Prefer

Three layers, with dependencies pointing only inwards:

- **Domain:** entities, value objects and domain services holding the
  business rules and invariants, with no framework or I/O imports.
- **Application:** use cases that orchestrate the domain and own the ports,
  which are interfaces named for what the domain needs.
- **Adapters:** the web, CLI, database, queue and vendor integrations that
  implement the ports or call the use cases.

One bounded context per area of the business, each with its own model and a
public interface. Other contexts use that interface and never its internals.

```python
# Domain defines what it needs, in its own words.
class OrderRepository(Protocol):
    def next_to_ship(self) -> Order | None: ...

# An adapter implements it; the domain never imports this module.
class PostgresOrderRepository:
    def next_to_ship(self) -> Order | None: ...
```

Because the core depends on nothing outside itself, it can be tested with
in-memory fakes of the ports and no framework. The `repo-scaffolding` skill
covers enforcing this structure with a tool.
