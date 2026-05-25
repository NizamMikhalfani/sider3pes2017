-- Stadium switcher v1.3: assign the stadium for home team
-- Custom content is used, not LiveCPK/game: content\stadium-server is the root
-- author: zlac, 2017
-- originally posted on evo-web

local new_stadium_path
local stadiumroot = ".\\content\\stadium-server\\"
local stadium_switched = false

local replay_stad_id = nil
local replay_source_stadium_map = nil
local replay_source_stadium_key = nil

local random_num_comp -- which stadium to select randomly in competition modes from stadium server (depending on entries available per competition in map_competition.txt)
local random_num_exhib -- which stadium to select randomly in exhibition modes from stadium server
local rnd_server_or_cpk -- to serve random stadium from stadium server (depending on entries available per competition in map_competition.txt) or from default .cpk files (i.e. stadium server deactivates itself temporarily)

local team_assignment_map = {}
local competition_assignment_map = {}
local all_stadiums_map = {}

-- override_competitions contains comma-separated ID's of the competitions that allow for team-assigned stadiums to have precedence before competiton-assigned stadiums
-- .. e.g. you've assigned a home stadium for ALL exhibition mode matches (tid 0) in map_competitions.txt, but you still want to use
-- .. custom home-team stadium for those teams that have it assigned in map_teams.txt -> add 0 in override_competitions
-- .. OR: you have assigned multiple stadiums to be selected randomly (e.g. for EPL) for those teams that do not have their own stadiums, but you 
-- .. still want to use custom home-team stadium for those teams that have it assigned in map_teams.txt -> add 39 too (EPL id) in override_competitions
-- initially, all (probably?) Exhibition mode, League and League-Cup matches are included in competition overrides
-- BEGIN CUSTOMIZABLE LUA TABLE                         
local override_competitions = {0, 1, 2, 5, -- Exhibition matches - regular, CL, EL, AFC
                11, 12, 13, -- Champions league
                18, 19, 20, -- Europa League
                32,33,-- Copa Libertadores
                23,24,25,-- AFC Champions
								39, 40, 84, -- England 1st and 2nd div league and cup
								43, 44, 85, -- Spain 1st and 2nd div league and cup
								47, 48, 86, -- Italy 1st and 2nd div league and cup
								51, 52, 87, -- France 1st and 2nd div league and cup
								54, 89, -- Portugal league and cup
								53, 88, -- Netherlands league and cup
								60, 95, -- Argentina league and cup
								57, 92, -- Brazil league and cup
								64, 96, -- Chile league (first stage) and cup
								72, 111, -- PEU league and cup
								74, 112, -- PLA league and cup
								77, 114, -- PAS league and cup
								}
-- END CUSTOMIZABLE LUA TABLE

-- specify the IDs of the teams which already have their real homegrounds assigned via .cpk + EDIT00000000
-- if not listed here, their .cpk homeground may be overriden by map_competition.txt assignment ...
-- ... e.g. Barcelona and Camp Nou: if you assign generic stadiums to La Liga in map_competition.txt and DO NOT assign external Camp Nou to Barca via map_teams.txt, then ...
-- ... Barcelona would never use Camp Nou from .cpk in La Liga-related competition modes - it would use one of the random generics for La Liga
-- Only the teams with original Konami stadiums are listed initially!
-- ADD YOUR OWN TEAM ID'S, BASED ON YOUR EDIT00000000's STADIUM ASSIGNMENTS FROM THE .CPK PACK THAT YOU USE!!
-- BEGIN CUSTOMIZABLE LUA TABLE 
local teams_with_cpk_homegrounds = {
      --108,	-- Barcelona (Camp Nou)
      --119,	-- Internazionale (Giuseppe Meazza)
      --121,	-- Milan (San Siro)
      --1706,	-- Basel (St. Jakob Park)
      --1255,	-- Sao Paulo (Estadio do Morumbi)
      --1254,	-- Santos (Estadio Urbano Caldeira)
      --138,	-- River Plate (El Monumental)
      --139,	-- Boca Juniors (Estadio Alberto J. Armando)
      --147,	-- Urawa Red Diamonds (Saitama Stadium 2002)
      }
-- END CUSTOMIZABLE LUA TABLE

-- remove trailing and leading whitespace from string
local function trim(s)
    return s:gsub("^%s*(.-)%s*$", "%1")
end


local function split(s, inSplitPattern)
   local outResults = {}
   -- chop off the trailing comment, if present
   local theCommentStart = string.find( s, "#", 1 )
   local data = s
   if theCommentStart ~= nil then
      data = string.sub(s, 1, theCommentStart-1)
   end

   -- now do the splits by main separator (inSplitPattern)
   local theStart = 1
   local theSplitStart, theSplitEnd = string.find( data, inSplitPattern, theStart )
   while theSplitStart do
      outResults[#outResults+1] = trim(string.sub( data, theStart, theSplitStart-1 ))
      theStart = theSplitEnd + 1
      theSplitStart, theSplitEnd = string.find( data, inSplitPattern, theStart )
   end
   outResults[#outResults+1] = trim(string.sub( data, theStart ))
   return outResults
end

local function print_arr(tbl)
    for index, value in ipairs(tbl) do
        log("     " .. value)
    end
end

local function tableLength(T)
    local count = 0
    for _ in pairs(T) do 
        count = count + 1
    end
    return count
end

local function valueArrayExistsInTable(tbl, val)
    for key, value in pairs(tbl) do
        if val[1] == value[1] and val[2] == value[2] and val[3] == value[3] then
            return true
        end
    end   
    return false
end

local function merge_maps()
    local idx = 1
    for key, row in pairs(team_assignment_map) do
        if row[1] ~= nil and row[1] ~= "" and row[2] ~= nil and row[2] ~= "" and row[3] ~= nil and row[3] ~= "" and not valueArrayExistsInTable(all_stadiums_map, row) then
            all_stadiums_map[idx] = {row[1], row[2], row[3]}
            idx = idx + 1
        end
    end

    for key, value in pairs(competition_assignment_map) do
        for index, row in ipairs(value) do
            if row[1] ~= nil and row[1] ~= "" and row[2] ~= nil and row[2] ~= "" and row[3] ~= nil and row[3] ~= "" and not valueArrayExistsInTable(all_stadiums_map, row) then
                all_stadiums_map[idx] = {row[1], row[2], row[3]}
                idx = idx + 1
            end
            -- see if the stadium for final match is already included ...
            if row[4] ~= nil and row[4] ~= "" and row[5] ~= nil and row[5] ~= "" and row[6] ~= nil and row[6] ~= "" and not valueArrayExistsInTable(all_stadiums_map, row) then
                all_stadiums_map[idx] = {row[4], row[5], row[6]}
                idx = idx + 1
            end
        end
    end
    log(string.format("%s unique stadiums available for random selection in exhibition modes.", tableLength(all_stadiums_map)))
end

local function load_map_txt(filename)
    local delim = ","
    
    local data = assert(io.lines(stadiumroot .. filename))
    log(filename .. " found in " .. stadiumroot .. filename)
    
    for line in data do
        line = trim(string.gsub(line, "^\239\187\191", "")) -- removes UTF BOM bytes at the beginning of the first line in .txt file and leading/trailing whitespaces in every line
        local fields = split(line, delim)
        if #fields > 1 then
            for i=1,#fields do
                fields[i] = trim(fields[i])
            end
            if fields[1] ~= nil and fields[1] ~= "" then
                if filename == "map_teams.txt" and fields[2] ~= nil and fields[3] ~= nil and fields[4] ~= nil then
                    team_assignment_map[tonumber(fields[1])] = {fields[2], fields[3], fields[4]}
                    log(string.format(" ==> %s stadium assignment::  team_id: %s -> stadium_id: %s, stadium: %s (%s)", filename, fields[1], fields[2], fields[4], fields[3]))
                end
                if filename == "map_competitions.txt" and fields[2] ~= nil and fields[3] ~= nil and fields[4] ~= nil and fields[5] ~= nil and fields[6] ~= nil and fields[7] ~= nil then
                    -- competition_assignment_map[tonumber(fields[1])] = {fields[2], fields[3], fields[4], fields[5], fields[6], fields[7]}
                    if competition_assignment_map[tonumber(fields[1])] ~= nil then
                        table.insert(competition_assignment_map[tonumber(fields[1])], {fields[2], fields[3], fields[4], fields[5], fields[6], fields[7]})
                    else
                        competition_assignment_map[tonumber(fields[1])] = { {fields[2], fields[3], fields[4], fields[5], fields[6], fields[7]} }
                    end
                    log(string.format(" ==> %s stadium assignment::  competition: %s -> stadium_id: %s, stadium: %s (%s) (finals: %s %s (%s))", filename, fields[1], fields[2], fields[4], fields[3], fields[5], fields[7], fields[6]))
                end
            end
        end
    end
end

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

local function select_random_stadium(ctx)
    local tid = tonumber(ctx.tournament_id)
    
    --select random stadium for exhibition mode
    random_num_exhib = nil
    if tid <= 5 and rnd_server_or_cpk == 1 then
        local tblLen = tableLength(all_stadiums_map)
        if  tblLen == 1 then
            random_num_exhib = 1
        else
            math.randomseed(os.time())
            random_num_exhib = math.random(1, tblLen)
            log(string.format("Selecting random stadium from stadium server for exhibition mode: %s (%s) ", all_stadiums_map[random_num_exhib][1], all_stadiums_map[random_num_exhib][2]))
        end
    end
  
    --now for competiton modes ... whenever game selects new home_team, pick a random index of a stadium to be used on competition level (e.g. if multiple stadiums are assigned to one competition_ID)
    random_num_comp = nil
    if tid > 5 and competition_assignment_map[tid] ~= nil then
        if #competition_assignment_map[tid] == 1 then
            -- if there's only one stadium assigned to competition, set "random" number to 1
            random_num_comp = 1 
        else
            -- if there are more stadiums, select one's index rendomly
            math.randomseed(os.time())
            random_num_comp = math.random(1, #competition_assignment_map[tid])
            log("Selecting random stadium for competition ID " .. tostring(tid) .. ": Stadium no. " .. tostring(random_num_comp) .. " (from " .. tostring(#competition_assignment_map[tid]) .. " stadium(s) available)")
        end
    end

end



local function home_team_selected(ctx, team_id)
    local tid = tonumber(ctx.tournament_id)
    
    -- if in-game stadium settings for exhibition modes are set to 'Random', then decide where to draw the stadium from - stadium server or .cpk
      math.randomseed(os.time())
      rnd_server_or_cpk = math.random(1, 2)
      log("If 'Random' in-game setting will be used in exhibition modes:: Source of random stadiums - either stadium server (1) or from .cpk (2): " .. tostring(rnd_server_or_cpk) )
  
end


local function is_it_stadium_file(filename)
    filename = string.lower(filename)
    if 
       string.match(filename, "common\\bg\\model\\bg\\ad") or
       string.match(filename, "common\\bg\\model\\bg\\audi") or
       -- comment-out only the next line of code if you want to use only those adboards which were added and configured via .cpk files
       string.match(filename, "common\\bg\\model\\bg\\bigflag") or -- ?? dt30.cpk
       string.match(filename, "common\\bg\\model\\bg\\bill") or
       string.match(filename, "common\\bg\\model\\bg\\cheer") or
       string.match(filename, "common\\bg\\model\\bg\\cornerflag") or -- ?? dt30.cpk
       string.match(filename, "common\\bg\\model\\bg\\effect") or
       string.match(filename, "common\\bg\\model\\bg\\goal") or -- Villa park
       string.match(filename, "common\\bg\\model\\bg\\pitch") or
       string.match(filename, "common\\bg\\model\\bg\\scarecrow") or
       string.match(filename, "common\\bg\\model\\bg\\sky") or
       string.match(filename, "common\\bg\\model\\bg\\stadium") or
       string.match(filename, "common\\bg\\model\\bg\\staff") or
       string.match(filename, "common\\bg\\model\\bg\\tv") or
       string.match(filename, "common\\character1\\model\\character") or -- Most of the italian stadiums
       string.match(filename, "common\\demo\\anime\\behavior\\fixdemo\\animations") or -- Atleti Azzuri
       string.match(filename, "common\\demo\\fixdemo\\change") or -- Villa park
       string.match(filename, "common\\demo\\fixdemo\\end") or 
       string.match(filename, "common\\demo\\fixdemo\\ent") or
       string.match(filename, "common\\demo\\fixdemo\\goal") or -- Villa park
       string.match(filename, "common\\demo\\fixdemo\\result") or -- Villa park
       string.match(filename, "common\\demo\\fixdemoobj\\passage") or
       string.match(filename, "common\\demo\\light") or -- Villa park, but dt12.cpk has only st029 files (only for Konami Stadium)
       string.match(filename, "common\\demo\\mob\\mob_") or -- Renzo Barbera
       string.match(filename, "common\\render\\model\\bg\\hit\\bill") or 
       string.match(filename, "common\\render\\model\\bg\\hit\\stadium")
       then
          return true
    else
          return false
    end
end

local function which_stadium_preview_tex(filename)
    return string.match(string.lower(filename), "common\\render\\thumbnail\\stadium\\(st%d+%.dds)")
end


local function get_new_stadium_path(ctx)
    local tid = tonumber(ctx.tournament_id)
    local stadium_path
    local custom_st_id
    local custom_name
    
    if tid and not ctx.is_replay_gallery then
        if rnd_server_or_cpk and rnd_server_or_cpk == 1 and tid <= 5 and random_num_exhib ~= nil then
            -- special case for exhibition mode with random stadium selection enabled ...
            stadium_path = all_stadiums_map[random_num_exhib][3]
            custom_name = all_stadiums_map[random_num_exhib][2]
            custom_st_id = all_stadiums_map[random_num_exhib][1]
        elseif competition_assignment_map[tid] == nil and team_assignment_map[ctx.home_team] ~= nil then 
            -- this particular competiton mode does not have the stadium assigned via map_competitions.txt
            -- .. individual home team assignments from map_teams.txt will be used here
            stadium_path = team_assignment_map[ctx.home_team][3]
            custom_name = team_assignment_map[ctx.home_team][2]
            custom_st_id = team_assignment_map[ctx.home_team][1]
        elseif competition_assignment_map[tid] ~= nil and team_assignment_map[ctx.home_team] ~= nil and has_value(override_competitions, tid) and ctx.match_info ~= 53 then
            -- this particular competiton mode HAS the stadium assigned via map_competitions.txt,
            -- .. but it is also listed in override_competitions, 
            -- .. AND it is not FINAL match (e.g. in league cup, which may possibly be held at neutral ground - and having stadium assigned already in map_competitions.txt), 
            -- .. therefore, individual home team assignments from map_teams.txt will be used here again
            stadium_path = team_assignment_map[ctx.home_team][3]
            custom_name = team_assignment_map[ctx.home_team][2]
            custom_st_id = team_assignment_map[ctx.home_team][1]
        else
            -- nothing else but possible competition assignment in map_competitions.txt
            -- .. stadium from assignment from map_competitions.txt will be used, if there is any
            -- log("four")
            if tid > 5 and competition_assignment_map[tid] ~= nil then
                if ctx.match_info == 53 and competition_assignment_map[tid][random_num_comp][4] ~= "" and competition_assignment_map[tid][random_num_comp][5] ~= "" and competition_assignment_map[tid][random_num_comp][6] ~= "" then
                    -- is this the final match of a competition (53)?
                    stadium_path = competition_assignment_map[tid][random_num_comp][6] -- use the stadium assigned for final match
                    custom_name = competition_assignment_map[tid][random_num_comp][5]
                    custom_st_id = competition_assignment_map[tid][random_num_comp][4]
                elseif competition_assignment_map[tid][random_num_comp][1] ~= "" and competition_assignment_map[tid][random_num_comp][2] ~= "" and competition_assignment_map[tid][random_num_comp][3] ~= "" then
                    stadium_path = competition_assignment_map[tid][random_num_comp][3]  -- use the regular stadium assigned for this competition
                    custom_name = competition_assignment_map[tid][random_num_comp][2]
                    custom_st_id = competition_assignment_map[tid][random_num_comp][1]
                end
            end
        end
    elseif ctx.is_replay_gallery and ctx.is_replay_gallery == true then
        if replay_source_stadium_map == "all_stadiums_map" then
            stadium_path = all_stadiums_map[replay_source_stadium_key][3]
            custom_name = all_stadiums_map[replay_source_stadium_key][2]
            custom_st_id = all_stadiums_map[replay_source_stadium_key][1]
        elseif replay_source_stadium_map == "team_assignment_map" then
            stadium_path = team_assignment_map[replay_source_stadium_key][3]
            custom_name = team_assignment_map[replay_source_stadium_key][2]
            custom_st_id = team_assignment_map[replay_source_stadium_key][1]
        end
    end
    ctx.stadium_path=stadium_path
    return stadium_path, custom_st_id, custom_name
end

local function make_key(ctx, filename)
    local custom_st_id
    local custom_name
    if ctx.is_edit_mode == nil and stadium_switched == true then -- do something only if edit mode is NOT active 
        if is_it_stadium_file(filename) then -- any stadium file, but preview
            -- log(string.format("it_is_stadium_file: %s", filename))
              new_stadium_path, custom_st_id, custom_name = get_new_stadium_path(ctx)
              if new_stadium_path then
                    -- log(string.format("new_stadium_path: %s", new_stadium_path .. "\\" .. filename))
                    return new_stadium_path .. "\\" .. filename
              end
        end
        -- now override the preview, if the stadium has already been predetermined by the game
        local spt_fname = which_stadium_preview_tex(filename)
        if spt_fname or spt_home_fname then       
            -- ctx.stadium_choice --> sider 3.4.0+ required
            if ctx.stadium_choice then
                return
            end
            
            new_stadium_path, custom_st_id, custom_name = get_new_stadium_path(ctx)
            if new_stadium_path then
                return string.gsub(new_stadium_path .. "\\" .. filename, "\\st%d%d%d%.dds", string.format("\\st%s.dds", custom_st_id))
            end
        end
    end
end

local function nil2str(value)
    if value ~= nil then
        return value
    else
        return "N/A"
    end
end

local function get_filepath(ctx, filename, key)
	if ctx.is_edit_mode == nil then -- do something only if edit mode is NOT active
	    if new_stadium_path then
	        -- log(string.format("Stadium file assignment for team ID %s (competition ID %s) - %s\\%s", nil2str(ctx.home_team), nil2str(ctx.tournament_id), stadiumroot, key))
	        return string.format("%s\\%s", stadiumroot, key)
	    end
	end
end

-- since sider 3.3.4 this event allows only stadium_id to be changed in options!! other params are read-only (day/weather/season)
local function set_stadium(ctx, options)
    random_num_exhib = nil
    random_num_comp = nil
    
    if ctx.is_edit_mode == nil and ctx.tournament_id then
        stadium_switched = false
        local tid = tonumber(ctx.tournament_id)
        local custom_st_id
        
        -- ctx.stadium_choice --> sider 3.4.0+ required
        if ctx.stadium_choice and ctx.stadium_choice ~= 253 and ctx.stadium_choice ~= 254 then
            -- exhibition modes, and the choice is neither "Home stadium" nor "Random" (i.e. - the choice is fixed stadium)
            -- therefore, do not change the stadium
            return
        elseif ctx.stadium_choice and ctx.stadium_choice == 253 and has_value(teams_with_cpk_homegrounds, ctx.home_team) then
            -- exhibition modes, the choice is "Home", but the team is listed to use exclusive .cpk home ground
            -- therefore, do not change the stadium
            return
        elseif ctx.stadium_choice and ctx.stadium_choice == 254 then
            -- exhibition modes, the choice is "Random"
            -- change the stadium depending on the value of rnd_server_or_cpk
            if rnd_server_or_cpk and rnd_server_or_cpk == 2 then
                -- if .cpk is the source (rnd_server_or_cpk == 2), do not change the stadium 
                return
            else
                -- Random setting in exhibition modes, stadium server is the source - always allow for random selection, even if the team has exclusive .cpk home ground
                select_random_stadium(ctx)
                custom_st_id = all_stadiums_map[random_num_exhib][1]
                stadium_switched = true
                log("Switching to stadium with ID " .. custom_st_id .. " (random stadium selection in exhibition mode)")
                return { stadium = tonumber(custom_st_id) }
            end
        end
    	
        if ctx.home_team ~= nil and competition_assignment_map[tid] == nil and team_assignment_map[ctx.home_team] ~= nil then
            custom_st_id = team_assignment_map[ctx.home_team][1]
            stadium_switched = true
            log("Switching to stadium with ID " .. custom_st_id .. " (basic home team assignment)")
            -- return the stadium id to indicate that this change is final. This stops processing
            -- of the event and modules further down the list will not receive this event.
            return { stadium = tonumber(custom_st_id) } -- Stadium id of the served stadium
        elseif ctx.home_team ~= nil and competition_assignment_map[tid] ~= nil and team_assignment_map[ctx.home_team] ~= nil and has_value(override_competitions, tid) and ctx.match_info ~= 53 then
            -- comptition assignment will be overriden by team assignment
            custom_st_id = team_assignment_map[ctx.home_team][1]
            stadium_switched = true
            log("Switching to stadium with ID " .. custom_st_id .. " (team overrides competition)")
            return { stadium = tonumber(custom_st_id) }
        elseif tid > 5 and competition_assignment_map[tid] ~= nil then
            select_random_stadium(ctx)
            if ctx.match_info == 53 and competition_assignment_map[tid][random_num_comp][4] ~= "" and competition_assignment_map[tid][random_num_comp][5] ~= "" and competition_assignment_map[tid][random_num_comp][6] ~= "" then
                -- is this the final match of a competition (53)?
                custom_st_id = competition_assignment_map[tid][random_num_comp][4]
                stadium_switched = true
                log("Switching to stadium with ID " .. custom_st_id .. " (final match of the competition)")
                return { stadium = tonumber(custom_st_id) }
            else 
                if has_value(teams_with_cpk_homegrounds, ctx.home_team) == false and competition_assignment_map[tid][random_num_comp][1] ~= "" and competition_assignment_map[tid][random_num_comp][2] ~= "" and competition_assignment_map[tid][random_num_comp][3] ~= "" then
                    -- competition mode, pre-finals, no exclusive .cpk home ground -> change the stadium
                    custom_st_id = competition_assignment_map[tid][random_num_comp][1]
                    stadium_switched = true
                    log("Switching to stadium with ID " .. custom_st_id .. " (pre-finals stage of the competition)")
                    return { stadium = tonumber(custom_st_id) }
                end
            end 
      end
	end
  get_new_stadium_path(ctx)--calling this because set_stadium function is the only certain function that will be called and we need to make at least 1 call to get stadium path to set it in the CTX object for use in niceAndClean module

end


local function enter_replay_gallery(ctx)
    replay_stad_id = nil
    replay_source_stadium_map = nil
    replay_source_stadium_key = nil
end

local function exit_replay_gallery(ctx)
    replay_stad_id = nil
    replay_source_stadium_map = nil
    replay_source_stadium_key = nil
end

local function stadiumIdExists(stID)
    -- is there any EXTERNAL stadium with this ID? if there's one, return the index of the first matching stadium
    for key, row in pairs(all_stadiums_map) do
        if tonumber(row[1]) == tonumber(stID) then
            return true, key
        end
    end
    return false, nil
end


local function set_stadium_for_replay(ctx, options)
    stadium_switched = false
    replay_source_stadium_map = nil
    replay_source_stadium_key = nil
    
    --[[log("set_stadium_for_replay:: initial stadium ID: " .. options.stadium)
    log("set_stadium_for_replay:: initial stadium conditions: timeofday -> " .. options.timeofday .. ", weather -> " .. options.weather .. ", season -> " .. options.season )
    log("set_stadium_for_replay:: home team: " .. ctx.home_team)
    log("set_stadium_for_replay:: tournament id: " .. ctx.tournament_id)
    log("set_stadium_for_replay:: replay_tournament_type: " .. ctx.replay_tournament_type)]]--
    
    local initial_stad_id = tonumber(options.stadium)
    local stadium_exists, stadium_key = stadiumIdExists(initial_stad_id)
    log(string.format("(Replay) stadiumIdExists(%s): %s", initial_stad_id, stadium_exists))
    
    -- IMPORTANT: NEITHER ctx.tournament_id, ctx.stadium_choice NOR ctx.match_info are available during replays
    if ctx.home_team ~= nil and team_assignment_map[ctx.home_team] ~= nil then
        -- team has home ground assigned in map_teams.txt
        if has_value(teams_with_cpk_homegrounds, ctx.home_team) == false and initial_stad_id == tonumber(team_assignment_map[ctx.home_team][1]) then  -- a)
            -- no exclusive .cpk homeground and saved stadium ID matches one from the map_teams.txt -> must have been homegorund assigned via stadium server
            replay_stad_id = initial_stad_id
            stadium_switched = true
            replay_source_stadium_map = "team_assignment_map"
            replay_source_stadium_key = ctx.home_team
            log("(Replay) Switching to stadium with ID " .. replay_stad_id .. " (basic home team assignment)")
        elseif initial_stad_id ~= tonumber(team_assignment_map[ctx.home_team][1]) then  -- b) / c)
            -- team has stadium in map_teams.txt, but saved stadium ID does not match 
            -- saved stadium ID does not match one from the map_teams.txt -> looks like it was either random selection or fixed .cpk stadium
            if stadium_exists == true and stadium_key ~= nil and has_value(teams_with_cpk_homegrounds, ctx.home_team) == false then
                -- probably random selection from stadium server?
                replay_stad_id = all_stadiums_map[stadium_key][1]
                stadium_switched = true
                replay_source_stadium_map = "all_stadiums_map"
                replay_source_stadium_key = stadium_key
                log("(Replay) Switching to stadium with ID " .. replay_stad_id .. " (first stadium with matching ID from the list of all stadiums)")
            else
                -- probably fixed .cpk stadium or exclusive .cpk homeground?
                stadium_switched = false
            end
        end
    else
        -- team does not have home ground assigned in map_teams.txt
        if stadium_exists == true and stadium_key ~= nil then -- and has_value(teams_with_cpk_homegrounds, ctx.home_team) == false then
            -- and it does not have exclusive .cpk homeground ... probably random selection from stadium server?
            replay_stad_id = all_stadiums_map[stadium_key][1]
            stadium_switched = true
            replay_source_stadium_map = "all_stadiums_map"
            replay_source_stadium_key = stadium_key
            log("(Replay) Switching to stadium with ID " .. replay_stad_id .. " (first stadium with matching ID from the list of all stadiums)")
        else
            -- probably fixed .cpk stadium or exclusive .cpk homeground?
            stadium_switched = false
        end
    end
    
    if stadium_switched == true then
        return { stadium = tonumber(replay_stad_id) }
    else
        return
    end
end

local function change_stadium_name(ctx, stadium_name, stadium_id)
    if ctx.is_edit_mode == nil then -- do something only if edit mode is NOT active
               
        -- ctx.stadium_choice --> sider 3.4.0+ required
        if not stadium_switched or (ctx.stadium_choice and ctx.tournament_id <= 5) then
            -- if we did not switch the stadium then no need to alter the name, OR:
            -- if it is exhibition mode and stadium selection has not been finalized yet ==> then do nothing.
            return
        end
        
        local new_stadium_path
        local custom_st_id
        local new_stadium_name
        
        new_stadium_path, custom_st_id, new_stadium_name = get_new_stadium_path(ctx)
        if new_stadium_name ~= nil and new_stadium_name ~= "" then
            log(string.format("switching stadium-name: %s --> %s", stadium_name, new_stadium_name))
            stadium_switched = true
            return new_stadium_name
        end
    end
end

local function init(ctx)
    if stadiumroot:sub(1,1)=='.' then
        stadiumroot = ctx.sider_dir .. stadiumroot
    end
    load_map_txt("map_teams.txt")
    load_map_txt("map_competitions.txt")
    merge_maps() -- create one master-table, which is going to have one entry for every stadium assigned - either via teams or competitions
    ctx.register("set_stadium", set_stadium)
    ctx.register("set_stadium_for_replay", set_stadium_for_replay)
    ctx.register("get_stadium_name", change_stadium_name)
    ctx.register("livecpk_make_key", make_key)
    ctx.register("livecpk_get_filepath", get_filepath)
    ctx.register("set_home_team", home_team_selected)
    ctx.register("enter_replay_gallery", enter_replay_gallery)
    ctx.register("exit_replay_gallery", exit_replay_gallery)
end

return { init = init }