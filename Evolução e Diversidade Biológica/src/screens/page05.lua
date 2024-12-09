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

function scene:create(event)
    local sceneGroup = self.view

    -- Fundo
    local background = display.newImageRect(sceneGroup, "src/assets/pages/page5/page05.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Botão de audio
    local soundButton = display.newImageRect(sceneGroup, "src/assets/Audio.png", 48, 48)
    soundButton.x = 45
    soundButton.y = 70

     -- Botões de navegação
     buttons.createBackYellowButton(sceneGroup, "src.screens.page04")
     buttons.createNextYellowButton(sceneGroup, "src.screens.contraCapa")
 
     -- Áudio
     backgroundMusic = audio.loadStream("src/assets/audios/audioPage5.mp3")
     if not hasPlayedAudio then
         audioHandle = audio.play(backgroundMusic, {channel = 1, loops = 0})
         hasPlayedAudio = true
     end
 
     -- Área de toque personalizada ajustada
     local touchArea = display.newRect(sceneGroup, display.contentCenterX, display.contentHeight * 0.6, display.contentWidth, display.contentHeight * 0.5)
     touchArea.isHitTestable = true
     touchArea.isVisible = false -- Apenas para detectar toques

    soundButton:addEventListener("tap", function()
        toggleAudio(soundButton, backgroundMusic)
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