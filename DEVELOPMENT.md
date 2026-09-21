# Building CTW Lite

## Papyrus

`Scripts/Source/*.psc` compiles with the Papyrus compiler that ships with the Creation
Kit. Besides this repository's source folder, the compiler needs the script sources of
everything these scripts extend or call, and none of them are redistributable here:

| Import | Why |
|---|---|
| `<this repo>\Scripts\Source` | this project's scripts |
| `<Skyrim>\Data\Scripts\Source` or `<Skyrim>\Data\Source\Scripts` | vanilla and SKSE script sources |
| SkyUI SDK `Scripts\Source` | `SKI_ConfigBase`, the MCM base class |
| PapyrusUtil `Scripts\Source` | `JsonUtil`, used by Persistent Settings |
| Carry That Weight `Source\Scripts` | the original's scripts, one of which Persistent Settings recompiles with two changes |

```
PapyrusCompiler.exe <script or folder> ^
  -f="TESV_Papyrus_Flags.flg" ^
  -i="<import 1>;<import 2>;..." ^
  -o="<where you want the .pex>"
```

**The game paths differ between installs**, which is why they are written as placeholders
rather than committed as a script. The Creation Kit puts the vanilla sources in one of the
two game folders above depending on how it was installed - check which one exists. The
list is order-independent and the separator is `;`.

## The plugins

The `.esp` files are produced by a generator that is not part of this repository. Each
release commits the exact plugins that go into the release archive, so what you see here is
what players run. To study or change a record, open the plugin in xEdit.

## What the author's own tree does differently, and why you do not need it

The author develops inside a Mod Organizer 2 instance, where this repository sits inside
the mod folder and the compiler writes `.pex` up into it, so the game loads a build
immediately. That arrangement is convenient and entirely optional: it is one way of
pointing `-o=` and nothing in the source depends on it.
