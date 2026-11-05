# FastMCP (MCP servers in Python)

FastMCP is the default for MCP servers. Follow [Python](python.md) for the
toolchain (`uv`, `ruff`, `mypy`, `pytest`), and pin `fastmcp` to a compatible
range with an upper bound on the major version, since its APIs have moved
between majors (`fastmcp>=X.Y.Z,<N+1`, with the exact version locked in
`uv.lock`).

## Structure

- Tool, resource and prompt functions are **thin adapters**: validate input,
  call an application service, shape the result. Business logic lives in
  `domain` and `application` modules that know nothing about MCP, so it is
  unit-testable without a server.
- Build the server in a factory (`build_server(settings) -> FastMCP`) taking
  explicit settings, so tests can construct it with fakes. No module-level
  server that reads the environment on import.
- Settings through `pydantic-settings`, validated at start-up, with secrets as
  `SecretStr`.
- An `import-linter` contract keeps `domain` and `application` from importing
  `fastmcp`.

## Typing and tool design

- Every tool parameter and return value is fully annotated; prefer Pydantic
  models and `Annotated[..., Field(description=...)]` for anything non-trivial,
  so the generated JSON Schema carries the constraints.
- Every tool has a docstring or `description` written for a model reader, and
  sets annotations: `readOnlyHint`, `destructiveHint`, `idempotentHint` and
  `openWorldHint`. A test enumerates all registered tools and fails if any
  lacks a description or any hint.
- Errors a model can act on are raised as `ToolError` with a plain message;
  internal details are masked (`mask_error_details=True`) and logged.
- Tool names are stable API. Snapshot `list_tools()` (names, descriptions and
  input schemas) in a test, so changing the contract is a deliberate diff.

## Transports and logging

- With the stdio transport, stdout is the protocol: nothing else may write to
  it. Log to stderr, and add a lint rule (`T201`) and a test that no `print`
  reaches stdout.
- Remote servers use streamable HTTP behind TLS, with auth (below).

## Security

- Remote servers always authenticate: use FastMCP's auth providers (OAuth or
  token verification) and `AuthMiddleware` or per-tool `auth=` checks for
  authorisation; test that an unauthenticated and an unauthorised client are
  both refused.
- Rate-limit tool calls with middleware, and cap input sizes and result sizes.
- Treat every tool argument as untrusted input: no shell string interpolation,
  parameterised queries, and path arguments resolved and checked against an
  allowed root.
- Never return secrets or raw upstream errors. Gitleaks and `pip-audit` as in
  [CI and supply chain](ci-and-supply-chain.md).

## Tests

- **Unit:** `domain` and `application` with plain pytest, no MCP involved.
- **Server:** drive the real server in memory with `async with Client(server)`:
  call each tool, assert the structured result, the schema and the error
  cases, and run authorisation and middleware through the same client. This is
  the layer that proves the MCP contract and carries most of the coverage of
  the adapters.
- **Integration:** adapters against real or containerised dependencies.
- **End to end:** start the server over its real transport (stdio subprocess
  and HTTP), connect with a `Client`, and run one smoke journey per transport.
- Coverage floors and the rest of the pyramid as in
  [architecture and tests](architecture-and-tests.md); `fastmcp dev` and the MCP
  Inspector are for manual exploration only, never a gate.
