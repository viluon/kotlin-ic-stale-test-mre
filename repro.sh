#!/usr/bin/env sh

set -eu

cd "$(dirname "$0")"

class_file="out/app/test/compile.dest/classes/repro/DeletedFailingTest.class"
source_file="app/test/src/repro/DeletedFailingTest.kt"

git restore "$source_file"
trap 'git restore "$source_file"' EXIT
rm -rf out

echo "== Step 1: compile with DeletedFailingTest source present =="
./mill --no-server app.test.compile

test -f "$class_file"

echo "== Step 2: delete DeletedFailingTest source and recompile =="
rm "$source_file"
./mill --no-server app.test.compile

test ! -f "$source_file"
test -f "$class_file"

echo "stale class still present: $class_file"

echo "== Step 3: run tests =="
if output=$(./mill --no-server app.test 2>&1); then
 printf '%s\n' "$output"
 echo "expected app.test to fail because DeletedFailingTest source was deleted" >&2
 exit 1
fi

printf '%s\n' "$output"

printf '%s\n' "$output" | grep -Fq "repro.DeletedFailingTest"
printf '%s\n' "$output" | grep -Fq "stale DeletedFailingTest still running"

echo "== Reproduced =="
echo "Deleted test source is gone, but stale DeletedFailingTest.class remains and still runs."
