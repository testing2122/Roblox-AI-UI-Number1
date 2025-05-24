-- Example usage of the AI Chat UI Library
local ChatLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/Roblox-AI-UI-Number1/main/ChatLibrary.lua"))();
local ChatExtensions = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/Roblox-AI-UI-Number1/main/ChatExtensions.lua"))();

-- Create chat instance with custom config
local chat = ChatLibrary.new({
    colors = {
        background = Color3.fromRGB(10, 10, 15),
        primary = Color3.fromRGB(139, 92, 246),
        secondary = Color3.fromRGB(124, 58, 237),
        accent = Color3.fromRGB(167, 139, 250),
        text = Color3.fromRGB(255, 255, 255)
    },
    ui = {
        cornerRadius = 12,
        transparency = 0.95,
        strokeTransparency = 0.9
    }
});

-- Add extensions
ChatExtensions.addTypingIndicator(chat);
ChatExtensions.addChatSidebar(chat);
ChatExtensions.addVoiceInput(chat);

-- Set up event handlers
chat:on("onMessageSent", function(message, chatId)
    chat:showTypingIndicator();
    
    task.delay(1.5, function()
        chat:hideTypingIndicator();
        chat:addMessage("This is a simulated AI response", false);
    end);
end);

chat:on("onChatCreated", function(chatId, chatData)
    print("New chat created:", chatId);
end);

-- Initialize the UI
chat:initialize();

-- Set custom title and subtitle
chat:setTitle("AI Chat Interface");
chat:setSubtitle("Ask me anything!");

-- Cleanup function if needed
getgenv().destroyChat = function()
    chat:destroy();
end;