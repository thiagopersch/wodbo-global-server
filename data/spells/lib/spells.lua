--Waves
AREA_WAVE4 = {
	{ 1, 1, 1, 1, 1 },
	{ 0, 1, 1, 1, 0 },
	{ 0, 1, 1, 1, 0 },
	{ 0, 0, 3, 0, 0 }
}

AREA_SQUAREWAVE5 = {
	{ 1, 1, 1 },
	{ 1, 1, 1 },
	{ 1, 1, 1 },
	{ 0, 1, 0 },
	{ 0, 3, 0 }
}

AREA_WAVE5 = {
	{ 0, 1, 1, 1, 0 },
	{ 1, 1, 1, 1, 1 },
	{ 0, 1, 1, 1, 0 },
	{ 0, 0, 1, 0, 0 },
	{ 0, 0, 3, 0, 0 }
}

--Diagonal waves
AREADIAGONAL_WAVE4 = {
	{ 0, 0, 0, 0, 1, 0 },
	{ 0, 0, 0, 1, 1, 0 },
	{ 0, 0, 1, 1, 1, 0 },
	{ 0, 1, 1, 1, 1, 0 },
	{ 1, 1, 1, 1, 1, 0 },
	{ 0, 0, 0, 0, 0, 3 }
}

AREADIAGONAL_SQUAREWAVE5 = {
	{ 1, 1, 1, 0, 0 },
	{ 1, 1, 1, 0, 0 },
	{ 1, 1, 1, 0, 0 },
	{ 0, 0, 0, 1, 0 },
	{ 0, 0, 0, 0, 3 }
}

AREADIAGONAL_WAVE5 = {
	{ 0, 0, 0, 0, 1, 0 },
	{ 0, 1, 1, 1, 0, 0 },
	{ 0, 1, 1, 1, 0, 0 },
	{ 0, 1, 1, 1, 0, 0 },
	{ 1, 0, 0, 0, 1, 0 },
	{ 0, 0, 0, 0, 0, 3 }
}

--Beams
AREA_BEAM1 = {
	{ 3 }
}

AREA_BEAM5 = {
	{ 1 },
	{ 1 },
	{ 1 },
	{ 1 },
	{ 1 },
	{ 3 }
}

AREA_BEAM7 = {
	{ 1 },
	{ 1 },
	{ 1 },
	{ 1 },
	{ 1 },
	{ 1 },
	{ 1 },
	{ 3 }
}

--Diagonal Beams
AREADIAGONAL_BEAM5 = {
	{ 1, 0, 0, 0, 0, 0 },
	{ 0, 1, 0, 0, 0, 0 },
	{ 0, 0, 1, 0, 0, 0 },
	{ 0, 0, 0, 1, 0, 0 },
	{ 0, 0, 0, 0, 1, 0 },
	{ 0, 0, 0, 0, 0, 3 }
}

AREADIAGONAL_BEAM7 = {
	{ 1, 0, 0, 0, 0, 0, 0, 0 },
	{ 0, 1, 0, 0, 0, 0, 0, 0 },
	{ 0, 0, 1, 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 1, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 1, 0, 0, 0 },
	{ 0, 0, 0, 0, 0, 1, 0, 0 },
	{ 0, 0, 0, 0, 0, 0, 1, 0 },
	{ 0, 0, 0, 0, 0, 0, 0, 3 }
}

--Circles
AREA_CIRCLE2X2 = {
	{ 0, 1, 1, 1, 0 },
	{ 1, 1, 1, 1, 1 },
	{ 1, 1, 3, 1, 1 },
	{ 1, 1, 1, 1, 1 },
	{ 0, 1, 1, 1, 0 }
}

AREA_CIRCLE2X2 = {
	{ 0, 0, 1, 1, 1, 0, 0 },
	{ 0, 1, 1, 1, 1, 1, 0 },
	{ 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 3, 1, 1, 1 },
	{ 1, 1, 1, 1, 1, 1, 1 },
	{ 0, 1, 1, 1, 1, 1, 0 },
	{ 0, 0, 1, 1, 1, 0, 0 }
}

-- Crosses
AREA_CROSS1X1 = {
	{ 0, 1, 0 },
	{ 1, 3, 1 },
	{ 0, 1, 0 }
}

AREA_CROSS5X5 = {
	{ 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0 },
	{ 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0 },
	{ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
	{ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
	{ 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1 },
	{ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
	{ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
	{ 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0 },
	{ 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0 },
	{ 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 }
}

AREA_CROSS6X6 = {
	{ 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0 },
	{ 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0 },
	{ 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0 },
	{ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
	{ 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1 },
	{ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
	{ 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0 },
	{ 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0 },
	{ 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 }
}

--Squares
AREA_SQUARE1X1 = {
	{ 1, 1, 1 },
	{ 1, 3, 1 },
	{ 1, 1, 1 }
}

AREA_SQUARE2X2 = {
	{ 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 1, 1 },
	{ 1, 1, 3, 1, 1 },
	{ 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 1, 1 }
}

-- Walls
AREA_WALLFIELD = {
	{ 1, 1, 3, 1, 1 }
}

AREADIAGONAL_WALLFIELD = {
	{ 0, 0, 0, 0, 1 },
	{ 0, 0, 0, 1, 1 },
	{ 0, 1, 3, 1, 0 },
	{ 1, 1, 0, 0, 0 },
	{ 1, 0, 0, 0, 0 },
}
