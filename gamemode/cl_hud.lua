
	
surface.CreateFont( "ArtistInfo", {
	font = "Calabri",
	size = 12,
	weight = 1500,
	antialias = true
} )	
surface.CreateFont( "MelonInfo", {
	font = "Calabri",
	size = 20,
	weight = 1500,
	antialias = true
} )
surface.CreateFont( "StoryText", {
	font = "Calabri",
	size = 25,
	weight = 1000,
	antialias = true
} )
surface.CreateFont( "Title", {
	font = "Calabri",
	size = 40,
	weight = 1000,
	antialias = true
} )
surface.CreateFont( "RespawnTimer", {
	font = "Calabri",
	size = 50,
	weight = 1000,
	antialias = true,
	shadow = true,
	additive = true,
	outline = true,
} )
surface.CreateFont( "ChoostFaction", {
	font = "Calabri",
	size = 60,
	weight = 1000,
	antialias = true,
	shadow = true,
	additive = true,
	outline = true,
} )
	
-- HUD GUI
local CrosshairTex = Material( "saikred/melontank/orange_crosshair.png" )
local UITex = Material( "saikred/melontank/UI.png" )
UIMelon = Material( "saikred/melontank/melon_half.png" )
UIMelon_moon = Material( "saikred/melontank/melon_half_moon.png" )
UILogo = Material( "saikred/melontank/logo.png" )
gui.EnableScreenClicker( true )
NextPrimFire = CurTime()
NextSecFire = NextPrimFire
function GM:HUDPaint()
	surface.SetMaterial( UITex )
	surface.SetDrawColor( Color( 255 , 255 , 255 , 255 ) )
	local ScrWide = ScrW()
	local ScrHigh = ScrH()
	local UIHeight = ScrWide / 12
	if LocalPlayer().HP and LocalPlayer().HP > 0 then
		surface.DrawTexturedRect( 0 , ScrHigh -UIHeight  , ScrWide, UIHeight )
		draw.SimpleText( "F1 - Team Menu", "StoryText", ScrWide * 0.225 , ScrHigh - UIHeight * 0.575 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
		draw.SimpleText( "F2 - Loadout Menu", "StoryText", ScrWide * 0.225 , ScrHigh - UIHeight * 0.335 ,  Color( 255 , 255 , 255 , 255 ) , TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
	
		if LocalPlayer().TankEnt then
			draw.RoundedBox( 0, ScrWide * 0.897 , ScrHigh - UIHeight * 0.595 , ( ScrWide * 0.0785 ) * (LocalPlayer().HP / 100 ) , UIHeight * 0.125, Color( 255, 0 , 0 , 255 ) )
			draw.RoundedBox( 0, ScrWide * 0.897 , ScrHigh - UIHeight * 0.332 , ( ScrWide * 0.0785 ) * ( math.Clamp( LocalPlayer().Shield , 0 , 100 ) / 100 ) , UIHeight * 0.125, Color( 50, 50 , 255 , 255 ) )
			if LocalPlayer().Shield > 100 then
				draw.RoundedBox( 0, ScrWide * 0.897 , ScrHigh - UIHeight * 0.30 , ( ScrWide * 0.0785 ) * ( math.Clamp( LocalPlayer().Shield - 100 , 0 , 100 ) / 100 ) , UIHeight * 0.095, Color( 0, 150 , 255 , 255 ) )
			end
			draw.RoundedBox( 0, ScrWide * 0.0799 , ScrHigh - UIHeight * 0.615 , ( ScrWide * 0.0785 ) * math.Clamp((NextPrimFire - CurTime()) * 1.2  , 0 , 1) , UIHeight * 0.125, Color( 225, 215 , 0 , 255 ) )
			draw.RoundedBox( 0, ScrWide * 0.0799 , ScrHigh - UIHeight * 0.365 , ( ScrWide * 0.0785 ) * math.Clamp((NextSecFire - CurTime()) / 4  , 0 , 1) , UIHeight * 0.125, Color( 218, 165 , 0 , 255 ) )
		
		end
	
	end
	
	
	local MouseX , MouseY = input.GetCursorPos( )
	--local MouseX , MouseY = gui.MousePos()
	surface.SetMaterial( CrosshairTex )
	surface.SetDrawColor( Color( 255 , 255 , 255 , 255 ) )
	surface.DrawTexturedRectRotated( MouseX , MouseY , 100, 100 , CurTime() * -20 )
	local CurrentTime = CurTime()
	if RespawnIn - CurrentTime >= 0 then
		draw.SimpleText( "Respawn in: " ..  math.floor( RespawnIn - CurrentTime ), "RespawnTimer", ScrW() / 2 + math.random( -3 , 3 ), ScrH() / 2 + math.random( -3 , 3 ), Color( 100 , 100, 100 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
		draw.SimpleText( "Respawn in: " ..  math.floor( RespawnIn - CurrentTime ), "RespawnTimer", ScrW() / 2 , ScrH() / 2 ,  Color( 255 , 255 , 255 , 255 ) , TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
	end
	
	
	draw.RoundedBox( 8 , ScrW() / 2 - 100 , -10 , 200 , 105 , Color( 0 , 190 , 0 , 200 ) )
	
	surface.SetMaterial( UIMelon )
	surface.SetDrawColor( Color( 255 , 255 , 255 , 255 ) )
	surface.DrawTexturedRectRotated( ScrW() / 2 - 60 , 53 , 50 , 70 , -130 )
	surface.SetMaterial( UIMelon_moon )
	surface.DrawTexturedRectRotated( ScrW() / 2 + 60 , 53 , 50 , 70 , 130 )
	
	draw.SimpleTextOutlined( "Spawns Remaining" , "StoryText", ScrW() / 2 , 15 , Color( 255 , 255 , 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER , 1, Color( 0 , 0 , 0 , 255 ) )
	if TeamsTable.Red > -1 then
		draw.SimpleTextOutlined( TeamsTable.Red , "RespawnTimer", ScrW() / 2 - 10 , 25 , Color( 255 , 255 , 255 , 255 ), TEXT_ALIGN_RIGHT , TEXT_ALIGN_BOTTOM , 5, Color( 0 , 0 , 0 , 255 ) )
	end                                
	if TeamsTable.Blue > -1 then
		draw.SimpleTextOutlined( TeamsTable.Blue , "RespawnTimer", ScrW() / 2 + 10 , 25 , Color( 255 , 255 , 255 , 255 ), TEXT_ALIGN_LEFT , TEXT_ALIGN_BOTTOM , 5, Color( 0 , 0 , 0 , 255 ) )
	end
	local MyCol = LocalPlayer().TeamCol
	if MyCol == "Red" and TeamsTable.Red == 0 then
		draw.SimpleText( "No Respawns left" , "RespawnTimer", ScrW() / 2 + math.random( -3 , 3 ),120 + math.random( -3 , 3 ), Color( 100 , 100, 100 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
		draw.SimpleText( "No Respawns left" , "RespawnTimer", ScrW() / 2 , 120 ,  Color( 255 , 255 , 255 , 255 ) , TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
	elseif MyCol == "Blue" and TeamsTable.Blue == 0 then
		draw.SimpleText( "No Respawns left" , "RespawnTimer", ScrW() / 2 + math.random( -3 , 3 ),120 + math.random( -3 , 3 ), Color( 100 , 100, 100 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
		draw.SimpleText( "No Respawns left" , "RespawnTimer", ScrW() / 2 , 120 ,  Color( 255 , 255 , 255 , 255 ) , TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
	end
	
	
	--if TeamsTable.Green > -1 then
		--draw.SimpleText( TeamsTable.Green , "RespawnTimer", ScrW() / 2,		 20 , Color( 0 , 255 , 0 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_BOTTOM )
	--end
	for _,ply in pairs( player.GetAll() ) do
		--[[if not ply.AvatarImg then
			ply.AvatarImg = vgui.Create( "AvatarImage" )
			ply.AvatarImg:SetSize( 26,26 )
			ply.AvatarImg:SetPos( -30 ,-30 )
			ply.AvatarImg:SetPlayer( ply )
			ply.AvatarImg:SetMouseInputEnabled( false )
			ply.AvatarImg:SetKeyboardInputEnabled( false )
		end]]
		if IsValid( ply.TankEnt ) and ply.HP > 0 then
			local Clr = Color( 0 , 255 , 0 , 255 )
			if ply.TeamCol == "Red" then 
				Clr = Color( 255 , 0 , 0 , 255 )
			elseif ply.TeamCol == "Blue" then 
				Clr = Color( 0 , 0 , 255 , 255 )
			end
			local Screenpos = ply.TankEnt:GetPos():ToScreen()
			--if not ( Screenpos.x > 100 and Screenpos.x < ScrW() - 100 and Screenpos.y > 100 or Screenpos.y < ScrH() - 100 ) then
				local XPos = math.Clamp( Screenpos.x , 50 , ScrW() - 50 ) - 9
				local YPos = math.Clamp( Screenpos.y , 50 , ScrH() - 200 ) - 9
				
				if not ( XPos > 50 - 9 and XPos < ScrW() - 50 - 9 and YPos > 50 - 9 and YPos < ScrH() - 200 - 9 ) then
					draw.RoundedBox( 10 , XPos -2 , YPos -2 , 40 , 40 , Color( 0 , 255 , 0 , 255 ) )
					draw.RoundedBox( 8 , XPos , YPos , 36 , 36 , Clr )
		--		ply.AvatarImg:SetPos(math.Clamp( Screenpos.x , 0 , ScrW() - 0 ) - 4 , math.Clamp( Screenpos.y , 0 , ScrH() - 0 ) - 4 )
				end
		end
	end
end



local tab =
{
 [ "$pp_colour_addr" ] = 0.02,
 [ "$pp_colour_addg" ] = 0.02,
 [ "$pp_colour_addb" ] = 0.02,
 [ "$pp_colour_brightness" ] = 0,
 [ "$pp_colour_contrast" ] = 1,
 [ "$pp_colour_colour" ] = 3,
 [ "$pp_colour_mulr" ] = 0.02,
 [ "$pp_colour_mulg" ] = 0.02,
 [ "$pp_colour_mulb" ] = 0.02
}

function GM:RenderScreenspaceEffects()

 DrawColorModify( tab )

end

MelonFacts = {
"Not only does it quench your thirst, it can also quench inflammation that contributes to conditions like asthma, atherosclerosis, diabetes, colon cancer, and arthritis."
,"Over 1,200 varieties of watermelon are grown worldwide."
,"Watermelon is an ideal health food because it doesn’t contain any fat or cholesterol, is high in fiber and vitamins A & C and is a good source of potassium."
,"Pink watermelon is also a source of the potent carotenoid antioxidant, lycopene. These powerful antioxidants travel through the body neutralizing free radicals."
,"Watermelon is a vegetable! It is related to cucumbers, pumpkins and squash."
,"Early explorers used watermelons as canteens."
,"Watermelon is grown in over 96 countries worldwide."
,"In China and Japan watermelon is a popular gift to bring a host."
,"In Israel and Egypt, the sweet taste of watermelon is often paired with the salty taste of feta cheese."
,"Every part of a watermelon is edible, even the seeds and rinds."
,"The first recorded watermelon harvest occurred nearly 5,000 years ago in Egypt."
,"Watermelon is 92% water."
,"Watermelon's official name is Citrullus Lanatus of the botanical family Curcurbitaceae. It is cousins to cucumbers, pumpkins and squash."
,"By weight, watermelon is the most-consumed melon in the U.S., followed by cantaloupe and honeydew."
,"Early explorers used watermelons as canteens."
,"The first cookbook published in the U.S. in 1776 contained a recipe for watermelon rind pickles."
,"According to Guinness World Records, the world's heaviest watermelon was grown by Lloyd Bright of Arkadelphia, Arkansas in 2005, weighing in at 268.8 lbs (121.93 kg). Lloyd grew and weighed in for the Annual Hope, Arkansas Big Watermelon Contest on September 3, 2005."
,"The United States currently ranks 5th in worldwide production of watermelon. Forty-four states grow watermelons with Florida, Texas, California, Georgia and Arizona consistently leading the country in production."
,"Minecraft Melons are not an impossibility. By growing a Melon in a square perspecs box, it grows into a square shelf. Some Asian countries like this, because it makes putting them on shelves easier."
}

net.Receive( "SplashScreen" , function()
end )

function GetTeamSize( TEAM )
	local NumInTeam = 0
	for _,ply in pairs( player.GetAll() ) do
		if ply.TeamCol == TEAM then
			NumInTeam = NumInTeam + 1
		end
	end
	return NumInTeam
end

net.Receive( "TeamMenu" , function()
print( "Trying to open TeamMenu Menu" )
if IsValid( TeamMenu ) then TeamMenu:Remove() return end

	TeamMenu = vgui.Create( "DPanel")
	TeamMenu:SetSize( 800 , 800 )
	TeamMenu:SetPos( ScrW() / 2 - 400 , ScrH() / 2 - 400 )
	TeamMenu:SetKeyboardInputEnabled( true )
--	TeamMenu:SetMouseInputEnabled( true )
	--TeamMenu:SetCursor( "none" )
	TeamMenu.Paint = function()
							draw.RoundedBox( 20 , 0 , 0 , 800 , 800 , Color( 0 , 100 , 0 , 255 ) )
							draw.RoundedBox( 20 , 8 , 8 , 783 , 783 , Color( 0 , 170 , 0 , 255 ) )
							surface.SetMaterial( UILogo )
							surface.SetDrawColor( Color( 255 , 255 , 255 , 255 ) )
							surface.DrawTexturedRect( 200 , 10 , 400, 170 )
							
							draw.SimpleText( "Choose your Faction!" , "ChoostFaction", 400, 210 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
							draw.SimpleText( "or" , "ChoostFaction", 400, 330 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
							
							local BluClr = 200
							local RedClr = 200
							if GetTeamSize( "Blue" ) > GetTeamSize( "Red" ) then
								BluClr = 150
							    RedClr = 255
							elseif GetTeamSize( "Blue" ) < GetTeamSize( "Red" ) then
								BluClr = 255
							    RedClr = 150
							end
							surface.SetMaterial( UIMelon )
							surface.SetDrawColor( Color( RedClr , RedClr , RedClr , 255 ) )
							surface.DrawTexturedRect( 220 , 250 , 140, 180 )
							
							draw.SimpleText( "Corrupt" , "RespawnTimer", 135, 280 , Color( RedClr , RedClr, RedClr , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
							draw.SimpleText( "Citrullus" , "RespawnTimer", 135, 330 , Color( RedClr , RedClr, RedClr , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
							draw.SimpleText( "Revolution" , "RespawnTimer", 135, 380 , Color( RedClr , RedClr, RedClr , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
							draw.SimpleText( "Players:  " .. GetTeamSize( "Red" ) , "MelonInfo", 135, 410 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
							
							local BlueColour = 255 * ( ( GetTeamSize( "Blue" ) - GetTeamSize( "Red" ) ) )
							
							surface.SetMaterial( UIMelon_moon )
							surface.SetDrawColor( Color( BluClr , BluClr , BluClr , 255 ) )
							surface.DrawTexturedRect( 440 , 250 , 140, 180 )
							
							draw.SimpleText( "Marvelous" , "RespawnTimer", 800 - 135, 280 , Color( BluClr , BluClr, BluClr , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
							draw.SimpleText( "Moon-Melon" , "RespawnTimer", 800 - 135, 330 , Color( BluClr , BluClr, BluClr , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
							draw.SimpleText( "Uprising" , "RespawnTimer", 800 - 135, 380 , Color( BluClr	 , BluClr, BluClr , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
							draw.SimpleText( "Players:  " .. GetTeamSize( "Blue" ) , "MelonInfo", 800 - 135, 410 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )

							draw.SimpleText( "Official forums @ kickass-servers.net - Music Remix's by Jani Väänänen & Dr1661, Edits by Saikred - Map Created by Deep, Compiled by Saikred." , "ArtistInfo", 400, 775 , Color( 0 , 50, 0 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
						end
						
	MelonStory = "In the not too distant future, a giant energy crisis has struck. Due to the change in the atmosphere, the sun's light is restricted. Most other forms of energy, specially portable energy started failing. So scientists went about trying to develop other forms of portable energy soruces.\n\nLittle did they know, it was right in front of them the whole time. But shortly a new problem arose. Two factions were created, each believing their power source is better."
	
	local InfoLabel = vgui.Create( "DLabel" , TeamMenu )
	InfoLabel:SetPos( 80 , 400 )
	InfoLabel:SetSize( 640 , 300 )
	InfoLabel:SetWrap( true )
	InfoLabel:SetText( MelonStory )
	InfoLabel:SetFont( "StoryText" )
	InfoLabel:SetColor( Color( 240 , 240 , 240 , 255 ) )
	
	local InfoLabel = vgui.Create( "DLabel" , TeamMenu )
	InfoLabel:SetPos( 100 , 680 )
	InfoLabel:SetSize( 600 , 90 )
	InfoLabel:SetWrap( true )
	InfoLabel:SetText( "Melonfact:  " .. table.Random( MelonFacts ) )
	InfoLabel:SetFont( "MelonInfo" )
	InfoLabel:SetColor( Color( 255 , 255 , 255 , 255 ) )
	
	local TeamButton = vgui.Create( "DButton" , TeamMenu )
	TeamButton:SetPos( 10 , 250 )
	TeamButton:SetSize( 350 , 185 )
	TeamButton:SetText( "" )
	TeamButton.Paint = nil
	TeamButton.DoClick = function() RunConsoleCommand( "SetTeam" , "Red" ) TeamMenu:Remove() TeamMenu = nil RunConsoleCommand( "CloseMenu" ) end
	
	local Team2Button = vgui.Create( "DButton" , TeamMenu )
	Team2Button:SetPos( 440 , 250 )
	Team2Button:SetSize( 350 , 185 )
	Team2Button:SetText( "" )
	Team2Button.Paint = nil
	Team2Button.DoClick = function() RunConsoleCommand( "SetTeam" , "Blue" ) TeamMenu:Remove() TeamMenu = nil RunConsoleCommand( "CloseMenu" ) end
	
	local SpecButton = vgui.Create( "DButton" , TeamMenu )
	SpecButton:SetPos( 350 , 385 )
	SpecButton:SetSize( 100 , 40 )
	SpecButton:SetText( "" )
	SpecButton.Paint = function( Self , W , H ) 
							draw.SimpleText( "Spectate" , "StoryText", W / 2, H / 2 , Color( 220 , 255, 100 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
						end
	SpecButton.DoClick = function() RunConsoleCommand( "SetTeam" , "Spec" ) TeamMenu:Remove() TeamMenu = nil RunConsoleCommand( "CloseMenu" ) end
	
	local CloseButton = vgui.Create( "DButton" , TeamMenu )
	CloseButton:SetPos( 700 , 10 )
	CloseButton:SetSize( 100 , 40 )
	CloseButton:SetText( "" )
	CloseButton.Paint = function( Self , W , H ) 
							draw.SimpleText( "Close" , "StoryText", W / 2, H / 2 , Color( 220 , 255, 100 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
						end
	CloseButton.DoClick = function() TeamMenu:Remove() TeamMenu = nil RunConsoleCommand( "CloseMenu" ) end
	
	TeamMenu:MakePopup()
	
end )

local SelectedPrim = "shell_basic"
local SelectedSec = "mine"
function SendLoadout()
	net.Start( "SendWep" )
		net.WriteTable( { LocalPlayer() , SelectedPrim , SelectedSec } )
	net.SendToServer()
end
net.Receive( "LoadoutMenu" , function()
print( "Trying to open Loadout Menu" )
if IsValid( LoadoutMenu ) then LoadoutMenu:Remove() return end

	LoadoutMenu = vgui.Create( "DPanel")
	LoadoutMenu:SetSize( 850 , 600 )
	LoadoutMenu:SetPos( ScrW() / 2 - 400 , ScrH() / 2 - 400 )
	LoadoutMenu:SetKeyboardInputEnabled( true )
--	LoadoutMenu:SetMouseInputEnabled( true )
	--LoadoutMenu:SetCursor( "none" )
	LoadoutMenu.Paint = function( self , w , h )
							draw.RoundedBox( 20 , 0 , 0 , w , h , Color( 0 , 100 , 0 , 255 ) )
							draw.RoundedBox( 20 , 8 , 8 , w - 16 , h - 16 , Color( 0 , 170 , 0 , 255 ) )
							surface.SetMaterial( UILogo )
							surface.SetDrawColor( Color( 255 , 255 , 255 , 255 ) )
							surface.DrawTexturedRect( w / 2 - 200 , 10 , 400, 170 )
							
							draw.SimpleText( "Choose your Weapon Loadout!" , "ChoostFaction", 425, 210 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
							draw.SimpleText( "Primary Fire" , "Title", w / 4 , 270 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
							draw.SimpleText( "Secondary Fire" , "Title", w / 4 * 3, 270 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
						end
						
	
	local InfoLabel = vgui.Create( "DLabel" , LoadoutMenu )
	InfoLabel:SetPos( 100 , 700 )
	InfoLabel:SetSize( 600 , 90 )
	InfoLabel:SetWrap( true )
	InfoLabel:SetText( "Melonfact:  " .. table.Random( MelonFacts ) )
	InfoLabel:SetFont( "MelonInfo" )
	InfoLabel:SetColor( Color( 255 , 255 , 255 , 255 ) )
	
	local SelectPrim = vgui.Create( "DButton" , LoadoutMenu )
	SelectPrim:SetPos( 50 , 250 )
	SelectPrim:SetSize( 350 , 80 )
	SelectPrim:SetText( "Normal Shell" )
	SelectPrim:SetFont( "Title" )
	SelectPrim.Paint = function( self , w , h )
							if SelectedPrim == "shell_basic" then
								draw.RoundedBox( 10 , 0 , 0 , w , h , Color( 40 , 240 , 40 , 255 ) )
							else
								draw.RoundedBox( 10 , 0 , 0 , w , h , Color( 0 , 210 , 0 , 255 ) )
							end
						end
	SelectPrim.DoClick = function() SelectedPrim = "shell_basic" end

	local SelectPrim = vgui.Create( "DButton" , LoadoutMenu )
	SelectPrim:SetPos( 50 , 340 )
	SelectPrim:SetSize( 350 , 80 )
	SelectPrim:SetText( "Rocket Shell" )
	SelectPrim:SetFont( "Title" )
	SelectPrim.Paint = function( self , w , h )
							if SelectedPrim == "shell_fast" then
								draw.RoundedBox( 10 , 0 , 0 , w , h , Color( 40 , 240 , 40 , 255 ) )
							else
								draw.RoundedBox( 10 , 0 , 0 , w , h , Color( 0 , 210 , 0 , 255 ) )
							end
						end
	SelectPrim.DoClick = function() SelectedPrim = "shell_fast" end

	local SelectPrim = vgui.Create( "DButton" , LoadoutMenu )
	SelectPrim:SetPos( 50 , 430 )
	SelectPrim:SetSize( 350 , 80 )
	SelectPrim:SetText( "Rebounding Shell" )
	SelectPrim:SetFont( "Title" )
	SelectPrim.Paint = function( self , w , h )
							if SelectedPrim == "shell_rebound" then
								draw.RoundedBox( 10 , 0 , 0 , w , h , Color( 40 , 240 , 40 , 255 ) )
							else
								draw.RoundedBox( 10 , 0 , 0 , w , h , Color( 0 , 210 , 0 , 255 ) )
							end
						end
	SelectPrim.DoClick = function() SelectedPrim = "shell_rebound" end
	
	local SelectSec = vgui.Create( "DButton" , LoadoutMenu )
	SelectSec:SetPos( 450 , 250 )
	SelectSec:SetSize( 350 , 80 )
	SelectSec:SetText( "Roller Mine" )
	SelectSec:SetFont( "Title" )
	SelectSec.Paint = function( self , w , h )
							if SelectedSec == "mine" then
								draw.RoundedBox( 10 , 0 , 0 , w , h , Color( 40 , 240 , 40 , 255 ) )
							else
								draw.RoundedBox( 10 , 0 , 0 , w , h , Color( 0 , 210 , 0 , 255 ) )
							end
						end
	SelectSec.DoClick = function() SelectedSec = "mine" end
	
	local SelectSec = vgui.Create( "DButton" , LoadoutMenu )
	SelectSec:SetPos( 450 , 340 )
	SelectSec:SetSize( 350 , 80 )
	SelectSec:SetText( "Time & Prox Mine" )
	SelectSec:SetFont( "Title" )
	SelectSec.Paint = function( self , w , h )
							if SelectedSec == "mine_time" then
								draw.RoundedBox( 10 , 0 , 0 , w , h , Color( 40 , 240 , 40 , 255 ) )
							else
								draw.RoundedBox( 10 , 0 , 0 , w , h , Color( 0 , 210 , 0 , 255 ) )
							end
						end
	SelectSec.DoClick = function() SelectedSec = "mine_time" end
	
	local SelectSec = vgui.Create( "DButton" , LoadoutMenu )
	SelectSec:SetPos( 450 , 430 )
	SelectSec:SetSize( 350 , 80 )
	SelectSec:SetText( "Missile" )
	SelectSec:SetFont( "Title" )
	SelectSec.Paint = function( self , w , h )
							if SelectedSec == "missile" then
								draw.RoundedBox( 10 , 0 , 0 , w , h , Color( 40 , 240 , 40 , 255 ) )
							else
								draw.RoundedBox( 10 , 0 , 0 , w , h , Color( 0 , 210 , 0 , 255 ) )
							end
						end
	SelectSec.DoClick = function() SelectedSec = "missile" end
	
	
	
	local SelectLoadout = vgui.Create( "DButton" , LoadoutMenu )
	SelectLoadout:SetPos( 125 , 520 )
	SelectLoadout:SetSize( 600 , 60 )
	SelectLoadout:SetText( "Use selected Loadout?" )
	SelectLoadout:SetFont( "Title" )
	SelectLoadout.Paint = function( self , w , h )
							draw.RoundedBox( 10 , 0 , 0 , w , h , Color( 40 , 240 , 40 , 255 ) )
						end
	SelectLoadout.DoClick = function()  LoadoutMenu:Remove() LoadoutMenu = nil SendLoadout() end
	
	
	local CloseButton = vgui.Create( "DButton" , LoadoutMenu )
	CloseButton:SetPos( 750 , 10 )
	CloseButton:SetSize( 100 , 40 )
	CloseButton:SetText( "" )
	CloseButton.Paint = function( Self , W , H ) 
							draw.SimpleText( "Close" , "StoryText", W / 2, H / 2 , Color( 220 , 255, 100 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
						end
	CloseButton.DoClick = function() LoadoutMenu:Remove() LoadoutMenu = nil SendLoadout() end
	
	LoadoutMenu:MakePopup()
	
end )

WinningYells = {
"Huzzah!"
,"Jolly good"
,"Fantastic!"
,"Brilliant!"
,"Hooray!"
,"Victory!"
}
net.Receive( "EndGameSplash" , function()
	if IsValid( EndGameSplash ) then EndGameSplash:Remove() RunConsoleCommand( "CloseMenu" ) return end
end )
net.Receive( "EndGameSplash" , function()
print( "Trying to popup end game splash" )
local WinningTeam = net.ReadString()
local NextGame = net.ReadFloat()
local WinningText = table.Random( WinningYells )
if IsValid( EndGameSplash ) then EndGameSplash:Remove() end

	EndGameSplash = vgui.Create( "DPanel")
	EndGameSplash:SetSize( 850 , 600 )
	EndGameSplash:SetPos( ScrW() / 2 - 400 , ScrH() / 2 - 400 )
	EndGameSplash:SetKeyboardInputEnabled( false )
--	EndGameSplash:SetMouseInputEnabled( true )
	--EndGameSplash:SetCursor( "none" )
	EndGameSplash.Think = function() if NextGame <= CurTime() then EndGameSplash:Remove() RunConsoleCommand( "CloseMenu" ) EndGameSplash = nil end end
	EndGameSplash.Paint = function( self , w , h )
							draw.RoundedBox( 20 , 0 , 0 , w , h , Color( 0 , 100 , 0 , 255 ) )
							draw.RoundedBox( 20 , 8 , 8 , w - 16 , h - 16 , Color( 0 , 170 , 0 , 255 ) )
							if WinningTeam == "Blue" then
								draw.RoundedBox( 20 , 30 , 30 , w - 60 , h - 60 , Color( 0 , 0 , 200 , 255 ) )
								surface.SetMaterial( UIMelon_moon )
								surface.SetDrawColor( Color( 255 , 255 , 255 , 255 ) )
								surface.DrawTexturedRect( 27 , 190 , 300, 380 )
								
								draw.SimpleText( "The Marvelous" , "ChoostFaction", w / 2 , 280 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
								draw.SimpleText( "Moon-Melon Uprising" , "ChoostFaction", w / 2 , 330 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
								draw.SimpleText( "Defeated the Enemy" , "ChoostFaction", w / 2 , 400 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
								draw.SimpleText( WinningText , "ChoostFaction", w / 2 , 490 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
							else
								draw.RoundedBox( 20 , 30 , 30 , w - 60 , h - 60 , Color( 200 , 0 , 0 , 255 ) )
								surface.SetMaterial( UIMelon )
								surface.SetDrawColor( Color( 255 , 255 , 255 , 255 ) )
								surface.DrawTexturedRect( 510 , 180 , 300, 380 )
								
								draw.SimpleText( "The Evil" , "ChoostFaction", w / 2 , 280 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
								draw.SimpleText( "Citrullus Revolution" , "ChoostFaction", w / 2 , 330 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
								draw.SimpleText( "Defeated the Enemy" , "ChoostFaction", w / 2 , 400 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
								draw.SimpleText( WinningText , "ChoostFaction", w / 2 , 490 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
							end
							surface.SetMaterial( UILogo )
							surface.SetDrawColor( Color( 255 , 255 , 255 , 255 ) )
							surface.DrawTexturedRect( w / 2 - 200 , 40 , 400, 170 )
							
							
						draw.SimpleText( "Next game in: " .. math.floor( NextGame - CurTime() ) , "StoryText", 700, 520 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )surface.SetMaterial( UIMelon )
						end
							
	
	local CloseButton = vgui.Create( "DButton" , EndGameSplash )
	CloseButton:SetPos( 710 , 40 )
	CloseButton:SetSize( 100 , 40 )
	CloseButton:SetText( "" )
	CloseButton.Paint = function( Self , W , H ) 
							draw.SimpleText( "Close" , "StoryText", W / 2, H / 2 , Color( 220 , 255, 100 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
						end
	CloseButton.DoClick = function()
			EndGameSplash:Remove() 
			RunConsoleCommand( "CloseMenu" )
			EndGameSplash = nil
		end
	
	EndGameSplash:MakePopup()
	
end )


