# Hermit Prov — Knowledge Transfer Documents

Welcome to the project. Read these in order if you're new. Skip around if you know what you're looking for.

| Document | What it covers |
|----------|---------------|
| [KT_00_PROJECT_OVERVIEW.md](KT_00_PROJECT_OVERVIEW.md) | What the app is, non-negotiable constraints, feature summary, tech stack |
| [KT_01_DEV_SETUP.md](KT_01_DEV_SETUP.md) | Getting the environment running, how to build, test, and analyze |
| [KT_02_ARCHITECTURE.md](KT_02_ARCHITECTURE.md) | Layer structure, DI container, repository pattern, navigation, theme |
| [KT_03_DRILL_SYSTEM.md](KT_03_DRILL_SYSTEM.md) | Deep dive into the drill state machine — the most complex part of the app |
| [KT_04_DATA_LAYER.md](KT_04_DATA_LAYER.md) | Domain models, repositories, SQLite schema, backup/restore |
| [KT_05_TESTING_GUIDE.md](KT_05_TESTING_GUIDE.md) | Test types, test structure, how to write new tests |
| [KT_06_OPEN_ISSUES.md](KT_06_OPEN_ISSUES.md) | Known gaps, open GitHub issues, intentional non-issues |

## Other key files

| File | Purpose |
|------|---------|
| [spec.md](spec.md) | Authoritative product specification — when in doubt, the spec wins |
| [prompt_plan.md](prompt_plan.md) | The 28-step build plan; useful historical context for why things were built the way they were |
| [todo.md](todo.md) | Milestone checklist (note: not fully up to date — see issue #4) |
| [`DEVELOPER_NOTES.md`](../DEVELOPER_NOTES.md) | Implementation decisions and platform-specific notes |

## Where to start

1. Read `KT_00_PROJECT_OVERVIEW.md` to understand the product
2. Follow `KT_01_DEV_SETUP.md` to get running
3. Read `KT_02_ARCHITECTURE.md` to understand the code structure
4. Read `KT_03_DRILL_SYSTEM.md` — the drill system is the heart of the app
5. Skim `KT_04_DATA_LAYER.md` and `KT_05_TESTING_GUIDE.md`
6. Check `KT_06_OPEN_ISSUES.md` so you know what's still outstanding
