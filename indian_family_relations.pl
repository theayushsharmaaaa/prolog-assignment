% Indian Family Relations Knowledge Base
% Features:
% - 10+ Indian family relations
% - Interactive menu interface
% - Direct relationship queries
% - Path finding between family members
% - Detailed and concise relationship descriptions

% ========== FAMILY MEMBERS ==========
% Males
male(ramesh).
male(suresh).
male(mahesh).
male(dinesh).
male(mukesh).
male(ayush).
male(manan).
male(rahul).
male(vijay).
male(sanjay).
male(ajay).
male(vivek).
male(ashok).
male(prakash).
male(aditya).

% Females
female(sunita).
female(lalita).
female(kavita).
female(savita).
female(anita).
female(priya).
female(sneha).
female(pooja).
female(meena).
female(reena).
female(geeta).
female(seema).
female(radha).
female(shalini).
female(preeti).

% ========== FAMILY STRUCTURE ==========
% Parent relationships
parent(ramesh, mahesh).
parent(ramesh, dinesh).
parent(ramesh, kavita).
parent(sunita, mahesh).
parent(sunita, dinesh).
parent(sunita, kavita).

parent(suresh, mukesh).
parent(suresh, savita).
parent(lalita, mukesh).
parent(lalita, savita).

parent(mahesh, ayush).
parent(mahesh, sneha).
parent(anita, ayush).
parent(anita, sneha).

parent(dinesh, manan).
parent(dinesh, pooja).
parent(priya, manan).
parent(priya, pooja).

parent(mukesh, rahul).
parent(mukesh, meena).
parent(savita, vijay).
parent(savita, reena).

parent(ayush, sanjay).
parent(ayush, geeta).
parent(sneha, ajay).
parent(sneha, seema).

parent(manan, vivek).
parent(manan, radha).
parent(pooja, ashok).
parent(pooja, shalini).

parent(rahul, prakash).
parent(rahul, preeti).
parent(meena, aditya).

% Marriage relationships
married(ramesh, sunita).
married(sunita, ramesh).
married(suresh, lalita).
married(lalita, suresh).
married(mahesh, anita).
married(anita, mahesh).
married(dinesh, priya).
married(priya, dinesh).
married(mukesh, kavita).
married(kavita, mukesh).
married(ayush, pooja).
married(pooja, ayush).
married(manan, meena).
married(meena, manan).
married(rahul, reena).
married(reena, rahul).
married(vijay, sneha).
married(sneha, vijay).
married(sanjay, seema).
married(seema, sanjay).

% ========== RELATION DEFINITIONS ==========
% 1. Father relation
father(X, Y) :- male(X), parent(X, Y).

% 2. Mother relation
mother(X, Y) :- female(X), parent(X, Y).

% 3. Son relation
son(X, Y) :- male(X), parent(Y, X).

% 4. Daughter relation
daughter(X, Y) :- female(X), parent(Y, X).

% Helper relation for siblings
sibling(X, Y) :- parent(P, X), parent(P, Y), X \= Y.

% 5. Brother relation
brother(X, Y) :- male(X), sibling(X, Y).

% 6. Sister relation
sister(X, Y) :- female(X), sibling(X, Y).

% 7. Chacha relation (father's brother)
chacha(X, Y) :- father(F, Y), brother(X, F).

% 8. Chachi relation (father's brother's wife)
chachi(X, Y) :- chacha(C, Y), married(X, C), female(X).

% 9. Bua relation (father's sister)
bua(X, Y) :- father(F, Y), sister(X, F).

% 10. Fufa relation (father's sister's husband)
fufa(X, Y) :- bua(B, Y), married(X, B), male(X).

% 11. Cousin relation
cousin(X, Y) :- parent(P1, X), parent(P2, Y), sibling(P1, P2), X \= Y.

% 12. Dada relation (paternal grandfather)
dada(X, Y) :- father(F, Y), father(X, F).

% 13. Dadi relation (paternal grandmother)
dadi(X, Y) :- father(F, Y), mother(X, F).

% 14. Nana relation (maternal grandfather)
nana(X, Y) :- mother(M, Y), father(X, M).

% 15. Nani relation (maternal grandmother)
nani(X, Y) :- mother(M, Y), mother(X, M).

% 16. Mama relation (mother's brother)
mama(X, Y) :- mother(M, Y), brother(X, M).

% 17. Maami relation (mother's brother's wife)
maami(X, Y) :- mama(M, Y), married(X, M), female(X).

% 18. Mausa relation (mother's sister's husband)
mausa(X, Y) :- mother(M, Y), sister(S, M), married(X, S), male(X).

% 19. Mausi relation (mother's sister)
mausi(X, Y) :- mother(M, Y), sister(X, M).

% 20. Spouse relation
spouse(X, Y) :- married(X, Y).

% ========== LIST OF ALL RELATIONS ==========
all_relations([
    father, mother, son, daughter, brother, sister,
    chacha, chachi, bua, fufa, cousin, dada, dadi,
    nana, nani, mama, maami, mausa, mausi, spouse
]).

% ========== RELATIONSHIP PATH FINDING ==========
% Find the path between two people using BFS
find_path(X, Y, Path) :-
    bfs([[X]], Y, RevPath),
    reverse(RevPath, Path).

% BFS implementation
bfs([[Y|Path]|_], Y, [Y|Path]) :- !.
bfs([Path|Paths], Y, Result) :-
    extend_paths(Path, NewPaths),
    append(Paths, NewPaths, UpdatedPaths),
    bfs(UpdatedPaths, Y, Result).

% Extend a path with all possible next relationships
extend_paths([X|Path], NewPaths) :-
    findall([Z,Relation,X|Path],
            (valid_relation(X, Z, Relation), \+ member(Z, [X|Path])),
            NewPaths).

% Check if a valid relationship exists between two people
valid_relation(X, Z, Relation) :-
    all_relations(Relations),
    member(Relation, Relations),
    RelTerm =.. [Relation, X, Z],
    call(RelTerm).

% ========== RELATIONSHIP DESCRIPTIONS ==========
% Format a path to a chain of relationships
format_chain(Path, Chain) :-
    create_relation_chain(Path, Chain).

% Create a chain of relations from a path
create_relation_chain([_], []).
create_relation_chain([X, Relation, Y | Rest], [rel(X, Y, Relation) | ChainRest]) :-
    create_relation_chain([Y | Rest], ChainRest).

% Describe relationship chain in natural language
describe_chain([]) :- 
    writeln('No relationship found.').
describe_chain([rel(X, Y, Relation)]) :-
    format('~w is the ~w of ~w.~n', [X, Relation, Y]).
describe_chain([rel(X, Y, Relation) | Rest]) :-
    format('~w is the ~w of ~w, who ', [X, Relation, Y]),
    describe_chain_rest(Rest).

% Describe chain with only one entry
describe_chain_rest([rel(_, Y, Relation)]) :-
    format('is the ~w of ~w.~n', [Relation, Y]), !.

% Describe chain with multiple entries
describe_chain_rest([rel(_, Y, Relation)|Rest]) :-
    Rest \= [],
    format('is the ~w of ~w, who ', [Relation, Y]),
    describe_chain_rest(Rest).

% Create a concise relationship description
possessive_description([X], Result) :-
    atom_string(X, Result).

possessive_description([X, Relation, Y], Result) :-
    format(atom(Result), '~w is ~w\'s ~w', [X, Y, Relation]).

possessive_description([X, Relation, Y | Rest], Result) :-
    Rest \= [],
    format_remaining_path([Y | Rest], RemainderStr),
    format(atom(Result), '~w is ~w\'s ~w who is ~w', [X, Y, Relation, RemainderStr]).

% Format remaining path for possessive description
format_remaining_path([X], Result) :-
    atom_string(X, Result).

format_remaining_path([X, Relation, Y], Result) :-
    format(atom(Result), '~w\'s ~w', [Y, Relation]).

format_remaining_path([X, Relation, Y | Rest], Result) :-
    Rest \= [],
    format_remaining_path([Y | Rest], RemainderStr),
    format(atom(Result), '~w\'s ~w who is ~w', [Y, Relation, RemainderStr]).

% Simple possessive form (e.g., "X is Y's father's brother")
simple_possessive([First | Rest], Result) :-
    create_simple_possessive(Rest, First, PossessiveChain),
    format(atom(Result), '~w', [PossessiveChain]).

% Build a simple possessive chain
create_simple_possessive([], Last, Last).
create_simple_possessive([Relation, Next | Rest], First, Result) :-
    create_simple_possessive(Rest, Next, SubResult),
    format(atom(Result), '~w\'s ~w', [SubResult, Relation]).

% ========== QUERY EXECUTION ==========
% Execute a direct query and print results
direct_query(Query) :-
    setof(QueryResult, query_result(Query, QueryResult), UniqueResults),
    maplist(writeln, UniqueResults).
direct_query(Query) :-
    \+ (call(Query)),
    writeln('No results found.').

% Helper to get query results without duplicates
query_result(Query, Formatted) :-
    call(Query),
    Query =.. [Relation, X, Y],
    format(atom(Formatted), '~w is the ~w of ~w', [X, Relation, Y]).

% ========== INTERACTIVE SYSTEM ==========
% Main menu
main_menu :-
    nl,
    writeln('=== Family Knowledge Base System ==='),
    writeln('1. Direct relation query (e.g., chacha(X, sneha))'),
    writeln('2. How are X and Y related?'),
    writeln('3. Exit system'),
    write('Enter your choice (1-3): '),
    read(Choice),
    process_choice(Choice),
    (Choice = 3 -> true ; main_menu).

% Process menu choice
process_choice(1) :-
    writeln('Enter your query (end with a period):'),
    read(Query),
    direct_query(Query).

process_choice(2) :-
    write('Enter first person: '),
    read(Person1),
    write('Enter second person: '),
    read(Person2),
    process_relationship_query(Person1, Person2).

process_choice(3) :-
    writeln('Exiting system. Goodbye!').

process_choice(_) :-
    writeln('Invalid choice. Please try again.').

% Process relationship query between two people
process_relationship_query(X, Y) :-
    (find_path(X, Y, Path) ->
        nl,
        writeln('======== Relationship Found ========'),
        writeln('Detailed relationship:'),
        format_chain(Path, Chain),
        describe_chain(Chain),
        nl,
        writeln('Concise relationship:'),
        possessive_description(Path, Concise),
        writeln(Concise),
        nl,
        writeln('Simple possessive form:'),
        simple_possessive(Path, Simple),
        writeln(Simple),
        nl
    ;
        format('No relationship found between ~w and ~w.~n', [X, Y])
    ).

% Start the system
:- initialization(main_menu).