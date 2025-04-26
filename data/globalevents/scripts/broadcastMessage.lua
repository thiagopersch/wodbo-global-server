CONFIG = {
    [1] = {
        message = "- - > TV Karakura < - -\n\n Para ver os comandos, digite /commands.",
        color = 22
    },
    [2] = {
        message =
        "- - > Dragon Ball TV < - -\n\n Para transformar, basta dizer transformar 1/!saga 1, transformar 2/!saga 2.",
        color = 22
    },
    [3] = {
        message = "- - > Dragon Ball TV < - -\n\n Para ver os comandos, digite /commands.",
        color = 22
    }
}

function onThink()
    getRandom = math.random(1, #CONFIG)
    return
        doBroadcastMessage(CONFIG[getRandom].message, CONFIG[getRandom].color)
end
