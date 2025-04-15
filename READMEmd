# Assignment 1

# Indian Family Relations Knowledge Base

## Introduction

The Indian Family Relations Knowledge Base is a Prolog implementation that models traditional Indian family relationships. This system allows users to define family structures and then query both direct relationships and discover how two family members are connected through relationship paths. The system especially focuses on Indian kinship terms like chacha, chachi, bua, fufa, etc., providing culturally specific relationship modeling.

## Features

- **Comprehensive Relation Set**: Defines 10+ culturally specific Indian family relations:
  - father, mother, son, daughter
  - chacha (paternal uncle), chachi (paternal uncle's wife)
  - bua (paternal aunt), fufa (paternal aunt's husband)
  - cousin, dada (paternal grandfather), dadi (paternal grandmother)
  - mama (maternal uncle), maami (maternal uncle's wife)
  - and more

- **Interactive Interface**: Menu-driven system with options for:
  - Executing direct relationship queries
  - Finding relationships between any two people
  - Exiting the system

- **Relationship Path Finding**: Uses breadth-first search to find the shortest relationship path between any two family members.

- **Natural Language Descriptions**: Provides multiple formats for describing relationships:
  - Detailed step-by-step relationship chains
  - Concise relationship descriptions
  - Simple possessive forms (e.g., "X is Y's father's brother")

## Requirements

- SWI-Prolog (version 8.0 or later recommended)

## Usage

### Running the System

1. Start SWI-Prolog
2. Load the knowledge base:
   ```
   ?- [indian_family_relations].
   ```
3. The interactive menu will start automatically.

### Using the Interactive Menu

The system provides a menu with the following options:

1. **Direct relation query**
   - Enter a query like `father(ramesh, X).` to find all children of ramesh
   - Example: `chacha(X, sneha).` to find who is sneha's chacha (paternal uncle)

2. **How are X and Y related?**
   - Enter two people's names to find how they're related
   - The system will show both detailed and concise relationship descriptions

3. **Exit system**
   - Exit the program

### Example Queries

#### Direct Relation Query
```
?- father(ramesh, X).
ramesh is the father of mahesh
ramesh is the father of dinesh
ramesh is the father of kavita
```

#### Relationship Path Query
```
Enter first person: ramesh
Enter second person: sanjay

======== Relationship Found ========
Detailed relationship:
ramesh is the dada of ayush, who is the father of sanjay.

Concise relationship:
ramesh is ayush's dada who is sanjay's father

Simple possessive form:
sanjay's father's dada
```

## Family Structure

The knowledge base includes a sample family with members like:
- ramesh, sunita (married couple)
- mahesh, dinesh, kavita (their children)
- ayush, sneha (mahesh's children)
- manan, pooja (dinesh's children)
- and many more extending to multiple generations

## Technical Implementation

The system is built on four primitive relations:
1. `male/1`: Defines a person as male
2. `female/1`: Defines a person as female
3. `parent/2`: Defines parent-child relationships
4. `married/2`: Defines marriages between individuals

From these primitives, derived relations like father, mother, chacha, etc. are defined using logical rules. The system uses breadth-first search to find the shortest path between family members and provides multiple ways to format and describe these relationships.

## Extending the System

### Adding Family Members

1. Add gender facts:
   ```prolog
   male(new_person).
   female(new_person).
   ```

2. Add parent relationships:
   ```prolog
   parent(parent_name, child_name).
   ```

3. Add marriage relationships:
   ```prolog
   married(person1, person2).
   married(person2, person1).  % Both directions are required
   ```

## Background

This system was developed as an assignment for the Knowledge Representation and Reasoning course. It demonstrates how logical programming can model and query complex family relationships, with a focus on culturally specific Indian kinship terms.


# Assignment 2

# Sudoku CSP Solver with Tracing

This is a Prolog implementation of a Sudoku solver using Constraint Satisfaction Problem (CSP) techniques with detailed trace capabilities. The solver can handle Sudoku puzzles of different sizes, not just the standard 9×9 grid.

## Overview

This program uses constraint satisfaction techniques to solve Sudoku puzzles. It:

1. Represents the puzzle as a CSP where each cell is a variable
2. Applies the "all-different" constraint to rows, columns, and blocks
3. Uses a backtracking algorithm with constraint propagation to find a solution
4. Provides detailed tracing of the solving process

## How It Works

### CSP Representation

- **Variables**: Each cell in the Sudoku grid is a variable
- **Domain**: Each variable's domain consists of possible values (1 to N for an N×N grid)
- **Constraints**: All cells in each row, column, and block must have different values

### Solving Algorithm

The program uses a systematic backtracking search with constraint propagation:

1. **Constraint Setup**: Identifies all constraint groups (rows, columns, blocks)
2. **Domain Filtering**: Filters the domain of unassigned variables based on already assigned values
3. **Variable Assignment**: Assigns a value to an unassigned variable from its filtered domain
4. **Constraint Checking**: Ensures the assignment doesn't violate any constraints
5. **Backtracking**: If a constraint is violated, it backtracks and tries a different value

### Tracing

The program includes comprehensive tracing capabilities that record:
- Variable assignments
- Domain reductions
- Constraint checking
- Current state of variables

## Features

- Solves Sudoku puzzles of any size (not just 9×9)
- Provides detailed solving trace for educational purposes
- Validates grid dimensions automatically
- Includes example puzzles (9×9 and 4×4)

## How to Run

### Prerequisites

- SWI-Prolog installed on your system

### Running the Program

1. Load the program in SWI-Prolog:
   ```
   $ swipl sudoku_solver.pl
   ```

2. Solve the built-in 9×9 example puzzle:
   ```prolog
   ?- example_puzzle(Puzzle), run_sudoku_with_trace(3, 3, Puzzle).
   ```

3. Solve the built-in 4×4 example puzzle:
   ```prolog
   ?- example_small(Small), run_sudoku_with_trace(2, 2, Small).
   ```

### Solving Your Own Puzzles

To solve a custom Sudoku puzzle:

1. Define your puzzle grid with variables (use underscore `_` for empty cells):
   ```prolog
   ?- Grid = [
      [5,3,_,_,7,_,_,_,_],
      [6,_,_,1,9,5,_,_,_],
      [_,9,8,_,_,_,_,6,_],
      [8,_,_,_,6,_,_,_,3],
      [4,_,_,8,_,3,_,_,1],
      [7,_,_,_,2,_,_,_,6],
      [_,6,_,_,_,_,2,8,_],
      [_,_,_,4,1,9,_,_,5],
      [_,_,_,_,8,_,_,7,9]
   ].
   ```

2. Run the solver with appropriate block dimensions:
   ```prolog
   ?- run_sudoku_with_trace(3, 3, Grid).
   ```

   For a 9×9 puzzle, the block dimensions are 3×3 (BlockHeight = 3, BlockWidth = 3).
   For a 4×4 puzzle, the block dimensions are 2×2 (BlockHeight = 2, BlockWidth = 2).

## Understanding the Output

The program will display:

1. The initial puzzle
2. The solution
3. A step-by-step trace of the solving process

Example trace output:
```
1. Applying Group of 9 cells constraint to group: [...]
2. Current state of variables: [...]
3. Domain reduced from [1,2,3,4,5,6,7,8,9] to [2,4,6,8,9]
4. Assigned value 2 to variable
...
```

## Advanced Usage

### Different Formatting Options

The program offers different formatting options:

- `run_sudoku_with_trace/3`: Shows full trace information
- `run_sudoku_formatted/3`: Shows solution with minimal output
- `solve_sudoku/3`: Solves puzzle without trace information

### Definition Parameters

When running the solver:
- First parameter: BlockHeight (number of rows in each block)
- Second parameter: BlockWidth (number of columns in each block)
- Third parameter: The Sudoku grid

For example, for a 6×6 puzzle with 2×3 blocks:
```prolog
?- run_sudoku_with_trace(2, 3, Grid).
```

## Implementation Details

### Key Predicates

- `get_constraints/4`: Extracts all constraints from the grid
- `solve_sudoku_trace/5`: Main solving predicate with tracing
- `solve_group_with_trace/5`: Solves an individual constraint group
- `check_constraints/1`: Ensures all constraints are satisfied
- `print_grid/1`: Displays the grid

### Limitations

- Complex puzzles may take time to solve due to the backtracking nature
- Trace output can be lengthy for larger puzzles

## Conclusion

This Sudoku solver demonstrates the power of constraint satisfaction techniques in Prolog for solving complex puzzles. The tracing capability provides educational insight into how the constraint propagation and backtracking algorithm works.