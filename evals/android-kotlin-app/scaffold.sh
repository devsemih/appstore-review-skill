#!/usr/bin/env bash
# Seeds the empty run workspace (the current directory) with this case's fixture project.
# Only ./project is copied, so EXPECTED.md and graders/ never reach the agent under test.
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -R "$case_dir/project/." .
