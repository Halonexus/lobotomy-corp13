/*
Unused icons for new areas are "awaycontent1" ~ "awaycontent30"
*/


// Away Missions
/area/awaymission
	name = "Strange Location"
	icon_state = "away"
	has_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_AWAY
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/awaymission/beach
	name = "Beach"
	icon_state = "away"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	ambientsounds = list('sound/ambience/shore.ogg', 'sound/ambience/seag1.ogg','sound/ambience/seag2.ogg','sound/ambience/seag2.ogg','sound/ambience/ambiodd.ogg','sound/ambience/ambinice.ogg')

/area/awaymission/errorroom
	name = "Super Secret Room"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = STANDARD_GRAVITY

/area/awaymission/vr
	name = "Virtual Reality"
	icon_state = "awaycontent1"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	var/pacifist = TRUE // if when you enter this zone, you become a pacifist or not
	var/death = FALSE // if when you enter this zone, you die
	network_root_id = "VR"

/area/awaymission/enkr
	name = "Fathoms of E.G.O"
	icon_state = "awaycontent2"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	sound_environment = SOUND_AREA_STANDARD_STATION
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
