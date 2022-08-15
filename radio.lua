radio = {}

radio.messages = {

    [1] = "placeholder: we see you, starting to move",

    [2] = "placeholder: we have spotted a sus car parked 1km in front of the convoy",
    [3] = "placeholder: show of force success they are leaving",

    [4] = "placeholder: the attackers from the city are retreating",
    [5] = "placeholder: the attackers from the forest are retreating",
    [6] = "placeholder: no more fighting, evacuate the wounded",

}

function radio.notify(messageKey)
    --print(radio.messages.messageNumber)
    trigger.action.outText(radio.messages[messageKey], 10)
    trigger.action.outSound("Alert.ogg")
end