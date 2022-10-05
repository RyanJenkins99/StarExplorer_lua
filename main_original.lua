-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- Your code here

math.randomseed( os.time() )


-- Set up display groups

-- Load the background
local background = display.newImageRect( backGroup, "assets/background.png", 800, 1400 )
background.x = display.contentCenterX
background.y = display.contentCenterY
ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 )
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
physics.addBody( ship, { radius=30, isSensor=true } )
ship.myName = "ship"
-- Display lives and score
livesText = display.newText( uiGroup, "Lives: " .. lives, 50, -60, native.systemFont, 24 )
scoreText = display.newText( uiGroup, "Score: " .. score, 160, -60, native.systemFont, 24 )



ship:addEventListener( "touch", dragShip )
local function gameLoop()
    -- Create new asteroid
    createAsteroid()
    -- Remove asteroids which have drifted off screen
    for i = #asteroidsTable, 1, -1 do
        local thisAsteroid = asteroidsTable[i]
        if ( thisAsteroid.x < -100 or
             thisAsteroid.x > display.contentWidth + 100 or
             thisAsteroid.y < -100 or
             thisAsteroid.y > display.contentHeight + 100 )
        then
            display.remove( thisAsteroid )
            table.remove( asteroidsTable, i )
        end
    end
end
gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
local function restoreShip()
    ship.isBodyActive = false
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
    -- Fade in the ship
    transition.to( ship, { alpha=1, time=4000,
        onComplete = function()
            ship.isBodyActive = true
            died = false
        end
    } )
end
local function onCollision( event )
    if ( event.phase == "began" ) then
        local obj1 = event.object1
        local obj2 = event.object2
        if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
             ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
        then
            -- Remove both the laser and asteroid
            display.remove( obj1 )
            display.remove( obj2 )
            for i = #asteroidsTable, 1, -1 do
                if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
                    table.remove( asteroidsTable, i )
                    break
                end
            end
            -- Increase score
            score = score + 100
            scoreText.text = "Score: " .. score
        elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
        ( obj1.myName == "asteroid" and obj2.myName == "ship" ) )then
            if ( died == false ) then
                died = true
                -- Update lives
                lives = lives - 1
                livesText.text = "Lives: " .. lives
                if ( lives == 0 ) then
                    display.remove( ship )
                else
                    ship.alpha = 0
                    timer.performWithDelay( 1000, restoreShip )
                end
            end
        end
    end
end
Runtime:addEventListener( "collision", onCollision )














