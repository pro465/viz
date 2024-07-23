USING: accessors arrays calendar colors kernel math
math.constants math.functions math.parser math.primes.erato.fast
math.vectors opengl processing.shapes sequences timers ui
ui.gadgets ui.gadgets.cartesian ;
IN: digits-viz


TUPLE: turtle pdown direction position lines ;

: <turtle> ( -- turtle )
    t pi 2 / { 0.0 0.0 } clone V{ } clone turtle boa ;

<PRIVATE
: line ( turtle a b -- turtle )
    pick pdown>> [
        2array '[ _ suffix! ] change-lines
    ] [ 2drop ] if ; inline
PRIVATE>

: fwd ( turtle steps -- turtle )
    over direction>> [ cos * ] [ sin * ] 2bi 2array
    over position>> [ v+ ] keep [ line ] keepd >>position ;

: trn ( turtle rads -- turtle )
    ! over direction>> + >>direction ; inline
    >>direction ; inline

: pdn ( turtle -- turtle ) t >>pdown ; inline
: pup ( turtle -- turtle ) f >>pdown ; inline

CONSTANT: base 10
CONSTANT: zoom-factor 1.1
CONSTANT: trans-amt 10

TUPLE: digits-viz < cartesian turtle digits scale timer ;

M: digits-viz graft*
    [ timer>> start-timer ] [ call-next-method ] bi ;

M: digits-viz ungraft*
    [ timer>> stop-timer ] [ call-next-method ] bi ;

: init-digits ( -- digits )
    1000000 sieve V{ } [ base >base-digits append! ] reduce ;

: next-line ( digits-viz -- )
    dup digits>> [ relayout-1 ] [
        unclip-slice [ >>digits ] dip
        over turtle>> swap
        base / pi 2 * * trn 10 fwd 2drop
    ] if-empty ;

: update-range ( digits-viz -- digits-viz )
    dup dim>> [ [ -1 * ] keep 2array over scale>> 2 / v*n ] map
    first2 [ x-range ] dip y-range ;

: draw-digits ( digits-viz -- )
    COLOR: black gl-color
    turtle>> lines>> [ first2 draw-line* ] each ;

: <digits-viz> ( -- gadget )
    digits-viz new init-cartesian
        { 800 800 } >>pdim
        <turtle> >>turtle
        init-digits >>digits
        1.0 >>scale
        dup '[ _ next-line ] f 1 nanoseconds <timer> >>timer
        dup '[ COLOR: white gl-clear _ update-range draw-digits ] >>action ;

:: zoom ( digits-viz! factor -- )
    digits-viz factor over scale>> * >>scale digits-viz! ;

:: trans ( digits-viz! amt -- )
    digits-viz amt over scale>> trans-amt * v*n 
    over [ turtle>> position>> v+ ] keep turtle>> swap >>position >>turtle digits-viz! ;

digits-viz H{
    { T{ key-down f f "o" }       [ zoom-factor zoom ] }
    { T{ key-down f f "i" }       [ 1 zoom-factor / zoom ] }
    { T{ key-down f f "UP" }      [ { 0 -1 } trans ] }
    { T{ key-down f f "DOWN" }    [ { 0 1 } trans ] }
    { T{ key-down f f "LEFT" }    [ { -1 0 } trans ] }
    { T{ key-down f f "RIGHT" }   [ { 1 0 } trans ] }
} set-gestures

MAIN-WINDOW: digits-viz-window
    { { title "Digits Visualization" } }
    <digits-viz> >>gadgets ;

MAIN: digits-viz-window
