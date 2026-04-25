CONFIG = {
    [1] = {
        message =
        "- - > TV Dragon Ball < - -\n\n Para transformar, basta dizer !transformar ou /transformar.",
        color = 22
    },
    [2] = {
        message = "- - > TV Dragon Ball < - -\n\n Para ver os comandos, digite /commands.",
        color = 22
    },
    [3] = {
        message =
        "Para ver seu saldo de banco digite !balance, para depositar digite '!deposit value/all' e para sacar digite '!withdraw value/all'.",
        color = 22
    }
}

function onThink()
    getRandom = math.random(1, #CONFIG)
    message = CONFIG[getRandom].message
    color = CONFIG[getRandom].color
    return doBroadcastMessage(message, color)
end
