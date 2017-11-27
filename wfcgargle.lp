#const sx = 5.
#const sy = 3.
#const sz = 5.
#const stairs_per_floor = 1.
% define?
cell(1..sx, 1..sy, 1..sz).

% tiles, format: 
% pdef((tile name, 0), back edge, right edge, forward edge, left edge, bottom edge, top edge)

pdef((google_office_floor, 0),          path, path, path, path, normal, normal).

pdef((google_office_corner, 0),         path, path, wall, wall, normal, normal).

pdef((google_office_info_desk, 0),      path, path, path, path, normal, normal).

pdef((google_office_kitchen, 0),        path, path, wall, path, normal, normal).

pdef((google_office_kitchen_couch, 0),  path, path, corridor, path, normal, normal).

pdef((google_office_pillar, 0),         path, path, path, path, normal, normal).

% pdef((google_office_pillar, 0),         wall, wall, wall, wall, normal, normal).

pdef((google_office_pillar_alt, 0),     path, path, path, path, normal, normal).

pdef((air, 0),                          wall, wall, wall, wall, normal, normal).

assign(3, 1..sy, 3, (air, 0)).

% full staircase is a multi-tile (spans a 1x2x1 block) so an empty dummy tile must be placed above it 
% it has to be a multitle bc if it wasn't the top part of the staircase might have been
% a different rotation to the bottom part and so be untraversable

pdef((google_spiral_staircase_full, 0), path, path, path, path, normal, stair).
pdef((empty, 0),                        path, path, path, path, stair, normal).

pdef((google_office_corridor, 0),       corridor, wall, corridor, wall, normal, normal).

pdef((google_office_wall_door, 0),      path, path, corridor, path, normal, normal).

pdef((google_office_wall_door, 0),      path, path, path, path, normal, normal).

% generate rotations of the tile
pdef((P, I), E4, E1, E2, E3, U, D) :- pdef((P, I - 1), E1, E2, E3, E4, U, D), I <= 4, I >= 0.

pattern(P) :- pdef(P, _, _, _, _, _, _).

%extra(google_staircase_bottom).
%extra(google_spiral_staircase_top).

%must_exist((P, I)) :- pattern((P, I)).

walkable(path).
walkable(stair).
walkable(corridor).

dx( 0, 1, 0).
dx( 1, 0, 0).
dx( 0, 0, 1).
dx( 0,-1, 0).
dx(-1, 0, 0).
dx( 0, 0,-1).

% any pattern can be placed on itself
legal(0, 0, 0, P, P) :- pattern(P).

% P1 can be above P2 if P1's bottom edge and P2'
% top edge are connectable
legal(0, 0, 1, P1, P2) :-
  pdef(P1, E1, _, _, _, _, _), 
  pdef(P2, _, _, E2, _, _, _), 
  E1 == E2.

% P1 can be left of P2 if P1's right edge and P2's
% left edge are connectable
legal(1, 0, 0, P1, P2) :-
  pdef(P1, _, E1, _, _, _, _), 
  pdef(P2, _, _, _, E2, _, _), 
  E1 == E2.

% P1 can be below P2 if P1's top edge and P2's
% bottom edge are connectable
legal(0, 0, -1, P1, P2) :-
  pdef(P1, _, _, E1, _, _, _), 
  pdef(P2, E2, _, _, _, _, _), 
  E1 == E2.

% P1 can be right of P2 if P1's left edge and P2's
% right edge are connectable
legal(-1, 0, 0, P1, P2) :-
  pdef(P1, _, _, _, E1, _, _), 
  pdef(P2, _, E2, _, _, _, _), 
  E1 == E2.

legal(0, 1, 0, P1, P2) :-
  pdef(P1, _, _, _, _, E1, _),
  pdef(P2, _, _, _, _, _, E2),
  E1 == E2.

legal(0, -1, 0, P1, P2) :-
  pdef(P1, _, _, _, _, _, E1),
  pdef(P2, _, _, _, _, E2, _),
  E1 == E2.

% walkable means that it's possible to walk from 
% p1 to p2 in direction (DX, DY, DZ)
walkable(0, 0, 1, P1, P2) :-
  pdef(P1, E1, _, _, _, _, _), 
  pdef(P2, _, _, E1, _, _, _),
  walkable(E1).

walkable(1, 0, 0, P1, P2) :-
  pdef(P1, _, E1, _, _, _, _), 
  pdef(P2, _, _, _, E1, _, _),
  walkable(E1).

walkable(0, 0, -1, P1, P2) :-
  pdef(P1, _, _, E1, _, _, _), 
  pdef(P2, E1, _, _, _, _, _),
  walkable(E1). 

walkable(-1, 0, 0, P1, P2) :-
  pdef(P1, _, _, _, E1, _, _), 
  pdef(P2, _, E1, _, _, _, _),
  walkable(E1).

walkable(0, 1, 0, P1, P2) :-
  pdef(P2, _, _, _, _, E1, _),
  pdef(P1, _, _, _, _, _, E1),
  walkable(E1).

walkable(0, -1, 0, P1, P2) :-
  pdef(P1, _, _, _, _, _, E1),
  pdef(P2, _, _, _, _, E1, _),
  walkable(E1).


% there's an edge between two tiles if 
% we can walk from that tile to the other
% (we'll use this to check for connectivity later)
edge((X1, Y1, Z1), (X2, Y2, Z2)) :- 
  assign(X1, Y1, Z1, P1), 
  assign(X2, Y2, Z2, P2),
  adj(X1, Y1, Z1, X2, Y2, Z2, DX, DY, DZ),
  walkable(DX, DY, DZ, P1, P2).

connected(X,Z) :- edge(X,Z).

connected(X,Z) :- edge(X,Y), connected(Y,Z).

% two positions are adjacent if they are within cells and the difference
% in x and y is equal to dx and dy
adj(X1, Y1, Z1, X2, Y2, Z2, DX, DY, DZ) :-
  cell(X1, Y1, Z1), cell(X2, Y2, Z2),
  dx(DX, DY, DZ), (X1 - X2)==DX, (Y1 - Y2)==DY, (Z1 - Z2)==DZ.

% generate?
1 { assign(X,Y,Z,P):pattern(P) } 1 :- cell(X,Y,Z).

% fail if two cells are adjacent and one of them is assigned P1 at X1 Y1
% but no legal assignment for X2 Y2 exists
:- adj(X1,Y1,Z1,X2,Y2,Z2,DX,DY,DZ), assign(X1,Y1,Z1,P1),
  not 1 { assign(X2,Y2,Z2,P2):legal(DX,DY,DZ,P1,P2) }.
  
% at least 1 rotation of every pattern must be present at least 1 times
:- pattern((P, _)), not 1 { assign(X,Y,Z,(P, _)):cell(X,Y,Z) }.

floor(1..sy).

% any floor can have 1 to k staircases
%:- floor(I), not 1 <= #count { assign(X,Y,Z,(google_spiral_staircase_full, 0..3)):cell(X,Y,Z) } 
%                    <= stairs_per_floor.

% the corners of every floor must be connected

%:- not connected((2, 1, 2), (2, sy, 2)).
%:- not connected((1, 1, 1), (2, 1, 2)).

hot(X) :- connected(X, (1,1,1)).

:- not hot((1..2, 5, 1..2)).

% there must be a cell on storey 1 connected to a cell on the top storey
% :- not 1 <= #count { must_connect_to((X, sy, z)):cell(X,sy,Z) }.
#show edge/2.
#show hot/1.
#show assign/4.
%#show edge/2.
