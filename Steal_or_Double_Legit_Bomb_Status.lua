-- Steal or Double - Legitimate Bomb Status GUI
-- Displays only status text that is visibly supplied by the game UI.
-- It does NOT predict random outcomes or access hidden server-side state.
-- Use only with UI text you are authorized to read.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GUI_NAME = "StealDoubleStatusGui"
local old = playerGui:FindFirstChild(GUI_NAME)
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(300, 118)
main.Position = UDim2.new(1, -320, 1, -155)
main.BackgroundColor3 = Color3.fromRGB(25, 26, 38)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(105, 90, 210)
stroke.Thickness = 1.5
stroke.Parent = main

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -44, 0, 34)
header.Position = UDim2.fromOffset(12, 4)
header.BackgroundTransparency = 1
header.Font = Enum.Font.GothamBold
header.Text = "💣  BOMB STATUS"
header.TextSize = 15
header.TextColor3 = Color3.fromRGB(245, 245, 255)
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 26)
close.Position = UDim2.new(1, -34, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(190, 65, 80)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextSize = 13
close.Parent = main
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 36)
status.Position = UDim2.fromOffset(12, 40)
status.BackgroundColor3 = Color3.fromRGB(43, 44, 59)
status.BorderSizePixel = 0
status.Font = Enum.Font.GothamBold
status.Text = "WAITING FOR VISIBLE GAME STATUS"
status.TextSize = 12
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(255, 205, 105)
status.Parent = main
Instance.new("UICorner", status).CornerRadius = UDim.new(0, 7)

local detail = Instance.new("TextLabel")
detail.Size = UDim2.new(1, -24, 0, 24)
detail.Position = UDim2.fromOffset(12, 82)
detail.BackgroundTransparency = 1
detail.Font = Enum.Font.Gotham
detail.Text = "No verified result detected"
detail.TextSize = 10
detail.TextColor3 = Color3.fromRGB(170, 170, 190)
detail.TextWrapped = true
detail.Parent = main

-- Search visible UI labels for an explicit, authoritative status message.
-- Deliberately does not interpret odds, money, generic bomb icons, or button text as proof.
local function scanVisibleText()
    local foundSafe, foundUnsafe = false, false
    local evidence = nil

    for _, obj in ipairs(playerGui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            if obj.Visible and obj.Text and obj.Text ~= "" then
                local s = string.lower(obj.Text)
                local mentionsBomb = string.find(s, "bomb", 1, true) ~= nil
                local explicitSafe =
                    string.find(s, "safe to double", 1, true) ~= nil or
                    string.find(s, "double is safe", 1, true) ~= nil or
                    string.find(s, "will not explode", 1, true) ~= nil or
                    string.find(s, "won't explode", 1, true) ~= nil
                local explicitUnsafe =
                    string.find(s, "not safe", 1, true) ~= nil or
                    string.find(s, "will explode", 1, true) ~= nil or
                    string.find(s, "going to explode", 1, true) ~= nil

                if mentionsBomb and explicitSafe then
                    foundSafe = true
                    evidence = obj.Text
                elseif mentionsBomb and explicitUnsafe then
                    foundUnsafe = true
                    evidence = obj.Text
                end
            end
        end
    end

    if foundSafe and not foundUnsafe then
        status.Text = "SAFE"
        status.TextColor3 = Color3.fromRGB(110, 240, 165)
        detail.Text = "Visible game text: " .. string.sub(evidence or "", 1, 60)
    elseif foundUnsafe and not foundSafe then
        status.Text = "NOT SAFE"
        status.TextColor3 = Color3.fromRGB(255, 125, 135)
        detail.Text = "Visible game text: " .. string.sub(evidence or "", 1, 60)
    else
        status.Text = "UNVERIFIED"
        status.TextColor3 = Color3.fromRGB(255, 205, 105)
        detail.Text = "No explicit bomb result visible"
    end
end

-- Re-scan when the game UI changes. No hidden state or prediction is used.
playerGui.DescendantAdded:Connect(function()
    task.defer(scanVisibleText)
end)
playerGui.DescendantRemoving:Connect(function()
    task.defer(scanVisibleText)
end)

task.spawn(function()
    while gui.Parent do
        scanVisibleText()
        task.wait(0.5)
    end
end)
