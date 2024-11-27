local composer = require("composer")
local scene = composer.newScene()

local buttons = require("src.components.buttons")
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

    -- Background
    local background = display.newImageRect(sceneGroup, "src/assets/pages/capa/capa.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Audio Button
    local soundButton = display.newImageRect(sceneGroup, "src/assets/Audio.png", 48, 48)
    soundButton.x = 43
    soundButton.y = 31

    -- Next Button
    buttons.createNextYellowButton(sceneGroup, "src.screens.page01")

    -- Load and play audio
    backgroundMusic = audio.loadStream("src/assets/audios/audioCapa.mp3")
    if not hasPlayedAudio then
        audioHandle = audio.play(backgroundMusic, {channel = 1, loops = 0})
        hasPlayedAudio = true
    end

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
