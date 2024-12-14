local composer = require("composer")
local scene = composer.newScene()

local buttons = require("src.components.button")
local audioHandle
local backgroundMusic
local hasPlayedAudio = false

local function toggleAudio(soundButton, audioFile)
    if audio.isChannelPlaying(1) then
        audio.stop(1)
        soundButton.fill = {type = "image", filename = "src/assets/Mute.png"}
    else
        audioHandle = audio.play(audioFile, {channel = 1, loops = 0})
        soundButton.fill = {type = "image", filename = "src/assets/Audio.png"}
    end
end

-- Ativa o multitouch
system.activate("multitouch")

-- Grupo para gerenciar os passarinhos
local birdGroup

-- Imagens dos passarinhos
local blueBirdImage = "src/assets/pages/page5/Blue-Bird.png"
local pinkBirdImage = "src/assets/pages/page5/Pink-Bird.png"

-- Função para criar os passarinhos iniciais
local function createInitialBirds(sceneGroup)
    -- Remove todos os passarinhos existentes
    if birdGroup then
        birdGroup:removeSelf()
    end
    birdGroup = display.newGroup()
    sceneGroup:insert(birdGroup)

    -- Blue Bird
    local blueBird = display.newImageRect(birdGroup, blueBirdImage, 80, 80)
    blueBird.x, blueBird.y = display.contentCenterX - 50, display.contentCenterY + 200
    blueBird.type = "blue"

    -- Pink Bird
    local pinkBird = display.newImageRect(birdGroup, pinkBirdImage, 80, 80)
    pinkBird.x, pinkBird.y = display.contentCenterX + 50, display.contentCenterY + 200
    pinkBird.type = "pink"

    -- Animação de balanço
    transition.to(blueBird, {rotation = -10, time = 800, iterations = 0, transition = easing.continuousLoop})
    transition.to(pinkBird, {rotation = 10, time = 800, iterations = 0, transition = easing.continuousLoop})
end

-- Função para gerar novos passarinhos
local function createNewBirdPair()
    local birdX, birdY

    -- Gera posição aleatória segura
    repeat
        birdX = math.random(60, display.contentWidth - 60)
        birdY = math.random(250, display.contentHeight - 120)
    until not (birdX > 30 and birdX < 150 and birdY > 30 and birdY < 170) -- Ajuste do limite dos botões e imagem de instrução

    -- Blue Bird
    local blueBird = display.newImageRect(birdGroup, blueBirdImage, 80, 80)
    blueBird.x, blueBird.y = birdX - 50, birdY
    blueBird.type = "blue"
    transition.to(blueBird, {rotation = -10, time = 800, iterations = 0, transition = easing.continuousLoop})

    -- Pink Bird
    local pinkBird = display.newImageRect(birdGroup, pinkBirdImage, 80, 80)
    pinkBird.x, pinkBird.y = birdX + 50, birdY
    pinkBird.type = "pink"
    transition.to(pinkBird, {rotation = 10, time = 800, iterations = 0, transition = easing.continuousLoop})
end

-- Listener para interação de toque com gesto de pinça
local function onPinch(event)
    local target = event.target
    local phase = event.phase

    if phase == "began" then
        display.getCurrentStage():setFocus(target, event.id)
    elseif phase == "moved" then
        -- Verifica se os pássaros colidiram no centro
        local birds = birdGroup.numChildren
        if birds >= 2 then
            local bird1 = birdGroup[birds - 1]
            local bird2 = birdGroup[birds]

            if math.abs(bird1.x - bird2.x) < 10 and math.abs(bird1.y - bird2.y) < 10 then
                createNewBirdPair()
            end
        end
    elseif phase == "ended" then
        display.getCurrentStage():setFocus(target, nil)
    end
    return true
end

function scene:create(event)
    local sceneGroup = self.view

    -- Fundo
    local background = display.newImageRect(sceneGroup, "src/assets/pages/page5/page05.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Botão de áudio
    local soundButton = display.newImageRect(sceneGroup, "src/assets/Audio.png", 48, 48)
    soundButton.x = 45
    soundButton.y = 70

    -- Botões de navegação
    buttons.createBackYellowButton(sceneGroup, "src.screens.page04")
    buttons.createNextYellowButton(sceneGroup, "src.screens.contraCapa")

    -- Imagem de instrução
    local instructionImage = display.newImageRect(sceneGroup, "src/assets/pages/page5/instrucao.png", 120, 110)
    instructionImage.x = display.contentCenterX
    instructionImage.y = display.contentHeight - 80
    transition.to(instructionImage, {time = 1000, alpha = 0.7, iterations = 0, transition = easing.continuousLoop})

    -- Áudio
    backgroundMusic = audio.loadStream("src/assets/audios/audioPage5.mp3")
    if not hasPlayedAudio then
        audioHandle = audio.play(backgroundMusic, {channel = 1, loops = 0})
        hasPlayedAudio = true
    end

    soundButton:addEventListener("tap", function()
        toggleAudio(soundButton, backgroundMusic)
    end)

    -- Cria os passarinhos iniciais
    createInitialBirds(sceneGroup)

    -- Adiciona listener de gesto de pinça nos passarinhos
    birdGroup:addEventListener("touch", onPinch)
end

function scene:destroy(event)
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
