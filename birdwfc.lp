#const sx = 7.
#const sy = 10.
#const sz = 7.
% define?
cell(1..sx, 1..sy, 1..sz).

assign(1..sx, 1,  1, (green_ground, 0)).
assign(1,     1,  1..sz, (green_ground, 0)).
assign(1..sx, 1,  sz, (green_ground, 0)).
assign(sx,    1,  1..sz, (green_ground, 0)).

assign(1..sx, 2..sy,  1, (air, 0)).
assign(1,     2..sy,  1..sz, (air, 0)).
assign(1..sx, 2..sy,  sz, (air, 0)).
assign(sx,    2..sy,  1..sz, (air, 0)).

% tiles, format: 
% pdef((tile name, 0), back edge, left edge, forward edge, right edge, bottom edge, top edge)

pdef((green_ground, 0), grass, grass, grass, grass, ground, air).

pdef((interior_ground, 0), igrass, igrass, igrass, igrass, ground, ground).
%pdef((interior_ground, 0), air, air, air, air, ground, air).

%pdef((pillar_4_knot,   0), air, air, air, air, pillar4, pillar4).
%pdef((pillar_4_knot,   0), air, air, air, air, pillar4, air).
pdef((pillar_4_pillar, 0), air, air, air, air, pillar4, pillar4).
pdef((pillar_4_pillar, 0), air, air, air, air, pillar4, air).
pdef((pillar_4_bottom, 0), grass, grass, grass, grass, ground, pillar4).
pdef((pillar_4_bottom, 0), grass, grass, grass, grass, ground, air).
pdef((pillar_4_cap, 0), air, air, air, air, pillar4, ground).

pdef((buttress, 0), wall_face_flat, air_padded, air_padded, air_padded, air, ground).
pdef((corner_building, 0), wall_face, wall_face, wall_l, wall_r, ground, ground).
pdef((corner_building_windows, 0), wall_face, wall_face, wall_l, wall_r, ground, ground).

pdef((wall_building_all_window, 0), window_r, wall_face, window_l, igrass, ground, ground).
pdef((wall_building_side_window, 0), wall_r, wall_face, wall_l, igrass, ground, ground).
pdef((wall_building_window_end, 0), wall_r, wall_face, window_l, igrass, ground, ground).
pdef((wall_building_window_end_rev, 0), window_r, wall_face, wall_l, igrass, ground, ground).
pdef((wall_building_window_window, 0), window_r, wall_face, window_l, igrass, ground, ground).

pdef((air, 0), air, air, air, air, air, air).
pdef((air, 0), air, air, air, air, ground, air).

% generate rotations of the tile
pdef((P, I), E4, E1, E2, E3, U, D) :- pdef((P, I - 1), E1, E2, E3, E4, U, D), I <= 3, I >= 0.

% floor(4..(sy - 1)).

% at least 2 different tiles on each "floor"
%:- floor(I), 
%   not 2 { patternD(P):assignD(X,I,Z,P) }.

% :- floor(I), not 80 { assignD(X,I,Z,air):cell(X,I,Z) } 95.

% at least 1/3 of each floor should be air
%:- floor(5..6;8..10;13..16;20..21),
%  not 80 { assignD(X,I,Z,air):cell(X,I,Z) }.

:- not 5 { assignD(X1,Y1,Z1,pillar_4_pillar):cell(X1,Y1,Z1) }.

pattern(P) :- pdef(P, _, _, _, _, _, _).

not_self(wall_face_flat).
not_self(air_padded).
not_self(wall_face).
not_self(wall_l).
not_self(wall_r).
not_self(window_l).
not_self(window_r).

% same edges can always connect to each other
connectable(E1, E1) :- pdef(_, E1, _, _, _, _, _), not not_self(E1).
connectable(E1, E1) :- pdef(_, _, E1, _, _, _, _), not not_self(E1).
connectable(E1, E1) :- pdef(_, _, _, E1, _, _, _), not not_self(E1).
connectable(E1, E1) :- pdef(_, _, _, _, E1, _, _), not not_self(E1).
connectable(E1, E1) :- pdef(_, _, _, _, _, E1, _), not not_self(E1).
connectable(E1, E1) :- pdef(_, _, _, _, _, _, E1), not not_self(E1).
connectable(E1, E2) :- connectable(E2, E1).

%connectable(air, air).
connectable(air, air_padded).
connectable(wall_face, air).
connectable(grass, wall_face).
connectable(wall_l, wall_r).
connectable(window_l, window_r).
connectable(wall_face_flat, wall_face).

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
:- patternD(P), not 1 { assignD(X,Y,Z,P):cell(X,Y,Z) }.

% there must be a cell on storey 1 connected to a cell on the top storey
% :- not 1 <= #count { must_connect_to((X, sy, z)):cell(X,sy,Z) }.
#show assign/4.
