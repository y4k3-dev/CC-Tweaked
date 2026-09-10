local URL = "wss://mg4fbsm9-8080.uks1.devtunnels.ms/"
local HEARTBEAT_INTERVAL = 32

-- 1. Payload Builders
local function buildHandshake()
    return textutils.serializeJSON({
        type = "handshake",
        id = os.getComputerID(),
        label = os.getComputerLabel() or ("turtle_" .. os.getComputerID()),
        fuel = turtle.getFuelLevel(),
        fuelLimit = turtle.getFuelLimit()
    })
end

local function buildStatusReport(success)
    return textutils.serializeJSON({
        type = "status",
        id = os.getComputerID(),
        fuel = turtle.getFuelLevel(),
        success = success
    })
end

-- 2. Command Execution
local function handleMessage(ws, message)
    local func, syntax_err = load(message, "remote", "t", _ENV)
    
    if not func then
        print("Syntax Error: " .. tostring(syntax_err))
        return
    end

    local success, run_err = pcall(func)
    if not success then
        print("Error running command: " .. tostring(run_err))
    end
    
    ws.send(buildStatusReport(success))
end

-- 3. Concurrent Threads
local function receiveLoop(ws)
    while true do
        local message = ws.receive() 
        if not message then
            print("Connection closed by server.")
            break -- Breaks this loop, causing parallel.waitForAny to finish
        end
        handleMessage(ws, message)
    end
end

local function heartbeatLoop(ws)
    while true do
        sleep(HEARTBEAT_INTERVAL)
        ws.send(buildHandshake())
        print("Heartbeat handshake sent.")
    end
end

-- 4. Main Connection Manager
local function main()
    while true do
        print("Connecting to Swarm...")
        local ws, err = http.websocket(URL)
        
        if ws then
            print("Connected! Awaiting instructions.")
            ws.send(buildHandshake())
            
            -- Runs both functions simultaneously. 
            -- If the connection dies, receiveLoop breaks, taking heartbeatLoop down with it.
            parallel.waitForAny(
                function() receiveLoop(ws) end,
                function() heartbeatLoop(ws) end
            )
            
            ws.close()
        else
            print("Connection failed: " .. tostring(err))
        end
        
        print("Reconnecting in 5 seconds...")
        sleep(5)
    end
end

main()