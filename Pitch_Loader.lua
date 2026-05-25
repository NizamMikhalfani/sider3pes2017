local pitchroot = ".\\content\\Pitch_Loader\\"
local pitch

--[[
DOCUMENTATION

Add the next line in "sider.ini" to activate this script :

lua.module = "Pitch_Loader.lua"

Suggestion : Place the line below snow mod and above stadium server, example :

lua.module = "Snow_Mod.lua"
lua.module = "Pitch_Loader.lua"
lua.module = "Stadium_Server.lua"

Pitch Loader by eCommunity. Specially made for pitch makers and people who like to change the pitch and gfx for all stadiums quikly ;D.
Every single step is described so that lua developers can easily add more essential files and remove un-necessary files also.
Feel free to contact our FB page for any bugs\developments discovered by you. 
https://fb.com/ecommunitypatch
Please don't edit this file unless you know what you're doing.
]]--

-- Pitch files include : Turf color, design, line and diffuse map for every situation
-- Usually found in "common\bg\model\bg\pitch\common\texture" and "common\bg\model\bg\pitch\st(id)\texture"

local pitch_files = {

["\\3Dpitch.*%.dds"] = "texture\\3Dpitch.dds",
["\\ground_c.dds"] = "texture\\ground_c.dds",
["\\ground_dry.dds"] = "texture\\ground_dry.dds",
["\\ground_wet.dds"] = "texture\\ground_wet.dds",
["\\pitch_bsm.dds"] = "texture\\pitch_bsm.dds",
["\\pitch_nrm.dds"] = "texture\\pitch_nrm.dds",
["\\line_alp.dds"] = "texture\\line_alp.dds",
["\\pitch_nrm_ed0%d%.dds"] = "texture\\pitch_nrm.dds", -- Replaces All Pitch designs for less errors
["\\pitch_winter.dds"] = "texture\\pitch_winter.dds",
["\\pitch_summer.dds"] = "texture\\pitch_summer.dds",
["\\weather_dry.dds"] = "texture\\weather_dry.dds",
["\\weather_wet.dds"] = "texture\\weather_wet.dds",
["\\turf_df.dds"] = "texture\\turf_df.dds",
["\\turf_dr.dds"] = "texture\\turf_dr.dds",
["\\turf_dw.dds"] = "texture\\turf_dw.dds",
["\\turf_nf.dds"] = "texture\\turf_nf.dds",
["\\turf_nr.dds"] = "texture\\turf_nr.dds",
["\\turf_nw.dds"] = "texture\\turf_nw.dds",
["\\turflen.dds"] = "texture\\turflen.dds",
["\\pitch.*%.model"] = "texture\\pitch.model",

}


-- Script files are applied for every stadium so that they can read upper pitch files
-- Don't edit this section, you can edit ".mtl" files to change pitch file names'

local script_files = {
--["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_s_df.mtl"] = "scripts\\pitch_s_df.mtl",
--["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_s_df.xml"] = "scripts\\pitch_s_df.xml",
["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_s_dr.mtl"] = "scripts\\pitch_s_dr.mtl",
["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_s_dr.xml"] = "scripts\\pitch_s_dr.xml",
["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_s_nf.mtl"] = "scripts\\pitch_s_nf.mtl",
["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_s_nf.xml"] = "scripts\\pitch_s_nf.xml",
["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_s_nr.mtl"] = "scripts\\pitch_s_nr.mtl",
["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_s_nr.xml"] = "scripts\\pitch_s_nr.xml",
--["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_w_df.mtl"] = "scripts\\pitch_w_df.mtl",
--["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_w_df.xml"] = "scripts\\pitch_w_df.xml",
["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_w_dr.mtl"] = "scripts\\pitch_w_dr.mtl",
["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_w_dr.xml"] = "scripts\\pitch_w_dr.xml",
["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_w_nf.mtl"] = "scripts\\pitch_w_nf.mtl",
["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_w_nf.xml"] = "scripts\\pitch_w_nf.xml",
["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_w_nr.mtl"] = "scripts\\pitch_w_nr.mtl",
["common\\bg\\model\\bg\\pitch\\st%d%d%d\\pitch_w_nr.xml"] = "scripts\\pitch_w_nr.xml",

}

-- GFX files responible of turf, face and kit color and light reflection in-game

local gfx_files = {

["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\cg_df.dds"] = "gfx\\cg_df.dds",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\cg_df_demo.dds"] = "gfx\\cg_df_demo.dds",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\cg_dr.dds"] = "gfx\\cg_dr.dds",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\cg_dr_demo.dds"] = "gfx\\cg_dr_demo.dds",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\cg_nf.dds"] = "gfx\\cg_nf.dds",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\cg_nf_demo.dds"] = "gfx\\cg_nf_demo.dds",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\cg_nr.dds"] = "gfx\\cg_nr.dds",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\cg_nr_demo.dds"] = "gfx\\cg_nr_demo.dds",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\Default.dds"] = "gfx\\Default.dds",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\effect_config_df.xml"] = "gfx\\effect_config_df.xml",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\effect_config_dr.xml"] = "gfx\\effect_config_dr.xml",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\effect_config_nf.xml"] = "gfx\\effect_config_nf.xml",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\effect_config_nr.xml"] = "gfx\\effect_config_nr.xml",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\env_df.dds"] = "gfx\\env_df.dds",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\env_dr.dds"] = "gfx\\env_dr.dds",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\env_nf.dds"] = "gfx\\env_nf.dds",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\env_nr.dds"] = "gfx\\env_nr.dds",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\light_config_df.xml"] = "gfx\\light_config_df.xml",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\light_config_df_demo_gate.xml"] = "gfx\\light_config_df_demo_gate.xml",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\light_config_dr.xml"] = "gfx\\light_config_dr.xml",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\light_config_dr_demo_gate.xml"] = "gfx\\light_config_dr_demo_gate.xml",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\light_config_nf.xml"] = "gfx\\light_config_nf.xml",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\light_config_nf_demo_gate.xml"] = "gfx\\light_config_nf_demo_gate.xml",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\light_config_nr.xml"] = "gfx\\light_config_nr.xml",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\light_config_nr_demo_gate.xml"] = "gfx\\light_config_nr_demo_gate.xml",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\stad_df.irv"] = "gfx\\stad_df.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\stad_df.lmn"] = "gfx\\stad_df.lmn",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\stad_df_demo_gate.irv"] = "gfx\\stad_df_demo_gate.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\stad_dr.irv"] = "gfx\\stad_dr.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\stad_dr.lmn"] = "gfx\\stad_dr.lmn",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\stad_dr_demo_gate.irv"] = "gfx\\stad_dr_demo_gate.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\stad_nf.irv"] = "gfx\\stad_nf.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\stad_nf.lmn"] = "gfx\\stad_nf.lmn",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\stad_nf_demo_gate.irv"] = "gfx\\stad_nf_demo_gate.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\stad_nf_shlight.irv"] = "gfx\\stad_nf_shlight.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\stad_nr.irv"] = "gfx\\stad_nr.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\stad_nr.lmn"] = "gfx\\stad_nr.lmn",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\stad_nr_demo_gate.irv"] = "gfx\\stad_nr_demo_gate.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\stad_nr_shlight.irv"] = "gfx\\stad_nr_shlight.irv",

-- Replaces "st(id)_(matchcondition).irv" with available files for no errors (Red Players)
-- Check renaming that type of file "st(id)_(matchcondition).irv" to replace "st(id)" with "stad" in case some pitches uses that file in their gfx.

["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\st%d%d%d_df.irv"] = "gfx\\stad_df.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\st%d%d%d_df.lmn"] = "gfx\\stad_df.lmn",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\st%d%d%d_df_demo_gate.irv"] = "gfx\\stad_df_demo_gate.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\st%d%d%d_dr.irv"] = "gfx\\stad_dr.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\st%d%d%d_dr.lmn"] = "gfx\\stad_dr.lmn",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\st%d%d%d_dr_demo_gate.irv"] = "gfx\\stad_dr_demo_gate.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\st%d%d%d_nf.irv"] = "gfx\\stad_nf.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\st%d%d%d_nf.lmn"] = "gfx\\stad_nf.lmn",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\st%d%d%d_nf_demo_gate.irv"] = "gfx\\stad_nf_demo_gate.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\st%d%d%d_nf_shlight.irv"] = "gfx\\stad_nf_shlight.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\st%d%d%d_nr.irv"] = "gfx\\stad_nr.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\st%d%d%d_nr.lmn"] = "gfx\\stad_nr.lmn",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\st%d%d%d_nr_demo_gate.irv"] = "gfx\\stad_nr_demo_gate.irv",
["common\\bg\\model\\bg\\stadium\\st%d%d%d\\etc\\st%d%d%d_nr_shlight.irv"] = "gfx\\stad_nr_shlight.irv",

}


local function rewrite(ctx, filename)
	local m_file
	m_file = mtl_replace(filename)
	if m_file then 
		filename.open()
			for line in filename:lines() do
					table.insert (fileContent, line)
			end
		filename.close()
		
		local ambientnum = search_value(fileContent, '%Ambient%')
		local shadenum = search_value(fileContent, '%Shade%')
		local ambientstring = fileContent[ambientnum]
		local shadestring = fileContent[shadenum]
		
	if m_file == "pitch_s_df.mtl" then
			-- Summer-Day-Fine
			fileContent[2] = '    <material name="pitch_mat" shader="Turf_Day_G3">'
			fileContent[3] = '        <vector name="EnvParam" x="1" y="0" z="0" w="0" />'
			fileContent[4] = '        <sampler name="DiffuseMap" path="model/bg/pitch/common/texture/turf_df.dds" srgb="1" minfilter="anisotropic" magfilter="linear" mipfilter="linear" uaddr="wrap" vaddr="wrap" waddr="wrap" maxaniso="2" />'
			fileContent[5] = '        <sampler name="DecalMap" path="model/bg/pitch/common/texture/line_alp.dds" srgb="0" minfilter="anisotropic" magfilter="linear" mipfilter="linear" uaddr="wrap" vaddr="wrap" waddr="wrap" maxaniso="2" />'
			fileContent[6] = '        <sampler name="GroundColorMap" path="model/bg/pitch/common/texture/ground_dry.dds" srgb="1" minfilter="anisotropic" magfilter="linear" mipfilter="linear" uaddr="wrap" vaddr="wrap" waddr="wrap" maxaniso="2" />'
			fileContent[7] = '        <sampler name="NormalMap" path="model/bg/pitch/common/texture/pitch_nrm.dds" srgb="0" minfilter="anisotropic" magfilter="linear" mipfilter="linear" uaddr="wrap" vaddr="wrap" waddr="wrap" maxaniso="2" />'
			fileContent[8] = '        <sampler name="MaskMap" path="model/bg/pitch/common/texture/weather_dry.dds" srgb="0" minfilter="anisotropic" magfilter="linear" mipfilter="linear" uaddr="wrap" vaddr="wrap" waddr="wrap" maxaniso="2" />'
			fileContent[9] = '        <sampler name="TurfDetailMap" path="model/bg/pitch/common/texture/pitch_summer.dds" srgb="0" minfilter="anisotropic" magfilter="linear" mipfilter="linear" uaddr="wrap" vaddr="wrap" waddr="wrap" maxaniso="2" />'
	elseif m_file == "pitch_w_df.mtl" then
			-- Winter-Day-Fine
			fileContent[2] = '    <material name="pitch_mat" shader="Turf_Day_G3">'
			fileContent[3] = '        <vector name="EnvParam" x="1" y="0" z="0" w="0" />'
			fileContent[4] = '        <sampler name="DiffuseMap" path="model/bg/pitch/common/texture/turf_dw.dds" srgb="1" minfilter="anisotropic" magfilter="linear" mipfilter="linear" uaddr="wrap" vaddr="wrap" waddr="wrap" maxaniso="2" />'
			fileContent[5] = '        <sampler name="DecalMap" path="model/bg/pitch/common/texture/line_alp.dds" srgb="0" minfilter="anisotropic" magfilter="linear" mipfilter="linear" uaddr="wrap" vaddr="wrap" waddr="wrap" maxaniso="2" />'
			fileContent[6] = '        <sampler name="GroundColorMap" path="model/bg/pitch/common/texture/ground_dry.dds" srgb="1" minfilter="anisotropic" magfilter="linear" mipfilter="linear" uaddr="wrap" vaddr="wrap" waddr="wrap" maxaniso="2" />'
			fileContent[7] = '        <sampler name="NormalMap" path="model/bg/pitch/common/texture/pitch_nrm.dds" srgb="0" minfilter="anisotropic" magfilter="linear" mipfilter="linear" uaddr="wrap" vaddr="wrap" waddr="wrap" maxaniso="2" />'
			fileContent[8] = '        <sampler name="MaskMap" path="model/bg/pitch/common/texture/weather_dry.dds" srgb="0" minfilter="anisotropic" magfilter="linear" mipfilter="linear" uaddr="wrap" vaddr="wrap" waddr="wrap" maxaniso="2" />'
			fileContent[9] = '        <sampler name="TurfDetailMap" path="model/bg/pitch/common/texture/pitch_winter.dds" srgb="0" minfilter="anisotropic" magfilter="linear" mipfilter="linear" uaddr="wrap" vaddr="wrap" waddr="wrap" maxaniso="2" />'
	end
	
			-- Applies for all conditions (10 & 11 are replaced with empty lines, you can replace them with anything you want)
			
			fileContent[1] = '<materialset>'
			fileContent[10] = " "
			fileContent[11] = " "
			fileContent[12] = ambientstring
			fileContent[13] = shadestring
			fileContent[14] = '        <state name="alpharef" value="0" />'
			fileContent[15] = '        <state name="blendmode" value="0" />'
			fileContent[16] = '        <state name="alphablend" value="0" />'
			fileContent[17] = '        <state name="alphatest" value="0" />'
			fileContent[18] = '        <state name="twosided" value="0" />'
			fileContent[19] = '        <state name="ztest" value="1" />'
			fileContent[20] = '        <state name="zwrite" value="1" />'
			fileContent[21] = '    </material>'
			fileContent[22] = '</materialset>'
					
    	filename.open()
    		for index, value in ipairs(fileContent) do
        		filename:write(value..'\n')
    		end
    	filename.close()
		return filename
	end
end

-- lcpk maker for above files

function make_key(ctx, filename)

	for pattern,repl in pairs(pitch_files) do
		if string.match(filename, pattern) then
			return repl
		end
	end
	
	for pattern,repl in pairs(script_files) do
		if string.match(filename, pattern) then
			return repl
		end
	end
	
	for pattern,repl in pairs(gfx_files) do
		if string.match(filename, pattern) then
			return repl
        end
    end
	
	return filename
end

function get_filepath(ctx, filename, key)
    if key then
        return pitchroot .. key
    end
end

function init(ctx)
	if pitchroot:sub(1,1) == "." then
        	pitchroot = ctx.sider_dir .. pitchroot
	end
	ctx.register("livecpk_rewrite", rewrite)
	ctx.register("livecpk_make_key", make_key)
	ctx.register("livecpk_get_filepath", get_filepath)
end

return { init = init }