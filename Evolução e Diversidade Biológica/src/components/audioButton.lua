local composer = require("composer")
local audioButton = {}
local audioTrack

-- Função para criar o controle de som
function audioButton.create(sceneGroup, audioFile)
    local soundIcons = {
        "src/assets/Audio.png",  -- Ícone de som ligado
        "src/assets/Mute.png"    -- Ícone de som desligado
    }
    local soundLabels = {
        "Audio On", 
        "Mute"
    }

    local currentState = 1 -- Estado inicial: Som ligado
    local soundIcon
    local soundLabel

    -- Função para alternar entre Som e Mute
    local function toggleSound(event)
        currentState = (currentState % 2) + 1 -- Alterna entre 1 e 2

        -- Atualizar ícone
        soundIcon:removeSelf()
        soundIcon = display.newImageRect(sceneGroup, soundIcons[currentState], 73, 48)
        soundIcon.x = 43
        soundIcon.y = 31
        soundIcon:addEventListener("tap", toggleSound)

        -- Atualizar label
        soundLabel:removeSelf()
        soundLabel = display.newText({
            parent = sceneGroup,
            text = soundLabels[currentState],
            x = 43,
            y = 80, -- Ajustado para ficar abaixo do botão
            width = 200,
            font = native.systemFont,
            fontSize = 18,
            align = "center"
        })
        soundLabel:setFillColor(0, 0, 0)

        -- Gerenciar áudio
        if currentState == 2 then
            audio.setVolume(0) -- Mute
        else
            audio.setVolume(0.5) -- Restaurar volume
        end
    end

    -- Carregar e reproduzir o áudio ao entrar na página
    if audioFile then
        if audioTrack then
            audio.stop()
            audio.dispose(audioTrack)
        end
        audioTrack = audio.loadStream(audioFile)
        audio.play(audioTrack, {
            loops = 0, -- Reproduz uma vez
            onComplete = function()
                print("Audio completed.")
            end
        })
        audio.setVolume(0.5) -- Volume padrão
    end

    -- Criar ícone inicial
    soundIcon = display.newImageRect(sceneGroup, soundIcons[currentState], 73, 48)
    soundIcon.x = 43
    soundIcon.y = 31
    soundIcon:addEventListener("tap", toggleSound)

    -- Criar label inicial
    soundLabel = display.newText({
        parent = sceneGroup,
        text = soundLabels[currentState],
        x = 43,
        y = 80, -- Ajustado para ficar abaixo do botão
        width = 200,
        font = native.systemFont,
        fontSize = 18,
        align = "center"
    })
    soundLabel:setFillColor(0, 0, 0)

    -- Retornar os elementos para controle externo, se necessário
    return {
        soundIcon = soundIcon,
        soundLabel = soundLabel
    }
end

-- Função para parar o áudio ao sair da página
function audioButton.stop()
    if audioTrack then
        audio.stop()
        audio.dispose(audioTrack)
        audioTrack = nil
    end
end

return audioButton