#!/usr/bin/env bash
# Three-exit probe skeleton.
#   0  the condition holds (open)
#   42 the condition does not hold (shut)
#   1  the probe could not answer (broken)
#
# The third exit is the point. Without it, "I could not tell" is
# indistinguishable from "no", because both are non-zero.
set -uo pipefail

broken() { echo "PROBE BROKEN: $*" >&2; exit 1; }

# 1. Establish the probe can work at all, before trusting any answer.
command -v jq >/dev/null 2>&1 || broken "jq not on PATH"
[[ -n "${TARGET_REF:-}" ]]    || broken "TARGET_REF unset"

# 2. Locate input BY NAME. Never by glob, never by readdir order,
#    never by 'the file that looks like the right shape'.
INPUT="records/${TARGET_REF}.ndjson"
[[ -f "$INPUT" ]] || broken "no record for ${TARGET_REF} at ${INPUT}"

# 3. Positive control: an input the probe MUST accept. If this fails,
#    the probe is wrong, not the tree.
CONTROL="records/known-good.ndjson"
[[ -f "$CONTROL" ]] || broken "positive control missing: ${CONTROL}"
jq -e 'has("result")' "$CONTROL" >/dev/null 2>&1 \
  || broken "positive control did not parse — probe cannot read this format"

# 4. Only now is a negative answer believable.
if jq -e '.result == "ok"' "$INPUT" >/dev/null 2>&1; then
  echo "OPEN: ${TARGET_REF}"
  exit 0
fi

echo "SHUT: ${TARGET_REF}"
exit 42
