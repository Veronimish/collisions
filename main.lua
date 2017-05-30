require("Collisions")

function love.load()
  math.randomseed(os.time())
  local i
  local j
  local ligne
  local colonne
  local sommets
  
  typeTest = 1
  
  plane = {}
  plane.masque = {-44, -8, -44, -22, -23, -36, 29, -36, 42, -17, 42, 31, 15, 38, -23, 31}
  plane.x = love.mouse.getX()
  plane.y = love.mouse.getY()
  plane.sommets = {}
  for i=1,16,2 do
    table.insert(plane.sommets, plane.x+plane.masque[i])
    table.insert(plane.sommets, plane.y+plane.masque[i+1])
  end
  plane.img = love.graphics.newImage("plane.png")
  plane.dx = 44
  plane.dy = 35
  
  love.mouse.setVisible(false)
  mouse = {}
  mouse.x = love.mouse.getX()
  mouse.y = love.mouse.getY()
  mouse.r1 = 30
  mouse.r2 = 10
  mouse.angle = 0
  mouse.sommets = {}
 
  for i=0,2 do
      table.insert(mouse.sommets, mouse.x + math.sin(Angle120 * i) * mouse.r1)
      table.insert(mouse.sommets, mouse.y + math.cos(Angle120 * i) * mouse.r1)
      table.insert(mouse.sommets, mouse.x + math.sin(Angle120 * (i+1)) * mouse.r2)
      table.insert(mouse.sommets, mouse.y + math.cos(Angle120 * (i+1)) * mouse.r2)
  end
  mouse.triangles = love.math.triangulate(mouse.sommets)
  
  polygones = {}
  polygones.liste = {}
  polygones.angle = 0
  polygones.rayon = 50
    
  local nbSommets = 3
  for ligne=0,2,2 do
    for colonne=0,3 do
      local polygone = {}
      polygone.x = colonne * 200 + 100
      polygone.y = ligne * 200 + 100
      polygone.angle = 0
      polygone.rotation = true
      polygone.sommets = {}
      local angles = Angle360 / nbSommets
      for sommets = 1,nbSommets do
        local angle = angles * sommets
          table.insert(polygone.sommets, polygone.x + math.sin(angle) * polygones.rayon)
          table.insert(polygone.sommets, polygone.y + math.cos(angle) * polygones.rayon)
      end
      polygone.triangles = love.math.triangulate(polygone.sommets)
      table.insert(polygones.liste, polygone)
      nbSommets = nbSommets + 1
    end
  end
  
  local rectangle = {}
  rectangle.x = 200
  rectangle.y = 300
  rectangle.width = 150
  rectangle.height = 70
  rectangle.angle = 0
  rectangle.rotation = true
  rectangle.sommets = TransformRectangleToPoly(rectangle)
  rectangle.triangles = love.math.triangulate(rectangle.sommets)
  table.insert(polygones.liste, rectangle)
  
  local etoile = {}
  etoile.x = 600
  etoile.y = 300
  etoile.rMin = 30
  etoile.rMax = 100
  etoile.angle = 0
  etoile.rotation = true
  etoile.sommets = {}
  local angle = 0
  for i=1,5 do
    angle = angle + Angle36
    table.insert(etoile.sommets, etoile.x + math.sin(angle) * etoile.rMax)
    table.insert(etoile.sommets, etoile.y + math.cos(angle) * etoile.rMax)
    angle = angle + Angle36
    table.insert(etoile.sommets, etoile.x + math.sin(angle) * etoile.rMin)
    table.insert(etoile.sommets, etoile.y + math.cos(angle) * etoile.rMin)
  end
  etoile.triangles = love.math.triangulate(etoile.sommets)
  table.insert(polygones.liste, etoile)
  
  local cercle = {}
  cercle.x = 400
  cercle.y = 300
  cercle.rayon = 80
  cercle.angle = 0
  cercle.rotation = false
  cercle.sommets = {}
  for i=1,36 do
    table.insert(cercle.sommets, cercle.x + math.sin(Angle10 * i) * cercle.rayon)
    table.insert(cercle.sommets, cercle.y + math.cos(Angle10 * i) * cercle.rayon)
  end
  cercle.triangles = love.math.triangulate(cercle.sommets)
  table.insert(polygones.liste, cercle)
end

function TransformRectangleToPoly(rectangle)
  local deltaX = rectangle.width / 2
  local deltaY = rectangle.height / 2
  local X = rectangle.x
  local Y = rectangle.y
  return {X - deltaX, Y - deltaY, X + deltaX, Y - deltaY, X + deltaX, Y + deltaY, X - deltaX, Y + deltaY}
end

function RotateMouse(polygone, rotation)
  local y = love.mouse.getY()
  local px = polygone.x
  local py = polygone.y
  local i
  polygone.x = love.mouse.getX()
  polygone.y = love.mouse.getY()
  for i=1,#polygone.sommets, 2 do
    local rayon = Distance({px, py}, {polygone.sommets[i], polygone.sommets[i+1]})
    local angle = Angle({px, py}, {polygone.sommets[i], polygone.sommets[i+1]})
    polygone.sommets[i] = polygone.x + math.sin(angle + rotation) * rayon
    polygone.sommets[i+1] = polygone.y + math.cos(angle + rotation) * rayon
  end
  polygone.triangles = love.math.triangulate(polygone.sommets)
end

function RotatePolygone(polygone, rotation)
  local i
  for i=1,#polygone.sommets, 2 do
    local rayon = Distance({polygone.x, polygone.y}, {polygone.sommets[i], polygone.sommets[i+1]})
    local angle = Angle({polygone.x, polygone.y}, {polygone.sommets[i], polygone.sommets[i+1]})
    polygone.sommets[i] = polygone.x + math.sin(angle + rotation) * rayon
    polygone.sommets[i+1] = polygone.y + math.cos(angle + rotation) * rayon
  end
  polygone.triangles = love.math.triangulate(polygone.sommets)
end

function love.update(dt)
  local i
  for i=1,#polygones.liste do
    if polygones.liste[i].rotation then
      RotatePolygone(polygones.liste[i], -Angle45 * dt)
    end
  end
  
  if typeTest == 1 then
    RotateMouse(mouse, Angle5)
  elseif typeTest == 2 then
    mouse.Point = Point(love.mouse.getX(), love.mouse.getY())
  else
    plane.x = love.mouse.getX()
    plane.y = love.mouse.getY()
    for i=1,16,2 do
      plane.sommets[i] = plane.x+plane.masque[i]
      plane.sommets[i+1] = plane.y+plane.masque[i+1]
    end
  end
end

function love.draw()
  local i
  local j
  love.graphics.print("Appuyez sur [espace] pour changer de pointeur souris", 10, 10)
  love.graphics.print("[Echap] pour quitter", 10, 25)
  love.graphics.setColor(100,255,100)
  if typeTest == 1 then
    for i=1,#polygones.liste do
      if CollidePP(polygones.liste[i].sommets, mouse.sommets) then
        for j=1,#polygones.liste[i].triangles do
          love.graphics.polygon("fill", polygones.liste[i].triangles[j])
        end
      end
    end
  elseif typeTest == 2 then
    for i=1,#polygones.liste do
      if CollidePtP(mouse.Point, polygones.liste[i].sommets) then
        for j=1,#polygones.liste[i].triangles do
          love.graphics.polygon("fill", polygones.liste[i].triangles[j])
        end
      end
    end
  else
    for i=1,#polygones.liste do
      if CollidePP(polygones.liste[i].sommets, plane.sommets) then
        for j=1,#polygones.liste[i].triangles do
          love.graphics.polygon("fill", polygones.liste[i].triangles[j])
        end
      end
    end
  end
  love.graphics.setColor(255,255,255)
  for i=1,#polygones.liste do
    love.graphics.polygon("line", polygones.liste[i].sommets)
  end
  if typeTest == 1 then 
    love.graphics.setColor(255,100,100)
    for i=1,#mouse.triangles do
      love.graphics.polygon("fill", mouse.triangles[i])
    end
    love.graphics.setColor(255,255,255)
    love.graphics.polygon("line", mouse.sommets)
  elseif typeTest == 3 then
    love.graphics.polygon("line", plane.sommets)
    love.graphics.draw(plane.img, plane.x, plane.y, 0, 1, 1, plane.dx, plane.dy)
  end
end

function love.keypressed(key, scancode)
  if key == " " or key == "space" then
    if typeTest == 1 then
      typeTest = 2
      love.mouse.setVisible(true)
    elseif typeTest == 2 then
      typeTest = 3
      love.mouse.setVisible(false)
    else
      typeTest = 1
      love.mouse.setVisible(false)
    end
  end 

  if key == "escape" then
    love.event.quit()
  end
end