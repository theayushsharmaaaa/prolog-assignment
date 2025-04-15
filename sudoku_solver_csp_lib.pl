% Sudoku Solver using Knowledge Representation and Reasoning
% This program solves Sudoku puzzles using constraint logic programming

% Load the clpfd library for finite domain constraints
:- use_module(library(clpfd)).

% Main predicate to solve a Sudoku puzzle
sudoku(Puzzle, Solution) :-
    % Ensure puzzle is valid
    length(Puzzle, 9),
    maplist(same_length(Puzzle), Puzzle),
    
    % Convert puzzle to a flat list for easier processing
    append(Puzzle, Vars),
    
    % Set domain for all variables to be between 1 and 9
    Vars ins 1..9,
    
    % Apply constraints to rows
    maplist(all_distinct, Puzzle),
    
    % Apply constraints to columns
    transpose(Puzzle, Columns),
    maplist(all_distinct, Columns),
    
    % Apply constraints to 3x3 blocks
    blocks(Puzzle, Blocks),
    maplist(all_distinct, Blocks),
    
    % Set Solution to Puzzle (they reference the same variables)
    Solution = Puzzle,
    
    % Print inference steps
    print_inference_steps(Puzzle),
    
    % Find a solution with minimum backtracking
    maplist(label, Puzzle).

% Helper predicate to extract the 3x3 blocks from the puzzle
blocks(Puzzle, Blocks) :-
    Blocks = [Block1, Block2, Block3, Block4, Block5, Block6, Block7, Block8, Block9],
    block(Puzzle, 0, 0, Block1),
    block(Puzzle, 0, 3, Block2),
    block(Puzzle, 0, 6, Block3),
    block(Puzzle, 3, 0, Block4),
    block(Puzzle, 3, 3, Block5),
    block(Puzzle, 3, 6, Block6),
    block(Puzzle, 6, 0, Block7),
    block(Puzzle, 6, 3, Block8),
    block(Puzzle, 6, 6, Block9).

% Helper predicate to extract a 3x3 block starting at (StartRow, StartCol)
block(Puzzle, StartRow, StartCol, Block) :-
    Block = [A, B, C, D, E, F, G, H, I],
    Row1 is StartRow,
    Row2 is StartRow + 1,
    Row3 is StartRow + 2,
    Col1 is StartCol,
    Col2 is StartCol + 1,
    Col3 is StartCol + 2,
    nth0(Row1, Puzzle, Row1List), nth0(Col1, Row1List, A),
    nth0(Row1, Puzzle, Row1List), nth0(Col2, Row1List, B),
    nth0(Row1, Puzzle, Row1List), nth0(Col3, Row1List, C),
    nth0(Row2, Puzzle, Row2List), nth0(Col1, Row2List, D),
    nth0(Row2, Puzzle, Row2List), nth0(Col2, Row2List, E),
    nth0(Row2, Puzzle, Row2List), nth0(Col3, Row2List, F),
    nth0(Row3, Puzzle, Row3List), nth0(Col1, Row3List, G),
    nth0(Row3, Puzzle, Row3List), nth0(Col2, Row3List, H),
    nth0(Row3, Puzzle, Row3List), nth0(Col3, Row3List, I).

% Print the current state of the puzzle
print_puzzle(Puzzle) :-
    format('~n+---------+---------+---------+~n', []),
    print_rows(Puzzle, 0).

print_rows([], _).
print_rows([Row|Rows], RowNum) :-
    print_row(Row, 0, RowNum),
    NextRowNum is RowNum + 1,
    print_rows(Rows, NextRowNum).

print_row([], _, _) :-
    format('|~n', []).
print_row([Cell|Rest], ColNum, RowNum) :-
    (ColNum mod 3 =:= 0 -> format('| ', []) ; true),
    (var(Cell) -> format('. ', []) ; format('~d ', [Cell])),
    NextColNum is ColNum + 1,
    print_row(Rest, NextColNum, RowNum).

% Custom trace for inference steps
print_inference_steps(Puzzle) :-
    format('~nConstraint Propagation Steps:~n', []),
    format('1. Setting domains of all cells to 1-9~n', []),
    format('2. Enforcing all_distinct constraint on rows~n', []),
    format('3. Enforcing all_distinct constraint on columns~n', []),
    format('4. Enforcing all_distinct constraint on 3x3 blocks~n', []),
    identify_possible_values(Puzzle, 1).

% Identify possible values for cells based on constraints
identify_possible_values(Puzzle, RowNum) :-
    RowNum =< 9,
    nth1(RowNum, Puzzle, Row),
    identify_possible_values_row(Row, 1, RowNum),
    NextRowNum is RowNum + 1,
    identify_possible_values(Puzzle, NextRowNum).
identify_possible_values(_, RowNum) :- RowNum > 9.

identify_possible_values_row([], _, _).
identify_possible_values_row([Cell|Rest], ColNum, RowNum) :-
    (var(Cell) ->
        % For unbound variables, check their domain
        (fd_dom(Cell, Dom),
         fd_size(Dom, Size),
         (Size =:= 1 ->
             % This is a naked single
             fd_dom(Cell, Dom),
             dom_min(Dom, Value),
             format('   - Cell (~d,~d) must be ~d (Naked Single)~n', [RowNum, ColNum, Value])
         ;
             % Multiple possibilities
             fd_dom(Cell, Dom),
             format('   - Cell (~d,~d) has ~d possible values~n', [RowNum, ColNum, Size])
         ))
    ;
        % For already bound cells (initial values)
        format('   - Cell (~d,~d) is initially set to ~d~n', [RowNum, ColNum, Cell])
    ),
    NextColNum is ColNum + 1,
    identify_possible_values_row(Rest, NextColNum, RowNum).

% Main predicate for solving and displaying results
solve_sudoku(Puzzle) :-
    format('~nInitial Puzzle:~n', []),
    print_puzzle(Puzzle),
    
    format('~nSolving...~n', []),
    
    % Solve with time measurement
    statistics(runtime, [Start|_]),
    sudoku(Puzzle, Solution),
    statistics(runtime, [End|_]),
    Time is End - Start,
    
    format('~nSolved Puzzle:~n', []),
    print_puzzle(Solution),
    format('~nSolved in ~d ms~n', [Time]).

% Example usage with the puzzle from the assignment
:- initialization(main).

main :-
    Puzzle = [
    [_,_,_,_,_,_,_,_,_],
    [_,_,_,_,_,3,_,8,5],
    [_,_,1,_,2,_,_,_,_],
    [_,_,_,5,_,7,_,_,_],
    [_,_,4,_,_,_,1,_,_],
    [_,9,_,_,_,_,_,_,_],
    [5,_,_,_,_,_,_,7,3],
    [_,_,2,_,1,_,_,_,_],
    [_,_,_,_,4,_,_,_,9]
    ],
    solve_sudoku(Puzzle).

% Query to run:
% ?- main.