--[[
    KernelUI  v1.0.0
    Biblioteca de interface para Roblox (Luau)

    Componentes: janela, abas, secoes, botao, toggle, slider, dropdown,
    textbox, keybind, color picker, graficos, avatar 3D, notificacoes,
    watermark (FPS / ping / usuario) e 3 temas (Dark+, White, Demon).

    Uso rapido:
        local KernelUI = require(script.KernelUI)   -- ModuleScript
        local Window = KernelUI:CreateWindow({ Title = "KERNEL" })
        local Tab = Window:AddTab("Main")
        Tab:AddSection("Hello"):AddButton({ Name = "Click", Callback = print })
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

local Lib = {
	Version = "1.0.0",
	Flags = {},
	Windows = {},
	FPS = 60,
	Ping = 0,
	CurrentTheme = "Dark+",
}

---------------------------------------------------------------------------
-- TEMAS
---------------------------------------------------------------------------
local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

Lib.Themes = {
	-- preto fosco com foco no azul (padrao)
	["Dark+"] = {
		Background = rgb(9, 10, 13),
		Surface = rgb(14, 15, 20),
		SurfaceAlt = rgb(20, 22, 29),
		Hover = rgb(28, 31, 42),
		Stroke = rgb(33, 37, 50),
		Accent = rgb(46, 125, 255),
		AccentDark = rgb(22, 62, 140),
		Text = rgb(230, 235, 246),
		SubText = rgb(122, 130, 150),
		OnAccent = rgb(255, 255, 255),
		Success = rgb(46, 204, 113),
		Warning = rgb(241, 196, 15),
		Error = rgb(235, 64, 82),
	},
	-- claro
	White = {
		Background = rgb(240, 242, 247),
		Surface = rgb(250, 251, 253),
		SurfaceAlt = rgb(255, 255, 255),
		Hover = rgb(232, 236, 245),
		Stroke = rgb(210, 215, 228),
		Accent = rgb(36, 104, 235),
		AccentDark = rgb(150, 185, 245),
		Text = rgb(24, 28, 40),
		SubText = rgb(100, 108, 128),
		OnAccent = rgb(255, 255, 255),
		Success = rgb(30, 170, 90),
		Warning = rgb(214, 160, 0),
		Error = rgb(214, 48, 66),
	},
	-- preto profundo com vermelho
	Demon = {
		Background = rgb(5, 4, 5),
		Surface = rgb(12, 9, 10),
		SurfaceAlt = rgb(19, 13, 14),
		Hover = rgb(34, 18, 20),
		Stroke = rgb(48, 22, 25),
		Accent = rgb(228, 24, 48),
		AccentDark = rgb(110, 10, 24),
		Text = rgb(240, 226, 228),
		SubText = rgb(150, 112, 116),
		OnAccent = rgb(255, 255, 255),
		Success = rgb(46, 204, 113),
		Warning = rgb(241, 196, 15),
		Error = rgb(255, 70, 70),
	},
}
Lib.ThemeOrder = { "Dark+", "White", "Demon" }

local function TH()
	return Lib.Themes[Lib.CurrentTheme]
end

-- instancias ligadas a tokens de tema (chaves fracas: nao seguram memoria)
local bound = setmetatable({}, { __mode = "k" })
-- callbacks de redesenho para elementos que dependem de estado
local hooks = {}

local function bind(inst, prop, token)
	inst[prop] = TH()[token]
	local b = bound[inst]
	if not b then
		b = {}
		bound[inst] = b
	end
	b[prop] = token
end

local function hook(inst, fn)
	hooks[inst] = fn
	fn(false)
end

function Lib:SetTheme(name, instant)
	local theme = Lib.Themes[name]
	if not theme then
		return false
	end
	Lib.CurrentTheme = name
	local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	for inst, props in pairs(bound) do
		if inst:IsDescendantOf(game) then
			local goal = {}
			for prop, token in pairs(props) do
				goal[prop] = theme[token]
			end
			if instant then
				for p, v in pairs(goal) do
					inst[p] = v
				end
			else
				TweenService:Create(inst, info, goal):Play()
			end
		end
	end
	for inst, fn in pairs(hooks) do
		if inst:IsDescendantOf(game) then
			pcall(fn, not instant)
		else
			hooks[inst] = nil
		end
	end
	return true
end

function Lib:RegisterTheme(name, overrides, base)
	local t = {}
	for k, v in pairs(Lib.Themes[base or "Dark+"]) do
		t[k] = v
	end
	for k, v in pairs(overrides or {}) do
		t[k] = v
	end
	Lib.Themes[name] = t
	for _, n in ipairs(Lib.ThemeOrder) do
		if n == name then
			return
		end
	end
	table.insert(Lib.ThemeOrder, name)
end

function Lib:SetAccent(color)
	local th = TH()
	th.Accent = color
	th.AccentDark = color:Lerp(Color3.new(0, 0, 0), 0.5)
	Lib:SetTheme(Lib.CurrentTheme)
end

---------------------------------------------------------------------------
-- UTILITARIOS
---------------------------------------------------------------------------
local function safe(fn, ...)
	if type(fn) == "function" then
		local ok, err = pcall(fn, ...)
		if not ok then
			warn("[KernelUI] " .. tostring(err))
		end
	end
end

local function new(class, props, theme)
	local o = Instance.new(class)
	local parent = nil
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			parent = v
		else
			o[k] = v
		end
	end
	if theme then
		for p, token in pairs(theme) do
			bind(o, p, token)
		end
	end
	o.Parent = parent
	return o
end

local function corner(p, r)
	return new("UICorner", { CornerRadius = UDim.new(0, r or 4), Parent = p })
end

local function stroke(p, token, thick)
	return new("UIStroke", {
		Thickness = thick or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = p,
	}, { Color = token or "Stroke" })
end

local function label(parent, text, props, token)
	props = props or {}
	props.BackgroundTransparency = 1
	props.BorderSizePixel = 0
	props.Text = text
	props.Font = props.Font or Enum.Font.GothamMedium
	props.TextSize = props.TextSize or 13
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props.Parent = parent
	local themed = nil
	if token ~= false then
		themed = { TextColor3 = token or "Text" }
	end
	return new("TextLabel", props, themed)
end

local function tween(o, t, goal, style, dir)
	local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), goal)
	tw:Play()
	return tw
end

local function apply(inst, animate, goal)
	if animate then
		tween(inst, 0.15, goal)
	else
		for k, v in pairs(goal) do
			inst[k] = v
		end
	end
end

local function isDown(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

local function isMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

-- arrastar um frame inteiro (usa conexoes temporarias: sem vazamento)
local function draggable(frame, handle)
	handle.InputBegan:Connect(function(input)
		if not isDown(input) then
			return
		end
		local startPos = input.Position
		local startFrame = frame.Position
		local move, up
		move = UserInputService.InputChanged:Connect(function(i)
			if isMove(i) then
				local d = i.Position - startPos
				frame.Position = UDim2.new(startFrame.X.Scale, startFrame.X.Offset + d.X, startFrame.Y.Scale, startFrame.Y.Offset + d.Y)
			end
		end)
		up = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				move:Disconnect()
				up:Disconnect()
			end
		end)
	end)
end

-- arrastar dentro de uma area, devolvendo posicao relativa (0..1)
local function alphaDrag(frame, fn)
	local function applyInput(input)
		local p, s = frame.AbsolutePosition, frame.AbsoluteSize
		fn(
			math.clamp((input.Position.X - p.X) / math.max(s.X, 1), 0, 1),
			math.clamp((input.Position.Y - p.Y) / math.max(s.Y, 1), 0, 1)
		)
	end
	frame.InputBegan:Connect(function(input)
		if not isDown(input) then
			return
		end
		applyInput(input)
		local move, up
		move = UserInputService.InputChanged:Connect(function(i)
			if isMove(i) then
				applyInput(i)
			end
		end)
		up = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				move:Disconnect()
				up:Disconnect()
			end
		end)
	end)
end

local function makeGui(name, order)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local full = "KernelUI_" .. name
	local old = playerGui:FindFirstChild(full)
	if old then
		old:Destroy()
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = full
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = order or 10
	gui.Parent = playerGui
	return gui
end

local function hoverRow(f)
	f.MouseEnter:Connect(function()
		tween(f, 0.12, { BackgroundColor3 = TH().Hover })
	end)
	f.MouseLeave:Connect(function()
		tween(f, 0.12, { BackgroundColor3 = TH().SurfaceAlt })
	end)
end

---------------------------------------------------------------------------
-- FPS / PING (um unico loop para a lib inteira)
---------------------------------------------------------------------------
local function getPing()
	local ok, v = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if ok and type(v) == "number" then
		return math.floor(v + 0.5)
	end
	return 0
end

do
	local frames, acc = 0, 0
	Lib._step = RunService.RenderStepped:Connect(function(dt)
		frames = frames + 1
		acc = acc + dt
		if acc >= 0.5 then
			Lib.FPS = math.floor(frames / acc + 0.5)
			Lib.Ping = getPing()
			frames, acc = 0, 0
			if Lib._wm then
				Lib._wm:_update()
			end
		end
	end)
end

---------------------------------------------------------------------------
-- WATERMARK
---------------------------------------------------------------------------
function Lib:CreateWatermark(o)
	o = o or {}
	if Lib._wm then
		Lib._wm:Destroy()
	end
	local gui = makeGui("Watermark", 500)
	local frame = new("Frame", {
		Name = "Watermark",
		AnchorPoint = Vector2.new(1, 0),
		Position = o.Position or UDim2.new(1, -12, 0, 10),
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		BorderSizePixel = 0,
		Active = true,
		ClipsDescendants = true,
		Parent = gui,
	}, { BackgroundColor3 = "Surface" })
	corner(frame, 4)
	stroke(frame)
	new("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		Parent = frame,
	}, { BackgroundColor3 = "Accent" })
	local txt = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = Enum.Font.Code,
		TextSize = 13,
		RichText = true,
		Text = "",
		Parent = frame,
	}, { TextColor3 = "Text" })
	new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 2), Parent = txt })
	draggable(frame, frame)

	local wm = { Visible = true, Gui = gui }
	local opts = {
		Title = o.Title or "KERNEL",
		ShowUser = o.ShowUser ~= false,
		ShowFPS = o.ShowFPS ~= false,
		ShowPing = o.ShowPing ~= false,
		UseDisplayName = o.UseDisplayName == true,
	}

	function wm:_update()
		local th = TH()
		local sep = string.format('<font color="#%s">  |  </font>', th.SubText:ToHex())
		local parts = { string.format('<font color="#%s"><b>%s</b></font>', th.Accent:ToHex(), opts.Title) }
		if opts.ShowUser then
			table.insert(parts, opts.UseDisplayName and LocalPlayer.DisplayName or LocalPlayer.Name)
		end
		if opts.ShowFPS then
			local c = th.Error
			if Lib.FPS >= 55 then
				c = th.Success
			elseif Lib.FPS >= 30 then
				c = th.Warning
			end
			table.insert(parts, string.format('<font color="#%s">%d</font> fps', c:ToHex(), Lib.FPS))
		end
		if opts.ShowPing then
			local c = th.Error
			if Lib.Ping <= 80 then
				c = th.Success
			elseif Lib.Ping <= 150 then
				c = th.Warning
			end
			table.insert(parts, string.format('<font color="#%s">%d</font> ms', c:ToHex(), Lib.Ping))
		end
		txt.Text = table.concat(parts, sep)
	end

	function wm:SetVisible(v)
		wm.Visible = v and true or false
		gui.Enabled = wm.Visible
	end

	function wm:SetTitle(t)
		opts.Title = t
		wm:_update()
	end

	function wm:Destroy()
		if Lib._wm == wm then
			Lib._wm = nil
		end
		gui:Destroy()
	end

	hook(frame, function()
		wm:_update()
	end)
	Lib._wm = wm
	return wm
end

function Lib:SetWatermarkVisible(v)
	if not Lib._wm then
		if v then
			Lib:CreateWatermark()
		end
		return
	end
	Lib._wm:SetVisible(v)
end

---------------------------------------------------------------------------
-- NOTIFICACOES (canto inferior direito)
---------------------------------------------------------------------------
local notifOrder = 0
local TYPE_TOKEN = { Info = "Accent", Success = "Success", Warning = "Warning", Error = "Error" }

local function ensureHolder()
	if Lib._notifHolder and Lib._notifHolder.Parent then
		return Lib._notifHolder
	end
	local gui = makeGui("Notifications", 1000)
	local holder = new("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -14, 1, -14),
		Size = UDim2.new(0, 300, 1, -28),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	new("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Parent = holder,
	})
	Lib._notifGui = gui
	Lib._notifHolder = holder
	return holder
end

function Lib:Notify(o)
	o = o or {}
	local holder = ensureHolder()
	local token = TYPE_TOKEN[o.Type or "Info"] or "Accent"
	local title = o.Title or "Notice"
	local text = o.Content or ""
	local dur = o.Duration or 4
	local width = 290
	local textH = TextService:GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(width - 30, 1000)).Y
	local height = 27 + textH + 13

	notifOrder = notifOrder + 1
	local wrap = new("Frame", {
		Size = UDim2.fromOffset(width, height),
		BackgroundTransparency = 1,
		LayoutOrder = notifOrder,
		Parent = holder,
	})
	local card = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.new(1, 30, 0, 0),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = wrap,
	}, { BackgroundColor3 = "Surface" })
	corner(card, 5)
	stroke(card)
	new("Frame", { Size = UDim2.new(0, 3, 1, 0), BorderSizePixel = 0, Parent = card }, { BackgroundColor3 = token })
	label(card, title, {
		Size = UDim2.new(1, -24, 0, 16),
		Position = UDim2.fromOffset(14, 9),
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	label(card, text, {
		Size = UDim2.new(1, -30, 0, textH),
		Position = UDim2.fromOffset(14, 27),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, "SubText")
	local prog = new("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		BorderSizePixel = 0,
		Parent = card,
	}, { BackgroundColor3 = token })

	tween(card, 0.35, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint)
	if dur > 0 then
		tween(prog, dur, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
	end

	local dead = false
	local function close()
		if dead then
			return
		end
		dead = true
		tween(card, 0.25, { Position = UDim2.new(1, 30, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.25, function()
			if wrap.Parent then
				tween(wrap, 0.2, { Size = UDim2.fromOffset(width, 0) })
				task.delay(0.2, function()
					wrap:Destroy()
				end)
			end
		end)
	end
	card.InputBegan:Connect(function(i)
		if isDown(i) then
			close()
		end
	end)
	if dur > 0 then
		task.delay(dur, close)
	end
	return { Close = close }
end

---------------------------------------------------------------------------
-- CONTAINER (Tab e Section compartilham os mesmos elementos)
---------------------------------------------------------------------------
local Container = {}
Container.__index = Container

local function nextOrder(self)
	self._order = (self._order or 0) + 1
	return self._order
end

local function rowFrame(self, h)
	local f = new("Frame", {
		Size = UDim2.new(1, 0, 0, h or 32),
		BorderSizePixel = 0,
		LayoutOrder = nextOrder(self),
		Parent = self.Frame,
	}, { BackgroundColor3 = "SurfaceAlt" })
	corner(f, 4)
	stroke(f)
	hoverRow(f)
	return f
end

function Container:AddSection(name)
	local box = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
		LayoutOrder = nextOrder(self),
		Parent = self.Frame,
	}, { BackgroundColor3 = "Surface" })
	corner(box, 5)
	stroke(box)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		Parent = box,
	})
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = box })
	label(box, string.upper(name or "SECTION"), {
		Size = UDim2.new(1, 0, 0, 14),
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		LayoutOrder = 0,
	}, "Accent")
	return setmetatable({ Window = self.Window, Tab = self.Tab, Frame = box, _order = 0 }, Container)
end

function Container:AddLabel(text)
	local l = label(self.Frame, text or "", {
		Size = UDim2.new(1, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		TextSize = 12,
		LayoutOrder = nextOrder(self),
	}, "SubText")
	local obj = {}
	function obj:Set(t)
		l.Text = t
	end
	return obj
end

function Container:AddDivider()
	new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		LayoutOrder = nextOrder(self),
		Parent = self.Frame,
	}, { BackgroundColor3 = "Stroke" })
end

function Container:AddButton(o)
	o = o or {}
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		LayoutOrder = nextOrder(self),
		Parent = self.Frame,
	}, { BackgroundColor3 = "SurfaceAlt" })
	corner(b, 4)
	stroke(b)
	local txt = label(b, o.Name or "Button", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(12, 0) })
	label(b, ">", {
		Size = UDim2.fromOffset(24, 32),
		Position = UDim2.new(1, -30, 0, 0),
		Font = Enum.Font.Code,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Center,
	}, "Accent")
	b.MouseEnter:Connect(function()
		tween(b, 0.12, { BackgroundColor3 = TH().Hover })
	end)
	b.MouseLeave:Connect(function()
		tween(b, 0.12, { BackgroundColor3 = TH().SurfaceAlt })
	end)
	b.MouseButton1Down:Connect(function()
		tween(b, 0.08, { BackgroundColor3 = TH().AccentDark })
	end)
	b.MouseButton1Up:Connect(function()
		tween(b, 0.12, { BackgroundColor3 = TH().Hover })
	end)
	b.MouseButton1Click:Connect(function()
		safe(o.Callback)
	end)
	local obj = {}
	function obj:SetText(t)
		txt.Text = t
	end
	return obj
end

function Container:AddToggle(o)
	o = o or {}
	local state = o.Default == true
	local r = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		LayoutOrder = nextOrder(self),
		Parent = self.Frame,
	}, { BackgroundColor3 = "SurfaceAlt" })
	corner(r, 4)
	stroke(r)
	hoverRow(r)
	label(r, o.Name or "Toggle", { Size = UDim2.new(1, -64, 1, 0), Position = UDim2.fromOffset(12, 0) })
	local track = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(34, 16),
		BorderSizePixel = 0,
		Parent = r,
	})
	corner(track, 8)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(12, 12),
		BorderSizePixel = 0,
		Parent = track,
	})
	corner(knob, 6)

	local function render(animate)
		local t = TH()
		apply(track, animate, { BackgroundColor3 = state and t.Accent or t.Stroke })
		apply(knob, animate, {
			BackgroundColor3 = state and t.OnAccent or t.SubText,
			Position = state and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		})
	end
	hook(track, render)

	local obj = {}
	function obj:Set(v, silent)
		state = v == true
		render(true)
		if o.Flag then
			Lib.Flags[o.Flag] = state
		end
		if not silent then
			safe(o.Callback, state)
		end
	end
	function obj:Get()
		return state
	end
	r.MouseButton1Click:Connect(function()
		obj:Set(not state)
	end)
	if o.Flag then
		Lib.Flags[o.Flag] = state
	end
	return obj
end

function Container:AddSlider(o)
	o = o or {}
	local min, max = o.Min or 0, o.Max or 100
	local inc = o.Increment or 1
	local dec = #((tostring(inc)):match("%.(%d+)") or "")
	local suffix = o.Suffix or ""
	local value = math.clamp(o.Default or min, min, max)

	local r = rowFrame(self, 46)
	label(r, o.Name or "Slider", { Size = UDim2.new(1, -100, 0, 16), Position = UDim2.fromOffset(12, 6) })
	local val = label(r, "", {
		Size = UDim2.fromOffset(80, 16),
		Position = UDim2.new(1, -92, 0, 6),
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.Code,
		TextSize = 12,
	}, "Accent")
	local hit = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -24, 0, 20),
		Position = UDim2.fromOffset(12, 22),
		Parent = r,
	})
	local bar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 0.5, -3),
		BorderSizePixel = 0,
		Parent = hit,
	}, { BackgroundColor3 = "Stroke" })
	corner(bar, 3)
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, Parent = bar }, { BackgroundColor3 = "Accent" })
	corner(fill, 3)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.fromScale(1, 0.5),
		BorderSizePixel = 0,
		Parent = fill,
	}, { BackgroundColor3 = "OnAccent" })
	corner(knob, 6)
	stroke(knob, "Accent", 2)

	local function fmt(v)
		return string.format("%." .. dec .. "f", v) .. suffix
	end
	local function setValue(v, silent, instant)
		v = math.clamp(math.floor((v - min) / inc + 0.5) * inc + min, min, max)
		v = tonumber(string.format("%." .. dec .. "f", v))
		local changed = v ~= value
		value = v
		local a = (max == min) and 0 or (v - min) / (max - min)
		if instant then
			fill.Size = UDim2.fromScale(a, 1)
		else
			tween(fill, 0.08, { Size = UDim2.fromScale(a, 1) })
		end
		val.Text = fmt(v)
		if o.Flag then
			Lib.Flags[o.Flag] = v
		end
		if changed and not silent then
			safe(o.Callback, v)
		end
	end
	setValue(value, true, true)
	alphaDrag(hit, function(ax)
		setValue(min + (max - min) * ax)
	end)

	local obj = {}
	function obj:Set(v, silent)
		setValue(v, silent)
	end
	function obj:Get()
		return value
	end
	return obj
end

function Container:AddDropdown(o)
	o = o or {}
	local multi = o.Multi == true
	local options = o.Options or {}
	local selected = {}
	local single = nil
	if multi then
		for _, v in ipairs(o.Default or {}) do
			selected[v] = true
		end
	else
		single = o.Default
	end

	local root = new("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		ClipsDescendants = true,
		BorderSizePixel = 0,
		LayoutOrder = nextOrder(self),
		Parent = self.Frame,
	}, { BackgroundColor3 = "SurfaceAlt" })
	corner(root, 4)
	stroke(root)
	local head = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = root,
	})
	label(head, o.Name or "Dropdown", { Size = UDim2.new(0.5, -12, 1, 0), Position = UDim2.fromOffset(12, 0) })
	local valLbl = label(head, "", {
		Size = UDim2.new(0.5, -34, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.Code,
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, "SubText")
	local arrow = label(head, "v", {
		Size = UDim2.fromOffset(20, 32),
		Position = UDim2.new(1, -26, 0, 0),
		Font = Enum.Font.Code,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
	}, "Accent")
	arrow.AnchorPoint = Vector2.new(0, 0)

	local list = new("ScrollingFrame", {
		Position = UDim2.fromOffset(6, 36),
		Size = UDim2.new(1, -12, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = root,
	}, { ScrollBarImageColor3 = "Accent" })
	new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

	local open = false
	local buttons = {}

	local function isSel(opt)
		if multi then
			return selected[opt] == true
		end
		return single == opt
	end
	local function current()
		if multi then
			local t = {}
			for _, opt in ipairs(options) do
				if selected[opt] then
					table.insert(t, opt)
				end
			end
			return t
		end
		return single
	end
	local function summary()
		if multi then
			local t = {}
			for _, opt in ipairs(options) do
				if selected[opt] then
					table.insert(t, tostring(opt))
				end
			end
			return #t > 0 and table.concat(t, ", ") or "None"
		end
		return single ~= nil and tostring(single) or "None"
	end
	local function render()
		local t = TH()
		valLbl.Text = summary()
		for opt, b in pairs(buttons) do
			local sel = isSel(opt)
			b.TextColor3 = sel and t.Accent or t.SubText
			b.BackgroundColor3 = t.Hover
			b.BackgroundTransparency = sel and 0 or 1
		end
	end
	local function listHeight()
		return math.min(#options, 5) * 28
	end
	local function setOpen(v)
		open = v
		tween(arrow, 0.2, { Rotation = v and 180 or 0 })
		list.Size = UDim2.new(1, -12, 0, listHeight())
		tween(root, 0.2, { Size = UDim2.new(1, 0, 0, v and (36 + listHeight() + 6) or 32) })
	end
	local function fire()
		if o.Flag then
			Lib.Flags[o.Flag] = current()
		end
		safe(o.Callback, current())
	end
	local function build()
		for _, b in pairs(buttons) do
			b:Destroy()
		end
		buttons = {}
		for i, opt in ipairs(options) do
			local b = new("TextButton", {
				Size = UDim2.new(1, -4, 0, 26),
				Text = tostring(opt),
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false,
				BorderSizePixel = 0,
				LayoutOrder = i,
				Parent = list,
			})
			corner(b, 3)
			new("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = b })
			b.MouseButton1Click:Connect(function()
				if multi then
					selected[opt] = (not selected[opt]) or nil
				else
					single = opt
					setOpen(false)
				end
				render()
				fire()
			end)
			buttons[opt] = b
		end
		render()
	end
	build()
	hook(root, function()
		render()
	end)
	head.MouseButton1Click:Connect(function()
		setOpen(not open)
	end)
	if o.Flag then
		Lib.Flags[o.Flag] = current()
	end

	local obj = {}
	function obj:Set(v, silent)
		if multi then
			selected = {}
			for _, x in ipairs(v or {}) do
				selected[x] = true
			end
		else
			single = v
		end
		render()
		if not silent then
			fire()
		end
	end
	function obj:Get()
		return current()
	end
	function obj:Refresh(newOptions)
		options = newOptions or {}
		build()
		if open then
			setOpen(true)
		end
	end
	return obj
end

function Container:AddTextbox(o)
	o = o or {}
	local r = rowFrame(self, 32)
	label(r, o.Name or "Textbox", { Size = UDim2.new(0.45, -12, 1, 0), Position = UDim2.fromOffset(12, 0) })
	local box = new("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0.55, -16, 0, 22),
		Text = o.Default or "",
		PlaceholderText = o.Placeholder or "type here...",
		ClearTextOnFocus = o.ClearOnFocus == true,
		Font = Enum.Font.Code,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = r,
	}, { BackgroundColor3 = "Background", TextColor3 = "Text", PlaceholderColor3 = "SubText" })
	corner(box, 3)
	local st = stroke(box)
	new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = box })
	box.Focused:Connect(function()
		tween(st, 0.15, { Color = TH().Accent })
	end)
	box.FocusLost:Connect(function(enter)
		tween(st, 0.15, { Color = TH().Stroke })
		if o.Flag then
			Lib.Flags[o.Flag] = box.Text
		end
		safe(o.Callback, box.Text, enter)
	end)
	if o.Flag then
		Lib.Flags[o.Flag] = box.Text
	end
	local obj = {}
	function obj:Set(t)
		box.Text = t
	end
	function obj:Get()
		return box.Text
	end
	return obj
end

function Container:AddKeybind(o)
	o = o or {}
	local win = self.Window
	local key = o.Default
	local mode = o.Mode or "Press" -- Press | Hold | Toggle
	local state = false
	local listening = false

	local r = rowFrame(self, 32)
	label(r, o.Name or "Keybind", { Size = UDim2.new(1, -120, 1, 0), Position = UDim2.fromOffset(12, 0) })
	local btn = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(100, 22),
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = Enum.Font.Code,
		TextSize = 12,
		Parent = r,
	}, { BackgroundColor3 = "Background", TextColor3 = "Accent" })
	corner(btn, 3)
	stroke(btn)
	local function show()
		if listening then
			btn.Text = "..."
		else
			btn.Text = key and key.Name or "None"
		end
	end
	show()
	btn.MouseButton1Click:Connect(function()
		listening = true
		win.Rebinding = true
		show()
	end)
	win:_conn(UserInputService.InputBegan, function(input, gp)
		if listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				listening = false
				win.Rebinding = false
				if input.KeyCode == Enum.KeyCode.Backspace then
					key = nil
				elseif input.KeyCode ~= Enum.KeyCode.Escape then
					key = input.KeyCode
				end
				show()
				safe(o.OnChange, key)
			end
			return
		end
		if gp or not key or input.KeyCode ~= key then
			return
		end
		if mode == "Hold" then
			state = true
			safe(o.Callback, true)
		elseif mode == "Toggle" then
			state = not state
			safe(o.Callback, state)
		else
			safe(o.Callback)
		end
	end)
	win:_conn(UserInputService.InputEnded, function(input)
		if mode == "Hold" and state and key and input.KeyCode == key then
			state = false
			safe(o.Callback, false)
		end
	end)
	local obj = {}
	function obj:Set(k)
		key = k
		show()
	end
	function obj:Get()
		return key
	end
	return obj
end

function Container:AddColorPicker(o)
	o = o or {}
	local color = o.Default or Color3.fromRGB(255, 255, 255)
	local h, s, v = color:ToHSV()

	local root = new("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		ClipsDescendants = true,
		BorderSizePixel = 0,
		LayoutOrder = nextOrder(self),
		Parent = self.Frame,
	}, { BackgroundColor3 = "SurfaceAlt" })
	corner(root, 4)
	stroke(root)
	local head = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = root,
	})
	label(head, o.Name or "Color", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromOffset(12, 0) })
	local swatch = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(30, 16),
		BorderSizePixel = 0,
		Parent = head,
	})
	corner(swatch, 3)
	stroke(swatch)

	local sv = new("Frame", {
		Position = UDim2.fromOffset(12, 42),
		Size = UDim2.new(1, -56, 0, 100),
		BorderSizePixel = 0,
		Parent = root,
	})
	corner(sv, 3)
	local white = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = sv,
	})
	corner(white, 3)
	new("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })
	local black = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Parent = sv,
	})
	corner(black, 3)
	new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black })
	local svCursor = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(10, 10),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = sv,
	})
	corner(svCursor, 5)
	new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, Parent = svCursor })

	local hueBar = new("Frame", {
		Position = UDim2.new(1, -36, 0, 42),
		Size = UDim2.fromOffset(24, 100),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = root,
	})
	corner(hueBar, 3)
	local keys = {}
	for i = 0, 6 do
		table.insert(keys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
	end
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(keys), Parent = hueBar })
	local hueCursor = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, 4, 0, 4),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = hueBar,
	})
	new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, Parent = hueCursor })

	local function update(silent)
		color = Color3.fromHSV(h, s, v)
		swatch.BackgroundColor3 = color
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svCursor.Position = UDim2.fromScale(s, 1 - v)
		hueCursor.Position = UDim2.fromScale(0.5, h)
		if o.Flag then
			Lib.Flags[o.Flag] = color
		end
		if not silent then
			safe(o.Callback, color)
		end
	end
	update(true)
	alphaDrag(sv, function(ax, ay)
		s = ax
		v = 1 - ay
		update()
	end)
	alphaDrag(hueBar, function(_, ay)
		h = math.clamp(ay, 0, 0.999)
		update()
	end)

	local open = false
	head.MouseButton1Click:Connect(function()
		open = not open
		tween(root, 0.22, { Size = UDim2.new(1, 0, 0, open and 154 or 32) })
	end)

	local obj = {}
	function obj:Set(c, silent)
		h, s, v = c:ToHSV()
		update(silent)
	end
	function obj:Get()
		return color
	end
	return obj
end

function Container:AddGraph(o)
	o = o or {}
	local height = o.Height or 110
	local maxPts = o.Points or 60
	local kind = o.Type or "Line" -- Line | Bar
	local fixedMin, fixedMax = o.Min, o.Max
	local suffix = o.Suffix or ""

	local r = rowFrame(self, height + 36)
	label(r, o.Name or "Graph", { Size = UDim2.new(0.6, -12, 0, 18), Position = UDim2.fromOffset(12, 6), TextSize = 12 })
	local valLbl = label(r, "--", {
		Size = UDim2.new(0.4, -12, 0, 18),
		Position = UDim2.new(0.6, 0, 0, 6),
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.Code,
		TextSize = 12,
	}, "Accent")
	local canvas = new("Frame", {
		Position = UDim2.fromOffset(10, 28),
		Size = UDim2.new(1, -20, 0, height),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = r,
	}, { BackgroundColor3 = "Background" })
	corner(canvas, 3)
	stroke(canvas)
	for i = 1, 3 do
		new("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, i / 4, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = 0.6,
			Parent = canvas,
		}, { BackgroundColor3 = "Stroke" })
	end
	local rangeHi = label(canvas, "", { Size = UDim2.fromOffset(60, 12), Position = UDim2.fromOffset(4, 2), TextSize = 9, Font = Enum.Font.Code }, "SubText")
	local rangeLo = label(canvas, "", { Size = UDim2.fromOffset(60, 12), Position = UDim2.new(0, 4, 1, -14), TextSize = 9, Font = Enum.Font.Code }, "SubText")

	local data, items = {}, {}
	local function item(i)
		local it = items[i]
		if not it then
			it = new("Frame", {
				BorderSizePixel = 0,
				AnchorPoint = (kind == "Bar") and Vector2.new(0, 1) or Vector2.new(0.5, 0.5),
				Parent = canvas,
			})
			if o.Color then
				it.BackgroundColor3 = o.Color
			else
				bind(it, "BackgroundColor3", "Accent")
			end
			if kind == "Bar" then
				it.BackgroundTransparency = 0.15
			end
			items[i] = it
		end
		return it
	end

	local function render()
		local n = #data
		local w, hgt = canvas.AbsoluteSize.X, canvas.AbsoluteSize.Y
		if n == 0 or w <= 0 or hgt <= 0 then
			return
		end
		local lo, hi = fixedMin, fixedMax
		if lo == nil or hi == nil then
			local mn, mx = math.huge, -math.huge
			for _, x in ipairs(data) do
				mn = math.min(mn, x)
				mx = math.max(mx, x)
			end
			if mx - mn < 1e-6 then
				mx = mn + 1
			end
			local padv = (mx - mn) * 0.1
			lo = fixedMin or (mn - padv)
			hi = fixedMax or (mx + padv)
		end
		rangeHi.Text = string.format("%.0f", hi)
		rangeLo.Text = string.format("%.0f", lo)
		local function yOf(x)
			return hgt - math.clamp((x - lo) / (hi - lo), 0, 1) * hgt
		end
		local offset = maxPts - n
		if kind == "Bar" then
			local slot = w / maxPts
			local bw = math.max(1, slot - 1)
			for i = 1, n do
				local it = item(i)
				local top = yOf(data[i])
				it.Visible = true
				it.Size = UDim2.fromOffset(bw, hgt - top)
				it.Position = UDim2.fromOffset((offset + i - 1) * slot, hgt)
			end
			for i = n + 1, #items do
				items[i].Visible = false
			end
		else
			local step = w / (maxPts - 1)
			for i = 1, n - 1 do
				local x1, y1 = (offset + i - 1) * step, yOf(data[i])
				local x2, y2 = (offset + i) * step, yOf(data[i + 1])
				local dx, dy = x2 - x1, y2 - y1
				local it = item(i)
				it.Visible = true
				it.Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy) + 1, 2)
				it.Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2)
				it.Rotation = math.deg(math.atan2(dy, dx))
			end
			for i = math.max(n, 1), #items do
				items[i].Visible = false
			end
		end
	end
	canvas:GetPropertyChangedSignal("AbsoluteSize"):Connect(render)

	local obj = {}
	function obj:Push(x)
		table.insert(data, x)
		if #data > maxPts then
			table.remove(data, 1)
		end
		valLbl.Text = string.format("%.1f", x) .. suffix
		render()
	end
	function obj:SetData(t)
		data = {}
		for _, x in ipairs(t or {}) do
			table.insert(data, x)
		end
		while #data > maxPts do
			table.remove(data, 1)
		end
		for _, it in ipairs(items) do
			it.Visible = false
		end
		if #data > 0 then
			valLbl.Text = string.format("%.1f", data[#data]) .. suffix
		end
		render()
	end
	function obj:Clear()
		data = {}
		for _, it in ipairs(items) do
			it.Visible = false
		end
		valLbl.Text = "--"
	end
	return obj
end

function Container:AddAvatar(o)
	o = o or {}
	local height = o.Height or 240
	local win = self.Window
	local tab = self.Tab

	local r = new("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		LayoutOrder = nextOrder(self),
		Parent = self.Frame,
	}, { BackgroundColor3 = "SurfaceAlt" })
	corner(r, 4)
	stroke(r)
	local vp = new("ViewportFrame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -34),
		Ambient = Color3.fromRGB(170, 170, 185),
		LightColor = Color3.fromRGB(255, 255, 255),
		LightDirection = Vector3.new(-0.5, -1, -0.8),
		Parent = r,
	})
	local cam = Instance.new("Camera")
	cam.FieldOfView = 32
	cam.Parent = vp
	vp.CurrentCamera = cam

	local status = label(r, "loading avatar...", {
		Size = UDim2.new(1, 0, 1, -34),
		Font = Enum.Font.Code,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
	}, "SubText")
	local nameLbl = label(r, "", {
		Size = UDim2.new(1, -210, 0, 18),
		Position = UDim2.new(0, 12, 1, -28),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	label(r, "drag to rotate / scroll to zoom", {
		Size = UDim2.fromOffset(190, 18),
		Position = UDim2.new(1, -200, 1, -28),
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.Code,
		TextSize = 10,
	}, "SubText")

	local model, center, size = nil, Vector3.new(), Vector3.new(4, 6, 2)
	local yaw, dist, zoom = math.pi, 10, 1
	local auto = o.AutoRotate ~= false
	local speed = o.Speed or 0.7
	local token = 0

	local function placeCamera()
		if not model then
			return
		end
		local pos = center + Vector3.new(math.sin(yaw) * dist * zoom, size.Y * 0.04, math.cos(yaw) * dist * zoom)
		cam.CFrame = CFrame.lookAt(pos, center)
	end

	local function load(who)
		token = token + 1
		local my = token
		status.Visible = true
		status.Text = "loading avatar..."
		nameLbl.Text = ""
		if model then
			model:Destroy()
			model = nil
		end
		task.spawn(function()
			local userId = who
			if type(userId) == "string" then
				local ok, id = pcall(function()
					return Players:GetUserIdFromNameAsync(who)
				end)
				userId = ok and id or nil
			end
			if not userId then
				if my == token then
					status.Text = "user not found"
				end
				return
			end
			local label2 = ""
			if userId == LocalPlayer.UserId then
				label2 = LocalPlayer.DisplayName .. "  (@" .. LocalPlayer.Name .. ")"
			else
				local okN, uname = pcall(function()
					return Players:GetNameFromUserIdAsync(userId)
				end)
				label2 = okN and ("@" .. uname) or tostring(userId)
			end

			local m = nil
			local okD, desc = pcall(function()
				return Players:GetHumanoidDescriptionFromUserId(userId)
			end)
			if okD and desc then
				local okM, built = pcall(function()
					return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
				end)
				if okM then
					m = built
				end
			end
			if not m and userId == LocalPlayer.UserId and LocalPlayer.Character then
				local ch = LocalPlayer.Character
				local was = ch.Archivable
				ch.Archivable = true
				m = ch:Clone()
				ch.Archivable = was
			end
			if my ~= token or not r.Parent then
				if m then
					m:Destroy()
				end
				return
			end
			if not m then
				status.Text = "avatar unavailable"
				return
			end
			for _, d in ipairs(m:GetDescendants()) do
				if d:IsA("BasePart") then
					d.Anchored = true
				elseif d:IsA("LuaSourceContainer") then
					d:Destroy()
				end
			end
			m:PivotTo(CFrame.new(0, 0, 0))
			m.Parent = vp
			local cf, sz = m:GetBoundingBox()
			model, center, size = m, cf.Position, sz
			dist = (sz.Y / 2) / math.tan(math.rad(cam.FieldOfView / 2)) * 1.35
			status.Visible = false
			nameLbl.Text = label2
			placeCamera()
		end)
	end
	load(o.Username or LocalPlayer.UserId)

	-- interacao: arrastar para girar, scroll para zoom
	local hover, dragging = false, false
	r.MouseEnter:Connect(function()
		hover = true
		tab.Frame.ScrollingEnabled = false
	end)
	r.MouseLeave:Connect(function()
		hover = false
		tab.Frame.ScrollingEnabled = true
	end)
	vp.InputBegan:Connect(function(input)
		if isDown(input) then
			dragging = true
			local c
			c = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					c:Disconnect()
				end
			end)
		end
	end)
	win:_conn(UserInputService.InputChanged, function(input)
		if dragging and isMove(input) then
			yaw = yaw - input.Delta.X * 0.012
			placeCamera()
		elseif hover and input.UserInputType == Enum.UserInputType.MouseWheel then
			zoom = math.clamp(zoom - input.Position.Z * 0.08, 0.55, 1.6)
			placeCamera()
		end
	end)
	win:_conn(RunService.RenderStepped, function(dt)
		if auto and not dragging and model and win.Open and tab.Active then
			yaw = yaw + dt * speed
			placeCamera()
		end
	end)

	local obj = {}
	function obj:SetUser(who)
		load(who)
	end
	function obj:SetAutoRotate(b)
		auto = b and true or false
	end
	function obj:SetSpeed(x)
		speed = x
	end
	function obj:ResetView()
		yaw, zoom = math.pi, 1
		placeCamera()
	end
	return obj
end

---------------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------------
local Window = {}
Window.__index = Window

function Window:_conn(signal, fn)
	local c = signal:Connect(fn)
	table.insert(self._conns, c)
	return c
end

function Window:AddTab(name, icon)
	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 30),
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		LayoutOrder = #self.Tabs + 1,
		Parent = self.TabList,
	}, { BackgroundColor3 = "SurfaceAlt" })
	corner(btn, 4)
	local bar = new("Frame", {
		Size = UDim2.fromOffset(3, 14),
		Position = UDim2.new(0, 0, 0.5, -7),
		BorderSizePixel = 0,
		Parent = btn,
	}, { BackgroundColor3 = "Accent" })
	corner(bar, 2)
	if icon then
		new("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.new(0, 10, 0.5, -8),
			Image = icon,
			Parent = btn,
		}, { ImageColor3 = "Text" })
	end
	local txt = label(btn, name or "Tab", {
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.fromOffset(icon and 32 or 12, 0),
		TextSize = 12,
	}, false)

	local page = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = self.Content,
	}, { ScrollBarImageColor3 = "Accent" })
	new("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 14),
		Parent = page,
	})
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })

	local tab = setmetatable({ Window = self, Frame = page, Button = btn, Name = name, Active = false }, Container)
	tab.Tab = tab

	local function render(animate)
		local t = TH()
		apply(btn, animate, { BackgroundTransparency = tab.Active and 0 or 1 })
		apply(bar, animate, { BackgroundTransparency = tab.Active and 0 or 1 })
		apply(txt, animate, { TextColor3 = tab.Active and t.Text or t.SubText })
	end
	tab._render = render
	hook(btn, render)
	btn.MouseEnter:Connect(function()
		if not tab.Active then
			tween(btn, 0.12, { BackgroundTransparency = 0.6 })
		end
	end)
	btn.MouseLeave:Connect(function()
		if not tab.Active then
			tween(btn, 0.12, { BackgroundTransparency = 1 })
		end
	end)
	btn.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	table.insert(self.Tabs, tab)
	if #self.Tabs == 1 then
		self:SelectTab(tab, true)
	end
	return tab
end

function Window:SelectTab(tab, instant)
	for _, t in ipairs(self.Tabs) do
		if t ~= tab and t.Active then
			t.Active = false
			t.Frame.Visible = false
			t._render(true)
		end
	end
	if tab.Active then
		return
	end
	tab.Active = true
	tab.Frame.Visible = true
	tab._render(not instant)
	if not instant then
		tab.Frame.Position = UDim2.fromOffset(0, 12)
		tween(tab.Frame, 0.22, { Position = UDim2.fromOffset(0, 0) })
	end
	self.CurrentTab = tab
end

function Window:Toggle(state)
	if state == nil then
		state = not self.Open
	end
	if state == self.Open then
		return
	end
	self.Open = state
	local target = self._targetScale()
	if state then
		self.Main.Visible = true
		self.Scale.Scale = target * 0.92
		tween(self.Scale, 0.22, { Scale = target }, Enum.EasingStyle.Back)
	else
		tween(self.Scale, 0.15, { Scale = target * 0.92 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.15, function()
			if not self.Open and self.Main.Parent then
				self.Main.Visible = false
			end
		end)
	end
end

function Window:SetScale(n)
	self.UserScale = n
	tween(self.Scale, 0.15, { Scale = self._targetScale() })
end

function Window:Notify(o)
	return Lib:Notify(o)
end

function Window:Destroy()
	for _, c in ipairs(self._conns) do
		c:Disconnect()
	end
	self._conns = {}
	if self.Gui then
		self.Gui:Destroy()
	end
	for i, w in ipairs(Lib.Windows) do
		if w == self then
			table.remove(Lib.Windows, i)
			break
		end
	end
end

-- aba pronta de configuracoes (tema, accent, escala, tecla, watermark)
function Window:AddSettingsTab()
	local tab = self:AddTab("Settings")
	local ui = tab:AddSection("Interface")
	ui:AddDropdown({
		Name = "Theme",
		Options = Lib.ThemeOrder,
		Default = Lib.CurrentTheme,
		Callback = function(v)
			Lib:SetTheme(v)
		end,
	})
	ui:AddColorPicker({
		Name = "Accent color",
		Default = TH().Accent,
		Callback = function(c)
			Lib:SetAccent(c)
		end,
	})
	ui:AddSlider({
		Name = "UI scale",
		Min = 0.7,
		Max = 1.3,
		Default = 1,
		Increment = 0.05,
		Callback = function(v)
			self:SetScale(v)
		end,
	})
	ui:AddKeybind({
		Name = "Menu key",
		Default = self.ToggleKey,
		OnChange = function(k)
			if k then
				self.ToggleKey = k
			end
		end,
	})
	ui:AddToggle({
		Name = "Watermark",
		Default = Lib._wm ~= nil and Lib._wm.Visible,
		Callback = function(v)
			Lib:SetWatermarkVisible(v)
		end,
	})
	local sys = tab:AddSection("System")
	sys:AddButton({
		Name = "Test notification",
		Callback = function()
			Lib:Notify({ Title = "Notification", Content = "Everything is working as expected.", Type = "Success" })
		end,
	})
	sys:AddButton({
		Name = "Unload UI",
		Callback = function()
			Lib:Unload()
		end,
	})
	return tab
end

function Lib:CreateWindow(o)
	o = o or {}
	if o.Theme then
		Lib:SetTheme(o.Theme, true)
	end
	local win = setmetatable({
		_conns = {},
		Tabs = {},
		Open = true,
		ToggleKey = o.ToggleKey or Enum.KeyCode.RightShift,
		UserScale = 1,
		Rebinding = false,
	}, Window)

	local W = (o.Size and o.Size.X.Offset) or 580
	local H = (o.Size and o.Size.Y.Offset) or 400

	local gui = makeGui("Main_" .. tostring(o.Title or "Window"), 100)
	win.Gui = gui
	-- marca interna de build
	local BUILD = { id = "k1", a = "gustaaav0" }
	gui:SetAttribute("_b", BUILD.a .. ":" .. BUILD.id)

	local function targetScale()
		local cam = workspace.CurrentCamera
		local vs = cam and cam.ViewportSize or Vector2.new(1280, 720)
		return math.min(1, vs.X / (W + 30), vs.Y / (H + 70)) * win.UserScale
	end
	win._targetScale = targetScale

	local main = new("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(W, H),
		BorderSizePixel = 0,
		Active = true,
		ClipsDescendants = true,
		Parent = gui,
	}, { BackgroundColor3 = "Background" })
	corner(main, 6)
	stroke(main)
	local scale = new("UIScale", { Scale = targetScale() * 0.92, Parent = main })
	tween(scale, 0.3, { Scale = targetScale() }, Enum.EasingStyle.Back)
	win.Main, win.Scale = main, scale

	-- barra superior
	local top = new("Frame", { Size = UDim2.new(1, 0, 0, 38), BorderSizePixel = 0, Parent = main }, { BackgroundColor3 = "Surface" })
	local accentLine = new("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = top,
	})
	local grad = new("UIGradient", { Parent = accentLine })
	hook(accentLine, function()
		grad.Color = ColorSequence.new(TH().Accent, TH().AccentDark)
	end)
	new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BorderSizePixel = 0, Parent = top }, { BackgroundColor3 = "Stroke" })

	local titleBox = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.6, 0, 1, -2),
		Position = UDim2.fromOffset(14, 2),
		Parent = top,
	})
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		Parent = titleBox,
	})
	label(titleBox, string.upper(o.Title or "KERNEL"), {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
	})
	label(titleBox, o.SubTitle or ("v" .. Lib.Version), {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = Enum.Font.Code,
		TextSize = 11,
	}, "Accent")

	local function topBtn(txt, x, hoverToken)
		local b = new("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.fromOffset(28, 24),
			Position = UDim2.new(1, x, 0.5, 1),
			Text = txt,
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Parent = top,
		}, { TextColor3 = "SubText" })
		b.MouseEnter:Connect(function()
			tween(b, 0.12, { TextColor3 = TH()[hoverToken] })
		end)
		b.MouseLeave:Connect(function()
			tween(b, 0.12, { TextColor3 = TH().SubText })
		end)
		return b
	end
	local closeBtn = topBtn("x", -8, "Error")
	local minBtn = topBtn("-", -38, "Text")
	closeBtn.MouseButton1Click:Connect(function()
		win:Destroy()
	end)
	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		tween(main, 0.25, { Size = UDim2.fromOffset(W, minimized and 38 or H) })
	end)
	draggable(main, top)

	-- corpo
	local body = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 38),
		Size = UDim2.new(1, 0, 1, -38),
		Parent = main,
	})
	local side = new("Frame", { Size = UDim2.new(0, 140, 1, 0), BorderSizePixel = 0, Parent = body }, { BackgroundColor3 = "Surface" })
	new("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BorderSizePixel = 0, Parent = side }, { BackgroundColor3 = "Stroke" })
	local tabList = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.new(1, -16, 1, -68),
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = side,
	})
	new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabList })

	-- cartao do usuario (rosto + nome)
	local card = new("Frame", {
		Size = UDim2.new(1, -16, 0, 44),
		Position = UDim2.new(0, 8, 1, -52),
		BorderSizePixel = 0,
		Parent = side,
	}, { BackgroundColor3 = "SurfaceAlt" })
	corner(card, 5)
	stroke(card)
	local face = new("ImageLabel", {
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.fromOffset(7, 7),
		BorderSizePixel = 0,
		Parent = card,
	}, { BackgroundColor3 = "Background" })
	corner(face, 15)
	label(card, LocalPlayer.DisplayName, {
		Size = UDim2.new(1, -46, 0, 16),
		Position = UDim2.fromOffset(44, 6),
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	label(card, "@" .. LocalPlayer.Name, {
		Size = UDim2.new(1, -46, 0, 14),
		Position = UDim2.fromOffset(44, 22),
		Font = Enum.Font.Code,
		TextSize = 10,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, "SubText")
	task.spawn(function()
		local ok, img = pcall(function()
			return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
		if ok and face.Parent then
			face.Image = img
		end
	end)

	win.TabList = tabList
	win.Content = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(140, 0),
		Size = UDim2.new(1, -140, 1, 0),
		ClipsDescendants = true,
		Parent = body,
	})

	-- tecla para abrir/fechar
	win:_conn(UserInputService.InputBegan, function(input, gp)
		if gp or win.Rebinding then
			return
		end
		if input.KeyCode == win.ToggleKey then
			win:Toggle()
		end
	end)

	-- ajusta ao tamanho da tela
	local cam = workspace.CurrentCamera
	if cam then
		win:_conn(cam:GetPropertyChangedSignal("ViewportSize"), function()
			if win.Open then
				scale.Scale = targetScale()
			end
		end)
	end

	-- botao flutuante para celular
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		local tb = new("TextButton", {
			Size = UDim2.fromOffset(42, 42),
			Position = UDim2.new(0, 12, 0.5, -21),
			Text = "=",
			Font = Enum.Font.GothamBold,
			TextSize = 22,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Parent = gui,
		}, { BackgroundColor3 = "Surface", TextColor3 = "Accent" })
		corner(tb, 8)
		stroke(tb, "Accent")
		draggable(tb, tb)
		tb.MouseButton1Click:Connect(function()
			win:Toggle()
		end)
	end

	if o.Watermark ~= false then
		Lib:CreateWatermark({ Title = o.WatermarkTitle or string.upper(o.Title or "KERNEL") })
	end

	table.insert(Lib.Windows, win)
	return win
end

function Lib:Unload()
	for i = #Lib.Windows, 1, -1 do
		Lib.Windows[i]:Destroy()
	end
	if Lib._wm then
		Lib._wm:Destroy()
	end
	if Lib._notifGui then
		Lib._notifGui:Destroy()
		Lib._notifGui, Lib._notifHolder = nil, nil
	end
	if Lib._step then
		Lib._step:Disconnect()
		Lib._step = nil
	end
end

return Lib
