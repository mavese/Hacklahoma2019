+
[
    >+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >++++++++++++++++++++++++++++++++
    >+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >++++++++++++++++++++++++++++++++
    >+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >++++++++++++++++++++++++++++++++
    >+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    >++++++++++++++++++++++++++++++++++++++++++++++++++++++++++<<<<<<<<<<<<<<<<<<<<-
]
>
[.>]
<
[[-]<]              Reset the tape to all 0s

>+                  intializes the tape to 0 1
[                   while the current cell is not 0
    ,               read the char from stdin
    [>+>+<<-]       cut the current cell to the two cells to the right
    >>              move two cells over
    [<<+>>-]        cut this cell to the position of the original cell that was cut
    ++++ ++++ ++    set the current cell which was just cleared to 10 which is the ascii for carrraige return
    [<->-]          decrement the carriage return counter and the most recent input cell
    <               move to the copied input item and if is zero exit the loop
]                   check if the current cell is zero which only happens if the character is a carriage return
<                   move off the zero cell back to the actual string
---- ---- --
[<]                 move to the original 0
>

@
<
[[-]<]              Reset the tape to all 0s

>+
[
    [                   while the current cell is not 0
        ,               read the char from stdin
        [>+>+<<-]       cut the current cell to the two cells to the right
        >>              move two cells over
        [<<+>>-]        cut this cell to the position of the original cell that was cut
        ++++ ++++ ++    set the current cell which was just cleared to 10 which is the ascii for carrraige return
        [<->-]          decrement the carriage return counter and the most recent input cell
        <               move to the copied input item and if is zero exit the loop
    ]                   check if the current cell is zero which only happens if the character is a carriage return
    [<]                 back up to cell 0
    >
    [*>]                write char to socket
    [[-]<]              Reset the tape to all 0s
    >+
]