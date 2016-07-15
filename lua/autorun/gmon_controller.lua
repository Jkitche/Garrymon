--[[
GMON TABLE FORMAT
Name = "SomeName"
Class = npc:GetClass()
HP = npc:Health()
MaxHP = npc:MaxHealth()
Skin = npc:GetSkin()
Mod = npc:GetModel()
Mat = npc:GetMaterial()
]]--

local DEBUG = true
local PLAYER = getmetatable("Player")

GMON_MODE_NIL = 0
GMON_MODE_FOLLOW = 1
GMON_MODE_ATTACK = 2
GMON_MODE_STAY = 3

GMON_CLASS_EXCEPTIONS = {"npc_rollermine", "npc_combinedropship", "npc_helicopter", "npc_combinegunship",
						 "NPC_turret_ceiling", "npc_combine_camera", "npc_turret_floor", "npc_barnacle",
						 "npc_antlion_grub"}


if SERVER then

local function setCatchPct(ent)
	if not ent:IsValid() then return end
	local maxhp, curhp, size, maxsize, pctrate, rate, a, p
	maxhp = ent:GetMaxHealth()
	curhp = ent:Health()
	size = ent:GetMaxHealth() + ent:OBBMaxs().z
	maxsize = 1500
	pctrate = (maxsize - math.Clamp(size, 0, maxsize)) / maxsize
	if pctrate == 0 then pctrate = .0005 end
	rate = 255 * pctrate
	if ent:IsOnFire() then bonus = 1.5 else bonus = 1 end
	a = (((3 * maxhp - 2 * curhp) * rate) / (3 * maxhp)) * bonus
	p = a / (2^8 - 1) * 100
	ent:SetNWFloat("CatchPercent", p)
end

local function getCatchPct(ent)
	if not ent:IsValid() then return end
	local maxhp, curhp, size, maxsize, pctrate, rate, a, p
	maxhp = ent:GetMaxHealth()
	curhp = ent:Health()
	size = ent:GetMaxHealth() + ent:OBBMaxs().z
	maxsize = 1500
	pctrate = (maxsize - math.Clamp(size, 0, maxsize)) / maxsize
	if pctrate == 0 then pctrate = .0005 end
	rate = 255 * pctrate
	if ent:IsOnFire() then bonus = 1.5 else bonus = 1 end
	a = (((3 * maxhp - 2 * curhp) * rate) / (3 * maxhp)) * bonus
	p = a / (2^8 - 1) * 100
	return p
end

local function NetworkHP(ent, hpdiff)
	local ratio = (ent:Health() - hpdiff) / ent:GetMaxHealth()
	net.Start("GMonHPNet")
		net.WriteEntity(ent)
		net.WriteFloat(ratio)
	net.Send(player.GetAll())
end
util.AddNetworkString("GMonHPNet")

hook.Add("EntityTakeDamage", "SetCatchPercentDmgd", function(ent, dmginfo)
	if ent:IsNPC() then
		setCatchPct(ent)
		NetworkHP(ent, dmginfo:GetDamage())
	end
end)

local function SetCatchPercSpawn(ent)
	if ent:IsNPC() then
		timer.Simple(.01, function() 
			pcall(setCatchPct, ent)
			NetworkHP(ent, 0)
		end)
	end
end
hook.Add("OnEntityCreated", "SetCatchPercentSpawn", SetCatchPercSpawn)

hook.Add("InitialPlayerSpawn", "GMonPlayerInit", function(ply)
	ply.ActiveGMon = nil
	ply.ActiveGMonState = GMON_MODE_NIL
end)

end
//END SERVER FUNCS//

//CLIENT FUNCTIONS//
if CLIENT then
local function DrawBeltBalls(ply)
	if ply.BeltBall == nil then
		ply.BeltBall = ClientsideModel("models/weapons/w_models/w_pokeball.mdl")
		ply.BeltBall:SetModelScale(.4, 0)
	end
	if ply.PokeHat == nil then
		ply.PokeHat = ClientsideModel("models/player/items/scout/fwk_scout_cap.mdl")
		ply.PokeHat:SetModelScale(1.05,0)
		ply.PokeHat.Flipped = false
	end
	local head = ply:LookupBone("ValveBiped.Bip01_Head1")
	local headPos, headAng = ply:GetBonePosition(head)
	if ply:GetNWBool("GMonHatFlipped") then
		headAng:RotateAroundAxis(headAng:Forward(), -90)
		headAng:RotateAroundAxis(headAng:Right(), 280)
		ply.PokeHat:SetPos(headPos + headAng:Forward() * -.25)
		ply.PokeHat:SetAngles(headAng)
		ply.PokeHat:SetModelScale(1.05,0)
	else
		headAng:RotateAroundAxis(headAng:Forward(), 90)
		headAng:RotateAroundAxis(headAng:Right(), 230)
		ply.PokeHat:SetPos(headPos + headAng:Forward() * -3)
		ply.PokeHat:SetAngles(headAng)
		ply.PokeHat:SetModelScale(1.05,0)
	end
	local pelvis = ply:LookupBone("ValveBiped.Bip01_Pelvis")
	local bonePos, boneAng = ply:GetBonePosition(pelvis)
	if ply.BeltBall and ply.BeltBall:IsValid() then
		boneAng:RotateAroundAxis(boneAng:Up(), 180)
		boneAng:RotateAroundAxis(boneAng:Forward(), 90)
		ply.BeltBall:SetAngles(boneAng)
		ply.BeltBall:SetPos(bonePos + boneAng:Right() * -4 + boneAng:Up() * 2 + boneAng:Forward() * 4)
		ply.BeltBall:DrawModel()
		ply.BeltBall:SetPos(bonePos + boneAng:Right() * -4.5 + boneAng:Up() * 2 + boneAng:Forward() * 2.75)
		ply.BeltBall:SetupBones()
		ply.BeltBall:DrawModel()
		ply.BeltBall:SetPos(bonePos + boneAng:Right() * -4.75 + boneAng:Up() * 2 + boneAng:Forward() * 1.5)
		ply.BeltBall:SetupBones()
		ply.BeltBall:DrawModel()
		ply.BeltBall:SetPos(bonePos + boneAng:Right() * -5 + boneAng:Up() * 2 + boneAng:Forward() * .25)
		ply.BeltBall:SetupBones()
		ply.BeltBall:DrawModel()
		ply.BeltBall:SetPos(bonePos + boneAng:Right() * -4.75 + boneAng:Up() * 2 + boneAng:Forward() * -1)
		ply.BeltBall:SetupBones()
		ply.BeltBall:DrawModel()
		ply.BeltBall:SetPos(bonePos + boneAng:Right() * -4.5 + boneAng:Up() * 2 + boneAng:Forward() * -2.25)
		ply.BeltBall:SetupBones()
		ply.BeltBall:DrawModel()
	end
end
//hook.Add("PostPlayerDraw", "DrawBeltPokeballs", DrawBeltBalls)

net.Receive("GMonHPNet", function()
	local ent = net.ReadEntity()
	ent.HPRatio = net.ReadFloat()
end)

local function ClearItems()
	for k, ply in pairs(player.GetAll()) do
		local head = ply:LookupBone("ValveBiped.Bip01_Head1")
		local headPos, headAng = ply:GetBonePosition(head)
		if ply.PokeHat and ply.BeltBall then
			if (ply:Alive()) then
				ply.PokeHat:RemoveEffects(EF_NODRAW)
				ply.BeltBall:RemoveEffects(EF_NODRAW)
			else
				ply.PokeHat:AddEffects(EF_NODRAW)
				ply.BeltBall:AddEffects(EF_NODRAW)
			end
		end
	end
end
//hook.Add("Think", "ClearEquipmentPoke", ClearItems)
/*
local function UpdateGMonTable(data)
	local self = LocalPlayer()
	self.GMonTable = self.GMonTable or {}
	local index = data:ReadShort()
	self.GMonTable[index] = self.GMonTable[index] or {}
	self.GMonTable[index].Name = data:ReadString()
	self.GMonTable[index].Class = data:ReadString()
	self.GMonTable[index].HP 	= data:ReadShort()
	self.GMonTable[index].MaxHP = data:ReadShort()
	self.GMonTable[index].Skin 	= data:ReadShort()
	self.GMonTable[index].Mod 	= data:ReadString()
	self.GMonTable[index].Mat 	= data:ReadString()
end
usermessage.Hook("GMonCUp", UpdateGMonTable)
*/
end
//END CLIENT FUNCS//
