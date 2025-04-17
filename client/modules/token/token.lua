local currentToken = nil

-- Event handler to receive the token from the server
RegisterNetEvent('ReceiveToken')
AddEventHandler('ReceiveToken', function(token)
    currentToken = token
end)

-- Function to send a secure event to the server
function SendSecureEvent(eventName, data)
    if currentToken then
        TriggerServerEvent(eventName, currentToken, data)
    else
        print("No token received yet.")
    end
end

-- Example usage
SendSecureEvent('secureEvent', {action = 'moneyTransfer', amount = 500})