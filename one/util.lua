local util

util = {
	table_copy = function(source, target)
		target = target or {}

		for key, value in pairs(source) do
			if (type(value) == "table") then
				target[key] = util.table_copy(value)
			else
				target[key] = value
			end
		end

		return target
	end,

	table_merge = function(source, target)
		for key, value in pairs(source) do
			if (not target[key]) then
				if (type(value) == "table") then
					target[key] = util.table_copy(value)
				else
					target[key] = value
				end
			end
		end

		return target
	end,

	rgb_interpolate = function(factor, from, to, alpha)
		local ifactor = 1 - factor

		local r = from[1] * factor + to[1] * ifactor
		local g = from[2] * factor + to[2] * ifactor
		local b = from[3] * factor + to[3] * ifactor

		return {r, g, b, alpha}
	end,

	aabb_intersect = function(x1, y1, w1, h1, x2, y2, w2, h2)
		return not (
			y1 + h1 < y2 or
			x1 + w1 < x2 or
			y1 > y2 + h2 or
			x1 > x2 + w2
		)
	end
}

return util