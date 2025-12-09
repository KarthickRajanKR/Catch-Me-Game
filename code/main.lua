-- GAME CODE

-- On ready
function love.load()


    --fullscreen
    love.window.setFullscreen(true)
    --cursor visible
    love.mouse.setVisible(true)


    --window information
    window_data = {}
    window_data.width = love.graphics.getWidth()
    window_data.height = love.graphics.getHeight()

    --audio
    sounds = {}
    sounds.background_music = love.audio.newSource("audio/background_music.mp3","stream")
    sounds.bullet = love.audio.newSource("audio/bullet.wav","static")
    sounds.enemy_dead = love.audio.newSource("audio/enemy_dead.wav","static")

    --volume
    sounds.background_music:setVolume(.09)
    sounds.bullet:setVolume(.2)
    sounds.enemy_dead:setVolume(.2)
    -- background music

    sounds.background_music:setLooping(true)
    sounds.background_music:play()


    --player
    player = {}
    player.position = {}
    player.input = {}
    player.position.x = window_data.width / 2  
    player.position.y = window_data.height / 2
    player.input.dir_x = 0
    player.input.dir_y = 0
    player.speed = 50
    player.diagonal_speed = 1.4
    player.radius = 60

    -- enemy 
    enemy1 = enemy(-200 ,-200 ,13 , 5)
    enemy2 = enemy(window_data.width / 2 , -200, 15, 10)
    enemy3 = enemy(window_data.width +200, 0, 20, 15)
    enemy4 = enemy(-200, window_data.height / 2, 23, 20)
    enemy5 = enemy(window_data.width + 200, window_data.height / 2, 25,25)
    enemy6 = enemy(-200, window_data.height, 28, 30)
    enemy7 = enemy(window_data.width / 2, window_data.height + 200, 30, 35)
    enemy8 = enemy(window_data.width, window_data.height + 200, 33, 40)

    --mouse
    mouse_data = {}
    mouse_data.position = {}
    mouse_data.x = 0
    mouse_data.y = 0

    -- bullet
    bullet1 = bullet(player.position.x,player.position.y)

    -- Game Manager
    game_manager = {}
    game_manager.game_over = false
    game_manager.score = 0
    game_manager.high_score = 0

end


-- On update, runs every frame
function love.update(delta)

    -- player control
    
    if love.keyboard.isDown("a") then
        player.input.dir_x = -1
    elseif love.keyboard.isDown("d") then 
        player.input.dir_x = 1
    else  
        player.input.dir_x = 0
    end
    if love.keyboard.isDown("w") then
        player.input.dir_y = -1
    elseif love.keyboard.isDown("s") then
        player.input.dir_y = 1        
    else  
        player.input.dir_y = 0
    end
    -- reduce player speed when moving diagonal
    if math.abs(player.input.dir_x) == math.abs(player.input.dir_y) then
        player.input.dir_x = player.input.dir_x / player.diagonal_speed
        player.input.dir_y = player.input.dir_y / player.diagonal_speed
    end 

 -- GAME LOGIC
    if (game_manager.game_over == false) then
        -- player movement
        player.position.x = player.position.x + (player.input.dir_x * player.speed * delta * 10)
        player.position.y = player.position.y + (player.input.dir_y * player.speed * delta * 10)
        

        --mouse
        mouse_data.position.x = love.mouse.getX()
        mouse_data.position.y = love.mouse.getY()

        --bullet  logic
        bullet1.logic(delta)



        --Border 
         if player.position.x > window_data.width - player.radius then
             player.position.x = window_data.width - player.radius
         elseif player.position.x < player.radius then
            player.position.x = player.radius
        end
         if player.position.y > window_data.height - player.radius then
            player.position.y = window_data.height - player.radius
        elseif player.position.y < player.radius then
            player.position.y = player.radius
        end
    end

    --Enemy logic
    enemy1.logic(delta)
    enemy2.logic(delta)
    enemy3.logic(delta)
    enemy4.logic(delta)
    enemy5.logic(delta)
    enemy6.logic(delta)
    enemy7.logic(delta)
    enemy8.logic(delta)

    -- Restart
    if love.keyboard.isDown("r") then

        player.position.x = window_data.width / 2
        player.position.y = window_data.height / 2
        enemy1.reset()
        enemy2.reset()
        enemy3.reset()
        enemy4.reset()
        enemy5.reset()
        enemy6.reset()
        enemy7.reset()
        enemy8.reset()
        bullet1.reset()
        --High score
        if game_manager.score >= game_manager.high_score then
            game_manager.high_score = game_manager.score
        end
        game_manager.score = 0
        game_manager.game_over = false
    end

    -- quit window
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end


end

-- Draw images every frame 
function love.draw()

    --draw player
    love.graphics.circle("line",player.position.x,player.position.y,player.radius)

    --draw enemy
    enemy1.drawEnemy()
    enemy2.drawEnemy()
    enemy3.drawEnemy()
    enemy4.drawEnemy()
    enemy5.drawEnemy()
    enemy6.drawEnemy()
    enemy7.drawEnemy()
    enemy8.drawEnemy()

    --bullet draw
    love.graphics.circle("fill",bullet1.position.x,bullet1.position.y,bullet1.radius)

    --Simple UI
    love.graphics.print("Controls:\nw - move up\na - move left\ns - move down\nd - move right\nleft click - shoot\nescape - quit\nr - restart",10,window_data.height -150,nil,1.2,1.2)
    love.graphics.print("Score: " .. game_manager.score .. "\nHigh Score: " .. game_manager.high_score,10,10,nil,1.5,1.5)
    love.graphics.print("CATCH ME\nby Karthick Rajan",window_data.width - 140,window_data.height -50,nil,1.2,1.2)





end


--Enemy object
function enemy(x,y,speed,reincarn_time)
    local enemy = {}
    enemy.position = {}
    enemy.direction = {}
    enemy.timer = {}
    enemy.timer.reset_time = reincarn_time

    enemy.position.x = x
    enemy.position.y = y
    enemy.speed = speed
    enemy.radius = 60
    enemy.direction.x = 0
    enemy.direction.y = 0
    enemy.distance = 0 
    enemy.is_dead = true

    -- Enemy logic
    enemy.logic = function(delta)
        if (enemy.is_dead == false) then
            enemy.distance = find_distance(player.position, enemy.position)  -- Distance between enemy and player
            -- Unit Vector (direction)
            enemy.direction = find_direction(player.position,enemy.position,enemy.distance)
            enemy.position.x = enemy.position.x + (enemy.direction.x * enemy.speed * delta * 10 )
            enemy.position.y = enemy.position.y + (enemy.direction.y * enemy.speed * delta  * 10)

            -- collision
            if (enemy.distance <= player.radius + enemy.radius and enemy.distance >= 0) then  
                game_manager.game_over = true
            end

        else
            -- enemy reincarnation delay
            enemy.timer.reset_time = enemy.timer.reset_time - delta
            if (enemy.timer.reset_time <= 0 ) then
                enemy.reincarnation()
            end
        end
    end

    --draw enemy
    enemy.drawEnemy = function()
        if (enemy.is_dead == false) then
                love.graphics.circle("fill",enemy.position.x,enemy.position.y,enemy.radius)
        end
    end

    --reincarnation function
    enemy.reincarnation = function()
        enemy.position.x = x
        enemy.position.y = y
        enemy.timer.reset_time = reincarn_time
        enemy.is_dead = false

    end

    -- reset function
    enemy.reset = function()
        enemy.position.x = x 
        enemy.position.y = y 
        enemy.timer.reset_time = reincarn_time
        enemy.is_dead = true
    end
    return enemy
end

--bullet object
function bullet(x , y )
    local bullet = {}
    bullet.position = {}
    bullet.idle_direction = {}
    bullet.target_direction = {}
    bullet.player_direction = {}
    bullet.timer = {}

    bullet.player_distance = 0
    bullet.position.x = x
    bullet.position.y = y
    bullet.idle_direction.x = 0
    bullet.idle_direction.y = 0
    bullet.player_direction.x = 0
    bullet.player_direction.y = 0
    bullet.radius = 15
    bullet.idle_distance = 0
    bullet.idle_speed = 5
    bullet.shoot_speed = 80
    bullet.return_speed = 120
    bullet.is_idle = true
    bullet.timer.back_time = 2.3
    bullet.timer.v_back_time = 0

    -- bullet logic
    bullet.logic = function(delta)
        -- Bullet movement inside player
        if bullet.is_idle then
            bullet.position.x = player.position.x
            bullet.position.y = player.position.y
            bullet.idle_distance = find_distance(mouse_data.position,bullet.position)
            bullet.idle_direction = find_direction(mouse_data.position,bullet.position,bullet.idle_distance)
            bullet.position.x = bullet.position.x + (bullet.idle_direction.x *  bullet.idle_speed * 5)
            bullet.position.y = bullet.position.y + (bullet.idle_direction.y *  bullet.idle_speed * 5)

            -- Triggered 
            if love.mouse.isDown(1) then
                bullet.target_direction.x = bullet.idle_direction.x
                bullet.target_direction.y = bullet.idle_direction.y
                bullet.is_idle = false
                sounds.bullet:play()
            end
        else


            --Thor's hammer mechanism 
            if(bullet.timer.v_back_time <= 0 ) then
                bullet.player_distance = find_distance(player.position,bullet.position)
                bullet.player_direction = find_direction(player.position,bullet.position,bullet.player_distance)
                bullet.position.x = bullet.position.x + (bullet.player_direction.x * bullet.return_speed * delta *10)
                bullet.position.y = bullet.position.y + (bullet.player_direction.y * bullet.return_speed * delta *10)
               if (bullet.player_distance <= player.radius) then
                    bullet.is_idle = true
                    bullet.timer.v_back_time = bullet.timer.back_time
                    sounds.bullet:play()
                end
            else
                bullet.timer.v_back_time = bullet.timer.v_back_time - delta
                bullet.position.x = bullet.position.x + (bullet.target_direction.x * bullet.shoot_speed * delta *10)
                bullet.position.y = bullet.position.y + (bullet.target_direction.y * bullet.shoot_speed * delta *10)
            end

            --detect collision 
            enemy_collision(enemy1,find_distance(enemy1.position,bullet.position))
            enemy_collision(enemy2,find_distance(enemy2.position,bullet.position))
            enemy_collision(enemy3,find_distance(enemy3.position,bullet.position))
            enemy_collision(enemy4,find_distance(enemy4.position,bullet.position))
            enemy_collision(enemy5,find_distance(enemy5.position,bullet.position))
            enemy_collision(enemy6,find_distance(enemy6.position,bullet.position))
            enemy_collision(enemy7,find_distance(enemy7.position,bullet.position))
            enemy_collision(enemy8,find_distance(enemy8.position,bullet.position))
            

        end
    end
    --reset bullet
    bullet.reset = function()
        bullet.is_idle = true
        bullet.timer.v_back_time = 0
    end
    return bullet
end


-- Finding distance using pythagoras theorem 
function find_distance(a,b)
     local distance = math.sqrt(math.pow(a.x - b.x,2) + math.pow(a.y - b.y,2))
     return distance
end


-- direction = a-b / ||a-b||    (Normalized Vector)
function find_direction(a,b,distance)
    local direction = {}
    direction.x = (a.x - b.x) / distance
    direction.y = (a.y - b.y) / distance
    return direction
end

-- Enemy Collision
function enemy_collision(enemy_data,distance)
        if (distance <= enemy_data.radius and distance >= 0) then
            if(enemy_data.is_dead == false) then
                enemy_data.is_dead = true
                game_manager.score = game_manager.score + 1
                sounds.enemy_dead:stop()
                sounds.enemy_dead:play()
            end
        end    
end



