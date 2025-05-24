-- ChatExtensions.lua - Extension module for additional functionality
local ChatExtensions = {}

-- Add typing indicator functionality
function ChatExtensions.addTypingIndicator(chatInstance)
    local typingIndicator = Instance.new("Frame")
    typingIndicator.Name = "TypingIndicator"
    typingIndicator.Size = UDim2.new(0, 200, 0, 40)
    typingIndicator.Position = UDim2.new(0.5, -100, 1, 0)
    typingIndicator.AnchorPoint = Vector2.new(0.5, 0)
    typingIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    typingIndicator.BackgroundTransparency = 0.98
    typingIndicator.BorderSizePixel = 0
    typingIndicator.Visible = false
    typingIndicator.ZIndex = 25
    typingIndicator.Parent = chatInstance.ui.mainFrame
    
    chatInstance.ui.typingIndicator = typingIndicator
    
    function chatInstance:showTypingIndicator()
        self.ui.typingIndicator.Visible = true
        self.ui.typingIndicator.Position = UDim2.new(0.5, -100, 1, 0)
        
        local showTween = game:GetService("TweenService"):Create(self.ui.typingIndicator, 
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -100, 1, -60)
        })
        showTween:Play()
    end
    
    function chatInstance:hideTypingIndicator()
        local hideTween = game:GetService("TweenService"):Create(self.ui.typingIndicator, 
            TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -100, 1, 0)
        })
        hideTween:Play()
        hideTween.Completed:Connect(function()
            self.ui.typingIndicator.Visible = false
        end)
    end
end

-- Add chat history sidebar
function ChatExtensions.addChatSidebar(chatInstance)
    local chatSidebar = Instance.new("Frame")
    chatSidebar.Name = "ChatSidebar"
    chatSidebar.Size = UDim2.new(0, 300, 1, 0)
    chatSidebar.Position = UDim2.new(0, -250, 0, 0)
    chatSidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    chatSidebar.BackgroundTransparency = 0.1
    chatSidebar.BorderSizePixel = 0
    chatSidebar.ZIndex = 30
    chatSidebar.Parent = chatInstance.ui.mainFrame
    
    chatInstance.ui.chatSidebar = chatSidebar
    
    function chatInstance:toggleSidebar()
        self.sidebarOpen = not self.sidebarOpen
        local targetPosition = self.sidebarOpen and UDim2.new(0, 0, 0, 0) or UDim2.new(0, -250, 0, 0)
        
        local sidebarTween = game:GetService("TweenService"):Create(self.ui.chatSidebar, 
            TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = targetPosition
        })
        sidebarTween:Play()
    end
end

-- Add voice input functionality
function ChatExtensions.addVoiceInput(chatInstance)
    function chatInstance:startVoiceInput()
        print("Voice input started (placeholder)")
        -- Implement voice recognition here
    end
    
    function chatInstance:stopVoiceInput()
        print("Voice input stopped (placeholder)")
        -- Stop voice recognition here
    end
end

return ChatExtensions