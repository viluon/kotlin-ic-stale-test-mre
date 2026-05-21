# Kotlin IC stale class MRE

Mill, running Kotlin incremental compilation, keeps deleted classes around. `./repro.sh` to reproduce.

TL;DR:
1. compile `app.test`
2. delete [`DeletedFailingTest.kt`](app/test/src/repro/DeletedFailingTest.kt)
3. run `./mill --no-server app.test.compile`

Expected:

- `out/app/test/compile.dest/classes/repro/DeletedFailingTest.class` is gone
- `./mill --no-server app.test` runs only `StillHereTest`

Actual:

- `out/app/test/compile.dest/classes/repro/DeletedFailingTest.class` is still there
- `./mill --no-server app.test` discovers and executes `repro.DeletedFailingTest`

> [!WARNING]
> MRE done by Copilot, GPT 5.4.
