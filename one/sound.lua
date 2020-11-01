local sound

sound = {
	root = "asset/sounds/",
	loaded = {},
	loaded2 = {},

	load = function(self, names, sort, volume)
		if (names) then
			if (type(names) == "string") then
				if (love.filesystem.exists(self.root .. names)) then
					local source = love.audio.newSource(self.root .. names, sort)
					local source2 = love.audio.newSource(self.root .. names, sort)

					if (volume) then
						source:setVolume(volume)
						source2:setVolume(volume)
					end

					self.loaded[names] = source
					self.loaded2[names] = source2
				else
					print("Failed to load sound", names)
				end
			elseif (type(names) == "table") then
				for key, value in pairs(names) do
					self:load(value, sort, volume)
				end
			end
		end

		return source
	end,

	play = function(self, names)
		if (type(names) == "string") then
			if (self.loaded[names]) then
				if (self.loaded[names]:isStopped()) then
					self.loaded[names]:play()
				elseif (self.loaded2[names]:isStopped()) then
					self.loaded2[names]:play()
				else
					self.loaded[names]:stop()
					self.loaded[names]:play()
				end
			else
				print("Couldn't play sound", names)
			end
		elseif (type(names) == "table") then
			self:play(names[math.random(1, #names)])
		end
	end,

	stop = function(self, names)
		if (type(names) == "string") then
			if (self.loaded[names]) then
				self.loaded[names]:stop()
				self.loaded2[names]:stop()
			end
		elseif (type(names) == "table") then
			for key, value in pairs(names) do
				self:stop(value)
			end
		end
	end,

	is_stopped = function(self, name)
		if (self.loaded[name]) then
			return self.loaded[name]:isStopped() and self.loaded2[name]:isStopped()
		end

		return true
	end
}

return sound