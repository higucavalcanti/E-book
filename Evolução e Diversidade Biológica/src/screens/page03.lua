local composer = require("composer")
local scene = composer.newScene()

local buttons = require("src.components.button")
local audioHandle
local backgroundMusic
local hasPlayedAudio = false

local evolutionStage = 1
local bird
local particleEffects = {}
local birdImages = {
    "src/assets/pages/page3/Stage1.png",
    "src/assets/pages/page3/Stage2.png",
    "src/assets/pages/page3/Stage3.png"
}
local birdSizes = {
    {width = 140, height = 140}, -- Estágio 1
    {width = 220, height = 220}, -- Estágio 2
    {width = 300, height = 300}  -- Estágio 3
}

-- Função para alternar o áudio
local function toggleAudio(soundButton, audioFile)
    if audio.isChannelPlaying(1) then
        audio.stop(1)
        soundButton.fill = {type = "image", filename = "src/assets/Mute.png"}
    else
        audioHandle = audio.play(audioFile, {channel = 1, loops = -1})
        soundButton.fill = {type = "image", filename = "src/assets/Audio.png"}
    end
end

-- Função para criar partículas visualmente impactantes
local function createParticles(x, y)
    for i = 1, 20 do
        local particle = display.newCircle(x, y, math.random(10, 20))
        particle:setFillColor(math.random(), math.random(), math.random())
        particle.alpha = 1
        scene.view:insert(particle)
        table.insert(particleEffects, particle)

        transition.to(particle, {
            x = x + math.random(-150, 150),
            y = y + math.random(-150, 150),
            time = math.random(800, 1200),
            alpha = 0,
            xScale = math.random(0.5, 1.2),
            yScale = math.random(0.5, 1.2),
            rotation = math.random(0, 360),
            transition = easing.outExpo,
            onComplete = function() display.remove(particle) end
        })
    end
end

-- Função de mutação com efeitos chamativos
local function mutateEffect(target)
    transition.to(target, {
        time = 500,
        xScale = 1.4,
        yScale = 1.4,
        rotation = 30,
        transition = easing.outBounce,
        onComplete = function()
            transition.to(target, {
                time = 500,
                xScale = 1,
                yScale = 1,
                rotation = 0,
                transition = easing.inOutQuad
            })
        end
    })
end

-- Função de evolução do pássaro
local function evolveBird()
    if evolutionStage < #birdImages then
        evolutionStage = evolutionStage + 1
        createParticles(bird.x, bird.y)
        mutateEffect(bird)

        timer.performWithDelay(800, function()
            bird.fill = {type = "image", filename = birdImages[evolutionStage]}
            bird.width = birdSizes[evolutionStage].width
            bird.height = birdSizes[evolutionStage].height
            createParticles(bird.x, bird.y)
        end)
    else
        print("Estágio máximo atingido!")
    end
end

-- Função para detectar shake e iniciar evolução
local function onShake(event)
    if event.isShake then
        evolveBird()
    end
end

function scene:create(event)
    local sceneGroup = self.view

    -- Background
    local background = display.newImageRect(sceneGroup, "src/assets/pages/page3/page03.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Bird (primeiro estágio)
    bird = display.newImageRect(sceneGroup, birdImages[evolutionStage], birdSizes[evolutionStage].width, birdSizes[evolutionStage].height)
    bird.x = display.contentCenterX
    bird.y = display.contentHeight - 200 -- Subida do pássaro

    -- Botão de áudio
    local soundButton = display.newImageRect(sceneGroup, "src/assets/Audio.png", 48, 48)
    soundButton.x = 45
    soundButton.y = 70

    -- Botões de navegação
    buttons.createBackBlueButton(sceneGroup, "src.screens.page02")
    buttons.createNextBlueButton(sceneGroup, "src.screens.page04")

    -- Carregar e tocar áudio
    backgroundMusic = audio.loadStream("src/assets/audios/audioPage3.mp3")
    if not hasPlayedAudio then
        audioHandle = audio.play(backgroundMusic, {channel = 1, loops = -1})
        hasPlayedAudio = true
    end

    soundButton:addEventListener("tap", function()
        toggleAudio(soundButton, backgroundMusic)
    end)

    Runtime:addEventListener("accelerometer", onShake)
end

-- Reiniciar evolução ao entrar novamente na cena
function scene:show(event)
    if event.phase == "did" then
        evolutionStage = 1
        bird.fill = {type = "image", filename = birdImages[evolutionStage]}
        bird.width = birdSizes[evolutionStage].width
        bird.height = birdSizes[evolutionStage].height
    end
end

function scene:destroy(event)
    if audioHandle then
        audio.stop(audioHandle)
        audio.dispose(backgroundMusic)
        backgroundMusic = nil
    end
    Runtime:removeEventListener("accelerometer", onShake)
end

function scene:hide(event)
    if event.phase == "will" and audioHandle then
        audio.stop(audioHandle)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("destroy", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("show", scene)

return scene