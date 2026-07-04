local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Clean up existing calculator
if CoreGui:FindFirstChild("Calculator") then 
    CoreGui.Calculator:Destroy() 
end

-- Create main ScreenGui
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Calculator"
ScreenGui.ResetOnSpawn = false

-- Create main frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

-- Create display
local Display = Instance.new("TextBox", MainFrame)
Display.Size = UDim2.new(1, -20, 0, 80)
Display.Position = UDim2.new(0, 10, 0, 10)
Display.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Display.TextColor3 = Color3.new(1, 1, 1)
Display.TextSize = 40
Display.Font = Enum.Font.GothamBold
Display.Text = "0"
Display.TextXAlignment = Enum.TextXAlignment.Right
Display.TextYAlignment = Enum.TextYAlignment.Center
Display.ClearTextOnFocus = false
Display.BorderSizePixel = 0
Instance.new("UICorner", Display).CornerRadius = UDim.new(0, 10)

-- Create button grid
local ButtonGrid = Instance.new("Frame", MainFrame)
ButtonGrid.Size = UDim2.new(1, -20, 1, -110)
ButtonGrid.Position = UDim2.new(0, 10, 0, 100)
ButtonGrid.BackgroundTransparency = 1
ButtonGrid.BorderSizePixel = 0

local UIGridLayout = Instance.new("UIGridLayout", ButtonGrid)
UIGridLayout.CellSize = UDim2.new(0.22, 0, 0.2, 0)
UIGridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
UIGridLayout.FillDirection = Enum.FillDirection.Row
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Color scheme
local NumberColor = Color3.fromRGB(70, 70, 70)
local OperatorColor = Color3.fromRGB(255, 159, 10)
local FunctionColor = Color3.fromRGB(60, 60, 60)
local TextColor = Color3.new(1, 1, 1)

-- Create button function
local function CreateButton(text, bgColor, onClick)
    local Button = Instance.new("TextButton", ButtonGrid)
    Button.Size = UDim2.new(0.22, 0, 0.2, 0)
    Button.BackgroundColor3 = bgColor
    Button.Text = text
    Button.TextColor3 = TextColor
    Button.TextSize = 20
    Button.Font = Enum.Font.GothamBold
    Button.BorderSizePixel = 0
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
    
    Button.MouseButton1Click:Connect(onClick)
    
    -- Hover effect
    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(
            math.min(255, bgColor.R * 255 + 30),
            math.min(255, bgColor.G * 255 + 30),
            math.min(255, bgColor.B * 255 + 30)
        )
    end)
    
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = bgColor
    end)
    
    return Button
end

-- Calculator logic
local function Calculate(expression)
    -- Replace display symbols with operators
    expression = expression:gsub("×", "*")
    expression = expression:gsub("÷", "/")
    expression = expression:gsub("−", "-")
    
    -- Use pcall to safely evaluate
    local success, result = pcall(function()
        return loadstring("return " .. expression)()
    end)
    
    if success and result then
        return tostring(result)
    else
        return "Error"
    end
end

-- Button layout: 4 columns, 5 rows
local buttons = {
    -- Row 1
    {"C", FunctionColor},
    {"⌫", FunctionColor},
    {"%", OperatorColor},
    {"÷", OperatorColor},
    -- Row 2
    {"7", NumberColor},
    {"8", NumberColor},
    {"9", NumberColor},
    {"×", OperatorColor},
    -- Row 3
    {"4", NumberColor},
    {"5", NumberColor},
    {"6", NumberColor},
    {"−", OperatorColor},
    -- Row 4
    {"1", NumberColor},
    {"2", NumberColor},
    {"3", NumberColor},
    {"+", OperatorColor},
    -- Row 5
    {"0", NumberColor},
    {".", NumberColor},
    {"=", OperatorColor},
}

-- Create all buttons
for _, buttonData in ipairs(buttons) do
    local text, color = buttonData[1], buttonData[2]
    
    CreateButton(text, color, function()
        if text == "C" then
            Display.Text = "0"
        elseif text == "⌫" then
            if Display.Text ~= "0" then
                Display.Text = Display.Text:sub(1, -2)
                if Display.Text == "" then
                    Display.Text = "0"
                end
            end
        elseif text == "=" then
            local result = Calculate(Display.Text)
            Display.Text = result
        else
            if Display.Text == "0" and text ~= "." then
                Display.Text = text
            else
                Display.Text = Display.Text .. text
            end
        end
    end)
end

-- Make it draggable
local dragging = false
local dragStart = nil
local startPos = nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("Calculator loaded! You can drag it around.")
