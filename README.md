# KernelUI & MikuUI

Two UI libraries for Roblox (Luau), built for script hubs and tools.

![KernelUI](https://img.shields.io/badge/KernelUI-1.1.0-2e7dff)
![MikuUI](https://img.shields.io/badge/MikuUI-6.4.0-8b6cff)
![language](https://img.shields.io/badge/language-Luau-blue)
![license](https://img.shields.io/badge/license-free%20with%20credits-green)

**Language / Язык:** [English](#-english) | [Русский](#-русский)

---

<a name="-english"></a>
# 🇬🇧 English

## Overview

This repository contains **two UI libraries** made by the same author, each one with a different purpose:

| | **MikuUI** | **KernelUI** |
| --- | --- | --- |
| **File** | [`MikuUI.lua`](MikuUI.lua) | [`KernelUI.lua`](KernelUI.lua) |
| **Version** | 6.4.0 | 1.1.0 |
| **Used in** | The **free** version of my script | The **premium** version of my script |
| **Focus** | A polished, icon-driven, ready-to-go menu with one signature look | A full toolkit: themes, live data, 3D avatar, settings, mobile support |
| **Look** | Dark with a purple accent (single built-in palette) | `Dark+` (blue), `White` and `Demon`, plus custom themes and accent color |
| **API style** | Direct calls: `MikuUI:CreateToggle(page, ...)` | Chained objects: `Section:AddToggle({ ... })` |
| **Default window** | 1000 x 580, resizable, minimize button | 580 x 400, `SetScale`, floating toggle button |
| **Default menu key** | `RightControl` | `RightShift` |

### Main differences

- **Look & customization.** MikuUI ships with one carefully tuned purple dark palette. KernelUI adds three themes you can switch at runtime, custom themes (`RegisterTheme`), a custom accent color (`SetAccent`) and an animated rainbow top bar (`SetRainbow`).
- **Extra components.** KernelUI includes things MikuUI does not: **live graphs** (line/bar), a **3D avatar viewer**, typed **notifications** (Info / Success / Warning / Error), a watermark with **FPS and ping**, and a ready-made **settings tab**. Its elements with a `Flag` also write to `KernelUI.Flags`.
- **Things MikuUI has that KernelUI does not.** **Lucide icons** on tabs and controls, a **profile card** (avatar, display name and `@username`), a **resizable** window with a minimize button, **checkboxes**, **searchable dropdowns** and **descriptions** on toggles.
- **Platform.** KernelUI is **mobile friendly** (auto scaling, touch dragging, floating toggle button) and works both as a `ModuleScript` and through `loadstring`. MikuUI is meant to be loaded with `loadstring` and keeps a single window instance in `getgenv().Shared`.
- **Dependencies.** KernelUI is self-contained. MikuUI downloads its Lucide icon pack from [`deividcomsono/lucide-roblox-direct`](https://github.com/deividcomsono/lucide-roblox-direct) at load time (if it fails, the UI still works, just without icons).

### Which one should I use?

- Want a **lightweight, good-looking menu** with icons and a profile card? → **MikuUI**.
- Want **themes, graphs, avatar viewer, flags, settings tab and mobile support**? → **KernelUI**.

---

## MikuUI

The library behind the **free version** of my script. Focus: a clean sidebar layout, Lucide icons, a profile card and a simple, direct API.

### Features

- Window with sidebar tabs, profile card, **drag**, **resize** and **minimize**
- Components: section, label, divider, button, toggle (with description and icon), checkbox, slider, textbox, dropdown (single, **multi**, **searchable**), keybind, color picker, icon, icon button
- **Lucide icon** support by name (`"house"`) or any `rbxassetid` / image URL
- Notifications with a progress bar and a simple text watermark (`Draggable = true` makes it draggable)
- Smooth `TweenService` animations
- `MikuUI:SetValue`, `MikuUI:SetVisible`, `MikuUI:SetDisabled` to control any element after creation
- Only one window at a time by default (the old one is destroyed when you create a new one; set `getgenv().Shared.MikuLibKeepOldInstance = true` to keep it)

### Installation

```lua
local MikuUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gustavolp08/KernelUI/main/MikuUI.lua"))()
```

### Quick start

```lua
local Window = MikuUI:CreateWindow({
    Title = "MY SCRIPT",
    Subtitle = "free",                       -- default: "v6.4.0"
    Keybind = Enum.KeyCode.RightControl,     -- show / hide
})

local Page = Window:CreateTab({ Name = "Main", Icon = "house" })   -- returns the page

MikuUI:CreateSection(Page, "Hello")

MikuUI:CreateButton(Page, "Click me", function()
    MikuUI:Notify("Hi", "It works!", 4)
end)

MikuUI:CreateToggle(Page, { Name = "Enabled", Description = "Turns the feature on", Default = false,
    Callback = function(state) print(state) end })

MikuUI:CreateSlider(Page, "Speed", 0, 100, 25, function(v) print(v) end)

MikuUI:CreateDropdown(Page, {
    Name = "Targets", Options = { "A", "B", "C" }, Multi = true, Searchable = true,
    Callback = function(selected) print(selected) end,
})
```

### Window options

| Option | Description |
| --- | --- |
| `Title` / `Subtitle` | Window title and the small text next to it |
| `Size` / `Width` / `Height` | Initial size (default 1000 x 580) |
| `Keybind` | `Enum.KeyCode` to show/hide (default `RightControl`, `false` to disable) |
| `StartVisible` | `false` to start hidden |
| `Profile` | `{ Name, Tag, Image, Hidden }` to customize the profile card |
| `DisplayOrder` | `ScreenGui` display order |

Window methods: `CreateTab`, `SelectTab`, `Open`, `Close`, `Toggle`, `Minimize`, `SetSize`, `SetTitle`, `SetProfile`, `SetKeybind`, `Notify`, `CreateWatermark`, `Destroy`.
Library methods: `CreateWindow`, `Create*` (all components), `Notify`, `CreateWatermark`, `SetValue`, `SetVisible`, `SetDisabled`, `GetIcon`, `DestroyAll`.

---

## KernelUI

The library behind the **premium version** of my script. Focus: a serious "dark tool" look, full theming and richer components, with live data and mobile support.

### Features

- **Components:** window, tabs, sections, button, toggle, slider, dropdown (single and multi), textbox, keybind, color picker, label, divider
- **3D avatar viewer:** shows the Roblox avatar of the current user (or any username) in a `ViewportFrame`. Drag to rotate, scroll to zoom, optional auto-rotate
- **Live graphs:** line or bar charts with auto or fixed scale
- **Notifications:** bottom-right cards with 4 types (Info, Success, Warning, Error) and a progress bar
- **Watermark:** draggable panel with username, FPS and ping
- **Themes:** `Dark+` (default), `White` and `Demon`, switchable at runtime. Custom themes supported
- **Custom main color:** `SetAccent`, or the animated **rainbow** top bar (`SetRainbow`)
- **Smooth:** built on `TweenService`, one single global FPS/ping loop, no per-frame polling in the UI
- **Mobile friendly:** auto scaling, touch dragging and a floating toggle button
- **Ready-made settings tab:** theme, accent color, UI scale, menu key, watermark and unload button

### Installation

**Option A: ModuleScript (Roblox Studio)**

1. Create a `ModuleScript` named `KernelUI` (for example in `ReplicatedStorage`).
2. Paste the contents of [`KernelUI.lua`](KernelUI.lua) into it.
3. Require it from a `LocalScript`:

```lua
local KernelUI = require(game.ReplicatedStorage.KernelUI)
```

**Option B: load from this repository**

```lua
local KernelUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gustavolp08/KernelUI/main/KernelUI.lua"))()
```

Use **only one** of the two methods in a script. GitHub may cache the raw file for a few minutes after an update. KernelUI runs on the **client** and creates its interfaces inside `PlayerGui`.

### Quick start

```lua
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

The menu opens and closes with **RightShift** by default (`ToggleKey` option). A full example with every element is in [`Example.lua`](Example.lua).

### Elements

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
| 3D avatar | `AddAvatar({ Username, Height, AutoRotate, Speed, UseCharacter, Accessories })` | `:SetUser(name)` `:SetAutoRotate(b)` `:SetSpeed(n)` `:SetAccessories(b)` `:SetUseCharacter(b)` `:ResetView()` |

Every element can be added to a **tab** or to a **section**. Elements with a `Flag` write their value to `KernelUI.Flags`.

### Themes and customization

```lua
KernelUI:SetTheme("Demon")                           -- Dark+ | White | Demon
KernelUI:SetAccent(Color3.fromRGB(0, 200, 120))      -- change the main (accent) color
KernelUI:ResetAccent()                               -- back to the theme's own color
KernelUI:SetRainbow(true, 0.5)                       -- animated rainbow top bar (optional speed)

KernelUI:RegisterTheme("Ocean", {                    -- create your own theme
    Accent     = Color3.fromRGB(0, 190, 210),
    AccentDark = Color3.fromRGB(0, 90, 105),
}, "Dark+")
KernelUI:SetTheme("Ocean")
```

Theme tokens: `Background`, `Surface`, `SurfaceAlt`, `Hover`, `Stroke`, `Accent`, `AccentDark`, `Text`, `SubText`, `OnAccent`, `Success`, `Warning`, `Error`.

### Graphs, avatar and notifications

```lua
local fps = Section:AddGraph({ Name = "FPS", Type = "Line", Min = 0 })   -- no Max: auto scale
task.spawn(function()
    while true do fps:Push(KernelUI.FPS) task.wait(0.25) end             -- FPS / Ping update automatically
end)

local view = Section:AddAvatar({ Height = 260 })                          -- current player by default
view:SetUser("Roblox")                                                    -- or any username

KernelUI:Notify({ Title = "Saved", Content = "Settings saved.", Type = "Success", Duration = 5 })
```

### Window options

| Option | Description |
| --- | --- |
| `Title` | Window title (default `"KERNEL"`) |
| `SubTitle` | Small text next to the title |
| `Size` | `UDim2.fromOffset(width, height)` (default 580 x 400) |
| `Theme` | `"Dark+"`, `"White"`, `"Demon"` or a custom theme |
| `ToggleKey` | `Enum.KeyCode` to show/hide the window (default `RightShift`) |
| `Watermark` | Set to `false` to disable the watermark |
| `Accent` | Start with a custom main color (`Color3`) |
| `Rainbow` | `true` to start with the rainbow top bar |

Window methods: `AddTab`, `AddSettingsTab`, `SelectTab`, `Toggle`, `SetScale`, `Notify`, `Destroy`.
Library methods: `CreateWindow`, `Notify`, `SetTheme`, `RegisterTheme`, `SetAccent`, `ResetAccent`, `GetAccent`, `SetRainbow`, `CreateWatermark`, `SetWatermarkVisible`, `Unload`.

---

## Repository structure

```
KernelUI/
|- KernelUI.lua      -- premium library
|- MikuUI.lua        -- free library
|- Example.lua       -- full KernelUI usage example
|- README.md
```

## License: free to use, credits required

**KernelUI & MikuUI Attribution License** - Copyright (c) gustaaav0 / Gustavolp08

You are free to use, copy and modify these libraries in your own projects, **including commercial ones** (free or paid scripts, hubs, products and services), under these conditions:

1. **Credits are mandatory.** You must give visible credit to the author, **gustaaav0** (`github.com/Gustavolp08`), and name the library used (KernelUI or MikuUI). Put it somewhere users can see it: in the UI itself (a label, the subtitle, the settings/about tab or the watermark) **and/or** in your script's page, description or loader.
2. **Do not remove or hide the credits.** Credits must not be deleted, disguised or replaced, and the header comment of the library files must stay intact if you redistribute them.
3. **Do not claim it as your own.** You may not present the libraries, or a lightly modified copy, as your own work.
4. **No reselling the library itself.** You may sell products that *use* the libraries, but not the library files as a standalone product.
5. **No warranty.** The libraries are provided "as is". The author is not liable for any damage or issue caused by their use.
6. Breaking these terms ends your right to use the libraries.

Suggested credit line:

```
UI: KernelUI by gustaaav0 - github.com/Gustavolp08/KernelUI
```

## Author

Made by **gustaaav0** ([@Gustavolp08](https://github.com/Gustavolp08)).

---

<a name="-русский"></a>
# 🇷🇺 Русский

## Обзор

В этом репозитории находятся **две UI-библиотеки** для Roblox (Luau) от одного автора. У каждой своя задача:

| | **MikuUI** | **KernelUI** |
| --- | --- | --- |
| **Файл** | [`MikuUI.lua`](MikuUI.lua) | [`KernelUI.lua`](KernelUI.lua) |
| **Версия** | 6.4.0 | 1.1.0 |
| **Где используется** | **Бесплатная** версия моего скрипта | **Премиум**-версия моего скрипта |
| **Фокус** | Аккуратное готовое меню с иконками и фирменным стилем | Полный набор: темы, живые данные, 3D-аватар, настройки, поддержка мобильных устройств |
| **Внешний вид** | Тёмный с фиолетовым акцентом (одна встроенная палитра) | `Dark+` (синий), `White` и `Demon`, а также свои темы и цвет акцента |
| **Стиль API** | Прямые вызовы: `MikuUI:CreateToggle(page, ...)` | Цепочки объектов: `Section:AddToggle({ ... })` |
| **Окно по умолчанию** | 1000 x 580, изменяемый размер, кнопка сворачивания | 580 x 400, `SetScale`, плавающая кнопка открытия |
| **Клавиша меню по умолчанию** | `RightControl` | `RightShift` |

### Основные отличия

- **Внешний вид и настройка.** MikuUI содержит одну тщательно подобранную тёмно-фиолетовую палитру. В KernelUI есть три темы с переключением во время работы, собственные темы (`RegisterTheme`), свой цвет акцента (`SetAccent`) и анимированная радужная полоса сверху (`SetRainbow`).
- **Дополнительные компоненты.** В KernelUI есть то, чего нет в MikuUI: **живые графики** (линейные и столбчатые), **3D-просмотр аватара**, **уведомления** нескольких типов (Info / Success / Warning / Error), водяной знак с **FPS и пингом** и готовая **вкладка настроек**. Элементы с `Flag` также записывают значение в `KernelUI.Flags`.
- **Что есть в MikuUI, но нет в KernelUI.** **Иконки Lucide** на вкладках и элементах, **карточка профиля** (аватар, отображаемое имя и `@username`), окно с **изменяемым размером** и кнопкой сворачивания, **чекбоксы**, **выпадающие списки с поиском** и **описания** у переключателей.
- **Платформа.** KernelUI **адаптирован под мобильные устройства** (автомасштаб, перетаскивание касанием, плавающая кнопка) и работает как через `ModuleScript`, так и через `loadstring`. MikuUI рассчитан на загрузку через `loadstring` и хранит единственный экземпляр окна в `getgenv().Shared`.
- **Зависимости.** KernelUI полностью автономен. MikuUI при загрузке скачивает набор иконок Lucide из [`deividcomsono/lucide-roblox-direct`](https://github.com/deividcomsono/lucide-roblox-direct) (если загрузка не удалась, интерфейс всё равно работает, просто без иконок).

### Что выбрать?

- Нужно **лёгкое красивое меню** с иконками и карточкой профиля? → **MikuUI**.
- Нужны **темы, графики, просмотр аватара, флаги, вкладка настроек и поддержка мобильных устройств**? → **KernelUI**.

---

## MikuUI

Библиотека **бесплатной версии** моего скрипта. Фокус: чистая боковая панель вкладок, иконки Lucide, карточка профиля и простой, прямой API.

### Возможности

- Окно с боковыми вкладками, карточкой профиля, **перетаскиванием**, **изменением размера** и **сворачиванием**
- Компоненты: секция, текст, разделитель, кнопка, переключатель (с описанием и иконкой), чекбокс, ползунок, текстовое поле, выпадающий список (обычный, **множественный**, **с поиском**), назначение клавиши, выбор цвета, иконка, кнопка-иконка
- Поддержка **иконок Lucide** по имени (`"house"`) или любого `rbxassetid` / ссылки на изображение
- Уведомления с полосой прогресса и простой текстовый водяной знак (с `Draggable = true` его можно перетаскивать)
- Плавные анимации на `TweenService`
- `MikuUI:SetValue`, `MikuUI:SetVisible`, `MikuUI:SetDisabled` для управления любым элементом после создания
- По умолчанию одновременно открыто только одно окно (старое удаляется при создании нового; чтобы оставить его, установите `getgenv().Shared.MikuLibKeepOldInstance = true`)

### Установка

```lua
local MikuUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gustavolp08/KernelUI/main/MikuUI.lua"))()
```

### Быстрый старт

```lua
local Window = MikuUI:CreateWindow({
    Title = "MY SCRIPT",
    Subtitle = "free",                       -- по умолчанию: "v6.4.0"
    Keybind = Enum.KeyCode.RightControl,     -- показать / скрыть
})

local Page = Window:CreateTab({ Name = "Main", Icon = "house" })   -- возвращает страницу

MikuUI:CreateSection(Page, "Hello")

MikuUI:CreateButton(Page, "Click me", function()
    MikuUI:Notify("Hi", "It works!", 4)
end)

MikuUI:CreateToggle(Page, { Name = "Enabled", Description = "Turns the feature on", Default = false,
    Callback = function(state) print(state) end })

MikuUI:CreateSlider(Page, "Speed", 0, 100, 25, function(v) print(v) end)

MikuUI:CreateDropdown(Page, {
    Name = "Targets", Options = { "A", "B", "C" }, Multi = true, Searchable = true,
    Callback = function(selected) print(selected) end,
})
```

### Параметры окна

| Параметр | Описание |
| --- | --- |
| `Title` / `Subtitle` | Заголовок окна и небольшой текст рядом с ним |
| `Size` / `Width` / `Height` | Начальный размер (по умолчанию 1000 x 580) |
| `Keybind` | `Enum.KeyCode` для показа/скрытия (по умолчанию `RightControl`, `false` — отключить) |
| `StartVisible` | `false`, чтобы окно было изначально скрыто |
| `Profile` | `{ Name, Tag, Image, Hidden }` для настройки карточки профиля |
| `DisplayOrder` | Порядок отображения `ScreenGui` |

Методы окна: `CreateTab`, `SelectTab`, `Open`, `Close`, `Toggle`, `Minimize`, `SetSize`, `SetTitle`, `SetProfile`, `SetKeybind`, `Notify`, `CreateWatermark`, `Destroy`.
Методы библиотеки: `CreateWindow`, `Create*` (все компоненты), `Notify`, `CreateWatermark`, `SetValue`, `SetVisible`, `SetDisabled`, `GetIcon`, `DestroyAll`.

---

## KernelUI

Библиотека **премиум-версии** моего скрипта. Фокус: строгий «dark tool» стиль, полноценные темы и более богатые компоненты, живые данные и поддержка мобильных устройств.

### Возможности

- **Компоненты:** окно, вкладки, секции, кнопка, переключатель, ползунок, выпадающий список (обычный и множественный), текстовое поле, назначение клавиши, выбор цвета, текст, разделитель
- **3D-просмотр аватара:** показывает аватар Roblox текущего пользователя (или любого ника) в `ViewportFrame`. Вращение перетаскиванием, масштаб колёсиком, автовращение по желанию
- **Живые графики:** линейные или столбчатые, с автоматической или фиксированной шкалой
- **Уведомления:** карточки в правом нижнем углу, 4 типа (Info, Success, Warning, Error) и полоса прогресса
- **Водяной знак:** перетаскиваемая панель с именем пользователя, FPS и пингом
- **Темы:** `Dark+` (по умолчанию), `White` и `Demon`, переключаются во время работы. Поддерживаются свои темы
- **Свой основной цвет:** `SetAccent` или анимированная **радужная** полоса сверху (`SetRainbow`)
- **Плавность:** построено на `TweenService`, один общий цикл FPS/пинга, без опроса интерфейса каждый кадр
- **Для мобильных устройств:** автомасштаб, перетаскивание касанием и плавающая кнопка открытия
- **Готовая вкладка настроек:** тема, цвет акцента, масштаб интерфейса, клавиша меню, водяной знак и кнопка выгрузки

### Установка

**Вариант A: ModuleScript (Roblox Studio)**

1. Создайте `ModuleScript` с именем `KernelUI` (например, в `ReplicatedStorage`).
2. Вставьте в него содержимое [`KernelUI.lua`](KernelUI.lua).
3. Подключите его из `LocalScript`:

```lua
local KernelUI = require(game.ReplicatedStorage.KernelUI)
```

**Вариант B: загрузка из этого репозитория**

```lua
local KernelUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gustavolp08/KernelUI/main/KernelUI.lua"))()
```

Используйте **только один** из двух способов в скрипте. GitHub может кэшировать raw-файл несколько минут после обновления. KernelUI работает на **клиенте** и создаёт интерфейсы внутри `PlayerGui`.

### Быстрый старт

```lua
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

Меню по умолчанию открывается и закрывается клавишей **RightShift** (параметр `ToggleKey`). Полный пример со всеми элементами находится в [`Example.lua`](Example.lua).

### Элементы

| Элемент | Вызов | Возвращаемый объект |
| --- | --- | --- |
| Текст | `AddLabel(text)` | `:Set(text)` |
| Разделитель | `AddDivider()` | - |
| Кнопка | `AddButton({ Name, Callback })` | `:SetText(text)` |
| Переключатель | `AddToggle({ Name, Default, Flag, Callback })` | `:Set(bool, silent?)` `:Get()` |
| Ползунок | `AddSlider({ Name, Min, Max, Default, Increment, Suffix, Callback })` | `:Set(n, silent?)` `:Get()` |
| Выпадающий список | `AddDropdown({ Name, Options, Default, Multi, Callback })` | `:Set(v, silent?)` `:Get()` `:Refresh(options)` |
| Текстовое поле | `AddTextbox({ Name, Placeholder, Callback })` | `:Set(text)` `:Get()` |
| Клавиша | `AddKeybind({ Name, Default, Mode, Callback })` | `:Set(key)` `:Get()` |
| Выбор цвета | `AddColorPicker({ Name, Default, Callback })` | `:Set(color, silent?)` `:Get()` |
| График | `AddGraph({ Name, Type, Height, Points, Min, Max, Suffix })` | `:Push(n)` `:SetData(t)` `:Clear()` |
| 3D-аватар | `AddAvatar({ Username, Height, AutoRotate, Speed, UseCharacter, Accessories })` | `:SetUser(name)` `:SetAutoRotate(b)` `:SetSpeed(n)` `:SetAccessories(b)` `:SetUseCharacter(b)` `:ResetView()` |

Любой элемент можно добавить во **вкладку** или в **секцию**. Элементы с `Flag` записывают значение в `KernelUI.Flags`.

### Темы и настройка

```lua
KernelUI:SetTheme("Demon")                           -- Dark+ | White | Demon
KernelUI:SetAccent(Color3.fromRGB(0, 200, 120))      -- изменить основной цвет (акцент)
KernelUI:ResetAccent()                               -- вернуть цвет темы
KernelUI:SetRainbow(true, 0.5)                       -- радужная полоса сверху (скорость необязательна)

KernelUI:RegisterTheme("Ocean", {                    -- создать свою тему
    Accent     = Color3.fromRGB(0, 190, 210),
    AccentDark = Color3.fromRGB(0, 90, 105),
}, "Dark+")
KernelUI:SetTheme("Ocean")
```

Токены темы: `Background`, `Surface`, `SurfaceAlt`, `Hover`, `Stroke`, `Accent`, `AccentDark`, `Text`, `SubText`, `OnAccent`, `Success`, `Warning`, `Error`.

### Графики, аватар и уведомления

```lua
local fps = Section:AddGraph({ Name = "FPS", Type = "Line", Min = 0 })   -- без Max: автошкала
task.spawn(function()
    while true do fps:Push(KernelUI.FPS) task.wait(0.25) end             -- FPS / Ping обновляются автоматически
end)

local view = Section:AddAvatar({ Height = 260 })                          -- по умолчанию текущий игрок
view:SetUser("Roblox")                                                    -- или любой ник

KernelUI:Notify({ Title = "Saved", Content = "Settings saved.", Type = "Success", Duration = 5 })
```

### Параметры окна

| Параметр | Описание |
| --- | --- |
| `Title` | Заголовок окна (по умолчанию `"KERNEL"`) |
| `SubTitle` | Небольшой текст рядом с заголовком |
| `Size` | `UDim2.fromOffset(width, height)` (по умолчанию 580 x 400) |
| `Theme` | `"Dark+"`, `"White"`, `"Demon"` или своя тема |
| `ToggleKey` | `Enum.KeyCode` для показа/скрытия окна (по умолчанию `RightShift`) |
| `Watermark` | `false` — отключить водяной знак |
| `Accent` | Стартовый основной цвет (`Color3`) |
| `Rainbow` | `true` — запустить с радужной полосой |

Методы окна: `AddTab`, `AddSettingsTab`, `SelectTab`, `Toggle`, `SetScale`, `Notify`, `Destroy`.
Методы библиотеки: `CreateWindow`, `Notify`, `SetTheme`, `RegisterTheme`, `SetAccent`, `ResetAccent`, `GetAccent`, `SetRainbow`, `CreateWatermark`, `SetWatermarkVisible`, `Unload`.

---

## Структура репозитория

```
KernelUI/
|- KernelUI.lua      -- премиум-библиотека
|- MikuUI.lua        -- бесплатная библиотека
|- Example.lua       -- полный пример использования KernelUI
|- README.md
```

## Лицензия: свободное использование, указание авторства обязательно

**KernelUI & MikuUI Attribution License** - Copyright (c) gustaaav0 / Gustavolp08

Вы можете свободно использовать, копировать и изменять эти библиотеки в своих проектах, **в том числе коммерческих** (бесплатные и платные скрипты, хабы, продукты и сервисы), при следующих условиях:

1. **Указание авторства обязательно.** Вы должны явно указать автора — **gustaaav0** (`github.com/Gustavolp08`) — и название использованной библиотеки (KernelUI или MikuUI). Разместите это там, где пользователи это увидят: в самом интерфейсе (текст, подзаголовок, вкладка настроек/«О программе» или водяной знак) **и/или** на странице, в описании или в загрузчике вашего скрипта.
2. **Не удаляйте и не скрывайте авторство.** Указание авторства нельзя удалять, маскировать или подменять; комментарий-заголовок в файлах библиотек должен остаться нетронутым при их распространении.
3. **Не выдавайте за своё.** Нельзя представлять библиотеки или слегка изменённую копию как собственную работу.
4. **Нельзя продавать саму библиотеку.** Вы можете продавать продукты, которые *используют* библиотеки, но не сами файлы библиотек как отдельный продукт.
5. **Без гарантий.** Библиотеки предоставляются «как есть». Автор не несёт ответственности за любой ущерб или проблемы, вызванные их использованием.
6. Нарушение этих условий прекращает ваше право на использование библиотек.

Рекомендуемая строка с авторством:

```
UI: KernelUI by gustaaav0 - github.com/Gustavolp08/KernelUI
```

## Автор

Создано **gustaaav0** ([@Gustavolp08](https://github.com/Gustavolp08)).
