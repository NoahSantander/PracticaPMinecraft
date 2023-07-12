jugador(stuart, [piedra, piedra, piedra, piedra, piedra, piedra, piedra, piedra], 3).
jugador(tim, [madera, madera, madera, madera, madera, pan, carbon, carbon, carbon, pollo, pollo], 8).
jugador(steve, [madera, carbon, carbon, diamante, panceta, panceta, panceta], 2).

lugar(playa, [stuart, tim], 2).
lugar(mina, [steve], 8).
lugar(bosque, [], 6).

comestible(pan).
comestible(panceta).
comestible(pollo).
comestible(pescado).

% 1.a
% tieneItem/2 Relaciona a un jugador con el item que posee
tieneItem(Jugador, Item):-
    jugador(Jugador, Items, _),
    member(Item, Items).

% 1.b
tieneMasDeUnComestible(Items):-
    comestible(Comestible1),
    comestible(Comestible2),
    Comestible1 \= Comestible2,
    member(Comestible1, Items),
    member(Comestible2, Items).

% sePreocupaPorSuSalud/1 Saber si un jugador tiene entre sus items mas de un tipo comestible
sePreocupaPorSuSalud(Jugador):-
    jugador(Jugador, Items, _),
    tieneMasDeUnComestible(Items).

% 1.c
% cuantoSeRepite/3 Relacionar un item con la cantidad de veces que aparece en un inventario
cuantoSeRepite(_, [], 0).
cuantoSeRepite(Item, [ItemInventario|RestoInventario], CantidadTotal):-
    Item \= ItemInventario,
    cuantoSeRepite(Item, RestoInventario, CantidadSiguiente),
    CantidadTotal is CantidadSiguiente + 0.
cuantoSeRepite(Item, [Item|RestoInventario], CantidadTotal):-
    cuantoSeRepite(Item, RestoInventario, CantidadSiguiente),
    CantidadTotal is CantidadSiguiente + 1.

% cantidadDelItem/3 Relacionar un jugador con un ítem que existe (un ítem existe si lo tiene alguien), y la cantidad que tiene de ese ítem
cantidadDelItem(Jugador, Item, 0):-
    not(tieneItem(Jugador, Item)).
cantidadDelItem(Jugador, Item, Cantidad):-
    tieneItem(Jugador, Item),
    jugador(Jugador, Inventario, _),
    cuantoSeRepite(Item, Inventario, Cantidad).

% 1.d
% noEsElQueMasTiene/3 Relaciona un item con el jugador que tiene mas que el otro
noEsElQueMasTiene(Item, JugadorQueTieneMas, JugadorQueTieneMenos):-
    tieneItem(JugadorQueTieneMas, Item),
    cantidadDelItem(JugadorQueTieneMas, Item, CantidadMayor),
    cantidadDelItem(JugadorQueTieneMenos, Item, CantidadMenor),
    CantidadMayor > CantidadMenor.

% tieneMasDe/2 Relacionar un jugador con un ítem, si de entre todos los jugadores, es el que más cantidad tiene de ese ítem
tieneMasDe(Jugador, Item):-
    tieneItem(Jugador, Item),
    not(noEsElQueMasTiene(Item, _, Jugador)).

% 2.a
% hayMounstros/1 Saber en que lugar hay mounstros
hayMounstros(Lugar):-
    lugar(Lugar, _, NivelDeOscuridad),
    NivelDeOscuridad > 6.

% 2.b
% correPeligro/1 Saber si un jugador corre peligro
correPeligro(Jugador):-
    jugador(Jugador, _, Hambre),
    Hambre < 4,
    not(sePreocupaPorSuSalud(Jugador)).

correPeligro(Jugador):-
    hayMounstros(Lugar),
    lugar(Lugar, Gente, _),
    member(Jugador, Gente).

% 2.c
% estaHambriento/2 Relaciona a un lugar y si hay una persona hambrienta en ella
estaHambriento(Lugar, Hambriento):-
    lugar(Lugar, Poblacion, _),
    jugador(Hambriento, _, Hambre),
    Hambre < 4,
    member(Hambriento, Poblacion).

% nivelPeligrosidad/2 Relaciona un lugar con su nivel de peligrosidad
nivelPeligrosidad(Lugar, 100):-
    hayMounstros(Lugar).

nivelPeligrosidad(Lugar, NivelPeligrosidad):-
    lugar(Lugar, Poblacion, NivelDeOscuridad),
    length(Poblacion, 0),
    NivelPeligrosidad is NivelDeOscuridad * 10.

nivelPeligrosidad(Lugar, NivelPeligrosidad):-
    lugar(Lugar, Poblacion, _),
    not(hayMounstros(Lugar)),
    findall(Hambriento, estaHambriento(Lugar, Hambriento), ListaHambrientos),
    length(ListaHambrientos, CantHambrientos),
    length(Poblacion, CantPoblacion),
    NivelPeligrosidad is (100*CantHambrientos)/CantPoblacion.

% 3
item(horno, [itemSimple(piedra, 8)]).
item(placaDeMadera, [itemSimple(madera, 1)]).
item(palo, [itemCompuesto(placaDeMadera)]).
item(antorcha, [itemCompuesto(palo), itemSimple(carbon, 1)]).

puedeConstruilo(Jugador, itemSimple(Item, Cantidad)):-
    tieneItem(Jugador, Item),
    cantidadDelItem(Jugador, Item, CantidadItem),
    Cantidad =< CantidadItem.

% puedeConstruir/2 Relacionar un jugador con un item que puede construir
puedeConstruir(Jugador, Item):-
    item(Item, Requisitos),
    satisfaceRequisitos(Jugador, Requisitos).

satisfaceRequisitos(Jugador, [itemSimple(Item, Cantidad)]):-
    puedeConstruilo(Jugador, itemSimple(Item, Cantidad)).

satisfaceRequisitos(Jugador, [itemCompuesto(Item)]):-
    puedeConstruir(Jugador, Item).

satisfaceRequisitos(Jugador, [itemCompuesto(Item)|SiguienteRequisito]):-
    puedeConstruir(Jugador, Item),
    satisfaceRequisitos(Jugador, SiguienteRequisito).

satisfaceRequisitos(Jugador, [itemSimple(Item, Cantidad)|SiguienteRequisito]):-
    puedeConstruilo(Jugador, itemSimple(Item, Cantidad)),
    satisfaceRequisitos(Jugador, SiguienteRequisito).
    
    
% 4.a
% Al querer consultar el nivel de peligrosidad del desierto, me retorna falso, ya que por Principio de Universo Cerrado, todo lo que esta en mi base de conocimiento es verdadero y todo aquello que no, es falso