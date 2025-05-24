-- ChatLibrary.lua - Modular AI Chat Interface Library
local ChatLibrary = {}
ChatLibrary.__index = ChatLibrary

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Default configuration
local DEFAULT_CONFIG = {
    colors = {
        background = Color3.fromRGB(0, 0, 0),
        primary = Color3.fromRGB(139, 69, 255),
        secondary = Color3.fromRGB(99, 102, 255),
        accent = Color3.fromRGB(217, 70, 239),
        text = Color3.fromRGB(255, 255, 255)
    },
    animations = {
        duration = 0.3,
        easing = Enum.EasingStyle.Quad
    },
    ui = {
        cornerRadius = 16,
        transparency = 0.98,
        strokeTransparency = 0.95
    }
}

-- Constructor
function ChatLibrary.new(config)
    local self = setmetatable({}, ChatLibrary)
    
    -- Merge config with defaults
    self.config = {}
    for key, value in pairs(DEFAULT_CONFIG) do
        if config and config[key] then
            if type(value) == "table" then
                self.config[key] = {}
                for subKey, subValue in pairs(value) do
                    self.config[key][subKey] = (config[key][subKey] ~= nil) and config[key][subKey] or subValue
                end
            else
                self.config[key] = config[key]
            end
        else
            self.config[key] = value
        end
    end
    
    -- Initialize state
    self.player = Players.LocalPlayer
    self.playerGui = self.player:WaitForChild("PlayerGui")
    self.chats = {}
    self.currentChatId = nil
    self.chatIdCounter = 0
    self.isInChatMode = false
    self.sidebarOpen = false
    
    -- Event callbacks
    self.callbacks = {
        onMessageSent = nil,
        onChatCreated = nil,
        onChatSwitched = nil,
        onCommandExecuted = nil
    }
    
    -- UI References
    self.ui = {}
    
    return self
end

-- Event system
function ChatLibrary:on(event, callback)
    if self.callbacks[event] ~= nil then
        self.callbacks[event] = callback
    else
        warn("Unknown event: " .. tostring(event))
    end
end

function ChatLibrary:emit(event, ...)
    if self.callbacks[event] then
        self.callbacks[event](...)
    end
end

-- UI Creation Methods
function ChatLibrary:createRadialGradientBlob(parent, color, baseSize, position, animationDuration, delay)
    local blobContainer = Instance.new("Frame")
    blobContainer.Name = "BlobContainer"
    blobContainer.Size = baseSize
    blobContainer.Position = position
    blobContainer.BackgroundTransparency = 1
    blobContainer.BorderSizePixel = 0
    blobContainer.ZIndex = 1
    blobContainer.Parent = parent
    
    local layers = {
        {size = 1.0, transparency = 0.85},
        {size = 1.2, transparency = 0.90},
        {size = 1.4, transparency = 0.93},
        {size = 1.6, transparency = 0.95},
        {size = 1.8, transparency = 0.97},
        {size = 2.0, transparency = 0.98},
        {size = 2.2, transparency = 0.99},
    }
    
    local circles = {}
    
    for i, layer in ipairs(layers) do
        local circle = Instance.new("Frame")
        circle.Name = "GradientLayer" .. i
        circle.Size = UDim2.new(layer.size, 0, layer.size, 0)
        circle.Position = UDim2.new(0.5 - layer.size/2, 0, 0.5 - layer.size/2, 0)
        circle.BackgroundColor3 = color
        circle.BackgroundTransparency = layer.transparency
        circle.BorderSizePixel = 0
        circle.ZIndex = blobContainer.ZIndex - i
        circle.Parent = blobContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle
        
        table.insert(circles, circle)
    end
    
    spawn(function()
        wait(delay)
        
        local endPosition = UDim2.new(position.X.Scale + 0.05, position.X.Offset, 
                                     position.Y.Scale + 0.05, position.Y.Offset)
        
        local moveTween = TweenService:Create(blobContainer, 
            TweenInfo.new(animationDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), 
            {Position = endPosition})
        moveTween:Play()
        
        for i, circle in ipairs(circles) do
            local originalTransparency = layers[i].transparency
            local pulseTween = TweenService:Create(circle, 
                TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), 
                {BackgroundTransparency = math.min(originalTransparency + 0.02, 0.99)})
            pulseTween:Play()
        end
    end)
    
    return blobContainer
end

function ChatLibrary:createMainFrame()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AIChat"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = self.playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.Position = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundColor3 = self.config.colors.background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    self.ui.screenGui = screenGui
    self.ui.mainFrame = mainFrame
    
    return mainFrame
end

function ChatLibrary:createBackgroundBlobs()
    spawn(function()
        self:createRadialGradientBlob(self.ui.mainFrame, self.config.colors.primary, 
            UDim2.new(0, 384, 0, 384), UDim2.new(0.25, 0, 0, 0), 8, 0)
    end)
    
    spawn(function()
        self:createRadialGradientBlob(self.ui.mainFrame, self.config.colors.secondary, 
            UDim2.new(0, 384, 0, 384), UDim2.new(0.75, -384, 1, -384), 10, 0.7)
    end)
    
    spawn(function()
        self:createRadialGradientBlob(self.ui.mainFrame, self.config.colors.accent, 
            UDim2.new(0, 256, 0, 256), UDim2.new(0.66, 0, 0.25, 0), 6, 1)
    end)
end

function ChatLibrary:createCenterContainer()
    local centerContainer = Instance.new("Frame")
    centerContainer.Name = "CenterContainer"
    centerContainer.Size = UDim2.new(0, 672, 0, 600)
    centerContainer.Position = UDim2.new(0.5, -336, 0.5, -300)
    centerContainer.BackgroundTransparency = 1
    centerContainer.ZIndex = 10
    centerContainer.Parent = self.ui.mainFrame
    
    self.ui.centerContainer = centerContainer
    return centerContainer
end

function ChatLibrary:createTitleSection()
    local titleContainer = Instance.new("Frame")
    titleContainer.Name = "TitleContainer"
    titleContainer.Size = UDim2.new(1, 0, 0, 100)
    titleContainer.Position = UDim2.new(0, 0, 0, 0)
    titleContainer.BackgroundTransparency = 1
    titleContainer.Parent = self.ui.centerContainer
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "How can I help today?"
    titleLabel.TextColor3 = self.config.colors.text
    titleLabel.TextSize = 36
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = titleContainer
    
    local underline = Instance.new("Frame")
    underline.Name = "Underline"
    underline.Size = UDim2.new(0, 0, 0, 1)
    underline.Position = UDim2.new(0.5, 0, 0, 65)
    underline.AnchorPoint = Vector2.new(0.5, 0)
    underline.BackgroundColor3 = self.config.colors.text
    underline.BackgroundTransparency = 0.8
    underline.BorderSizePixel = 0
    underline.Parent = titleContainer
    
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "Subtitle"
    subtitleLabel.Size = UDim2.new(1, 0, 0, 20)
    subtitleLabel.Position = UDim2.new(0, 0, 0, 75)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "This is only a template"
    subtitleLabel.TextColor3 = self.config.colors.text
    subtitleLabel.TextTransparency = 0.4
    subtitleLabel.TextSize = 14
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    subtitleLabel.Parent = titleContainer
    
    self.ui.titleContainer = titleContainer
    self.ui.titleLabel = titleLabel
    self.ui.underline = underline
    self.ui.subtitleLabel = subtitleLabel
end

function ChatLibrary:createInputContainer()
    local inputContainer = Instance.new("Frame")
    inputContainer.Name = "InputContainer"
    inputContainer.Size = UDim2.new(1, 0, 0, 140)
    inputContainer.Position = UDim2.new(0, 0, 0, 150)
    inputContainer.BackgroundColor3 = self.config.colors.text
    inputContainer.BackgroundTransparency = self.config.ui.transparency
    inputContainer.BorderSizePixel = 0
    inputContainer.ZIndex = 15
    inputContainer.Parent = self.ui.centerContainer
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, self.config.ui.cornerRadius)
    inputCorner.Parent = inputContainer
    
    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = self.config.colors.text
    inputStroke.Transparency = self.config.ui.strokeTransparency
    inputStroke.Thickness = 1
    inputStroke.Parent = inputContainer
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextInput"
    textBox.Size = UDim2.new(1, -32, 0, 60)
    textBox.Position = UDim2.new(0, 16, 0, 16)
    textBox.BackgroundTransparency = 1
    textBox.Text = ""
    textBox.PlaceholderText = "Ask Template AI a question..."
    textBox.TextColor3 = self.config.colors.text
    textBox.TextTransparency = 0
    textBox.PlaceholderColor3 = self.config.colors.text
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Gotham
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.MultiLine = true
    textBox.TextWrapped = true
    textBox.ClearTextOnFocus = false
    textBox.Parent = inputContainer
    
    self.ui.inputContainer = inputContainer
    self.ui.textBox = textBox
    self.ui.inputStroke = inputStroke
    
    self:setupInputEvents()
end

function ChatLibrary:setupInputEvents()
    local textBox = self.ui.textBox
    
    textBox.Focused:Connect(function()
        local focusTween = TweenService:Create(self.ui.inputStroke, TweenInfo.new(0.2), {
            Transparency = 0.7,
            Color = self.config.colors.primary
        })
        focusTween:Play()
    end)
    
    textBox.FocusLost:Connect(function()
        local unfocusTween = TweenService:Create(self.ui.inputStroke, TweenInfo.new(0.2), {
            Transparency = self.config.ui.strokeTransparency,
            Color = self.config.colors.text
        })
        unfocusTween:Play()
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Return and textBox:IsFocused() then
            self:sendMessage()
        end
    end)
end

-- Chat Management Methods
function ChatLibrary:createNewChat(firstMessage)
    self.chatIdCounter = self.chatIdCounter + 1
    local chatId = self.chatIdCounter
    
    self.chats[chatId] = {
        title = firstMessage:sub(1, 30) .. (firstMessage:len() > 30 and "..." or ""),
        messages = {}
    }
    
    self.currentChatId = chatId
    self:emit("onChatCreated", chatId, self.chats[chatId])
    
    return chatId
end

function ChatLibrary:addMessage(message, isUser, chatId)
    chatId = chatId or self.currentChatId
    if chatId and self.chats[chatId] then
        table.insert(self.chats[chatId].messages, {
            text = message,
            isUser = isUser,
            timestamp = tick()
        })
    end
end

function ChatLibrary:sendMessage()
    local message = self.ui.textBox.Text
    if message:len() > 0 then
        if not self.currentChatId then
            self:createNewChat(message)
        end
        
        self:addMessage(message, true)
        self:emit("onMessageSent", message, self.currentChatId)
        
        self.ui.textBox.Text = ""
        
        if not self.isInChatMode then
            self:transitionToChatMode()
        end
    end
end

function ChatLibrary:transitionToChatMode()
    if self.isInChatMode then return end
    self.isInChatMode = true
    
    local titleFade = TweenService:Create(self.ui.titleLabel, TweenInfo.new(0.3), {
        TextTransparency = 1
    })
    local subtitleFade = TweenService:Create(self.ui.subtitleLabel, TweenInfo.new(0.3), {
        TextTransparency = 1
    })
    local underlineFade = TweenService:Create(self.ui.underline, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 1)
    })
    
    titleFade:Play()
    subtitleFade:Play()
    underlineFade:Play()
    
    wait(0.2)
    local inputMove = TweenService:Create(self.ui.inputContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -336, 1, -160),
        AnchorPoint = Vector2.new(0.5, 0)
    })
    inputMove:Play()
    
    local centerMove = TweenService:Create(self.ui.centerContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -336, 0.5, -200)
    })
    centerMove:Play()
end

-- Animation Methods
function ChatLibrary:animateEntrance()
    self.ui.titleLabel.TextTransparency = 1
    self.ui.subtitleLabel.TextTransparency = 1
    self.ui.underline.Size = UDim2.new(0, 0, 0, 1)
    self.ui.inputContainer.Size = UDim2.new(1, 0, 0, 0)
    
    wait(0.2)
    local titleTween = TweenService:Create(self.ui.titleLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    })
    titleTween:Play()
    
    wait(0.3)
    local underlineTween = TweenService:Create(self.ui.underline, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, 1)
    })
    underlineTween:Play()
    
    wait(0.1)
    local subtitleTween = TweenService:Create(self.ui.subtitleLabel, TweenInfo.new(0.5), {
        TextTransparency = 0.4
    })
    subtitleTween:Play()
    
    wait(0.2)
    local inputTween = TweenService:Create(self.ui.inputContainer, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, 140)
    })
    inputTween:Play()
end

-- Public API Methods
function ChatLibrary:initialize()
    self:createMainFrame()
    self:createBackgroundBlobs()
    self:createCenterContainer()
    self:createTitleSection()
    self:createInputContainer()
    
    spawn(function()
        self:animateEntrance()
    end)
end

function ChatLibrary:destroy()
    if self.ui.screenGui then
        self.ui.screenGui:Destroy()
    end
end

function ChatLibrary:getChat(chatId)
    return self.chats[chatId]
end

function ChatLibrary:getAllChats()
    return self.chats
end

function ChatLibrary:getCurrentChat()
    return self.chats[self.currentChatId]
end

function ChatLibrary:setTitle(title)
    if self.ui.titleLabel then
        self.ui.titleLabel.Text = title
    end
end

function ChatLibrary:setSubtitle(subtitle)
    if self.ui.subtitleLabel then
        self.ui.subtitleLabel.Text = subtitle
    end
end

function ChatLibrary:addCustomButton(name, text, callback, position)
    -- Method to add custom buttons to the interface
    -- Implementation would go here
end

function ChatLibrary:addCustomCommand(command, description, callback)
    -- Method to add custom commands
    -- Implementation would go here
end

return ChatLibrary