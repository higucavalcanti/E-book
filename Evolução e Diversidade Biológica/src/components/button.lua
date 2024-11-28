local composer = require("composer")
local buttons = {}

-- botão "Próximo Amarelo"
function buttons.createNextYellowButton(sceneGroup, nextPage)
    local nextYellowButton = display.newImageRect(sceneGroup, "src/assets/ProximoAmarelo.png", 106, 40)
    nextYellowButton.x = 643
    nextYellowButton.y = 933
    nextYellowButton:addEventListener("tap", function()
        composer.gotoScene(nextPage)
    end)
    return nextYellowButton
end

-- botão "Próximo Azul"
function buttons.createNextBlueButton(sceneGroup, nextPage)
    local nextBlueButton = display.newImageRect(sceneGroup, "src/assets/ProximoAzul.png", 106, 40)
    nextBlueButton.x = 643
    nextBlueButton.y = 933
    nextBlueButton:addEventListener("tap", function()
        composer.gotoScene(nextPage)
    end)
    return nextBlueButton
end

-- botão "Voltar Azul"
function buttons.createBackBlueButton(sceneGroup, prevPage)
    local backBlueButton = display.newImageRect(sceneGroup, "src/assets/VoltarAzul.png", 106, 40)
    backBlueButton.x = 103
    backBlueButton.y = 933
    backBlueButton:addEventListener("tap", function()
        composer.gotoScene(prevPage)
    end)
    return backBlueButton
end

-- botão "Voltar Amarelo"
function buttons.createBackYellowButton(sceneGroup, prevPage)
    local backYellowButton = display.newImageRect(sceneGroup, "src/assets/VoltarAmarelo.png", 106, 40)
    backYellowButton.x = 103
    backYellowButton.y = 933
    backYellowButton:addEventListener("tap", function()
        composer.gotoScene(prevPage)
    end)
    return backYellowButton
end

-- botão "Início"
function buttons.createInitialButton(sceneGroup, initialPage)
    local initialButton = display.newImageRect(sceneGroup, "src/assets/InitialButton.png", 106, 40)
    initialButton.x = 643
    initialButton.y = 933
    initialButton:addEventListener("tap", function()
        composer.gotoScene(initialPage)
    end)
    return initialButton
end

return buttons