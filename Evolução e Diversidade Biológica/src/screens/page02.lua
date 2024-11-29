local composer = require("composer")
local scene = composer.newScene()

local buttons = require("src.components.button")
local backgroundMusic, audioHandle, hasPlayedAudio = nil, nil, false
local predator, preyTable, capturedPrey = nil, {}, 0

-- Função para alternar o áudio (ligar/desligar)
local function toggleAudio(soundButton, audioFile)
    if audio.isChannelPlaying(1) then
        audio.stop(1)
        soundButton.fill = {type = "image", filename = "src/assets/Mute.png"}
    else
        audioHandle = audio.play(audioFile, {channel = 1, loops = -1})
        soundButton.fill = {type = "image", filename = "src/assets/Audio.png"}
    end
end

-- Função para criar as presas
local function createPrey(sceneGroup, image, size, speed, isFast)
    local prey = display.newImageRect(sceneGroup, image, size, size)
    prey.x = math.random(display.contentWidth * 0.1, display.contentWidth * 0.9)
    prey.y = math.random(display.contentHeight * 0.7, display.contentHeight * 0.85)
    prey.speed = speed
    prey.isFast = isFast
    prey.escapes = 0
    prey.transition = nil -- Adicionado para controlar transições
    preyTable[#preyTable + 1] = prey
    return prey
end

-- Função de movimento das presas
local function movePrey(prey)
    if prey.escapes >= 4 then
        if prey.transition then transition.cancel(prey.transition) end
        prey.transition = transition.to(prey, {
            x = prey.x + math.random(-50, 50),
            y = -100,
            time = 800, -- Tempo ajustado
            onComplete = function()
                display.remove(prey)
                for i = #preyTable, 1, -1 do
                    if preyTable[i] == prey then
                        table.remove(preyTable, i)
                        break
                    end
                end
                print("A presa veloz fugiu completamente!")
            end
        })
    else
        local xDirection = math.random(-1, 1)
        local yDirection = math.random(-1, 1)
        local newX = math.max(display.contentWidth * 0.1, math.min(prey.x + (xDirection * prey.speed), display.contentWidth * 0.9))
        local newY = math.max(display.contentHeight * 0.7, math.min(prey.y + (yDirection * prey.speed), display.contentHeight * 0.85))
        if prey.transition then transition.cancel(prey.transition) end
        prey.transition = transition.to(prey, {
            x = newX,
            y = newY,
            time = 800, -- Tempo ajustado
            onComplete = function() movePrey(prey) end
        })
    end
end

-- Função de captura das presas
local function capturePrey(target)
    if target.isFast then
        target.escapes = target.escapes + 1
        print("A presa veloz escapou mais uma vez! Esquivas: " .. target.escapes)
        if target.escapes >= 4 then
            movePrey(target) -- Lógica de fuga completa no próximo movimento
        else
            local escapeAngle = math.random(0, 360) * math.pi / 180
            local escapeDistance = 100
            local newX = math.max(display.contentWidth * 0.1, math.min(target.x + math.cos(escapeAngle) * escapeDistance, display.contentWidth * 0.9))
            local newY = math.max(display.contentHeight * 0.7, math.min(target.y + math.sin(escapeAngle) * escapeDistance, display.contentHeight * 0.85))
            if target.transition then transition.cancel(target.transition) end
            target.transition = transition.to(target, {x = newX, y = newY, time = 300})
        end
    else
        display.remove(target)
        for i = #preyTable, 1, -1 do
            if preyTable[i] == target then
                table.remove(preyTable, i)
                break
            end
        end
        capturedPrey = capturedPrey + 1
        print("Presas capturadas: " .. capturedPrey)
    end
end

-- Movimento do predador até o local clicado
local function movePredator(event)
    local targetX = math.max(display.contentWidth * 0.1, math.min(event.x, display.contentWidth * 0.9))
    local targetY = math.max(display.contentHeight * 0.65, math.min(event.y, display.contentHeight * 0.85))

    transition.to(predator, {
        x = targetX,
        y = targetY,
        time = 400,
        onComplete = function()
            for _, prey in ipairs(preyTable) do
                if math.abs(prey.x - predator.x) < 50 and math.abs(prey.y - predator.y) < 50 then
                    capturePrey(prey)
                end
            end
        end
    })
end
Runtime:addEventListener("touch", movePredator)

-- Criar predador, presas e botões
function scene:create(event)
    local sceneGroup = self.view
    local background = display.newImageRect(sceneGroup, "src/assets/pages/page2/page02.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    predator = display.newImageRect(sceneGroup, "src/assets/pages/page2/leao.png", 100, 100)
    predator.x = display.contentCenterX
    predator.y = display.contentHeight * 0.75

    preyTable = {}
    createPrey(sceneGroup, "src/assets/pages/page2/gazela.png", 70, 50, false)
    createPrey(sceneGroup, "src/assets/pages/page2/zebra.png", 80, 60, false)
    createPrey(sceneGroup, "src/assets/pages/page2/veloz.png", 90, 80, true)

    for _, prey in ipairs(preyTable) do
        movePrey(prey)
    end

    buttons.createBackYellowButton(sceneGroup, "src.screens.page01")
    buttons.createNextYellowButton(sceneGroup, "src.screens.page03")

    local soundButton = display.newImageRect(sceneGroup, "src/assets/Audio.png", 48, 48)
    soundButton.x = 45
    soundButton.y = 70
    soundButton:addEventListener("tap", function()
        toggleAudio(soundButton, backgroundMusic)
    end)

    backgroundMusic = audio.loadStream("src/assets/audios/audioPage2.mp3")
    if not hasPlayedAudio then
        audioHandle = audio.play(backgroundMusic, {channel = 1, loops = -1})
        hasPlayedAudio = true
    end
end

function scene:destroy(event)
    for _, prey in ipairs(preyTable) do
        if prey.transition then transition.cancel(prey.transition) end
        display.remove(prey)
    end
    preyTable = {}
    if audioHandle then
        audio.stop(audioHandle)
        audio.dispose(backgroundMusic)
        backgroundMusic = nil
    end
end

function scene:hide(event)
    if event.phase == "will" and audioHandle then
        audio.stop(audioHandle)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("destroy", scene)
scene:addEventListener("hide", scene)

return scene