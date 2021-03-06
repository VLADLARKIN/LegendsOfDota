:: -- Compile the scripts --
call compile_s2.bat

:: -- Stage source2 binaries --

:: Cleanup the old copy of it
rmdir /S /Q "lod_s2_bin"

:: Create directory structure
mkdir "lod_s2_bin\resource"
mkdir "lod_s2_bin\scripts\npc"
mkdir "lod_s2_bin\maps"

:: Hard link info files
mklink /H "lod_s2_bin\addoninfo.txt" "lod_game\addoninfo.txt"

:: Hard link top level scripts
mklink /H "lod_s2_bin\scripts\custom_events.txt" "lod_game\scripts\custom_events.txt"
mklink /H "lod_s2_bin\scripts\stat_collection.kv" "lod_game\scripts\stat_collection.kv"

:: Hard link NPC scripts
mklink /H "lod_s2_bin\scripts\npc\activelist.txt" "lod_game\scripts\npc\activelist_s2.txt"
mklink /H "lod_s2_bin\scripts\npc\herolist.txt" "lod_game\scripts\npc\herolist_s2.txt"
mklink /H "lod_s2_bin\scripts\npc\npc_units_custom.txt" "script_generator\BIN\s2\npc_units_custom.txt"
mklink /H "lod_s2_bin\scripts\npc\npc_items_custom.txt" "script_generator\BIN\s2\npc_items_custom.txt"

:: Link script folders
mklink /D /J "lod_s2_bin\scripts\vscripts" "lod_game\scripts\vscripts\"
mklink /D /J "lod_s2_bin\scripts\kv" "lod_game\scripts\kv"
mklink /D /J "lod_s2_bin\scripts\abilities" "lod_game\scripts\abilities"
mklink /D /J "lod_s2_bin\scripts\game_sounds" "lod_game\scripts\game_sounds"

:: Link particle folder
mklink /D /J "lod_s2_bin\particles" "lod_game\particles_s2"

:: Link resource folders
mklink /D /J "lod_s2_bin\resource\flash3" "lod_game\resource\flash3"
mklink /D /J "lod_s2_bin\resource\overviews" "lod_game\resource\overviews"

:: Hard link generated scripts
mklink /H "lod_s2_bin\resource\addon_english.txt" "script_generator\BIN\s2\addon_english.txt"
mklink /H "lod_s2_bin\resource\addon_russian.txt" "script_generator\BIN\s2\addon_russian.txt"
mklink /H "lod_s2_bin\scripts\npc\npc_abilities_custom.txt" "script_generator\BIN\s2\npc_abilities_custom.txt"
mklink /H "lod_s2_bin\scripts\npc\npc_heroes_custom.txt" "script_generator\BIN\s2\npc_heroes_custom.txt"

:: Hard link materials folder
mklink /D /J "lod_s2_bin\materials" "lod_game\materials"

:: Hard link maps
::mklink /H "lod_s2_bin\maps\dota_pvp.vpk" "maps\dota_pvp.vpk"
mklink /H "lod_s2_bin\maps\dota_pvp_tiled.vpk" "maps\dota_pvp_tiled.vpk"

