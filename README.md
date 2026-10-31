# KernelUI

A clean, fast and fully themed UI library for Roblox (Luau).
Windows, tabs, sliders, dropdowns, color pickers, live graphs, a 3D avatar viewer, notifications and a watermark — all with smooth tweened animations and a serious "dark tool" look.

![version](https://img.shields.io/badge/version-1.0.0-2e7dff)
![language](https://img.shields.io/badge/language-Luau-blue)

---

## Features

- **Components:** window, tabs, sections, button, toggle, slider, dropdown (single and multi), textbox, keybind, color picker, label, divider
- **3D avatar viewer:** shows the Roblox avatar of the current user (or any username) in a `ViewportFrame`. Drag to rotate, scroll to zoom, optional auto-rotate
- **Live graphs:** line or bar charts with auto or fixed scale
- **Notifications:** bottom-right cards with 4 types (Info, Success, Warning, Error) and a progress bar
- **Watermark:** draggable panel with username, FPS and ping
- **Themes:** `Dark+` (default), `White` and `Demon`, switchable at runtime. Custom themes supported
- **Smooth:** built on `TweenService`, one single global FPS/ping loop, no per-frame polling in the UI
- **Mobile friendly:** auto scaling, touch dragging and a floating toggle button
- **Ready-made settings tab:** theme, accent color, UI scale, menu key, watermark and unload button

## Installation

### Option A: ModuleScript (Roblox Studio)

1. Create a `ModuleScript` named `KernelUI` (for example in `ReplicatedStorage`).
2. Paste the contents of [`KernelUI.lua`](KernelUI.lua) into it.
3. Require it from a `LocalScript`:

```lua
local KernelUI = require(game.ReplicatedStorage.KernelUI)
```

### Option B: load from this repository

```lua
local url = "https://raw.githubusercontent.com/USERNAME/KernelUI/main/KernelUI.lua"
local KernelUI = loadstring(game:HttpGet(url))()
```

Replace `USERNAME` with the GitHub account that hosts the repository.

> KernelUI runs on the **client** and creates its interfaces inside `PlayerGui`.

## Quick start

```lua
local KernelUI = require(game.ReplicatedStorage.KernelUI)

local Window  = KernelUI:CreateWindow({ Title = "KERNEL", Theme = "Dark+" })
local Tab     = Window:AddTab("Main")
local Section = Tab:AddSection("Hello")

Section:AddButton({
    Name = "Click me",
    Callback = function()
        KernelUI:Notify({ Title = "Hi", Content = "It works!", Type = "Success" })
    end,
})

Section:AddToggle({ Name = "Enabled", Flag = "enabled" })
Section:AddSlider({ Name = "Speed", Min = 0, Max = 100, Default = 25 })

Window:AddSettingsTab()
```

The menu opens and closes with **RightShift** by default (`ToggleKey` option).

A full example with every element is in [`Example.lua`](Example.lua).

## Elements

| Element | Call | Returned object |
| --- | --- | --- |
| Label | `AddLabel(text)` | `:Set(text)` |
| Divider | `AddDivider()` | - |
| Button | `AddButton({ Name, Callback })` | `:SetText(text)` |
| Toggle | `AddToggle({ Name, Default, Flag, Callback })` | `:Set(bool, silent?)` `:Get()` |
| Slider | `AddSlider({ Name, Min, Max, Default, Increment, Suffix, Callback })` | `:Set(n, silent?)` `:Get()` |
| Dropdown | `AddDropdown({ Name, Options, Default, Multi, Callback })` | `:Set(v, silent?)` `:Get()` `:Refresh(options)` |
| Textbox | `AddTextbox({ Name, Placeholder, Callback })` | `:Set(text)` `:Get()` |
| Keybind | `AddKeybind({ Name, Default, Mode, Callback })` | `:Set(key)` `:Get()` |
| Color picker | `AddColorPicker({ Name, Default, Callback })` | `:Set(color, silent?)` `:Get()` |
| Graph | `AddGraph({ Name, Type, Height, Points, Min, Max, Suffix })` | `:Push(n)` `:SetData(t)` `:Clear()` |
| 3D avatar | `AddAvatar({ Username, Height, AutoRotate, Speed })` | `:SetUser(name)` `:SetAutoRotate(b)` `:SetSpeed(n)` `:ResetView()` |

Every element can be added to a **tab** or to a **section**. Elements with a `Flag` write their value to `KernelUI.Flags`.

## 3D avatar

```lua
local view = Section:AddAvatar({ Height = 260 })   -- current player by default

Section:AddTextbox({
    Name = "Other user",
    Callback = function(text, enter)
        if enter and text ~= "" then view:SetUser(text) end
    end,
})
```

## Graphs

```lua
local fps = Section:AddGraph({ Name = "FPS", Type = "Line", Min = 0, Max = 120 })

task.spawn(function()
    while true do
        fps:Push(KernelUI.FPS)   -- KernelUI.FPS and KernelUI.Ping update automatically
        task.wait(0.25)
    end
end)
```

## Notifications

```lua
KernelUI:Notify({
    Title = "Saved",
    Content = "Your settings were saved.",
    Type = "Success",   -- Info | Success | Warning | Error
    Duration = 5,       -- seconds, 0 = stay until clicked
})
```

## Watermark

Created automatically with the window (disable with `Watermark = false`).

```lua
KernelUI:SetWatermarkVisible(false)
KernelUI:CreateWatermark({ Title = "MY HUB", ShowFPS = true, ShowPing = true })
```

## Themes and customization

```lua
KernelUI:SetTheme("Demon")                           -- Dark+ | White | Demon
KernelUI:SetAccent(Color3.fromRGB(0, 200, 120))      -- change the accent color

KernelUI:RegisterTheme("Ocean", {                    -- create your own theme
    Accent     = Color3.fromRGB(0, 190, 210),
    AccentDark = Color3.fromRGB(0, 90, 105),
}, "Dark+")
KernelUI:SetTheme("Ocean")
```

Theme tokens: `Background`, `Surface`, `SurfaceAlt`, `Hover`, `Stroke`, `Accent`, `AccentDark`, `Text`, `SubText`, `OnAccent`, `Success`, `Warning`, `Error`.

## Window options

| Option | Description |
| --- | --- |
| `Title` | Window title (default `"KERNEL"`) |
| `SubTitle` | Small text next to the title |
| `Size` | `UDim2.fromOffset(width, height)` (default 580 x 400) |
| `Theme` | `"Dark+"`, `"White"`, `"Demon"` or a custom theme |
| `ToggleKey` | `Enum.KeyCode` to show/hide the window (default `RightShift`) |
| `Watermark` | Set to `false` to disable the watermark |

Window methods: `AddTab`, `AddSettingsTab`, `SelectTab`, `Toggle`, `SetScale`, `Notify`, `Destroy`.
Library methods: `CreateWindow`, `Notify`, `SetTheme`, `RegisterTheme`, `SetAccent`, `CreateWatermark`, `SetWatermarkVisible`, `Unload`.

## Documentation

The complete documentation (every command, option and customization) is available as a PDF: [`KernelUI_Documentacao.pdf`](KernelUI_Documentacao.pdf) (written in Portuguese).

## Repository structure

```
KernelUI/
|- KernelUI.lua                  -- the library
|- Example.lua                   -- full usage example
|- KernelUI_Documentacao.pdf     -- full documentation
|- README.md
```

## Author

Made by **gustaaav0**.
