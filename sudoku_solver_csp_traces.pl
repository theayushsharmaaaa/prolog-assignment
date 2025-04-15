/***************************************
 *   Sudoku CSP Solver with Tracing   *
 ***************************************/

/**********************
 * Utility Predicates *
 **********************/

% remove_first/3 (+Element, +List, -ResultList)
% Removes the first occurrence of Element from List
remove_first(Element, [Element|Rest], Rest) :- !.
remove_first(Element, [H|T], [H|Result]) :- remove_first(Element, T, Result).
remove_first(_, [], []).

% filter_domain/3 (+Variables, +Domain, -FilteredDomain)
% Removes assigned values from domain
filter_domain([], Domain, Domain) :- !.
filter_domain([Var|Vars], Domain, Filtered) :-
    nonvar(Var), !,
    remove_first(Var, Domain, TempDomain),
    filter_domain(Vars, TempDomain, Filtered).
filter_domain([Var|Vars], Domain, Filtered) :-
    var(Var),
    filter_domain(Vars, Domain, Filtered).

/**************************
 * Sudoku Grid Operations *
 **************************/

% extract_column/3 (+Matrix, -Column, -RestMatrix)
% Extract first column from matrix
extract_column([], [], []).
extract_column([[First|RowRest]|Rows], [First|ColRest], [RowRest|MatrixRest]) :-
    extract_column(Rows, ColRest, MatrixRest).

% transpose_matrix/2 (+RowMatrix, -ColumnMatrix)
% Convert rows to columns
transpose_matrix([[]|_], []) :- !.
transpose_matrix(Matrix, [Col|Cols]) :-
    extract_column(Matrix, Col, RestMatrix),
    transpose_matrix(RestMatrix, Cols).

% extract_block/6 (+Grid, +BlockWidth, +BlockHeight, +Buffer, -Block, -RemainingGrid)
% Extract a block from the grid
extract_block([], _, _, Buffer, [Buffer], []) :- 
    Buffer \= [], !.
extract_block([], _, _, [], [], []) :- !.

extract_block(Grid, Width, Height, Buffer, [Buffer|Blocks], RemainRows) :-
    BlockSize is Width * Height,
    length(Buffer, BlockSize), !,
    extract_block(Grid, Width, Height, [], Blocks, RemainRows).

extract_block([Row|Rows], Width, Height, CurrentBuffer, Blocks, [RemainingRow|RemainingRows]) :-
    length(BlockSlice, Width),
    append(BlockSlice, RemainingRow, Row),
    append(CurrentBuffer, BlockSlice, NewBuffer),
    extract_block(Rows, Width, Height, NewBuffer, Blocks, RemainingRows).

% get_all_blocks/4 (+Grid, +BlockWidth, +BlockHeight, -AllBlocks)
% Extract all blocks from grid
get_all_blocks([], _, _, []) :- !.
get_all_blocks([[]|_], _, _, []) :- !.

get_all_blocks(Grid, Width, Height, AllBlocks) :-
    extract_block(Grid, Width, Height, [], BlockStack, RemainingGrid),
    get_all_blocks(RemainingGrid, Width, Height, OtherBlocks),
    append(BlockStack, OtherBlocks, AllBlocks).

% validate_grid/3 (+Grid, +BlockWidth, +BlockHeight)
% Validate grid dimensions
validate_grid(Grid, BlockWidth, BlockHeight) :-
    length(Grid, Size),
    maplist(length_check(Size), Grid),
    0 =:= Size mod BlockHeight,
    0 =:= Size mod BlockWidth,
    Size =:= BlockWidth * BlockHeight.

length_check(Len, List) :- length(List, Len).

% get_constraints/4 (+BlockHeight, +BlockWidth, +Grid, -Constraints)
% Get all constraint groups (rows, columns, blocks)
get_constraints(BlockHeight, BlockWidth, Grid, Constraints) :-
    validate_grid(Grid, BlockWidth, BlockHeight),
    transpose_matrix(Grid, Columns),
    get_all_blocks(Grid, BlockWidth, BlockHeight, Blocks),
    append(Grid, Columns, RowsAndCols),
    append(RowsAndCols, Blocks, Constraints).

/****************************
 * Constraint Satisfaction  *
 ****************************/

% all_different/1 (+List)
% Ensures all elements in List are different
all_different([]).
all_different([X|Xs]) :- 
    maplist(dif(X), Xs), 
    all_different(Xs).

% check_constraints/1 (+ConstraintGroups)
% Check if all constraint groups satisfy all-different
check_constraints([]).
check_constraints([Group|Groups]) :-
    all_different(Group),
    check_constraints(Groups).

/**********************
 * Tracing Facilities *
 **********************/

% initialize_trace/1 (-Trace)
% Create empty trace
initialize_trace([]).

% add_trace_event/3 (+TraceIn, +Event, -TraceOut)
% Add event to trace
add_trace_event(TraceIn, Event, [Event|TraceIn]).

% trace_assignment/3 (+Value, +TraceIn, -TraceOut)
% Record variable assignment
trace_assignment(Value, TraceIn, TraceOut) :-
    format(atom(Event), 'Assigned value ~w to variable', [Value]),
    add_trace_event(TraceIn, Event, TraceOut).

% trace_domain_reduction/4 (+Original, +Reduced, +TraceIn, -TraceOut) 
% Record domain reduction
trace_domain_reduction(Original, Reduced, TraceIn, TraceOut) :-
    format(atom(Event), 'Domain reduced from ~w to ~w', [Original, Reduced]),
    add_trace_event(TraceIn, Event, TraceOut).

% trace_constraint_check/4 (+Type, +Group, +TraceIn, -TraceOut)
% Record constraint check
trace_constraint_check(Type, Group, TraceIn, TraceOut) :-
    format(atom(Event), 'Applying ~w constraint to group: ~w', [Type, Group]),
    add_trace_event(TraceIn, Event, TraceOut).

% trace_current_state/3 (+Variables, +TraceIn, -TraceOut)
% Record current state
trace_current_state(Variables, TraceIn, TraceOut) :-
    format(atom(Event), 'Current state of variables: ~w', [Variables]),
    add_trace_event(TraceIn, Event, TraceOut).

/*************************
 * CSP Solving with Trace *
 *************************/

% solve_group_with_trace/5 (+Group, +Domain, +AllConstraints, +TraceIn, -TraceOut)
% Solve a single constraint group with tracing
solve_group_with_trace([], _, _, Trace, Trace) :- !.

solve_group_with_trace([Var|Vars], Domain, Constraints, TraceIn, TraceOut) :-
    nonvar(Var), !,
    solve_group_with_trace(Vars, Domain, Constraints, TraceIn, TraceOut).

solve_group_with_trace([Var|Vars], Domain, Constraints, TraceIn, TraceOut) :-
    var(Var),
    member(Value, Domain),
    Var = Value,
    
    % Record assignment in trace
    trace_assignment(Value, TraceIn, TraceNext),
    
    % Check if constraints still valid
    check_constraints(Constraints),
    
    % Remove value from domain for remaining variables
    select(Value, Domain, NewDomain),
    solve_group_with_trace(Vars, NewDomain, Constraints, TraceNext, TraceOut).

% solve_sudoku_trace/5 (+Constraints, +Domain, +Grid, +TraceIn, -TraceOut)
% Main CSP solving predicate with tracing
solve_sudoku_trace([], _, _, Trace, Trace).
solve_sudoku_trace([Group|Groups], Domain, Grid, TraceIn, TraceOut) :-
    % Record which constraint group we're working on
    (Group = [_|_],
     length(Group, Len),
     format(atom(GroupType), 'Group of ~w cells', [Len])),
    trace_constraint_check(GroupType, Group, TraceIn, TraceNext1),
    
    % Record current state
    trace_current_state(Group, TraceNext1, TraceNext2),
    
    % Filter domain based on assigned values
    filter_domain(Group, Domain, FilteredDomain),
    trace_domain_reduction(Domain, FilteredDomain, TraceNext2, TraceNext3),
    
    % Solve this group
    solve_group_with_trace(Group, FilteredDomain, [Group|Groups], TraceNext3, TraceNext4),
    
    % Continue with remaining groups
    solve_sudoku_trace(Groups, Domain, Grid, TraceNext4, TraceOut).

/*******************
 * Simple Printing *
 *******************/

% print_cell/1 (+Cell)
% Print a single cell
print_cell(Cell) :-
    (var(Cell) -> write('_') ; write(Cell)).

% print_row/1 (+Row)
% Print a row of cells
print_row([]) :- nl.
print_row([Cell|Rest]) :-
    print_cell(Cell),
    write(' '),
    print_row(Rest).

% print_grid/1 (+Grid)
% Print an entire grid
print_grid([]).
print_grid([Row|Rows]) :-
    print_row(Row),
    print_grid(Rows).

% print_grid_with_blocks/3 (+Grid, +BlockWidth, +BlockHeight)
% Print grid with block formatting
print_grid_with_blocks(Grid, BlockWidth, BlockHeight) :-
    write('Grid with blocks ('), write(BlockWidth), write('x'), write(BlockHeight), write('):'), nl,
    print_grid(Grid).

% display_trace/1 (+Trace)
% Display trace in chronological order with numbered steps
display_trace(Trace) :-
    reverse(Trace, ChronologicalTrace),
    display_trace_entries(ChronologicalTrace, 1).

% display_trace_entries/2 (+Trace, +StepNumber)
% Display each trace entry with step number
display_trace_entries([], _).
display_trace_entries([Entry|Rest], Number) :-
    format('~w. ~w~n', [Number, Entry]),
    NextNumber is Number + 1,
    display_trace_entries(Rest, NextNumber).

/*********************
 * Public Predicates *
 *********************/

% solve_sudoku/3 (+BlockHeight, +BlockWidth, +Grid)
% Solve sudoku without trace (for compatibility)
solve_sudoku(BlockHeight, BlockWidth, Grid) :-
    get_constraints(BlockHeight, BlockWidth, Grid, Constraints),
    Size is BlockHeight * BlockWidth,
    numlist(1, Size, Domain),
    solve_sudoku_no_trace(Constraints, Domain),
    writeln('Solution:'),
    print_grid(Grid).

% solve_sudoku_no_trace/2 (+Constraints, +Domain)
% Original solver without tracing
solve_sudoku_no_trace([], _).
solve_sudoku_no_trace([Group|Groups], Domain) :-
    filter_domain(Group, Domain, FilteredDomain),
    solve_group_no_trace(Group, FilteredDomain, [Group|Groups]),
    solve_sudoku_no_trace(Groups, Domain).

% solve_group_no_trace/3 (+Group, +Domain, +Constraints)
% Solve a group without tracing
solve_group_no_trace([], _, _).
solve_group_no_trace([Var|Vars], Domain, Constraints) :-
    nonvar(Var), !,
    solve_group_no_trace(Vars, Domain, Constraints).
solve_group_no_trace([Var|Vars], Domain, Constraints) :-
    member(Value, Domain),
    Var = Value,
    check_constraints(Constraints),
    select(Value, Domain, NewDomain),
    solve_group_no_trace(Vars, NewDomain, Constraints).

% solve_sudoku_with_trace/4 (+BlockHeight, +BlockWidth, +Grid, -Trace)
% Solve sudoku and return trace
solve_sudoku_with_trace(BlockHeight, BlockWidth, Grid, Trace) :-
    get_constraints(BlockHeight, BlockWidth, Grid, Constraints),
    Size is BlockHeight * BlockWidth,
    numlist(1, Size, Domain),
    initialize_trace(InitialTrace),
    solve_sudoku_trace(Constraints, Domain, Grid, InitialTrace, Trace).

% run_sudoku_with_trace/3 (+BlockHeight, +BlockWidth, +Grid)
% Main entry point to solve a sudoku with trace and simplified formatting
run_sudoku_with_trace(BlockHeight, BlockWidth, Grid) :-
    writeln('Initial Sudoku puzzle:'),
    print_grid_with_blocks(Grid, BlockWidth, BlockHeight),
    writeln('Solving with CSP and generating trace...'),
    solve_sudoku_with_trace(BlockHeight, BlockWidth, Grid, Trace),
    writeln('Solution:'),
    print_grid_with_blocks(Grid, BlockWidth, BlockHeight),
    writeln('Trace of constraint propagation:'),
    display_trace(Trace).

% run_sudoku_formatted/3 (+BlockHeight, +BlockWidth, +Grid)
% Run solver and suppress raw variable output at the end
run_sudoku_formatted(BlockHeight, BlockWidth, Grid) :-
    run_sudoku_with_trace(BlockHeight, BlockWidth, Grid),
    writeln('Puzzle solved successfully.').

/* Example puzzle (9x9 Sudoku) */
example_puzzle([
    [5,3,_,_,7,_,_,_,_],
    [6,_,_,1,9,5,_,_,_],
    [_,9,8,_,_,_,_,6,_],
    [8,_,_,_,6,_,_,_,3],
    [4,_,_,8,_,3,_,_,1],
    [7,_,_,_,2,_,_,_,6],
    [_,6,_,_,_,_,2,8,_],
    [_,_,_,4,1,9,_,_,5],
    [_,_,_,_,8,_,_,7,9]
]).

/* Other example (4x4 Sudoku) */
example_small([
    [_,_,3,4],
    [3,4,_,_],
    [_,3,4,_],
    [4,_,_,3]
]).

/* Usage examples:
   ?- example_puzzle(Puzzle), run_sudoku_with_trace(3, 3, Puzzle).
   ?- example_small(Small), run_sudoku_with_trace(2, 2, Small).
   ?- example_puzzle(Puzzle), run_sudoku_formatted(3, 3, Puzzle).
*/