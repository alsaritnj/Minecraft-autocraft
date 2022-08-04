local sides = require("sides")
return
	{
		x = 0, y = 0, z = 0, face = sides.front,
		forward = function()
			print("Robot go forward")
		end,

		back = function()
			print("Robot go back")
		end,

		turnRight = function()
			print("Robot turn right")
		end,

		turnLeft = function()
			print("Robot turn left")
		end,

		turnAround = function()
			print("Robot turn around")
		end,

		select = function(slot)
			print("Robot select slot "..slot)
		end
	}