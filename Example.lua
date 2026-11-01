-- Example.lua : full usage example for KernelUI

-- Load from GitHub (executor):
local KernelUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gustavolp08/KernelUI/main/KernelUI.lua"))()
-- Roblox Studio (ModuleScript): use this line INSTEAD of the one above
-- local KernelUI = require(script.Parent.KernelUI)

local RunService = game:GetService("RunService")

local Window = KernelUI:CreateWindow({
	Title = "KERNEL",
	SubTitle = "example",
	Theme = "Dark+", -- "Dark+" | "White" | "Demon"
	ToggleKey = Enum.KeyCode.RightShift,
	-- Accent = Color3.fromRGB(0, 200, 120), -- optional: custom main color
	-- Rainbow = true,                       -- optional: animated rainbow top bar
})

---------------------------------------------------------------- Main
local Main = Window:AddTab("Main")

local Controls = Main:AddSection("Controls")
Controls:AddLabel("Basic elements of the library.")
Controls:AddButton({
	Name = "Notify me",
	Callback = function()
		KernelUI:Notify({ Title = "Hello", Content = "Button clicked successfully.", Type = "Info", Duration = 4 })
	end,
})
Controls:AddToggle({
	Name = "Enable feature",
	Default = false,
	Flag = "feature",
	Callback = function(state)
		print("toggle:", state)
	end,
})
Controls:AddSlider({
	Name = "Speed",
	Min = 0,
	Max = 100,
	Default = 25,
	Increment = 1,
	Suffix = " %",
	Flag = "speed",
	Callback = function(v)
		print("slider:", v)
	end,
})
Controls:AddDropdown({
	Name = "Mode",
	Options = { "Easy", "Normal", "Hard" },
	Default = "Normal",
	Callback = function(v)
		print("mode:", v)
	end,
})
Controls:AddDropdown({
	Name = "Targets (multi)",
	Options = { "A", "B", "C", "D" },
	Multi = true,
	Default = { "A" },
	Callback = function(list)
		print("selected:", table.concat(list, ","))
	end,
})
Controls:AddTextbox({
	Name = "Name",
	Placeholder = "type...",
	Callback = function(text, enter)
		print("text:", text, enter)
	end,
})
Controls:AddKeybind({
	Name = "Action key",
	Default = Enum.KeyCode.F,
	Mode = "Press", -- "Press" | "Hold" | "Toggle"
	Callback = function()
		print("key pressed")
	end,
})
Controls:AddColorPicker({
	Name = "Color",
	Default = Color3.fromRGB(46, 125, 255),
	Callback = function(c)
		print("color:", c)
	end,
})

---------------------------------------------------------------- Appearance (theme / accent / rainbow)
local Look = Main:AddSection("Appearance")
local accentPicker
Look:AddDropdown({
	Name = "Theme",
	Options = KernelUI.ThemeOrder, -- Dark+ | White | Demon
	Default = KernelUI.CurrentTheme,
	Callback = function(name)
		KernelUI:SetTheme(name)
		accentPicker:Set(KernelUI:GetAccent(), true) -- keep the picker in sync
	end,
})
accentPicker = Look:AddColorPicker({
	Name = "Main color (accent)",
	Default = KernelUI:GetAccent(),
	Callback = function(color)
		KernelUI:SetAccent(color)
	end,
})
Look:AddButton({
	Name = "Reset main color",
	Callback = function()
		KernelUI:ResetAccent()
		accentPicker:Set(KernelUI:GetAccent(), true)
	end,
})
Look:AddToggle({
	Name = "Rainbow top bar",
	Default = false,
	Callback = function(on)
		KernelUI:SetRainbow(on)
	end,
})
Look:AddSlider({
	Name = "Rainbow speed",
	Min = 0.05,
	Max = 1,
	Default = 0.25,
	Increment = 0.05,
	Callback = function(v)
		KernelUI.RainbowSpeed = v
	end,
})

---------------------------------------------------------------- Player (3D avatar)
local Player = Window:AddTab("Player")
local Avatar = Player:AddSection("Avatar 3D")
local view = Avatar:AddAvatar({ Height = 260, AutoRotate = true }) -- local user by default
Avatar:AddTextbox({
	Name = "Another user",
	Placeholder = "Roblox username",
	Callback = function(text, enter)
		if enter and text ~= "" then
			view:SetUser(text)
		end
	end,
})
Avatar:AddButton({
	Name = "Back to me",
	Callback = function()
		view:SetUser(game:GetService("Players").LocalPlayer.UserId)
	end,
})
Avatar:AddToggle({
	Name = "Auto rotate",
	Default = true,
	Callback = function(v)
		view:SetAutoRotate(v)
	end,
})
Avatar:AddToggle({
	Name = "Show accessories",
	Default = true,
	Callback = function(v)
		view:SetAccessories(v)
	end,
})

---------------------------------------------------------------- Stats (graphs)
local Stats = Window:AddTab("Stats")
local Graphs = Stats:AddSection("Live graphs")
-- no Max on purpose: the scale adjusts itself, so 320+ FPS fits too
local fpsGraph = Graphs:AddGraph({ Name = "FPS", Type = "Line", Min = 0, Suffix = " fps" })
local pingGraph = Graphs:AddGraph({ Name = "Ping", Type = "Bar", Min = 0, Suffix = " ms", Height = 90 })

local acc = 0
RunService.Heartbeat:Connect(function(dt)
	acc = acc + dt
	if acc >= 0.25 then
		acc = 0
		fpsGraph:Push(KernelUI.FPS)
		pingGraph:Push(KernelUI.Ping)
	end
end)

---------------------------------------------------------------- Settings (ready-made)
Window:AddSettingsTab()

KernelUI:Notify({
	Title = "KernelUI " .. KernelUI.Version,
	Content = "Loaded. Press RightShift to show/hide the menu.",
	Type = "Success",
})
