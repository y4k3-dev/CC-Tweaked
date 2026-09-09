-- Replace with your desktop's IP or Ngrok URL
local url = "wss://mg4fbsm9-8080.uks1.devtunnels.ms/" 

print("Connecting to Swarm Commander...")
local ws, err = http.websocket(url) 

-- The API returns false and an error string if the connection fails
if not ws then 
    print("Connection failed: " .. tostring(err))
    return
end

print("Connected! Awaiting instructions.")

while true do
    -- receive() returns the string message, or nil if the connection drops
    local message, isBinary = ws.receive() 
    
    if message then
        local func, syntax_err = load(message, "remote", "t", _ENV)
        if func then
            local success, run_err = pcall(func)
            if not success then
                print("Error running command: " .. tostring(run_err))
            end
        else
            print("Syntax Error: " .. tostring(syntax_err))
        end
    else
        print("Connection closed by server.")
        break
    end
end

if ws then ws.close() end