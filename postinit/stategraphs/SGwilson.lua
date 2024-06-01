local AddStategraphState = AddStategraphState
local AddStategraphEvent = AddStategraphEvent
local AddStategraphActionHandler = AddStategraphActionHandler
local AddStategraphPostInit = AddStategraphPostInit
GLOBAL.setfenv(1, GLOBAL)

local DoFoleySounds = nil
local ClearStatusAilments = nil
local ForceStopHeavyLifting = nil
local StartTeleporting = nil
local ToggleOnPhysics = nil
local ToggleOffPhysics = nil
local DoneTeleporting = nil
local DoWortoxPortalTint = nil

local function OnExitRow(inst)
    local boat = inst.replica.sailor:GetBoat()
    if boat and boat.components.rowboatwakespawner then
        boat.components.rowboatwakespawner:StopSpawning()
    end
    if inst.sg.nextstate ~= "row" and inst.sg.nextstate ~= "sail" then
        inst.components.locomotor:Stop(nil, true)
        if inst.sg.nextstate ~= "row_stop" and inst.sg.nextstate ~= "sail_stop" then -- Make sure equipped items are pulled back out (only really for items with flames right now)
            local equipped = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then
                equipped:PushEvent("stoprowing", {owner = inst})
            end
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayIdleAnims()
            end
        end
    end
end

local function OnExitSail(inst)
    local boat = inst.replica.sailor:GetBoat()
    if boat and boat.components.rowboatwakespawner then
        boat.components.rowboatwakespawner:StopSpawning()
    end

    if inst.sg.nextstate ~= "sail" then
        inst.SoundEmitter:KillSound("sail_loop")
        if inst.sg.nextstate ~= "row" then
            inst.components.locomotor:Stop(nil, true)
        end
        if inst.sg.nextstate ~= "row_stop" and inst.sg.nextstate ~= "sail_stop" then
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayIdleAnims()
            end
        end
    end
end

local actionhandlers = {
    ActionHandler(ACTIONS.EMBARK, "embark"),
    ActionHandler(ACTIONS.DISEMBARK, "disembark"),
    ActionHandler(ACTIONS.RETRIEVE, "dolongaction"),
    ActionHandler(ACTIONS.TOGGLEON, "give"),
    ActionHandler(ACTIONS.TOGGLEOFF, "give"),
    ActionHandler(ACTIONS.REPAIRBOAT, "dolongaction"),
    ActionHandler(ACTIONS.HACK, function(inst)
        if inst:HasTag("beaver") then
            return not inst.sg:HasStateTag("gnawing") and "gnaw" or nil
        end
        return not inst.sg:HasStateTag("prehack") and (inst.sg:HasStateTag("hacking") and "hack" or "hack_start") or nil
    end),
    ActionHandler(ACTIONS.PAN, function(inst)
        if not inst.sg:HasStateTag("panning") then
            return "pan_start"
        end
    end),
    ActionHandler(ACTIONS.SHEAR, function(inst)
        if not inst.sg:HasStateTag("preshear") then
            if inst.sg:HasStateTag("shearing") then
                return "shear"
            else
                return "shear_start"
            end
        end
    end),
    ActionHandler(ACTIONS.CUREPOISON, function(inst, action)
        local target = action.target

        if not target or target == inst then
            return "curepoison"
        else
            return "give"
        end
    end),
}

local eventhandlers = {
    EventHandler("sailequipped", function(inst)
        if inst.sg:HasStateTag("rowing") then
            inst.sg:GoToState("sail")
            local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then
                equipped:PushEvent("stoprowing", {owner = inst})
            end
        end
    end),
    EventHandler("sailunequipped", function(inst)
        if inst.sg:HasStateTag("sailing") then
            inst.sg:GoToState("row")

            if not inst:HasTag("mime") then
                inst.AnimState:OverrideSymbol("paddle", "swap_paddle", "paddle")
            end
            -- TODO allow custom paddles?
            inst.AnimState:OverrideSymbol("wake_paddle", "swap_paddle", "wake_paddle")

            local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then
                equipped:PushEvent("startrowing", {owner = inst})
            end
        end
    end),
    EventHandler("sneeze", function(inst, data)
        if not inst.components.health:IsDead() and not inst.components.health:IsInvincible() then
            if inst.sg:HasStateTag("busy") then
                inst.sg.wantstosneeze = true
            else
                inst.sg:GoToState("sneeze")
            end
        end
    end),
}

local plant_symbols =
{
    "waterpuddle",
    "sparkle",
    "puddle",
    "plant",
    "lunar_mote3",
    "lunar_mote",
    "glow",
    "blink"
}

local states = {
    State{
        name = "mounted_poison_idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            if inst.components.poisonable and inst.components.poisonable:IsPoisoned() then
                inst.AnimState:PlayAnimation("idle_poison_pre")
                inst.AnimState:PushAnimation("idle_poison_loop")
                inst.AnimState:PushAnimation("idle_poison_pst", false)
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "hack_start",
        tags = {"prehack", "working"},

        onenter = function(inst)
            inst.components.locomotor:Stop()

            local buffaction = inst:GetBufferedAction()
            local tool = buffaction ~= nil and buffaction.invobject or nil
            local hacksymbols = tool ~= nil and tool.hack_overridesymbols or nil

            if hacksymbols ~= nil then
                hacksymbols[3] = tool:GetSkinBuild()
                if hacksymbols[3] ~= nil then
                    inst.AnimState:OverrideItemSkinSymbol("swap_machete", hacksymbols[3], hacksymbols[1], tool.GUID, hacksymbols[2])
                else
                    inst.AnimState:OverrideSymbol("swap_machete", hacksymbols[1], hacksymbols[2])
                end
                inst.AnimState:PlayAnimation("hack_pre")
            else
                inst.AnimState:PlayAnimation("chop_pre")
            end

        end,

        events = {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("hack")
                end
            end),
        },
    },

    State{
        name = "hack",
        tags = {"prehack", "hacking", "working"},

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            local tool = inst.sg.statemem.action ~= nil and inst.sg.statemem.action.invobject or nil
            local hacksymbols = tool ~= nil and tool.hack_overridesymbols or nil

            -- Note this is used to make sure the tool symbol is still the machete even when inventory hacking
            if hacksymbols ~= nil then
                -- This code only needs to run when hacking a coconut but im running it regardless to prevent hiding issues
                hacksymbols[3] = tool:GetSkinBuild()
                if hacksymbols[3] ~= nil then
                    inst.AnimState:OverrideItemSkinSymbol("swap_machete", hacksymbols[3], hacksymbols[1], tool.GUID, hacksymbols[2])
                else
                    inst.AnimState:OverrideSymbol("swap_machete", hacksymbols[1], hacksymbols[2])
                end
                inst.AnimState:PlayAnimation("hack_loop")
            else
                inst.AnimState:PlayAnimation("chop_loop")
            end
        end,

        timeline = {
            TimeEvent(2 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),


            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("prehack")
            end),

            TimeEvent(14 * FRAMES, function(inst)
                if inst.components.playercontroller ~= nil and
                inst.components.playercontroller:IsAnyOfControlsPressed(
                CONTROL_PRIMARY, CONTROL_ACTION, CONTROL_CONTROLLER_ACTION) and
                inst.sg.statemem.action ~= nil and
                inst.sg.statemem.action:IsValid() and
                inst.sg.statemem.action.target ~= nil and
                inst.sg.statemem.action.target.components.hackable ~= nil and
                inst.sg.statemem.action.target.components.hackable:CanBeHacked() and
                inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and
                CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),

            TimeEvent(16 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("hacking")
            end),
        },

        events = {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "pan_start",
        tags = {"prepan", "working"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pan_pre")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.panning = true
                    inst.sg:GoToState("pan")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.panning then
                inst:RemoveTag("prepan")
            end
        end,
    },

    State{
        name = "pan",
        tags = {"prepan", "panning", "working"},

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("pan_loop", true)
            inst.sg:SetTimeout(1 + math.random())
        end,

        timeline=
        {
            TimeEvent(6 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/pool/pan") end),
            TimeEvent(14 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/pool/pan") end),
            TimeEvent(21 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/pool/pan") end),
            TimeEvent(29 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/pool/pan") end),
            TimeEvent(36 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/pool/pan") end),
            TimeEvent(44 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/pool/pan") end),
            TimeEvent(51 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/pool/pan") end),
            TimeEvent(59 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/pool/pan") end),
            TimeEvent(66 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/pool/pan") end),
            TimeEvent(74 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/pool/pan") end),
        },

        ontimeout = function(inst)
            inst:PerformBufferedAction()
            inst.AnimState:PlayAnimation("pan_pst")
            inst.sg:GoToState("idle", true)
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "shear_start",
        tags = {"preshear", "working"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("cut_pre")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("shear")
                end
            end),
        },
    },

    State{
        name = "shear",
        tags = {"preshear", "shearing", "working"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("cut_loop")
            inst.sg.statemem.action = inst:GetBufferedAction()
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/grass_tall/shears")
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("preshear")
            end),

            TimeEvent(14 * FRAMES, function(inst)
                if inst.components.playercontroller ~= nil
                    and inst.components.playercontroller:IsAnyOfControlsPressed(CONTROL_PRIMARY, CONTROL_ACTION, CONTROL_CONTROLLER_ACTION) and
                    inst.sg.statemem.action and
                    inst.sg.statemem.action:IsValid() and
                    inst.sg.statemem.action.target and
                    inst.sg.statemem.action.target.components.shearable and
                    inst.sg.statemem.action.target.components.shearable:CanShear() and
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and
                    CanEntitySeeTarget(inst, inst.sg.statemem.action.target)
                then
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),

            TimeEvent(16 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("shearing")
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("cut_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },
    },

    State{
        name = "sneeze",
        tags = {"busy", "sneeze", "nopredict"},

        onenter = function(inst)
            if inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown() then
                inst.sg:GoToState("sink_boat")
                return
            end

            inst.sg.wantstosneeze = false
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit", nil, .02)
            inst.AnimState:PlayAnimation("sneeze")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/sneeze")
            inst:ClearBufferedAction()

            if not inst:HasTag("mime") then
                local sound_name = inst.soundsname or inst.prefab
                local path = inst.talker_path_override or "dontstarve/characters/"

                local sound_event = path .. sound_name .. "/hurt"
                inst.SoundEmitter:PlaySound(inst.hurtsoundoverride or sound_event)
            end

            inst.components.talker:Say(GetString(inst, "ANNOUNCE_SNEEZE"))
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                if inst.components.hayfever then
                    inst.components.hayfever:DoSneezeEffects()
                end
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "rebirth_floweroflife",
        tags = {"nopredict", "silentmorph"},

        onenter = function(inst, source)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.AnimState:PlayAnimation("rebirth2")

            local skin_build = source and source:GetSkinBuild() or nil
            if skin_build ~= nil then
                for k,v in pairs(plant_symbols) do
                    inst.AnimState:OverrideItemSkinSymbol(v, skin_build, v, inst.GUID, "lifeplant")
                end
            else
                for k,v in pairs(plant_symbols) do
                    inst.AnimState:OverrideSymbol(v, "lifeplant", v)
                end
            end

            inst.components.health:SetInvincible(true)
            inst:ShowHUD(false)
            inst:SetCameraDistance(12) -- TODO: Do not set to 12 if interior
        end,

        timeline =
        {
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            for k, v in pairs(plant_symbols) do
                inst.AnimState:ClearOverrideSymbol(v)
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end

            inst.components.health:SetInvincible(false)
            inst:ShowHUD(true)
            inst:SetCameraDistance()

            SerializeUserSession(inst)
        end,
    },

    State{
        name = "castspell_bone",
        tags = {"doing", "busy", "canrotate", "spell"},

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.AnimState:PlayAnimation("staff_pre")
            inst.AnimState:PushAnimation("staff", false)
            inst.components.locomotor:Stop()

            --Spawn an effect on the player's location
            local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local colour = staff and staff.fxcolour or {1, 1, 1}

            inst.sg.statemem.stafffx = SpawnPrefab(inst.components.rider:IsRiding() and "staffcastfx_mount" or "staffcastfx")
            inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
            inst.sg.statemem.stafffx:SetUp(colour)

            inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
            inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.sg.statemem.stafflight:SetUp(colour, 1.9, 0.33)

            inst.sg.statemem.castsound = (staff and staff.skin_castsound or staff.castsound) or "dontstarve/wilson/use_gemstaff"
        end,

        onexit = function(inst)
            if inst.components.playercontroller then
                inst.components.playercontroller:Enable(true)
            end
            if inst.sg.statemem.stafffx and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_gemstaff")
                inst:PerformBufferedAction()
            end),
            TimeEvent(60 * FRAMES, function(inst)
                local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if staff and staff.endcast then
                    staff.endcast(staff)
                end

                inst.sg:RemoveStateTag("busy")
                         if inst.components.playercontroller ~= nil then
                              inst.components.playercontroller:Enable(true)
                        end
            end),
        },

        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "embark",
        tags = {"canrotate", "boating", "busy", "nomorph", "nopredict"},
        onenter = function(inst)
            local action = inst:GetBufferedAction()
            if action.target and action.target.components.sailable and not action.target.components.sailable:IsOccupied() then
                if inst.components.sailor and inst.components.sailor:IsSailing() then
                    inst.components.sailor:Disembark(nil, true)
                else
                    inst.sg:GoToState("jumponboatstart")
                end
            else
                inst.sg:GoToState("idle")
                inst:PushEvent("actionfailed", { action = action, reason = "INUSE" })
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "disembark",
        tags = {"canrotate", "boating", "busy", "nomorph", "nopredict"},
        onenter = function(inst)
            inst:PerformBufferedAction()
        end,
    },

    State{
        name = "jumponboatstart",
        tags = { "doing", "nointerrupt", "canrotate", "busy", "nomorph", "nopredict"},
        onenter = function(inst)
            if inst.Physics.ClearCollidesWith then
                inst.Physics:ClearCollidesWith(COLLISION.LIMITS) -- R08_ROT_TURNOFTIDES
            end
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("jumpboat")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_whoosh")

            inst.sg.statemem.startpos = inst:GetPosition()
            local action = inst:GetBufferedAction()
            if action ~= nil then
                inst.sg.statemem.targetpos = action.target and action.target:GetPosition()
                inst.sg.statemem.boattarget = action.target
                action.target.components.sailable.isembarking = true
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        onexit = function(inst)
            if inst.sg.statemem.boattarget ~= nil then
                inst.sg.statemem.boattarget.components.sailable.isembarking = false
            end

            if inst.Physics.ClearCollidesWith then
                inst.Physics:CollidesWith(COLLISION.LIMITS) -- R08_ROT_TURNOFTIDES
            end

            inst.components.locomotor:Stop()

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
                local dist = inst:GetPosition():Dist(inst.sg.statemem.targetpos)
                local speed = dist / (18 / 30)
                inst.Physics:SetMotorVelOverride(speed, 0, 0)
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end

                inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
                inst.Physics:Stop()

                inst.components.locomotor:Stop()
                local embark_succeeded = inst:PerformBufferedAction()
                if not embark_succeeded then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "jumpboatland",
        tags = { "doing", "nointerrupt", "busy", "canrotate", "invisible", "nomorph", "nopredict"},

        onenter = function(inst, pos)
            if inst.Physics.ClearCollidesWith then
                inst.Physics:CollidesWith(COLLISION.LIMITS) -- R08_ROT_TURNOFTIDES
            end

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("landboat")
            local boat = inst.components.sailor.boat
            if boat and boat.landsound then
                inst.SoundEmitter:PlaySound(boat.landsound)
            end
        end,

        onexit = function(inst)
            if inst.components.drydrownable ~= nil and inst.components.drydrownable:ShouldDrown() then
                inst:PushEvent("onhitcoastline")
            end
        end,

        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "jumpoffboatstart",
        tags = {"doing", "nointerrupt", "busy", "canrotate", "nomorph", "nopredict"},

        onenter = function(inst, pos)
            if inst.Physics.ClearCollidesWith then
                inst.Physics:ClearCollidesWith(COLLISION.LIMITS) -- R08_ROT_TURNOFTIDES
            end
            inst.components.locomotor:StopMoving()
            -- inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.AnimState:PlayAnimation("jumpboat")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_whoosh")

            inst.sg.statemem.startpos = inst:GetPosition()
            inst.sg.statemem.targetpos = pos

            inst:PushEvent("ms_closepopups")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        onexit = function(inst)
            -- This shouldn"t actually be reached
            if inst.Physics.ClearCollidesWith then
                inst.Physics:CollidesWith(COLLISION.LIMITS) -- R08_ROT_TURNOFTIDES
            end
            inst.components.locomotor:Stop()
            -- inst.components.locomotor:EnableGroundSpeedMultiplier(true)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,

        timeline = {
            -- Make the action cancel-able until this?
            TimeEvent(7 * FRAMES, function(inst)
                inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
                local dist = inst:GetPosition():Dist(inst.sg.statemem.targetpos)
                local speed = dist / (18 / 30)
                inst.Physics:SetMotorVelOverride(speed, 0, 0)
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
                    inst.sg:GoToState("jumpoffboatland")
                end
            end),
        },
    },

    State{
        name = "jumpoffboatland",
        tags = {"doing", "nointerrupt", "busy", "canrotate", "nomorph", "nopredict"},

        onenter = function(inst, pos)
            if inst.Physics.ClearCollidesWith then
                inst.Physics:CollidesWith(COLLISION.LIMITS) -- R08_ROT_TURNOFTIDES
            end
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("land", false)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_to_land")
            PlayFootstep(inst)
        end,

        events = {
            EventHandler("animqueueover", function(inst)
                inst:PerformBufferedAction()
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "curepoison",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("quick_eat")
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/player_drink")
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("celebrate") end),
        },
    },

    State{
        name = "celebrate",
        tags = {"idle"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("research")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/antivenom_whoosh") end),
            TimeEvent(13 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/heelclick") end),
            TimeEvent(21 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/heelclick") end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "row_start",
        tags = {"moving", "running", "rowing", "boating", "canrotate", "autopredict" },

        onenter = function(inst)
            local boat = inst.replica.sailor:GetBoat()

            inst.components.locomotor:RunForward()

            if not inst:HasTag("mime") then
                inst.AnimState:OverrideSymbol("paddle", "swap_paddle", "paddle")
            end
            -- TODO allow custom paddles?
            inst.AnimState:OverrideSymbol("wake_paddle", "swap_paddle", "wake_paddle")

            -- RoT has row_pre, which is identical but uses the equipped item as paddle

            local oar = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation(oar and oar:HasTag("oar") and "row_pre" or "row_pre_pl")
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayPreRowAnims()
            end

            DoFoleySounds(inst)

            local equipped = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then
                equipped:PushEvent("startrowing", {owner = inst})
            end
            inst:PushEvent("startrowing")
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        onexit = OnExitRow,

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("row")
                end
            end),
        },
    },

    State{
        name = "row",
        tags = {"moving", "running", "rowing", "boating", "canrotate", "autopredict" },

        onenter = function(inst)
            local boat = inst.replica.sailor:GetBoat()

            if boat and boat.replica.sailable and boat.replica.sailable.creaksound then
                inst.SoundEmitter:PlaySound(boat.replica.sailable.creaksound, nil, nil, true)
            end
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boat/paddle", nil, nil, true)
            DoFoleySounds(inst)

            local oar = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            local anim = oar and oar:HasTag("oar") and "row_medium" or "row_loop"
            if not inst.AnimState:IsCurrentAnimation(anim) then
                -- RoT has row_medium, which is identical but uses the equipped item as paddle
                inst.AnimState:PlayAnimation(anim, true)
            end
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayRowAnims()
            end

            if boat and boat.components.rowboatwakespawner then
                boat.components.rowboatwakespawner:StartSpawning()
            end

            -- if inst.components.mapwrapper
            -- and inst.components.mapwrapper._state > 1
            -- and inst.components.mapwrapper._state < 5 then
            --     inst.sg:AddStateTag("nomorph")
            --     -- TODO pause predict?
            -- end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        onexit = OnExitRow,

        timeline = {
            TimeEvent(8 * FRAMES, function(inst)
                local boat = inst.replica.sailor:GetBoat()
                if boat and boat.replica.container then
                    local trawlnet = boat.replica.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
                    if trawlnet and trawlnet.rowsound then
                        inst.SoundEmitter:PlaySound(trawlnet.rowsound, nil, nil, true)
                    end
                end
            end),
        },

        events = {
            EventHandler("trawlitem", function(inst)
                local boat = inst.replica.sailor:GetBoat()
                if boat and boat.replica.sailable then
                    boat.replica.sailable:PlayTrawlOverAnims()
                end
            end),
        },

        ontimeout = function(inst) inst.sg:GoToState("row") end,
    },

    State{
        name = "row_stop",
        tags = {"canrotate", "idle", "autopredict"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            local boat = inst.replica.sailor:GetBoat()
            local oar = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation(oar and oar:HasTag("oar") and "row_idle_pst" or "row_pst")
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayPostRowAnims()
            end
        end,

        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    local equipped = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if equipped then
                        equipped:PushEvent("stoprowing", {owner = inst})
                    end
                    inst:PushEvent("stoprowing")
                    -- If the player had something in their hand before starting to row, put it back.
                    if equipped and not equipped:HasTag("oar") then
                        inst.sg:GoToState("item_out")
                        return
                    end
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "sail_start",
        tags = {"moving", "running", "canrotate", "boating", "sailing", "autopredict"},

        onenter = function(inst)
            local boat = inst.replica.sailor:GetBoat()

            inst.components.locomotor:RunForward()

            local anim = boat.replica.sailable.sailstartanim or "sail_pre"
            if anim ~= "sail_pre" or inst.has_sailface then
                inst.AnimState:PlayAnimation(anim)
            else
                inst.AnimState:PlayAnimation("sail_pre")
            end
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayPreSailAnims()
            end

            local equipped = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then
                equipped:PushEvent("startsailing", {owner = inst})
            end
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        onexit = OnExitSail,

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("sail")
                end
            end),
        },
    },

    State{
        name = "sail",
        tags = {"canrotate", "moving", "running", "boating", "sailing", "autopredict"},

        onenter = function(inst)
            local boat = inst.replica.sailor:GetBoat()

            local loopsound = nil
            local flapsound = nil

            if boat and boat.replica.container and boat.replica.container.hasboatequipslots then
                local sail = boat.replica.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
                if sail then
                    loopsound = sail.loopsound
                    flapsound = sail.flapsound
                end
            elseif boat and boat.replica.sailable and boat.replica.sailable.sailsound then
                loopsound = boat.replica.sailable.sailsound
            end

            if not inst.SoundEmitter:PlayingSound("sail_loop") and loopsound then
                inst.SoundEmitter:PlaySound(loopsound, "sail_loop", nil, true)
            end

            if flapsound then
                inst.SoundEmitter:PlaySound(flapsound, nil, nil, true)
            end

            if boat and boat.replica.sailable and boat.replica.sailable.creaksound then
                inst.SoundEmitter:PlaySound(boat.replica.sailable.creaksound, nil, nil, true)
            end

            local anim =boat and boat.replica.sailable and boat.replica.sailable.sailloopanim or "sail_loop"
            if not inst.AnimState:IsCurrentAnimation(anim) then
                if anim ~= "sail_loop" or inst.has_sailface then
                    inst.AnimState:PlayAnimation(anim , true)
                else
                    inst.AnimState:PlayAnimation("sail_loop", true)
                end
            end
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlaySailAnims()
            end

            if boat and boat.components.rowboatwakespawner then
                boat.components.rowboatwakespawner:StartSpawning()
            end

            -- if inst.components.mapwrapper
            -- and inst.components.mapwrapper._state > 1
            -- and inst.components.mapwrapper._state < 5 then
            --     inst.sg:AddStateTag("nomorph")
            --     -- TODO pause predict?
            -- end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        onexit = OnExitSail,

        events = {
            -- EventHandler("animover", function(inst) inst.sg:GoToState("sail") end ),
            EventHandler("trawlitem", function(inst)
                local boat = inst.replica.sailor:GetBoat()
                if boat and boat.replica.sailable then
                    boat.replica.sailable:PlayTrawlOverAnims()
                end
            end),
        },

        ontimeout = function(inst) inst.sg:GoToState("sail") end,
    },

    State{
        name = "sail_stop",
        tags = {"canrotate", "idle", "autopredict"},

        onenter = function(inst)
            local boat = inst.replica.sailor:GetBoat()

            inst.components.locomotor:Stop()
            local anim = boat.replica.sailable.postsailanim or "sail_pst"
            if anim ~= "sail_pst" or inst.has_sailface then
                inst.AnimState:PlayAnimation(anim)
            else
                inst.AnimState:PlayAnimation("sail_pst")
            end
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayPostSailAnims()
            end
        end,

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local equipped = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if equipped then
                        equipped:PushEvent("stopsailing", {owner = inst})
                    end
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "sink_boat",
        tags = {"busy", "nopredict", "nomorph", "drowning", "nointerrupt", "noattack"},

        onenter = function(inst, shore_pt)
            ForceStopHeavyLifting(inst)
            inst:ClearBufferedAction()

            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

            inst.AnimState:Hide("swap_arm_carry")
            inst.AnimState:PlayAnimation("boat_death")

            if inst:HasTag("beaver") then
                inst.AnimState:SetBuild("werebeaver_boat_death")
                inst.AnimState:SetBankAndPlayAnimation("werebeaver_boat_death", "boat_death")
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/woodie/sinking_death_werebeaver")
            else
                inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/sinking")
            end

            if inst:HasTag("weremoose") then
                inst.AnimState:PlayAnimation("sink")
                inst.AnimState:Hide("plank")
                inst.AnimState:Hide("float_front")
                inst.AnimState:Hide("float_back")
            end

            if inst.components.rider:IsRiding() then
                inst.sg:AddStateTag("dismounting")
            end

            if shore_pt ~= nil then
                inst.components.drownable:OnFallInOcean(shore_pt:Get())
            else
                inst.components.drownable:OnFallInOcean()
            end

            inst.components.drownable:DropInventory()

            inst.sg:SetTimeout(3.3)  -- just in case
        end,

        timeline = {
            TimeEvent(14 * FRAMES, function(inst)
                if inst:HasTag("weremoose") then
                    inst.AnimState:Show("float_front")
                    inst.AnimState:Show("float_back")
                end
            end),
            TimeEvent(50 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/boat/sinking/shadow")
            end),
            TimeEvent(70 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
                inst:ShowHUD(false)
            end),
        },

        ontimeout = function(inst)  -- failsafe
            -- if inst.components.drownable:GetRescueData() ~= nil then
            --     -- copy from animover
            --     if inst:HasTag("beaver") then
            --         inst.AnimState:SetBank("werebeaver")
            --         if inst.components.skinner then
            --             inst.components.skinner:SetSkinMode("werebeaver_skin")
            --         else
            --             inst.AnimState:SetBuild("werebeaver")
            --         end
            --     end
            -- end
            StartTeleporting(inst)

            if inst.sg:HasStateTag("dismounting") then
                inst.sg:RemoveStateTag("dismounting")

                local mount = inst.components.rider:GetMount()
                inst.components.rider:ActualDismount()
                if mount ~= nil then
                    if mount.components.drownable ~= nil then
                        mount:Hide()
                        mount:PushEvent("onsink", {noanim = true, shore_pt = Vector3(inst.components.drownable.dest_x, inst.components.drownable.dest_y, inst.components.drownable.dest_z)})
                    elseif mount.components.health ~= nil then
                        mount:Hide()
                        mount.components.health:Kill()
                    end
                end
            end

            if inst.components.health and not inst.components.health:IsDead() then
                inst.components.drownable:_WashAshore()
            end
        end,

        events = {
            EventHandler("animover", function(inst)
                -- if inst.components.drownable:GetRescueData() ~= nil then
                --     -- copy from animover
                --     if inst:HasTag("beaver") then
                --         inst.AnimState:SetBank("werebeaver")
                --         if inst.components.skinner then
                --             inst.components.skinner:SetSkinMode("werebeaver_skin")
                --         else
                --             inst.AnimState:SetBuild("werebeaver")
                --         end
                --     end
                -- end
                StartTeleporting(inst)

                if inst.sg:HasStateTag("dismounting") then
                    inst.sg:RemoveStateTag("dismounting")

                    local mount = inst.components.rider:GetMount()
                    inst.components.rider:ActualDismount()
                    if mount ~= nil then
                        if mount.components.drownable ~= nil then
                            mount:Hide()
                            mount:PushEvent("onsink", {noanim = true, shore_pt = Vector3(inst.components.drownable.dest_x, inst.components.drownable.dest_y, inst.components.drownable.dest_z)})
                        elseif mount.components.health ~= nil then
                            mount:Hide()
                            mount.components.health:Kill()
                        end
                    end
                end

                inst.components.drownable:WashAshore()
            end),

            EventHandler("on_washed_ashore", function(inst)
                -- Congrats you LIVE!
                inst.sg:GoToState("washed_ashore")
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end

            if inst.sg.statemem.isteleporting then
                DoneTeleporting(inst)
            end

            inst.DynamicShadow:Enable(true)
            inst:ShowHUD(true)
        end,
    },

    State{
        name = "death_drown",
        tags = {"busy", "dead", "canrotate", "nopredict", "nomorph", "drowning", "nointerrupt"},

        onenter = function(inst, data)
            assert(inst.deathcause ~= nil, "Entered death state without cause.")

            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)

            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst:ClearBufferedAction()

            inst.components.burnable:Extinguish()

            if HUMAN_MEAT_ENABLED then
                inst.components.inventory:GiveItem(SpawnPrefab("humanmeat")) -- Drop some player meat!
            end

            inst.components.inventory:DropEverything(true)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
                inst.components.playercontroller:Enable(false)
            end

            if inst.ghostenabled then
                inst.components.cursable:Died()
                if inst:HasTag("wonkey") then
                    inst:ChangeFromMonkey()
                else
                    inst:PushEvent("makeplayerghost", { skeleton = TheWorld.Map:IsPassableAtPoint(inst.Transform:GetWorldPosition()) }) -- if we are not on valid ground then don't drop a skeleton
                end
            else
                inst.AnimState:SetPercent(inst.deathanimoverride or "death", 1)
                inst:PushEvent("playerdied", { skeleton = false })
            end
        end,
    },

    State{
        name = "portal_jumpin_boat",
        tags = { "busy", "pausepredict", "nodangle", "nomorph" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wortox_portal_jumpin")
            local x, y, z = inst.Transform:GetWorldPosition()
            SpawnPrefab("wortox_portal_jumpin_fx").Transform:SetPosition(x, y, z)
            inst.sg:SetTimeout(11 * FRAMES)
            inst.sg.statemem.from_map = data and data.from_map or nil
            local dest_target = data and data.dest_target or nil
            if dest_target ~= nil then
                inst.sg.statemem.dest_target = dest_target
                inst.sg.statemem.dest_pos = dest_target:GetPosition()
                inst:ForceFacePoint(dest_target.Transform:GetWorldPosition())
                dest_target.components.sailable.isembarking = true
            else
                inst.sg.statemem.dest_target = nil
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end

            if inst.components.sailor and inst.components.sailor:IsSailing() then
                inst.components.sailor:Disembark(nil, nil, true)
            end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.tints ~= nil then
                DoWortoxPortalTint(inst, table.remove(inst.sg.statemem.tints))
                if #inst.sg.statemem.tints <= 0 then
                    inst.sg.statemem.tints = nil
                end
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_post", nil, .7)
                inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.sg.statemem.tints = { 1, .6, .3, .1 }
                PlayFootstep(inst)
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:AddStateTag("noattack")
                inst.components.health:SetInvincible(true)
                inst.DynamicShadow:Enable(false)
            end),
        },

        ontimeout = function(inst)
            inst.sg.statemem.portaljumping = true
            inst.sg:GoToState("portal_jumpout_boat", {dest_target = inst.sg.statemem.dest_target, dest_pos = inst.sg.statemem.dest_pos, from_map = inst.sg.statemem.from_map})
        end,

        onexit = function(inst)
            inst.sg.statemem.dest_target.components.sailable.isembarking = false
            if not inst.sg.statemem.portaljumping then
                inst.components.health:SetInvincible(false)
                inst.DynamicShadow:Enable(true)
                DoWortoxPortalTint(inst, 0)
            end
        end,
    },

    State{
        name = "portal_jumpout_boat",
        tags = { "busy", "nopredict", "nomorph", "noattack", "nointerrupt" },

        onenter = function(inst, data)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wortox_portal_jumpout")
            inst:ResetMinimapOffset()
            if data and data.from_map then
                inst:SnapCamera()
            end
            local dest_target = data and data.dest_target or nil
            if dest_target ~= nil then
                inst.Physics:Teleport(dest_target.Transform:GetWorldPosition())
                if dest_target and dest_target.components.sailable and dest_target.components.sailable.sailor == nil then
                    inst.components.sailor:Embark(dest_target, true)
                end
            else
                inst.Physics:Teleport(dest_pos:Get())
            end
            SpawnPrefab("wortox_portal_jumpout_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.DynamicShadow:Enable(false)
            inst.sg:SetTimeout(14 * FRAMES)
            DoWortoxPortalTint(inst, 1)
            inst.components.health:SetInvincible(true)
            inst:PushEvent("soulhop")
        end,

        onupdate = function(inst)
            if inst.sg.statemem.tints ~= nil then
                DoWortoxPortalTint(inst, table.remove(inst.sg.statemem.tints))
                if #inst.sg.statemem.tints <= 0 then
                    inst.sg.statemem.tints = nil
                end
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/hop_out") end),
            TimeEvent(5 * FRAMES, function(inst)
                inst.sg.statemem.tints = { 0, .4, .7, .9 }
            end),
            TimeEvent(7 * FRAMES, function(inst)
                inst.components.health:SetInvincible(false)
                inst.sg:RemoveStateTag("noattack")
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
            TimeEvent(8 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
                ToggleOnPhysics(inst)
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst.DynamicShadow:Enable(true)
            DoWortoxPortalTint(inst, 0)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
        end,
    },
}

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson", actionhandler)
end

for _, eventhandler in ipairs(eventhandlers) do
    AddStategraphEvent("wilson", eventhandler)
end

for _, state in ipairs(states) do
    AddStategraphState("wilson", state)
end

AddStategraphPostInit("wilson", function(sg)
    local _run_start_timeevent_2 = sg.states["run_start"].timeline[2].fn
    DoFoleySounds = ToolUtil.GetUpvalue(_run_start_timeevent_2, "DoFoleySounds")

    local _electrocute_onenter = sg.states["electrocute"].onenter
    ClearStatusAilments = ToolUtil.GetUpvalue(_electrocute_onenter, "ClearStatusAilments")
    ForceStopHeavyLifting = ToolUtil.GetUpvalue(_electrocute_onenter, "ForceStopHeavyLifting")

    local _jumpin_onexit = sg.states["jumpin"].onexit
    ToggleOnPhysics = ToolUtil.GetUpvalue(_jumpin_onexit, "ToggleOnPhysics")

    local _jumpin_onenter = sg.states["jumpin"].onenter
    ToggleOffPhysics = ToolUtil.GetUpvalue(_jumpin_onenter, "ToggleOffPhysics")

    local _abandon_ship_onexit = sg.states["abandon_ship"].onexit
    DoneTeleporting = ToolUtil.GetUpvalue(_abandon_ship_onexit, "DoneTeleporting")

    local _abandon_ship_events_animover = sg.states["abandon_ship"].events.animover.fn
    StartTeleporting = ToolUtil.GetUpvalue(_abandon_ship_events_animover, "StartTeleporting")

    local _portal_jumpin_onupdate = sg.states["portal_jumpin"].onupdate
    DoWortoxPortalTint = ToolUtil.GetUpvalue(_portal_jumpin_onupdate, "DoWortoxPortalTint")

    local _attack_deststate = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, ...)
        if not inst.sg:HasStateTag("sneeze") then
            return _attack_deststate and _attack_deststate(inst, ...)
        end
    end

    local _attacked_eventhandler = sg.events.attacked.fn
    sg.events.attacked.fn = function(inst, data)
        if inst.components.sailor and inst.components.sailor:IsSailing() then
            local boat = inst.components.sailor:GetBoat()
            if not inst.components.health:IsDead() and not (boat and boat.components.boathealth and boat.components.boathealth:IsDead()) then

                if not boat.components.sailable or not boat.components.sailable:CanDoHit() then
                    return
                end

                if data.attacker and (data.attacker:HasTag("insect"))then
                    local is_idle = inst.sg:HasStateTag("idle")
                    if not is_idle then
                        return
                    end
                end

                boat.components.sailable:GetHit()

                _attacked_eventhandler(inst, data)
            end
        else
            _attacked_eventhandler(inst, data)
        end
    end

    sg.events["boatattacked"] = EventHandler("boatattacked", sg.events.attacked.fn)

    -- Disembark properly and drop no skeleton
    local _death_animover = sg.states["death"].events.animover.fn
    sg.states["death"].events.animover.fn = function(inst, ...)
        local x, y, z = inst.Transform:GetWorldPosition()
        if inst.AnimState:AnimDone() and not inst.sg:HasStateTag("dismounting") and TheWorld.Map:ReverseIsVisualWaterAtPoint(x, y, z) then
            if inst.components.sailor and inst.components.sailor:IsSailing() then
                inst.components.sailor:Disembark()
            end
            inst:PushEvent(inst.ghostenabled and "makeplayerghost" or "playerdied", {skeleton = false})
        else
            _death_animover(inst, ...)
        end
    end

    local _idle_onenter = sg.states["idle"].onenter
    sg.states["idle"].onenter = function(inst, ...)
        if not (inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown()) then
            if inst.sg.wantstosneeze then
                inst.components.locomotor:Stop()
                inst.components.locomotor:Clear()

                inst.sg:GoToState("sneeze")
                return
            end
        end

        if _idle_onenter ~= nil then
            return _idle_onenter(inst, ...)
        end
    end

    local _mounted_idle_onenter = sg.states["mounted_idle"].onenter
    sg.states["mounted_idle"].onenter = function(inst, ...)
        if inst.sg.wantstosneeze then
            inst.sg:GoToState("sneeze")
            return
        end

        local equippedArmor = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
        if (equippedArmor ~= nil and equippedArmor:HasTag("band")) or
            not (inst.components.poisonable and inst.components.poisonable:IsPoisoned()) then
            if _mounted_idle_onenter ~= nil then
                return _mounted_idle_onenter(inst, ...)
            end
        else
            inst.sg:GoToState("mounted_poison_idle")
        end
    end

    local _funnyidle_onenter = sg.states["funnyidle"].onenter
    sg.states["funnyidle"].onenter = function(inst, ...)
        if inst.components.poisonable and inst.components.poisonable:IsPoisoned() then
            inst.AnimState:PlayAnimation("idle_poison_pre")
            inst.AnimState:PushAnimation("idle_poison_loop")
            inst.AnimState:PushAnimation("idle_poison_pst", false)
        elseif _funnyidle_onenter then
            _funnyidle_onenter(inst, ...)
        end
    end

    local _portal_jumpin_onenter = sg.states["portal_jumpin"].onenter
    sg.states["portal_jumpin"].onenter = function(inst, ...)
        _portal_jumpin_onenter(inst, ...)
        if inst.components.sailor and inst.components.sailor:IsSailing() then
            inst.components.sailor:Disembark(nil, nil, true)
        end
    end

    local _transform_werebeaver_exit = sg.states["transform_werebeaver"].onexit
    sg.states["transform_werebeaver"].onexit = function(inst, ...)
        if not inst.sg:HasStateTag("transform") and inst.components.sailor and inst.components.sailor:IsSailing() then

            -- this will cause the boat to "drown" the player and handle the rest of the code.
            inst.components.sailor.boat.components.boathealth:MakeEmpty()
        end
        return _transform_werebeaver_exit(inst, ...)
    end
    local _transform_weremoose_exit = sg.states["transform_weremoose"].onexit
    sg.states["transform_weremoose"].onexit = function(inst, ...)
        if not inst.sg:HasStateTag("transform") and inst.components.sailor and inst.components.sailor:IsSailing() then

            -- this will cause the boat to "drown" the player and handle the rest of the code.
            inst.components.sailor.boat.components.boathealth:MakeEmpty()
        end
        return _transform_weremoose_exit(inst, ...)
    end
    local _transform_weregoose_exit = sg.states["transform_weregoose"].onexit
    sg.states["transform_weregoose"].onexit = function(inst, ...)
        -- if inst.sg:HasStateTag("drowning") then return end -- simple hack to prevent looping
        if not inst.sg:HasStateTag("transform") and inst.components.sailor and inst.components.sailor:IsSailing() then
            -- inst.sg:AddStateTag("drowning") -- goose does not drown
            inst.components.sailor:Disembark(nil, nil, true)
        end
        return _transform_weregoose_exit(inst, ...)
    end

    local _locomote_eventhandler = sg.events.locomote.fn
    sg.events.locomote.fn = function(inst, data, ...)
        local is_attacking = inst.sg:HasStateTag("attack")

        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        local should_move = inst.components.locomotor:WantsToMoveForward()
        if inst.components.sailor and inst.components.sailor.boat and not inst.components.sailor.boat.components.sailable then
            should_move = false
        end

        local should_run = inst.components.locomotor:WantsToRun()
        local hasSail = inst.replica.sailor and inst.replica.sailor:GetBoat() and inst.replica.sailor:GetBoat().replica.sailable:GetIsSailEquipped() or false
        if not should_move then
            if inst.components.sailor and inst.components.sailor.boat then
                inst.components.sailor.boat:PushEvent("boatstopmoving")
            end
        end
        if should_move then
            if inst.components.sailor and inst.components.sailor.boat then
                inst.components.sailor.boat:PushEvent("boatstartmoving")
            end
        end

        if inst.sg:HasStateTag("busy") or inst:HasTag("busy") or inst.sg:HasStateTag("overridelocomote") then
            return _locomote_eventhandler(inst, data, ...)
        end
        if inst.components.sailor and inst.components.sailor:IsSailing() then
            if not is_attacking then
                if is_moving and not should_move then
                    if hasSail then
                        inst.sg:GoToState("sail_stop")
                    else
                        inst.sg:GoToState("row_stop")
                    end
                elseif not is_moving and should_move or (is_moving and should_move and is_running ~= should_run) then
                    if hasSail then
                        inst.sg:GoToState("sail_start")
                    else
                        inst.sg:GoToState("row_start")
                    end
                end
            end
            return
        end

        return _locomote_eventhandler(inst, data, ...)
    end

    local _onsink_eventhandler = sg.events.onsink.fn
    sg.events.onsink.fn = function(inst, data, ...)
        if data and data.pl_boat and not inst.components.health:IsDead() and not inst.sg:HasStateTag("drowning") and
        (inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown()) then
            inst.sg:GoToState("sink_boat", data.shore_pt)
        else
            if inst.components.sailor and inst.components.sailor.boat and inst.components.sailor.boat.components.container then
                inst.components.sailor.boat.components.container:Close(true)
            end
            _onsink_eventhandler(inst, data, ...)
        end
    end

    local _death_eventhandler = sg.events.death.fn
    sg.events.death.fn = function(inst, data)
        if data.cause == "drowning" then
            inst.sg:GoToState("death_drown")
        else
            if inst.components.sailor and inst.components.sailor.boat and inst.components.sailor.boat.components.container then
                inst.components.sailor.boat.components.container:Close(true)
            end
            _death_eventhandler(inst, data)
        end
    end

    local _castspell_deststate = sg.actionhandlers[ACTIONS.CASTSPELL].deststate
    sg.actionhandlers[ACTIONS.CASTSPELL].deststate = function(inst, action)
        local staff = action.invobject or action.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if staff:HasTag("bonestaff") then
            return "castspell_bone"
        else
            return _castspell_deststate and _castspell_deststate(inst, action)
        end
    end
end)
