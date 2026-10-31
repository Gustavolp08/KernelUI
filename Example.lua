-- Example.lua : exemplo completo de uso da KernelUI
-- ModuleScript (Studio):  local KernelUI = require(script.Parent.KernelUI)
-- Hospedada:              local KernelUI = loadstring(game:HttpGet("URL_RAW_DO_SEU_GITHUB/KernelUI.lua"))()

local KernelUI = require(script.Parent.KernelUI)
local RunService = game:GetService("RunService")

local Window = KernelUI:CreateWindow({
	Title = "KERNEL",
	SubTitle = "example",
	Theme = "Dark+", -- "Dark+" | "White" | "Demon"
	ToggleKey = Enum.KeyCode.RightShift,
})

---------------------------------------------------------------- Main
local Main = Window:AddTab("Main")

local Controls = Main:AddSection("Controls")
Controls:AddLabel("Elementos basicos da biblioteca.")
Controls:AddButton({
	Name = "Notify me",
	Callback = function()
		KernelUI:Notify({ Title = "Hello", Content = "Botao clicado com sucesso.", Type = "Info", Duration = 4 })
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

---------------------------------------------------------------- Player (avatar 3D)
local Player = Window:AddTab("Player")
local Avatar = Player:AddSection("Avatar 3D")
local view = Avatar:AddAvatar({ Height = 260, AutoRotate = true }) -- usuario local por padrao
Avatar:AddTextbox({
	Name = "Another user",
	Placeholder = "Roblox username",
	Callback = function(text, enter)
		if enter and text ~= "" then
			view:SetUser(text)
		end
	end,
})
Avatar:AddToggle({
	Name = "Auto rotate",
	Default = true,
	Callback = function(v)
		view:SetAutoRotate(v)
	end,
})

---------------------------------------------------------------- Stats (graficos)
local Stats = Window:AddTab("Stats")
local Graphs = Stats:AddSection("Live graphs")
local fpsGraph = Graphs:AddGraph({ Name = "FPS", Type = "Line", Min = 0, Max = 120, Suffix = " fps" })
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

---------------------------------------------------------------- Settings (pronta)
Window:AddSettingsTab()

KernelUI:Notify({
	Title = "KernelUI " .. KernelUI.Version,
	Content = "Loaded. Press RightShift to show/hide the menu.",
	Type = "Success",
})
