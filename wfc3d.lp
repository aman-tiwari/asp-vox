#const sx = 5.
#const sy = 10.
#const sz = 5.
% define?
cell(1..sx, 1..sy, 1..sz).

% tiles, format: 
% pdef((tile name, 0), bottom edge, right edge, top edge, left edge)

pdef((line_v, 0), empty, path, empty, path, reg, reg).

pdef((none, 0), empty, empty, empty, empty, reg, reg).

pdef((plus, 0), path, path, path, path, reg, reg).

pdef((corner, 0), path, path, empty, empty, reg, reg).

pdef((tee, 0), empty, path, path, path, reg, reg).

pdef((stair_bot, 0), empty, path, empty, empty, st, reg).

pdef((stair_top, 0), empty, empty, empty, path, reg, st).

% generate rotations of the tile
pdef((P, I), E4, E1, E2, E3, U, D) :- pdef((P, I - 1), E1, E2, E3, E4, U, D), I <= 4, I >= 0.

pattern(P) :- pdef(P, _, _, _, _, _, _).

extra(stair_bot).
extra(stair_top).

must_exist((P, I)) :- pattern((P, I)), not extra(P).

walkable(path).
walkable(st).

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
  pdef(P1, _, _, _, _, E1, _),
  pdef(P2, _, _, _, _, _, E1),
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
  walkable(X1 - X2, Y1 - Y2, Z1 - Z2, P1, P2).

edge(X,Y) :- edge(Y,X).

connected(X,Y):- edge(X,Y).

connected(X,Z):- edge(X,Y) ; connected(Y,Z).

% P1 can be left/below of P2 if P2 can be right/above P1
% legal(DX, DY, P1, P2) :- legal(-DX, -DY, P2, P1).

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
  
% every important pattern must be present at least 1 times
:- must_exist((P, _)), not 1 { assign(X,Y,Z,(P, _)):cell(X,Y,Z) }.

% there must be a cell on the floor 1 connected to a cell on the top floor
:- not 1 { connected((X1, 1, Z1), (X2, sy, Z2)):cell(X2,sy,Z2),cell(X1,1,Z1) }.

#show assign/4.
%#show edge/2.
