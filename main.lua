--[[
MAIN LOOP
run the game, you hag
]]

local core

function love.run()
	success, core = pcall(require, "one.core")

	if (not success) then
		love.errhand("error")
	end

	love.math.setRandomSeed(os.time())

	love.event.pump()

	core:load()
	love.timer.step()

	local delta = 0
	local accumulator = 0
	local frame_time = 1 / 60

	while (true) do
		love.event.pump()
		for e, a, b, c, d in love.event.poll() do
			if e == "quit" then
				if (not core:quit()) then
					love.audio.stop()
					return
				end
			end

			if (core[e]) then
				core[e](core, a, b, c, d)
			end
		end

		if (delta > 0.25) then
			delta = 0.25
		end

		love.timer.step()
		delta = love.timer.getDelta()
		accumulator = accumulator + delta

		while (accumulator > frame_time) do
			core.time = core.time + frame_time
			core:update(frame_time)

			accumulator = accumulator - frame_time
		end

		love.graphics.clear()
		love.graphics.origin()
		core:draw()
		love.graphics.present()

		love.timer.sleep(0.001)
	end
end

local old_hand = love.errhand

function love.errhand(msg)
	msg = tostring(msg)

	if (core and core.quiterr) then
		print(pcall(core.quiterr, core, msg))
	end

	love.mouse.setVisible(true)
	love.mouse.setGrabbed(false)

	for i,v in ipairs(love.joystick.getJoysticks()) do
		v:setVibration()
	end

	love.audio.stop()

	love.graphics.reset()
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setNewFont(14)
	love.graphics.clear()
	love.graphics.origin()

	local trace = debug.traceback()

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, msg.."\n\n")

	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") then
			l = string.gsub(l, "stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

	print(p)

	while (true) do
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			end
			if e == "keypressed" and a == "escape" then
				return
			end
		end

		love.graphics.clear()
		love.graphics.printf(p, 2, 2, love.graphics.getWidth() - 2)
		love.graphics.present()

		love.timer.sleep(0.1)
	end
end