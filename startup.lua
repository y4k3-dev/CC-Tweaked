local url = "wss://mg4fbsm9-8080.uks1.devtunnels.ms/" 

print("Connecting...")
local ws, err = http.websocket(url) 

if not ws then 
    print("Connection failed: " .. tostring(err))
    return
end

print("Connected!")

-- 1. Gather hardware stats
local handshake = {
    type = "handshake",
    id = os.getComputerID(),
    label = os.getComputerLabel() or ("turtle_" .. os.getComputerID()),
    fuel = turtle.getFuelLevel(),
    fuelLimit = turtle.getFuelLimit()
}

ws.send(textutils.serializeJSON(handshake))
print("Handshake sent! Awaiting instructions.")

while true do
    local message, isBinary = ws.receive() 
    
    if message then
        local func, syntax_err = load(message, "remote", "t", _ENV)
        if func then
            local success, run_err = pcall(func)
            if not success then
                print("Error running command: " .. tostring(run_err))
            end
            
            -- Optional: Report updated fuel back after every command
            local report = {
                type = "status",
                id = os.getComputerID(),
                fuel = turtle.getFuelLevel(),
                success = success
            }
            ws.send(textutils.serializeJSON(report))
        else
            print("Syntax Error: " .. tostring(syntax_err))
        end
    else
        print("Connection closed by server.")
        break
    end
end

if ws then ws.close() end