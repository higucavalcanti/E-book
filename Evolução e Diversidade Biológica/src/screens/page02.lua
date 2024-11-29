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
    preyTable[#preyTable + 1] = prey
    return prey
end

-- Função de movimento das presas
local function movePrey(prey)
    if prey.escapes >= 2 then
        -- Remove a presa ao escapar
        transition.to(prey, {
            x = prey.x + math.random(-50, 50),
            y = -100,
            time = 1000,
            onComplete = function()
                display.remove(prey)
                for i = #preyTable, 1, -1 do
                    if preyTable[i] == prey then
                        table.remove(preyTable, i)
                        break
                    end
                end
                print("A presa veloz sobreviveu e escapou!")
            end
        })
    else
        -- Movimento aleatório da presa
        local xDirection = math.random(-1, 1)
        local yDirection = math.random(-1, 1)
        local newX = math.max(display.contentWidth * 0.1, math.min(prey.x + (xDirection * prey.speed), display.contentWidth * 0.9))
        local newY = math.max(display.contentHeight * 0.7, math.min(prey.y + (yDirection * prey.speed), display.contentHeight * 0.85))
        transition.to(prey, {
            x = newX,
            y = newY,
            time = 1000,
            onComplete = function() movePrey(prey) end
        })
    end
end

-- Função de captura das presas
local function capturePrey(target)
    if target.isFast then
        target.escapes = target.escapes + 1
        print("A presa veloz escapou mais uma vez!")
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

local isMoving = false -- Flag para controlar o movimento do predador

local function movePredator(event)
    if event.phase == "began" and not isMoving then
        isMoving = true -- Impede novos movimentos enquanto o atual não termina

        local targetX = math.max(display.contentWidth * 0.1, math.min(event.x, display.contentWidth * 0.9))
        local targetY = math.max(display.contentHeight * 0.7, math.min(event.y, display.contentHeight * 0.85))

        transition.to(predator, {
            x = targetX,
            y = targetY,
            time = 300,
            onComplete = function()
                -- Checa se capturou alguma presa
                for _, prey in ipairs(preyTable) do
                    if math.abs(prey.x - predator.x) < 50 and math.abs(prey.y - predator.y) < 50 then
                        capturePrey(prey)
                    end
                end
                isMoving = false -- Libera o movimento novamente
            end
        })
    end
    return true -- Permite que o evento não interfira em outros objetos
end

-- Criar predador, presas e botões
function scene:create(event)
    local sceneGroup = self.view

    -- Fundo
    local background = display.newImageRect(sceneGroup, "src/assets/pages/page2/page02.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Área de interação (toda a tela)
    local interactionArea = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    interactionArea:setFillColor(0, 0, 0, 0) -- Transparente

    -- Predador
    predator = display.newImageRect(sceneGroup, "src/assets/pages/page2/leao.png", 100, 100)
    predator.x = display.contentCenterX
    predator.y = display.contentHeight * 0.75

    -- Presas
    preyTable = {}
    createPrey(sceneGroup, "src/assets/pages/page2/gazela.png", 70, 50, false)
    createPrey(sceneGroup, "src/assets/pages/page2/zebra.png", 80, 60, false)
    createPrey(sceneGroup, "src/assets/pages/page2/veloz.png", 90, 80, true)

    -- Movimento das presas
    for _, prey in ipairs(preyTable) do
        movePrey(prey)
    end

    -- Botões de navegação
    buttons.createBackYellowButton(sceneGroup, "src.screens.page01")
    buttons.createNextYellowButton(sceneGroup, "src.screens.page03")

    -- Botão de som
    local soundButton = display.newImageRect(sceneGroup, "src/assets/Audio.png", 48, 48)
    soundButton.x = 45
    soundButton.y = 70
    soundButton:addEventListener("tap", function()
        toggleAudio(soundButton, backgroundMusic)
    end)

    -- Evento de toque para mover o predador
    interactionArea:addEventListener("touch", function(event)
        if event.phase == "began" or event.phase == "moved" then
            movePredator(event)
        end
        return true
    end)

    -- Áudio
    backgroundMusic = audio.loadStream("src/assets/audios/audioPage2.mp3")
    if not hasPlayedAudio then
        audioHandle = audio.play(backgroundMusic, {channel = 1, loops = -1})
        hasPlayedAudio = true
    end
end

-- Limpeza de recursos
function scene:destroy(event)
    for _, prey in ipairs(preyTable) do
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