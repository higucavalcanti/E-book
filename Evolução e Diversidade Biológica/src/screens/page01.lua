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

-- Configuração dos estágios
local stages = {
    {image = "src/assets/pages/page1/Stage1.png", direction = "left"},  -- Ancestral
    {image = "src/assets/pages/page1/Stage2.png", direction = "right"}, -- Peixe
    {image = "src/assets/pages/page1/Stage3.png", direction = "left"},  -- Anfíbio
    {image = "src/assets/pages/page1/Stage4.png", direction = "right"}, -- Réptil
    {image = "src/assets/pages/page1/Stage5.png", direction = "left"},  -- Mamífero
    {image = "src/assets/pages/page1/Stage6.png", direction = "right"}, -- Primata
    {image = "src/assets/pages/page1/Stage7.png", direction = "left"},  -- Humano
}

local currentStage = 1
local stageImages = {}
local zoomGroup
local spiralGroup
local isSpiralComplete = false
local ancestralPosition = {x = 0, y = 0} -- Guarda a posição inicial do ancestral

-- Função para criar a imagem de cada estágio
local function createStageImage(index, x, y)
    local stage = stages[index]
    local image = display.newImageRect(zoomGroup, stage.image, 250, 250)
    image.x = x
    image.y = y
    image.alpha = (index == 1) and 1 or 0 -- Apenas o ancestral aparece inicialmente
    return image
end

-- Função para transição de uma imagem
local function slideImage(stageIndex, onComplete)
    local stage = stages[stageIndex]
    local direction = stage.direction
    local startX = (direction == "left") and -300 or display.contentWidth + 300
    local targetX = ancestralPosition.x
    local targetY = ancestralPosition.y

    local image = stageImages[stageIndex]
    image.x = startX
    image.alpha = 1

    transition.to(image, {
        time = 700,
        x = targetX,
        y = targetY,
        transition = easing.outExpo,
        onComplete = function()
            if onComplete then onComplete() end
        end
    })
end

-- Próximo estágio
local function nextStage()
    if not isSpiralComplete and currentStage < #stages then
        currentStage = currentStage + 1
        slideImage(currentStage)
    elseif not isSpiralComplete then
        -- Exibir espiral
        isSpiralComplete = true
        spiralGroup = display.newGroup()
        zoomGroup:insert(spiralGroup)

        local centerX, centerY = ancestralPosition.x, ancestralPosition.y
        local radius = 50
        local angleStep = 50
        local scale = 0.6

        for i = 1, #stages do
            local image = stageImages[i]
            local angle = math.rad(i * angleStep)
            local x = centerX + radius * math.cos(angle)
            local y = centerY + radius * math.sin(angle)

            transition.to(image, {
                time = 1000,
                x = x,
                y = y,
                xScale = scale,
                yScale = scale,
                transition = easing.outExpo
            })

            radius = radius + 5
        end
    else
        -- Recolher espiral de volta ao ancestral
        isSpiralComplete = false

        for i = #stages, 1, -1 do
            local image = stageImages[i]
            local targetX = ancestralPosition.x
            local targetY = ancestralPosition.y

            transition.to(image, {
                time = 700,
                x = targetX,
                y = targetY,
                xScale = 1,
                yScale = 1,
                transition = easing.inExpo,
                onComplete = function()
                    if i == 1 then
                        currentStage = 1
                        for j = 2, #stages do
                            stageImages[j].alpha = 0
                        end
                    end
                end
            })
        end
    end
end

function scene:create(event)
    local sceneGroup = self.view

    -- Fundo
    local background = display.newImageRect(sceneGroup, "src/assets/pages/page1/page01.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Botão de som
    local soundButton = display.newImageRect(sceneGroup, "src/assets/Audio.png", 48, 48)
    soundButton.x = 45
    soundButton.y = 70

    soundButton:addEventListener("tap", function()
        toggleAudio(soundButton, backgroundMusic)
    end)

    -- Grupo de zoom
    zoomGroup = display.newGroup()
    sceneGroup:insert(zoomGroup)

    -- Criação das imagens dos estágios
    for i = 1, #stages do
        stageImages[i] = createStageImage(i, display.contentCenterX, display.contentHeight * 0.75)
    end

    -- Posição inicial do ancestral
    ancestralPosition.x = stageImages[1].x
    ancestralPosition.y = stageImages[1].y

    -- Botões de navegação
    buttons.createBackYellowButton(sceneGroup, "src.screens.capa")
    buttons.createNextYellowButton(sceneGroup, "src.screens.page02")

    -- Áudio
    backgroundMusic = audio.loadStream("src/assets/audios/audioPage1.mp3")
    if not hasPlayedAudio then
        audioHandle = audio.play(backgroundMusic, {channel = 1, loops = 0})
        hasPlayedAudio = true
    end

    -- Área de toque personalizada ajustada
    local touchArea = display.newRect(sceneGroup, display.contentCenterX, display.contentHeight * 0.6, display.contentWidth, display.contentHeight * 0.5)
    touchArea.isHitTestable = true
    touchArea.isVisible = false -- Apenas para detectar toques

    touchArea:addEventListener("tap", function(event)
        nextStage()
    end)
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