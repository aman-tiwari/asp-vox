#const sx = 9.
#const sy = 9.
#const sz = 5.

#const ax = 7.
#const az = 7.

#const atrium_size = 3.
#const stairs_per_floor = 1.
% define?
%cell(1..sx, 1..sy, 1..sz).

#const aox = sx/2 - atrium_size/2 + 1.
#const aoz = sz/2 - atrium_size/2 + 1.

cell(1..sx, 1..sy, 1..(sz/2 - atrium_size/2)).
cell(1..sx, 1..sy, (sz/2 + 1 + atrium_size/2 + 1)..sz).

cell(1..(sx/2 - atrium_size/2), 1..sy, (sz/2 - atrium_size/2)..(sz/2 + atrium_size/2 + 1)).
cell((sx/2 + 1 + atrium_size/2 + 1)..sx, 1..sy, (sz/2 - atrium_size/2)..(sz/2 + atrium_size/2 + 1)).

% grid(1..sx, 1..sy, 1..sz).

% cutout((sx/2 - atrium_size/2 + 1)..(sx/2 + atrium_size/2))

% cell(X,Y,Z) :- grid(X,Y,Z), not cutout(X,Y,Z).

% tiles, format: 
% pdef((tile name, 0), back edge, right edge, forward edge, left edge, bottom edge, top edge)

pdef((google_office_floor, 0),          path, path, path, path, normal, normal).

pdef((google_office_corner, 0),         path, path, wall, wall, normal, normal).

pdef((google_office_corner_plain, 0),   path, path, wall, wall, normal, normal).

pdef((google_office_info_desk, 0),      path, path, path, path, normal, normal).

pdef((google_office_kitchen, 0),        path, path, wall, path, normal, normal).

pdef((google_office_kitchen_couch, 0),  path, path, corridor, path, normal, normal).

pdef((google_office_kitchen_couch, 0),  path, path, wall, path, normal, normal).

pdef((google_office_kitchen_couch, 0),  path, path, path, path, normal, normal).

pdef((google_office_pillar, 0),         path, path, path, path, normal, normal).

pdef((google_office_pillar_alt, 0),     path, path, path, path, normal, normal).

pdef((google_office_roomish, 0),     path, corridor, wall, wall, normal, normal).
pdef((google_office_roomish, 0),     path, path, wall, wall, normal, normal).

pdef((castle_floor_pillar, 0),      path, path, path, path, normal, pillar).
pdef((castle_floor_pillar, 0),      wall, path, path, path, normal, pillar).
pdef((castle_floor_pillar, 0),      wall, wall, path, path, normal, pillar).
pdef((castle_floor_pillar, 0),      wall, path, wall, path, normal, pillar).
pdef((castle_floor_pillar, 0),      wall, wall, wall, path, normal, pillar).

pdef((castle_floor_pillar_top, 0),  path2, wall, wall, wall, pillar, normal).
pdef((castle_floor_pillar_top, 0),  path2, path2, path2, wall, pillar, normal).
pdef((castle_floor_pillar_top, 0),  wall, wall, wall, wall, pillar, normal).
pdef((castle_floor_pillar_top, 0),  wall, path2, wall, path2, pillar, normal).

% pdef((air, 0),                          wall, wall, wall, wall, normal, normal).

% full staircase is a multi-tile (spans a 1x2x1 block) so an empty dummy tile must be placed above it 
% it has to be a multitle bc if it wasn't the top part of the staircase might have been
% a different rotation to the bottom part and so be untraversable

pdef((google_spiral_staircase_full, 0), path, path, path, path, normal, stair).
pdef((empty, 0),                        path, path, path, path, stair, normal).

pdef((google_office_corridor, 0),       corridor, wall, corridor, wall, normal, normal).
pdef((google_office_corridor, 0),       path, wall, path, wall, normal, normal).
%pdef((google_office_corridor, 0),       corridor, path, corridor, path, normal, normal).

pdef((google_office_wall_door, 0),      path, path, corridor, path, normal, normal).

pdef((google_office_wall_door, 0),      path, path, path, path, normal, normal).


%assign(0, 1..sy, 1..sz, (google_office_floor_window_solid, 0)).

%assign(sx + 1, 1..sy, 1..sz, (google_office_floor_window_solid, 2)).

%assign(1..sx, 1..sy, 0, (google_office_floor_window_solid, 1)).

%assign(1..sx, 1..sy, sz + 1, (google_office_floor_window_solid, 3)).

% forced placement of windows
forced(0, 1..sy, 1..sz, (google_office_floor_window, 1)).

forced(sx + 1, 1..sy, 1..sz, (google_office_floor_window, 3)).

forced(1..sx, 1..sy, 0, (google_office_floor_window, 0)).

forced(1..sx, 1..sy, sz + 1, (google_office_floor_window, 2)).

forced(sx/2 - atrium_size/2 + 1, 
       1..sy,  
       (sz/2 - atrium_size/2 + 1)..(sz/2 + atrium_size/2 + 1),
       (google_office_floor_window, 3)).

forced(sx/2 + atrium_size/2 + 1, 
       1..sy,  
       (sz/2 - atrium_size/2+1)..(sz/2 + atrium_size/2+1),
       (google_office_floor_window, 1)).

forced((sx/2 - atrium_size/2+1)..(sx/2 + atrium_size/2 + 1), 
       1..sy,  
       sz/2 - atrium_size/2 + 1,
       (google_office_floor_window, 2)).

forced((sx/2 - atrium_size/2 + 1)..(sx/2 + atrium_size/2 + 1), 
       1..sy,  
       sz/2 + atrium_size/2 + 1,
       (google_office_floor_window, 0)).

% generate rotations of the tile
pdef((P, I), E4, E1, E2, E3, U, D) :- pdef((P, I - 1), E1, E2, E3, E4, U, D), I <= 3, I >= 0.

pattern(P) :- pdef(P, _, _, _, _, _, _).

% sane basement
% assign(0..sx, 0, 0..sz, (google_office_floor, 0)).

%pdef((google_window_box, 0), window, window, window, window, normal, normal).

%extra(google_staircase_bottom).
%extra(google_spiral_staircase_top).

%must_exist((P, I)) :- pattern((P, I)).

walkable(path).
walkable(stair).
walkable(corridor).

connectable(path, path2).
connectable(path2, path).
connectable(pillar, pillar).
connectable(path, path).
connectable(corridor, corridor).
connectable(stair, stair).
connectable(normal, normal).

%connectable(path, window).
%connectable(window, path).

%connectable(wall, window).
%connectable(window, wall).

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
  connectable(E1, E2).
%  E1 == E2.

% P1 can be left of P2 if P1's right edge and P2's
% left edge are connectable
legal(1, 0, 0, P1, P2) :-
  pdef(P1, _, E1, _, _, _, _), 
  pdef(P2, _, _, _, E2, _, _), 
  connectable(E1, E2).
%  E1 == E2.

% P1 can be below P2 if P1's top edge and P2's
% bottom edge are connectable
legal(0, 0, -1, P1, P2) :-
  pdef(P1, _, _, E1, _, _, _), 
  pdef(P2, E2, _, _, _, _, _), 
  connectable(E1, E2).
%  E1 == E2.

% P1 can be right of P2 if P1's left edge and P2's
% right edge are connectable
legal(-1, 0, 0, P1, P2) :-
  pdef(P1, _, _, _, E1, _, _), 
  pdef(P2, _, E2, _, _, _, _), 
  connectable(E1, E2).
%  E1 == E2.

legal(0, 1, 0, P1, P2) :-
  pdef(P1, _, _, _, _, E1, _),
  pdef(P2, _, _, _, _, _, E2),
  connectable(E1, E2).
%  E1 == E2.

legal(0, -1, 0, P1, P2) :-
  pdef(P1, _, _, _, _, _, E1),
  pdef(P2, _, _, _, _, E2, _),
  connectable(E1, E2).
%  E1 == E2.

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
  
patternD(P) :- pattern((P, _)).
assignD(X,Y,Z,P) :- assign(X,Y,Z,(P, _)), patternD(P).
%#show patternD/1.
%#show assignD/4.

% at least 1 rotation of every pattern must be present at least 3 times
:- patternD(P), not 1 <= { assignD(X,Y,Z,P):cell(X,Y,Z) }.

nbhood(-2..2, -1..1, -2..2).

neib(X1,Y1,Z1, X2,Y2,Z2) :-
  nbhood(X2 - X1, Y2 - Y1, Z2 - Z1),
  cell(X1, Y1, Z1), cell(X2, Y2, Z2).

% don't put staircases next to each other
:- assign(X1,Y1,Z1, (google_spiral_staircase_full, _)),
    assign(X2,Y2,Z2, (google_spiral_staircase_full, _)),
    X1 != X2,
    neib(X1,Y1,Z1, X2,Y2,Z2).

:- assign(X1,Y1,Z1, (google_spiral_staircase_full, _)),
   assign(X2,Y2,Z2, (google_spiral_staircase_full, _)),
   Y1 != Y2,
   neib(X1,Y1,Z1, X2,Y2,Z2).

:- assign(X1,Y1,Z1, (google_spiral_staircase_full, _)),
   assign(X2,Y2,Z2, (google_spiral_staircase_full, _)),
   Z1 != Z2,
   neib(X1,Y1,Z1, X2,Y2,Z2).

% :- cell(X,Y,Z), not 1 { assign(X1,Y1,Z1,(google_spiral_staircase_full, _)): }

floor(1..sy).

special_pattern((wifi_monolith, 0)).
special_pattern((power_socket, 0)).
special_pattern((qr_code, 0)).

% these can be placed on any tile
placeable_atop((wifi_monolith, 0), P) :- pattern(P).
placeable_atop((power_socket, 0), P) :- pattern(P).
placeable_atop((qr_code, 0), P) :- pattern(P), P != (empty, 0..3).

0 <= {special_assign(X,Y,Z,P) : special_pattern(P)} <= 1 :- cell(X,Y,Z).

:- special_assign(X,Y,Z,SP), assign(X,Y,Z,P), not placeable_atop(SP, P).

:- special_pattern(P), floor(I), not 1 { special_assign(X,I,Z,P):hot((X,I,Z)) } 2.

% any floor can have 1 to k staircases doesnt work...
:- floor(I), 4 <= { assign(X,Y,Z,(google_spiral_staircase_full, 0..3)):cell(X,Y,Z) }.

% the corners of every floor must be connected

%:- not connected((2, 1, 2), (2, sy, 2)).
%:- not connected((1, 1, 1), (2, 1, 2)).

hot(X) :- connected(X, ((2,2,5)).

:- not hot((1..2, sy, 1..2)).
:- not hot(((sx - 2), sy, (sz-2)..sz)).
:- not hot((2,2,9)).
% there must be a cell on storey 1 connected to a cell on the top storey
% :- not 1 <= #count { must_connect_to((X, sy, z)):cell(X,sy,Z) }.
#show edge/2.
#show hot/1.
#show assign/4.
#show forced/4.
#show special_assign/4.
