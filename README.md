# RezChest

A Decal plugin for Asheron's Call (ACE servers) that loots chests quickly, using your VTank loot profile.

- **Picks a chest for you:** set a chest once, or click any chest and press **Loot Selected**.
- **Uses your key only when needed:** if you set a key, RezChest applies it only when the chest is actually locked.
- **Identifies quickly:** every item the loot rules need IDs for is identified right away.
- **Decides with VTank:** each item is checked against VTank's current loot profile, or any `.utl` file you pick.
- **Loots back to back:** each pickup starts the moment the previous item lands in your pack.
- **Reports when done:** closes the chest and prints what it took and how long it took.

## Requirements

- Decal with Virindi View Service
- VTank (RezTank or Virindi Tank) with VTClassic. RezChest uses VTank's loot rules and its item tracker.

## Install

1. Download the newest `RezChest…dll` from [Releases](https://github.com/ResistanceLab/RezChest/releases).
2. Put it in a folder of its own, for example `C:\Games\Decal Plugins\RezChest\`.
3. Open the Decal Agent, click **Add**, pick the DLL, and make sure it's checked.
4. Start the game. Chat shows `[RezChest] RezChest… loaded`.

## Updates

RezChest checks this repository at login and then every hour.

- **New build found:** RezChest downloads it, checks its SHA-256, and installs it next to the old one. The new build loads the next time you start the game.
- **Channels:** test builds only follow test builds, and releases only follow releases. RezChest never downgrades.
- **Run AC as administrator once:** this lets RezChest point Decal at the new file directly. Without it, the update replaces the running file at the next start instead.
- **Turn off downloading:** put an empty `noautoupdate.txt` next to the DLL. You'll still be told when there's a new build.
- **Check right now:** the **Update** tab's **Check for Update** button, or `/rzc update`. While it runs the button reads **Cancel Update**; the tab shows the status, a download progress bar and the release notes.
- **Window title:** the RezChest window and the mini HUD show the version you're running.

## Use

1. **Chest:** select the chest and press **Set**. Or skip this and use **Loot Selected** on any chest you click.
2. **Key (optional):** select the key in your pack and press **Set**. It's only used when the chest is locked.
3. **Profile:** pick VTank's current loot profile or any `.utl` file in VTank's folder.
4. **Run:** press **Start**, or type `/rzc start`. That command also works from a VTank meta.

Chat shows a summary like `[RezChest] Done: Chest - looted 7 of 23 items in 4.2 s, 16 skipped`.

### Commands (`/rezchest` or `/rzc`)

```
/rzc start              open, ID and loot the saved chest
/rzc sel                loot the selected chest (doesn't change the saved one)
/rzc stop               cancel
/rzc chest              set the chest from your selection
/rzc key                set the key from your selection
/rzc key <name>         set the key by name
/rzc key none           no key
/rzc profile <file.utl> use that loot profile
/rzc profile vtank      use VTank's current loot profile
/rzc close on|off       close the chest when done (default on)
/rzc report on|off      one chat line per looted item
/rzc loop on|off        with a key set: keep unlocking and looting until the keys run out (default on)
/rzc auto on|off        loot any chest you open yourself, straight away (default off)
/rzc hud                show/hide the mini HUD (status lines + Spawn Cache, RT AutoSalvage = /rz autosalvage force, Stop/Start: stops at once, then re-runs the same chest)
/rzc ids <n>            ID requests in flight (default 4)
/rzc idgap <ms>         gap between ID requests (default 50)
/rzc idmode direct|decal  how IDs are requested (default direct)
/rzc debug on|off       timestamped trace of every step
/rzc update [cancel]    check for a newer build now (cancel = stop a check / download)
/rzc status             show the settings
```

Settings are saved per character in `Documents\Decal Plugins\RezChest\<server>\<character>.ini`. Errors are logged to `errors.txt` in `Documents\Decal Plugins\RezChest\`.
