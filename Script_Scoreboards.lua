--=======================================
-- Dynamic Scoreboard Switcher (Competition + League + Exhibition)
-- Made by Javohir Qobilov a.k.a JDPROUZ
-- Specially made for SiderX - © Copyright 2025
--=======================================

local new_file_path
local fileroot = ".\\content\\Scoreboards\\"
local random_num
local random_seeded = false

local competition_assignment_map = {}
local override_competitions = {0}

local TEAM_LEAGUES = {
    ["England\\Premier League"] = { 4071,101,107,4180,377,378,102,382,177,178,104,103,173,100,106,389,396,179,105,208 },
    ["England\\Championship"] = { 176,1760,207,379,4183,383,1589,386,4363,205,387,388,5086,4364,4365,4192,1327,4194,394,395,204,1909,398,399 },
    ["Spain\\LaLiga"] = { 4145,258,172,108,195,259,362,2187,361,366,261,263,370,194,109,196,265,110,4260,267 },
    ["Spain\\LaLiga Segunda"] = { 4302,357,4247,4308,4309,4395,359,111,4146,364,4988,1765,2188,4272,260,2616,266,4259,264,363,4147,268 },
    ["Italy\\Serie A"] = { 234,186,320,4219,4220,124,323,336,119,120,122,4237,121,1919,327,123,125,333,190,4241 },
    ["Italy\\Serie B"] = { 319,187,4218,4233,1362,1920,4928,4229,4234,2517,4379,237,238,235,4225,4244,240,4914,1600,4228 },
    ["France\\Ligue 1"] = { 403,180,1329,413,182,213,181,113,112,4123,216,217,114,414,218,4211,4213,221 },
    ["France\\Ligue 2"] = { 209,4200,5685,210,405,407,4206,4370,211,412,1330,5884,215,418,5099,4212,4372,420,5097,5100 },
    ["Netherlands\\Eredivisie"] = { 116,1598,242,117,345,346,244,245,349,246,247,256,118,254,351,250,251,255 },
    ["Portugal\\Liga Portugal"] = { 2380,5954,191,4323,1974,5633,2383,5844,5028,4086,2387,2388,1944,192,1979,2391,193,1804 },
    ["Germany\\Bundesliga"] = { 4124,128,127,126,225,226,4139,227,5009,5719,436,5010,231,4126,4140,4128,185,232 },
    ["Brazil\\Brasileirão"] = { 1245,2453,1246,2454,1247,274,1248,1249,5143,1250,1252,5137,5767,137,2459,1254,1255,1936,136,1937 },
    ["Argentina\\Primera División"] = { 2717,1236,2719,1927,5657,2536,139,4995,2722,5366,1238,1239,1924,1922,1240,2726,2727,1929,1241,5454,1237,138,1242,1243,1925,2730,5046,1926,2538,1244 },
    ["Chile\\Liga de Primera"] = { 2192,2553,1256,2707,2543,2544,5980,2208,2545,2699,2541,2548,2360,2546,2191,2209 },
    ["Colombia\\Primera A"] = { 1257,1258,2193,2195,2210,2284,2285,2361,2650,2651,2652,2653,2654,2655,2657,5207,5208,5210,5370,5371 },
    ["United States\\Major League Soccer"] = { 5736,5740,4156,5832,4150,4151,4152,5737,4153,5738,5741,4155,5742,5061,4158,5062,4160,4161,4163,4166 },
    ["Indonesia\\Super League"] = { 2399,2400,2401,2402,2403,2404,2405,2406,2407,2408,2409,2689,2690,2691,2692,2693,2697,2698 },
    ["Japan\\J1 League"] = { 167,169,168,1881,157,146,149,163,156,2372,155,159,153,165,150,151,147,158,164,152 },
    ["Saudi Arabia\\Pro League"] = { 1349,9003,1902,5940,1489,1350,9005,9012,2577,9007,9013,9008,9002,1348,2580,1351 }
}

for league, teams in pairs(TEAM_LEAGUES) do
    local lookup = {}
    for _, id in ipairs(teams) do
        lookup[id] = true
    end
    TEAM_LEAGUES[league] = lookup
end

local function trim(s)
    return s:gsub("^%s*(.-)%s*$", "%1")
end

local function load_map_txt(filename)
    local filepath = fileroot .. filename
    local file = io.open(filepath, "r")
    if not file then
        log("Cannot open " .. filepath)
        return
    end

    for line in file:lines() do
        line = line:gsub("^\239\187\191", "") -- remove BOM
        line = trim(line)
        if line ~= "" and not line:match("^#") then
            line = line:gsub("%s*#.*$", "") -- remove inline comment
            local comp_id, default_path, replay_path, extra_path =
                line:match("^(%d+)%s*,%s*([^,]*)%s*,%s*([^,]*)%s*,?%s*([^,]*)$")
            if comp_id and default_path then
                local tid = tonumber(comp_id)
                competition_assignment_map[tid] = competition_assignment_map[tid] or {}
                table.insert(competition_assignment_map[tid], {
                    trim(default_path),
                    trim(replay_path or ""),
                    trim(extra_path or "")
                })
            end
        end
    end
    file:close()
end

local function is_team_in_league(team_id, league)
    return TEAM_LEAGUES[league] and TEAM_LEAGUES[league][team_id] or false
end

local function get_league_by_teams(home_team, away_team)
    for league, _ in pairs(TEAM_LEAGUES) do
        if is_team_in_league(home_team, league) and is_team_in_league(away_team, league) then
            return league
        end
    end
end

local function get_exhibition_path(ctx)
    if ctx.season == 0 and ctx.timeofday == 0 then
        return "Exhibition Random\\EA Sports FC25"
    elseif ctx.season == 1 and ctx.timeofday == 1 then
        return "Exhibition Random\\eFootball 2025"
    elseif ctx.season == 0 and ctx.timeofday == 1 then
        return "Exhibition Random\\EA Sports FC25"
    elseif ctx.season == 1 and ctx.timeofday == 0 then
        return "Exhibition Random\\eFootball 2025"
    end
end

local function home_team_selected(ctx, team_id)
    local tid = tonumber(ctx.tournament_id)
    random_num = nil
    if competition_assignment_map[tid] then
        if #competition_assignment_map[tid] == 1 or ctx.is_replay_gallery then
            random_num = 1
        else
            if not random_seeded then
                math.randomseed(os.time())
                random_seeded = true
            end
            random_num = math.random(1, #competition_assignment_map[tid])
        end
    end
end

local function get_competition_entry(tid, ctx)
    local list = competition_assignment_map[tid]
    if not list or #list == 0 then
        return nil
    end

    if random_num == nil or not list[random_num] then
        if #list == 1 or ctx.is_replay_gallery then
            random_num = 1
        else
            if not random_seeded then
                math.randomseed(os.time())
                random_seeded = true
            end
            random_num = math.random(1, #list)
        end
    end

    return list[random_num]
end

local function is_it_scoreboard_file(filename)
    filename = string.lower(filename)
    return (
        string.match(filename, "common\\menu\\licence") or
        string.match(filename, "common\\menu\\font") or
        string.match(filename, "common\\menu\\fade") or
        string.match(filename, "common\\menu\\general") or
        string.match(filename, "common\\menu\\system") or 
        string.match(filename, "common\\render\\symbol\\flag")
    ) and filename or nil
end

local function get_new_scoreboard_path(ctx)
    local tid = tonumber(ctx.tournament_id)

    if tid and competition_assignment_map[tid] then
        local entry = get_competition_entry(tid, ctx)
        if entry then
            if ctx.match_info == 53 and entry[2] ~= "" then
                return entry[2]
            end
            return entry[1]
        else
            return nil
        end
    end

    if ctx.home_team and ctx.away_team then
        local league = get_league_by_teams(ctx.home_team, ctx.away_team)
        if league then
            return league
        end
    end

    return get_exhibition_path(ctx)
end

local function make_key(ctx, filename)
    if not ctx.is_edit_mode and is_it_scoreboard_file(filename) then
        new_file_path = get_new_scoreboard_path(ctx)
        if new_file_path then
            return new_file_path .. "\\" .. filename
        end
    end
end

local function get_filepath(ctx, filename, key)
    if not ctx.is_edit_mode and new_file_path then
        return string.format("%s\\%s", fileroot, key)
    end
end

local function init(ctx)
    if fileroot:sub(1, 1) == '.' then
        fileroot = ctx.sider_dir .. fileroot
    end
    load_map_txt("map_competitions.txt")
    ctx.register("livecpk_make_key", make_key)
    ctx.register("livecpk_get_filepath", get_filepath)
    ctx.register("set_home_team", home_team_selected)
     -- Success log
    log("Scoreboard server by JDPRO loaded successfully. Enjoy it :D")
end

return { init = init }
