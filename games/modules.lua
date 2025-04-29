local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/QP-Offcial/VapeV4ForRoblox/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end
local run = function(func)
	func()
end
local btext = function(text)
	return text..' '
end

local queue_on_teleport = queue_on_teleport or function() end
local cloneref = cloneref or function(obj)
	return obj
end

local function getPlacedBlock(pos)
	if not pos then
		return
	end
	local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
	return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

local vapeConnections
if shared.vapeConnections and type(shared.vapeConnections) == "table" then vapeConnections = shared.vapeConnections else vapeConnections = {}; shared.vapeConnections = vapeConnections; end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local runService = cloneref(game:GetService('RunService'))
local inputService = cloneref(game:GetService('UserInputService'))
local tweenService = cloneref(game:GetService('TweenService'))
local lightingService = cloneref(game:GetService('Lighting'))
local marketplaceService = cloneref(game:GetService('MarketplaceService'))
local teleportService = cloneref(game:GetService('TeleportService'))
local httpService = cloneref(game:GetService('HttpService'))
local guiService = cloneref(game:GetService('GuiService'))
local groupService = cloneref(game:GetService('GroupService'))
local textChatService = cloneref(game:GetService('TextChatService'))
local contextService = cloneref(game:GetService('ContextActionService'))
local coreGui = cloneref(game:GetService('CoreGui'))
local collectionService = cloneref(game:GetService("CollectionService"))

local isnetworkowner = identifyexecutor and table.find({'AWP', 'Nihon'}, ({identifyexecutor()})[1]) and isnetworkowner or function()
	return true
end
local gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
local lplr = playersService.LocalPlayer
local assetfunction = getcustomasset

local GuiLibrary = shared.GuiLibrary
local vape = shared.vape
local entitylib = vape.Libraries.entity
local targetinfo = vape.Libraries.targetinfo
local sessioninfo = vape.Libraries.sessioninfo
local uipallet = vape.Libraries.uipallet
local tween = vape.Libraries.tween
local color = vape.Libraries.color
local whitelist = vape.Libraries.whitelist
local prediction = vape.Libraries.prediction
local getfontsize = vape.Libraries.getfontsize
local getcustomasset = vape.Libraries.getcustomasset

local activeTweens = {}
local activeAnimationTrack = nil
local activeModel = nil
local emoteActive = false
 

local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = runService.RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = runService.Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = runService.Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

local XStore = {
	bedtable = {},
	Tweening = false,
	AntiHitting = false
}
XFunctions:SetGlobalData('XStore', XStore)

local function getrandomvalue(tab)
	return #tab > 0 and tab[math.random(1, #tab)] or ''
end

local function GetEnumItems(enum)
	local fonts = {}
	for i,v in next, Enum[enum]:GetEnumItems() do 
		table.insert(fonts, v.Name) 
	end
	return fonts
end

local isAlive = function(plr, healthblacklist)
	plr = plr or lplr
	local alive = false 
	if plr.Character and plr.Character.PrimaryPart and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Head") then 
		alive = true
	end
	if not healthblacklist and alive and plr.Character.Humanoid.Health and plr.Character.Humanoid.Health <= 0 then 
		alive = false
	end
	return alive
end
local function GetMagnitudeOf2Objects(part, part2, bypass)
	local magnitude, partcount = 0, 0
	if not bypass then 
		local suc, res = pcall(function() return part.Position end)
		partcount = suc and partcount + 1 or partcount
		suc, res = pcall(function() return part2.Position end)
		partcount = suc and partcount + 1 or partcount
	end
	if partcount > 1 or bypass then 
		magnitude = bypass and (part - part2).magnitude or (part.Position - part2.Position).magnitude
	end
	return magnitude
end
local function createSequence(args)
    local seq =
        ColorSequence.new(
        {
            ColorSequenceKeypoint.new(args[1], args[2]),
            ColorSequenceKeypoint.new(args[3], args[4])
        }
    )
    return seq
end
local function GetTopBlock(position, smart, raycast, customvector)
	position = position or isAlive(lplr, true) and lplr.Character:WaitForChild("HumanoidRootPart").Position
	if not position then 
		return nil 
	end
	if raycast and not game.Workspace:Raycast(position, Vector3.new(0, -2000, 0), store.blockRaycast) then
	    return nil
    end
	local lastblock = nil
	for i = 1, 500 do 
		local newray = game.Workspace:Raycast(lastblock and lastblock.Position or position, customvector or Vector3.new(0.55, 999999, 0.55), store.blockRaycast)
		local smartest = newray and smart and game.Workspace:Raycast(lastblock and lastblock.Position or position, Vector3.new(0, 5.5, 0), store.blockRaycast) or not smart
		if newray and smartest then
			lastblock = newray
		else
			break
		end
	end
	return lastblock
end
local function FindEnemyBed(maxdistance, highest)
	local target = nil
	local distance = maxdistance or math.huge
	local whitelistuserteams = {}
	local badbeds = {}
	if not lplr:GetAttribute("Team") then return nil end
	for i,v in pairs(playersService:GetPlayers()) do
		if v ~= lplr then
			local type, attackable = vape.Libraries.whitelist:get(v)
			if not attackable then
				whitelistuserteams[v:GetAttribute("Team")] = true
			end
		end
	end
	for i,v in pairs(collectionService:GetTagged("bed")) do
			local bedteamstring = string.split(v:GetAttribute("id"), "_")[1]
			if whitelistuserteams[bedteamstring] ~= nil then
			   badbeds[v] = true
		    end
	    end
	for i,v in pairs(collectionService:GetTagged("bed")) do
		if v:GetAttribute("id") and v:GetAttribute("id") ~= lplr:GetAttribute("Team").."_bed" and badbeds[v] == nil and lplr.Character and lplr.Character.PrimaryPart then
			if v:GetAttribute("NoBreak") or v:GetAttribute("PlacedByUserId") and v:GetAttribute("PlacedByUserId") ~= 0 then continue end
			local magdist = GetMagnitudeOf2Objects(lplr.Character.PrimaryPart, v)
			if magdist < distance then
				target = v
				distance = magdist
			end
		end
	end
	local coveredblock = highest and target and GetTopBlock(target.Position, true)
	if coveredblock then
		target = coveredblock.Instance
	end
	for i,v in pairs(game:GetService("Teams"):GetTeams()) do
		if target and v.TeamColor == target.Bed.BrickColor then
			XStore.bedtable[target] = v.Name
		end
	end
	return target
end
local function FindTeamBed()
	local bedstate, res = pcall(function()
		return lplr.leaderstats.Bed.Value
	end)
	return bedstate and res and res ~= nil and res == "✅"
end
local function FindItemDrop(item)
	local itemdist = nil
	local dist = math.huge
	local function abletocalculate() return lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") end
    for i,v in pairs(collectionService:GetTagged("ItemDrop")) do
		if v and v.Name == item and abletocalculate() then
			local itemdistance = GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v)
			if itemdistance < dist then
			itemdist = v
			dist = itemdistance
		end
		end
	end
	return itemdist
end

local function getItem(itemName, inv)
	for slot, item in (inv or store.inventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end

local vapeAssert = function(argument, title, text, duration, hault, moduledisable, module) 
	if not argument then
    local suc, res = pcall(function()
    local notification = GuiLibrary:CreateNotification(title or "QP Vape", text or "Failed to call function.", duration or 20, "assets/WarningNotification.png")
    notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
    notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
    if moduledisable and (module and vape.Modules[module].Enabled) then vape.Modules[module]:Toggle(false) end
    end)
    if hault then while true do task.wait() end end end
end

local function spinParts(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name == "Middle" or part.Name == "Outer") then
            local tweenInfo, goal
            if part.Name == "Middle" then
                tweenInfo = TweenInfo.new(12.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0)
                goal = { Orientation = part.Orientation + Vector3.new(0, -360, 0) }
            elseif part.Name == "Outer" then
                tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0)
                goal = { Orientation = part.Orientation + Vector3.new(0, 360, 0) }
            end
 
            local tween = tweenService:Create(part, tweenInfo, goal)
            tween:Play()
            table.insert(activeTweens, tween)
        end
    end
end
 
local function placeModelUnderLeg()
    local player = playersService.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
 
    if humanoidRootPart then
        local assetsFolder = replicatedStorage:FindFirstChild("Assets")
        if assetsFolder then
            local effectsFolder = assetsFolder:FindFirstChild("Effects")
            if effectsFolder then
                local modelTemplate = effectsFolder:FindFirstChild("NightmareEmote")
                if modelTemplate and modelTemplate:IsA("Model") then
                    local clonedModel = modelTemplate:Clone()
                    clonedModel.Parent = workspace
 
                    if clonedModel.PrimaryPart then
                        clonedModel:SetPrimaryPartCFrame(humanoidRootPart.CFrame - Vector3.new(0, 3, 0))
                    else
                        warn("PrimaryPart not set for NightmareEmote model!")
                        return
                    end
 
                    spinParts(clonedModel)
                    activeModel = clonedModel
                else
                    warn("NightmareEmote model not found or is not a valid model!")
                end
            else
                warn("Effects folder not found in Assets!")
            end
        else
            warn("Assets folder not found in ReplicatedStorage!")
        end
    else
        warn("HumanoidRootPart not found in character!")
    end
end
 
local function playAnimation(animationId)
    local player = playersService.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
 
    if humanoid then
        local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
        local animation = Instance.new("Animation")
        animation.AnimationId = animationId
        activeAnimationTrack = animator:LoadAnimation(animation)
        activeAnimationTrack:Play()
    else
        warn("Humanoid not found in character!")
    end
end
 
local function stopEffects()
    for _, tween in ipairs(activeTweens) do
        tween:Cancel()
    end
    activeTweens = {}
 
    if activeAnimationTrack then
        activeAnimationTrack:Stop()
        activeAnimationTrack = nil
    end
 
    if activeModel then
        activeModel:Destroy()
        activeModel = nil
    end
 
    emoteActive = false
end
 
local function monitorWalking()
    local player = playersService.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
 
    if humanoid then
        humanoid.Running:Connect(function(speed)
            if speed > 0 and emoteActive then
                stopEffects()
            end
        end)
    else
        warn("Humanoid not found in character!")
    end
end
 
local function activateNightmareEmote()
    if emoteActive then
        return
    end
 
    emoteActive = true
    local success, err = pcall(function()
        monitorWalking()
        placeModelUnderLeg()
        playAnimation("rbxassetid://9191822700")
    end)
 
    if not success then
        warn("Error occurred: " .. tostring(err))
        emoteActive = false
    end
end




run(function()
    local InfiniteJump
    local Velocity
    InfiniteJump = vape.Categories.Modules:CreateModule({
        Name = "InfiniteJump",
        Function = function(callback)
            if callback then
				InfiniteJump:Clean(inputService.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then return end
					if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
						while inputService:IsKeyDown(Enum.KeyCode.Space) do
							local PrimaryPart = lplr.Character.PrimaryPart
							if entitylib.isAlive and PrimaryPart then
								PrimaryPart.Velocity = vector.create(PrimaryPart.Velocity.X, Velocity.Value, PrimaryPart.Velocity.Z)
							end
							wait()
						end
					end
				end))
				if inputService.TouchEnabled then
					local Jumping = false
					local JumpButton = lplr.PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
					
					InfiniteJump:Clean(JumpButton.MouseButton1Down:Connect(function()
						Jumping = true
					end))

					InfiniteJump:Clean(JumpButton.MouseButton1Up:Connect(function()
						Jumping = false
					end))

					InfiniteJump:Clean(runService.RenderStepped:Connect(function()
						if Jumping and entitylib.isAlive then
							local PrimaryPart = lplr.Character.PrimaryPart
							PrimaryPart.Velocity = vector.create(PrimaryPart.Velocity.X, Velocity.Value, PrimaryPart.Velocity.Z)
						end
					end))
				end
			end
        end,
        Tooltip = "Allows infinite jumping"
    })
    Velocity = InfiniteJump:CreateSlider({
        Name = 'Velocity',
        Min = 50,
        Max = 300,
        Default = 50
    })
end)

run(function()
	local InfernalKill = {Enabled = false}
	InfernalKill = vape.Categories.Modules:CreateModule({
		["Name"] = "EmberExploit",
		["Function"] = function(callback)
			if callback then
				repeat
					wait()
					local tmp = getItem("infernal_saber")
					if tmp then
						bedwars.Client:Get('HellBladeRelease'):SendToServer({
							weapon = tmp.tool;
							player = game:GetService("Players").LocalPlayer;
							chargeTime = 0.9;
						})
					end
				until not InfernalKill["Enabled"]
			end
		end,
		["Description"] = "Ember Exploit"
	})
end)

run(function()
	local SkyScytheKill = {Enabled = false}
	SkyScytheKill = vape.Categories.Modules:CreateModule({
		["Name"] = "SkyScytheExploit",
		["Function"] = function(callback)
			if callback then
				repeat
					wait()
					if getItem("sky_scythe") then
						bedwars.Client:Get('SkyScytheSpin'):SendToServer()
					end
				until not SkyScytheKill["Enabled"]
			end
		end,
		["Description"] = "SkyScytheExploit"
	})
end)

run(function()
	local PartyPopperExploit = {Enabled = false}
	PartyPopperExploit = vape.Categories.Modules:CreateModule({
		["Name"] = "PartyPopperExploit",
		["Function"] = function(callback)
			if callback then
				repeat
					wait()
					bedwars.AbilityController:useAbility('PARTY_POPPER')
				until not PartyPopperExploit["Enabled"]
			end
		end,
		["Description"] = "PartyPopperExploit"
	})
end)

run(function()
	local TrainWhistleExploit = {Enabled = false}
	TrainWhistleExploit = vape.Categories.Modules:CreateModule({
		["Name"] = "TrainWhistleExploit",
		["Function"] = function(callback)
			if callback then
				repeat
					wait()
					bedwars.AbilityController:useAbility('TRAIN_WHISTLE')
				until not TrainWhistleExploit["Enabled"]
			end
		end,
		["Description"] = "TrainWhistleExploit"
	})
end)


-- patched
-- run(function()
-- 	local ProjectileExploit = {Enabled = false}
-- 	local old
-- 	ProjectileExploit = vape.Categories.Modules:CreateModule({
-- 		["Name"] = "ProjectileExploit",
-- 		["Function"] = function(callback)
-- 			if callback then
-- 				old = hookmetamethod(game, "__namecall", function(self, ...)
-- 					if self == replicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.ProjectileFire and not checkcaller() then
-- 						local args = {...}
-- 						args[8].drawDurationSeconds = 0/0
-- 					end
-- 					return old(self, ...)
-- 				end)
-- 			else
-- 				if old then
-- 					hookmetamethod(game, '__namecall', old)
-- 				end
-- 			end
-- 		end,
-- 		["Description"] = "ProjectileExploit Thanks Retro.gone"
-- 	})
-- end)

-- patched
-- run(function()
-- 	local SkollKitCrasher = {Enabled = false}
-- 	SkollKitCrasher = vape.Categories.Modules:CreateModule({
-- 		["Name"] = "SkollKitCrasher",
-- 		["Function"] = function(callback)
-- 			if callback then
-- 				repeat
-- 					task.wait()
-- 					game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("VoidHunter_MarkAbilityRequest"):FireServer({
-- 						direction = Vector3.zero;
-- 					})
-- 				until not SkollKitCrasher["Enabled"]
-- 			end
-- 		end,
-- 		["Description"] = "SkollKitCrasher"
-- 	})
-- end)
-- run(function()
-- 	local AntiSkollKitCrasher = {Enabled = false}
-- 	AntiSkollKitCrasher = vape.Categories.Modules:CreateModule({
-- 		["Name"] = "AntiSkollKitCrasher",
-- 		["Function"] = function(callback)
-- 			if callback then
-- 				for i,v in next, getgc() do
-- 					if type(v) == 'function' and debug.info(v,"n") == "useMarkAbility" then
-- 						local RateLimit = {}
-- 						local old
-- 						old = hookfunction(v,function(...)
-- 							local args = {...}
-- 							if not RateLimit[args[2]] then
-- 								RateLimit[args[2]] = tick()
-- 								return old(...)
-- 							elseif RateLimit[args[2]] + 10 < tick() then
-- 								RateLimit[args[2]] = tick()
-- 								return old(...)
-- 							end
-- 						end)
-- 						break
-- 					end
-- 				end
-- 			end
-- 		end,
-- 		["Description"] = "AntiSkollKitCrasher"
-- 	})
-- end)

run(function()
    local NightmareEventButton
    NightmareEventButton = vape.Categories.Modules:CreateModule({
        Name = "Nightmare Emote",
        Description = "Play Nightmare Emote",
        Function = function(callback)
            if callback then
                NightmareEventButton:Toggle(false)
                activateNightmareEmote()
            end
        end
    })
end)

run(function()
    local AdetundeExploit
    local AdetundeExploit_List

    local adetunde_remotes = {
        ["Shield"] = function()
            local args = { [1] = "shield" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end,

        ["Speed"] = function()
            local args = { [1] = "speed" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end,

        ["Strength"] = function()
            local args = { [1] = "strength" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end
    }

    local current_upgrador = "Shield"
    local hasnt_upgraded_everything = true
    local testing = 1

    AdetundeExploit = vape.Categories.Modules:CreateModule({
        Name = 'AdetundeExploit',
        Function = function(calling)
            if calling then 
                -- Check if in testing mode or equipped kit
                -- if tostring(shared.store.queueType) == "training_room" or shared.store.equippedKit == "adetunde" then
                --     AdetundeExploit["ToggleButton"](false) 
                --     current_upgrador = AdetundeExploit_List.Value
                task.spawn(function()
                    repeat
                        local returning_table = adetunde_remotes[current_upgrador]()
                        
                        if type(returning_table) == "table" then
                            local Speed = returning_table["speed"]
                            local Strength = returning_table["strength"]
                            local Shield = returning_table["shield"]

                            print("Speed: " .. tostring(Speed))
                            print("Strength: " .. tostring(Strength))
                            print("Shield: " .. tostring(Shield))
                            print("Current Upgrador: " .. tostring(current_upgrador))

                            if returning_table[string.lower(current_upgrador)] == 3 then
                                if Strength and Shield and Speed then
                                    if Strength == 3 or Speed == 3 or Shield == 3 then
                                        if (Strength == 3 and Speed == 2 and Shield == 2) or
                                           (Strength == 2 and Speed == 3 and Shield == 2) or
                                           (Strength == 2 and Speed == 2 and Shield == 3) then
                                            -- warningNotification("AdetundeExploit", "Fully upgraded everything possible!", 7)
                                            hasnt_upgraded_everything = false
                                        else
                                            local things = {}
                                            for i, v in pairs(adetunde_remotes) do
                                                table.insert(things, i)
                                            end
                                            for i, v in pairs(things) do
                                                if things[i] == current_upgrador then
                                                    table.remove(things, i)
                                                end
                                            end
                                            local random = things[math.random(1, #things)]
                                            current_upgrador = random
                                        end
                                    end
                                end
                            end
                        else
                            local things = {}
                            for i, v in pairs(adetunde_remotes) do
                                table.insert(things, i)
                            end
                            for i, v in pairs(things) do
                                if things[i] == current_upgrador then
                                    table.remove(things, i)
                                end
                            end
                            local random = things[math.random(1, #things)]
                            current_upgrador = random
                        end
                        task.wait(0.1)
                    until not AdetundeExploit.Enabled or not hasnt_upgraded_everything
                end)
                -- else
                --     AdetundeExploit["ToggleButton"](false)
                --     warningNotification("AdetundeExploit", "Kit required or you need to be in testing mode", 5)
                -- end
            end
        end
    })

    local real_list = {}
    for i, v in pairs(adetunde_remotes) do
        table.insert(real_list, i)
    end

    AdetundeExploit_List = AdetundeExploit:CreateDropdown({
        Name = 'Preferred Upgrade',
        List = real_list,
        Function = function() end,
        Default = "Shield"
    })
end)

run(function()
	local NoNameTag
	NoNameTag = vape.Categories.Modules:CreateModule({
		PerformanceModeBlacklisted = true,
		Name = 'NoNameTag',
        Tooltip = 'Removes your NameTag.',
		Function = function(callback)
			if callback then
				NoNameTag:Clean(runService.RenderStepped:Connect(function()
					pcall(function()
						lplr.Character.Head.Nametag:Destroy()
					end)
				end))
			end
		end,
        Default = false
	})
end)

run(function()
	local DamageIndicator = {}
	local DamageIndicatorColorToggle = {}
	local DamageIndicatorColor = {Hue = 0, Sat = 0, Value = 0}
	local DamageIndicatorTextToggle = {}
	local DamageIndicatorText = {ListEnabled = {}}
	local DamageIndicatorFontToggle = {}
	local DamageIndicatorFont = {Value = 'GothamBlack'}
	local DamageIndicatorTextObjects = {}
    local DamageIndicatorMode1
    local DamageMessages = {
		'Pow!',
		'Pop!',
		'Hit!',
		'Smack!',
		'Bang!',
		'Boom!',
		'Whoop!',
		'Damage!',
		'-9e9!',
		'Whack!',
		'Crash!',
		'Slam!',
		'Zap!',
		'Snap!',
		'Thump!'
	}
	local RGBColors = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(255, 127, 0),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(0, 0, 255),
		Color3.fromRGB(75, 0, 130),
		Color3.fromRGB(148, 0, 211)
	}
	local orgI, mz, vz = 1, 5, 10
    local DamageIndicatorMode = {Value = 'Rainbow'}
	local DamageIndicatorMode2 = {Value = 'Gradient'}
	DamageIndicator = vape.Categories.Modules:CreateModule({
        PerformanceModeBlacklisted = true,
		Name = 'DamageIndicator',
		Function = function(calling)
			if calling then
				task.spawn(function()
					table.insert(DamageIndicator.Connections, workspace.DescendantAdded:Connect(function(v)
						pcall(function()
                            if v.Name ~= 'DamageIndicatorPart' then return end
							local indicatorobj = v:FindFirstChildWhichIsA('BillboardGui'):FindFirstChildWhichIsA('Frame'):FindFirstChildWhichIsA('TextLabel')
							if indicatorobj then
                                if DamageIndicatorColorToggle.Enabled then
                                    -- indicatorobj.TextColor3 = Color3.fromHSV(DamageIndicatorColor.Hue, DamageIndicatorColor.Sat, DamageIndicatorColor.Value)
                                    if DamageIndicatorMode.Value == 'Rainbow' then
                                        if DamageIndicatorMode2.Value == 'Gradient' then
                                            indicatorobj.TextColor3 = Color3.fromHSV(tick() % mz / mz, orgI, orgI)
                                        else
                                            runService.Stepped:Connect(function()
                                                orgI = (orgI % #RGBColors) + 1
                                                indicatorobj.TextColor3 = RGBColors[orgI]
                                            end)
                                        end
                                    elseif DamageIndicatorMode.Value == 'Custom' then
                                        indicatorobj.TextColor3 = Color3.fromHSV(
                                            DamageIndicatorColor.Hue, 
                                            DamageIndicatorColor.Sat, 
                                            DamageIndicatorColor.Value
                                        )
                                    else
                                        indicatorobj.TextColor3 = Color3.fromRGB(127, 0, 255)
                                    end
                                end
                                if DamageIndicatorTextToggle.Enabled then
                                    if DamageIndicatorMode1.Value == 'Custom' then
                                        print(getrandomvalue(DamageIndicatorText.ListEnabled))
                                        local o = getrandomvalue(DamageIndicatorText.ListEnabled)
                                        indicatorobj.Text = o ~= '' and o or indicatorobj.Text
									elseif DamageIndicatorMode1.Value == 'Multiple' then
										indicatorobj.Text = DamageMessages[math.random(orgI, #DamageMessages)]
									else
										indicatorobj.Text = 'Render Intents on top!'
									end
								end
								indicatorobj.Font = DamageIndicatorFontToggle.Enabled and Enum.Font[DamageIndicatorFont.Value] or indicatorobject.Font
							end
						end)
					end))
				end)
			end
		end
	})
    DamageIndicatorMode = DamageIndicator:CreateDropdown({
		Name = 'Color Mode',
		List = {
			'Rainbow',
			'Custom',
			'Lunar'
		},
		HoverText = 'Mode to color the Damage Indicator',
		Value = 'Rainbow',
		Function = function() end
	})
	DamageIndicatorMode2 = DamageIndicator:CreateDropdown({
		Name = 'Rainbow Mode',
		List = {
			'Gradient',
			'Paint'
		},
		HoverText = 'Mode to color the Damage Indicator\nwith Rainbow Color Mode',
		Value = 'Gradient',
		Function = function() end
	})
    DamageIndicatorMode1 = DamageIndicator:CreateDropdown({
		Name = 'Text Mode',
		List = {
            'Custom',
			'Multiple',
			'Lunar'
		},
		HoverText = 'Mode to change the Damage Indicator Text',
		Value = 'Custom',
		Function = function() end
	})
	DamageIndicatorColorToggle = DamageIndicator:CreateToggle({
		Name = 'Custom Color',
		Function = function(calling) pcall(function() DamageIndicatorColor.Object.Visible = calling end) end
	})
	DamageIndicatorColor = DamageIndicator:CreateColorSlider({
		Name = 'Text Color',
		Function = function() end
	})
	DamageIndicatorTextToggle = DamageIndicator:CreateToggle({
		Name = 'Custom Text',
		HoverText = 'random messages for the indicator',
		Function = function(calling) pcall(function() DamageIndicatorText.Object.Visible = calling end) end
	})
	DamageIndicatorText = DamageIndicator:CreateTextList({
		Name = 'Text',
		TempText = 'Indicator Text',
		AddFunction = function() end
	})
	DamageIndicatorFontToggle = DamageIndicator:CreateToggle({
		Name = 'Custom Font',
		Function = function(calling) pcall(function() DamageIndicatorFont.Object.Visible = calling end) end
	})
	DamageIndicatorFont = DamageIndicator:CreateDropdown({
		Name = 'Font',
		List = GetEnumItems('Font'),
		Function = function() end
	})
	DamageIndicatorColor.Object.Visible = DamageIndicatorColorToggle.Enabled
	DamageIndicatorText.Object.Visible = DamageIndicatorTextToggle.Enabled
	DamageIndicatorFont.Object.Visible = DamageIndicatorFontToggle.Enabled
end)

run(function()
	local HealthbarVisuals = {};
	local HealthbarRound = {};
	local HealthbarColorToggle = {};
	local HealthbarGradientToggle = {};
	local HealthbarGradientColor = {};
	local HealthbarHighlight = {};
	local HealthbarHighlightColor = newcolor();
	local HealthbarGradientRotation = {Value = 0};
	local HealthbarTextToggle = {};
	local HealthbarFontToggle = {};
	local HealthbarTextColorToggle = {};
	local HealthbarBackgroundToggle = {};
	local HealthbarText = {ListEnabled = {}};
	local HealthbarInvis = {Value = 0};
	local HealthbarRoundSize = {Value = 4};
	local HealthbarFont = {value = 'LuckiestGuy'};
	local HealthbarColor = newcolor();
	local HealthbarBackground = newcolor();
	local HealthbarTextColor = newcolor();
	local healthbarobjects = Performance.new();
	local oldhealthbar;
	local healthbarhighlight;
	local textconnection;
	local function healthbarFunction()
		if not HealthbarVisuals.Enabled then 
			return 
		end
		local healthbar = ({pcall(function() return lplr.PlayerGui.hotbar['1'].HotbarHealthbarContainer.HealthbarProgressWrapper['1'] end)})[2]
		if healthbar and type(healthbar) == 'userdata' then 
			oldhealthbar = healthbar;
			healthbar.Transparency = (0.1 * HealthbarInvis.Value);
			healthbar.BackgroundColor3 = (HealthbarColorToggle.Enabled and Color3.fromHSV(HealthbarColor.Hue, HealthbarColor.Sat, HealthbarColor.Value) or healthbar.BackgroundColor3)
			if HealthbarGradientToggle.Enabled then 
				healthbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				local gradient = (healthbar:FindFirstChildWhichIsA('UIGradient') or Instance.new('UIGradient', healthbar))
				gradient.Color = createSequence({0, Color3.fromHSV(HealthbarColor.Hue, HealthbarColor.Sat, HealthbarColor.Value), 1, Color3.fromHSV(HealthbarGradientColor.Hue, HealthbarGradientColor.Sat, HealthbarGradientColor.Value)})
				gradient.Rotation = HealthbarGradientRotation.Value
				table.insert(healthbarobjects, gradient)
			end
			for i,v in healthbar.Parent:GetChildren() do 
				if v:IsA('Frame') and v:FindFirstChildWhichIsA('UICorner') == nil and HealthbarRound.Enabled then
					local corner = Instance.new('UICorner', v);
					corner.CornerRadius = UDim.new(0, HealthbarRoundSize.Value);
					table.insert(healthbarobjects, corner)
				end
			end
			local healthbarbackground = ({pcall(function() return healthbar.Parent.Parent end)})[2]
			if healthbarbackground and type(healthbarbackground) == 'userdata' then
				healthbar.Transparency = (0.1 * HealthbarInvis.Value);
				if HealthbarHighlight.Enabled then 
					local highlight = Instance.new('UIStroke', healthbarbackground);
					highlight.Color = Color3.fromHSV(HealthbarHighlightColor.Hue, HealthbarHighlightColor.Sat, HealthbarHighlightColor.Value);
					highlight.Thickness = 1.6; 
					healthbarhighlight = highlight
				end
				if healthbar.Parent.Parent:FindFirstChildWhichIsA('UICorner') == nil and HealthbarRound.Enabled then 
					local corner = Instance.new('UICorner', healthbar.Parent.Parent);
					corner.CornerRadius = UDim.new(0, HealthbarRoundSize.Value);
					table.insert(healthbarobjects, corner)
				end 
				if HealthbarBackgroundToggle.Enabled then
					healthbarbackground.BackgroundColor3 = Color3.fromHSV(HealthbarBackground.Hue, HealthbarBackground.Sat, HealthbarBackground.Value)
				end
			end
			local healthbartext = ({pcall(function() return healthbar.Parent.Parent['1'] end)})[2]
			if healthbartext and type(healthbartext) == 'userdata' then 
				local randomtext = getrandomvalue(HealthbarText.ListEnabled)
				if HealthbarTextColorToggle.Enabled then
					healthbartext.TextColor3 = Color3.fromHSV(HealthbarTextColor.Hue, HealthbarTextColor.Sat, HealthbarTextColor.Value)
				end
				if HealthbarFontToggle.Enabled then 
					healthbartext.Font = Enum.Font[HealthbarFont.Value]
				end
				if randomtext ~= '' and HealthbarTextToggle.Enabled then 
					healthbartext.Text = randomtext:gsub('<health>', isAlive(lplr, true) and tostring(math.round(lplr.Character:GetAttribute('Health') or 0)) or '0')
				else
					pcall(function() healthbartext.Text = tostring(lplr.Character:GetAttribute('Health')) end)
				end
				if not textconnection then 
					textconnection = healthbartext:GetPropertyChangedSignal('Text'):Connect(function()
						local randomtext = getrandomvalue(HealthbarText.ListEnabled)
						if randomtext ~= '' then 
							healthbartext.Text = randomtext:gsub('<health>', isAlive() and tostring(math.floor(lplr.Character:GetAttribute('Health') or 0)) or '0')
						else
							pcall(function() healthbartext.Text = tostring(math.floor(lplr.Character:GetAttribute('Health'))) end)
						end
					end)
				end
			end
		end
	end
	HealthbarVisuals = vape.Categories.Modules:CreateModule({
		Name = 'HealthbarVisuals',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(HealthbarVisuals.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'HotbarHealthbarContainer' and v.Parent and v.Parent.Parent and v.Parent.Parent.Name == 'hotbar' then
							healthbarFunction()
						end
					end))
					healthbarFunction()
				end)
			else
				pcall(function() textconnection:Disconnect() end)
				pcall(function() oldhealthbar.Parent.Parent.BackgroundColor3 = Color3.fromRGB(41, 51, 65) end)
				pcall(function() oldhealthbar.BackgroundColor3 = Color3.fromRGB(203, 54, 36) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].Text = tostring(lplr.Character:GetAttribute('Health')) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].TextColor3 = Color3.fromRGB(255, 255, 255) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].Font = Enum.Font.LuckiestGuy end)
				oldhealthbar = nil
				textconnection = nil
				for i,v in healthbarobjects do 
					pcall(function() v:Destroy() end)
				end
				table.clear(healthbarobjects);
				pcall(function() healthbarhighlight:Destroy() end);
				healthbarhighlight = nil;
			end
		end
	})
	HealthbarColorToggle = HealthbarVisuals:CreateToggle({
		Name = 'Main Color',
		Default = true,
		Function = function(calling)
			pcall(function() HealthbarColor.Object.Visible = calling end)
			pcall(function() HealthbarGradientToggle.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end 
	})
	HealthbarGradientToggle = HealthbarVisuals:CreateToggle({
		Name = 'Gradient',
		Function = function(calling)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end
	})
	HealthbarColor = HealthbarVisuals:CreateColorSlider({
		Name = 'Main Color',
		Function = function()
			task.spawn(healthbarFunction)
		end
	})
	HealthbarGradientColor = HealthbarVisuals:CreateColorSlider({
		Name = 'Secondary Color',
		Function = function(calling)
			if HealthbarGradientToggle.Enabled then 
				task.spawn(healthbarFunction)
			end
		end
	})
	HealthbarBackgroundToggle = HealthbarVisuals:CreateToggle({
		Name = 'Background Color',
		Function = function(calling)
			pcall(function() HealthbarBackground.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end 
	})
	HealthbarBackground = HealthbarVisuals:CreateColorSlider({
		Name = 'Background Color',
		Function = function() 
			task.spawn(healthbarFunction)
		end
	})
	HealthbarTextToggle = HealthbarVisuals:CreateToggle({
		Name = 'Text',
		Function = function(calling)
			pcall(function() HealthbarText.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end 
	})
	HealthbarText = HealthbarVisuals:CreateTextList({
		Name = 'Text',
		TempText = 'Healthbar Text',
		AddFunction = function()
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end,
		RemoveFunction = function()
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end
	})
	HealthbarTextColorToggle = HealthbarVisuals:CreateToggle({
		Name = 'Text Color',
		Function = function(calling)
			pcall(function() HealthbarTextColor.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end 
	})
	HealthbarTextColor = HealthbarVisuals:CreateColorSlider({
		Name = 'Text Color',
		Function = function() 
			task.spawn(healthbarFunction)
		end
	})
	HealthbarFontToggle = HealthbarVisuals:CreateToggle({
		Name = 'Text Font',
		Function = function(calling)
			pcall(function() HealthbarFont.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end 
	})
	HealthbarFont = HealthbarVisuals:CreateDropdown({
		Name = 'Text Font',
		List = GetEnumItems('Font'),
		Function = function(calling)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end
	})
	HealthbarRound = HealthbarVisuals:CreateToggle({
		Name = 'Round',
		Function = function(calling)
			pcall(function() HealthbarRoundSize.Object.Visible = calling end);
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end
	})
	HealthbarRoundSize = HealthbarVisuals:CreateSlider({
		Name = 'Corner Size',
		Min = 1,
		Max = 20,
		Default = 5,
		Function = function(value)
			if HealthbarVisuals.Enabled then 
				pcall(function() 
					oldhealthbar.Parent:FindFirstChildOfClass('UICorner').CornerRadius = UDim.new(0, value);
					oldhealthbar.Parent.Parent:FindFirstChildOfClass('UICorner').CornerRadius = UDim.new(0, value)  
				end)
			end
		end
	})
	HealthbarHighlight = HealthbarVisuals:CreateToggle({
		Name = 'Highlight',
		Function = function(calling)
			pcall(function() HealthbarHighlightColor.Object.Visible = calling end);
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end
	})
	HealthbarHighlightColor = HealthbarVisuals:CreateColorSlider({
		Name = 'Highlight Color',
		Function = function()
			if HealthbarVisuals.Enabled then 
				pcall(function() healthbarhighlight.Color = Color3.fromHSV(HealthbarHighlightColor.Hue, HealthbarHighlightColor.Sat, HealthbarHighlightColor.Value) end)
			end
		end
	})
	HealthbarInvis = HealthbarVisuals:CreateSlider({
		Name = 'Invisibility',
		Min = 0,
		Max = 10,
		Function = function(value)
			pcall(function() 
				oldhealthbar.Transparency = (0.1 * value);
				oldhealthbar.Parent.Parent.Transparency = (0.1 * HealthbarInvis.Value); 
			end)
		end
	})
	HealthbarBackground.Object.Visible = false;
	HealthbarText.Object.Visible = false;
	HealthbarTextColor.Object.Visible = false;
	HealthbarFont.Object.Visible = false;
	HealthbarRoundSize.Object.Visible = false;
	HealthbarHighlightColor.Object.Visible = false;
end)

run(function()
	local PlayerViewModel = {};
    local viewmodelMode = {};
	local viewmodel = Performance.new()
	local reModel = function(entity)
		for i,v in entity.Character:GetChildren() do
			if v:IsA('BasePart') or v:IsA('Accessory') then
				pcall(function() v.Transparency = 1 end)
			end
		end
		local part = Instance.new("Part", entity.Character)
		part.CanCollide = false

		local mesh = Instance.new("SpecialMesh", part)
		mesh.MeshId = viewmodelMode.Value == 'Among Us' and 'http://www.roblox.com/asset/?id=6235963214' or 'http://www.roblox.com/asset/?id=13004256866'
		mesh.TextureId = viewmodelMode.Value == 'Among Us' and 'http://www.roblox.com/asset/?id=6235963270' or 'http://www.roblox.com/asset/?id=13004256905'
		mesh.Offset = viewmodelMode.Value == 'Rabbit' and Vector3.new(0,1.6,0) or Vector3.new(0,0.3,0)
		mesh.Scale = viewmodelMode.Value == 'Rabbit' and Vector3.new(10, 8, 10) or Vector3.new(0.11, 0.11, 0.11)

		local weld = Instance.new("Weld", part)
		weld.Part0 = part
		weld.Part1 = part.Parent.UpperTorso or part.Parent.Torso
		
		table.insert(viewmodel, task.spawn(function()
			viewmodel[entity.Name] = part
		end))
	end;
	local removeModel = function(ent)
        viewmodel[ent.Name]:Remove()
        for i,v in ent.Character:GetChildren() do
            if v:IsA('BasePart') or v:IsA('Accessory') then
                pcall(function() 
                    if v ~= ent.Character.PrimaryPart then 
                        v.Transparency = 0 
                    end 
                end)
            end
        end
        viewmodel[ent.Name] = nil
		task.wait(1)
	end
	PlayerViewModel = vape.Categories.Modules:CreateModule({
		Name = 'PlayerViewModel',
		Function = function(call)
			if call then
				for i,v in playersService:GetPlayers() do
					table.insert(PlayerViewModel.Connections, v.CharacterAdded:Connect(function()
						pcall(function() removeModel(v) end)
						task.spawn(pcall, reModel, v)
					end))
				end
				table.insert(PlayerViewModel.Connections, playersService.PlayerAdded:Connect(function(v)
					table.insert(PlayerViewModel.Connections, v.CharacterAdded:Connect(function()
						task.spawn(pcall, removeModel, v)
						task.spawn(pcall, reModel, v)
					end))
				end))
				RunLoops:BindToHeartbeat('PlayerVM', function()
					for i,v in playersService:GetPlayers() do
						if isAlive(v) and not viewmodel[v.Name] then
                            if not PlayerViewModel.Enabled then break end
							task.spawn(pcall, reModel, v)
						end
					end
				end)
			else
                RunLoops:UnbindFromHeartbeat('PlayerVM')
                for i,v in playersService:GetPlayers() do
                    task.spawn(pcall, removeModel, v)
                end
			end
		end,
		HoverText = 'Turns you into a curtain model'
	})
    viewmodelMode = PlayerViewModel:CreateDropdown({
        Name = 'Model',
        List = {'Among Us', 'Rabbit'},
        Function = function()
			PlayerViewModel:Toggle()
        end,
        Default = 'Among Us'
    })
end);


run(function()
	local queuecardvisuals = {};
	local queucardvisualsgradientoption = {};
	local queuecardvisualhighlight = {};
	local queuecardmodshighlightcolor = newcolor();
	local queuecardvisualscolor = newcolor();
	local queuecardvisualscolor2 = newcolor();
	local queuecardobjects = Performance.new();
	local queuecardvisualsround = {Value = 4};
	local queuecardfunc: () -> () = function()
		if not lplr.PlayerGui:FindFirstChild('QueueApp') then return end;
		if not queuecardvisuals.Enabled then return end;
		local card: Frame = lplr.PlayerGui.QueueApp:WaitForChild('1', math.huge);
		local cardcorner: UICorner = card:FindFirstChildOfClass('UICorner') or Instance.new('UICorner', card);
		card.BackgroundColor3 = Color3.fromHSV(queuecardvisualscolor.Hue, queuecardvisualscolor.Sat, queuecardvisualscolor.Value);
		cardcorner.CornerRadius = queuecardvisualsround.Value;
		if table.find(queuecardobjects, cardcorner) == nil then 
			table.insert(queuecardobjects, cardcorner);
		end;
		if queucardvisualsgradientoption.Enabled then 
			card.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			local gradient = card:FindFirstChildWhichIsA('UIGradient') or Instance.new('UIGradient', card);
			gradient.Color = ColorSequence.new({
				[1] = ColorSequenceKeypoint.new(0, Color3.fromHSV(queuecardvisualscolor.Hue, queuecardvisualscolor.Sat, queuecardvisualscolor.Value)), 
				[2] = ColorSequenceKeypoint.new(1, Color3.fromHSV(queuecardvisualscolor2.Hue, queuecardvisualscolor2.Sat, queuecardvisualscolor2.Value))
			});
			if table.find(queuecardobjects, gradient) == nil then
				table.insert(queuecardobjects, gradient);
			end;
		end;
		if queuecardvisualhighlight.Enabled then 
			local highlight: UIStroke? = card:FindFirstChildOfClass('UIStroke') or Instance.new('UIStroke', card);
			highlight.Thickness = 1.7;
			highlight.Color = Color3.fromHSV(queuecardmodshighlightcolor.Hue, queuecardmodshighlightcolor.Sat, queuecardmodshighlightcolor.Value);
			if table.find(queuecardobjects, highlight) == nil then
				table.insert(queuecardobjects, highlight);
			end;
		else
			pcall(function() card:FindFirstChildOfClass('UIStroke'):Destroy() end)
		end;
	end;
	queuecardvisuals = vape.Categories.Modules:CreateModule({
		Name = 'QueueCardVisuals',
		Function = function(calling: boolean)
			if calling then 
				pcall(queuecardfunc);
				table.insert(queuecardvisuals.Connections, lplr.PlayerGui.ChildAdded:Connect(queuecardfunc));
			else
				queuecardobjects:clear(game.Destroy)
			end
		end
	});
	queucardvisualsgradientoption = queuecardvisuals:CreateToggle({
		Name = 'Gradient',
		Function = function(calling)
			pcall(function() queuecardvisualscolor2.Object.Visible = calling end) 
		end
	});
	queuecardvisualsround = queuecardvisuals:CreateSlider({
		Name = 'Rounding',
		Min = 0,
		Max = 20,
		Default = 4,
		Function = function(value: number): ()
			for i: number, v: UICorner? in queuecardobjects do 
				if v.ClassName == 'UICorner' then 
					v.CornerRadius = value;
				end;
			end
		end
	})
	queuecardvisualscolor = queuecardvisuals:CreateColorSlider({
		Name = 'Color',
		Function = function()
			task.spawn(pcall, queuecardfunc)
		end
	});
	queuecardvisualscolor2 = queuecardvisuals:CreateColorSlider({
		Name = 'Color 2',
		Function = function()
			task.spawn(pcall, queuecardfunc)
		end
	});
	queuecardvisualhighlight = queuecardvisuals:CreateToggle({
		Name = 'Highlight',
		Function = function()
			task.spawn(pcall, queuecardfunc)
		end
	});
	queuecardmodshighlightcolor = queuecardvisuals:CreateColorSlider({
		Name = 'Highlight Color',
		Function = function()
			task.spawn(pcall, queuecardfunc)
		end;
	});
end);


run(function()
	local Atmosphere = {}
	local AtmosphereMethod = {Value = 'Custom'}
	local skythemeobjects = Performance.new();
	local SkyUp = {Value = ''};
	local SkyDown = {Value = ''};
	local SkyLeft = {Value = ''};
	local SkyRight = {Value = ''};
	local SkyFront = {Value = ''};
	local SkyBack = {Value = ''};
	local SkySun = {Value = ''};
	local SkyMoon = {Value = ''};
	local SkyColor = {Value = 1};
	local skyobj: Sky;
	local skyatmosphereobj;
	local oldtime;
	local oldobjects = {};
	local themetable = {
		Custom = function() 
			skyobj.SkyboxBk = tonumber(SkyBack.Value) and 'rbxassetid://'..SkyBack.Value or SkyBack.Value
			skyobj.SkyboxDn = tonumber(SkyDown.Value) and 'rbxassetid://'..SkyDown.Value or SkyDown.Value
			skyobj.SkyboxFt = tonumber(SkyFront.Value) and 'rbxassetid://'..SkyFront.Value or SkyFront.Value
			skyobj.SkyboxLf = tonumber(SkyLeft.Value) and 'rbxassetid://'..SkyLeft.Value or SkyLeft.Value
			skyobj.SkyboxRt = tonumber(SkyRight.Value) and 'rbxassetid://'..SkyRight.Value or SkyRight.Value
			skyobj.SkyboxUp = tonumber(SkyUp.Value) and 'rbxassetid://'..SkyUp.Value or SkyUp.Value
			skyobj.SunTextureId = tonumber(SkySun.Value) and 'rbxassetid://'..SkySun.Value or SkySun.Value
			skyobj.MoonTextureId = tonumber(SkyMoon.Value) and 'rbxassetid://'..SkyMoon.Value or SkyMoon.Value
		end,
		Purple = function()
            skyobj.SkyboxBk = 'rbxassetid://8539982183'
            skyobj.SkyboxDn = 'rbxassetid://8539981943'
            skyobj.SkyboxFt = 'rbxassetid://8539981721'
            skyobj.SkyboxLf = 'rbxassetid://8539981424'
            skyobj.SkyboxRt = 'rbxassetid://8539980766'
            skyobj.SkyboxUp = 'rbxassetid://8539981085'
			skyobj.MoonAngularSize = 0
            skyobj.SunAngularSize = 0
            skyobj.StarCount = 3e3
		end,
		Galaxy = function()
            skyobj.SkyboxBk = 'rbxassetid://159454299'
            skyobj.SkyboxDn = 'rbxassetid://159454296'
            skyobj.SkyboxFt = 'rbxassetid://159454293'
            skyobj.SkyboxLf = 'rbxassetid://159454293'
            skyobj.SkyboxRt = 'rbxassetid://159454293'
            skyobj.SkyboxUp = 'rbxassetid://159454288'
			skyobj.SunAngularSize = 0
		end,
		BetterNight = function()
			skyobj.SkyboxBk = 'rbxassetid://155629671'
            skyobj.SkyboxDn = 'rbxassetid://12064152'
            skyobj.SkyboxFt = 'rbxassetid://155629677'
            skyobj.SkyboxLf = 'rbxassetid://155629662'
            skyobj.SkyboxRt = 'rbxassetid://155629666'
            skyobj.SkyboxUp = 'rbxassetid://155629686'
			skyobj.SunAngularSize = 0
		end,
		BetterNight2 = function()
			skyobj.SkyboxBk = 'rbxassetid://248431616'
            skyobj.SkyboxDn = 'rbxassetid://248431677'
            skyobj.SkyboxFt = 'rbxassetid://248431598'
            skyobj.SkyboxLf = 'rbxassetid://248431686'
            skyobj.SkyboxRt = 'rbxassetid://248431611'
            skyobj.SkyboxUp = 'rbxassetid://248431605'
			skyobj.StarCount = 3e3
		end,
		MagentaOrange = function()
			skyobj.SkyboxBk = 'rbxassetid://566616113'
            skyobj.SkyboxDn = 'rbxassetid://566616232'
            skyobj.SkyboxFt = 'rbxassetid://566616141'
            skyobj.SkyboxLf = 'rbxassetid://566616044'
            skyobj.SkyboxRt = 'rbxassetid://566616082'
            skyobj.SkyboxUp = 'rbxassetid://566616187'
			skyobj.StarCount = 3e3
		end,
		Purple2 = function()
			skyobj.SkyboxBk = 'rbxassetid://8107841671'
			skyobj.SkyboxDn = 'rbxassetid://6444884785'
			skyobj.SkyboxFt = 'rbxassetid://8107841671'
			skyobj.SkyboxLf = 'rbxassetid://8107841671'
			skyobj.SkyboxRt = 'rbxassetid://8107841671'
			skyobj.SkyboxUp = 'rbxassetid://8107849791'
			skyobj.SunTextureId = 'rbxassetid://6196665106'
			skyobj.MoonTextureId = 'rbxassetid://6444320592'
			skyobj.MoonAngularSize = 0
		end,
		Galaxy2 = function()
			skyobj.SkyboxBk = 'rbxassetid://14164368678'
			skyobj.SkyboxDn = 'rbxassetid://14164386126'
			skyobj.SkyboxFt = 'rbxassetid://14164389230'
			skyobj.SkyboxLf = 'rbxassetid://14164398493'
			skyobj.SkyboxRt = 'rbxassetid://14164402782'
			skyobj.SkyboxUp = 'rbxassetid://14164405298'
			skyobj.SunTextureId = 'rbxassetid://8281961896'
			skyobj.MoonTextureId = 'rbxassetid://6444320592'
			skyobj.SunAngularSize = 0
			skyobj.MoonAngularSize = 0
		end,
	Pink = function()
		skyobj.SkyboxBk = 'rbxassetid://271042516'
		skyobj.SkyboxDn = 'rbxassetid://271077243'
		skyobj.SkyboxFt = 'rbxassetid://271042556'
		skyobj.SkyboxLf = 'rbxassetid://271042310'
		skyobj.SkyboxRt = 'rbxassetid://271042467'
		skyobj.SkyboxUp = 'rbxassetid://271077958'
	end,
	PurpleMountains = function() --
		skyobj.SkyboxBk = 'rbxassetid://17901353811';
		skyobj.SkyboxDn = 'rbxassetid://17901366771';
		skyobj.SkyboxFt = 'rbxassetid://17901356262';
		skyobj.SkyboxLf = 'rbxassetid://17901359687';
		skyobj.SkyboxRt = 'rbxassetid://17901362326';
		skyobj.SkyboxUp = 'rbxassetid://17901365106';
		skyobj.SunAngularSize = 0;
	end,
	AestheticMountains = function()
		skyobj.SkyboxBk = 'rbxassetid://15470198023';
		skyobj.SkyboxDn = 'rbxassetid://15470151245';
		skyobj.SkyboxFt = 'rbxassetid://15470200128';
		skyobj.SkyboxLf = 'rbxassetid://15470202648';
		skyobj.SkyboxRt = 'rbxassetid://15470204862';
		skyobj.SkyboxUp = 'rbxassetid://15470207755';
		skyobj.MoonAngularSize = 11;
		skyobj.SunAngularSize = 21;
	end,
	OverPlanet = function()
		skyobj.SkyboxBk = 'rbxassetid://165052268';
		skyobj.SkyboxDn = 'rbxassetid://165052286';
		skyobj.SkyboxFt = 'rbxassetid://165052328';
		skyobj.SkyboxLf = 'rbxassetid://165052365';
		skyobj.SkyboxRt = 'rbxassetid://165052306';
		skyobj.SkyboxUp = 'rbxassetid://165052345';
		skyobj.MoonAngularSize = 11;
		skyobj.SunAngularSize = 21;
		skyobj.StarCount = 3000;
	end,
	Beach = function()
		skyobj.SkyboxBk = 'rbxassetid://173380597';
		skyobj.SkyboxDn = 'rbxassetid://173380627';
		skyobj.SkyboxFt = 'rbxassetid://173380642';
		skyobj.SkyboxLf = 'rbxassetid://173380671';
		skyobj.SkyboxRt = 'rbxassetid://173380774';
		skyobj.SkyboxUp = 'rbxassetid://173380790';
		skyobj.MoonAngularSize = 11;
		skyobj.SunAngularSize = 21;
	end,
	RedNight = function()
		skyobj.SkyboxBk = 'rbxassetid://401664839';
		skyobj.SkyboxDn = 'rbxassetid://401664862';
		skyobj.SkyboxFt = 'rbxassetid://401664960';
		skyobj.SkyboxLf = 'rbxassetid://401664881';
		skyobj.SkyboxRt = 'rbxassetid://401664901';
		skyobj.SkyboxUp = 'rbxassetid://401664936';
		skyobj.SunAngularSize = 0;
	end,
	GreenHaze = function()
		skyobj.SkyboxBk = 'rbxassetid://160193404';
		skyobj.SkyboxDn = 'rbxassetid://160193466';
		skyobj.SkyboxFt = 'rbxassetid://160193461';
		skyobj.SkyboxLf = 'rbxassetid://160193469';
		skyobj.SkyboxRt = 'rbxassetid://160193463';
		skyobj.SkyboxUp = 'rbxassetid://160193458';
		skyobj.SunAngularSize = 0;
	end,
	Purple3 = function()
		skyobj.SkyboxBk = 'rbxassetid://433274085'
		skyobj.SkyboxDn = 'rbxassetid://433274194'
		skyobj.SkyboxFt = 'rbxassetid://433274131'
		skyobj.SkyboxLf = 'rbxassetid://433274370'
		skyobj.SkyboxRt = 'rbxassetid://433274429'
		skyobj.SkyboxUp = 'rbxassetid://433274285'
	end,
	DarkishPink = function()
		skyobj.SkyboxBk = 'rbxassetid://570555736'
		skyobj.SkyboxDn = 'rbxassetid://570555964'
		skyobj.SkyboxFt = 'rbxassetid://570555800'
		skyobj.SkyboxLf = 'rbxassetid://570555840'
		skyobj.SkyboxRt = 'rbxassetid://570555882'
		skyobj.SkyboxUp = 'rbxassetid://570555929'
	end,
	Space = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://166509999'
		skyobj.SkyboxDn = 'rbxassetid://166510057'
		skyobj.SkyboxFt = 'rbxassetid://166510116'
		skyobj.SkyboxLf = 'rbxassetid://166510092'
		skyobj.SkyboxRt = 'rbxassetid://166510131'
		skyobj.SkyboxUp = 'rbxassetid://166510114'
	end,
	Space2 = function()
		skyobj.SkyboxBk = 'rbxassetid://11844076072';
		skyobj.SkyboxDn = 'rbxassetid://11844069700';
		skyobj.SkyboxFt = 'rbxassetid://11844067209';
		skyobj.SkyboxLf = 'rbxassetid://11844063543';
		skyobj.SkyboxRt = 'rbxassetid://11844058446';
		skyobj.SkyboxUp = 'rbxassetid://11844053742';
		skyobj.MoonTextureId = 'rbxassetid://11844121592';
		skyobj.SunAngularSize = 11;
		skyobj.StarCount = 3e3;
		skyobj.MoonAngularSize = 20;
	end,
	Galaxy3 = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://14543264135'
		skyobj.SkyboxDn = 'rbxassetid://14543358958'
		skyobj.SkyboxFt = 'rbxassetid://14543257810'
		skyobj.SkyboxLf = 'rbxassetid://14543275895'
		skyobj.SkyboxRt = 'rbxassetid://14543280890'
		skyobj.SkyboxUp = 'rbxassetid://14543371676'
	end,
	NetherWorld = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://14365019002'
		skyobj.SkyboxDn = 'rbxassetid://14365023350'
		skyobj.SkyboxFt = 'rbxassetid://14365018399'
		skyobj.SkyboxLf = 'rbxassetid://14365018705'
		skyobj.SkyboxRt = 'rbxassetid://14365018143'
		skyobj.SkyboxUp = 'rbxassetid://14365019327'
	end,
	Nebula = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://5260808177'
		skyobj.SkyboxDn = 'rbxassetid://5260653793'
		skyobj.SkyboxFt = 'rbxassetid://5260817288'
		skyobj.SkyboxLf = 'rbxassetid://5260800833'
		skyobj.SkyboxRt = 'rbxassetid://5260811073'
		skyobj.SkyboxUp = 'rbxassetid://5260824661'
	end,
	PurpleSpace = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://15983968922'
		skyobj.SkyboxDn = 'rbxassetid://15983966825'
		skyobj.SkyboxFt = 'rbxassetid://15983965025'
		skyobj.SkyboxLf = 'rbxassetid://15983967420'
		skyobj.SkyboxRt = 'rbxassetid://15983966246'
		skyobj.SkyboxUp = 'rbxassetid://15983964246'
		skyobj.SkyboxFt = 'rbxassetid://5260817288'
		skyobj.StarCount = 3000
	end,
	PurpleNight = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://5260808177'
		skyobj.SkyboxDn = 'rbxassetid://5260653793'
		skyobj.SkyboxFt = 'rbxassetid://5260817288'
		skyobj.SkyboxLf = 'rbxassetid://5260800833'
		skyobj.SkyboxRt = 'rbxassetid://5260800833'
		skyobj.SkyboxUp = 'rbxassetid://5084576400'
	end,
	Aesthetic = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://1417494030'
		skyobj.SkyboxDn = 'rbxassetid://1417494146'
		skyobj.SkyboxFt = 'rbxassetid://1417494253'
		skyobj.SkyboxLf = 'rbxassetid://1417494402'
		skyobj.SkyboxRt = 'rbxassetid://1417494499'
		skyobj.SkyboxUp = 'rbxassetid://1417494643'
	end,
	Aesthetic2 = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://600830446'
		skyobj.SkyboxDn = 'rbxassetid://600831635'
		skyobj.SkyboxFt = 'rbxassetid://600832720'
		skyobj.SkyboxLf = 'rbxassetid://600886090'
		skyobj.SkyboxRt = 'rbxassetid://600833862'
		skyobj.SkyboxUp = 'rbxassetid://600835177'
	end,
	Pastel = function()
		skyobj.SunAngularSize = 0
		skyobj.MoonAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://2128458653'
		skyobj.SkyboxDn = 'rbxassetid://2128462480'
		skyobj.SkyboxFt = 'rbxassetid://2128458653'
		skyobj.SkyboxLf = 'rbxassetid://2128462027'
		skyobj.SkyboxRt = 'rbxassetid://2128462027'
		skyobj.SkyboxUp = 'rbxassetid://2128462236'
	end,
	PurpleClouds = function()
		skyobj.SkyboxBk = 'rbxassetid://570557514'
		skyobj.SkyboxDn = 'rbxassetid://570557775'
		skyobj.SkyboxFt = 'rbxassetid://570557559'
		skyobj.SkyboxLf = 'rbxassetid://570557620'
		skyobj.SkyboxRt = 'rbxassetid://570557672'
		skyobj.SkyboxUp = 'rbxassetid://570557727'
	end,
	BetterSky = function()
		if skyobj then
		skyobj.SkyboxBk = 'rbxassetid://591058823'
		skyobj.SkyboxDn = 'rbxassetid://591059876'
		skyobj.SkyboxFt = 'rbxassetid://591058104'
		skyobj.SkyboxLf = 'rbxassetid://591057861'
		skyobj.SkyboxRt = 'rbxassetid://591057625'
		skyobj.SkyboxUp = 'rbxassetid://591059642'
		end
	end,
	DarkClouds = function()
		skyobj.SkyboxBk = 'rbxassetid://190477248';
		skyobj.SkyboxDn = 'rbxassetid://190477222';
		skyobj.SkyboxFt = 'rbxassetid://190477200';
		skyobj.SkyboxLf = 'rbxassetid://190477185';
		skyobj.SkyboxRt = 'rbxassetid://190477166';
		skyobj.SkyboxUp = 'rbxassetid://190477146';
		skyobj.MoonAngularSize = 1.5;
		skyobj.StarCount = 0;
	end,
	Pinkie = function()
		skyobj.SkyboxBk = 'rbxassetid://11555017034';
		skyobj.SkyboxDn = 'rbxassetid://11555013415';
		skyobj.SkyboxFt = 'rbxassetid://11555010145';
		skyobj.SkyboxLf = 'rbxassetid://11555006545';
		skyobj.SkyboxRt = 'rbxassetid://11555000712';
		skyobj.SkyboxUp = 'rbxassetid://11554996247';
		skyobj.MoonAngularSize = 1.5;
		skyobj.StarCount = 0;
	end,
	Hell = function()
		skyobj.SkyboxBk = 'rbxassetid://11730840088';
		skyobj.SkyboxDn = 'rbxassetid://11730842997';
		skyobj.SkyboxFt = 'rbxassetid://11730849615';
		skyobj.SkyboxLf = 'rbxassetid://11730852920';
		skyobj.SkyboxRt = 'rbxassetid://11730855491';
		skyobj.SkyboxUp = 'rbxassetid://11730857150';
		skyobj.MoonAngularSize = 11;
		skyobj.StarCount = 3000;
	end,
	BetterNight3 = function()
		skyobj.MoonTextureId = 'rbxassetid://1075087760'
		skyobj.SkyboxBk = 'rbxassetid://2670643994'
		skyobj.SkyboxDn = 'rbxassetid://2670643365'
		skyobj.SkyboxFt = 'rbxassetid://2670643214'
		skyobj.SkyboxLf = 'rbxassetid://2670643070'
		skyobj.SkyboxRt = 'rbxassetid://2670644173'
		skyobj.SkyboxUp = 'rbxassetid://2670644331'
		skyobj.MoonAngularSize = 1.5
		skyobj.StarCount = 500
	end,
	Orange = function()
		skyobj.SkyboxBk = 'rbxassetid://150939022'
		skyobj.SkyboxDn = 'rbxassetid://150939038'
		skyobj.SkyboxFt = 'rbxassetid://150939047'
		skyobj.SkyboxLf = 'rbxassetid://150939056'
		skyobj.SkyboxRt = 'rbxassetid://150939063'
		skyobj.SkyboxUp = 'rbxassetid://150939082'
	end,
	DarkMountains = function()
		skyobj.SkyboxBk = 'rbxassetid://5098814730'
		skyobj.SkyboxDn = 'rbxassetid://5098815227'
		skyobj.SkyboxFt = 'rbxassetid://5098815653'
		skyobj.SkyboxLf = 'rbxassetid://5098816155'
		skyobj.SkyboxRt = 'rbxassetid://5098820352'
		skyobj.SkyboxUp = 'rbxassetid://5098819127'
	end,
	FlamingSunset = function()
		skyobj.SkyboxBk = 'rbxassetid://415688378'
		skyobj.SkyboxDn = 'rbxassetid://415688193'
		skyobj.SkyboxFt = 'rbxassetid://415688242'
		skyobj.SkyboxLf = 'rbxassetid://415688310'
		skyobj.SkyboxRt = 'rbxassetid://415688274'
		skyobj.SkyboxUp = 'rbxassetid://415688354'
	end,
	Nebula2 = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://16932794531'
		skyobj.SkyboxDn = 'rbxassetid://16932797813'
		skyobj.SkyboxFt = 'rbxassetid://16932800523'
		skyobj.SkyboxLf = 'rbxassetid://16932803722'
		skyobj.SkyboxRt = 'rbxassetid://16932806825'
		skyobj.SkyboxUp = 'rbxassetid://16932810138'
	end,
	Nebula3 = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://17839210699'
		skyobj.SkyboxDn = 'rbxassetid://17839215896'
		skyobj.SkyboxFt = 'rbxassetid://17839218166'
		skyobj.SkyboxLf = 'rbxassetid://17839220800'
		skyobj.SkyboxRt = 'rbxassetid://17839223605'
		skyobj.SkyboxUp = 'rbxassetid://17839226876'
	end,
	Nebula4 = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://17103618635'
		skyobj.SkyboxDn = 'rbxassetid://17103622190'
		skyobj.SkyboxFt = 'rbxassetid://17103624898'
		skyobj.SkyboxLf = 'rbxassetid://17103628153'
		skyobj.SkyboxRt = 'rbxassetid://17103636666'
		skyobj.SkyboxUp = 'rbxassetid://17103639457'
	end,
	NewYork = function()
		skyobj.SkyboxBk = 'rbxassetid://11333973069'
		skyobj.SkyboxDn = 'rbxassetid://11333969768'
		skyobj.SkyboxFt = 'rbxassetid://11333964303'
		skyobj.SkyboxLf = 'rbxassetid://11333971332'
		skyobj.SkyboxRt = 'rbxassetid://11333982864'
		skyobj.SkyboxUp = 'rbxassetid://11333967970'
		skyobj.SunAngularSize = 0
	end,
	Aesthetic3 = function()
		skyobj.SkyboxBk = 'rbxassetid://151165214'
		skyobj.SkyboxDn = 'rbxassetid://151165197'
		skyobj.SkyboxFt = 'rbxassetid://151165224'
		skyobj.SkyboxLf = 'rbxassetid://151165191'
		skyobj.SkyboxRt = 'rbxassetid://151165206'
		skyobj.SkyboxUp = 'rbxassetid://151165227'
	end,
	FakeClouds = function()
		skyobj.SkyboxBk = 'rbxassetid://8496892810'
		skyobj.SkyboxDn = 'rbxassetid://8496896250'
		skyobj.SkyboxFt = 'rbxassetid://8496892810'
		skyobj.SkyboxLf = 'rbxassetid://8496892810'
		skyobj.SkyboxRt = 'rbxassetid://8496892810'
		skyobj.SkyboxUp = 'rbxassetid://8496897504'
		skyobj.SunAngularSize = 0
	end,
	LunarNight = function()
		skyobj.SkyboxBk = 'rbxassetid://187713366'
		skyobj.SkyboxDn = 'rbxassetid://187712428'
		skyobj.SkyboxFt = 'rbxassetid://187712836'
		skyobj.SkyboxLf = 'rbxassetid://187713755'
		skyobj.SkyboxRt = 'rbxassetid://187714525'
		skyobj.SkyboxUp = 'rbxassetid://187712111'
		skyobj.SunAngularSize = 0
		skyobj.StarCount = 0
	end,
	FPSBoost = function()
		skyobj.SkyboxBk = 'rbxassetid://11457548274'
		skyobj.SkyboxDn = 'rbxassetid://11457548274'
		skyobj.SkyboxFt = 'rbxassetid://11457548274'
		skyobj.SkyboxLf = 'rbxassetid://11457548274'
		skyobj.SkyboxRt = 'rbxassetid://11457548274'
		skyobj.SkyboxUp = 'rbxassetid://11457548274'
		skyobj.SunAngularSize = 0
		skyobj.StarCount = 3000
	end,
	PurplePlanet = function()
		skyobj.SkyboxBk = 'rbxassetid://16262356578'
		skyobj.SkyboxDn = 'rbxassetid://16262358026'
		skyobj.SkyboxFt = 'rbxassetid://16262360469'
		skyobj.SkyboxLf = 'rbxassetid://16262362003'
		skyobj.SkyboxRt = 'rbxassetid://16262363873'
		skyobj.SkyboxUp = 'rbxassetid://16262366016'
		skyobj.SunAngularSize = 21
		skyobj.StarCount = 3000
	end,
	BluePlanet = function()
		skyobj.SkyboxBk = 'rbxassetid://16888989874';
		skyobj.SkyboxDn = 'rbxassetid://16888991855';
		skyobj.SkyboxFt = 'rbxassetid://16888995219';
		skyobj.SkyboxLf = 'rbxassetid://16888998994';
		skyobj.SkyboxRt = 'rbxassetid://16889000916';
		skyobj.SkyboxUp = 'rbxassetid://16889004122';
		skyobj.SunAngularSize = 21;
		skyobj.StarCount = 3000;
	end,
	Mountains = function()
		skyobj.SkyboxBk = 'rbxassetid://15359410490';
		skyobj.SkyboxDn = 'rbxassetid://15359411132';
		skyobj.SkyboxFt = 'rbxassetid://15359412131';
		skyobj.SkyboxLf = 'rbxassetid://15359411633';
		skyobj.SkyboxRt = 'rbxassetid://15359417656';
		skyobj.SkyboxUp = 'rbxassetid://15359412677';
		skyobj.SunAngularSize = 21;
		skyobj.StarCount = 3000;
	end,
	LunarNight2 = function()
		skyobj.SkyboxBk = 'rbxassetid://14365026085';
		skyobj.SkyboxDn = 'rbxassetid://14365026242';
		skyobj.SkyboxFt = 'rbxassetid://14365025735';
		skyobj.SkyboxLf = 'rbxassetid://14365025904';
		skyobj.SkyboxRt = 'rbxassetid://14365025444';
		skyobj.SkyboxUp = 'rbxassetid://14365026442';
		skyobj.SunAngularSize = 21;
		skyobj.StarCount = 3000;
	end,
	FunnyStorm = function()
		skyobj.SkyboxBk = 'rbxassetid://6280934001';
		skyobj.SkyboxDn = 'rbxassetid://6280935347';
		skyobj.SkyboxFt = 'rbxassetid://6280936575';
		skyobj.SkyboxLf = 'rbxassetid://6280938749';
		skyobj.SkyboxRt = 'rbxassetid://6280940989';
		skyobj.SkyboxUp = 'rbxassetid://6280942402';
		skyobj.SunAngularSize = 21;
		skyobj.StarCount = 3000;
	end,
	Flame = function()
		skyobj.SkyboxBk = 'rbxassetid://6286780109';
		skyobj.SkyboxDn = 'rbxassetid://6286782353';
		skyobj.SkyboxFt = 'rbxassetid://6286784186';
		skyobj.SkyboxLf = 'rbxassetid://6286785801';
		skyobj.SkyboxRt = 'rbxassetid://6286788245';
		skyobj.SkyboxUp = 'rbxassetid://6286790025';
		skyobj.SunAngularSize = 21;
		skyobj.StarCount = 3000;
	end,
	BlueSpace = function()
		skyobj.SkyboxBk = 'rbxassetid://16876541778';
		skyobj.SkyboxDn = 'rbxassetid://16876543880';
		skyobj.SkyboxFt = 'rbxassetid://16876546384';
		skyobj.SkyboxLf = 'rbxassetid://16876548320';
		skyobj.SkyboxRt = 'rbxassetid://16876550345';
		skyobj.SkyboxUp = 'rbxassetid://16876552681';
		skyobj.SunAngularSize = 21;
		skyobj.StarCount = 3000;
	end
}

Atmosphere = vape.Categories.Modules:CreateModule({
		Name = 'Atmosphere',
		ExtraText = function()
			return AtmosphereMethod.Value ~= 'Custom' and AtmosphereMethod.Value or ''
		end,
		Function = function(callback)
			if callback then 
				pcall(function()
					for i,v in (lightingService:GetChildren()) do 
						if v:IsA('PostEffect') or v:IsA('Sky') then 
							table.insert(oldobjects, v)
							v.Parent = game
						end
					end
				end)
				skyobj = Instance.new('Sky')
				skyobj.Parent = lightingService
				skyatmosphereobj = Instance.new('ColorCorrectionEffect')
			    skyatmosphereobj.TintColor = Color3.fromHSV(SkyColor.Hue, SkyColor.Sat, SkyColor.Value)
			    skyatmosphereobj.Parent = lightingService
				task.spawn(themetable[AtmosphereMethod.Value]);
				table.insert(Atmosphere.Connections, lightingService.ChildAdded:Connect(function(object: Sky?)
					if object.ClassName == 'Sky' then 
						skyobj:Destroy();
						skyobj = Instance.new('Sky', lightingService);
						task.spawn(themetable[AtmosphereMethod.Value])
					end
				end));
				table.insert(Atmosphere.Connections, lightingService.ChildRemoved:Connect(function(object: Sky?)
					if object.ClassName == 'Sky' then 
						skyobj:Destroy();
						skyobj = Instance.new('Sky', lightingService);
						task.spawn(themetable[AtmosphereMethod.Value])
					end
				end));
			else
				if skyobj then skyobj:Destroy() end
				if skyatmosphereobj then skyatmosphereobj:Destroy() end
				for i,v in (oldobjects) do 
					v.Parent = lightingService
				end
				if oldtime then 
					lightingService.TimeOfDay = oldtime
					oldtime = nil
				end
				table.clear(oldobjects)
			end
		end
	})
	local themetab = {'Custom'}
	for i,v in themetable do 
		table.insert(themetab, i)
	end
	AtmosphereMethod = Atmosphere:CreateDropdown({
		Name = 'Mode',
		List = themetab,
		Function = function(val)
			task.spawn(function()
			if Atmosphere.Enabled then 
				Atmosphere:Toggle()
				if val == 'Custom' then task.wait() end
				Atmosphere:Toggle()
			end
			for i,v in skythemeobjects do 
				v.Object.Visible = AtmosphereMethod.Value == 'Custom'
			end
		    end)
		end
	})
	SkyUp = Atmosphere:CreateTextBox({
		Name = 'SkyUp',
		TempText = 'Sky Top ID',
		FocusLost = function(enter) 
			Atmosphere:Toggle()
		end
	})
	SkyDown = Atmosphere:CreateTextBox({
		Name = 'SkyDown',
		TempText = 'Sky Bottom ID',
		FocusLost = function(enter) 
			Atmosphere:Toggle()
		end
	})
	SkyLeft = Atmosphere:CreateTextBox({
		Name = 'SkyLeft',
		TempText = 'Sky Left ID',
		FocusLost = function(enter) 
			Atmosphere:Toggle()
		end
	})
	SkyRight = Atmosphere:CreateTextBox({
		Name = 'SkyRight',
		TempText = 'Sky Right ID',
		FocusLost = function(enter) 
			Atmosphere:Toggle()
		end
	})
	SkyFront = Atmosphere:CreateTextBox({
		Name = 'SkyFront',
		TempText = 'Sky Front ID',
		FocusLost = function(enter) 
			Atmosphere:Toggle()
		end
	})
	SkyBack = Atmosphere:CreateTextBox({
		Name = 'SkyBack',
		TempText = 'Sky Back ID',
		FocusLost = function(enter) 
			Atmosphere:Toggle()
		end
	})
	SkySun = Atmosphere:CreateTextBox({
		Name = 'SkySun',
		TempText = 'Sky Sun ID',
		FocusLost = function(enter) 
			Atmosphere:Toggle()
		end
	})
	SkyMoon = Atmosphere:CreateTextBox({
		Name = 'SkyMoon',
		TempText = 'Sky Moon ID',
		FocusLost = function(enter) 
			Atmosphere:Toggle()
		end
	})
	SkyColor = Atmosphere:CreateColorSlider({
		Name = 'Color',
		Function = function(h, s, v)
			if skyatmosphereobj then 
				skyatmosphereobj.TintColor = Color3.fromHSV(SkyColor.Hue, SkyColor.Sat, SkyColor.Value)
			end
		end
	})
	table.insert(skythemeobjects, SkyUp)
	table.insert(skythemeobjects, SkyDown)
	table.insert(skythemeobjects, SkyLeft)
	table.insert(skythemeobjects, SkyRight)
	table.insert(skythemeobjects, SkyFront)
	table.insert(skythemeobjects, SkyBack)
	table.insert(skythemeobjects, SkySun)
	table.insert(skythemeobjects, SkyMoon)
end)

run(function() -- pasted from old render once again
	local HotbarVisuals: vapemodule = {};
	local HotbarRounding: vapeminimodule = {};
	local HotbarHighlight: vapeminimodule = {};
	local HotbarColorToggle: vapeminimodule = {};
	local HotbarHideSlotIcons: vapeminimodule = {};
	local HotbarSlotNumberColorToggle: vapemodule = {};
	local HotbarSpacing: vapeslider = {Value = 0};
	local HotbarInvisibility: vapeslider = {Value = 4};
	local HotbarRoundRadius: vapeslider = {Value = 3};
	local HotbarAnimations: vapeminimodule = {};
	local HotbarColor: vapeminimodule = {};
	local HotbarHighlightColor: vapeminimodule = {};
	local HotbarSlotNumberColor: vapeminimodule = {};
	local hotbarcoloricons: securetable = Performance.new();
	local hotbarsloticons: securetable = Performance.new();
	local hotbarobjects: securetable = Performance.new();
	local HotbarVisualsGradient: vapeminimodule = {};
	local hotbarslotgradients: securetable = Performance.new();
	local HotbarMinimumRotation: vapeslider = {Value = 0};
	local HotbarMaximumRotation: vapeslider = {Value = 60};
	local HotbarAnimationSpeed: vapeslider = {Value = 8};
	local HotbarVisualsHighlightSize: vapeslider = {Value = 0};
	local HotbarVisualsGradientColor: vapecolorslider = {};
	local HotbarVisualsGradientColor2: vapecolorslider = {};
	local HotbarAnimationThreads: securetable = Performance.new();
	local inventoryiconobj;
	local hotbarFunction = function()
		local inventoryicons = ({pcall(function() return lplr.PlayerGui.hotbar['1'].ItemsHotbar end)})[2]
		if inventoryicons and type(inventoryicons) == 'userdata' then
			inventoryiconobj = inventoryicons;
			pcall(function() inventoryicons:FindFirstChildOfClass('UIListLayout').Padding = UDim.new(0, HotbarSpacing.Value) end);
			for i,v in inventoryicons:GetChildren() do 
				local sloticon = ({pcall(function() return v:FindFirstChildWhichIsA('ImageButton'):FindFirstChildWhichIsA('TextLabel') end)})[2]
				if type(sloticon) ~= 'userdata' then 
					continue
				end
				table.insert(hotbarcoloricons, sloticon.Parent);
				sloticon.Parent.Transparency = (0.1 * HotbarInvisibility.Value);
				if HotbarColorToggle.Enabled and not HotbarVisualsGradient.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value)
				end
				local gradient;
				if HotbarVisualsGradient.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					if sloticon.Parent:FindFirstChildWhichIsA('UIGradient') == nil then 
						gradient = Instance.new('UIGradient') 
						local color = Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)
						local color2 = Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value)
						gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color2)})
						gradient.Parent = sloticon.Parent
						table.insert(hotbarslotgradients, gradient)
						table.insert(hotbarcoloricons, sloticon.Parent) 
					end;
					if gradient then 
						HotbarAnimationThreads[gradient] = task.spawn(function()
							repeat
								task.wait();
								if not HotbarAnimations.Enabled then 
									continue;
								end;
								local integers: table = {
									[1] = HotbarMinimumRotation.Value + math.random(1, 15),
									[2] = HotbarMaximumRotation.Value - math.random(1, 14)
								};
								for i: number, v: number in integers do 
									local rotationtween: Tween = tweenService:Create(gradient, TweenInfo.new(0.1 * HotbarAnimationSpeed.Value), {Rotation = v});
									rotationtween:Play();
									rotationtween.Completed:Wait();
									task.wait(0.3);
								end;
							until (not HotbarVisuals.Enabled)
						end);
					end;
				end
				if HotbarRounding.Enabled then 
					local uicorner = Instance.new('UICorner')
					uicorner.Parent = sloticon.Parent
					uicorner.CornerRadius = UDim.new(0, HotbarRoundRadius.Value)
					table.insert(hotbarobjects, uicorner)
				end
				if HotbarHighlight.Enabled then
					local highlight = Instance.new('UIStroke')
					highlight.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value)
					highlight.Thickness = 1.3 + (0.1 * HotbarVisualsHighlightSize.Value);
					highlight.Parent = sloticon.Parent
					table.insert(hotbarobjects, highlight)
				end
				if HotbarHideSlotIcons.Enabled then 
					sloticon.Visible = false 
				end
				table.insert(hotbarsloticons, sloticon)
			end 
		end
	end
	HotbarVisuals = vape.Categories.Modules:CreateModule({
		Name = 'HotbarVisuals',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(HotbarVisuals.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'hotbar' then
							hotbarFunction()
						end
					end))
					hotbarFunction()
				end)
				table.insert(HotbarVisuals.Connections, runService.RenderStepped:Connect(function()
					for i,v in hotbarcoloricons do 
						pcall(function() v.Transparency = (0.1 * HotbarInvisibility.Value) end); 
					end	
				end))
			else
				HotbarAnimationThreads:clear(task.cancel);
				for i,v in hotbarsloticons do 
					pcall(function() v.Visible = true end)
				end
				for i,v in hotbarcoloricons do 
					pcall(function() v.BackgroundColor3 = Color3.fromRGB(29, 36, 46) end)
				end
				for i,v in hotbarobjects do
					pcall(function() v:Destroy() end)
				end
				for i,v in hotbarslotgradients do 
					pcall(function() v:Destroy() end)
				end
				table.clear(hotbarobjects)
				table.clear(hotbarsloticons)
				table.clear(hotbarcoloricons)
			end
		end
	})
	HotbarColorToggle = HotbarVisuals:CreateToggle({
		Name = 'Slot Color',
		Function = function(calling)
			pcall(function() HotbarColor.Object.Visible = calling end)
			pcall(function() HotbarColorToggle.Object.Visible = calling end)
			if HotbarVisuals.Enabled then 
				HotbarVisuals:Toggle()
				HotbarVisuals:Toggle()
			end
		end
	})
	HotbarVisualsGradient = HotbarVisuals:CreateToggle({
		Name = 'Gradient Slot Color',
		Function = function(calling)
			pcall(function() HotbarVisualsGradientColor.Object.Visible = calling end)
			pcall(function() HotbarVisualsGradientColor2.Object.Visible = calling end)
			HotbarMinimumRotation.Object.Visible = calling and HotbarAnimations.Enabled;
			HotbarMaximumRotation.Object.Visible = calling and HotbarAnimations.Enabled;
			HotbarAnimationSpeed.Object.Visible = calling and HotbarAnimations.Enabled;
			if HotbarVisuals.Enabled then 
				HotbarVisuals:Toggle()
				HotbarVisuals:Toggle()
			end
		end
	})
	HotbarVisualsGradientColor = HotbarVisuals:CreateColorSlider({
		Name = 'Gradient Color',
		Function = function(h, s, v)
			for i,v in hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value))}) end)
			end
		end
	});
	HotbarAnimations = HotbarVisuals:CreateToggle({
		Name = 'Animations',
		HoverText = 'Animates hotbar gradient rotation.',
		Function = function(calling: boolean)
			HotbarMinimumRotation.Object.Visible = calling;
			HotbarMaximumRotation.Object.Visible = calling;
			HotbarAnimationSpeed.Object.Visible = calling;
		end
	});
	HotbarVisualsGradientColor2 = HotbarVisuals:CreateColorSlider({
		Name = 'Gradient Color 2',
		Function = function(h, s, v)
			for i,v in hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value))}) end)
			end
		end
	});
	HotbarMinimumRotation = HotbarVisuals:CreateSlider({
		Name = 'Minimum',
		Min = 0,
		Max = 75,
		Function = function(...) end
	});
	HotbarMaximumRotation = HotbarVisuals:CreateSlider({
		Name = 'Maximum',
		Min = 10,
		Max = 100,
		Function = function(...) end
	});
	HotbarAnimationSpeed = HotbarVisuals:CreateSlider({
		Name = 'Speed',
		Min = 0,
		Max = 15,
		Default = 8,
		Function = function(...) end
	});
	HotbarColor = HotbarVisuals:CreateColorSlider({
		Name = 'Slot Color',
		Function = function(h, s, v)
			for i,v in hotbarcoloricons do
				if HotbarColorToggle.Enabled then
					pcall(function() v.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value) end) -- for some reason the 'h, s, v' didn't work :(
				end
			end
		end
	})
	HotbarRounding = HotbarVisuals:CreateToggle({
		Name = 'Rounding',
		Function = function(calling)
			pcall(function() HotbarRoundRadius.Object.Visible = calling end)
			if HotbarVisuals.Enabled then 
				HotbarVisuals:Toggle()
				HotbarVisuals:Toggle()
			end
		end
	})
	HotbarRoundRadius = HotbarVisuals:CreateSlider({
		Name = 'Corner Radius',
		Min = 1,
		Max = 20,
		Function = function(calling)
			for i,v in hotbarobjects do 
				pcall(function() v.CornerRadius = UDim.new(0, calling) end)
			end
		end
	});
	HotbarHighlight = HotbarVisuals:CreateToggle({
		Name = 'Outline Highlight',
		Function = function(calling)
			pcall(function() HotbarHighlightColor.Object.Visible = calling end)
			pcall(function() HotbarVisualsHighlightSize.Object.Visible = calling end);
			if HotbarVisuals.Enabled then 
				HotbarVisuals:Toggle()
				HotbarVisuals:Toggle()
			end
		end
	})
	HotbarHighlightColor = HotbarVisuals:CreateColorSlider({
		Name = 'Highlight Color',
		Function = function(h, s, v)
			for i,v in hotbarobjects do 
				if v:IsA('UIStroke') and HotbarHighlight.Enabled then 
					pcall(function() v.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value) end)
				end
			end
		end
	});
	HotbarVisualsHighlightSize = HotbarVisuals:CreateSlider({
		Name = 'Highlight Size',
		Min = 0,
		Max = 8,
		Function = function(value: number)
			for i: number, v: UIStroke? in hotbarobjects do 
				if v.ClassName == 'UIStroke' and HotbarHighlight.Enabled then 
					pcall(function() v.Thickness = 1.3 + (0.1 * value) end)
				end
			end
		end
	});
	HotbarHideSlotIcons = HotbarVisuals:CreateToggle({
		Name = 'No Slot Numbers',
		Function = function()
			if HotbarVisuals.Enabled then 
				HotbarVisuals:Toggle()
				HotbarVisuals:Toggle()
			end
		end
	})
	HotbarInvisibility = HotbarVisuals:CreateSlider({
		Name = 'Invisibility',
		Min = 0,
		Max = 10,
		Default = 4,
		Function = function(value)
			for i,v in hotbarcoloricons do 
				pcall(function() v.Transparency = (0.1 * value) end); 
			end
		end
	})
	HotbarSpacing = HotbarVisuals:CreateSlider({
		Name = 'Spacing',
		Min = 0,
		Max = 5,
		Function = function(value)
			if HotbarVisuals.Enabled then 
				pcall(function() inventoryiconobj:FindFirstChildOfClass('UIListLayout').Padding = UDim.new(0, value) end)
			end
		end
	});

	HotbarAnimationThreads.oncleanevent:Connect(task.cancel);
	HotbarColor.Object.Visible = false;
	HotbarRoundRadius.Object.Visible = false;
	HotbarHighlightColor.Object.Visible = false;
	HotbarMinimumRotation.Object.Visible = false;
	HotbarMaximumRotation.Object.Visible = false;
	HotbarAnimationSpeed.Object.Visible = false;
end);


run(function()
	local BlockIn
	
	local function getBedNear()
		local localPosition = entitylib.isAlive and entitylib.character.RootPart.Position or Vector3.zero
		for _, v in collectionService:GetTagged('bed') do
			if (localPosition - v.Position).Magnitude < 20 and v:GetAttribute('Team'..(lplr:GetAttribute('Team') or -1)..'NoBreak') then
				return v
			end
		end
	end
	
	local function getBlocks()
		local blocks = {}
		for _, item in store.inventory.inventory.items do
			local block = bedwars.ItemMeta[item.itemType].block
			if block then
				table.insert(blocks, {item.itemType, block.health})
			end
		end
		table.sort(blocks, function(a, b) 
			return a[2] < b[2]
		end)
		return blocks
	end
	
	local function getPyramid(size, grid)
		return {
			Vector3.new(3, 0, 0);
			Vector3.new(0, 0, 3);
			Vector3.new(-3, 0, 0);
			Vector3.new(0, 0, -3);
			Vector3.new(3, 3, 0);
			Vector3.new(0, 3, 3);
			Vector3.new(-3, 3, 0);
			Vector3.new(0, 3, -3);
			Vector3.new(0, 6, 0);
		}
	end
	
	BlockIn = vape.Categories.Modules:CreateModule({
		Name = 'BlockIn',
		Function = function(callback)
			if callback then
				me = entitylib.isAlive and entitylib.character.RootPart.Position or nil
				if me then
					for i, block in getBlocks() do
						for _, pos in getPyramid(i, 3) do
							if not BlockIn.Enabled then break end
							if getPlacedBlock(me + pos) then continue end
							bedwars.placeBlock(me + pos, block[1], false)
						end
					end
					if BlockIn.Enabled then 
						BlockIn:Toggle() 
					end
				else
					notif('BlockIn', 'Unable to locate me', 5)
					BlockIn:Toggle()
				end
			end
		end,
		Tooltip = 'Automatically places strong blocks around the me.'
	})
end)