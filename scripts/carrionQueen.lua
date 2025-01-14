local mod = BetterMonsters


function mod:carrionQueenInit(entity)
	if entity.Variant == 2 and entity.I1 == 0 then
		entity.ProjectileCooldown = 30

		-- Nerf champion HP
		if entity.SubType == 1 then
			entity.MaxHitPoints = 525
			entity.HitPoints = entity.MaxHitPoints
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.carrionQueenInit, EntityType.ENTITY_CHUB)

function mod:carrionQueenUpdate(entity)
	if entity.Variant == 2 and entity.I1 == 0 then
		-- Charge diagonally
		if entity.State == NpcState.STATE_MOVE and ((entity.HitPoints > (entity.MaxHitPoints / 10) * 3) or entity.SubType == 1) then
			entity.StateFrame = 1
			
			if entity.ProjectileCooldown <= 0 then
				local target = entity:GetPlayerTarget()
				local angle = (target.Position - entity.Position):GetAngleDegrees()
				if angle < 0 then
					angle = angle + 360
				end
				
				for i = 0, 3 do
					local chargeAngle = 45 + (i * 90)

					if angle > (chargeAngle - 15) and angle < (chargeAngle + 15) and target.Position:Distance(entity.Position) <= 240
					and Game():GetRoom():CheckLine(target.Position, entity.Position, 0, 0, false, false) == true then
						entity.State = NpcState.STATE_ATTACK
						entity.V1 = Vector.FromAngle(chargeAngle)
						entity:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_0, 1, 0, false, 1)
						entity.ProjectileCooldown = 30
					end
				end
			
			else
				entity.ProjectileCooldown = entity.ProjectileCooldown - 1
			end
		
		
		-- Make the tail not glitch out when shitting
		elseif entity.State == NpcState.STATE_SUMMON then
			if entity.StateFrame == 0 then
				entity.Child.Child.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			elseif entity.StateFrame == 30 then
				entity.Child.Child.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.carrionQueenUpdate, EntityType.ENTITY_CHUB)

-- Make the pink champion be able to eat her own hearts
function mod:carrionQueenCollide(entity, target, bool)
	if entity.Variant == 2 and entity.SubType == 1 and entity:ToNPC().I1 == 0 and entity:ToNPC().State == NpcState.STATE_ATTACK and target.Type == EntityType.ENTITY_HEART then
		target:Kill()
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, mod.carrionQueenCollide, EntityType.ENTITY_CHUB)