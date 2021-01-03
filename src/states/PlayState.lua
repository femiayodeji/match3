PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.transitionAlpha = 1
    self.boardHighlightX = 0
    self.boardHighlightY = 0
    self.rectHighlighted = false
    self.canInput = true
    self.highlightedTile = nil
    self.score = 0

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

function PlayState:enter(params)
    self.level = params.level
    self.board = params.board or Board(VIRTUAL_WIDTH - 272, 16)
    self.score = params.score or 0
    self.scoreGoal = self.level * 1.2 * 1000
    self.timer = self.level / 2 * 1.5 * 60
end

function PlayState:update(dt)
    if self.timer <= 0 then 
        Timer.clear()
        gSounds['game-over']:play()
        gStateMachine:change('game-over', {
            score = self.score
        })
    end

    if self.score >= self.scoreGoal then 
        Timer.clear()
        gSounds['next-level']:play()
        gStateMachine:change('begin-game', {
            level = self.level + 1, 
            score = self.score
        })
    end

    if self.canInput then 
        if love.keyboard.wasPressed('up') then 
            self.boardHighlightY = math.max(0, self.boardHighlightY - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('down') then 
            self.boardHighlightY = math.min(7, self.boardHighlightY + 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('left') then 
            self.boardHighlightX = math.max(0, self.boardHighlightX - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('right') then 
            self.boardHighlightX = math.min(7, self.boardHighlightX + 1)
            gSounds['select']:play()
        end

        if (
            love.keyboard.wasPressed('enter') or 
            love.keyboard.wasPressed('return')
        ) then 
            local x = self.boardHighlightX + 1
            local y = self.boardHighlightY + 1
            local currentTile = self.board.tiles[y][x]

            if not self.highlightedTile then 
                self.highlightedTile = currentTile
            elseif self.highlightedTile == currentTile then 
                self.highlightedTile = nil
            elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then 
                gSounds['error']:play()
                self.highlightedTile = nil
            else 
                local tempX = self.highlightedTile.gridX
                local tempY = self.highlightedTile.gridY

                local newTile = self.board.tiles[y][x]

                self.highlightedTile.gridX = newTile.gridX
                self.highlightedTile.gridY = newTile.gridY
                newTile.gridX = tempX
                newTile.gridY = tempY

                self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] = self.highlightedTile
                self.board.tiles[newTile.gridY][newTile.gridX] = newTile
                
                Timer.tween(0.1, {
                    [self.highlightedTile] = {x = newTile.x, y = newTile.y},
                    [newTile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
                })
                :finish(function() 
                    self:calculateMatches()
                end)
            end
        end
    end
    Timer.update(dt)
end

function PlayState:calculateMatches()
    self.highlightedTile = nil 
    local matches = self.board:calculateMatches()

    if matches then 
        gSounds['match']:stop()
        gSounds['match']:play()
        
        for k, match in pairs(matches) do 
            self.score = self.score + #match * 50
        end

        self.board:removeMatches()

        local tilesToFall = self.board:getFallingTiles()

        Timer.tween(0.25, tilesToFall):finish(function() 
            self:calculateMatches()
        end)
    else
        self.canInput = true
    end
end

function PlayState:render()
    self.board:render()

    if self.highlightedTile then 
        love.graphics.setBlendMode('add')
        love.graphics.setColor(1, 1, 1, 96/255)
        love.graphics.rectangle(
            'fill', 
            (self.highlightedTile.gridX - 1) * 32 + (VIRTUAL_WIDTH - 272), 
            (self.highlightedTile.gridY - 1) * 32 + 16, 
            32, 32, 4
        )
        love.graphics.setBlendMode('alpha')
    end

    if self.rectHighlighted then 
        love.graphics.setColor(217/255, 87/255, 99/255, 1)
    else
        love.graphics.setColor(172/255, 50/255, 50/255, 1)
    end

    love.graphics.setLineWidth(4)
    love.graphics.rectangle(
        'line', 
        self.boardHighlightX * 32 + (VIRTUAL_WIDTH - 272), 
        self.boardHighlightY * 32 + 16, 
        32, 32, 4
    )

    love.graphics.setColor(56/255, 56/255, 56/255, 234/255)
    love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

    love.graphics.setColor(99/255, 155/255, 1, 1)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
    love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
    love.graphics.printf('Goal: ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
    love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')
end
