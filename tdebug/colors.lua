local colors = require 'term.colors'

-- colored text output wrappers

return {
    blue = colors.blue,
    yellow = colors.yellow,
    red = colors.red,
    grey = function(text)
        return colors.bright(colors.black(text))
    end
}

