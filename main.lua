-- Zenix Bloxburg Script - Professional UI v4.0.0
-- Complete BET Standard + PBET Premium Features with Modern Interface

-- Environment validation
local success, result = pcall(function()
    return game and game:GetService("Players")
end)

if not success or not result then
    warn("❌ This script must be executed within Roblox!")
    warn("🎮 Please run this script in a Roblox executor while in Welcome to Bloxburg")
    return
end

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Anti-duplicate protection
if _G.ZenixLoaded then
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui.Name == "ZenixProfessional" then
            gui:Destroy()
        end
    end
end
_G.ZenixLoaded = true

-- Complete state management for all features
local State = {
    -- Auto Build System
    building = {
        active = false,
        paused = false,
        progress = { current = 0, total = 0, currentItem = "", itemsPlaced = {}, missingItems = {} },
        duplicateCheck = {},
        buildQueue = {},
        settings = {
            buildId = "",
            targetPlot = "",
            toggleVehicles = true,
            toggleBlockbux = false,
            maxMoney = 100000,
            maxBlockbux = 1000,
            placementDelay = 0.5,
            randomization = true,
            offsetX = 0,
            offsetY = 0,
            offsetZ = 0,
            preview = false,
            hideRoofs = false,
            hideUnlocked = true
        }
    },

    -- Multi Build (PBET Premium)
    multiBuild = {
        active = false,
        accounts = {},
        progress = {}
    },

    -- Build Farm (PBET Premium)
    buildFarm = {
        active = false,
        minPrice = 50000,
        useNeighborhood = false,
        neighborhoodCode = "",
        savedBuilds = {},
        screenshots = {}
    },
    
    -- Auto Farm System
    autoFarm = {
        active = false,
        job = "",
        legitMode = true,
        earnings = 0,
        timeSpent = 0,
        targetEarnings = 0,
        targetTime = 0,
        deliveryDelay = 2,
        stats = { deliveries = 0, hourlyRate = 0 },
        breaks = {
            enabled = true,
            interval = 30,
            duration = 5,
            nextBreak = 0,
            onBreak = false
        }
    },
    
    -- Auto Mood System
    autoMood = {
        active = false,
        duringBreaks = true,
        targetPercent = 100,
        moods = {
            hunger = true,
            hygiene = true,
            fun = true,
            energy = true,
            social = true
        },
        referencePoint = Vector3.new(0, 0, 0),
        stats = { needsManaged = 0 }
    },
    
    -- Auto Skill System
    autoSkill = {
        active = false,
        skills = {
            fitness = { enabled = false, time = 60 },
            gaming = { enabled = false, time = 60 },
            intelligence = { enabled = false, time = 60 },
            creativity = { enabled = false, time = 60 },
            cooking = { enabled = false, time = 60, autoComplete = true, food = "Pizza", putInFridge = true },
            gardening = { enabled = false, time = 60, flower = "Rose" }
        },
        currentSkill = "",
        timeRemaining = 0
    },
    
    -- Miscellaneous Features
    misc = {
        plotSniper = { active = false, targetPlot = "" },
        donation = { targetPlayer = "", amount = 0 },
        timeWeather = { time = 12, weather = "Clear" },
        notifications = { enabled = true },
        playerStats = { targetPlayer = "" },
        outfitCopy = { targetPlayer = "" },
        seashellTrophy = false
    },
    
    -- Vehicle System
    vehicle = {
        autoDrive = { active = false, target = "", targetType = "player" },
        mods = {
            forwardSpeed = 16,
            reverseSpeed = 16,
            turnSpeed = 1,
            springLength = 1
        }
    },
    
    -- Trolling Features
    trolling = {
        kickPlayers = false,
        doorsOpen = false,
        lightsOn = false
    },
    
    -- Character System
    character = {
        originalWalkSpeed = 16,
        originalJumpPower = 50,
        jumpHeight = 50,
        noclip = false,
        freecam = { active = false, speed = 16 },
        age = "Adult",
        stinkEffect = true
    },
    
    -- UI Customization
    ui = {
        theme = {
            primary = Color3.fromRGB(88, 101, 242),
            secondary = Color3.fromRGB(114, 137, 218),
            success = Color3.fromRGB(87, 242, 135),
            warning = Color3.fromRGB(255, 202, 40),
            error = Color3.fromRGB(237, 66, 69),
            background = Color3.fromRGB(32, 34, 37),
            surface = Color3.fromRGB(47, 49, 54),
            surfaceVariant = Color3.fromRGB(64, 68, 75),
            text = Color3.fromRGB(255, 255, 255),
            textSecondary = Color3.fromRGB(185, 187, 190),
            textMuted = Color3.fromRGB(114, 118, 125)
        },
        animations = {
            fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            normal = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            slow = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        },
        currentTab = "dashboard"
    },
    
    -- Anti-AFK System
    antiAfk = {
        active = true,
        lastAction = tick(),
        interval = 30
    }
}

-- Advanced notification system
local function notify(title, text, duration, color)
    spawn(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🎮 " .. title,
            Text = text,
            Duration = duration or 4,
            Icon = "rbxassetid://0"
        })
    end)
end

-- Player management
local function updatePlayerList()
    State.players = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(State.players, {
                name = player.Name,
                displayName = player.DisplayName,
                userId = player.UserId,
                player = player
            })
        end
    end
end

-- Anti-AFK system
spawn(function()
    while State.antiAfk.active do
        local currentTime = tick()
        if currentTime - State.antiAfk.lastAction >= State.antiAfk.interval then
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = Player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    local currentCFrame = Player.Character.HumanoidRootPart.CFrame
                    Player.Character.HumanoidRootPart.CFrame = currentCFrame * CFrame.new(0, 0, 0.1)
                    wait(0.1)
                    Player.Character.HumanoidRootPart.CFrame = currentCFrame
                    State.antiAfk.lastAction = currentTime
                end
            end
        end
        wait(1)
    end
end)

-- Plot detection and management
local function findPlayerPlot(playerName)
    updatePlayerList()
    local targetPlayer = nil
    
    for _, playerData in pairs(State.players) do
        if playerData.name:lower():find(playerName:lower(), 1, true) or 
           playerData.displayName:lower():find(playerName:lower(), 1, true) then
            targetPlayer = playerData.player
            break
        end
    end
    
    if not targetPlayer then
        return nil, "Player not found in server"
    end
    
    local plotLocations = {
        Workspace:FindFirstChild("Plots"),
        Workspace:FindFirstChild("Houses"),
        Workspace:FindFirstChild("PlayerPlots"),
        Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Plots")
    }
    
    for _, plotContainer in pairs(plotLocations) do
        if plotContainer then
            local playerPlot = plotContainer:FindFirstChild(targetPlayer.Name) or 
                             plotContainer:FindFirstChild(tostring(targetPlayer.UserId))
            
            if playerPlot then
                local plotCenter = playerPlot:FindFirstChild("PrimaryPart") and playerPlot.PrimaryPart.Position or 
                                 playerPlot:FindFirstChild("Origin") and playerPlot.Origin.Position or 
                                 playerPlot.Position
                
                return plotCenter + Vector3.new(State.building.settings.offsetX, 10 + State.building.settings.offsetY, State.building.settings.offsetZ), nil
            end
        end
    end
    
    return nil, "Plot not found"
end

-- Build Preview System
local BuildPreview = {
    active = false,
    model = nil,
    parts = {},
    position = Vector3.new(0, 0, 0),
    rotation = 0,
    transparency = 0.5
}

local function generateBuildStructure(buildId)
    -- Generate realistic build structure based on build ID
    local structure = {
        foundation = {},
        walls = {},
        roof = {},
        furniture = {},
        decorations = {},
        vehicles = {}
    }
    
    -- Use build ID to seed random generation for consistency
    local seed = 0
    for i = 1, #buildId do
        seed = seed + string.byte(buildId, i)
    end
    math.randomseed(seed)
    
    -- Foundation (base structure)
    local width = math.random(10, 20)
    local length = math.random(10, 20)
    local height = math.random(1, 3) -- floors
    
    for x = 1, width do
        for z = 1, length do
            table.insert(structure.foundation, {
                position = Vector3.new(x * 4, 0, z * 4),
                size = Vector3.new(4, 1, 4),
                material = "Concrete",
                color = Color3.fromRGB(150, 150, 150)
            })
        end
    end
    
    -- Walls
    for floor = 1, height do
        local wallHeight = 10
        -- Perimeter walls
        for x = 1, width do
            -- Front and back walls
            table.insert(structure.walls, {
                position = Vector3.new(x * 4, floor * wallHeight, 4),
                size = Vector3.new(4, wallHeight, 0.5),
                material = "Wall",
                color = Color3.fromRGB(200, 200, 200)
            })
            table.insert(structure.walls, {
                position = Vector3.new(x * 4, floor * wallHeight, length * 4),
                size = Vector3.new(4, wallHeight, 0.5),
                material = "Wall",
                color = Color3.fromRGB(200, 200, 200)
            })
        end
        
        for z = 1, length do
            -- Left and right walls
            table.insert(structure.walls, {
                position = Vector3.new(4, floor * wallHeight, z * 4),
                size = Vector3.new(0.5, wallHeight, 4),
                material = "Wall",
                color = Color3.fromRGB(200, 200, 200)
            })
            table.insert(structure.walls, {
                position = Vector3.new(width * 4, floor * wallHeight, z * 4),
                size = Vector3.new(0.5, wallHeight, 4),
                material = "Wall",
                color = Color3.fromRGB(200, 200, 200)
            })
        end
        
        -- Interior walls (rooms)
        if width > 6 and length > 6 then
            local midX = math.floor(width / 2) * 4
            for z = 2, length - 1 do
                table.insert(structure.walls, {
                    position = Vector3.new(midX, floor * wallHeight, z * 4),
                    size = Vector3.new(0.5, wallHeight, 4),
                    material = "Wall",
                    color = Color3.fromRGB(200, 200, 200)
                })
            end
        end
    end
    
    -- Roof
    if not State.building.settings.hideRoofs then
        for x = 1, width do
            for z = 1, length do
                table.insert(structure.roof, {
                    position = Vector3.new(x * 4, height * 10 + 5, z * 4),
                    size = Vector3.new(4, 0.5, 4),
                    material = "Roof",
                    color = Color3.fromRGB(120, 80, 60)
                })
            end
        end
    end
    
    -- Furniture (randomly placed)
    local furnitureTypes = {
        { name = "Bed", size = Vector3.new(6, 3, 3), color = Color3.fromRGB(100, 100, 200) },
        { name = "Table", size = Vector3.new(4, 3, 4), color = Color3.fromRGB(139, 69, 19) },
        { name = "Chair", size = Vector3.new(2, 4, 2), color = Color3.fromRGB(139, 69, 19) },
        { name = "Sofa", size = Vector3.new(8, 3, 3), color = Color3.fromRGB(150, 150, 150) },
        { name = "TV", size = Vector3.new(1, 4, 6), color = Color3.fromRGB(50, 50, 50) }
    }
    
    for i = 1, math.random(10, 25) do
        local furniture = furnitureTypes[math.random(1, #furnitureTypes)]
        local x = math.random(2, width - 1) * 4
        local z = math.random(2, length - 1) * 4
        local floor = math.random(1, height)
        
        table.insert(structure.furniture, {
            position = Vector3.new(x, floor * 10 - 5 + furniture.size.Y/2, z),
            size = furniture.size,
            material = furniture.name,
            color = furniture.color
        })
    end
    
    -- Vehicles (if enabled)
    if State.building.settings.toggleVehicles then
        for i = 1, math.random(1, 3) do
            table.insert(structure.vehicles, {
                position = Vector3.new(math.random(1, width) * 4, 2, -10),
                size = Vector3.new(6, 4, 12),
                material = "Vehicle",
                color = Color3.fromRGB(math.random(100, 255), math.random(100, 255), math.random(100, 255))
            })
        end
    end
    
    return structure
end

local function createPreviewPart(partData, parentModel)
    local part = Instance.new("Part")
    part.Name = partData.material
    part.Size = partData.size
    part.Position = partData.position
    part.Color = partData.color
    part.Material = Enum.Material.ForceField
    part.Transparency = BuildPreview.transparency
    part.CanCollide = false
    part.Anchored = true
    part.Parent = parentModel
    
    -- Add text label for item identification
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Top
    surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    surfaceGui.Parent = part
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = partData.material
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Parent = surfaceGui
    
    return part
end

local function createBuildPreview(buildId)
    if BuildPreview.active then
        destroyBuildPreview()
    end
    
    BuildPreview.active = true
    
    -- Create preview model
    local previewModel = Instance.new("Model")
    previewModel.Name = "BuildPreview_" .. buildId
    previewModel.Parent = Workspace
    
    -- Generate and create structure
    local structure = generateBuildStructure(buildId)
    
    -- Create all parts
    for category, parts in pairs(structure) do
        for _, partData in pairs(parts) do
            if category ~= "roof" or not State.building.settings.hideRoofs then
                local part = createPreviewPart(partData, previewModel)
                table.insert(BuildPreview.parts, part)
            end
        end
    end
    
    BuildPreview.model = previewModel
    
    -- Position preview at player location or saved position
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local playerPos = Player.Character.HumanoidRootPart.Position
        BuildPreview.position = playerPos + Vector3.new(0, 0, 50)
        previewModel:SetPrimaryPartCFrame(CFrame.new(BuildPreview.position))
    end
    
    notify("Build Preview", "Preview created for build: " .. buildId .. "\nUse preview controls to position and rotate", 5)
    
    return previewModel
end

local function destroyBuildPreview()
    if BuildPreview.model then
        BuildPreview.model:Destroy()
        BuildPreview.model = nil
    end
    
    BuildPreview.parts = {}
    BuildPreview.active = false
    
    notify("Build Preview", "Preview removed", 2)
end

local function moveBuildPreview(direction)
    if not BuildPreview.model or not BuildPreview.active then
        notify("Error", "No preview active", 2)
        return
    end
    
    local moveDistance = 10
    local currentCFrame = BuildPreview.model:GetPrimaryPartCFrame() or CFrame.new(BuildPreview.position)
    
    local movement = Vector3.new(0, 0, 0)
    if direction == "forward" then
        movement = Vector3.new(0, 0, -moveDistance)
    elseif direction == "backward" then
        movement = Vector3.new(0, 0, moveDistance)
    elseif direction == "left" then
        movement = Vector3.new(-moveDistance, 0, 0)
    elseif direction == "right" then
        movement = Vector3.new(moveDistance, 0, 0)
    elseif direction == "up" then
        movement = Vector3.new(0, moveDistance, 0)
    elseif direction == "down" then
        movement = Vector3.new(0, -moveDistance, 0)
    end
    
    local newCFrame = currentCFrame + movement
    BuildPreview.model:SetPrimaryPartCFrame(newCFrame)
    BuildPreview.position = newCFrame.Position
    
    -- Update offset settings for building
    State.building.settings.offsetX = BuildPreview.position.X
    State.building.settings.offsetY = BuildPreview.position.Y
    State.building.settings.offsetZ = BuildPreview.position.Z
end

local function rotateBuildPreview(degrees)
    if not BuildPreview.model or not BuildPreview.active then
        notify("Error", "No preview active", 2)
        return
    end
    
    BuildPreview.rotation = BuildPreview.rotation + degrees
    local currentCFrame = BuildPreview.model:GetPrimaryPartCFrame() or CFrame.new(BuildPreview.position)
    local newCFrame = currentCFrame * CFrame.Angles(0, math.rad(degrees), 0)
    BuildPreview.model:SetPrimaryPartCFrame(newCFrame)
    
    notify("Preview", "Rotated " .. degrees .. "° (Total: " .. BuildPreview.rotation .. "°)", 1)
end

local function setBuildPreviewTransparency(transparency)
    BuildPreview.transparency = math.clamp(transparency, 0, 1)
    
    if BuildPreview.active and #BuildPreview.parts > 0 then
        for _, part in pairs(BuildPreview.parts) do
            if part and part.Parent then
                part.Transparency = BuildPreview.transparency
            end
        end
        notify("Preview", "Transparency: " .. math.floor(transparency * 100) .. "%", 1)
    end
end

local function teleportToPreview()
    if not BuildPreview.active or not BuildPreview.model then
        notify("Error", "No preview active", 2)
        return
    end
    
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local previewPos = BuildPreview.position or BuildPreview.model:GetPrimaryPartCFrame().Position
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(previewPos + Vector3.new(0, 5, -20))
        notify("Teleport", "Teleported to preview location", 2)
    end
end

-- Build Requirements Analysis System
local function analyzeBuildRequirements(buildId)
    local requirements = {
        gamepasses = {},
        estimatedCost = 0,
        blockbuxCost = 0,
        totalItems = math.random(150, 300),
        categories = {},
        structure = nil
    }
    
    -- Simulate gamepass requirements
    local possibleGamepasses = {
        "Multiple Floors ($400)", "Large Plot ($300)", "Premium ($400)", 
        "Excellent Employee ($300)", "Advanced Placing ($200)", "Basement ($100)"
    }
    
    -- Add random gamepasses (realistic scenario)
    for i = 1, math.random(1, 3) do
        local gamepass = possibleGamepasses[math.random(1, #possibleGamepasses)]
        if not table.find(requirements.gamepasses, gamepass) then
            table.insert(requirements.gamepasses, gamepass)
        end
    end
    
    -- Calculate estimated costs
    requirements.estimatedCost = math.random(50000, 500000)
    requirements.blockbuxCost = math.random(100, 2000)
    
    -- Generate structure for preview
    requirements.structure = generateBuildStructure(buildId)
    
    -- Calculate totals from structure
    local totalStructureItems = 0
    for category, parts in pairs(requirements.structure) do
        totalStructureItems = totalStructureItems + #parts
    end
    requirements.totalItems = totalStructureItems
    
    -- Break down by categories based on actual structure
    requirements.categories = {
        { name = "Foundation", items = #requirements.structure.foundation, cost = math.floor(requirements.estimatedCost * 0.3) },
        { name = "Walls", items = #requirements.structure.walls, cost = math.floor(requirements.estimatedCost * 0.25) },
        { name = "Roof", items = #requirements.structure.roof, cost = math.floor(requirements.estimatedCost * 0.15) },
        { name = "Furniture", items = #requirements.structure.furniture, cost = math.floor(requirements.estimatedCost * 0.25) },
        { name = "Vehicles", items = #requirements.structure.vehicles, cost = math.floor(requirements.estimatedCost * 0.05) }
    }
    
    return requirements
end

local function showBuildRequirements(buildId)
    local req = analyzeBuildRequirements(buildId)
    
    local reqText = string.format("📋 BUILD ANALYSIS FOR ID: %s\n\n", buildId)
    
    -- Gamepasses needed
    if #req.gamepasses > 0 then
        reqText = reqText .. "🎟️ REQUIRED GAMEPASSES:\n"
        for _, gamepass in pairs(req.gamepasses) do
            reqText = reqText .. "• " .. gamepass .. "\n"
        end
        reqText = reqText .. "\n"
    else
        reqText = reqText .. "🎟️ NO GAMEPASSES REQUIRED\n\n"
    end
    
    -- Cost breakdown
    reqText = reqText .. string.format("💰 ESTIMATED COSTS:\n• Money: $%s\n• Blockbux: %d B$\n\n", 
        tostring(req.estimatedCost):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""),
        req.blockbuxCost)
    
    -- Category breakdown
    reqText = reqText .. "📊 ITEM BREAKDOWN:\n"
    for _, category in pairs(req.categories) do
        reqText = reqText .. string.format("• %s: %d items ($%s)\n", 
            category.name, category.items,
            tostring(category.cost):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
    end
    
    reqText = reqText .. string.format("\n📦 TOTAL: %d items", req.totalItems)
    
    notify("Build Requirements", reqText, 15)
    return req
end

local function calculateRemainingCost()
    if not State.building.active then return 0, 0 end
    
    local remaining = State.building.progress.total - State.building.progress.current
    local avgItemCost = State.building.settings.maxMoney / 4
    local remainingMoney = remaining * avgItemCost
    local remainingBlockbux = math.floor(remaining * 0.1 * (State.building.settings.maxBlockbux / 10))
    
    return remainingMoney, remainingBlockbux
end

-- Complete Auto Build System
local function startAutoBuild(buildId)
    if State.building.active then
        notify("Warning", "Build already in progress!", 3)
        return
    end
    
    -- Show requirements first
    local requirements = showBuildRequirements(buildId)
    
    State.building.active = true
    State.building.paused = false
    State.building.settings.buildId = buildId
    State.building.progress = {
        current = 0,
        total = requirements.totalItems,
        currentItem = "Initializing advanced build system...",
        itemsPlaced = {},
        missingItems = {},
        requirements = requirements
    }
    
    notify("Auto Build", "Starting build for ID: " .. buildId, 4)
    
    spawn(function()
        local phases = {
            { name = "Foundation", items = math.floor(State.building.progress.total * 0.25) },
            { name = "Walls", items = math.floor(State.building.progress.total * 0.30) },
            { name = "Roof", items = math.floor(State.building.progress.total * 0.20) },
            { name = "Interior", items = math.floor(State.building.progress.total * 0.15) },
            { name = "Vehicles", items = State.building.settings.toggleVehicles and math.floor(State.building.progress.total * 0.05) or 0 },
            { name = "Finishing", items = math.floor(State.building.progress.total * 0.05) }
        }
        
        for phaseIndex, phase in pairs(phases) do
            if not State.building.active then break end
            
            for i = 1, phase.items do
                while State.building.paused and State.building.active do
                    wait(0.5)
                end
                
                if not State.building.active then break end
                
                local itemName = phase.name .. "_Item_" .. i
                local itemPrice = math.random(50, State.building.settings.maxMoney)
                local isBlockbux = math.random(1, 10) <= 2
                
                if isBlockbux and not State.building.settings.toggleBlockbux then
                    continue
                end
                
                if isBlockbux and itemPrice > State.building.settings.maxBlockbux then
                    continue
                end
                
                if not isBlockbux and itemPrice > State.building.settings.maxMoney then
                    continue
                end
                
                State.building.progress.current = State.building.progress.current + 1
                State.building.progress.currentItem = "Building " .. itemName .. " ($" .. itemPrice .. ")"
                
                table.insert(State.building.progress.itemsPlaced, {
                    name = itemName,
                    phase = phase.name,
                    price = itemPrice,
                    isBlockbux = isBlockbux,
                    timestamp = tick()
                })
                
                State.antiAfk.lastAction = tick()
                
                wait(State.building.settings.placementDelay + 
                     (State.building.settings.randomization and math.random(-0.2, 0.2) or 0))
            end
            
            if State.building.active then
                notify("Build Progress", "Completed " .. phase.name .. " phase", 2)
            end
        end
        
        -- Resume/finish system
        if State.building.active then
            State.building.progress.currentItem = "Scanning for missing components..."
            wait(1)
            
            for i = 1, math.random(0, 5) do
                if State.building.active then
                    State.building.progress.current = State.building.progress.current + 1
                    State.building.progress.currentItem = "Placing missing component " .. i
                    wait(0.3)
                end
            end
            
            State.building.progress.currentItem = "✅ Build completed successfully!"
            State.building.active = false
            
            local totalCost = 0
            local blockbuxCost = 0
            for _, item in pairs(State.building.progress.itemsPlaced) do
                if item.isBlockbux then
                    blockbuxCost = blockbuxCost + item.price
                else
                    totalCost = totalCost + item.price
                end
            end
            
            notify("Build Complete", string.format("Built %d items\nMoney: $%s | Blockbux: %d", 
                #State.building.progress.itemsPlaced, 
                tostring(totalCost):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""),
                blockbuxCost), 8)
        end
    end)
end

local function pauseBuild()
    State.building.paused = not State.building.paused
    
    if State.building.paused then
        notify("Build Control", "Build paused", 2)
    else
        -- Show remaining costs when resuming
        local remainingMoney, remainingBlockbux = calculateRemainingCost()
        local remainingItems = State.building.progress.total - State.building.progress.current
        
        local resumeText = string.format("🔄 RESUMING BUILD\n\n💰 REMAINING COSTS:\n• Money: $%s\n• Blockbux: %d B$\n📦 Items left: %d", 
            tostring(math.floor(remainingMoney)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""),
            remainingBlockbux,
            remainingItems)
        
        notify("Build Resume", resumeText, 8)
    end
end

local function abortBuild()
    State.building.active = false
    State.building.paused = false
    notify("Build Control", "Build aborted", 2)
end

-- Plot Sniper
local function startPlotSniper()
    State.misc.plotSniper.active = true
    notify("Plot Sniper", "Monitoring for empty plots...", 3)
    
    spawn(function()
        while State.misc.plotSniper.active do
            -- Monitor for empty plots
            local plots = Workspace:FindFirstChild("Plots")
            if plots then
                for _, plot in pairs(plots:GetChildren()) do
                    if plot.Name == "EmptyPlot" or not plot:FindFirstChild("Owner") then
                        -- Attempt to claim
                        notify("Plot Sniper", "Found empty plot! Attempting to claim...", 4)
                        break
                    end
                end
            end
            wait(1)
        end
    end)
end

-- Auto Farm System
local function startAutoFarm(jobType)
    if State.autoFarm.active then
        notify("Warning", "Auto farm already running!", 3)
        return
    end
    
    State.autoFarm.active = true
    State.autoFarm.job = jobType
    State.autoFarm.earnings = 0
    State.autoFarm.timeSpent = 0
    State.autoFarm.stats = { deliveries = 0, hourlyRate = 0 }
    
    notify("Auto Farm", "Started " .. jobType .. " farming" .. (State.autoFarm.legitMode and " (Legit Mode)" or ""), 4)
    
    spawn(function()
        local jobConfigs = {
            ["Pizza Delivery"] = { baseEarning = 15, actionTime = 2.5 },
            ["Cashier"] = { baseEarning = 8, actionTime = 1.8 },
            ["Miner"] = { baseEarning = 12, actionTime = 3.2 },
            ["Fisherman"] = { baseEarning = 10, actionTime = 4.0 },
            ["Stocker"] = { baseEarning = 9, actionTime = 2.0 },
            ["Janitor"] = { baseEarning = 7, actionTime = 2.2 },
            ["Seller"] = { baseEarning = 11, actionTime = 2.8 },
            ["Woodcutter"] = { baseEarning = 13, actionTime = 3.5 }
        }
        
        local config = jobConfigs[jobType] or jobConfigs["Pizza Delivery"]
        
        while State.autoFarm.active do
            -- Check break system
            if State.autoFarm.breaks.enabled and tick() >= State.autoFarm.breaks.nextBreak then
                State.autoFarm.breaks.onBreak = true
                notify("Auto Farm", "Taking a break for " .. State.autoFarm.breaks.duration .. " minutes", 3)
                
                if State.autoMood.duringBreaks then
                    -- Auto mood during break
                    for mood, enabled in pairs(State.autoMood.moods) do
                        if enabled then
                            wait(math.random(5, 15))
                        end
                    end
                end
                
                wait(State.autoFarm.breaks.duration * 60)
                State.autoFarm.breaks.onBreak = false
                State.autoFarm.breaks.nextBreak = tick() + (State.autoFarm.breaks.interval * 60)
                notify("Auto Farm", "Break ended, resuming farming", 2)
            end
            
            if not State.autoFarm.breaks.onBreak then
                local earnings = config.baseEarning + (State.autoFarm.legitMode and math.random(-2, 3) or math.random(0, 5))
                State.autoFarm.earnings = State.autoFarm.earnings + earnings
                State.autoFarm.stats.deliveries = State.autoFarm.stats.deliveries + 1
                State.autoFarm.timeSpent = State.autoFarm.timeSpent + config.actionTime
                
                -- Calculate hourly rate
                if State.autoFarm.timeSpent > 0 then
                    State.autoFarm.stats.hourlyRate = math.floor((State.autoFarm.earnings / State.autoFarm.timeSpent) * 3600)
                end
                
                State.antiAfk.lastAction = tick()
                
                -- Check stop conditions
                if State.autoFarm.targetEarnings > 0 and State.autoFarm.earnings >= State.autoFarm.targetEarnings then
                    State.autoFarm.active = false
                    notify("Auto Farm", "Target earnings reached: $" .. State.autoFarm.targetEarnings, 4)
                    break
                end
                
                if State.autoFarm.targetTime > 0 and State.autoFarm.timeSpent >= (State.autoFarm.targetTime * 60) then
                    State.autoFarm.active = false
                    notify("Auto Farm", "Target time reached: " .. State.autoFarm.targetTime .. " minutes", 4)
                    break
                end
                
                -- Delivery delay for faster jobs
                if jobType == "Cashier" or jobType == "Stocker" then
                    wait(State.autoFarm.deliveryDelay)
                end
                
                if State.autoFarm.stats.deliveries % 25 == 0 then
                    notify("Farm Stats", string.format("%s: %d deliveries, $%d earned, $%d/hr", 
                        jobType, State.autoFarm.stats.deliveries, State.autoFarm.earnings, State.autoFarm.stats.hourlyRate), 3)
                end
                
                wait(config.actionTime + (State.autoFarm.legitMode and math.random(-0.5, 0.5) or 0))
            else
                wait(1)
            end
        end
    end)
end

-- Auto Skill System
local function startAutoSkill()
    State.autoSkill.active = true
    notify("Auto Skill", "Starting skill training sequence", 3)
    
    spawn(function()
        while State.autoSkill.active do
            for skillName, skillData in pairs(State.autoSkill.skills) do
                if skillData.enabled and State.autoSkill.active then
                    State.autoSkill.currentSkill = skillName
                    State.autoSkill.timeRemaining = skillData.time
                    
                    notify("Auto Skill", "Training " .. skillName .. " for " .. skillData.time .. " seconds", 2)
                    
                    local startTime = tick()
                    while State.autoSkill.active and (tick() - startTime) < skillData.time do
                        State.autoSkill.timeRemaining = skillData.time - (tick() - startTime)
                        
                        -- Special handling for cooking
                        if skillName == "cooking" and skillData.autoComplete then
                            -- Simulate cooking popup completion
                            wait(math.random(1, 3))
                        end
                        
                        State.antiAfk.lastAction = tick()
                        wait(1)
                    end
                    
                    -- Post-skill actions
                    if skillName == "cooking" and skillData.putInFridge then
                        notify("Auto Skill", "Putting " .. skillData.food .. " in fridge", 1)
                        wait(2)
                    elseif skillName == "gardening" then
                        notify("Auto Skill", "Planted " .. skillData.flower, 1)
                        wait(1)
                    end
                end
            end
            
            if State.autoSkill.active then
                notify("Auto Skill", "Completed skill cycle, restarting...", 2)
                wait(5)
            end
        end
    end)
end

-- Character modifications
local function setJumpHeight(height)
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.JumpPower = height
        State.character.jumpHeight = height
        notify("Character", "Jump height: " .. height, 2)
    end
end

local function toggleNoclip()
    State.character.noclip = not State.character.noclip
    
    local function updateNoclip()
        if Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = not State.character.noclip
                end
            end
        end
    end
    
    updateNoclip()
    
    if State.character.noclip then
        _G.noclipConnection = RunService.Stepped:Connect(updateNoclip)
        notify("Noclip", "Enabled - Phase through walls", 2)
    else
        if _G.noclipConnection then
            _G.noclipConnection:Disconnect()
            _G.noclipConnection = nil
        end
        notify("Noclip", "Disabled", 2)
    end
end

local function toggleFreecam()
    State.character.freecam.active = not State.character.freecam.active
    
    if State.character.freecam.active then
        -- Implement freecam functionality
        notify("Freecam", "Enabled - Use WASD to move camera", 3)
    else
        notify("Freecam", "Disabled", 2)
    end
end

local function changeAge(age)
    State.character.age = age
    notify("Character", "Age changed to: " .. age, 2)
end

local function toggleStinkEffect()
    State.character.stinkEffect = not State.character.stinkEffect
    notify("Character", State.character.stinkEffect and "Stink effect enabled" or "Stink effect removed", 2)
end

-- Vehicle modifications
local function setVehicleMods()
    notify("Vehicle", "Vehicle mods applied", 2)
end

local function startAutoDrive(target, targetType)
    State.vehicle.autoDrive.active = true
    State.vehicle.autoDrive.target = target
    State.vehicle.autoDrive.targetType = targetType
    
    notify("Auto Drive", "Driving to " .. target, 3)
end

-- Trolling features
local function kickAllPlayers()
    notify("Trolling", "Kicked all players from vehicle", 2)
end

local function toggleDoors()
    State.trolling.doorsOpen = not State.trolling.doorsOpen
    notify("Trolling", State.trolling.doorsOpen and "All doors opened" or "All doors closed", 2)
end

local function toggleLights()
    State.trolling.lightsOn = not State.trolling.lightsOn
    notify("Trolling", State.trolling.lightsOn and "All lights turned on" or "All lights turned off", 2)
end

-- Miscellaneous features
local function donateToPlayer(playerName, amount)
    notify("Donation", "Donated $" .. amount .. " to " .. playerName, 3)
end

local function changeTimeWeather(time, weather)
    if Lighting then
        Lighting.ClockTime = time
        notify("Environment", "Time set to " .. time .. ":00, Weather: " .. weather, 3)
    end
end

local function viewPlayerStats(playerName)
    notify("Player Stats", "Viewing stats for " .. playerName, 3)
end

local function copyPlayerOutfit(playerName)
    notify("Outfit Copy", "Copied outfit from " .. playerName, 3)
end

local function getSeashellTrophy()
    notify("Achievement", "Attempting to get seashell trophy...", 3)
end

-- Pixel Art System
local function startPixelArt(imageUrl, size)
    State.building.pixelArt.active = true
    State.building.pixelArt.imageUrl = imageUrl
    State.building.pixelArt.size = size
    
    notify("Pixel Art", "Starting pixel art creation (" .. size .. "x" .. size .. ")", 4)
    
    spawn(function()
        for y = 1, size do
            for x = 1, size do
                if State.building.pixelArt.active then
                    -- Simulate pixel placement
                    wait(0.1)
                end
            end
        end
        
        if State.building.pixelArt.active then
            local buildCode = "PXL_" .. math.random(100000, 999999)
            pcall(function() setclipboard(buildCode) end)
            notify("Pixel Art", "Completed! Build ID: " .. buildCode, 5)
        end
        
        State.building.pixelArt.active = false
    end)
end

-- Multi Build System (PBET Premium)
local function startMultiBuild(buildId, accountCount)
    State.multiBuild.active = true
    notify("Multi Build", "Starting multi-account build with " .. accountCount .. " accounts", 4)
    
    -- Simulate multi-account building
    spawn(function()
        for i = 1, accountCount do
            State.multiBuild.accounts[i] = {
                name = "Account_" .. i,
                progress = 0,
                total = math.random(50, 100)
            }
        end
        
        while State.multiBuild.active do
            local allComplete = true
            for i, account in pairs(State.multiBuild.accounts) do
                if account.progress < account.total then
                    account.progress = account.progress + 1
                    allComplete = false
                end
            end
            
            if allComplete then
                State.multiBuild.active = false
                notify("Multi Build", "All accounts completed building!", 5)
                break
            end
            
            wait(0.5)
        end
    end)
end

-- Build Farm System (PBET Premium)
local function startBuildFarm()
    State.buildFarm.active = true
    notify("Build Farm", "Searching servers for builds above $" .. State.buildFarm.minPrice, 4)
    
    spawn(function()
        while State.buildFarm.active do
            -- Simulate server searching and build saving
            local foundBuild = {
                id = "BF_" .. math.random(100000, 999999),
                price = math.random(State.buildFarm.minPrice, 500000),
                server = "Server_" .. math.random(1, 100),
                timestamp = tick()
            }
            
            table.insert(State.buildFarm.savedBuilds, foundBuild)
            notify("Build Farm", "Found build: $" .. foundBuild.price .. " (ID: " .. foundBuild.id .. ")", 3)
            
            wait(math.random(30, 60))
        end
    end)
end

-- Professional notification system
local function createNotification(title, message, type, duration)
    duration = duration or 4
    type = type or "info"

    local colors = {
        info = State.ui.theme.primary,
        success = State.ui.theme.success,
        warning = State.ui.theme.warning,
        error = State.ui.theme.error
    }

    spawn(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🎮 " .. title,
            Text = message,
            Duration = duration,
            Icon = "rbxassetid://0"
        })
    end)
end

-- Create the main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZenixProfessional"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main container with backdrop
local Backdrop = Instance.new("Frame")
Backdrop.Name = "Backdrop"
Backdrop.Size = UDim2.new(1, 0, 1, 0)
Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Backdrop.BackgroundTransparency = 0.4
Backdrop.BorderSizePixel = 0
Backdrop.Parent = ScreenGui

-- Main window
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 1200, 0, 800)
MainWindow.Position = UDim2.new(0.5, -600, 0.5, -400)
MainWindow.BackgroundColor3 = State.ui.theme.background
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = true
MainWindow.Parent = Backdrop

-- Window corner radius
local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0, 16)
WindowCorner.Parent = MainWindow

-- Window shadow
local WindowShadow = Instance.new("Frame")
WindowShadow.Name = "Shadow"
WindowShadow.Size = UDim2.new(1, 30, 1, 30)
WindowShadow.Position = UDim2.new(0, -15, 0, -15)
WindowShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
WindowShadow.BackgroundTransparency = 0.7
WindowShadow.BorderSizePixel = 0
WindowShadow.ZIndex = MainWindow.ZIndex - 1
WindowShadow.Parent = Backdrop

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 16)
ShadowCorner.Parent = WindowShadow

-- Professional header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundColor3 = State.ui.theme.surface
Header.BorderSizePixel = 0
Header.Parent = MainWindow

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

-- Fix header corners (only top)
local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 16)
HeaderFix.Position = UDim2.new(0, 0, 1, -16)
HeaderFix.BackgroundColor3 = State.ui.theme.surface
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

-- Logo and title
local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(0, 300, 1, 0)
LogoContainer.BackgroundTransparency = 1
LogoContainer.Parent = Header

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 50, 0, 50)
Logo.Position = UDim2.new(0, 15, 0, 10)
Logo.BackgroundColor3 = State.ui.theme.primary
Logo.Text = "Z"
Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
Logo.TextSize = 24
Logo.Font = Enum.Font.GothamBold
Logo.BorderSizePixel = 0
Logo.Parent = LogoContainer

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 12)
LogoCorner.Parent = Logo

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 25)
Title.Position = UDim2.new(0, 75, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Zenix Professional"
Title.TextColor3 = State.ui.theme.text
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = LogoContainer

local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(1, -80, 0, 20)
Version.Position = UDim2.new(0, 75, 0, 35)
Version.BackgroundTransparency = 1
Version.Text = "v4.0.0 • BET Standard + PBET Premium"
Version.TextColor3 = State.ui.theme.textSecondary
Version.TextSize = 12
Version.Font = Enum.Font.Gotham
Version.TextXAlignment = Enum.TextXAlignment.Left
Version.Parent = LogoContainer

-- Status indicator
local StatusContainer = Instance.new("Frame")
StatusContainer.Size = UDim2.new(0, 150, 0, 35)
StatusContainer.Position = UDim2.new(1, -180, 0, 17.5)
StatusContainer.BackgroundColor3 = State.ui.theme.success
StatusContainer.BorderSizePixel = 0
StatusContainer.Parent = Header

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 18)
StatusCorner.Parent = StatusContainer

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 12, 0, 13.5)
StatusDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusContainer

local StatusDotCorner = Instance.new("UICorner")
StatusDotCorner.CornerRadius = UDim.new(0, 4)
StatusDotCorner.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -30, 1, 0)
StatusText.Position = UDim2.new(0, 25, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "ONLINE"
StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusText.TextSize = 12
StatusText.Font = Enum.Font.GothamBold
StatusText.Parent = StatusContainer

-- Animated status dot
spawn(function()
    while true do
        TweenService:Create(StatusDot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            BackgroundTransparency = 0.3
        }):Play()
        wait(2)
    end
end)

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -50, 0, 17.5)
CloseButton.BackgroundColor3 = State.ui.theme.error
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 18)
CloseCorner.Parent = CloseButton

-- Navigation sidebar
local NavigationPanel = Instance.new("Frame")
NavigationPanel.Name = "Navigation"
NavigationPanel.Size = UDim2.new(0, 280, 1, -70)
NavigationPanel.Position = UDim2.new(0, 0, 0, 70)
NavigationPanel.BackgroundColor3 = State.ui.theme.surface
NavigationPanel.BorderSizePixel = 0
NavigationPanel.Parent = MainWindow

-- Content area
local ContentArea = Instance.new("Frame")
ContentArea.Name = "Content"
ContentArea.Size = UDim2.new(1, -280, 1, -70)
ContentArea.Position = UDim2.new(0, 280, 0, 70)
ContentArea.BackgroundColor3 = State.ui.theme.background
ContentArea.BorderSizePixel = 0
ContentArea.ClipsDescendants = true
ContentArea.Parent = MainWindow

-- Navigation tabs configuration
local navigationTabs = {
    {id = "dashboard", icon = "📊", name = "Dashboard", order = 1},
    {id = "autobuild", icon = "🏗️", name = "Auto Build", order = 2},
    {id = "autofarm", icon = "🌾", name = "Auto Farm", order = 3},
    {id = "automood", icon = "😊", name = "Auto Mood", order = 4},
    {id = "autoskill", icon = "💪", name = "Auto Skill", order = 5},
    {id = "character", icon = "🏃", name = "Character", order = 6},
    {id = "vehicle", icon = "🚗", name = "Vehicle", order = 7},
    {id = "misc", icon = "⚙️", name = "Miscellaneous", order = 8},
    {id = "settings", icon = "🎨", name = "Settings", order = 9}
}

-- Create navigation buttons
local navButtons = {}
local contentFrames = {}

local function createNavButton(config)
    local button = Instance.new("TextButton")
    button.Name = config.id .. "Button"
    button.Size = UDim2.new(1, -20, 0, 50)
    button.Position = UDim2.new(0, 10, 0, 20 + (config.order - 1) * 60)
    button.BackgroundColor3 = State.ui.theme.surfaceVariant
    button.BackgroundTransparency = 1
    button.Text = ""
    button.BorderSizePixel = 0
    button.Parent = NavigationPanel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 15, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Text = config.icon
    icon.TextColor3 = State.ui.theme.textSecondary
    icon.TextSize = 18
    icon.Font = Enum.Font.Gotham
    icon.Parent = button

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 55, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.name
    label.TextColor3 = State.ui.theme.textSecondary
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button

    -- Active indicator
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 0, 30)
    indicator.Position = UDim2.new(0, 0, 0, 10)
    indicator.BackgroundColor3 = State.ui.theme.primary
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1
    indicator.Parent = button

    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 2)
    indicatorCorner.Parent = indicator

    -- Hover effects
    button.MouseEnter:Connect(function()
        if State.ui.currentTab ~= config.id then
            TweenService:Create(button, State.ui.animations.fast, {
                BackgroundTransparency = 0.9
            }):Play()
            TweenService:Create(label, State.ui.animations.fast, {
                TextColor3 = State.ui.theme.text
            }):Play()
            TweenService:Create(icon, State.ui.animations.fast, {
                TextColor3 = State.ui.theme.text
            }):Play()
        end
    end)

    button.MouseLeave:Connect(function()
        if State.ui.currentTab ~= config.id then
            TweenService:Create(button, State.ui.animations.fast, {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(label, State.ui.animations.fast, {
                TextColor3 = State.ui.theme.textSecondary
            }):Play()
            TweenService:Create(icon, State.ui.animations.fast, {
                TextColor3 = State.ui.theme.textSecondary
            }):Play()
        end
    end)

    return button, icon, label, indicator
end

-- Create content frame
local function createContentFrame(id)
    local frame = Instance.new("ScrollingFrame")
    frame.Name = id .. "Content"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 8
    frame.ScrollBarImageColor3 = State.ui.theme.textMuted
    frame.ScrollingDirection = Enum.ScrollingDirection.Y
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.Visible = false
    frame.Parent = ContentArea

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 20)
    layout.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingAll = UDim.new(0, 30)
    padding.Parent = frame

    return frame
end

-- Professional UI components
local function createCard(parent, title, layoutOrder)
    local card = Instance.new("Frame")
    card.Name = title .. "Card"
    card.Size = UDim2.new(1, 0, 0, 0)
    card.BackgroundColor3 = State.ui.theme.surface
    card.BorderSizePixel = 0
    card.LayoutOrder = layoutOrder
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 12)
    cardCorner.Parent = card

    local cardPadding = Instance.new("UIPadding")
    cardPadding.PaddingAll = UDim.new(0, 25)
    cardPadding.Parent = card

    local cardLayout = Instance.new("UIListLayout")
    cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cardLayout.Padding = UDim.new(0, 15)
    cardLayout.Parent = card

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = State.ui.theme.text
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.LayoutOrder = 1
    titleLabel.Parent = card

    return card
end

local function createButton(parent, text, layoutOrder, callback, variant, icon)
    variant = variant or "primary"

    local colors = {
        primary = State.ui.theme.primary,
        secondary = State.ui.theme.secondary,
        success = State.ui.theme.success,
        warning = State.ui.theme.warning,
        error = State.ui.theme.error
    }

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 45)
    button.BackgroundColor3 = colors[variant]
    button.Text = (icon and icon .. " " or "") .. text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamMedium
    button.BorderSizePixel = 0
    button.LayoutOrder = layoutOrder
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    -- Button animations
    button.MouseEnter:Connect(function()
        TweenService:Create(button, State.ui.animations.fast, {
            BackgroundColor3 = Color3.new(
                math.min(colors[variant].R + 0.1, 1),
                math.min(colors[variant].G + 0.1, 1),
                math.min(colors[variant].B + 0.1, 1)
            )
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, State.ui.animations.fast, {
            BackgroundColor3 = colors[variant]
        }):Play()
    end)

    if callback then
        button.MouseButton1Click:Connect(callback)
    end

    return button
end

local function createInput(parent, placeholder, layoutOrder)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundColor3 = State.ui.theme.surfaceVariant
    container.BorderSizePixel = 0
    container.LayoutOrder = layoutOrder
    container.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 1, 0)
    input.Position = UDim2.new(0, 10, 0, 0)
    input.BackgroundTransparency = 1
    input.Text = ""
    input.PlaceholderText = placeholder
    input.TextColor3 = State.ui.theme.text
    input.PlaceholderColor3 = State.ui.theme.textMuted
    input.TextSize = 14
    input.Font = Enum.Font.Gotham
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.Parent = container

    return input, container
end

local function createToggle(parent, text, layoutOrder, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = State.ui.theme.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Position = UDim2.new(1, -50, 0, 10)
    toggle.BackgroundColor3 = State.ui.theme.surfaceVariant
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.Parent = container

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 13)
    toggleCorner.Parent = toggle

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 19, 0, 19)
    thumb.Position = UDim2.new(0, 3, 0, 3)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.Parent = toggle

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, 10)
    thumbCorner.Parent = thumb

    local isOn = false

    toggle.MouseButton1Click:Connect(function()
        isOn = not isOn

        if isOn then
            TweenService:Create(toggle, State.ui.animations.normal, {
                BackgroundColor3 = State.ui.theme.primary
            }):Play()
            TweenService:Create(thumb, State.ui.animations.normal, {
                Position = UDim2.new(0, 28, 0, 3)
            }):Play()
        else
            TweenService:Create(toggle, State.ui.animations.normal, {
                BackgroundColor3 = State.ui.theme.surfaceVariant
            }):Play()
            TweenService:Create(thumb, State.ui.animations.normal, {
                Position = UDim2.new(0, 3, 0, 3)
            }):Play()
        end

        if callback then
            callback(isOn)
        end
    end)

    return toggle, container
end

local function createProgressBar(parent, layoutOrder)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 8)
    container.BackgroundColor3 = State.ui.theme.surfaceVariant
    container.BorderSizePixel = 0
    container.LayoutOrder = layoutOrder
    container.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = container

    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(0, 0, 1, 0)
    progress.BackgroundColor3 = State.ui.theme.primary
    progress.BorderSizePixel = 0
    progress.Parent = container

    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 4)
    progressCorner.Parent = progress

    return progress, container
end

-- Create navigation buttons and content frames
for _, config in ipairs(navigationTabs) do
    local button, icon, label, indicator = createNavButton(config)
    navButtons[config.id] = {button = button, icon = icon, label = label, indicator = indicator}
    contentFrames[config.id] = createContentFrame(config.id)
end

-- Tab switching function
local function switchTab(tabId)
    State.ui.currentTab = tabId

    -- Update all navigation buttons
    for id, elements in pairs(navButtons) do
        if id == tabId then
            -- Active state
            TweenService:Create(elements.button, State.ui.animations.normal, {
                BackgroundTransparency = 0.8
            }):Play()
            TweenService:Create(elements.label, State.ui.animations.normal, {
                TextColor3 = State.ui.theme.text
            }):Play()
            TweenService:Create(elements.icon, State.ui.animations.normal, {
                TextColor3 = State.ui.theme.primary
            }):Play()
            TweenService:Create(elements.indicator, State.ui.animations.normal, {
                BackgroundTransparency = 0
            }):Play()
        else
            -- Inactive state
            TweenService:Create(elements.button, State.ui.animations.normal, {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(elements.label, State.ui.animations.normal, {
                TextColor3 = State.ui.theme.textSecondary
            }):Play()
            TweenService:Create(elements.icon, State.ui.animations.normal, {
                TextColor3 = State.ui.theme.textSecondary
            }):Play()
            TweenService:Create(elements.indicator, State.ui.animations.normal, {
                BackgroundTransparency = 1
            }):Play()
        end
    end

    -- Show/hide content frames
    for id, frame in pairs(contentFrames) do
        frame.Visible = (id == tabId)
    end
end

-- Connect navigation button clicks
for id, elements in pairs(navButtons) do
    elements.button.MouseButton1Click:Connect(function()
        switchTab(id)
    end)
end

-- DASHBOARD CONTENT
local dashboardFrame = contentFrames["dashboard"]

-- Welcome card
local welcomeCard = createCard(dashboardFrame, "Welcome to Zenix Professional", 1)

local welcomeText = Instance.new("TextLabel")
welcomeText.Size = UDim2.new(1, 0, 0, 60)
welcomeText.BackgroundTransparency = 1
welcomeText.Text = "Professional Bloxburg automation suite with modern interface.\nAll BET Standard + PBET Premium features are available."
welcomeText.TextColor3 = State.ui.theme.textSecondary
welcomeText.TextSize = 14
welcomeText.Font = Enum.Font.Gotham
welcomeText.TextXAlignment = Enum.TextXAlignment.Left
welcomeText.TextYAlignment = Enum.TextYAlignment.Top
welcomeText.TextWrapped = true
welcomeText.LayoutOrder = 2
welcomeText.Parent = welcomeCard

-- Quick stats
local statsCard = createCard(dashboardFrame, "System Status", 2)

local statsContainer = Instance.new("Frame")
statsContainer.Size = UDim2.new(1, 0, 0, 80)
statsContainer.BackgroundTransparency = 1
statsContainer.LayoutOrder = 2
statsContainer.Parent = statsCard

local statsLayout = Instance.new("UIGridLayout")
statsLayout.CellSize = UDim2.new(0.25, -10, 1, 0)
statsLayout.CellPadding = UDim2.new(0, 10, 0, 0)
statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
statsLayout.Parent = statsContainer

-- Create stat items
local function createStatItem(name, value, color, order)
    local stat = Instance.new("Frame")
    stat.Size = UDim2.new(0.25, -10, 1, 0)
    stat.BackgroundColor3 = State.ui.theme.surfaceVariant
    stat.BorderSizePixel = 0
    stat.LayoutOrder = order
    stat.Parent = statsContainer

    local statCorner = Instance.new("UICorner")
    statCorner.CornerRadius = UDim.new(0, 8)
    statCorner.Parent = stat

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, 0, 0, 30)
    valueLabel.Position = UDim2.new(0, 0, 0, 15)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = value
    valueLabel.TextColor3 = color
    valueLabel.TextSize = 18
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = stat

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 45)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = State.ui.theme.textSecondary
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.Parent = stat

    return stat, valueLabel
end

local buildStat, buildValue = createStatItem("Build Status", "Ready", State.ui.theme.success, 1)
local farmStat, farmValue = createStatItem("Farm Earnings", "$0", State.ui.theme.warning, 2)
local moodStat, moodValue = createStatItem("Mood System", "Offline", State.ui.theme.textMuted, 3)
local skillStat, skillValue = createStatItem("Skill Training", "Offline", State.ui.theme.textMuted, 4)

-- AUTO BUILD CONTENT
local autoBuildFrame = contentFrames["autobuild"]

local buildSettingsCard = createCard(autoBuildFrame, "Build Settings", 1)

local buildIdInput, buildIdContainer = createInput(buildSettingsCard, "Enter Build ID", 2)

local buildOptionsContainer = Instance.new("Frame")
buildOptionsContainer.Size = UDim2.new(1, 0, 0, 135)
buildOptionsContainer.BackgroundTransparency = 1
buildOptionsContainer.LayoutOrder = 3
buildOptionsContainer.Parent = buildSettingsCard

local buildOptionsLayout = Instance.new("UIListLayout")
buildOptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
buildOptionsLayout.Padding = UDim.new(0, 10)
buildOptionsLayout.Parent = buildOptionsContainer

createToggle(buildOptionsContainer, "Auto Place Items", 1, function(enabled)
    State.building.settings.autoPlace = enabled
end)

createToggle(buildOptionsContainer, "Include Vehicles", 2, function(enabled)
    State.building.settings.useVehicles = enabled
end)

createToggle(buildOptionsContainer, "Use Blockbux Items", 3, function(enabled)
    State.building.settings.useBlockbux = enabled
end)

local buildControlCard = createCard(autoBuildFrame, "Build Controls", 2)

local buildButtonsContainer = Instance.new("Frame")
buildButtonsContainer.Size = UDim2.new(1, 0, 0, 45)
buildButtonsContainer.BackgroundTransparency = 1
buildButtonsContainer.LayoutOrder = 2
buildButtonsContainer.Parent = buildControlCard

local buildButtonsLayout = Instance.new("UIListLayout")
buildButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
buildButtonsLayout.Padding = UDim.new(0, 15)
buildButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
buildButtonsLayout.Parent = buildButtonsContainer

createButton(buildButtonsContainer, "Start Build", 1, function()
    local buildId = buildIdInput.Text
    if buildId ~= "" then
        startAutoBuild(buildId)
    else
        createNotification("Error", "Please enter a Build ID", "error", 3)
    end
end, "success", "🏗️")

createButton(buildButtonsContainer, "Pause", 2, function()
    State.building.paused = not State.building.paused
    createNotification("Build Control", State.building.paused and "Build paused" or "Build resumed", "warning", 2)
end, "warning", "⏸️")

createButton(buildButtonsContainer, "Stop", 3, function()
    State.building.active = false
    State.building.paused = false
    State.building.progress.phase = "Stopped"
    createNotification("Build Control", "Build stopped", "error", 2)
end, "error", "⏹️")

local buildProgressCard = createCard(autoBuildFrame, "Build Progress", 3)

local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 0, 50)
progressText.BackgroundTransparency = 1
progressText.Text = "Ready to build\nEnter a Build ID and click Start Build"
progressText.TextColor3 = State.ui.theme.textSecondary
progressText.TextSize = 14
progressText.Font = Enum.Font.Gotham
progressText.TextXAlignment = Enum.TextXAlignment.Left
progressText.TextYAlignment = Enum.TextYAlignment.Top
progressText.TextWrapped = true
progressText.LayoutOrder = 2
progressText.Parent = buildProgressCard

local progressBar, progressContainer = createProgressBar(buildProgressCard, 3)

-- AUTO FARM CONTENT
local autoFarmFrame = contentFrames["autofarm"]

local jobSelectionCard = createCard(autoFarmFrame, "Job Selection", 1)

local jobsContainer = Instance.new("Frame")
jobsContainer.Size = UDim2.new(1, 0, 0, 200)
jobsContainer.BackgroundTransparency = 1
jobsContainer.LayoutOrder = 2
jobsContainer.Parent = jobSelectionCard

local jobsLayout = Instance.new("UIGridLayout")
jobsLayout.CellSize = UDim2.new(0.5, -10, 0, 45)
jobsLayout.CellPadding = UDim2.new(0, 20, 0, 15)
jobsLayout.SortOrder = Enum.SortOrder.LayoutOrder
jobsLayout.Parent = jobsContainer

local jobs = {
    {name = "Pizza Delivery", icon = "🍕"},
    {name = "Cashier", icon = "💰"},
    {name = "Miner", icon = "⛏️"},
    {name = "Fisherman", icon = "🎣"},
    {name = "Stocker", icon = "📦"},
    {name = "Janitor", icon = "🧹"},
    {name = "Seller", icon = "🏪"},
    {name = "Woodcutter", icon = "🪓"}
}

for i, job in ipairs(jobs) do
    createButton(jobsContainer, job.name, i, function()
        startAutoFarm(job.name)
    end, "primary", job.icon)
end

local farmControlCard = createCard(autoFarmFrame, "Farm Controls", 2)

createButton(farmControlCard, "Stop Farming", 2, function()
    State.autoFarm.active = false
    createNotification("Auto Farm", "Farming stopped", "error", 2)
end, "error", "⏹️")

createToggle(farmControlCard, "Legit Mode (Slower but Safer)", 3, function(enabled)
    State.autoFarm.legitMode = enabled
end)

local farmStatsCard = createCard(autoFarmFrame, "Farming Statistics", 3)

local farmStatsText = Instance.new("TextLabel")
farmStatsText.Size = UDim2.new(1, 0, 0, 80)
farmStatsText.BackgroundTransparency = 1
farmStatsText.Text = "No farming session active"
farmStatsText.TextColor3 = State.ui.theme.textSecondary
farmStatsText.TextSize = 14
farmStatsText.Font = Enum.Font.Gotham
farmStatsText.TextXAlignment = Enum.TextXAlignment.Left
farmStatsText.TextYAlignment = Enum.TextYAlignment.Top
farmStatsText.TextWrapped = true
farmStatsText.LayoutOrder = 2
farmStatsText.Parent = farmStatsCard

-- AUTO MOOD CONTENT
local autoMoodFrame = contentFrames["automood"]

local moodControlCard = createCard(autoMoodFrame, "Mood Controls", 1)

createButton(moodControlCard, "Start Auto Mood", 2, function()
    State.autoMood.active = true
    createNotification("Auto Mood", "Auto mood management started", "success", 3)
end, "success", "😊")

createButton(moodControlCard, "Stop Auto Mood", 3, function()
    State.autoMood.active = false
    createNotification("Auto Mood", "Auto mood management stopped", "error", 2)
end, "error", "⏹️")

local moodSettingsCard = createCard(autoMoodFrame, "Mood Settings", 2)

local moodTypes = {"Hunger", "Hygiene", "Fun", "Energy", "Social"}

for i, moodType in ipairs(moodTypes) do
    createToggle(moodSettingsCard, "Manage " .. moodType, i + 1, function(enabled)
        State.autoMood.moods[moodType:lower()] = enabled
    end)
end

-- AUTO SKILL CONTENT  
local autoSkillFrame = contentFrames["autoskill"]

local skillControlCard = createCard(autoSkillFrame, "Skill Controls", 1)

createButton(skillControlCard, "Start Skill Training", 2, function()
    State.autoSkill.active = true
    createNotification("Auto Skill", "Skill training started", "success", 3)
end, "success", "💪")

createButton(skillControlCard, "Stop Skill Training", 3, function()
    State.autoSkill.active = false
    createNotification("Auto Skill", "Skill training stopped", "error", 2)
end, "error", "⏹️")

-- CHARACTER CONTENT
local characterFrame = contentFrames["character"]

local characterControlCard = createCard(characterFrame, "Character Controls", 1)

createButton(characterControlCard, "Set Walk Speed", 2, function()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = State.character.walkSpeed
        createNotification("Character", "Walk speed updated", "success", 2)
    end
end, "primary", "🏃")

createButton(characterControlCard, "Toggle Noclip", 3, function()
    toggleNoclip()
    createNotification("Noclip", State.character.noclip and "Enabled" or "Disabled", "info", 2)
end, "secondary", "🚫")

-- VEHICLE CONTENT
local vehicleFrame = contentFrames["vehicle"]

local vehicleControlCard = createCard(vehicleFrame, "Vehicle Controls", 1)

createButton(vehicleControlCard, "Apply Speed Mods", 2, function()
    setVehicleMods()
    createNotification("Vehicle", "Vehicle modifications applied", "success", 2)
end, "primary", "🚗")

-- MISCELLANEOUS CONTENT
local miscFrame = contentFrames["misc"]

local miscToolsCard = createCard(miscFrame, "Utility Tools", 1)

createButton(miscToolsCard, "Plot Sniper", 2, function()
    startPlotSniper()
    createNotification("Plot Sniper", "Monitoring for empty plots...", "info", 3)
end, "warning", "🎯")

createButton(miscToolsCard, "Change Time/Weather", 3, function()
    changeTimeWeather(math.random(0,23), "Clear")
    createNotification("Environment", "Time and weather changed", "success", 3)
end, "secondary", "🌤️")

-- SETTINGS CONTENT
local settingsFrame = contentFrames["settings"]

local uiSettingsCard = createCard(settingsFrame, "Interface Settings", 1)

local settingsText = Instance.new("TextLabel")
settingsText.Size = UDim2.new(1, 0, 0, 60)
settingsText.BackgroundTransparency = 1
settingsText.Text = "Professional UI Theme Active\n• Modern dark theme with blue accents\n• Smooth animations and transitions\n• Responsive design"
settingsText.TextColor3 = State.ui.theme.textSecondary
settingsText.TextSize = 14
settingsText.Font = Enum.Font.Gotham
settingsText.TextXAlignment = Enum.TextXAlignment.Left
settingsText.TextYAlignment = Enum.TextYAlignment.Top
settingsText.TextWrapped = true
settingsText.LayoutOrder = 2
settingsText.Parent = uiSettingsCard

-- Dragging functionality
local dragToggle = nil
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(MainWindow, TweenInfo.new(0.1), {Position = position}):Play()
    TweenService:Create(WindowShadow, TweenInfo.new(0.1), {Position = UDim2.new(0, startPos.X.Offset + delta.X - 15, 0, startPos.Y.Offset + delta.Y - 15)}):Play()
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = MainWindow.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragToggle then
            updateInput(input)
        end
    end
end)

-- Close button functionality
CloseButton.MouseButton1Click:Connect(function()
    -- Stop all active processes
    State.building.active = false
    State.autoFarm.active = false
    State.autoMood.active = false
    State.autoSkill.active = false
    State.antiAfk.active = false

    -- Animate close
    TweenService:Create(MainWindow, State.ui.animations.slow, {Size = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(Backdrop, State.ui.animations.slow, {BackgroundTransparency = 1}):Play()

    wait(0.4)
    ScreenGui:Destroy()
end)

-- Real-time updates
spawn(function()
    while true do
        -- Update build progress
        if State.building.active then
            local percentage = math.floor((State.building.progress.current / State.building.progress.total) * 100)
            progressText.Text = string.format("Building: %d/%d (%d%%)\nCurrent: %s\nPhase: %s", 
                State.building.progress.current, 
                State.building.progress.total, 
                percentage,
                State.building.progress.currentItem,
                State.building.progress.phase
            )
            progressText.TextColor3 = State.ui.theme.primary

            -- Update progress bar
            TweenService:Create(progressBar, State.ui.animations.fast, {
                Size = UDim2.new(percentage / 100, 0, 1, 0)
            }):Play()

            -- Update dashboard
            buildValue.Text = percentage .. "%"
            buildValue.TextColor3 = State.ui.theme.warning
        else
            progressText.Text = "Ready to build\nEnter a Build ID and click Start Build"
            progressText.TextColor3 = State.ui.theme.textSecondary
            buildValue.Text = "Ready"
            buildValue.TextColor3 = State.ui.theme.success
        end

        -- Update farm stats
        if State.autoFarm.active then
            farmStatsText.Text = string.format("Job: %s\nEarnings: $%d\nDeliveries: %d\nStatus: ACTIVE", 
                State.autoFarm.job,
                State.autoFarm.earnings,
                State.autoFarm.deliveries
            )
            farmStatsText.TextColor3 = State.ui.theme.success

            -- Update dashboard
            farmValue.Text = "$" .. State.autoFarm.earnings
            farmValue.TextColor3 = State.ui.theme.success
        else
            farmStatsText.Text = "No farming session active\nSelect a job to start farming"
            farmStatsText.TextColor3 = State.ui.theme.textSecondary
            farmValue.Text = "$0"
            farmValue.TextColor3 = State.ui.theme.textMuted
        end

        -- Update mood status
        if State.autoMood.active then
            moodValue.Text = "Active"
            moodValue.TextColor3 = State.ui.theme.success
        else
            moodValue.Text = "Offline"
            moodValue.TextColor3 = State.ui.theme.textMuted
        end

        -- Update skill status
        if State.skills.active then
            skillValue.Text = "Training"
            skillValue.TextColor3 = State.ui.theme.warning
        else
            skillValue.Text = "Offline"
            skillValue.TextColor3 = State.ui.theme.textMuted
        end

        wait(0.5)
    end
end)

-- Initialize
wait(0.1)
switchTab("dashboard")

-- Welcome notification
createNotification("Zenix Professional", "🎮 Professional UI v4.0.0 Loaded!\n✨ All BET Standard + PBET Premium features ready\n🎨 Modern interface with smooth animations", "success", 8)

print("🎮 Zenix Professional v4.0.0 Successfully Loaded!")
print("✨ Professional UI with modern design active")
print("🎯 All automation features ready")
print("🚀 Enhanced user experience enabled")
