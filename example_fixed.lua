-- Fixed example with proper UI initialization
local ChatLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/Roblox-AI-UI-Number1/main/ChatLibrary.lua"))();

-- Create chat instance with custom config
local chat = ChatLibrary.new({
    colors = {
        background = Color3.fromRGB(10, 10, 15),
        primary = Color3.fromRGB(139, 92, 246),
        secondary = Color3.fromRGB(124, 58, 237),
        accent = Color3.fromRGB(167, 139, 250),
        text = Color3.fromRGB(255, 255, 255),
        button = Color3.fromRGB(30, 30, 35),
        buttonHover = Color3.fromRGB(40, 40, 45)
    },
    ui = {
        cornerRadius = 12,
        transparency = 0.95,
        strokeTransparency = 0.9
    }
});

-- Initialize the UI
chat:initialize();

-- Force transition to chat mode to show all elements
chat.isInChatMode = true;

-- Create initial chat
chat:createNewChat("Welcome to AI Chat");
chat:addMessage("Hello! How can I help you today?", false);

-- Add custom buttons
chat:addButton("Copy", function()
    local currentChat = chat:getCurrentChat();
    if currentChat and #currentChat.messages > 0 then
        setclipboard(currentChat.messages[#currentChat.messages].text);
    end
end);

chat:addButton("Clear History", function()
    chat.chats = {};
    chat.chatIdCounter = 0;
    chat.currentChatId = nil;
    chat:createNewChat("New Conversation");
end);

-- Add some example conversations to show the selector
for i = 1, 3 do
    local chatId = chat:createNewChat("Example Chat " .. i);
    chat:addMessage("This is example chat " .. i, false, chatId);
    chat:addConversationItem(chatId, "Example Chat " .. i);
end

-- Show the conversation tab by default
chat.tabOpen = true;
chat:toggleConversationTab();

-- Handle message events
chat:on("onMessageSent", function(message, chatId)
    -- Example response
    wait(0.5); -- Simulate API delay
    chat:addMessage("You said: " .. message, false, chatId);
    
    -- Add conversation to sidebar
    chat:addConversationItem(chatId, message:sub(1, 20) .. "...");
end);

-- Handle chat switching
chat:on("onChatSwitched", function(chatId)
    local selectedChat = chat:getChat(chatId);
    if selectedChat then
        chat:setTitle(selectedChat.title);
    end
end);