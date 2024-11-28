local composer = require("composer")
local scene = composer.newScene()

local buttons = require("src.components.button")
local audioHandle
local backgroundMusic
local hasPlayedAudio = false

-- Configuração dos estágios e direções
local stages = {
    {image = "src/assets/pages/page1/Stage1.png", direction = "left"},  -- Ancestral
    {image = "src/assets/pages/page1/Stage2.png", direction = "right"}, -- Peixe
    {image = "src/assets/pages/page1/Stage3.png", direction = "left"},  -- Anfíbio
    {image = "src/assets/pages/page1/Stage4.png", direction = "right"}, -- Réptil
    {image = "src/assets/pages/page1/Stage5.png", direction = "left"},  -- Mamífero
    {image = "src/assets/pages/page1/Stage6.png", direction = "right"}, -- Primata
    {image = "src/assets/pages/page1/Stage7.png", direction = "left"},  -- Humano
}

local currentStage = 0
local stageImages = {}
local zoomGroup
local spiralGroup

-- Função para criar a imagem de cada estágio
local function createStageImage(index, x, y)
    local stage = stages[index]
    local image = display.newImageRect(zoomGroup, stage.image, 200, 200)
    image.x = x
    image.y = y
    image.alpha = 0
    return image
end

-- Função para transição de uma imagem
local function slideImage(stageIndex, onComplete)
    local stage = stages[stageIndex]
    local direction = stage.direction
    local startX = (direction == "left") and -300 or display.contentWidth + 300
    local targetX = display.contentCenterX
    local targetY = display.contentCenterY + 100  -- Posiciona as imagens mais para baixo

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
    if currentStage < #stages then
        currentStage = currentStage + 1
        slideImage(currentStage)
    else
        -- Final: Exibição em espiral
        spiralGroup = display.newGroup()
        zoomGroup:insert(spiralGroup)

        local centerX, centerY = display.contentCenterX, display.contentCenterY + 100
        local radius = 80
        local angleStep = 360 / #stages
        local scale = 0.7  -- Escala para as imagens na espiral

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

            -- Aumenta o raio para a próxima imagem
            radius = radius + 50
        end

        -- Coloca o humano no centro
        local humanImage = stageImages[#stages]
        transition.to(humanImage, {
            time = 1000,
            x = centerX,
            y = centerY,
            xScale = scale + 0.2,
            yScale = scale + 0.2,
            transition = easing.outExpo
        })
    end
end

function scene:create(event)
    local sceneGroup = self.view

    -- Fundo
    local background = display.newImageRect(sceneGroup, "src/assets/pages/page1/page01.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Grupo de zoom
    zoomGroup = display.newGroup()
    sceneGroup:insert(zoomGroup)

    -- Criação das imagens dos estágios
    for i = 1, #stages do
        stageImages[i] = createStageImage(i, display.contentCenterX, display.contentHeight * 0.5)
    end

    -- Botões de navegação
    buttons.createBackYellowButton(sceneGroup, "src.screens.capa")
    buttons.createNextYellowButton(sceneGroup, "src.screens.page02")

    -- Áudio
    backgroundMusic = audio.loadStream("src/assets/audios/audioPage1.mp3")
    if not hasPlayedAudio then
        audioHandle = audio.play(backgroundMusic, {channel = 1, loops = 0})
        hasPlayedAudio = true
    end

    -- Inicia o próximo estágio ao clicar
    background:addEventListener("tap", function()
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
