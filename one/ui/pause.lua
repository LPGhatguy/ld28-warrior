local pause
local core = require("one.core")
local button = require("one.ui.button")

local function mm()
	core:set_state("menu")
end

pause = {
	buttons = {},
	font = core:get_font(),

	load = function(self)
		local w, h = core.screen_w, core.screen_h

		self.font = core:get_font(h * 0.4)

		local mm_button = button:new(w * 0.3, h * 0.5, w * 0.4, h * 0.1, h * 0.08)
		mm_button.text = "Main Menu"
		mm_button.click = mm

		self.buttons = {mm_button}
	end,

	draw = function(self)
		local w, h = core.screen_w, core.screen_h

		love.graphics.setColor(50, 50, 50, 150)
		love.graphics.rectangle("fill", 0, 0, love.window.getDimensions())

		love.graphics.setColor(255, 255, 255)
		love.graphics.printf("PAUSED", 0, h * 0.8 - self.font:getHeight(), w, "center")

		for key, button in pairs(self.buttons) do
			button:draw()
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
}

return pause