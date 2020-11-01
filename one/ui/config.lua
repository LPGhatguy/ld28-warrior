local config
local core = require("one.core")
local button = require("one.ui.button")

local min_width = 800
local modes = {}
local mode_index = 1
local mode = {}
local fullscreen = true
local vsync = true
local full_button
local v_button

local function toggle_fullscreen()
	fullscreen = not fullscreen
	full_button.hover = fullscreen
end

local function toggle_vsync()
	vsync = not vsync
	v_button.hover = vsync
end

local function cycler(direction)
	return function()
		mode_index = mode_index + direction

		if (mode_index > #modes) then
			mode_index = 1
		elseif (mode_index < 1) then
			mode_index = #modes
		end

		mode = modes[mode_index]
	end
end

local function okay(self, menu)
	love.window.setMode(mode.width, mode.height, {
		fullscreen = fullscreen,
		vsync = vsync,
		fullscreentype = "desktop"
	})

	core:resize(love.window.getDimensions())

	menu.configging = false
end

config = {
	buttons = {},
	big_font = core:get_font(30),
	small_font = core:get_font(20),

	load = function(self)
		local w, h = core.screen_w, core.screen_h

		modes = love.window.getFullscreenModes()

		for key, value in pairs(modes) do
			if (value.width < min_width) then
				modes[key] = nil
			end
		end

		table.sort(modes, function(a, b)
			return a.width * a.height < b.width * b.height
		end)

		mode = modes[mode_index]

		local resr = button:new(w * 0.6 + 70, h * 0.3, 20, 20, 20)
		resr.text = ">"
		resr.click = cycler(1)

		local resl = button:new(w * 0.6 - 100, h * 0.3, 20, 20, 20)
		resl.text = "<"
		resl.click = cycler(-1)

		full_button = button:new(w * 0.6 - 100, h * 0.3 + 30, 20, 20, h * 0.08)
		full_button.hover_color = {200, 200, 200}
		full_button.click = toggle_fullscreen
		full_button.hover = fullscreen

		v_button = button:new(w * 0.6 - 100, h * 0.3 + 60, 20, 20, h * 0.08)
		v_button.hover_color = {200, 200, 200}
		v_button.click = toggle_vsync
		v_button.hover = vsync

		local okay_button = button:new(w * 0.5 - self.small_font:getWidth("Okay") / 2, h * 0.3 + 90,
			self.small_font:getWidth("Okay") + 8, self.small_font:getHeight() + 8, 20)
		okay_button.text = "Okay"
		okay_button.click = okay

		self.buttons = {okay_button, resr, resl, full_button, v_button}
	end,

	draw = function(self)
		local w, h = core.screen_w, core.screen_h

		love.graphics.setColor(80, 80, 80, 220)
		love.graphics.rectangle("fill", w * 0.2, h * 0.2, w * 0.6, 220)

		love.graphics.setColor(0, 0, 0, 220)
		love.graphics.setLineWidth(4)
		love.graphics.rectangle("line", w * 0.2, h * 0.2, w * 0.6, 220)

		love.graphics.setFont(self.big_font)
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf("Configuration", w * 0.2, h * 0.2 + 4, w * 0.6, "center")

		love.graphics.setFont(self.small_font)
		love.graphics.printf("Resolution", w * 0.2, h * 0.3, w * 0.4 - 108, "right")
		if (mode.width) then
			love.graphics.printf(mode.width .. "x" .. mode.height, w * 0.6 - 80, h * 0.3, 160, "center")
		end

		love.graphics.printf("Fullscreen", w * 0.2, h * 0.3 + 30, w * 0.4 - 108, "right")
		love.graphics.printf("Vsync", w * 0.2, h * 0.3 + 60, w * 0.4 - 108, "right")

		for key, button in pairs(self.buttons) do
			button:draw()
		end
	end,

	mousepressed = function(self, menu, x, y, button)
		for key, button in pairs(self.buttons) do
			if (x > button.x and y > button.y and
			x < button.x + button.w and y < button.y + button.h) then
				button:click(menu)
			end
		end
	end
}

return config