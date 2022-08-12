radio = {}

radio.messages = {

    [1] = "debug: we see you, starting to move",
    [2] = "debug: we are taking fire from the north and the east",
    [2] = "debug: the attackers from the city are retreating",
    [3] = "debug: the attackers in the forest are retreating",

}

function radio.notify(messageNumber)
    trigger.action.outText(radio.messages.messageNumber, 10)
    trigger.action.outSound("Alert.ogg")
end