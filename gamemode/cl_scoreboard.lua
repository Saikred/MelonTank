
surface.CreateFont( "ScoreboardDefault",
{
	font		= "Helvetica",
	size		= 22,
	weight		= 800
})

surface.CreateFont( "ScoreboardDefaultTitle",
{
	font		= "Helvetica",
	size		= 32,
	weight		= 800
})


--
-- This defines a new panel type for the player row. The player row is given a player
-- and then from that point on it pretty much looks after itself. It updates player info
-- in the think function, and removes itself when the player leaves the server.
--
local PLAYER_LINE = 
{
	Init = function( self )

		if self.Team == "Spec" and ( self.Player.TeamCol != "Red" or self.Player.TeamCol != "Blue" ) then 
			self.AvatarButton = self:Add( "DButton" )
			self.AvatarButton:Dock( TOP )
			self.AvatarButton:SetSize( 32, 32 )
			self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

			self.Avatar		= vgui.Create( "AvatarImage", self.AvatarButton )
			self.Avatar:SetSize( 32, 32 )
			self.Avatar:SetMouseInputEnabled( false )		
		
			self:Dock( NODOCK )
			self:DockPadding( 3, 3, 3, 3 )
			self:SetHeight( 32 + 3*2 )
			self:DockMargin( 2, 0, 2, 2 )
		else
			self.AvatarButton = self:Add( "DButton" )
			self.AvatarButton:Dock( LEFT )
			self.AvatarButton:SetSize( 32, 32 )
			self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

			self.Avatar		= vgui.Create( "AvatarImage", self.AvatarButton )
			self.Avatar:SetSize( 32, 32 )
			self.Avatar:SetMouseInputEnabled( false )		

			self.Name		= self:Add( "DLabel" )
			self.Name:Dock( FILL )
			self.Name:SetFont( "ScoreboardDefault" )
			self.Name:DockMargin( 8, 0, 0, 0 )
			self.Name:SetColor( Color( 240 , 240 , 240 , 255 ) )

			self.Mute		= self:Add( "DImageButton" )
			self.Mute:SetSize( 32, 32 )
			self.Mute:Dock( RIGHT )

			self.Ping		= self:Add( "DLabel" )
			self.Ping:Dock( RIGHT )
			self.Ping:SetWidth( 50 )
			self.Ping:SetFont( "ScoreboardDefault" )
			self.Ping:SetContentAlignment( 5 )
			self.Ping:SetColor( Color( 240 , 240 , 240 , 255 ) )

			self:Dock( TOP )
			self:DockPadding( 3, 3, 3, 3 )
			self:SetHeight( 32 + 3*2 )
			self:DockMargin( 2, 0, 2, 2 )
		end
	end,

	Setup = function( self, pl )

		self.Player = pl

		self.Avatar:SetPlayer( pl )
		
		if IsValid( self.Name ) then
			self.Name:SetText( pl:Nick() )
		end
		
		self:Think( self )

		--local friend = self.Player:GetFriendStatus()
		--MsgN( pl, " Friend: ", friend )

	end,

	Think = function( self )

		if ( !IsValid( self.Player ) ) then
			self:Remove()
			return
		end
		if self.Player.TeamCol != self.Team then
			self:Remove()
			self:SetZPos( 1900 )
			return
		elseif self.Team == "Spec" and ( self.Player.TeamCol != "Red" or self.Player.TeamCol != "Blue" ) then 
		
		end

		if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
			self.NumPing	=	self.Player:Ping()
			self.Ping:SetText( self.NumPing )
		end

		--
		-- Change the icon of the mute button based on state
		--
		if ( self.Muted == nil || self.Muted != self.Player:IsMuted() ) then

			self.Muted = self.Player:IsMuted()
			if ( self.Muted ) then
				self.Mute:SetImage( "icon32/muted.png" )
			else
				self.Mute:SetImage( "icon32/unmuted.png" )
			end

			self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end

		end

		--
		-- Connecting players go at the very bottom
		--
		if ( self.Player:Team() == TEAM_CONNECTING ) then
			self:SetZPos( 2000 )
		end

		--
		-- This is what sorts the list. The panels are docked in the z order, 
		-- so if we set the z order according to kills they'll be ordered that way!
		-- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
		--
		--self:SetZPos( (self.NumKills * -50) + self.NumDeaths )

	end,

	Paint = function( self, w, h )

		if ( !IsValid( self.Player ) ) then
			return
		end

		--
		-- We draw our background a different colour based on the status of the player
		--
		if self.Team == "Spec" and ( self.Player.TeamCol != "Red" or self.Player.TeamCol != "Blue" ) then 
		
			draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 190, 0, 255 ) )
		end

		if ( self.Player:Team() == TEAM_CONNECTING ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color( 200, 200, 200, 200 ) )
			return
		end
		
		if ( not self.Player.HP or self.Player.HP and self.Player.HP <= 0 ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 90, 0, 200 ) )
			return
		end

		if ( self.Player:IsAdmin() ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 90, 0, 255 ) )
			draw.RoundedBox( 4, 4, 4, w-8, h-8, Color( 100, 220, 0, 255 ) )
			return
		end

		draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 90, 0, 255 ) )
		draw.RoundedBox( 4, 4, 4, w-8, h-8, Color( 0, 180, 0, 255 ) )

	end,
}

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DPanel" );

--
-- Here we define a new panel table for the scoreboard. It basically consists 
-- of a header and a scrollpanel - into which the player lines are placed.
--
local SCORE_BOARD = 
{
	Init = function( self )

		self.Header = self:Add( "Panel" )
		self.Header:Dock( TOP )
		self.Header:SetHeight( 265 )
		
		self.Scores = self:Add( "DScrollPanel" )
		self.Scores:Dock( LEFT )
		self.Scores:SetWide( 395 )
		
		self.ScoresMoon = self:Add( "DScrollPanel" )
		self.ScoresMoon:Dock( RIGHT )
		self.ScoresMoon:SetWide( 395 )
		
		self.ScoresSpec = self:Add( "DScrollPanel" )
		self.ScoresSpec:Dock( FILL )
		
	--	self.ScoresSpec = self:Add( "DScrollPanel" )
	--	self.ScoresSpec:Dock( BOTTOM )

	end,

	PerformLayout = function( self )

		self:SetSize( 850, ScrH() - 200 )
		self:SetPos( ScrW() / 2 - 425, 100 )

	end,

	Paint = function( self, w, h )

	surface.SetMaterial( UIMelon )
	surface.SetDrawColor( Color( 255 , 255 , 255 , 255 ) )
	surface.DrawTexturedRectRotated( w / 2 - 250 , 230 , 415 * 0.4 , 493 * 0.4 , 120 )
	
	surface.SetMaterial( UIMelon_moon )
	surface.SetDrawColor( Color( 255 , 255 , 255 , 255 ) )
	surface.DrawTexturedRectRotated( w / 2 + 217 , 230 , 415 * 0.4 , 493 * 0.4 , 240)
	
	surface.SetMaterial( UILogo )
	surface.SetDrawColor( Color( 255 , 255 , 255 , 255 ) )
	surface.DrawTexturedRect( w / 2 - 200 , 0 , 400, 170 )
	
	
	draw.SimpleText( "Corrupt Citrullus" , "ScoreboardDefaultTitle", w / 2 - 250 , 195 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
	draw.SimpleText( "Revolution" , "ScoreboardDefaultTitle", w / 2 - 250 , 235 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
	
	draw.SimpleText( "Marvelous Moon-Melon" , "ScoreboardDefaultTitle", w / 2 + 217 , 195 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )
	draw.SimpleText( "Uprising" , "ScoreboardDefaultTitle", w / 2 + 217 , 235 , Color( 255 , 255, 255 , 255 ), TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER )

	end,

	Think = function( self, w, h )

		--self.Name:SetText( GetHostName() )

		--
		-- Loop through each player, and if one doesn't have a score entry - create it.
		--
		local plyrs = player.GetAll()
		for id, pl in pairs( plyrs ) do

			if pl.TeamCol == "Red" then
				if ( IsValid( pl.ScoreEntry ) ) then continue end
				pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )
				pl.ScoreEntry.Team = "Red"
				pl.ScoreEntry:Setup( pl )
				self.Scores:AddItem( pl.ScoreEntry )
			elseif pl.TeamCol == "Blue" then
				if ( IsValid( pl.ScoreEntryMoon ) ) then continue end
				pl.ScoreEntryMoon = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntryMoon )
				pl.ScoreEntryMoon.Team = "Blue"
				pl.ScoreEntryMoon:Setup( pl )
				self.ScoresMoon:AddItem( pl.ScoreEntryMoon )
			else
				if ( IsValid( pl.ScoresEntrySpec ) ) then continue end
				pl.ScoresEntrySpec = vgui.CreateFromTable( PLAYER_LINE, pl.ScoresEntrySpec )
				pl.ScoresEntrySpec.Team = "Spec"
				pl.ScoresEntrySpec:Setup( pl )
				self.ScoresSpec:AddItem( pl.ScoresEntrySpec )
			end
		end
	end,
}

SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" );

--[[---------------------------------------------------------
   Name: gamemode:ScoreboardShow( )
   Desc: Sets the scoreboard to visible
-----------------------------------------------------------]]
function GM:ScoreboardShow()

	if ( !IsValid( g_Scoreboard ) ) then
		g_Scoreboard = vgui.CreateFromTable( SCORE_BOARD )
	end

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled( false )
		RunConsoleCommand( "InClMenu" )
	end

end

--[[---------------------------------------------------------
   Name: gamemode:ScoreboardHide( )
   Desc: Hides the scoreboard
-----------------------------------------------------------]]
function GM:ScoreboardHide()

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Hide()
		RunConsoleCommand( "CloseMenu" )
	end

end


--[[---------------------------------------------------------
   Name: gamemode:HUDDrawScoreBoard( )
   Desc: If you prefer to draw your scoreboard the stupid way (without vgui)
-----------------------------------------------------------]]
function GM:HUDDrawScoreBoard()

end

