local composer = require("composer")
local scene = composer.newScene()

local buttons = require("src.components.button")
local audioHandle
local backgroundMusic
local hasPlayedAudio = false

local physics = require("physics")
physics.start()

local stones = {}
local fossil
local foundFossil = false

local function toggleAudio(soundButton, audioFile)
    if audio.isChannelPlaying(1) then
        audio.stop(1)
        soundButton.fill = {type = "image", filename = "src/assets/Mute.png"}
    else
        audioHandle = audio.play(audioFile, {channel = 1, loops = 0})
        soundButton.fill = {type = "image", filename = "src/assets/Audio.png"}
    end
end

local function animateShine(shine)
    local function fadeInOut()
        transition.to(shine, {
            alpha = 0.1,
            time = 800,
            onComplete = function()
                transition.to(shine, {
                    alpha = 0.5,
                    time = 800,
                    onComplete = fadeInOut
                })
            end
        })
    end
    fadeInOut()
end

local function checkFossilFound()
    local allRemoved = true
    for _, stone in ipairs(stones) do
        if stone.x > fossil.x - 100 and stone.x < fossil.x + 100 and 
           stone.y > fossil.y - 100 and stone.y < fossil.y + 100 then
            allRemoved = false
            break
        end
    end

    if allRemoved and not foundFossil then
        foundFossil = true

        -- Efeito de brilho maior
        local shine = display.newCircle(fossil.x, fossil.y, 150) -- Tamanho do brilho aumentado
        shine:setFillColor(1, 1, 0.5, 0.4) -- Amarelo translúcido inicial
        scene.view:insert(shine)
        animateShine(shine)

        -- Remover brilho após um tempo maior
        timer.performWithDelay(5000, function()
            transition.to(shine, {
                alpha = 0,
                time = 1000,
                onComplete = function()
                    display.remove(shine)
                end
            })
        end)
    end
end

-- Interacao de arrastar as pedras
local function dragStone(event)
    local stone = event.target
    if event.phase == "began" then
        display.currentStage:setFocus(stone)
        stone.isFocus = true
    elseif event.phase == "moved" and stone.isFocus then
        stone.x = event.x
        stone.y = event.y
    elseif event.phase == "ended" or event.phase == "cancelled" then
        display.currentStage:setFocus(nil)
        stone.isFocus = false
        -- Verificar se o fóssil foi descoberto
        checkFossilFound()
    end
    return true
end

function scene:create(event)
    local sceneGroup = self.view

    -- Fundo
    local background = display.newImageRect(sceneGroup, "src/assets/pages/page4/page04.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Botão de áudio
    local soundButton = display.newImageRect(sceneGroup, "src/assets/Audio.png", 48, 48)
    soundButton.x = 45
    soundButton.y = 70

    -- Botões de navegação
    buttons.createBackYellowButton(sceneGroup, "src.screens.page03")
    buttons.createNextYellowButton(sceneGroup, "src.screens.page05")

    -- Imagem do arqueólogo
    local archaeologist = display.newImageRect(sceneGroup, "src/assets/pages/page4/Arqueologo.png", 200, 180)
    archaeologist.x = 130
    archaeologist.y = display.contentHeight - 250

    -- Imagem do fóssil
    fossil = display.newImageRect(sceneGroup, "src/assets/pages/page4/fossilTrex.png", 200, 200)
    fossil.x = display.contentCenterX + 80
    fossil.y = display.contentHeight - 245

    -- Imagens das pedras
    local stoneImages = {
        "src/assets/pages/page4/pedra1.png",
        "src/assets/pages/page4/pedra6.png",
        "src/assets/pages/page4/pedra3.png",
        "src/assets/pages/page4/pedra4.png",
        "src/assets/pages/page4/pedra5.png"
    }

    for i = 1, #stoneImages do
        local stone = display.newImageRect(sceneGroup, stoneImages[i], 220, 210)
        stone.x = fossil.x + math.random(-60, 60)
        stone.y = fossil.y + math.random(-60, 60)
        stone:addEventListener("touch", dragStone)
        table.insert(stones, stone)
    end

    -- Áudio
    backgroundMusic = audio.loadStream("src/assets/audios/audioPage4.mp3")
    if not hasPlayedAudio then
        audioHandle = audio.play(backgroundMusic, {channel = 1, loops = 0})
        hasPlayedAudio = true
    end

    soundButton:addEventListener("tap", function()
        toggleAudio(soundButton, backgroundMusic)
    end)
end

function scene:show(event)
    if event.phase == "will" then
        foundFossil = false

        -- Tentarr garantir cobertura total do fóssil
        local offset = 50
        for _, stone in ipairs(stones) do
            stone.isVisible = true
            stone.x = fossil.x + math.random(-offset, offset)
            stone.y = fossil.y + math.random(-offset, offset)
        end
    end
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
scene:addEventListener("show", scene)
scene:addEventListener("destroy", scene)
scene:addEventListener("hide", scene)

return scene