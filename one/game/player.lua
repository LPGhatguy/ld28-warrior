local player
local core = require("one.core")
local ai = require("one.game.ai")
local sound = require("one.sound")

local function zeroy(a, b)
	return math.min(math.abs(a), math.abs(b))
end

player = {
	shade = {255, 255, 255},
	normal = {255, 255, 255},
	dark = {150, 150, 150},

	character = nil,
	opponent = nil,

	skin = 1,
	ai = false,
	health = 0,
	x = 0,
	y = 0,
	direction = 1,

	anim = "stand",
	anim_frame = 1,
	anim_time = 0,

	moving = false,
	move_target = 0,
	move_time = 0,
	move_height = 0,
	move_speed = 1,

	collided = false,
	hitting = false,

	hit_charging = false,
	hit_charge = 0,
	hit_time = 0,

	alive = true,
	dead_time = 0,

	--METHODS
	start = function(self)
		self.health = self.character.max_health

		self.alive = true
		self.hitting = false
		self.moving = false
		self.collided = false
		self.hit_charging = false

		self:do_anim("stand")
		self.dead_time = 0
		self.hit_time = 0
		self.hit_charge = 0
	end,

	cancel = function(self)
		if (self:can_cancel_hit()) then
			self.hit_charging = false
			self.hit_charge = 0

			return true
		end
	end,

	move = function(self, direction)
		if (not self.moving and not self.hitting and self:can_cancel_hit()) then
			local char = self.character

			self:do_anim("move")

			self.move_time = char.jump_speed
			self.move_speed = self.move_time

			self.move_target = direction * char.jump_length
			self.move_height = char.jump_height
			self.moving = true

			self.hit_charge = 0

			sound:play(self.character.sound_move)
		end
	end,

	hit = function(self, direction)
		if (self.moving and not self.hitting) then
			--self:recovery()
		elseif (self:can_hit()) then
			local char = self.character

			self:do_anim("hit")

			self.move_time = char.hit_speed * #char.anims.hit
			self.move_speed = self.move_time

			self.move_target = direction * self.character.hit_move
			self.move_height = char.hit_height
			self.moving = true
			self.hitting = true
			self.collided = false

			self.hit_charge = 0

			sound:play(self.character.sound_hit)
		end
	end,

	die = function(self)
		self:do_anim("dead")
		self.alive = false
		self.y = 0
		self.move_time = 0
		self.moving = false
		self.hitting = false
		self.hit_charge = 0
		self.health = 0

		sound:play(self.character.sound_die)
	end,

	knockback = function(self, direction)
		local char = self.character

		self:do_anim("move")

		self.move_time = char.jump_speed / 2
		self.move_speed = self.move_time

		self.move_target = direction * self.opponent.character.hit_knockback * char.hit_knockbacked
		self.move_height = char.jump_height
		self.moving = true

		sound:play(self.character.sound_hurt)
	end,

	recovery = function(self)
		local char = self.character

		self:do_anim("stand")
		self.dropping = true

		sound:play(self.character.sound_recover)
	end,

	get_hitbox = function(self)
		local quad = self.character.quads[self.character.anims[self.anim][self.anim_frame]]

		if (quad) then
			local _, _, w, h = quad:getViewport()
			return w, h
		else
			return 0, 0
		end
	end,

	do_anim = function(self, anim)
		self.anim = anim
		self.anim_time = 0
		self.anim_frame = 1
	end,

	can_cancel_hit = function(self)
		return self.hit_charge < self.character.hit_charge_threshold
	end,

	can_hit = function(self)
		return not self.hitting and self.hit_charge > self.character.hit_threshold
	end,

	--LOOP EVENTS
	draw = function(self)
		local scale = core.scale
		local char = self.character
		local quad = char.quads[char.anims[self.anim][self.anim_frame]]

		if (quad) then
			local _, _, qw, qh = quad:getViewport()

			love.graphics.setColor(self.shade)

			if (self.alive) then
				love.graphics.draw(char.images[self.skin], quad, self.x * scale, (124 - qh) * scale + self.y * scale,
					0, scale * self.direction, scale)
			else
				love.graphics.draw(char.images[self.skin], quad, self.x * scale + self.direction * qw * scale,
					(124 - qh) * scale + self.y * scale + qh * scale +
						self.direction * math.min(self.dead_time * char.dead_height * 4, char.dead_height) * scale,
					math.min(self.dead_time * 6, math.pi / 2), scale * self.direction, scale,
					qw, qh)
			end
		end
	end,

	update = function(self, game, delta)
		if (self.alive) then
			if (self.ai) then
				ai:update(self, game, delta)
			end

			local char = self.character

			local anim = char.anims[self.anim]
			self.anim_time = self.anim_time + delta

			if (self.anim_time > anim[0]) then
				self.anim_frame = self.anim_frame + 1
				self.anim_time = 0

				if (self.anim_frame > #anim) then
					self.anim = "stand"
					self.anim_frame = 1
				end
			end

			if (self.dropping) then
				self.y = self.y + delta * self.character.jump_height * 2

				if (self.y >= 0) then
					self.moving = false
					self.hitting = false
					self.collided = false
					self.dropping = false
					self.y = 0

					sound:play(self.character.sound_land)

					self:hit(self.direction)
				end
			elseif (self.moving) then
				local change = math.min(self.move_time, delta)
				local dx = self.move_target * change / self.move_speed
				local t = self.move_time / self.move_speed

				self.y = self.move_height * (t * t - t)
				local target_x = self.x + dx
				local opponent = self.opponent

				local w = self.character.hitbox[1]
				local ow = opponent.character.hitbox[1]
				local sw = game.camera + core.screen_w / core.scale

				if (self.direction == 1) then
					if (target_x + w >= opponent.x - ow) then
						self.x = opponent.x - w - ow
					elseif (target_x + w >= sw) then
						self.x = sw - w
					elseif (target_x <= game.camera) then
						if (opponent.x >= sw) then
							self.x = game.camera
						else
							local change = zeroy(dx, sw - opponent.x)
							self.x = self.x - change
							game.camera = game.camera - change
						end
					else
						self.x = target_x
					end
				else
					if (target_x - w <= opponent.x + ow) then
						self.x = opponent.x + w + ow
					elseif (target_x <= game.camera) then
						self.x = game.camera
					elseif (target_x >= sw) then
						if (opponent.x <= game.camera) then
							self.x = sw
						else
							local change = zeroy(dx, opponent.x - game.camera)
							self.x = self.x + change
							game.camera = game.camera + change
						end
					else
						self.x = target_x
					end
				end

				if (self.move_time <= 0) then
					self.moving = false
					self.hitting = false
					self.collided = false
					self.dropping = false
					self.y = 0

					sound:play(self.character.sound_land)
				end

				self.move_time = self.move_time - delta
			end

			if (self.health <= 0) then
				self:die()
			end
		else
			self.dead_time = self.dead_time + delta
		end
	end
}

return player