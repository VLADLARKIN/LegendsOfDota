print('Loaded LoD dedicated file!')

-- How long to wait after the match ends before killing the server
local endGameDelay = 15

-- If we have started or not
local hasStarted = false

-- Load bans
local bans
function loadBans()
    -- Reload steamID64s
    bans = LoadKeyValues('scripts/kv/banned.kv');
end
loadBans()

-- Console command to reload bans
Convars:RegisterCommand('reload_bans', function()
    loadBans()
end, 'Reloads the bans KV', 0)

-- Ban manager
local autoAllocate = {}
ListenToGameEvent('player_connect', function(keys)
    -- Grab their steamID
    local steamID64 = tostring(keys.xuid)

    -- Check bans
    if bans[steamID64] then
        SendToServerConsole('kickid '..keys.userid);
    end

    -- Check their name
    local chr = keys.name:sub(1,1)
    if chr == 'R' then
        autoAllocate[keys.userid] = DOTA_TEAM_GOODGUYS
    elseif chr == 'D' then
        autoAllocate[keys.userid] = DOTA_TEAM_BADGUYS
    elseif chr == 'S' then
        autoAllocate[keys.userid] = 1
    end
end, nil)

-- Team allocation stuff
local tst = LoadKeyValues('cfg/allocation.kv')
if tst ~= 0 and tst ~= nil then
    print('Loaded LoD allocation code!')

    -- Stick people onto teams
    local allocated = {}
    ListenToGameEvent('player_connect_full', function(keys)
        -- Grab the entity index of this player
        local entIndex = keys.index+1
        local ply = EntIndexToHScript(entIndex)

        -- Validate player
        if ply and IsValidEntity(ply) then
            -- Make sure they aren't already on a team
            if not allocated[entIndex] then
                -- We have now allocated this player
                allocated[entIndex] = true

                -- Don't touch bots
                if PlayerResource:IsFakeClient(ply:GetPlayerID()) then return end

                -- Find number of players on each team
                local radiant = 0
                local dire = 0
                for i=0,9 do
                    if PlayerResource:GetConnectionState(i) >= 2 or PlayerResource:IsFakeClient(i) then
                        if PlayerResource:GetTeam(i) == DOTA_TEAM_GOODGUYS then
                            radiant = radiant + 1
                        elseif PlayerResource:GetTeam(i) == DOTA_TEAM_BADGUYS then
                            dire = dire + 1
                        end
                    end
                end

                -- Should we be spectating this player?
                if dire + radiant >= 10 then
                    -- Create a spectator
                    ply:SetTeam(1)
                    return
                end

                -- We have started
                hasStarted = true

                -- Check for allocaton code
                if autoAllocate[keys.userid] then
                    if autoAllocate[keys.userid] == DOTA_TEAM_GOODGUYS and radiant < 5 then
                        ply:SetTeam(DOTA_TEAM_GOODGUYS)
                        return
                    elseif autoAllocate[keys.userid] == DOTA_TEAM_BADGUYS and dire < 5 then
                        ply:SetTeam(DOTA_TEAM_BADGUYS)
                        return
                    elseif autoAllocate[keys.userid] == 1 then
                        ply:SetTeam(1)
                        return
                    end
                end

                -- Set their team
                if radiant <= dire then
                    ply:SetTeam(DOTA_TEAM_GOODGUYS)
                else
                    ply:SetTeam(DOTA_TEAM_BADGUYS)
                end
            end
        end
    end, nil)

    ListenToGameEvent('player_disconnect', function(keys)
        -- Prevent spam
        if not hasStarted then return end

        -- Kill server if no one is on it anymore
        GameRules:GetGameModeEntity():SetThink(function()
            -- Search for players
            local foundSomeone = false
            for i=0,9 do
                if PlayerResource:GetConnectionState(i) == 2 then
                    foundSomeone = true
                    break
                end
            end

            -- If we failed to find someone
            if not foundSomeone then
                -- Kill the server
                SendToServerConsole('quit')
            end
        end, 'killServer', 1, nil)
    end, nil)

    -- Kill the server when the match ends
    local killed = false
    ListenToGameEvent('game_rules_state_change', function(keys)
        -- Only do this once
        if killed then return end

        -- Grab the current game state
        local state = GameRules:State_Get()

        -- Check if the game is over
        if state >= DOTA_GAMERULES_STATE_POST_GAME then
            -- Don't kill again
            killed = true

            -- Kill server after a delay
            GameRules:GetGameModeEntity():SetThink(function()
                -- Kill the server
                SendToServerConsole('quit')
            end, 'killServerDelayed', endGameDelay, nil)
        end
    end, nil)
end

-- Bot allocation
local tst = LoadKeyValues('cfg/addbots.kv')
if tst ~= 0 and tst ~= nil then
    print('Loaded LoD bot allocation code')

    -- Auto add bots on the dedi server
    if GameRules:isSource1() then
        local addedBots = false
        local started = false
        ListenToGameEvent('game_rules_state_change', function(keys)
            local state = GameRules:State_Get()

            if state == DOTA_GAMERULES_STATE_INIT then
                started = true
            end

            if not started then return end

            if not addedBots and state >= DOTA_GAMERULES_STATE_PRE_GAME then
                addedBots = true
                SendToServerConsole('sm_gmode 1')
                SendToServerConsole('dota_bot_populate')
            end
        end, nil)
    end
end