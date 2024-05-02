--[[
  Collisions.lua, créé par Christophe FOUBET, aka Veronimish sur Gamecodeur.fr
  
  Cette librairie donne accès à diverses fonctions de calculs servants couramment dans les jeux.
  Son usage demande le respect de certaines règles. Les valeurs sont toujours en nombre pair car représentant des points ou sommets x, y
    - Voici la forme que prennent ces paramètres :
      - pt, pt1, pt2 sont des points au format : {valeur, valeur} - soit {x, y}
      - c, c1, c2 sont des cercles au format : {valeur, valeur, valeur} - soit {x, y, rayon}
      - r, r1, r2 sont des rectangles au format : {valeur, valeur, valeur, valeur} - soit {x, y, largeur, hauteur}
      - t, t1, t2 sont des triangles au format : {valeur, valeur, valeur, valeur, valeur, valeur} - soit { x1, y1, x2, y2, x3, y3}
      - p, p1, p2 sont des polygones au format : {valeur, valeur, .., .., valeur, valeur} - soit { x1, y1, .., .., xN, yN}
      
  Dans les dénominations des fonctions, lire :
    - Pt = Point, C = cercle, R = rectangle, T = Triangle, P = Polygone
    
  Ainsi une fonction de collision entre 2 cercles est nommée CollisionCC et demande donc en paramètres (c1, c2)

  Pour créer cette librairie, je me suis basé sur la méthode dite du Héron. Vous la trouverez sur Wikipedia.
  Tout est basé sur les comparaisons d'aires de triangles
  Un point P sera considéré comme étant a l'intérieur d'un triangle [ABC] si la somme des aires des 3 triangles
  suivants [PBC], [APC] et [ABP] est égale à l'aire du triangle [ABC]
  
  Vu le nombre important de calculs effectués, je pense qu'il vaux mieux éviter de gérer un trop grand nombre de collisions simultanées
]]--

-- Liste d'angles précalculés pour éviter de faire appel trop souvent à math.rad()
Angle5 = 0.087      -- 72
Angle10 = 0.174     -- 36
Angle15 = 0.261     -- 24
Angle30 = 0.523     -- 12
Angle36 = 0.628     -- 10
Angle45 = 0.785     --  8
Angle90 = 1.570     --  4
Angle120 = 2.094    --  3
Angle180 = 3.141    --  2 
Angle360 = 6.283    --  1

-- Cette fonction renvoi la distance entre deux points.
function Distance(pt1, pt2)
  return ((pt1[1] - pt2[1])^2 + (pt1[2] - pt2[2])^2)^0.5
end

-- Cette fonction renvoi l'angle de pt2 par rapport à pt1.
function Angle(pt1, pt2)
  return math.atan2(pt2[1] - pt1[1], pt2[2] - pt1[2])
end

-- Cette fonction renvoi la surface d'un triangle dont les sommets sont pt1, pt2 et pt3.
function Aire(pt1, pt2, pt3)
  local AB = ((pt1[1] - pt2[1])^2 + (pt1[2] - pt2[2])^2)^0.5
  local BC = ((pt2[1] - pt3[1])^2 + (pt2[2] - pt3[2])^2)^0.5
  local CA = ((pt3[1] - pt1[1])^2 + (pt3[2] - pt1[2])^2)^0.5
  local P = (AB + BC + CA) / 2
  return (P*(P-AB)*(P-BC)*(P-CA))^0.5
end

-- Fonction d'arrondi utilisee par les calculs de collisions.
function Round(valeur, decimales)
	local decalage = 10 ^decimales
	return math.floor( valeur * decalage + 0.5) / decalage
end

-- Fonction qui renvoi un point au format {valeur, valeur}.
-- Utile pour placer les paramètres.
-- Usage :
-- A la place de : Distance({x, y}, {x, y})
-- Utilisez        Distance(Point(x, y), Point(x, y))
function Point(x, y)
  return {x, y}
end

-- Fonction qui renvoi un triangle au format {valeur, valeur, valeur, valeur, valeur, valeur}.
-- Utile pour placer les paramètres.
-- Usage : Triangle(Point(x, 1), Point(x, y), Point(x, y))
function Triangle(PtA, PtB, PtC)
  return {PtA[1], PtA[2], PtB[1], PtB[2], PtC[1], PtC[2]}
end

function Rectangle(x, y, width, height)
  return {x, y, width, height}
end

-- Fonction qui renvoi true si les cercles c1 et c2 sont en contact.
function CollisionCC(c1, c2)
  return ((c1[1] - c2[1])^2 + (c1[2] - c2[2])^2)^0.5 < (c1[3] + c2[3])
end

-- Fonction qui renvoi true si le point pt est en contact ou dans le cercle c.
function CollisionPtC(pt, c)
  local distance = ((p[1] - c[1])^2 + (p[2] - c[2])^2)^0.5
  return (distance < c[3])
end

-- Fonction qui renvoi true si les rectangles r1 et r2 sont en contact.
function CollisionRR(r1, r2)
    return not (
      ( r1[1] >= r2[1] + r2[3] ) or
      ( r1[2] >= r2[2] + r2[4] ) or
      ( r1[1] + r1[3] <= r2[1] ) or
      ( r1[2] + r1[4] <= r2[2] )
    )
end

-- Fonction qui renvoi true si le point pt est en contact ou dans le rectangle r.
function CollisionPtR(pt, r)
    return (
      ( pt[1] >= r[1] ) and ( pt[1] <= r[1] + r[3] ) and
      ( pt[2] >= r[2] ) and ( pt[2] <= r[2] + r[4] )
    )
end

function CollidePtT(pt, t)
  local D = {x=pt[1], y=pt[2]}
  local A = {x=t[1], y=t[2]}
  local B = {x=t[3], y=t[4]}
  local C = {x=t[5], y=t[6]}
  -- Fonction pour calculer les coordonnées barycentriques du point D par rapport au triangle ABC
  local function coordonnees_barycentriques(A, B, C, D)
    local denominateur = (B.y - C.y) * (A.x - C.x) + (C.x - B.x) * (A.y - C.y)
    local alpha = ((B.y - C.y) * (D.x - C.x) + (C.x - B.x) * (D.y - C.y)) / denominateur
    local beta = ((C.y - A.y) * (D.x - C.x) + (A.x - C.x) * (D.y - C.y)) / denominateur
    local gamma = 1 - alpha - beta
    return alpha, beta, gamma
  end

  -- Calculer les coordonnées barycentriques de D par rapport à ABC
  local alpha, beta, gamma = coordonnees_barycentriques(A, B, C, D)

  -- Vérifier si les coordonnées barycentriques sont comprises entre 0 et 1
  if 0 <= alpha and alpha <= 1 and 0 <= beta and beta <= 1 and 0 <= gamma and gamma <= 1 then
    return true
  else
    return false
  end
end



-- Fonction qui renvoi true si le triangle t1 et le triangle t2 sont en contact.
function CollideTT(t1, t2)
  local pos = 1
  for i=1,3 do
    if CollidePtT({t1[pos], t1[pos+1]}, t2) or CollidePtT({t2[pos], t2[pos+1]}, t1) then
      return true
    end
    pos = pos+2
  end
  return false
end

-- Fonction qui renvoi true si le point pt est en contact ou dans le polygone pt.
function CollidePtP(pt, p)
  local pos = 1
  local triangles = love.math.triangulate(p)
  for i=1,#triangles do
    if CollidePtT(pt, triangles[i]) then
      return true
    end
  end
  return false
end

-- Fonction qui renvoi true si les polygones p1 et p2 sont en contact.
function CollidePP(p1, p2)
  local trianglesP1 = love.math.triangulate(p1)
  local trianglesP2 = love.math.triangulate(p2)
  for i=1,#trianglesP1 do
    local t1 = trianglesP1[i]
    for j=1,#trianglesP2 do
      local t2 = trianglesP2[j]
      if CollideTT(t1, t2) then
        return true
      end
    end
  end
  return false
end
