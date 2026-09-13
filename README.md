# CTW Lite

Two companion plugins for **Carry That Weight** by MrPMG
([Nexus 50144](https://www.nexusmods.com/skyrimspecialedition/mods/50144)):

- **Carry That Weight Lite** keeps only the carry capacity formula - base capacity,
  capacity per level and capacity per point of stamina - and replaces the original's menu
  with a single page. The item limiter and the encumbrance buffs and debuffs are gone, and
  so is the inventory event scripting they need.
- **Carry That Weight Settings Loader** saves your Carry That Weight settings to a file and
  loads them into a new game. It works with the original mod and with Lite.

Both plugins **require the original mod installed** - they use its plugin as a master.

**Status: early development.** Nothing here is released yet.

## Credit and license

Carry That Weight is the work of **MrPMG**, released by its author under
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). This project adapts and
builds on that work, and is released under the **same license, CC BY-SA 4.0**. See
[LICENSE](LICENSE).

## What is in this repository, and what is not

```
Scripts/Source/     Papyrus source (.psc)
Scripts/            compiled scripts (.pex) - added at each release
*.esp               the plugins - added at each release
```

**Compiled scripts and plugins arrive only with a release.** Between releases this
repository carries source; each release commits the exact `.pex` and `.esp` files that go
into the release archive.

**What is not here, on purpose:** the tool that generates the plugins, and the development
records - design notes, phase logs, decision history. They live in a separate private
repository. The released plugins are committed here and can be inspected with xEdit.

## Building

See [DEVELOPMENT.md](DEVELOPMENT.md).

## Contributing

Issues and patches are welcome. Because the development history lives elsewhere, a pull
request is judged on the code alone - explain the why in the description rather than
assuming shared context.
