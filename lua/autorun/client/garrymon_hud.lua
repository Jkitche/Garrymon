local sw, sh
local MainPanel
/*hook.Add("InitPostEntity", "GMon_HUDInit", function()
	local tr = LocalPlayer():GetEyeTrace()
	local pos = tr.HitPos + tr.HitNormal * 4
	local ang = tr.HitNormal:Angle()
	ang:RotateAroundAxis( ang:Up(), 90 )
	ang:RotateAroundAxis( ang:Forward() * -1, -90 )
	
	sw = ScrW()
	sh = ScrH()
	
	MainPanel = vgui.Create("DFrame")
	MainPanel:SetSize(sw * .45, sh * .33)
	MainPanel:Center()
	MainPanel:SetTitle(string.rep(" ", 21) .. "Gabedex - Garrymon Controller")
	MainPanel:SetDraggable(true)
	MainPanel:ShowCloseButton(true)
	MainPanel:SetVisible(false)
	MainPanel:SetDeleteOnClose(false)
	MainPanel.Paint = function()
		draw.NoTexture()
		DrawGHUDPod(50, MainPanel:GetWide(), MainPanel:GetTall(), Color(0,200,255,127))
	end
	
	
	local TestingComboBox = vgui.Create( "DComboBox", MainPanel )
	TestingComboBox:SetPos( 400, 35 )
	TestingComboBox:SetSize( 100, 185 )
	TestingComboBox:AddItem( "Add" ) -- Add our options
	TestingComboBox:AddItem( "Some" )
	TestingComboBox:AddItem( "Options" )
	TestingComboBox:AddItem( "Here" )
	
	local pokep = vgui.Create("DFrame", MainPanel)
	pokep:SetPos(25,45)
	pokep:SetSize(250,100)
	pokep:ShowCloseButton(false)
	pokep:SetTitle("")
	pokep.Paint = function()
		draw.NoTexture()
		DrawGHUDPod(15, pokep:GetWide(), pokep:GetTall(), Color(0,200,255,255))
		
		surface.SetDrawColor(255,255,255,255)
		surface.DrawRect(15,15, 65, 65)
	end
	
	local hBar = vgui.Create("DFrame", pokep)
	hBar:SetPos(90, 30)
	hBar:SetSize(145, 20)
	hBar:ShowCloseButton(false)
	hBar:SetTitle("")
	hBar.Paint = function()
		draw.NoTexture()
		DrawGHUDPod(5, hBar:GetWide(), hBar:GetTall(), Color(0,0,0,255))
		
		surface.SetDrawColor(255,255,255,255)
		surface.SetFont("ChatFont")
		surface.SetTextPos(3,3)
		surface.DrawText("HP")
		
		local HPPercent = math.Clamp(LocalPlayer():Health() / 100, 0, 100)
		local color = (HPPercent > 0.5) and Color(113, 247, 168) or ((HPPercent > 0.25) and Color(224, 219, 57) or Color(237, 91, 60))
		surface.SetDrawColor(color.r,color.g,color.b,255)
		local barLen = 115 * math.Clamp(LocalPlayer():Health() / 100, 0, 100)
		surface.DrawRect( 25, 3, barLen, 14)
	end
	
	local icon = vgui.Create("DModelPanel", pokep)
	icon:SetModel("models/weapons/w_models/w_pokeball.mdl")
	icon:SetPos(22.5,22.5)
	icon:SetSize(50,50)
	icon:SetCamPos(Vector(5,5,5))
	icon:SetLookAt(Vector())
	
	local pad = vgui.Create("DNumPad", MainPanel)
	pad:SetPos(25, 175)
	
	local confirmButton = vgui.Create("DButton", MainPanel)
	confirmButton:SetSize(75,30)
	confirmButton:Center()
	confirmButton:SetText(" Are you sure?")
	confirmButton:SetVisible(false)
	confirmButton.Paint = function()
		draw.NoTexture()
		if confirmButton:IsDown() then
			DrawGHUDPod(10, confirmButton:GetWide(), confirmButton:GetTall(), Color(255,255,0,255))
		else
			DrawGHUDPod(10, confirmButton:GetWide(), confirmButton:GetTall(), Color(0,200,255,255))
		end
	end
	confirmButton.DoClick = function()
		confirmButton:SetVisible(false)
	end
	
	local abButton = vgui.Create("DButton", MainPanel)
	abButton:SetPos(150, 175)
	abButton:SetSize(65,30)
	abButton:SetText("    Abandon\n    Selected")
	abButton.Paint = function()
		draw.NoTexture()
		if abButton:IsDown() then
			DrawGHUDPod(10, abButton:GetWide(), abButton:GetTall(), Color(255,255,0,255))
		else
			DrawGHUDPod(10, abButton:GetWide(), abButton:GetTall(), Color(0,200,255,255))
		end
	end
	abButton.DoClick = function()
		confirmButton:SetVisible(true)
	end
end)

function DrawGHUDPod(cutoff, w, h, col)
	local backPoints = {{},{},{},{},{},{}}
	backPoints[1].x = cutoff
	backPoints[1].y = 0
	backPoints[1].u = 0
	backPoints[1].v = 0
	
	backPoints[2].x = w
	backPoints[2].y = 0
	backPoints[2].u = 0
	backPoints[2].v = 0
	
	backPoints[3].x = w
	backPoints[3].y = h - cutoff
	backPoints[3].u = 0
	backPoints[3].v = 0
	
	backPoints[4].x = w - cutoff
	backPoints[4].y = h
	backPoints[4].u = 0
	backPoints[4].v = 0
	
	backPoints[5].x = 0
	backPoints[5].y = h
	backPoints[5].u = 0
	backPoints[5].v = 0
	
	backPoints[6].x = 0
	backPoints[6].y = cutoff
	backPoints[6].u = 0
	backPoints[6].v = 0
	
	
	surface.SetDrawColor(col.r,col.g,col.b,col.a)
	surface.DrawPoly(backPoints)
	
end
concommand.Add("+gmon_hud", function() 
	MainPanel:SetVisible(true); 	
	gui.EnableScreenClicker(true) 
end)
concommand.Add("-gmon_hud", function() MainPanel:SetVisible(false); gui.EnableScreenClicker(false) end)
*/

surface.CreateFont("Pokefont", { font = "ChatFont", size = 30, weight = 400, antialias = true, shadow = false } )
local pokeTexture = surface.GetTextureID("pokemon/pokeball")
local crossTexture = surface.GetTextureID("pokemon/pokeballCross")
hook.Add("PostDrawTranslucentRenderables", "DrawPercents", function()
	if not LocalPlayer().ShowCatchRate then return end
	for k, v in pairs(ents.GetAll()) do
		if v:IsValid() and v:IsNPC() and not (v:GetMoveType() == 0) then
			local tPos = v:GetPos() + Vector(0,0,v:OBBMaxs().z + 15)
			
			local ang = LocalPlayer():EyeAngles()
			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 90 )
 
			local pct = v:GetNWFloat("CatchPercent")
			pct = string.format("%6.2f", pct) .. "%"
			if string.Right(pct, 4) == "nan%" then pct = " Cannot Catch" end
			surface.SetFont("Pokefont")
			local textW, textH = surface.GetTextSize(pct)
			cam.Start3D2D( tPos, Angle( 0, ang.y, 90 ), .25 )
				surface.SetDrawColor(255,255,255,255)
				surface.SetTexture(pokeTexture)
				if table.HasValue(GMON_CLASS_EXCEPTIONS, v:GetClass()) then
					surface.DrawTexturedRect(textH * -.25, textH * .15, textH * .75, textH * .75)
					surface.SetTexture(crossTexture)
					surface.DrawTexturedRect(textH * -.25, textH * .15, textH * .75, textH * .75)
				else
					surface.DrawTexturedRect(textW * -.75, textH * .15, textH * .75, textH * .75)
	
					surface.SetTextPos(textW * -.5,0)
					surface.SetTextColor(255,255,255,255)
					surface.DrawText(pct)
				end
			cam.End3D2D()
		end
	end
end)
concommand.Add("ShowCatchRate", function(ply, cmd, args)
	ply.ShowCatchRate = not ply.ShowCatchRate
end)
