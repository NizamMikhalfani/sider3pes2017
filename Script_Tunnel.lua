local fileroot = ".\\content\\SiderX_Tunnel"
local tid

function set_tournament_id(ctx, tournament_id)
    tid = tournament_id or nil
    return tournament_id
end

local function fixdemo(ctx, options)
  stadium_id = ctx.stadium
  home_id = ctx.home_team
  
----ENGLAND
        if stadium_id == 7 and home_id == 100 then
              Data = "Manchester_United"
        elseif stadium_id == 4 and home_id == 103 then
              Data = "Liverpool (Anfield_With_Exterior)"
        elseif stadium_id == 9 and home_id == 102 then
              Data = "Chelsea"
        elseif stadium_id == 32 and home_id == 173 then
              Data = "Manchester_City"
        elseif stadium_id == 15 and home_id == 101 then
              Data = "Arsenal"
        elseif stadium_id == 74 and home_id == 104 then
              Data = "Leeds_United"
        elseif stadium_id == 77 and home_id == 400 then
              Data = "Wigan_Athletic"
        elseif stadium_id == 81 and home_id == 106 then
              Data = "Newcastle"
        elseif stadium_id == 93 and home_id == 398 then
              Data = "Watford"
        elseif stadium_id == 66 and home_id == 107 then
              Data = "Aston_Villa"
        elseif stadium_id == 101 and home_id == 389 then
              Data = "Nottingham"
        elseif stadium_id == 103 and home_id == 105 then
              Data = "Westham_United"
        elseif stadium_id == 106 and home_id == 399 then
              Data = "West_Bromwich_Albion"
        elseif stadium_id == 108 and home_id == 177 then
              Data = "Everton"
        elseif stadium_id == 109 and home_id == 204 then
              Data = "Leicester_City"
        elseif stadium_id == 110 and home_id == 179 then
              Data = "Tottenham_Hotspur"
        elseif stadium_id == 111 and home_id == 207 then
              Data = "Southampton"
        elseif stadium_id == 124 and home_id == 208 then
              Data = "Wolverhampton_Warderers"			  
        elseif stadium_id == 211 and home_id == 1327 then
              Data = "Queens_Park_Rangers"

----SPAIN
        elseif stadium_id == 2 and home_id == 108 then
              Data = "Barcelona"
        elseif stadium_id == 3 and home_id == 265 then
              Data = "Sevilla"
        elseif stadium_id == 20 and home_id == 109 then
              Data = "Real_Madrid"
        elseif stadium_id == 40 and home_id == 110 then
              Data = "Valencia"
        elseif stadium_id == 56 and home_id == 172 then
              Data = "Atletico_Madrid"
        elseif stadium_id == 75 and home_id == 4145 then
              Data = "Deportivo_Alaves"
        elseif stadium_id == 117 and home_id == 4146 then
              Data = "Eibar"
        elseif stadium_id == 119 and home_id == 362 then
              Data = "Getafe"
        elseif stadium_id == 125 and home_id == 267 then
              Data = "Villareal"
        elseif stadium_id == 155 and home_id == 2187 then
              Data = "Girona"
        elseif stadium_id == 157 and home_id == 266 then
              Data = "Valladolid"
        elseif stadium_id == 167 and home_id == 196 then
              Data = "Real_Sociedad"
        elseif stadium_id == 176 and home_id == 258 then
              Data = "Athletic_Club"
        elseif stadium_id == 177 and home_id == 366 then
              Data = "Levante"
        elseif stadium_id == 192 and home_id == 194 then
              Data = "Real_Betis"

----ITALIA
        elseif stadium_id == 1 and home_id == 119 then
              Data = "Inter"
        elseif stadium_id == 21 and home_id == 327 then
              Data = "Napoli"
        elseif stadium_id == 22 and home_id == 120 then
              Data = "Juventus (Allianz_Arena_With_Exterior)"
        elseif stadium_id == 30 and home_id == 121 then
              Data = "Ac_Milan"
        elseif stadium_id == 47 and home_id == 188 then
              Data = "Chievo_Verona"
        elseif stadium_id == 227 and home_id == 235 then
              Data = "Empoli"
        elseif stadium_id == 6 and home_id == 122 then
              Data = "Lazio"
        elseif stadium_id == 62 and home_id == 328 then
              Data = "Pescara"
        elseif stadium_id == 67 and home_id == 238 then
              Data = "Palermo"
        elseif stadium_id == 80 and home_id == 333 then
              Data = "Torino"
        elseif stadium_id == 96 and home_id == 234 then
              Data = "Atalanta"
        elseif stadium_id == 202 and home_id == 320 then
              Data = "Cagliari"
        elseif stadium_id == 99 and home_id == 190 then
              Data = "Udinese"
        elseif stadium_id == 170 and home_id == 1363 then
              Data = "Crotone"
        elseif stadium_id == 6 and home_id == 125 then
              Data = "As_Roma"
        elseif stadium_id == 130 and home_id == 186 then
              Data = "Bologna"
        elseif stadium_id == 136 and home_id == 4232 then
              Data = "Benevento"
        elseif stadium_id == 139 and home_id == 4244 then
              Data = "Salernitana"
        elseif stadium_id == 140 and home_id == 4923 then
              Data = "Spal_Ferrara"
        elseif stadium_id == 142 and home_id == 124 then
              Data = "Fiorentina"
        elseif stadium_id == 154 and home_id == 4229 then
              Data = "Venezia"
        elseif stadium_id == 165 and home_id == 123 then
              Data = "Parma"
        elseif stadium_id == 166 and home_id == 4929 then
              Data = "Foggia"
        elseif stadium_id == 208 and home_id == 1919 then
              Data = "Sassuolo"
        elseif stadium_id == 191 and home_id == 336 then
              Data = "Hellas_Verona"
        elseif stadium_id == 222 and home_id == 323 then
              Data = "Genoa"
        elseif stadium_id == 223 and home_id == 240 then
              Data = "Sampdoria"
        elseif stadium_id == 237 and home_id == 319 then
              Data = "Bari"

----FRANCE
        elseif stadium_id == 140 and home_id == 114 then
              Data = "Paris_Saint_Germain"
        elseif stadium_id == 43 and home_id == 418 then
              Data = "Saint_Etienne"
        elseif stadium_id == 54 and home_id == 181 then
              Data = "Olympique_Lyonnais"
        elseif stadium_id == 55 and home_id == 217 then
              Data = "Nice"
        elseif stadium_id == 18 and home_id == 113 then
              Data = "Marseille"
        elseif stadium_id == 137 and home_id == 405 then
              Data = "Stade_Malherbe_Caen"
        elseif stadium_id == 186 and home_id == 112 then
              Data = "As_Monaco"
        elseif stadium_id == 195 and home_id == 211 then
              Data = "Guingamp"
        elseif stadium_id == 229 and home_id == 218 then
              Data = "Stade_Rennais"

----GERMANY
        elseif stadium_id == 11 and home_id == 127 then
              Data = "Bayern_Munich"
        elseif stadium_id == 41 and home_id == 128 then
              Data = "Bayer_Leverkusen"
        elseif stadium_id == 3 and home_id == 126 then
              Data = "Borussia_Dortmund"
        elseif stadium_id == 85 and home_id == 185 then
              Data = "Werder_Bremen"
        elseif stadium_id == 138 and home_id == 225 then
              Data = "Borussia_M'Gladbach"
        elseif stadium_id == 188 and home_id == 184 then
              Data = "Schalke"
        elseif stadium_id == 179 and home_id == 226 then
              Data = "Frankfurt"
        elseif stadium_id == 190 and home_id == 232 then
              Data = "Wolfsburg"
        elseif stadium_id == 257 and home_id == 5010 then
              Data = "Leipzig"
        elseif stadium_id == 172 and home_id == 4140 then
              Data = "Union_Berlin"
        elseif stadium_id == 272 and home_id == 4324 then
              Data = "Paderborn"

----PORTUGAL
        elseif stadium_id == 8 and home_id == 191 then
              Data = "Benfica"
        elseif stadium_id == 159 and home_id == 4323 then
              Data = "Boavista"
        elseif stadium_id == 196 and home_id == 192 then
              Data = "Porto"
        elseif stadium_id == 197 and home_id == 193 then
              Data = "Sporting_Lisbon"
        elseif stadium_id == 201 and home_id == 1974 then
              Data = "Sc_Braga"

----NETHERLANDS
        elseif stadium_id == 144 and home_id == 250 then
              Data = "Twente"
        elseif stadium_id == 187 and home_id == 116 then
              Data = "Ajax_Amsterdam"
        elseif stadium_id == 246 and home_id == 242 then
              Data = "AZ_Alkmaar"
        elseif stadium_id == 275 and home_id == 118 then
              Data = "Psv"
        elseif stadium_id == 276 and home_id == 117 then
              Data = "Feyenoord"

----OTHER EUROPE
        elseif stadium_id == 49 and home_id == 1706 then
              Data = "Basel"
        elseif stadium_id == 71 and home_id == 133 then
              Data = "Olympiakos"
        elseif stadium_id == 88 and home_id == 1223 then
              Data = "Crvena_Zvedza"
        elseif stadium_id == 134 and home_id == 2229 then
              Data = "Rostov"
        elseif stadium_id == 135 and home_id == 130 then
              Data = "Galatasaray"
        elseif stadium_id == 145 and home_id == 1203 then
              Data = "Dinamo_Zagreb"
        elseif stadium_id == 169 and home_id == 131 then
              Data = "Celtic"
        elseif stadium_id == 199 and home_id == 1232 then
              Data = "Shakhtar_Donetsk"
        elseif stadium_id == 123 and home_id == 135 then
              Data = "Spartak_Moscow"
        elseif stadium_id == 200 and home_id == 1207 then
              Data = "Copenhagen"
        elseif stadium_id == 225 and home_id == 2618 then
              Data = "Krasnodar"

----SOUTH AMERICA
        elseif stadium_id == 14 and home_id == 1255 then
              Data = "Sao_Paulo"
        elseif stadium_id == 24 and home_id == 1248 then
              Data = "Flamengo"
        elseif stadium_id == 24 and home_id == 1249 then
              Data = "Fluminense"
        elseif stadium_id == 33 and home_id == 137 then
              Data = "Palmeiras"
        elseif stadium_id == 35 and home_id == 1247 then
              Data = "Corinthians"
        elseif stadium_id == 27 and home_id == 138 then
              Data = "River_Plate"
        elseif stadium_id == 28 and home_id == 139 then
              Data = "Boca_Junior"
        elseif stadium_id == 131 and home_id == 1250 then
              Data = "Gremio"
        elseif stadium_id == 269 and home_id == 1243 then
              Data = "San_Lorenzo"

----INDONESIAN
        elseif stadium_id == 173 and home_id == 1339 then
              Data = "Persebaya"
        elseif stadium_id == 277 and home_id == 5911 then
              Data = "Barito_Putera"
        elseif stadium_id == 282 and home_id == 1338 then
              Data = "PSM_Makassar"
        elseif stadium_id == 284 and home_id == 5901 then
              Data = "Madura_United"
        elseif stadium_id == 285 and home_id == 1480 then
              Data = "Arema"
        elseif stadium_id == 286 and home_id == 5902 then
              Data = "Bali_United"
        elseif stadium_id == 279 and home_id == 5904 then
              Data = "PSS_Sleman"
        elseif stadium_id == 287 and home_id == 5906 then
              Data = "Tira_Persikabo"
        elseif stadium_id == 234 and home_id == 1481 then
              Data = "Persipura"
        elseif stadium_id == 288 and home_id == 5909 then
              Data = "Borneo"
        elseif stadium_id == 281 and home_id == 4945 then
              Data = "Persib"
        elseif stadium_id == 289 and home_id == 5912 then
              Data = "Persela"
        elseif stadium_id == 283 and home_id == 5908 then
              Data = "PSIS_Semarang"
			  
----NATIONAL
        elseif stadium_id == 129 and home_id == 3 then
              Data = "Scotland"
        elseif stadium_id == 5 and home_id == 5 then
              Data = "England"
        elseif stadium_id == 233 and home_id == 6 then
              Data = "Portugal"
        elseif stadium_id == 6 and home_id == 12 then
              Data = "Italy"
        elseif stadium_id == 240 and home_id == 34 then
              Data = "Egypt"
        elseif stadium_id == 162 and home_id == 40 then
              Data = "Mexico"
        elseif stadium_id == 184 and home_id == 44 then
              Data = "Colombia"
        elseif stadium_id == 204 and home_id == 45 then
              Data = "Brazil"
        elseif stadium_id == 84 and home_id == 46 then
              Data = "Peru"
        elseif stadium_id == 45 and home_id == 49 then
              Data = "Uruguay"
        elseif stadium_id == 27 and home_id == 50 then
              Data = "Argentina"
			  
else
     Data = nil
  end
end

local function make_key(ctx, filename)
	fixdemo(ctx)
    if tid and Data ~= nil then
       return string.format("%s:%s", Data, filename)
    end
  end

local function get_filepath(ctx, filename, key)
    if tid and Data ~= nil then
        return string.format("%s\\%s\\%s", fileroot, Data, filename)
    end
end

local function printlog(ctx)
    if Data ~= nil then
       log("fixdemo switching to: " .. Data)
	end
end

local function init(ctx)
    if fileroot:sub(1,1)=='.' then
        fileroot = ctx.sider_dir .. fileroot
    end
    ctx.register("set_tournament_id", set_tournament_id)
    ctx.register("livecpk_make_key", make_key)
    ctx.register("livecpk_get_filepath", get_filepath)
	 ctx.register("tournament_check_for_trophy", printlog)
end

return { init = init }