local background
local core = require("one.core")

background = {
	load = function(self)
		self.image = love.graphics.newImage("asset/images/background1.png")
		self:scale()
	end,

	scale = function(self)
		core.scale = core.screen_h / self.image:getHeight()
	end,

	draw = function(self, position)
		position = position or 0

		local iw, ih = self.image:getDimensions()
		local scale = core.scale
		local mw = iw * scale

		local base = math.floor(position / mw) * mw

		if (base ~= base) then --NaN result
			base = 0
		end

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.image, base, 0, 0, scale)
		love.graphics.draw(self.image, base - mw, 0, 0, scale)
		love.graphics.draw(self.image, base + mw, 0, 0, scale)
	end
}

return background