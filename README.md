> [!WARNING]
> 🚧 Hengo is still under development! Expect bugs and incomplete features as we continue to improve it.

**Minimum Godot Version Required:** 4.3

# Hengo Demo Projects

Each folder containing a `project.godot` file is a demo project meant to
be used with [Godot Engine](https://godotengine.org), the open source
2D and 3D game engine.

All projects are developed entirely in [Hengo, a Visual Script](https://github.com/Henrique-Henrique/Hengo) designed for the Godot Engine.

## Downloading a demo

**[⬇ Releases page](https://github.com/Henrique-Henrique/HengoDemos/releases)**: each demo has its
own zip there, with the Hengo addon already inside.

- Download the zip of the demo you want.
- Extract it, the folder inside holds the `project.godot`.
- Import that folder in the Godot project manager and run it.

Nothing else to do, `sync-addons.sh` is only for the clone below.

## Importing all demos

To import all demos at once in the project manager:

- Clone this repository or download a ZIP archive.
  - If you've downloaded a ZIP archive, extract it somewhere.
- Run `./sync-addons.sh` from the repository root, so every demo gets the addon.
- Open the Godot project manager and click the **Scan** button on the right.
- Choose the path to the folder containing all demos.
- All demos should now appear in the project manager.

## The Hengo addon

Only the `addons/` folder at the repository root is versioned. Each demo keeps its
own copy of the addon, but that copy is ignored by git and is not in a fresh clone.

`sync-addons.sh` copies the root `addons/` into every folder that has a
`project.godot`, replacing the copy that folder had. Run it after cloning, and
again whenever the root `addons/` is updated:

```sh
./sync-addons.sh --dry-run   # lists what it would replace
./sync-addons.sh             # does it
```
