class "Parse"
local StringExtensions = require "__shared/Util/StringExtensions"

function Parse:LinearTransform(p_LinearTransform)
	local s_LinearTransformRaw = tostring(p_LinearTransform)
	local s_Split = s_LinearTransformRaw:gsub("%(", ""):gsub("%)", ""):gsub("% ", ","):split(",")

	local s_LinearTransform = LinearTransform(
		Vec3(tonumber(s_Split[1]), tonumber(s_Split[2]), tonumber(s_Split[3])),
		Vec3(tonumber(s_Split[4]), tonumber(s_Split[5]), tonumber(s_Split[6])),
		Vec3(tonumber(s_Split[7]), tonumber(s_Split[8]), tonumber(s_Split[9])),
		Vec3(tonumber(s_Split[10]),tonumber(s_Split[11]),tonumber(s_Split[12]))
	)
	return s_LinearTransform
end



return Parse