local menu
local core = require("one.core")
local button = require("one.ui.button")
local background = require("one.game.background")
local about_menu = require("one.ui.about")
local config_menu = require("one.ui.config")
local sound = require("one.sound")

local web_url = "http://www.lpghatguy.com/ld/28"
local game_name = "WARRIOR"

local function round(n)
	return math.floor(n + 0.5)
end

local function quit()
	love.event.push("quit")
end

local function play()
	core:set_state("game_start")
end

local function play_multi()
	core:set_state("game_start", true)
end

local function about()
	about_menu.position = 0
	menu.aboutting = true
end

local function config()
	menu.configging = true
end

local function website()
	if (love._os == "Windows") then
		os.execute("start " .. web_url)
	elseif (love._os == "OS X") then
		os.execute("open " .. web_url)
	elseif (love._os == "Linux") then
		os.execute("xdg-open " .. web_url)
	end
end

menu = {
	time = 0,
	aboutting = false,
	configging = false,
	title_font = core:get_font(),
	buttons = {},

	--INIT / DESTRUCT
	load = function(self, source)
		core:start_playlist({1})

		local w, h = core.screen_w, core.screen_h
		local font_size = h * 0.06

		local play_button = button:new(w * 0.6, h * 0.38, w * 0.3, h * 0.1, font_size)
		play_button.text = "Single Player"
		play_button.click = play

		local play_multi_button = button:new(w * 0.6, h * 0.5, w * 0.3, h * 0.1, font_size)
		play_multi_button.text = "Multiplayer"
		play_multi_button.click = play_multi

		local about_button = button:new(w * 0.6, h * 0.62, w * 0.3, h * 0.1, font_size)
		about_button.text = "About Game"
		about_button.click = about

		local config_button = button:new(w * 0.6, h * 0.74, w * 0.3, h * 0.1, font_size)
		config_button.text = "Settings"
		config_button.click = config

		local quit_button = button:new(w * 0.6, h * 0.86, w * 0.3, h * 0.1, font_size)
		quit_button.text = "Quit"
		quit_button.click = quit

		self.buttons = {play_button, play_multi_button, about_button, config_button, quit_button}

		background:load()
		self.time = math.random(-100, 100)

		self.title_font = core:get_font(160)

		config_menu:load()

		core:report("Main menu loaded from source", source)
	end,

	quit = function(self, target)
		self.buttons = {}
		core:report("Main menu quit to", target)
	end,

	quiterr = function(self)
	end,

	--EVENTS
	update = function(self, delta)
		self.time = self.time + delta
	end,

	draw = function(self)
		love.graphics.translate(round(-self.time * 120), 0)
		background:draw(self.time * 120)

		love.graphics.origin()
		love.graphics.setFont(self.title_font)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(game_name, 12, 12)

		love.graphics.setColor(0, 0, 0)
		love.graphics.print(game_name, 14, 14)

		for key, button in pairs(self.buttons) do
			button:draw()
		end

		if (self.aboutting) then
			about_menu:draw()
		elseif (self.configging) then
			config_menu:draw()
		end
	end,

	buttonpressed = function(self, button)
		if (button:sub(1, 1) ~= "m") then
			local fall = true

			if (self.aboutting) then
				if (button == "kdown") then
					about_menu.position = math.min(about_menu.position + 10, about_menu:get_height())
					fall = false
				elseif (button == "kup") then
					about_menu.position = math.max(about_menu.position - 10, 0)
					fall = false
				end
			end

			if (fall) then
				self.aboutting = false
			end
		end
	end,

	mousepressed = function(self, x, y, button)
		if (button == "l") then
			local buttoned = false

			if (self.configging) then
				config_menu:mousepressed(self, x, y, button)
			else
				if (not self.aboutting) then
					for key, button in pairs(self.buttons) do
						if (x > button.x and y > button.y and
						x < button.x + button.w and y < button.y + button.h) then
							button:click()
							buttoned = true
						end
					end
				end
			end

			if (not buttoned) then
				self.aboutting = false
			end
		elseif (self.aboutting) then
			if (button == "wd") then
				about_menu.position = math.min(about_menu.position + 10, about_menu:get_height())
			elseif (button == "wu") then
				about_menu.position = math.max(about_menu.position - 10, 0)
			end
		end
	end
}

return menu