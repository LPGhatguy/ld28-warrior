local character
local util = require("one.util")
local sound = require("one.sound")

character = {
	numerics = {
		"id",

		"max_health",
		"idle_speed",

		"jump_height",
		"jump_length",
		"jump_speed",

		"hit_threshold",
		"hit_charge_threshold",
		"hit_move",
		"hit_height",
		"hit_speed",
		"hit_knockback",
		"hit_knockbacked",

		"dead_height"
	},

	strings = {
		"name",
		"bio"
	},

	sounds = {
		"sound_win",
		"sound_die",
		"sound_hit",
		"sound_hurt",
		"sound_move",
		"sound_land",
		"sound_recover"
	},

	lists = {
		"hitbox"
	},

	id = 0,
	name = "UNKNOWN",
	bio = "No description given.",

	max_health = 5,
	idle_speed = 0.4,

	jump_height = 60,
	jump_length = 30,
	jump_speed = 0.4,

	hit_threshold = 1,
	hit_charge_threshold = 0.2,
	hit_reach = 20,
	hit_move = 10,
	hit_speed = 0.05,
	hit_knockback = 10,
	hit_knockbacked = 1,

	dead_height = 20,

	hitbox = {0, 0},

	anims = {
		["stand"] = {1, 2},
		["hit"] = {3, 4, 3},
		["move"] = {5},
		["dead"] = {5}
	},
	quads = {},
	image = nil,
	images = {},

	--METHODS
	load_from_file = function(self, filename)
		self = util.table_copy(self)

		local quad_buffer = {}
		local data = {}

		self.quads = {}
		
		for line in love.filesystem.lines(filename) do
			line = line:match("^([^#]+)#?")

			if (line) then
				if (line:sub(1, 1) == "@") then
					local x, y, w, h = line:match("([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+)")

					if (x and y and w and h) then
						table.insert(quad_buffer, {tonumber(x), tonumber(y), tonumber(w), tonumber(h)})
					end
				else
					local key, value = line:match("([^=]+)=([^#]+)")
					if (key and value) then
						key = key:gsub("%s", "")
						data[key] = value
					end
				end
			end
		end

		self.images = {}
		local image_list = {}
		if (data["images"]) then
			for path in data.images:gmatch("[^,]+") do
				table.insert(image_list, path)
			end
		else
			image_list = {"error.png"}
		end

		for index, path in next, image_list do
			path = "asset/images/" .. path
			if (love.filesystem.exists(path)) then
				table.insert(self.images, love.graphics.newImage(path))
			else
				print("Couldn't load image", path, "for", data.name or self.name)
			end
		end

		if (not self.images[1]) then
			self.images[1] = love.graphics.newImage("asset/images/error.png")
		end

		local reference = self.images[1]

		for index, quad in next, quad_buffer do
			table.insert(self.quads, love.graphics.newQuad(quad[1], quad[2], quad[3], quad[4], reference:getDimensions()))
		end

		for index, key in pairs(self.numerics) do
			self:setn(data, key)
		end

		for index, key in pairs(self.lists) do
			self:setl(data, key)
		end

		for index, key in pairs(self.strings) do
			self:sets(data, key)
		end

		for index, key in pairs(self.sounds) do
			self:setsl(data, key)

			if (self[key]) then
				sound:load(self[key], "static")
			end
		end

		for key in pairs(self.anims) do
			self:seta(data, key)
		end

		self.anims.move[0] = self.jump_speed
		self.anims.hit[0] = self.hit_speed
		self.anims.stand[0] = self.idle_speed

		return self
	end,

	setn = function(self, data, key)
		self[key] = tonumber(data[key]) or self[key]
	end,

	seta = function(self, data, key)
		if (data[key]) then
			self.anims[key] = {}

			for value in data[key]:gmatch("(%d+)") do
				table.insert(self.anims[key], tonumber(value) or 1)
			end
		end
	end,

	sets = function(self, data, key)
		if (data[key]) then
			self[key] = data[key]:gsub("/n", "\n")
		end
	end,

	setsl = function(self, data, key)
		if (data[key]) then
			self[key] = {}

			for value in data[key]:gmatch("([^,]+)") do
				table.insert(self[key], value)
			end
		end
	end,

	setl = function(self, data, key)
		if (data[key]) then
			self[key] = {}

			for value in data[key]:gmatch("(%d+)") do
				table.insert(self[key], tonumber(value) or 0)
			end
		end
	end,
}

return character