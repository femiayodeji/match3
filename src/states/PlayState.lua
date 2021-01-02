PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.transitionAlpha = 1
    self.boardHighlightX = 0
    self.boardHighlightY = 0
    self.rectHighlighted = false
    self.canInput = true
    self.highlightedTile = nil
    self.score = 0
    self.timer = 60

    Timer.every(0.5, function() 
        self.rectHighlighted = not self.rectHighlighted
    end)

    Timer.every(1, function() 
        self.timer = self.timer - 1
        if self.timer <= 5 then 
            gSounds['clock']:play()
        end
    end)
end


