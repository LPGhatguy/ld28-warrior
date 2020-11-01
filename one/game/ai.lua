local ai
local util = require("one.util")

ai = {
	aggression = 0.1,
	passiveness = 0.9,
	recklessness = 0.02,
	next_move = 0,
	speed = 0.7,

	update = function(self, player, game, delta)
		if (not game.warming and not game.over) then
			local pw = player.character.hitbox[1]
			local px = player.x
			local ow = player.opponent.character.hitbox[1]
			local ox = player.opponent.x

			if (px - pw * 2.8 <= ox) then
				player.hit_charging = true
				player:hit(-1)
			elseif (px - pw * 3.4 <= ox) then
				player.hit_charging = true

				if (love.math.random() <= self.recklessness) then
					player:hit(-1)
				end
			else
				if (not player:cancel()) then
					player:hit(-1)
				end

				self.next_move = self.next_move - delta

				if (self.next_move <= 0) then
					self.next_move = love.math.random(30, 50) / 100

					local action = love.math.random()
					if (action <= self.passiveness) then
						if (action <= self.aggression and game.arrows[2] == 1) then
							player:move(1)
						elseif (action >= self.aggression and game.arrows[2] == -1) then
							player:move(-1)
						end
					end
				end
			end
		end
	end
}

return ai