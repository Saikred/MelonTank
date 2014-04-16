/*---------------------------------------------------------------------------
HUD ConVars
---------------------------------------------------------------------------*/
local ConVars = {}
local HUDWidth
local HUDHeight

CreateClientConVar("weaponhud", 0, true, false)

local function ReloadConVars()
	ConVars = {
		background = {0,0,0,100},
		Healthbackground = {0,0,0,200},
		Healthforeground = {0,200,220,180},
		HealthText = {255,255,255,200},
		Job1 = {0,0,150,200},
		Job2 = {0,0,0,255},
		salary1 = {0,150,0,200},
		salary2 = {0,0,0,255}
	}

	for name, Colour in pairs(ConVars) do
		ConVars[name] = {}
		for num, rgb in SortedPairs(Colour) do
			local CVar = GetConVar(name..num) or CreateClientConVar(name..num, rgb, true, false)
			table.insert(ConVars[name], CVar:GetInt())

			if not cvars.GetConVarCallbacks(name..num, false) then
				cvars.AddChangeCallback(name..num, function() timer.Simple(0,ReloadConVars) end)
			end
		end
		ConVars[name] = Color(unpack(ConVars[name]))
	end


	HUDWidth = (GetConVar("HudW") or  CreateClientConVar("HudW", 240, true, false)):GetInt()
	HUDHeight = (GetConVar("HudH") or CreateClientConVar("HudH", 115, true, false)):GetInt()

	if not cvars.GetConVarCallbacks("HudW", false) and not cvars.GetConVarCallbacks("HudH", false) then
		cvars.AddChangeCallback("HudW", function() timer.Simple(0,ReloadConVars) end)
		cvars.AddChangeCallback("HudH", function() timer.Simple(0,ReloadConVars) end)
	end
end
ReloadConVars()

local function formatNumber(n)
	n = tonumber(n)
	if (!n) then
		return 0
	end
	if n >= 1e14 then return tostring(n) end
    n = tostring(n)
    sep = sep or ","
    local dp = string.find(n, "%.") or #n+1
	for i=dp-4, 1, -3 do
		n = n:sub(1, i) .. sep .. n:sub(i+1)
    end
    return n
end


local Scrw, Scrh, RelativeX, RelativeY
/*---------------------------------------------------------------------------
HUD Seperate Elements
---------------------------------------------------------------------------*/
local function DrawInfo()
	LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
	local Salary = 	LANGUAGE.salary .. CUR .. (LocalPlayer().DarkRPVars.salary or 0)

	local JobWallet =
	LANGUAGE.job .. (LocalPlayer().DarkRPVars.job or "") .. "\n"..
	LANGUAGE.wallet .. CUR .. (formatNumber(LocalPlayer().DarkRPVars.money) or 0)

	local wep = LocalPlayer( ):GetActiveWeapon( );

	if IsValid(wep) and GAMEMODE.Config.weaponhud then
        local name = wep:GetPrintName();
		draw.DrawText("Weapon: "..name, "UiBold", RelativeX + 5, RelativeY - HUDHeight - 18, Color(255, 255, 255, 255), 0)
	end
end

timer.Simple( 0.01, DrawInfo )

local Page = Material("icon16/page_white_text.png")
local function GunLicense()
	if LocalPlayer().DarkRPVars.HasGunlicense then
		surface.SetMaterial(Page)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(RelativeX + HUDWidth, ScrH() - 34, 32, 32)
	end
end

local function Agenda()
	local DrawAgenda, AgendaManager = DarkRPAgendas[LocalPlayer():Team()], LocalPlayer():Team()
	if not DrawAgenda then
		for k,v in pairs(DarkRPAgendas) do
			if table.HasValue(v.Listeners or {}, LocalPlayer():Team()) then
				DrawAgenda, AgendaManager = DarkRPAgendas[k], k
				break
			end
		end
	end
	if DrawAgenda then
		draw.RoundedBox(0, 10, 10, 460, 110, Color(0, 0, 0, 155))
		draw.RoundedBox(0, 12, 12, 456, 106, Color(51, 58, 51,100))
		draw.RoundedBox(0, 12, 12, 456, 20, Color( 0, 161, 242, 200 ))

		draw.DrawText(DrawAgenda.Title, "DarkRPHUD1", 30, 12, Color(255,255,255,255),0)

		local AgendaText = ""
		for k,v in pairs(team.GetPlayers(AgendaManager)) do
			if not v.DarkRPVars then continue end
			AgendaText = AgendaText .. (v.DarkRPVars.agenda or "") .. "\n"
		end
		draw.DrawText(string.gsub(string.gsub(AgendaText, "//", "\n"), "\\n", "\n"), "DarkRPHUD1", 30, 35, Color(255,255,255,255),0)
	end
end

local VoiceChatTexture = surface.GetTextureID("voice/icntlk_pl")
local function DrawVoiceChat()
	if LocalPlayer().DRPIsTalking then
		local chbxX, chboxY = chat.GetChatBoxPos()

		local Rotating = math.sin(CurTime()*3)
		local backwards = 0
		if Rotating < 0 then
			Rotating = 1-(1+Rotating)
			backwards = 180
		end
		surface.SetTexture(VoiceChatTexture)
		surface.SetDrawColor(ConVars.Healthforeground)
		surface.DrawTexturedRectRotated(ScrW() - 100, chboxY, Rotating*96, 96, backwards)
	end
end

local function LockDown()
	local chbxX, chboxY = chat.GetChatBoxPos()
	if util.tobool(GetConVarNumber("DarkRP_LockDown")) then
		local cin = (math.sin(CurTime()) + 1) / 2
		local chatBoxSize = math.floor(ScrH() / 4)
		draw.DrawText(LANGUAGE.lockdown_started, "ScoreboardSubtitle", chbxX, chboxY + chatBoxSize, Color(cin * 255, 0, 255 - (cin * 255), 255), TEXT_ALIGN_LEFT)
	end
end

local Arrested = function() end

usermessage.Hook("GotArrested", function(msg)
	local StartArrested = CurTime()
	local ArrestedUntil = msg:ReadFloat()

	Arrested = function()
		if CurTime() - StartArrested <= ArrestedUntil and LocalPlayer().DarkRPVars.Arrested then
		draw.DrawText(string.format(LANGUAGE.youre_arrested, math.ceil(ArrestedUntil - (CurTime() - StartArrested))), "DarkRPHUD1", ScrW()/2, ScrH() - ScrH()/12, Color(255,255,255,255), 1)
		elseif not LocalPlayer().DarkRPVars.Arrested then
			Arrested = function() end
		end
	end
end)

local AdminTell = function() end

usermessage.Hook("AdminTell", function(msg)
	local Message = msg:ReadString()

	AdminTell = function()
		draw.RoundedBox(4, 10, 10, ScrW() - 20, 100, Color(0, 0, 0, 200))
		draw.DrawText(LANGUAGE.listen_up, "GModToolName", ScrW() / 2 + 10, 10, Color(255, 255, 255, 255), 1)
		draw.DrawText(Message, "ChatFont", ScrW() / 2 + 10, 80, Color(200, 30, 30, 255), 1)
	end

	timer.Simple(10, function()
		AdminTell = function() end
	end)
end)

/*---------------------------------------------------------------------------
Drawing the HUD elements such as Health etc.
---------------------------------------------------------------------------*/
name = Material("icon16/user.png")
job = Material("icon16/wrench.png")
salarr = Material("icon16/money.png")
banii = Material("icon16/money_euro.png")
played = Material("icon16/time.png")

local function MyHUD()
		local newtime = string.ToMinutesSeconds(CurTime())
		local ply = LocalPlayer()
		local hp,ar = ply:Health(),ply:Armor()
		local slujba = LocalPlayer().DarkRPVars.job or "Unemployed"
		local salar = LocalPlayer().DarkRPVars.salary or "NONE"
		local bani = LocalPlayer().DarkRPVars.money or "NONE"
		local hr = LocalPlayer().DarkRPVars.Energy
	LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
	LocalPlayer().DarkRPVars.Energy = LocalPlayer().DarkRPVars.Energy or 0
	
if (ply:Alive()) then
	draw.RoundedBox(0,5,ScrH() - 115,270,110,Color(0,0,0,200))
	
		surface.SetMaterial(name)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(10,ScrH() - 110,16,16)
	draw.SimpleText("Name: "..ply:Nick(),"TargetID",30,ScrH() - 110)
	
		surface.SetMaterial(job)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(10,ScrH() - 90,16,16)
	draw.SimpleText("Job: "..slujba,"TargetID",30,ScrH() - 90)
	
		surface.SetMaterial(salarr)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(10,ScrH() - 70,16,16)
	draw.SimpleText("Salary: "..salar,"TargetID",30,ScrH() - 70)
	
			surface.SetMaterial(banii)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(10,ScrH() - 50,16,16)
	draw.SimpleText("Wallet: "..bani,"TargetID",30,ScrH() - 50)
	
				surface.SetMaterial(played)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(10,ScrH() - 30,16,16)
	draw.SimpleText("Session: "..newtime,"TargetID",30,ScrH() - 30)
	
	draw.RoundedBox(0,280,ScrH() - 25,150,20,Color(0,0,0,200))
	draw.RoundedBox(0,282,ScrH() - 23,math.Clamp(hp,0,100)*1.46,16,Color(127,0,0,200))
	draw.SimpleText("Health: "..hp,"TargetID",320,ScrH() - 23)
	
	if (hr > 0) then
		draw.RoundedBox(0,280,ScrH() - 50,150,20,Color(0,0,0,200))
	draw.RoundedBox(0,282,ScrH() - 48,math.Clamp(hr,0,100)*1.46,16,Color(125,226,43,200))
	draw.SimpleText("Hunger: "..hr,"TargetID",320,ScrH() - 48)
	end
	
	if (ar > 0) then
	draw.RoundedBox(0,280,ScrH() - 75,150,20,Color(0,0,0,200))
	draw.RoundedBox(0,282,ScrH() - 73,math.Clamp(ar,0,100)*1.46,16,Color(0,148,255,200))
	draw.SimpleText("Armor: "..ar,"TargetID",320,ScrH() - 73)
	end
	
	
return
false
end
end
timer.Simple( 0.01, MyHUD )

local function DrawHUD()
	Scrw, Scrh = ScrW(), ScrH()
	RelativeX, RelativeY = 0, Scrh
	
	MyHUD()
	DrawInfo()
	GunLicense()
	Agenda()
	DrawVoiceChat()
	LockDown()
	Arrested()
	AdminTell()
end

timer.Simple( 0.01, DrawHUD )

/*---------------------------------------------------------------------------
Entity HUDPaint things
---------------------------------------------------------------------------*/
local function DrawPlayerInfo(ply)
	local pos = ply:EyePos()

	pos.z = pos.z + 10 -- The position we want is a bit above the position of the eyes
	pos = pos:ToScreen()
	pos.y = pos.y - 50 -- Move the text up a few pixels to compensate for the height of the text

	if GAMEMODE.Config.showname and not ply.DarkRPVars.wanted then
		draw.DrawText(ply:Nick(), "DarkRPHUD2", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "DarkRPHUD2", pos.x, pos.y, team.GetColor(ply:Team()), 1)
		draw.DrawText(LANGUAGE.health ..ply:Health(), "DarkRPHUD2", pos.x + 1, pos.y + 21, Color(0, 0, 0, 255), 1)
		draw.DrawText(LANGUAGE.health..ply:Health(), "DarkRPHUD2", pos.x, pos.y + 20, Color(255,255,255,200), 1)
	end

	if GAMEMODE.Config.showjob then
		local teamname = team.GetName(ply:Team())
		draw.DrawText(ply.DarkRPVars.job or teamname, "DarkRPHUD2", pos.x + 1, pos.y + 41, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply.DarkRPVars.job or teamname, "DarkRPHUD2", pos.x, pos.y + 40, Color(255, 255, 255, 200), 1)
	end

	if ply.DarkRPVars.HasGunlicense then
		surface.SetMaterial(Page)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(pos.x-16, pos.y + 60, 32, 32)
	end
end

timer.Simple( 0.1, DrawPlayerInfo )

local function DrawWantedInfo(ply)
	if not ply:Alive() then return end

	local pos = ply:EyePos()
	if not pos:RPIsInSight({LocalPlayer(), ply}) then return end

	pos.z = pos.z + 14
	pos = pos:ToScreen()

	if GAMEMODE.Config.showname then
		draw.DrawText(ply:Nick(), "DarkRPHUD2", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "DarkRPHUD2", pos.x, pos.y, team.GetColor(ply:Team()), 1)
	end

	draw.DrawText(LANGUAGE.wanted.."\nReason: "..tostring(ply.DarkRPVars["wantedReason"]), "DarkRPHUD2", pos.x, pos.y - 40, Color(255, 255, 255, 200), 1)
	draw.DrawText(LANGUAGE.wanted.."\nReason: "..tostring(ply.DarkRPVars["wantedReason"]), "DarkRPHUD2", pos.x + 1, pos.y - 41, Color(255, 0, 0, 255), 1)
end

timer.Simple( 0.1, DrawWantedInfo )
/*---------------------------------------------------------------------------
The Entity display: draw HUD information about entities
---------------------------------------------------------------------------*/
local function DrawEntityDisplay()
	local shootPos = LocalPlayer():GetShootPos()
	local aimVec = LocalPlayer():GetAimVector()

	for k, ply in pairs(player.GetAll()) do
		if not ply:Alive() then continue end
		local hisPos = ply:GetShootPos()

		ply.DarkRPVars = ply.DarkRPVars or {}
		if ply.DarkRPVars.wanted then DrawWantedInfo(ply) end

		if GAMEMODE.Config.globalshow and ply ~= LocalPlayer() then
			DrawPlayerInfo(ply)
		-- Draw when you're (almost) looking at him
		elseif not GAMEMODE.Config.globalshow and hisPos:Distance(shootPos) < 400 then
			local pos = hisPos - shootPos
			local unitPos = pos:GetNormalized()
			if unitPos:Dot(aimVec) > 0.95 then
				local trace = util.QuickTrace(shootPos, pos, LocalPlayer())
				if trace.Hit and trace.Entity ~= ply then return end
				DrawPlayerInfo(ply)
			end
		end
	end

	local tr = LocalPlayer():GetEyeTrace()

	if tr.Entity:IsOwnable() and tr.Entity:GetPos():Distance(LocalPlayer():GetPos()) < 200 then
		tr.Entity:DrawOwnableInfo()
	end
end
timer.Simple( 0.1, DrawEntityDisplay )
/*---------------------------------------------------------------------------
Zombie display
---------------------------------------------------------------------------*/
local function DrawZombieInfo()
	if not LocalPlayer().DarkRPVars.zombieToggle then return end
	for x=1, LocalPlayer().DarkRPVars.numPoints, 1 do
		local zPoint = LocalPlayer().DarkRPVars["zPoints".. x]
		if zPoint then
			zPoint = zPoint:ToScreen()
			draw.DrawText("Zombie Spawn (" .. x .. ")", "DarkRPHUD2", zPoint.x, zPoint.y - 20, Color(255, 255, 255, 200), 1)
			draw.DrawText("Zombie Spawn (" .. x .. ")", "DarkRPHUD2", zPoint.x + 1, zPoint.y - 21, Color(255, 0, 0, 255), 1)
		end
	end
end

/*---------------------------------------------------------------------------
Actual HUDPaint hook
---------------------------------------------------------------------------*/
function GM:HUDPaint()
	DrawHUD()
	DrawZombieInfo()
	DrawEntityDisplay()

	self.BaseClass:HUDPaint()
end
timer.Simple( 0.1, HUDPaint )