# JAM_Drugs

JAM_Drugs is a "work-in-progress" mod that reworks the aspect of drug running in ESX. If you wish to use this in its current state, any bugs you encounter are yours to REPORT and FIX. If you don't already have the correct IPL's loaded for the drug lab interiors (and biker clubhouse interiors) then you'll want to use the iplList provided with the fivem-ipl mod (link in requirements).

# Requirements
- https://github.com/JustAnotherModder/JAM/releases
- https://github.com/JustAnotherModder/JAM_SafeCracker/releases
- https://github.com/ESX-PUBLIC/fivem-ipl
- You need GC-Phone if you want to use "snitching" notifications. Also uncomment the HandleSnitching function in JAM_Drugs_Client.lua.
- You will also need to download any/all dependencies for the required mods above. Make sure you have all of those working correctly before even attempting to go any further.

# Installation
- Import `JAM_DrugZones.sql` into your database.
- Import `JAM_Drugs.sql` into your database.
- Download the zip from the repo above.
- Extract the `JAM_Drugs` folder into your `JAM` folder, inside of the `resources` directory.
- Inside of your `JAM` folder, edit the `__resource.lua` file, and add the files to their respective locations. Example:

```
client_scripts {
	'JAM_Main.lua',
	'JAM_Client.lua',
	'JAM_Utilities.lua',

	-- Drugs
	'JAM_Drugs/JAM_Drugs_Config.lua',
	'JAM_Drugs/JAM_Drugs_Client.lua',
}

server_scripts {	
	'JAM_Main.lua',
	'JAM_Server.lua',
	'JAM_Utilities.lua',

	-- MySQL
	'@mysql-async/lib/MySQL.lua',

	-- Drugs
	'JAM_Drugs/JAM_Drugs_Config.lua',
	'JAM_Drugs/JAM_Drugs_Client.lua',
}
```

# SCREENSHOTS
<details>
  <summary>Click to view screenshots</summary>
  
  - Purchase direct from gang manufacturing plants.
![alttext](https://i.imgur.com/hS59kyV.jpg)
![alttext](https://i.imgur.com/tAUbkkc.jpg)
![alttext](https://i.imgur.com/3n1haZe.jpg)
  
  - Or try to rob their supply.
![alttext](https://i.imgur.com/PJf3fyg.jpg)
![alttext](https://i.imgur.com/u2x8wOw.jpg)
![alttext](https://i.imgur.com/UnBuwJJ.jpg)

  - Sell to random NPCs for more smaller deals and larger profit, or to gangs for bulk sales - but be careful, gangs might try to rob you and pedestrians might try to attack you or rat you out to the police!
![alttext](https://i.imgur.com/MQ6eU32.jpg)
![alttext](https://i.imgur.com/jQORGS8.jpg)
</details>

# NOTES
- Any and all improvements must be sent back to the author (me), here on github.
- No support. Don't post an issue.
