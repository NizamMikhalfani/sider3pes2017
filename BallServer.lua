-- Ball server for PES 2020: assign the ball for the home team (based on either competition or the team or the manual selection)
-- Custom content is used, not LiveCPK/game: content\ball-server is the root
-- author: zlac, 2018-2020
-- current version: 1.00
-- originally posted on evo-web

local ballroot = ".\\content\\ball-server\\"
local version = "1.00"
local random_num
local settings
local _empty = {}

local team_assignment_map = {}
local competition_assignment_map = {}
local all_balls_map = {}

local info_text = ""
local manual_ball_idx
local manual_ball_info = "Manually selected ball: None"
local manual_selection_status = "Off"
local manual_selection_status_info = "Selection mode: automatic map assignments"
local always_random_status = "Off"
local total_balls

local _ball_info = {}
local current_ball_preview_path

local exhib_same_league_tid

local RELOAD_MAPS_KEY = 0x30 -- 0 key (not the NUMPAD zero!!)
local ALWAYS_USE_RANDOM_BALL_KEY = 0x36 -- 6 key (not the NUMPAD 6!!)
local SET_AS_FAVORITE_BALL_KEY = 0x37 -- 7 key (not the NUMPAD 7!!)
local USE_FAVORITE_BALL_KEY = 0x38 -- 8 key (not the NUMPAD 8!!)
local SWITCH_SELECTION_MODE_KEY = 0x39 -- 9 key (not the NUMPAD 9!!)
local DEL_TEXT_KEY = 0x2E
local PREVIOUS_BALL_KEY = 0x21 -- Page Up
local NEXT_BALL_KEY = 0x22 -- Page Down


-- override_competitions contains comma-separated ID's of the competitions that allow for team-assigned balls to have precedence before competiton-assigned balls
-- .. e.g. you've assigned an official ball for ALL exhibition mode matches (tid 65535) in map_competitions.txt, but you still want to use
-- .. home-team ball for those teams that have it assigned in map_teams.txt -> add 65535 in override_competitions
-- initially, only Exhibition mode matches are included in competition overrides
-- BEGIN CUSTOMIZABLE LUA TABLE
local override_competitions = {65535, }
-- END CUSTOMIZABLE LUA TABLE



-- remove trailing and leading whitespace from string
local function trim(s)
  return s:gsub("^%s*(.-)%s*$", "%1")
end

local function nil2str(value)
	if value ~= nil then
		return value
	else
		return "N/A"
	end
end

local function get_common_lib(ctx)
    return ctx.common_lib or _empty
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

local function clear_table(t)
    for k,v in pairs(t) do
        t[k]=nil
    end
end

local function load_map_txt(filename)
    local delim = ","
    local data = assert(io.lines(ballroot .. filename))
    log(filename .. " found in " .. ballroot)

    if filename == "map_teams.txt" then
        clear_table(team_assignment_map)
    end
    if filename == "map_competitions.txt" then
        clear_table(competition_assignment_map)
    end

    for line in data do
       line = trim(string.gsub(line, "^\239\187\191", "")) -- removes UTF BOM bytes at the beginning of the first line in .txt file and leading/trailing whitespaces in every line
       local fields = split(line, delim)
       if #fields > 1 then
	       for i=1,#fields do
	           fields[i] = trim(fields[i])
	       end
	       if fields[1] ~= nil and fields[1] ~= "" then
	          if filename == "map_teams.txt" and fields[2] ~= nil and fields[3] ~= nil then
	      	  	 team_assignment_map[tonumber(fields[1])] = {fields[2], fields[3]}
	      	  	 log(string.format(" ==> %s ball assignment::   %s (ballID: %s): %s", filename, fields[1], fields[2], fields[3]))
	      	  end
	          if filename == "map_competitions.txt" and fields[2] ~= nil and fields[3] ~= nil
                      and fields[4] ~= nil and fields[5] ~= nil and fields[6] ~= nil and fields[7] ~= nil then
	      	  	 if competition_assignment_map[tonumber(fields[1])] ~= nil then
	      	  	 	table.insert(competition_assignment_map[tonumber(fields[1])], {fields[2], fields[3], fields[4], fields[5], fields[6], fields[7]})
	      	  	 else
	      	  	 	competition_assignment_map[tonumber(fields[1])] = { {fields[2], fields[3], fields[4], fields[5], fields[6], fields[7]} }
	      	  	 end
	      	  	 log(string.format(" ==> %s ball assignment::   %s (ballID: %s, name: %s) (for final match: %s %s | for winter matches: %s %s)", filename, fields[1], fields[2], fields[3], fields[4], fields[5], fields[6], fields[7]))
	      	  end
	       end
	   end
    end
end

local function has_value(tab, val)
    for index, value in pairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end


local function dump_table(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump_table(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local function tableLength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

local function valueArrayExistsInTable(tbl, val, startAt)
    for key, value in pairs(tbl) do
        if val[startAt] == value[1] and val[startAt+1] == value[2] then
            return true
        end
    end
    return false
end

local function compare_ball_names(a,b)
  return string.lower(a[2]) < string.lower(b[2]) -- {ball_ID, ball_name} pairs, compare names
end

local function merge_maps()
    local idx = 1
    clear_table(all_balls_map)

    for key, row in pairs(team_assignment_map) do
        if row[1] ~= nil and row[1] ~= "" and row[2] ~= nil and row[2] ~= "" and row[3] ~= nil and row[3] ~= "" and not valueArrayExistsInTable(all_balls_map, row, 1) then
            all_balls_map[idx] = {row[1], row[2]}
            idx = idx + 1
        end
    end

    for key, value in pairs(competition_assignment_map) do
        for index, row in pairs(value) do
            if row[1] ~= nil and row[1] ~= "" and row[2] ~= nil and row[2] ~= "" and not valueArrayExistsInTable(all_balls_map, row, 1) then
                all_balls_map[idx] = {row[1], row[2]}
                idx = idx + 1
            end
            -- see if the ball for final match is already included ...
            if row[3] ~= nil and row[3] ~= "" and row[4] ~= nil and row[4] ~= "" and not valueArrayExistsInTable(all_balls_map, row, 3) then
                all_balls_map[idx] = {row[3], row[4]}
                idx = idx + 1
            end
            -- see if the ball for winter matches is already included ...
            if row[5] ~= nil and row[5] ~= "" and row[6] ~= nil and row[6] ~= "" and not valueArrayExistsInTable(all_balls_map, row, 5) then
                all_balls_map[idx] = {row[5], row[6]}
                idx = idx + 1
            end
        end
    end

    total_balls = tableLength(all_balls_map)
    if total_balls > 0 then
        manual_ball_idx = 1
    end
    log(string.format("%s unique balls available for manual selection.", total_balls))
    -- log(dump_table(all_balls_map))
    table.sort(all_balls_map, compare_ball_names)
    -- log(dump_table(all_balls_map))
end


local function is_it_ball_file(filename)
    filename = string.lower(filename)
    if
        string.match(filename, "asset\\model\\ball\\ball%d+\\") or               -- ball model/texture
        string.match(filename, "common\\render\\thumbnail\\ball\\ball_%d+%.dds") -- ball preview
    then
        -- log(string.format("Ball file requested: %s", filename))
        return true
    else
        return false
    end
end

local function replace_ball_ids(ball_path, new_ball_id)
    local old_id
    local changed
    ball_path = string.lower(ball_path)
    -- ball preview
    if string.match(ball_path, "common\\render\\thumbnail\\ball\\ball_%d+%.dds") then
        old_id = string.match(ball_path, "common\\render\\thumbnail\\ball\\ball_(%d+)%.dds")
        changed = 1
        return string.gsub(ball_path, old_id, new_ball_id)
    end
    -- ball model
    if string.match(ball_path, "asset\\model\\ball\\ball%d+\\#win") then
        old_id = string.match(ball_path, "asset\\model\\ball\\ball(%d+)\\#win")
        changed = 1
        return string.gsub(ball_path, old_id, new_ball_id)
    end
    -- ball textures
    if string.match(ball_path, "asset\\model\\ball\\ball%d+\\#windx11\\ball%d+_.*%.ftex") then
        old_id = string.match(ball_path, "asset\\model\\ball\\ball(%d+)\\#windx11\\ball%d+_.*%.ftex")
        changed = 1
        return string.gsub(ball_path, old_id, new_ball_id)
    end

    if changed == nil then
        return ball_path
    end
end

local function get_ball_preview_path(ball_info)
    if ball_info then
        local ball_id = ball_info[1]
        local ball_prefix = ball_info[2]
        return string.format("%s%s\\common\\render\\thumbnail\\ball\\ball_%03d.dds", ballroot, ball_prefix, ball_id)
    end
end

local function get_new_ball_path(ctx, filename)
	local tid = tonumber(ctx.tournament_id)
	local ball_path_prefix
    local new_ball_id
    local new_filename

    if tid then
        if always_random_status == "On" and random_num then
            ball_path_prefix = all_balls_map[random_num][2]
            new_ball_id = all_balls_map[random_num][1]
            -- always-random mode selection from overlay trumps everything
        elseif manual_selection_status == "On" and manual_ball_idx then
            -- after that, manual selection from overlay trumps everything
            ball_path_prefix = all_balls_map[manual_ball_idx][2]
            new_ball_id = all_balls_map[manual_ball_idx][1]
        elseif competition_assignment_map[tid] == nil and team_assignment_map[ctx.home_team] ~= nil then
            -- this particular competiton mode does not have the ball assigned via map_competitions.txt
            -- .. individual home team assignments from map_teams.txt will be used here
            ball_path_prefix = team_assignment_map[ctx.home_team][2]
            new_ball_id = team_assignment_map[ctx.home_team][1]
        elseif competition_assignment_map[tid] ~= nil and team_assignment_map[ctx.home_team] ~= nil and has_value(override_competitions, tid) == true then
            -- this particular competiton mode HAS the ball assigned via map_competitions.txt,
            -- .. but it is also listed in override_competitions, therefore
            -- .. individual home team assignments from map_teams.txt will be used here again
            ball_path_prefix = team_assignment_map[ctx.home_team][2]
            new_ball_id = team_assignment_map[ctx.home_team][1]
		elseif exhib_same_league_tid and competition_assignment_map[exhib_same_league_tid] ~= nil and random_num ~= nil then
			-- exhibition mode, both teams belong to the same league
            ball_path_prefix = competition_assignment_map[exhib_same_league_tid][random_num][2]
			new_ball_id = competition_assignment_map[exhib_same_league_tid][random_num][1]
			if ctx.season == 1 and competition_assignment_map[exhib_same_league_tid][random_num][6] ~= "" then
				-- ... and if it is winter, try selecting winter ball (if any)
                ball_path_prefix = competition_assignment_map[exhib_same_league_tid][random_num][6]  -- use the ball assigned for winter-season matches
                new_ball_id = competition_assignment_map[exhib_same_league_tid][random_num][5]
			end
        else
            -- nothing else but possible competition assignment in map_competitions.txt
            -- .. ball assignment from map_competitions.txt will be used, if there is any
            if competition_assignment_map[tid] ~= nil then
                -- is this the final match of a competition (53)?
                if ctx.match_info == 53 and competition_assignment_map[tid][random_num][4] ~= "" then
                    ball_path_prefix = competition_assignment_map[tid][random_num][4]  -- use the ball assigned for final match
                    new_ball_id = competition_assignment_map[tid][random_num][3]
                elseif (tid == 20 or tid == 81) and competition_assignment_map[tid][random_num][6] ~= "" and competition_assignment_map[tid][random_num][2] ~= "" then
                    -- Ligue 1 & 2 use winter ball in the second half of the season
                    if ctx.match_id <= 19 then -- 1st half of the season
                        ball_path_prefix = competition_assignment_map[tid][random_num][2]  -- use the regular ball assigned for this competition
                        new_ball_id = competition_assignment_map[tid][random_num][1]
                    else -- 2nd half of the season
                        ball_path_prefix = competition_assignment_map[tid][random_num][6]  -- use the ball assigned for winter-season matches
                        new_ball_id = competition_assignment_map[tid][random_num][5]
                    end
                elseif ctx.season == 1 and competition_assignment_map[tid][random_num][6] ~= "" then
                    ball_path_prefix = competition_assignment_map[tid][random_num][6]  -- use the ball assigned for winter-season matches
                    new_ball_id = competition_assignment_map[tid][random_num][5]
                else
                    ball_path_prefix = competition_assignment_map[tid][random_num][2]  -- use the regular ball assigned for this competition
                    new_ball_id = competition_assignment_map[tid][random_num][1]
                end
            end
       end

        -- important ... scour the source ball path (filename arg) for triple-digit ball IDs ... gotta be replaced every time with the ballID from ball server
        -- that ID should be retrievable from competition_assignment_map[tid][random_num][1] or from team_assignment_map[ctx.home_team][1]
        if filename ~= "dummy_from_change_ball_name" and new_ball_id and ball_path_prefix then
            -- log(string.format("Path before ID replacement in Ball path: %s", filename))
            new_filename = replace_ball_ids(filename, new_ball_id)
			if manual_selection_status == "Off" and always_random_status == "Off" then
				manual_selection_status_info = string.format("Selection mode: automatic map assignments (using ball %s)", ball_path_prefix)
            elseif manual_selection_status == "Off" and always_random_status == "On" then
                manual_selection_status_info = string.format("Selection mode: always-random ball selection (using ball %s)", ball_path_prefix)
            end
            -- log(string.format("Path after ID replacement in Ball path: %s", new_filename))

			_ball_info[1] = new_ball_id
            _ball_info[2] = ball_path_prefix
            current_ball_preview_path = get_ball_preview_path(_ball_info)						   																		 
            return ball_path_prefix .. "\\" .. new_filename
		elseif filename ~= "dummy_from_change_ball_name" then
			if manual_selection_status == "Off" then
				manual_selection_status_info = string.format("Selection mode: automatic map assignments (using ball: %s)", "No ball(s) assigned to this competition")
                _ball_info[1] = nil
                _ball_info[2] = nil
                current_ball_preview_path = nil
			end
        else
            return ball_path_prefix
        end
    end

end

local function teams_selected(ctx, home_team_id, away_team_id)
	--whenever game selects new home_team, pick a random index of a ball to be used on competition level (e.g. if multiple balls are assigned to one competition_ID)
	local tid = tonumber(ctx.tournament_id)
	random_num = nil
	exhib_same_league_tid = nil
	
	if manual_selection_status == "Off" then
        _ball_info[1] = nil
        _ball_info[2] = nil
		current_ball_preview_path = nil
        manual_selection_status_info = "Selection mode: automatic map assignments"

        if always_random_status == "On" then
            manual_selection_status_info = "Selection mode: always-random ball selection"
        end
	end

	if always_random_status == "On" then
        if #all_balls_map == 1 then
            random_num = 1
        else
            random_num = math.random(1, #all_balls_map)
        end
        log("Selecting always-random ball for competition ID " .. tostring(tid) .. ": Ball no. " .. tostring(random_num) .. " (from " .. tostring(#all_balls_map) .. " ball(s) available)")
	elseif tid == 65535 then
        -- are both teams in exhibition mode from the same playable league?
        log("Checking if both teams in exhibition belong to the same league ... ")
		exhib_same_league_tid = get_common_lib(ctx).tid_same_league(home_team_id, away_team_id)
		        
		if exhib_same_league_tid ~= nil then
			log("... they do!")
			log("... mapped TournamentID for exhibition mode: " .. exhib_same_league_tid )
			if competition_assignment_map[exhib_same_league_tid] ~= nil then
				log(string.format("... competition with ID %s has %s balls assigned.", exhib_same_league_tid, #competition_assignment_map[exhib_same_league_tid]))
				if #competition_assignment_map[exhib_same_league_tid] == 1 then
					-- if there's only one ball assigned to competition, set "random" number to 1
					-- do the same if replay mode is active - tid is not reliably available, so assume there's only 1 ball available
					random_num = 1
				else
					-- if there are more balls, select one index rendomly
					-- random_num = math.random(1, #competition_assignment_map[tid])
					random_num = math.random(#competition_assignment_map[exhib_same_league_tid])
				end
				log("Selecting random ball for competition ID " .. tostring(exhib_same_league_tid) .. " in exhibition mode (both teams belong to the same league): Ball no. " .. tostring(random_num) .. " (from " .. tostring(#competition_assignment_map[exhib_same_league_tid]) .. " ball(s) available)")
			else
				log(string.format("... competition with ID %s has no balls assigned.", exhib_same_league_tid))
				-- since the mapped competition does not have its own balls, revert to default exhibition mode random selection
				if competition_assignment_map[tid] ~= nil then
					if #competition_assignment_map[tid] == 1 then
						random_num = 1
					else
						random_num = math.random(#competition_assignment_map[tid])
					end
					log("Selecting random ball for exhibition mode: Ball no. " .. tostring(random_num) .. " (from " .. tostring(#competition_assignment_map[tid]) .. " ball(s) available)")
				end
			end
		else
			log("... they don't!")
            -- if not from the same league, make sure we still generate random_num for exhibition mode ...
            if competition_assignment_map[tid] ~= nil then
                if #competition_assignment_map[tid] == 1 then
                    random_num = 1
                else
                    random_num = math.random(#competition_assignment_map[tid])
                end
                log("Selecting random ball for exhibition mode: Ball no. " .. tostring(random_num) .. " (from " .. tostring(#competition_assignment_map[tid]) .. " ball(s) available)")
            end
        end
	--
	elseif competition_assignment_map[tid] ~= nil and manual_selection_status == "Off" then
		-- if #competition_assignment_map[tid] == 1 or ctx.is_replay_gallery == true then
		if #competition_assignment_map[tid] == 1 then
			random_num = 1
		else
		    random_num = math.random(1, #competition_assignment_map[tid])
		end
		log("Selecting random ball for competition ID " .. tostring(tid) .. ": Ball no. " .. tostring(random_num) .. " (from " .. tostring(#competition_assignment_map[tid]) .. " ball(s) available)")
	end

    -- in Exhibition mode, we can update ball info in overlay
    if tid == 65535 then
        get_new_ball_path(ctx, "")
    end
end

local function make_key(ctx, filename)
	-- if ctx.is_edit_mode == nil then -- do something only if edit mode is NOT active
        if is_it_ball_file(filename) then
              -- log(string.format("Into make_key (ball file) ... (%s)", filename))
		      local new_ball_path = get_new_ball_path(ctx, filename)
		      if new_ball_path then
                  -- log("Into make_key (ball file): " .. new_ball_path .. "\\" .. filename)
		      	  -- return new_ball_path .. "\\" .. filename
                  return new_ball_path
		      end
		end
	-- end
end

local function get_filepath(ctx, filename, key)
    -- log(string.format("Into get_filepath ... (%s, %s)", filename, key))
	-- if ctx.is_edit_mode == nil then -- do something only if edit mode is NOT active
        if key and filename and filename ~= key then -- filename ~= key should ensure that it really is a file from custom repository, with modified path prefix???
	        -- log(string.format("Ball assignment for team ID %s (competition ID %s) - %s\\%s", nil2str(ctx.home_team), nil2str(ctx.tournament_id), ballroot, key))
	        return string.format("%s\\%s", ballroot, key)
	    end
	-- end
end

local function change_ball_name(ctx, ballname)
	-- if ctx.is_edit_mode == nil then -- do something only if edit mode is NOT active
	    local s = get_new_ball_path(ctx, "dummy_from_change_ball_name")
	    if s and ctx.home_team then -- ctx.home_team is nil in edit mode, but ctx.tournament_id isn't (it's 0) ... home_team check should hopefully prevent the script from switching data in edit mode
	        s = s:sub(1, 139) -- possible ball name length limit (from Ball.bin)
	        log(string.format("switching ball-name: %s --> %s", ballname, s))
	        return s
	    end
	-- end
end

local opts = { image_width = 0.15, image_hmargin = 0, image_vmargin = 0 }
local function overlay_on(ctx)
    local text = string.format("version %s\nBallServer commands:\nPress [0] to reload map .txt files\nPress [DEL] to clear info messages\nPress [6] to toggle 'Always use random ball' mode\n     Always-random ball mode status: %s\nPress [9] to switch between using map assignments/manual selection\n     Manual selection mode subcommands:\n       [PageUp][PageDn] to manually select previous/next ball\n       [7] to set current manual selection as favorite ball\n       [8] to use your favorite ball \n\n%s\n%s\n\n%s", version, always_random_status, manual_selection_status_info, manual_ball_info, info_text)
	local image = current_ball_preview_path
	return text, image, opts
end

local function load_ini(filename)
    local t = {}
    local data = assert(io.lines(ballroot .. filename))
    log(filename .. " found in " .. ballroot)

    for line in data do
        local name, value = string.match(line, "^([%w_]+)%s*=%s*([-%w%d.]+)")
        if name and value then
            value = tonumber(value) or value
            t[name] = value
            log(string.format("Using setting: %s = %s", name, value))
        end
    end
    return t
end

local function save_ini(filename)
    local f = io.open(ballroot .. filename, "wt")
    f:write(string.format("# BallServer settings. Generated by BallServer.lua\n"))
    f:write("\n")
    local keys = {}
    for name,value in pairs(settings) do
        keys[#keys + 1] = name
    end
    table.sort(keys)
    for i,name in ipairs(keys) do
        local value = settings[name]
        f:write(string.format("%s = %s\n", name, value))
    end
    f:write("\n")
    f:close()
end

local function key_down(ctx, vkey)
    if vkey == RELOAD_MAPS_KEY then
        log("Starting manual map files reload ... ")
        load_map_txt("map_teams.txt")
        load_map_txt("map_competitions.txt")
        merge_maps()
        manual_ball_idx = nil
        manual_ball_info = "Manually selected ball: None"
        manual_selection_status = "Off"
        if total_balls > 0 then
            manual_ball_idx = 1
        end
        info_text = info_text .. "map_teams.txt and map_competitions.txt reloaded\n"
        log("Manual map files reloading finished.")
    elseif vkey == DEL_TEXT_KEY then
        info_text = ""
    elseif vkey == SWITCH_SELECTION_MODE_KEY then
        if manual_selection_status == "Off" then
            manual_selection_status = "On"
            manual_selection_status_info = "Selection mode: manual selection [PageUp]/[PageDn]"
            manual_ball_info = string.format("Manually selected ball: %s\n", all_balls_map[manual_ball_idx][2])
			current_ball_preview_path = get_ball_preview_path(all_balls_map[manual_ball_idx])
            always_random_status = "Off"
        else
            manual_selection_status = "Off"
            manual_selection_status_info = "Selection mode: automatic map assignments"
            manual_ball_info = string.format("Manually selected ball: None")
            info_text = ""
			current_ball_preview_path = nil							   
        end
    elseif vkey == PREVIOUS_BALL_KEY then
        if manual_selection_status == "On" and total_balls > 0 and manual_ball_idx then
            manual_ball_idx = manual_ball_idx - 1
            if manual_ball_idx < 1 then
                manual_ball_idx = total_balls
            end
            manual_ball_info = string.format("Manually selected ball: %s\n", all_balls_map[manual_ball_idx][2])
			current_ball_preview_path = get_ball_preview_path(all_balls_map[manual_ball_idx])																				 
        end
    elseif vkey == NEXT_BALL_KEY then
        if manual_selection_status == "On" and total_balls > 0 and manual_ball_idx then
            manual_ball_idx = manual_ball_idx + 1
            if manual_ball_idx > total_balls then
                manual_ball_idx = 1
            end
            manual_ball_info = string.format("Manually selected ball: %s\n", all_balls_map[manual_ball_idx][2])
			current_ball_preview_path = get_ball_preview_path(all_balls_map[manual_ball_idx])																				 
        end
    elseif vkey == ALWAYS_USE_RANDOM_BALL_KEY then
        if always_random_status == "Off" then
            always_random_status = "On"
            manual_selection_status = "Off"
            manual_selection_status_info = "Selection mode: always-random ball selection"
            manual_ball_info = string.format("Manually selected ball: None")
            if random_num and ctx.home_team then
                current_ball_preview_path = get_ball_preview_path(all_balls_map[random_num])
                manual_selection_status_info = string.format("Selection mode: always-random ball selection (using ball %s)", all_balls_map[random_num][2])
            else
                current_ball_preview_path = nil
            end
        else
            always_random_status = "Off"
            manual_selection_status = "Off"
            manual_selection_status_info = "Selection mode: automatic map assignments"
            manual_ball_info = string.format("Manually selected ball: None")
            info_text = ""
            current_ball_preview_path = nil
        end
    elseif vkey == SET_AS_FAVORITE_BALL_KEY then
        if manual_selection_status == "On" and manual_ball_idx then
            if all_balls_map[manual_ball_idx] then
                settings["favorite_ball"] = manual_ball_idx
                save_ini("config.ini")
                info_text = info_text .. string.format("Ball %s saved as favorite\n", all_balls_map[manual_ball_idx][2])
            else
                info_text = info_text .. "Could not save favorite ball\n"
            end
        end
    elseif vkey == USE_FAVORITE_BALL_KEY then
        if manual_selection_status == "On" and settings["favorite_ball"] then
            if all_balls_map[tonumber(settings["favorite_ball"])] then
                manual_ball_idx = settings["favorite_ball"]
                manual_ball_info = string.format("Manually selected ball: %s\n", all_balls_map[manual_ball_idx][2])
				current_ball_preview_path = get_ball_preview_path(all_balls_map[manual_ball_idx])																				 
                info_text = info_text .. string.format("Favorite ball %s set as active\n", all_balls_map[manual_ball_idx][2])
            else
                info_text = info_text .. string.format("Could not find favorite ball (idx: %s)\n", settings["favorite_ball"])
            end
        end
    end
end

local function after_set_conditions(ctx)
    -- update ball selection in overlay
    local ball_path = get_new_ball_path(ctx, "")
	if ball_path then
		log(string.format("Ball assigned: %s", ball_path))
	end
	
end

local function init(ctx)
    if ballroot:sub(1,1)=='.' then
        ballroot = ctx.sider_dir .. ballroot
    end

    load_map_txt("map_teams.txt")
    load_map_txt("map_competitions.txt")
    merge_maps()
    settings = load_ini("config.ini")
    math.randomseed(os.time())

    ctx.register("livecpk_make_key", make_key)
    ctx.register("livecpk_get_filepath", get_filepath)
    ctx.register("set_teams", teams_selected)
    ctx.register("get_ball_name", change_ball_name)
    ctx.register("overlay_on", overlay_on)
    ctx.register("key_down", key_down)
    ctx.register("after_set_conditions", after_set_conditions)
end

return { init = init }
