local game
local core = require("one.core")
local util = require("one.util")
local sound = require("one.sound")
local player = require("one.game.player")

local function round(n)
	return math.floor(n + 0.5)
end

game = {
	pause_menu = require("one.ui.pause"),
	background = require("one.game.background"),
	ui = require("one.ui.game_ui"),

	time = 0,
	camera = 0,
	paused = false,
	round_time = 0,

	matched = false,

	over = false,
	over_time = 0,
	over_total = 4,

	warming = true,
	warmup_time = 0,
	warmup_total = 3,

	score = {0, 0},
	max_score = 3,

	arrows = {1, -1},
	arrow_times = {1, 1},
	arrow_pulse = 2,

	player1 = util.table_copy(player),
	player2 = util.table_copy(player),

	buttons = {"kz", "km"},
	button1 = false,
	button2 = false,

	--METHODS
	cycle_arrow = function(self, index)
		self.arrows[index] = (self.arrows[index] == 1) and -1 or 1

		self.arrow_times[index] = love.math.random(1, 3)
	end,

	check_match = function(self)
		if (self.score[1] >= self.max_score) then
			self.matched = true
			print("Player 1 wins match")
		elseif (self.score[2] >= self.max_score) then
			self.matched = true
			print("Player 2 wins match")
		end
	end,

	--INIT / DESTRUCT
	load = function(self, source, series)
		self.pause_menu:load()
		self.paused = false

		self.over = false
		self.matched = false
		self.over_time = 0

		self.button1 = false
		self.button2 = false

		self.warming = true
		self.warmup_time = 0

		self.ui:load(self)
		self.background:load()

		self.player1.opponent = self.player2
		self.player2.opponent = self.player1

		self.round_time = 90
		self.camera = love.math.random(-1000, 1000)

		self.player1.x = self.camera + core.screen_w * 0.05 / core.scale
		self.player2.x = self.camera + core.screen_w * 0.9 / core.scale

		self.player2.direction = -1

		self.player1:start()
		self.player2:start()

		core:report("Game loaded from", source)
	end,

	quit = function(self, target)
		core:report("Game quitting to", target)
	end,

	quiterr = function(self)
	end,

	--EVENTS
	draw = function(self)
		love.graphics.translate(round(-core.scale * self.camera), 0)
		self.background:draw(self.camera)
		self.player1:draw()
		self.player2:draw()

		love.graphics.origin()
		self.ui:draw(self)

		if (self.warmup_time >= self.warmup_total and self.warmup_time <= self.warmup_total + 1) then
			love.graphics.setFont(core:get_font(100))
			love.graphics.setColor(0, 0, 0)
			love.graphics.printf("FIGHT", 2, 92, core.screen_w, "center")

			love.graphics.setColor(200, 50, 50)
			love.graphics.printf("FIGHT", 0, 90, core.screen_w, "center")
		end

		if (self.matched) then
			love.graphics.setColor(0, 0, 0, math.min(math.max(self.over_time - 2, 0) * 127.5, 255))
			love.graphics.rectangle("fill", 0, 0, core.screen_w, core.screen_h)
		end

		if (self.paused) then
			self.pause_menu:draw()
		end
	end,

	update = function(self, delta)
		if (not self.paused) then
			local p1 = self.player1
			local p2 = self.player2
			local c1 = p1.character
			local c2 = p2.character

			p1:update(self, delta)
			p2:update(self, delta)

			self.warmup_time = self.warmup_time + delta

			if (self.warming) then
				if (self.warmup_time >= self.warmup_total) then
					self.warming = false
					sound:play("announcer_fight.ogg")
				end
			else
				self.time = self.time + delta

				if (self.over) then
					self.over_time = self.over_time + delta

					if (self.over_time >= self.over_total) then
						if (self.matched) then
							core:set_state("menu")
						else
							self.over = false
							self:load("game", true)
						end
					end
				else
					self.arrow_times[1] = self.arrow_times[1] - delta
					self.arrow_times[2] = self.arrow_times[2] - delta
					self.round_time = self.round_time - delta

					if (self.arrow_times[1] <= 0) then
						self:cycle_arrow(1)
					end

					if (self.arrow_times[2] <= 0) then
						self:cycle_arrow(2)
					end

					if (self.button1 or p1.hit_charging) then
						p1.hit_charge = p1.hit_charge + delta
					end

					if (self.button2 or p2.hit_charging) then
						p2.hit_charge = p2.hit_charge + delta
					end
				end

				if (not self.over and not self.matched and (self.round_time < 0 or not p1.alive or not p2.alive)) then
					self.over = true
					self.round_time = 0
					self.over_time = 0

					if (p1.alive and not p2.alive) then
						self.score[1] = self.score[1] + 1
						print("Player 1 wins")
						sound:play(self.player1.character.sound_win)
					elseif (p2.alive and not p1.alive) then
						self.score[2] = self.score[2] + 1
						print("Player 2 wins")
						sound:play(self.player2.character.sound_win)
					else
						print("Player 1", p1.alive)
						print("Player 2", p2.alive)
					end

					self:check_match()
				end

				local r1w, r1h = p1:get_hitbox()
				local r2w, r2h = p2:get_hitbox()

				--check collisions
				if (self.player1.hitting and not self.player1.collided) then
					if (util.aabb_intersect(p1.x, p1.y, r1w, r1h, p2.x - c2.hitbox[1], p2.y - c2.hitbox[2], c2.hitbox[1], c2.hitbox[2])) then
						self.player1.collided = true
						self.player2.dropping = false
						self.player2.moving = false
						self.player2.health = self.player2.health - 1
						self.player2:knockback(1)
					end
				end

				if (self.player2.hitting and not self.player2.collided) then
					if (util.aabb_intersect(p1.x, p1.y, c1.hitbox[1], c1.hitbox[2], p2.x - r2w, p2.y, r2w, r2h)) then
						self.player2.collided = true
						self.player1.dropping = false
						self.player1.moving = false
						self.player1.health = self.player1.health - 1
						self.player1:knockback(-1)
					end
				end
			end
		end
	end,

	--INPUT EVENTS
	mousepressed = function(self, x, y, button)
		if (self.paused) then
			self.pause_menu:mousepressed(x, y, button)
		end

		if (button == "m") then
			print("M!")
			self.player1:die()
		end
	end,

	keypressed = function(self, key)
		if (key == "escape") then
			self.paused = not self.paused
		end
	end,

	buttonpressed = function(self, button)
		if (not self.warming) then
			if (not self.player1.ai and button == self.buttons[1]) then
				self.button1 = true
			elseif (not self.player2.ai and button == self.buttons[2]) then
				self.button2 = true
			end
		end
	end,

	buttonreleased = function(self, button)
		if (not self.over and not self.warming) then
			if (not self.player1.ai and button == self.buttons[1]) then
				if (self.player1:can_cancel_hit()) then
					self.player1:move(self.arrows[1])
				elseif (self.player1:can_hit()) then
					if (self.player1.moving) then
						self.player1:recovery()
					else
						self.player1:hit(1)
					end
				end

				self.button1 = false
				self.player1.hit_charge = 0
			elseif (not self.player2.ai and button == self.buttons[2]) then
				if (self.player2:can_cancel_hit()) then
					self.player2:move(self.arrows[2])
				elseif (self.player2:can_hit()) then
					if (self.player2.moving) then
						self.player2:recovery()
					else
						self.player2:hit(-1)
					end
				end

				self.button2 = false
				self.player2.hit_charge = 0
			end
		end
	end
}

return game