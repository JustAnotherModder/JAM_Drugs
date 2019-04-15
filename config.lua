JAM_Drugs = {
	-- Config file handles all things that a server owner may want to modify. Still though, make sure you know what you're editing.
	Config = {
		-- Profit (or loss from clean money) for drug sales.
		SalesProfit 	= 10, -- %

		-- Edit drug prices and limits here (and nowhere else).
		MethPrice		= 700,
		CokePrice		= 1000,		
		MethLimit		= 100,
		CokeLimit		= 100,	

		-- Robbery and snitching settings.
		RobberyChance 	= 50, -- % chance of robbery.
		RobberAmount 	= 10, -- % of items taken from players inventory.
		SnitchingChance = 50, -- % chance of player being ratted to police.	

		-- Distance to load areas from.
		LoadDist 		= 100,

		-- Universal blip and marker settings.
		EnableBlips 	= true,
		EnableMarkers	= false,

		BlipScale 		= 1.0,
		BlipDisplay 	= 4,
		MarkerAlpha 	= 0,
		MarkerScale 	= { x = 1.5, y = 1.5, z = 2.0 },
		MarkerColor 	= { r = 255, g = 255, b = 255 },
		MarkerDrawDist	= 50,

		-- Areas for pickup and sale of drugs.
		Zones = {
			CocaineLab = {
				ZoneTitle 		= "Cocaine Lab",
				DrugTitle	 	= "Cocaine",
				ActionType		= "Buy",
				ZonePrice		= 1000,
				ZoneLimit 		= 100,
				ViewRadius 		= 250,
				BlipSprite 		= 497,
				BlipColor 		= 4,
				ZoneHeading		= 300.0,
				ExitHeading		= 185.0,
				ZonePos 		= vector3( -1321.42, -1264.21, 3.60 ),
				ExitPos 		= vector3( 1088.73, -3187.79, -39.95 ),
				ActionPos	 	= vector3( 1088.77, -3194.05, -39.95 ),

				SafePos				= vector3( 1100.10, -3193.60, -39.90 ),
				SafeActionPos		= vector3( 1099.81, -3194.41, -39.95 ),

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

				-- Entities for this zone.
				EntSettings = {
					-- Preset settings for these entities.
					Invincible = false,
					FreezeEnt = false,
					BlockEvents = false,
					Relationship = "AMBIENT_GANG_BALLAS",
				},
				
				SalesEnt = {
					Type = 5,						
					Models = { 'g_f_y_ballas_01', },
					Positions = { vector4( 1088.92, -3194.42, -40.0, 0.0 ) },
				},					

				WorkerEnt = {						
					Type = 5,
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
			},

			CocaineSales = {
				ZoneTitle 		= "Biker HQ",
				DrugTitle	 	= "Cocaine",
				ActionType		= "Sell",
				ZonePrice		= 1000,

				ViewRadius 		= 150,
				BlipSprite 		= 226,
				BlipColor 		= 4,
				ZoneHeading		= 51.31,
				ExitHeading		= 18.90,
				ZonePos 		= vector3( 986.99, -144.8, 73.31 ),			
				ExitPos		 	= vector3( 1121.01, -3152.40, -38.01 ),	
				ActionPos		= vector3( 1122.85, -3144.60, -38.00 ),

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
					},					
				},

				RobberEnt = {
					Type = 4,
					Models = { 'g_m_y_lost_01', 'g_m_y_lost_02', 'g_m_y_lost_03', },

					Positions = {
						vector4( 379.36, -2008.29, 23.79, 83.40 ),				
					},
				},
			},
		},
		-- Weapons list (for entities).
		Weapons = {
			Melee = { 
				'WEAPON_KNIFE', 'WEAPON_KNUCKLE', 'WEAPON_NIGHTSTICK', 'WEAPON_HAMMER', 'WEAPON_BAT', 'WEAPON_GOLFCLUB', 'WEAPON_CROWBAR', 'WEAPON_BOTTLE', 'WEAPON_DAGGER',
				'WEAPON_HATCHET', 'WEAPON_MACHETE', 'WEAPON_SWITCHBLADE', 'WEAPON_POOLCUE',
			},
			Pistol = {
				'WEAPON_REVOLVER', 'WEAPON_PISTOL', 'WEAPON_PISTOL_MK2', 'WEAPON_COMBATPISTOL', 'WEAPON_APPISTOL', 'WEAPON_PISTOL50', 'WEAPON_SNSPISTOL', 
				'WEAPON_HEAVYPISTOL','WEAPON_VINTAGEPISTOL', 'WEAPON_DOUBLEACTION', 'WEAPON_REVOLVER_MK2', 'WEAPON_SNSPISTOL_MK2',
			},
			SMG = {
				'WEAPON_MICROSMG','WEAPON_MINISMG','WEAPON_SMG','WEAPON_SMG_MK2','WEAPON_ASSAULTSMG', 'WEAPON_MACHINEPISTOL',
			},
			MG = {
				'WEAPON_MG','WEAPON_COMBATMG','WEAPON_COMBATMG_MK2',
			},
			Assault = {
				'WEAPON_ASSAULTRIFLE', 'WEAPON_ASSAULTRIFLE_MK2', 'WEAPON_CARBINERIFLE', 'WEAPON_CARBINERIFLE_MK2', 'WEAPON_ADVANCEDRIFLE', 'WEAPON_SPECIALCARBINE', 
				'WEAPON_BULLPUPRIFLE', 'WEAPON_COMPACTRIFLE', 'WEAPON_SPECIALCARBINE_MK2', 'WEAPON_BULLPUPRIFLE_MK2',
			},
			Shotgun = {
				 'WEAPON_PUMPSHOTGUN','WEAPON_SAWNOFFSHOTGUN','WEAPON_BULLPUPSHOTGUN','WEAPON_ASSAULTSHOTGUN','WEAPON_HEAVYSHOTGUN','WEAPON_DBSHOTGUN',
				 'WEAPON_PUMPSHOTGUN_MK2',
			},
		},

		-- Items to add to the database. (Only added once, but limit is updated per top of config every server startup).
		-- Note: If you wish to change the item names (for use with other mods), you will need to change the server SellDrugs and BugDrugs callbacks accordingly.

		Items = {			
			Cocaine = {
				Name 		= 'jamcocaine',
				Label 		= 'Cocaine',
				Limit 		= CokeLimit,
				Rare 		= 0,
				CanRemove 	= 1,
			},
			Meth = {
				Name 		= 'jammeth',
				Label 		= 'Meth',
				Limit 		= MethLimit,
				Rare 		= 0,
				CanRemove 	= 1,
			},
		},
		-- Key codes.
		Keys = {
		    ["ESC"] 		= 322, 	["F1"] 			= 288, 	["F2"] 			= 289, 	["F3"] 			= 170, 	["F5"] 	= 166, 	["F6"] 	= 167, 	["F7"] 	= 168, 	["F8"] 	= 169, 	["F9"] 	= 56, 	["F10"] 	= 57, 
		    ["~"] 			= 243, 	["1"] 			= 157, 	["2"] 			= 158, 	["3"] 			= 160, 	["4"] 	= 164, 	["5"] 	= 165, 	["6"] 	= 159, 	["7"] 	= 161, 	["8"] 	= 162, 	["9"] 		= 163, 	["-"] 	= 84, 	["="] 		= 83, 	["BACKSPACE"] 	= 177, 
		    ["TAB"] 		= 37,  	["Q"] 			= 44, 	["W"] 			= 32, 	["E"] 			= 38, 	["R"] 	= 45, 	["T"] 	= 245, 	["Y"] 	= 246, 	["U"] 	= 303, 	["P"] 	= 199, 	["["] 		= 39, 	["]"] 	= 40, 	["ENTER"] 	= 18,
		    ["CAPS"] 		= 137, 	["A"] 			= 34, 	["S"] 			= 8, 	["D"] 			= 9, 	["F"] 	= 23, 	["G"] 	= 47, 	["H"] 	= 74, 	["K"] 	= 311, 	["L"] 	= 182,
		    ["LEFTSHIFT"] 	= 21,  	["Z"] 			= 20, 	["X"] 			= 73, 	["C"] 			= 26, 	["V"] 	= 0, 	["B"] 	= 29, 	["N"] 	= 249, 	["M"] 	= 244, 	[","] 	= 82, 	["."] 		= 81,
		    ["LEFTCTRL"] 	= 36,  	["LEFTALT"] 	= 19, 	["SPACE"] 		= 22, 	["RIGHTCTRL"] 	= 70, 
		    ["HOME"] 		= 213, 	["PAGEUP"] 		= 10, 	["PAGEDOWN"] 	= 11, 	["DELETE"] 		= 178,
		    ["LEFT"] 		= 174, 	["RIGHT"] 		= 175, 	["TOP"] 		= 27, 	["DOWN"] 		= 173,
		    ["NENTER"] 		= 201, 	["N4"] 			= 108, 	["N5"] 			= 60, 	["N6"] 			= 107, 	["N+"] 	= 96, 	["N-"] 	= 97, 	["N7"] 	= 117, 	["N8"] 	= 61, 	["N9"] 	= 118
		},
	},
}

				
