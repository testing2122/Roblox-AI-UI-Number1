-- Multi-chat example showing how to create and switch between chats
local ChatLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/Roblox-AI-UI-Number1/main/ChatLibrary.lua"))();
local ChatExtensions = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/Roblox-AI-UI-Number1/main/ChatExtensions.lua"))();

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
        cornerRadius = 20, -- More rounded corners
        transparency = 0.95,
        strokeTransparency = 0.9,
        chatBoxWidth = 450 -- Smaller width for chat box
    }
});

-- Initialize the UI
chat:initialize();

-- Add extensions
ChatExtensions.addTypingIndicator(chat);
ChatExtensions.addChatSidebar(chat);
ChatExtensions.addVoiceInput(chat);

-- Add New Chat button
chat:addButton("New Chat", function()
    chat:createNewChat("New Conversation");
    chat:addConversationItem(chat.currentChatId, "New Conversation");
    chat:setTitle("New Conversation");
    chat:setSubtitle("Start typing to chat");
    chat:addMessage("How can I assist you with this new conversation?", false);
    
    -- If conversation tab isn't open, open it
    if not chat.tabOpen then
        chat:toggleConversationTab();
    end
 end);

-- Add Toggle Sidebar button
chat:addButton("Chats", function()
    chat:toggleConversationTab();
end);

-- Create initial chats
local initialChats = {
    {title = "General Assistance", message = "Welcome! I'm here to help with any questions you might have."},
    {title = "Code Helper", message = "Need help with coding? Ask me any programming questions!"},
    {title = "Creative Ideas", message = "Looking for creative inspiration? Let's brainstorm together!"}
};

for i, chatInfo in ipairs(initialChats) do
    local chatId = chat:createNewChat(chatInfo.title);
    chat:addMessage(chatInfo.message, false, chatId);
    chat:addConversationItem(chatId, chatInfo.title);
    
    -- Set first chat as active
    if i == 1 then
        chat.currentChatId = chatId;
        chat:setTitle(chatInfo.title);
        chat:setSubtitle("Active conversation");
    end
end

-- Set up event handlers
chat:on("onMessageSent", function(message, chatId)
    chat:showTypingIndicator();
    
    -- Simulate AI thinking time
    task.delay(1.2, function()
        chat:hideTypingIndicator();
        
        -- Example responses based on message content
        local responses = {
            ["hello"] = "Hello there! How can I help you today?",
            ["help"] = "I'm here to assist you. What do you need help with?",
            ["thanks"] = "You're welcome! Is there anything else you'd like to know?"
        };
        
        local responseText = "I received your message: '" .. message .. "'. How can I help further?";
        
        -- Check for keyword matches
        for keyword, response in pairs(responses) do
            if string.find(string.lower(message), keyword) then
                responseText = response;
                break;
            end
        end
        
        chat:addMessage(responseText, false, chatId);
        
        -- Update conversation list with first part of message
        local shortTitle = message:sub(1, 25) .. (message:len() > 25 and "..." or "");
        chat:addConversationItem(chatId, shortTitle);
    end);
end);

-- Handle chat switching
chat:on("onChatSwitched", function(chatId)
    local selectedChat = chat:getChat(chatId);
    if selectedChat then
        chat:setTitle(selectedChat.title);
        chat:setSubtitle("Active conversation");
        
        -- Enable the highlight for current chat
        for id, item in pairs(chat.conversationItems) do
            if item.highlight then
                item.highlight.Visible = (id == chatId);
            end
        end
    end
end);

-- Make the conversation tab visible by default
chat.tabOpen = true;
chat:toggleConversationTab();

-- Force transition to chat mode to show all elements
chat.isInChatMode = true;
chat:transitionToChatMode();

-- Toggle the tab after a delay to show it's a feature
task.delay(2, function()
    chat:toggleConversationTab();
    
    task.delay(1, function()
        chat:toggleConversationTab();
    end);
end);

-- Helper function to manually create a new chat from exploits
getgenv().createNewChat = function(title)
    local chatId = chat:createNewChat(title or "New Chat");
    chat:addConversationItem(chatId, title or "New Chat");
    chat:addMessage("This is a new conversation. How can I help?", false, chatId);
    return chatId;
end

-- Helper function to switch chats
getgenv().switchChat = function(chatId)
    if chat.chats[chatId] then
        chat.currentChatId = chatId;
        chat:emit("onChatSwitched", chatId);
    end
end

-- Helper function to send a message to the current chat
getgenv().sendMessage = function(text)
    if text and text:len() > 0 then
        chat.ui.textBox.Text = text;
        chat:sendMessage();
    end
end

-- Cleanup function
getgenv().destroyChat = function()
    chat:destroy();
end