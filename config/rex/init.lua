require("rex-navigator").setup()

rex.bind("cmd+d", "pane.split", { direction = "right" })
rex.bind("shift+cmd+d", "pane.split", { direction = "down" })

rex.bind("cmd+shift+h", "pane.resize", { direction = "left" })
rex.bind("cmd+shift+l", "pane.resize", { direction = "right" })
rex.bind("cmd+shift+j", "pane.resize", { direction = "down" })
rex.bind("cmd+shift+k", "pane.resize", { direction = "up" })
