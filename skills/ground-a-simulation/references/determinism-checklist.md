# Determinism checklist

These are templates, not a dependency. Adapt the tool names, patterns and
paths to your own stack; keep the shape.

## Lint: ban the usual leaks

An `eslint` config scoped to the rules path (adjust for another language's
linter — the point is the deny-list, not the tool):

```json
{
  "rules": {
    "no-restricted-globals": [
      "error",
      { "name": "Date", "message": "wall clock — not deterministic. Take time from state." },
      { "name": "performance", "message": "wall clock — not deterministic." }
    ],
    "no-restricted-properties": [
      "error",
      { "object": "Math", "property": "random", "message": "unseeded — draw from the subsystem's RNG stream instead." },
      { "object": "Date", "property": "now", "message": "wall clock — not deterministic." },
      { "object": "Intl", "property": "DateTimeFormat", "message": "locale- and clock-dependent." }
    ]
  }
}
```

`new Date()` needs a separate `no-restricted-syntax` rule (`NewExpression` on
callee name `Date`) since `no-restricted-globals` only catches bare
identifier reads, not constructor calls.

## Float-literal ban, scoped to the rules path

A grep-based pre-commit check is enough to start; a proper AST lint is
better once the rules path is large enough that hand-written numeric
literals with decimal points slip past reviewers:

```bash
# Fails if a rules-path file contains a bare float literal.
# Fixed-point values should be constructed through the scale-1/1024
# helper, never written as 0.5 in source.
git diff --cached --name-only -- 'packages/rules-*/src/**/*.ts' |
  xargs -r grep -nE '[^A-Za-z0-9_]([0-9]+\.[0-9]+)' &&
  { echo "float literal in rules path"; exit 1; }
```

## Package-manifest check: zero runtime dependencies

The core has zero runtime dependencies because a dependency is code you
didn't write and can't audit for a `Date.now()` or an unseeded `Math.random()`
buried three layers down. Assert it in CI, not just in review:

```bash
DEPS=$(node -p "Object.keys(require('./package.json').dependencies || {}).length")
[ "$DEPS" -eq 0 ] || { echo "core package gained a runtime dependency: $DEPS"; exit 1; }
```

## The shared division helper contract

Fixed-point arithmetic needs exactly one division helper, used everywhere,
because two different rounding rules for negative operands is a
determinism bug that only shows up when a value happens to go negative in
production and never in a test written by someone who only tried positive
numbers.

The contract:

- **One function.** Not `div` in three files with three different behaviours at the boundary.
- **Rounds toward negative infinity**, not toward zero and not away from it — pick one and document why negative operands don't get a special case.
- **Defined for negative operands.** A helper that only has test coverage on positive inputs has not been shown to satisfy its own contract.

The property test that pins it, independent of language:

```
property: for all integers a, b (b != 0):
  div(a, b) * b + mod(a, b) == a
  and: sign(mod(a, b)) == sign(b) or mod(a, b) == 0   # floor-division invariant
```

Run this before any behaviour is built on top of the helper. A unit test
with three hand-picked cases will not catch a rounding rule that's wrong
only for one sign combination.

## The stream-ID registry test

Every RNG stream ID is permanent once assigned. The registry test needs to
fail loud enough that nobody mistakes it for a lint nit:

```python
def test_stream_ids_append_only():
    registered = load_registry("rng-streams.json")
    assert len(registered) == len(set(registered.values())), (
        "stream ID collision — check ids {a!r} and {b!r}: "
        "every baseline committed since either was assigned is now invalid, "
        "not just the two subsystems that collided"
    )
```

The message names both colliding IDs, and it states the consequence —
invalidated baselines — rather than just the mechanical fact of the
collision. A message that says only "duplicate ID" reads as a lint issue;
a message that says "every baseline since is now invalid" reads as what it
actually is.
