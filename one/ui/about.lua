local about
local core = require("one.core")

local text = [[
Produced in 72 hours for the 28th Ludum Dare Game Jam

Code - Lucien Greathouse
Art - Cassie Scheirer

HOW TO PLAY
(scroll wheel or arrow keys to scroll)

In this game, you have one button and one button only. You can pick this button and it can be anything, from a mouse click, to a keyboard key, to a button on your game controller.

Tap your button to move in the direction of the arrow at your bottom corner of the screen. This arrow moves randomly, so watch it carefully!

Hold your button to charge your attack meter, which is below your health. When the meter is full, release your button to attack.

Each round lasts 90 seconds and the first player to three points wins! Good luck!
]]

about = {
	position = 0,
	font = core:get_font(20),

	get_height = function(self)
		local _, count = text:gsub("\n", "\n")
		return (self.font:getHeight() * count)
	end,

	draw = function(self)
		local w, h = core.screen_w, core.screen_h

		love.graphics.setColor(80, 80, 80, 220)
		love.graphics.rectangle("fill", w * 0.2, h * 0.2, w * 0.6, h * 0.6)

		love.graphics.setColor(0, 0, 0, 220)
		love.graphics.setLineWidth(4)
		love.graphics.rectangle("line", w * 0.2, h * 0.2, w * 0.6, h * 0.6)

		love.graphics.setScissor(w * 0.2, h * 0.2, w * 0.6, h * 0.6 - 4)
		love.graphics.setFont(self.font)
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf(text, w * 0.2, h * 0.2 + 4 - self.position, w * 0.6, "center")

		love.graphics.setScissor()
	end
}

return about