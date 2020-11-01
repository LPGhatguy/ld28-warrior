--[[
GAME CORE
be the core of ALL the things!
]]

local core
local sound = require("one.sound")

core = {
	--CONSTANTS
	report_enabled = true,

	--VARIABLES
	fonts = {},
	music = {"engarde-1.ogg", "engarde-2.ogg", "engarde-3.ogg", "engarde-4.ogg"},
	sounds = {
		"announcer_fight.ogg",
		"beep.ogg",
		"boop.ogg"
	},
	current_music = 1,
	playlist = {},
	time = 0,
	states = {},
	state = nil,
	screen_w = 0,
	screen_h = 0,
	scale = 1,

	--METHODS
	set_state = function(self, name, ...)
		local current = self.states[self.state]

		if (current and current.quit) then
			current:quit(name, ...)
		end

		local old_name = self.state
		self.state = name

		current = self.states[self.state]

		if (current and current.load) then
			current:load(old_name, ...)
		end
	end,

	call_state = function(self, method, ...)
		local state = self.states[self.state]

		if (state and state[method]) then
			return state[method](state, ...)
		end
	end,

	report = function(self, ...)
		if (self.report_enabled) then
			print(...)
		end
	end,

	get_font = function(self, size)
		size = size or 16

		if (self.fonts[size]) then
			return self.fonts[size]
		else
			local font = love.graphics.newFont(size)
			self.fonts[size] = font

			return font
		end
	end,

	start_playlist = function(self, playlist)
		sound:stop(self.music)

		self.playlist = playlist
		self.current_music = 1

		sound:play(self.music[playlist[1]])
	end,

	--INIT AND DESTRUCT
	load = function(self)
		self.screen_w, self.screen_h = love.window.getDimensions()
		love.graphics.setDefaultFilter("nearest", "nearest")

		self.states = {
			game = require("one.states.game"),
			game_start = require("one.states.game_start"),
			menu = require("one.states.menu")
		}

		sound:load(self.music, "stream", 0.7)

		for key, value in pairs(self.sounds) do
			sound:load(value, "static")
		end

		self:set_state("menu")
	end,

	quit = function(self)
		print("Game closed successfully!")
	end,

	quiterr = function(self)
		local state = self.states[self.state]

		if (state and state.quiterr) then
			print(pcall(state.quiterr, state))
		end

		print("Game closed with an error!")
	end,

	--WINDOW
	resize = function(self, w, h)
		self.screen_w = w or love.window.getWidth()
		self.screen_h = h or love.window.getHeight()

		self:call_state("quit")
		self:call_state("load")

		self:call_state("resize", w, h)
	end,

	--LOOP EVENTS
	update = function(self, delta)
		local name = self.music[self.playlist[self.current_music]]

		if (sound:is_stopped(name)) then
			self.current_music = (self.current_music % #self.playlist) + 1
			sound:play(self.music[self.playlist[self.current_music]])
		end

		self:call_state("update", delta)
	end,

	draw = function(self)
		self:call_state("draw")
	end,

	--USER EVENTS
	mousepressed = function(self, x, y, button)
		self:call_state("buttonpressed", "m" .. button)
		self:call_state("mousepressed", x, y, button)
	end,

	mousereleased = function(self, x, y, button)
		self:call_state("buttonreleased", "m" .. button)
		self:call_state("mousereleased", x, y, button)
	end,

	keypressed = function(self, key)
		if (key == "f4" and love.keyboard.isDown("lalt", "ralt")) then
			love.event.push("quit")
		end

		self:call_state("keypressed", key)
		self:call_state("buttonpressed", "k" .. key)
	end,

	keyreleased = function(self, key)
		self:call_state("keyreleased", key)
		self:call_state("buttonreleased", "k" .. key)
	end,

	joystickpressed = function(self, joystick, button)
		self:call_state("joystickpressed", joystick, button)
		self:call_state("buttonpressed", "j" .. joystick:getID() .. button)
	end,

	joystickreleased = function(self, joystick, button)
		self:call_state("joystickreleased", joystick, button)
		self:call_state("buttonreleased", "j" .. joystick:getID() .. button)
	end
}

return core