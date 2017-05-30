Collisions

Cette librairie permet de gérer les collisions dans lua/love2d en utilisant
pour les formes complexes l'algorithme du héron, ou plutôt la méthode de héron.

Cette méthode part du principe suivant :
Nous avons un rectangle [ABC] et un point P
Nous voulons savoir si le point P est DANS le triangle [ABC].
Pour ce faire, nous calculons l'aire de [ABC], ainsi que les aides des triangles
formés par [PBC], [APC] et [ABP]. Si la somme de l'aire de ces 3 triangles est
égal à l'aide du triangle [ABC], alors le point P est bien DANS le triangle [ABC]

Il y a également les fonctions de collisions rectangulaire de type AABB et
de type circulaire avec les distances entre 2 points moins les rayons
des deux cercles.
