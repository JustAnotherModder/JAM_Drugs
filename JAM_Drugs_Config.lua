JAM.Drugs = {}
local JDGS = JAM.Drugs
JDGS.ESX = JAM.ESX

JDGS.Config = {}
JDGS.Config.ZoneLoadDist 		= 100
JDGS.Config.ActionDist   		= 2
JDGS.Config.EnableBlips  		= true

JDGS.Config.SalesProfit 		= 10 -- %
JDGS.Config.NPCSalesProfit	= 20 -- %

JDGS.Config.DrugEffectTimer   = 30000

JDGS.Config.RobberyChance 	= 10 -- % chance of robbery.
JDGS.Config.RobberyAmount 	= 10 -- % of items taken from players inventory.
JDGS.Config.SnitchingChance 	= 100 -- % chance of player being ratted to police.	
JDGS.Config.NPCSalesChance  	= 10 -- % chance of being able to sell to random npc
JDGS.Config.NPCAgroChance 	= 10 -- % chance npcs will aggro if they dont buy your drugs.

JDGS.Config.NPCSalesDist		= 5
JDGS.Config.NPCSalesMax 		= 3

JDGS.Items = {}			
JDGS.Items.Cocaine = {
	Name 		= 'jamcocaine',
	Label 		= 'Cocaine',
	Limit 		= 100,
	Rare 		= 0,
	CanRemove 	= 1,
	Price 		= 1000,
}

JDGS.Items.Meth = {
	Name 		= 'jammeth',
	Label 		= 'Meth',
	Limit 		= 100,
	Rare 		= 0,
	CanRemove 	= 1,
	Price 		= 700,
}

JDGS.Zones = {}
JDGS.Zones.MethLab = {
	ZoneTitle 		= "Meth Lab",
	DrugTitle		= "Meth",	
	ActionType		= "Buy",	

	DrugPrice		= JDGS.Items.Meth.Price,
	DrugLimit		= JDGS.Items.Meth.Limit,

	ViewRadius 		= 500,

	BlipSprite 		= 499,
	BlipColor 		= 74,		
	BlipScale 		= 1.0,
	BlipDisplay 	= 4,

	Positions = {	
		EntryHeading	= 210.00,
		ExitHeading		= 277.70,
		EntryPos 		= vector3( 201.85, 2462.02, 54.50 ),
		ExitPos 		= vector3( 997.00, -3200.71, -37.50 ),
		ActionPos	 	= vector3( 1002.16, -3195.85, -40.0 ),

		SafePos			= vector3( 1012.10, -3194.40, -39.1 ),
		SafeActionPos	= vector3( 1012.15, -3195.35, -40.0 ),
	},

	SafeRewards	= { 
		WeaponAmount 	= 1,
		DrugsAmount 	= 75,
		CashAmount 		= 7500,

		Items = { 'jammeth', 'jamcocaine' },	
		
		Weapons = { 
		"WEAPON_HEAVYPISTOL", "WEAPON_PISTOL50", "WEAPON_SMG", "WEAPON_ASSAULTSMG", "WEAPON_REVOLVER", 
		"WEAPON_PUMPSHOTGUN", "WEAPON_ASSAULTRIFLE", "WEAPON_SMG", "WEAPON_REVOLVER", "WEAPON_COMBATMG", 
		"WEAPON_COMPACTRIFLE", "WEAPON_ASSAULTSHOTGUN", "WEAPON_SPECIALCARBINE", "WEAPON_ADVANCEDRIFLE",
		"WEAPON_SAWNOFFSHOTGUN", "WEAPON_HEAVYSHOTGUN", "WEAPON_MG",
		},				
	},

	EntSettings = {
		Invincible = false,
		FreezeEnt = false,
		BlockEvents = false,
		Relationship = "AMBIENT_GANG_LOST",
	},
	
	SalesEnt = {
		Type = 27,
		Models = { 'g_f_y_lost_01', 'u_f_y_bikerchic', },
		Positions = { vector4( 1003.85, -3195.75, -40.0, 90.0 ), },
	},

	WorkerEnt = {						
		Type = 27,
		Models = { 'mp_f_meth_01', "mp_m_meth_01" },
		AnimDict = 'anim@amb@business@meth@meth_monitoring_cooking@cooking@',

		Positions = { 	
			["base_idle_tank_cooker"] = vector4( 1005.80, -3200.38, -39.40, 175.0 ),
			["base_idle_tank_penci"] = vector4( 1009.80, -3196.78, -40.0, 165.0 ),
		},
	},

	GuardEnt = {						
		Type = 27,
		Models = { 'g_m_y_lost_01', 'g_m_y_lost_02', 'g_m_y_lost_03', },

		Positions = { 	
			vector4( 1016.48, -3195.81, -40.0, 120.0 ),						
			vector4( 1016.48, -3200.81, -40.0, 48.0 ),
			vector4( 1011.52, -3201.99, -40.0, 3.50 ),
			vector4( 1013.91, -3197.39, -40.0, 351.51 ),
			vector4( 1003.84, -3200.63, -40.0, 18.51 ),
			vector4( 1000.53, -3198.35, -40.0, 315.51 ),
			vector4( 1008.47, -3199.23, -40.0, 159.50 ),
			vector4( 997.14, -3201.96, -37.25, 339.50 ),
		},					
	},
}

JDGS.Zones.MethSales = {	
	ZoneTitle 	= "Meth Sales",
	DrugTitle	= "Meth",
	ActionType	= "Sell",	

	DrugPrice	= JDGS.Items.Meth.Price,

	ViewRadius 		= 250,

	BlipSprite 		= 499,
	BlipColor 		= 74,		
	BlipScale 		= 1.0,
	BlipDisplay 	= 4,

	Positions = {	
		ActionPos = vector3( 302.92, -1959.95, 22.89 ),
	},

	EntSettings = {
		Invincible = false,
		FreezeEnt = false,
		BlockEvents = false,
		Relationship = "AMBIENT_GANG_MEXICAN",
	},

	SalesEnt = {
		Type = 4,
		FreezeEnt = true,
		Models = { 'g_m_y_mexgoon_03', 'ig_ramp_mex', 'g_m_y_mexgoon_02', 'a_m_y_mexthug_01','g_m_y_mexgoon_01', },
		Positions = { vector4( 303.46, -1960.46, 22.80, 46.70 ), },
	},

	RobberEnt = {
		Type = 4,
		Models = { 'g_m_y_mexgoon_03', 'ig_ramp_mex', 'g_m_y_mexgoon_02', 'a_m_y_mexthug_01','g_m_y_mexgoon_01', },

		Positions = {
			vector4( 293.14, -1953.2, 23.18, 231.37 ),		
			vector4( 294.31, -1951.12, 23.18, 222.37 ),				
			vector4( 292.7, -1946.33, 23.18, 222.37 ),			
			vector4( 299.14, -1940.43, 23.43, 144.36 ),	
			vector4( 306.42, -1968.15, 21.47, 51.36 ),
			vector4( 291.55, -1957.99, 22.54, 282.36 ),	
		},
	},
}

JDGS.Zones.CocaineLab = {
	ZoneTitle 	= "Cocaine Lab",	
	DrugTitle	= "Cocaine",	
	ActionType	= "Buy",	

	DrugPrice	= JDGS.Items.Cocaine.Price,	
	DrugLimit	= JDGS.Items.Cocaine.Limit,

	ViewRadius 		= 300,

	BlipSprite 		= 497,
	BlipColor 		= 4,	
	BlipScale 		= 1.0,
	BlipDisplay 	= 4,

	Positions = {	
		EntryHeading	= 50.00,
		ExitHeading		= 185.00,
		EntryPos 		= vector3(   25.22,  6490.75,  30.54 ),
		ExitPos 		= vector3( 1088.73, -3187.79, -39.95 ),
		ActionPos	 	= vector3( 1088.77, -3194.05, -39.95 ),

		SafePos			= vector3( 1100.10, -3193.60, -39.90 ),
		SafeActionPos	= vector3( 1099.81, -3194.41, -39.95 ),
	},

	SafeRewards			= { 
		WeaponAmount = 3,
		DrugsAmount = 100,
		CashAmount = 10000,

		Items = { 'jammeth', 'jamcocaine' },	
		
		Weapons = { 
		"WEAPON_HEAVYPISTOL", "WEAPON_PISTOL50", "WEAPON_SMG", "WEAPON_ASSAULTSMG", "WEAPON_REVOLVER", 
		"WEAPON_PUMPSHOTGUN", "WEAPON_ASSAULTRIFLE", "WEAPON_SMG", "WEAPON_REVOLVER", "WEAPON_COMBATMG", 
		"WEAPON_COMPACTRIFLE", "WEAPON_ASSAULTSHOTGUN", "WEAPON_SPECIALCARBINE", "WEAPON_ADVANCEDRIFLE",
		"WEAPON_SAWNOFFSHOTGUN", "WEAPON_HEAVYSHOTGUN", "WEAPON_MG",
		},				
	},

	EntSettings = {
		Invincible = false,
		FreezeEnt = false,
		BlockEvents = false,
		Relationship = "AMBIENT_GANG_BALLAS",
	},
	
	SalesEnt = {
		Type = 4,						
		Models = { 'g_f_y_ballas_01', },
		Positions = { vector4( 1088.92, -3194.42, -40.0, 0.0 ) },
	},					

	WorkerEnt = {						
		Type = 4,
		Models = { 'mp_f_cocaine_01' },

		Positions = { 	
			vector4( 1093.08, -3196.60, -40.0, 0.0 ),
			vector4( 1090.34, -3196.67, -40.0, 0.0 ),
			vector4( 1095.28, -3196.57, -40.0, 0.0 ),
			vector4( 1095.28, -3194.82, -40.0, 180.0 ),
			vector4( 1093.00, -3194.92, -40.0, 180.0 ), 
		},

		AnimDict = 'anim@amb@business@coc@coc_unpack_cut_left@',	
		AnimName = 'coke_cut_v5_coccutter',
	},

	GuardEnt = {
		Type = 4,	
		Models = { 'csb_ballasog', 'g_m_y_ballaeast_01', 'g_m_y_ballaorig_01', 'g_m_y_ballasout_01', },

		Positions = {
		 	vector4( 1102.69, -3194.05, -40.0, 135.0 ),
			vector4( 1087.84, -3199.38, -40.0, 325.0 ),
			vector4( 1097.21, -3193.39, -40.0, 88.0 ),
			vector4( 1097.02, -3199.42, -40.0, 62.26 ),
			vector4( 1103.03, -3198.53, -40.0, 58.13 ), 
		},
	},
}

JDGS.Zones.CocaineSales = {
	ZoneTitle 	= "Biker HQ",	
	DrugTitle	= "Cocaine",
	ActionType	= "Sell",	

	DrugPrice	= JDGS.Items.Cocaine.Price,	

	ViewRadius 		= 150,

	BlipSprite 		= 226,
	BlipColor 		= 4,
	BlipScale 		= 1.0,
	BlipDisplay 	= 4,

	Positions = {
		EntryHeading	= 51.31,
		ExitHeading		= 18.90,
		EntryPos 		= vector3( 986.99, -144.8, 73.31 ),			
		ExitPos		 	= vector3( 1121.01, -3152.40, -38.01 ),	
		ActionPos		= vector3( 1122.85, -3144.60, -38.00 ),

		SafePos			= vector3( 1118.32, -3143.23, -38.00 ),
		SafeActionPos	= vector3( 1117.82, -3145.11, -37.05 ),
	},

	SafeRewards			= { 
		WeaponAmount = 3,
		DrugsAmount = 100,
		CashAmount = 10000,

		Items = { 'jammeth', 'jamcocaine' },	
		
		Weapons = { 
		"WEAPON_HEAVYPISTOL", "WEAPON_PISTOL50", "WEAPON_SMG", "WEAPON_ASSAULTSMG", "WEAPON_REVOLVER", 
		"WEAPON_PUMPSHOTGUN", "WEAPON_ASSAULTRIFLE", "WEAPON_SMG", "WEAPON_REVOLVER", "WEAPON_COMBATMG", 
		"WEAPON_COMPACTRIFLE", "WEAPON_ASSAULTSHOTGUN", "WEAPON_SPECIALCARBINE", "WEAPON_ADVANCEDRIFLE",
		"WEAPON_SAWNOFFSHOTGUN", "WEAPON_HEAVYSHOTGUN", "WEAPON_MG",
		},				
	},

	EntSettings = {
		Invincible = false,
		FreezeEnt = false,
		BlockEvents = false,
		Relationship = "AMBIENT_GANG_LOST",
	},

	SalesEnt = {
		Type = 5,
		Models = { 'g_f_y_lost_01', 'u_f_y_bikerchic', },
		Positions = { vector4( 1121.21, -3144.57, -38.00, 280.0 ), },
	},

	GuardEnt = {						
		Type = 4,
		Models = { 'g_m_y_lost_01', 'g_m_y_lost_02', 'g_m_y_lost_03', },

		Positions = { 	
			vector4( 1115.52, -3153.30, -38.00, 280.0 ),						
			vector4( 1118.50, -3159.43, -38.00, 0.0 ),
			vector4( 1119.30, -3148.58, -38.00, 213.12 ),
			vector4( 1117.27, -3162.73, -38.00, 280.0 ),
			vector4( 1123.22, -3159.08, -38.00, 76.00 ),
			vector4( 1114.83, -3159.26, -38.00, 342.45 ),
			vector4( 1113.37, -3147.71, -38.00, 285.30 ),
			vector4( 1113.90, -3143.27, -38.00, 225.45 ),
			vector4( 1087.02, -3187.76, -38.00, 213.30 ),
			vector4( 1090.29, -3187.93, -38.00, 153.45 ),
		},					
	},

	Vehicles = {
		Models = { "gburrito", "zombieb", "sanctus", "daemon", "gargoyle", "zombiea", "avarus", "coquette3", "trophytruck2", "sandking", "tampa2", "coquette2", "banshee2", "nh2r", "r1", },
		Positions = { 	
			vector4( 1109.27, -3162.82, -37.52, 0.0 ),						
			vector4( 1102.25, -3156.99, -37.52, 270.0 ),				
			vector4( 1099.53, -3145.54, -37.52, 180.0 ),		
			vector4( 1103.45, -3145.78, -37.52, 180.0 ),
		},
	},
}