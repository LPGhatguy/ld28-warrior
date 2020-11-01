local ui
local core = require("one.core")
local util = require("one.util")
local ar, al
local lg = love.graphics

ui = {
	name_font = core:get_font(),
	highlight_font = core:get_font(),
	good = {50, 200, 50},
	bad = {255, 0, 0},

	load = function(self, game)
		self.name_font = core:get_font(40)
		self.highlight_font = core:get_font(45)

		ar = love.graphics.newImage("asset/images/arrow_right.png")
		al = love.graphics.newImage("asset/images/arrow_left.png")
	end,

	draw = function(self, game)
		local w, h = core.screen_w, core.screen_h
		local hw = w / 2

		--Player names
		local p1 = game.player1.character.name
		local p2 = game.player2.character.name
		local p1w = self.name_font:getWidth(p1)
		local p2w = self.name_font:getWidth(p2)
		local fh = self.name_font:getHeight()

		--Boxing
		love.graphics.setColor(50, 50, 50, 180)
		--Player1
		love.graphics.rectangle("fill", 0, 50, p1w + 4, fh + 2)
		love.graphics.polygon("fill", p1w + 4, 52 + fh, p1w + 44, 50, p1w + 4, 50)
		--Player2
		love.graphics.rectangle("fill", w - p2w - 4, 50, p2w + 4, fh + 2)
		love.graphics.polygon("fill", w - p2w - 4, fh + 52, w - p2w - 44, 50, w - p2w - 4, 50)

		--Lines
		love.graphics.setColor(0, 0, 0)
		--Player1
		love.graphics.line(0, 52 + fh, p1w + 4, 52 + fh)
		love.graphics.line(p1w + 4, 52 + fh, p1w + 44, 50)
		--Player2
		love.graphics.line(w, 52 + fh, w - p2w - 4, 52 + fh)
		love.graphics.line(w - p2w - 4, 52 + fh, w - p2w - 44, 50)

		--Text
		lg.setFont(self.name_font)
		lg.setColor(255, 255, 255)
		lg.printf(p1, 4, 50, w)
		lg.printf(p2, 0, 50, w - 4, "right")

		--Player arrows
		local a1 = game.arrows[1]
		local a2 = game.arrows[2]

		lg.setColor(255, 255, 255)
		lg.draw((a1 == 1) and ar or al, 8, h - 72, 0, 4)
		lg.draw((a2 == 1) and ar or al, w - 72, h - 72, 0, 4)

		--Player health
		local f1 = game.player1.health / game.player1.character.max_health
		local f2 = game.player2.health / game.player2.character.max_health

		lg.setColor(50, 50, 50, 100)
		lg.rectangle("fill", 0, 0, w / 2 - 40, 48)
		lg.rectangle("fill", w, 0, -w / 2 - 40, 48)

		lg.setColor(util.rgb_interpolate(f1, self.good, self.bad, 200))
		lg.rectangle("fill", 0, 0, f1 * (w / 2 - 40), 48)

		lg.setColor(util.rgb_interpolate(f2, self.good, self.bad, 200))
		lg.rectangle("fill", w, 0, -f2 * (w / 2 - 40), 48)

		--Player charge
		local c1 = math.min(game.player1.hit_charge / game.player1.character.hit_threshold, 1)
		local c2 = math.min(game.player2.hit_charge / game.player2.character.hit_threshold, 1)
		local a1 = (c1 == 1) and 255 or 150
		local a2 = (c2 == 1) and 255 or 150

		lg.setColor(50, 50, 50, 100)
		lg.rectangle("fill", w / 2 - 140, 50, 100, 30)
		lg.rectangle("fill", w / 2 + 140, 50, -100, 30)

		lg.setColor(util.rgb_interpolate(c1, self.good, self.bad, a1))
		lg.rectangle("fill", w / 2 - 140, 50, 100 * c1, 30)

		lg.setColor(util.rgb_interpolate(c2, self.good, self.bad, a2))
		lg.rectangle("fill", w / 2 + 140, 50, -100 * c2, 30)

		lg.setColor(0, 0, 0)
		lg.rectangle("line", w / 2 - 140, 50, 100, 30)
		lg.rectangle("line", w / 2 + 140, 50, -100, 30)

		--Round time
		lg.setColor(30, 50, 70, 200)
		lg.rectangle("fill", hw - 40, 0, 80, 50)

		lg.setColor(0, 0, 0)
		lg.line(hw - 40, 0, hw - 40, 50)
		lg.line(hw + 40, 0, hw + 40, 50)

		lg.setFont(self.highlight_font)
		lg.setColor(200, 50, 50)
		lg.printf(math.ceil(game.round_time), 0, 2, w, "center")

		lg.setFont(self.name_font)
		lg.setColor(255, 255, 255)
		lg.printf(math.ceil(game.round_time), 0, 4, w, "center")

		--Score
		lg.setLineWidth(1)
		for count = 1, game.max_score do
			local c1 = w / 2 - 40 - 16 * count
			local c2 = w / 2 + 40 + 16 * count

			if (count <= game.score[1]) then
				lg.setColor(255, 215, 0)
			else
				lg.setColor(100, 100, 100)
			end
			lg.circle("fill", c1, 90, 7, 10)

			if (count <= game.score[2]) then
				lg.setColor(255, 215, 0)
			else
				lg.setColor(100, 100, 100)
			end
			lg.circle("fill", c2, 90, 7, 10)

			lg.setColor(0, 0, 0)
			lg.circle("line", c1, 90, 7, 10)
			lg.circle("line", c2, 90, 7, 10)
		end

		--Divider line
		lg.setColor(0, 0, 0)
		lg.setLineWidth(4)
		lg.line(0, 50, w, 50)
	end
}

return ui