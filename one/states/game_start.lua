--[[
CHOOSE YOUR FIGHTER, etc.
]]

local game_start
local play_button
local core = require("one.core")
local button = require("one.ui.button")
local character = require("one.game.character")
local game = require("one.states.game")
local sound = require("one.sound")

local mal, mar

local function round(n)
	return math.floor(n + 0.5)
end

local function back()
	core:set_state("menu")
end

local function play()
	sound:play("beep.ogg")

	if (game_start.multiplayer) then
		game_start.stage = game_start.stage + 0.5
	else
		game_start.stage = game_start.stage + 1
	end

	if (game_start.stage >= 4) then
		core:set_state("game")
	end
end

game_start = {
	buttons = {},
	characters = {},
	multiplayer = false,

	stage = 1,
	selected_characters = {1, 1},
	selected_skins = {1, 1},
	selected_buttons = {"kz", "km"},
	button1 = false,
	button2 = false,
	button1_time = 0,
	button2_time = 0,
	button_max = 0.7,

	color1 = {200, 50, 50},
	color2 = {0, 50, 200},

	flying = false,
	fly_time = 0,

	big_font = core:get_font(),
	little_font = core:get_font(20),

	--METHODS
	friendly_button = function(self, code)
		if (code) then
			if (code:sub(1, 1) == "k") then
				return "keyboard - " .. code:sub(2):gsub(" ", "space")
			elseif (code:sub(1, 1) == "j") then
				return "joystick " .. code:sub(2, 2) .. " - " .. code:sub(3)
			elseif (code:sub(1, 1) == "m") then
				return "mouse " .. code:sub(2)
			end
		else
			return "[none]"
		end
	end,

	draw_char = function(self, num, skin)
		local w, h = core.screen_w, core.screen_h
		local char = self.characters[self.selected_characters[num]]
		local quad = char.quads[char.anims["move"][1]]

		local _, _, qw, qh = quad:getViewport()

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(char.images[skin], quad,
			w * 0.3 - qw * core.scale / 2, h * 0.05 + 150, 0, core.scale, core.scale)

		love.graphics.setFont(self.big_font)
		love.graphics.draw(mal, w * 0.3 - 40 * core.scale, h * 0.05 + 110 * core.scale / 2, 0, 2)
		love.graphics.draw(mar, w * 0.3 + 30 * core.scale, h * 0.05 + 110 * core.scale / 2, 0, 2)
	end,

	button_hint = function(self, num)
		local w, h = core.screen_w, core.screen_h

		love.graphics.setFont(self.little_font)
		love.graphics.printf("(tap " .. self:friendly_button(self.selected_buttons[num]) .. " to switch, hold to confirm)",
			0, h * 0.05 + 90, w, "center")
	end,

	character_info = function(self, num)
		local w, h = core.screen_w, core.screen_h
		love.graphics.setFont(self.big_font)
		love.graphics.printf(self.characters[self.selected_characters[num]].name, w * 0.5, h * 0.3, w * 0.5, "left")

		love.graphics.setFont(self.little_font)
		love.graphics.printf(self.characters[self.selected_characters[num]].bio, w * 0.5, h * 0.3 + 50, w * 0.5, "left")
	end,

	--INIT/DESTROY
	load = function(self, from, multiplayer)
		core:start_playlist({4})

		self.characters = {}
		local char_files = love.filesystem.getDirectoryItems("asset/characters")

		for key, file in pairs(char_files) do
			local char = character:load_from_file("asset/characters/" .. file)

			if (char) then
				table.insert(self.characters, char)
			else
				print("Could not load character", file)
			end
		end

		mal = love.graphics.newImage("asset/images/marrow_left.png")
		mar = love.graphics.newImage("asset/images/marrow_right.png")

		local w, h = core.screen_w, core.screen_h

		back_button = button:new(4, 4, self.little_font:getWidth("Return") + 8, self.little_font:getHeight() + 8, 20)
		back_button.text = "Return"
		back_button.click = back

		self.buttons = {back_button}
		self.button1 = false
		self.button2 = false

		self.multiplayer = multiplayer
		game.player2.ai = not multiplayer

		self.big_font = core:get_font(40)
		self.little_font = core:get_font(20)

		self.selected_buttons[1] = game.buttons[1]
		self.selected_buttons[2] = game.buttons[2]

		self.stage = 1

		core:report("Game start loading from", from)
	end,

	quit = function(self, target)
		if (target == "game") then
			core:start_playlist({2, 3})

			local width = core.screen_w / core.scale

			game.buttons[1] = self.selected_buttons[1]
			game.buttons[2] = self.selected_buttons[2]

			game.player1.character = self.characters[self.selected_characters[1]]
			game.player1.skin = self.selected_skins[1]

			local p2c = self.selected_characters[2]

			if (self.multiplayer) then
				game.player2.character = self.characters[self.selected_characters[2]]
			else
				love.math.random()
				love.math.random()
				p2c = round(love.math.random(1, #self.characters))
				game.player2.character = self.characters[p2c]
			end

			if (self.selected_characters[1] == p2c) then
				game.player2.skin = (self.selected_skins[1] % #game.player1.character.images) + 1
			else
				game.player2.skin = self.selected_skins[2]
			end

			game.score[1] = 0
			game.score[2] = 0
		end

		core:report("Game start quit to", target)
	end,

	--LOOP EVENTS
	draw = function(self)
		local w, h = core.screen_w, core.screen_h
		love.graphics.setFont(self.big_font)
		love.graphics.setColor(255, 255, 255)

		if (self.stage == 1) then
			love.graphics.setColor(self.color1)
			love.graphics.printf("PLAYER 1", 0, h * 0.3, w, "center")

			love.graphics.setColor(255, 255, 255)
			love.graphics.printf("\nPress Your Button!\nHold to confirm!\n\nCurrently: " ..
				self:friendly_button(self.selected_buttons[1]),
				0, h * 0.3, w, "center")
		elseif (self.stage == 1.5) then
			love.graphics.setColor(self.color2)
			love.graphics.printf("PLAYER 2", 0, h * 0.3, w, "center")

			love.graphics.setColor(255, 255, 255)
			love.graphics.printf("\nPress Your Button!\nHold to confirm!\n\nCurrently: " ..
				self:friendly_button(self.selected_buttons[2]),
				0, h * 0.3, w, "center")
		elseif (self.stage == 2) then
			love.graphics.setColor(self.color1)
			love.graphics.printf("PLAYER 1", 0, h * 0.05, w, "center")

			love.graphics.setColor(255, 255, 255)
			love.graphics.printf("\nChoose Your Warrior!", 0, h * 0.05, w, "center")
			
			self:character_info(1)
			self:button_hint(1)
			self:draw_char(1, 1)
		elseif (self.stage == 2.5) then
			love.graphics.setColor(self.color2)
			love.graphics.printf("PLAYER 2", 0, h * 0.05, w, "center")

			love.graphics.setColor(255, 255, 255)
			love.graphics.printf("\nChoose Your Warrior!", 0, h * 0.05, w, "center")
			
			self:character_info(2)
			self:button_hint(2)
			self:draw_char(2, 1)
		elseif (self.stage == 3) then
			love.graphics.setColor(self.color1)
			love.graphics.printf("PLAYER 1", 0, h * 0.05, w, "center")

			love.graphics.setColor(255, 255, 255)
			love.graphics.printf("\nChoose Your Style!", 0, h * 0.05, w, "center")

			self:character_info(1)
			self:button_hint(1)
			self:draw_char(1, self.selected_skins[1])
		elseif (self.stage == 3.5) then
			love.graphics.setColor(self.color2)
			love.graphics.printf("PLAYER 2", 0, h * 0.05, w, "center")

			love.graphics.setColor(255, 255, 255)
			love.graphics.printf("\nChoose Your Style!", 0, h * 0.05, w, "center")
			
			self:character_info(2)
			self:button_hint(2)
			self:draw_char(2, self.selected_skins[2])
		end

		for key, button in pairs(self.buttons) do
			button:draw()
		end
	end,

	update = function(self, delta)
		if (self.flying) then
			self.fly_time = self.fly_time + delta

			if (self.fly_time >= 1) then
				self.flying = false
				self.fly_time = 0
			end
		end

		if (self.button1) then
			self.button1_time = self.button1_time + delta

			if (self.button1_time > self.button_max) then
				self:buttonreleased(self.selected_buttons[1], true)
			end
		end

		if (self.button2) then
			self.button2_time = self.button2_time + delta

			if (self.button2_time > self.button_max) then
				self:buttonreleased(self.selected_buttons[2], true)
			end
		end
	end,

	--USER EVENTS
	mousepressed = function(self, x, y, button)
		for key, button in pairs(self.buttons) do
			if (x > button.x and y > button.y and
			x < button.x + button.w and y < button.y + button.h) then
				button:click()
			end
		end
	end,

	buttonpressed = function(self, button)
		if (self.stage == 1) then
			self.selected_buttons[1] = button
			self.button1 = true
			sound:play("boop.ogg")
		elseif (self.stage == 1.5) then
			if (button ~= self.selected_buttons[1]) then
				self.selected_buttons[2] = button
				self.button2 = true
				sound:play("boop.ogg")
			end
		else
			if (button == self.selected_buttons[1]) then
				self.button1 = true
			elseif (button == self.selected_buttons[2]) then
				self.button2 = true
			end
		end
	end,

	buttonreleased = function(self, button, forced)
		local button1, button2
		local tapped = false

		if (self.selected_buttons[1] == button) then
			button1 = self.button1
			self.button1 = false

			if (not forced) then
				tapped = self.button1_time < self.button_max
			end

			self.button1_time = 0
		elseif (self.selected_buttons[2] == button) then
			button2 = self.button2
			self.button2 = false

			if (not forced) then
				tapped = self.button2_time < self.button_max
			end

			self.button2_time = 0
		end

		local boop = false

		if (self.stage == 1) then
			if (button1 and not tapped) then
				play()
			end
		elseif (self.stage == 1.5) then
			if (button2 and not tapped) then
				play()
			end
		elseif (self.stage == 2 and button1) then
			if (not forced and tapped) then
				self.selected_characters[1] = (self.selected_characters[1] % #self.characters) + 1
				boop = true
			else
				play()
			end

		elseif (self.stage == 2.5 and button2) then
			if (not forced and tapped) then
				self.selected_characters[2] = (self.selected_characters[2] % #self.characters) + 1
				boop = true
			else
				play()
			end

		elseif (self.stage == 3 and button1) then
			if (not forced and tapped) then
				self.selected_skins[1] = (self.selected_skins[1] % #self.characters[self.selected_characters[1]].images) + 1
				boop = true
			else
				play()
			end

		elseif (self.stage == 3.5 and button2) then
			if (not forced and tapped) then
				self.selected_skins[2] = (self.selected_skins[2] % #self.characters[self.selected_characters[2]].images) + 1
				boop = true
			else
				play()
			end
		end

		if (boop) then
			sound:play("boop.ogg")
		end
	end
}

return game_start