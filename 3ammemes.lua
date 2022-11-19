-- Variables


local tycoon = nil

local_plr = game:GetService("Players").LocalPlayer

task.spawn(function()
    while task.wait(1) do
        for i,v in pairs(game:GetService("Workspace").Tycoons:GetChildren()) do
            if v.Name ~= "CreateStorage" and v.Name ~= "Configuration" then
                if v.TycoonOwner.Value == local_plr.Name then
                    tycoon = v
                    break
                end
            end
        end
        if tycoon then
            break
        end
    end
end)

local upgrade_path = local_plr.Data
local upgrade_btns = local_plr.PlayerGui.PCGUI.Frame.Upgrades
local upgrade_event = game:GetService("ReplicatedStorage").Events.UpgradeItem

local advertising_lvl = upgrade_path.Advertising
local uploadspeed_lvl = upgrade_path.UploadSpeedLevel
local harddrive_lvl = upgrade_path.HardDriveLevel

local cash = local_plr.Data.Coins

local auto_farm_enabled = false

local AutoFarmSettings = {
    Belt1 = true,
    Belt2 = false,
    Belt3 = false
}

local AutoFarmSettings2 = {
    hire_friends = false,
    buy_upgrades = false
}

local util_instant_upload = false


-- Actual Script


local function getrandomtycoon()
    for i,v in pairs(game:GetService("Workspace").Tycoons:GetChildren()) do
        if v.Name ~= "CreateStorage" and v.Name ~= "Configuration" then
            if v.TycoonOwner.Value == "p" then
                if v.Claim:FindFirstChild("Claim") then
                    local_plr.Character.HumanoidRootPart.CFrame = v.Claim.Claim.CFrame
                    break
                end
            end
        end
    end
end

local function checksleeping()
    for i,v in pairs(tycoon.Items:GetChildren()) do
        if v.Name ~= "Father" then
            if v.Sleeping.Value == true then
                dropper = v.Noob.Head.CFrame
                local_plr.Character.HumanoidRootPart.CFrame = CFrame.new(dropper["x"], dropper["y"] + 3, dropper["z"])
                task.wait(0.5)
                fireproximityprompt(v.Noob.Torso.ProximityPrompt)
            end
        end
    end
end

task.spawn(function()
    while task.wait() do
        if auto_farm_enabled then
            checksleeping()
            for i,v in pairs(AutoFarmSettings) do
                if v == true then
                    local_plr.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Tycoons[tycoon.Name].StaticItems[tostring(i)].Collect.CollectPart.CFrame + Vector3.new(0, 5, 0)
                    task.wait(0.5)
                    fireproximityprompt(game:GetService("Workspace").Tycoons[tycoon.Name].StaticItems[tostring(i)].Collect.CollectPart.ProximityPrompt)
                    task.wait(0.5)
                    game:GetService("ReplicatedStorage").Events.MemeToStorage:FireServer()
                end
            end
            available_cash = cash.Value
            if AutoFarmSettings2["hire_friends"] then
                for i,v in pairs(tycoon.Purchases:GetChildren()) do
                    if v.Name ~= "HandlePurchases" then
                        if v.Transparency == 0 then
                            if v.Cost.Value < available_cash then
                                local_plr.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                                task.wait(1)
                            end
                        end
                    end
                end
            end
            if AutoFarmSettings2["buy_upgrades"] then
                current_cash = cash.Value
                need_refresh = false
                local function getnum(upgrade_type) local to_convert = string.gsub(upgrade_btns[upgrade_type].Cost.Text, "%D", "") local converted = tonumber(to_convert) if converted then return converted else return math.huge end end
                if current_cash > getnum("Advertising") then
                    upgrade_event:FireServer("Advertising", advertising_lvl.Value)
                    need_refresh = true
                end
                if current_cash > getnum("UploadSpeed") then
                    upgrade_event:FireServer("UploadSpeed", uploadspeed_lvl.Value)
                    need_refresh = true
                end
                if current_cash > getnum("HardDrive") then
                    upgrade_event:FireServer("HardDrive", harddrive_lvl.Value)
                    need_refresh = true
                end
                if need_refresh then
                    local_plr.Character.HumanoidRootPart.CFrame = tycoon.StaticItems.PC.Chair.Seat.CFrame + Vector3.new(0, 3, 0)
                    wait(0.5)
                    fireproximityprompt(tycoon.StaticItems.PC.Prompt.ProximityPrompt)
                    wait(2)
                    local btnevents = {"MouseButton1Click", "MouseButton1Down", "Activated"}
                    for i,v in pairs(btnevents) do
                        for i,v in pairs(getconnections(local_plr.PlayerGui.PcGui2.Exit[v])) do
                            v:Fire()
                        end
                    end
                    task.wait(0.25)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if util_instant_upload then
            game:GetService("ReplicatedStorage").Events.MemeToStorage:FireServer()
            game:GetService("ReplicatedStorage").Events.UploadCurrentMemes:FireServer()
        end
    end
end)

-- Creating UI


local config = {
   ["HeaderWidth"] = 200,
   ["AccentColor"] = Color3.new(0.6,0,0)
}

local gui = loadstring(game:HttpGet("https://gitlab.com/0x45.xyz/droplib/-/raw/master/drop-minified.lua"))():Init(config,game.CoreGui)

local util_tab = gui:CreateCategory("Utility")
local af_tab = gui:CreateCategory("AutoFarm")
local other_tab = gui:CreateCategory("Other")

util_tab:CreateButton("Claim Random Tycoon", getrandomtycoon)

local util_exploits = util_tab:CreateSection("Exploits")

util_exploits:CreateSwitch("Instant Upload", function() if util_instant_upload then util_instant_upload = false else util_instant_upload = true end end)

af_tab:CreateSwitch("Toggle AutoFarm", function() if auto_farm_enabled then auto_farm_enabled = false else auto_farm_enabled = true end end)

local af_settings = af_tab:CreateSection("Settings")

af_settings:CreateSwitch("Toggle Belt 1", function() if AutoFarmSettings["Belt1"] then AutoFarmSettings["Belt1"] = false else AutoFarmSettings["Belt1"] = true end end, true)

af_settings:CreateSwitch("Toggle Belt 2", function() if AutoFarmSettings["Belt2"] then AutoFarmSettings["Belt2"] = false else AutoFarmSettings["Belt2"] = true end end)

af_settings:CreateSwitch("Toggle Belt 3", function() if AutoFarmSettings["Belt3"] then AutoFarmSettings["Belt3"] = false else AutoFarmSettings["Belt3"] = true end end)
    
af_settings:CreateSwitch("Auto Buy Buttons", function() if AutoFarmSettings2["hire_friends"] then AutoFarmSettings2["hire_friends"] = false else AutoFarmSettings2["hire_friends"] = true end end)

af_settings:CreateSwitch("Auto Buy PC Upgrades", function() if AutoFarmSettings2["buy_upgrades"] then AutoFarmSettings2["buy_upgrades"] = false else AutoFarmSettings2["buy_upgrades"] = true end end)

local function self_destruct()
    gui:CleanUp()
    auto_farm_enabled = false
end

other_tab:CreateButton("Remove UI", self_destruct)

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
   wait(1)
   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)