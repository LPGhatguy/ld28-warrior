local button
local core = require("one.core")
local util = require("one.util")

button = {
	border_color = {0, 0, 0},
	color = {60, 60, 60, 220},
	hover_color = {80, 80, 80},
	text_color = {255, 255, 255},

	hover = false,
	t = 0,
	font = nil,
	text = nil,

	x = 0,
	y = 0,
	w = 0,
	h = 0,

	new = function(self, x, y, w, h, t)
		local instance = util.table_copy(self)
		
		instance.x = x or 0
		instance.y = y or 0
		instance.w = w or 0
		instance.h = h or 0
		instance.t = t or 0

		instance.font = core:get_font(t)

		return instance
	end,

	draw = function(self)
		if (self.hover) then
			love.graphics.setColor(self.hover_color)
		else
			love.graphics.setColor(self.color)
		end
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

		love.graphics.setColor(self.border_color)
		love.graphics.setLineWidth(2)
		love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

		if (self.font and self.text) then
			love.graphics.setFont(self.font)
			love.graphics.setColor(self.text_color)

			love.graphics.printf(self.text, self.x, self.y + self.h * 0.5 - self.font:getHeight() / 2, self.w, "center")
		end
	end,

	click = function(self)
		print("Button click (PLACEHOLDER)")
	end
}

return button