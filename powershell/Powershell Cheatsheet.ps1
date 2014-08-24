###################################################################################
# Functions. Note that functions in Powershell are commands, not like functions
# in other languages.
function PassArgsSeparately
{
    "Hello $args, how are you?"
}
PassArgsSeparately Phil and Bob


function CountArgs
{
    "`$args = $args"
    "`$args.count = " + $args.count
}
CountArgs a and b and c
CountArgs a,b,c             # Passes 1 argument, an array of strings.


function MultipleAssignment
{
    $x, $y = $args
    $x + $y
}
MultipleAssignment 2 5


function FormalParameters_Subtract($from, $count)
{
    $from - $count
}
FormalParameters_Subtract 10 2
FormalParameters_Subtract -count 3 -from 30
#FormalParameters_Subtract hello world          # Runtime failure


function TypedParameters_Multiply([int] $a, [int] $b)
{
    $a * $b
}

TypedParameters_Multiply 4 6
TypedParameters_Multiply 4 6.3      # Rounds down to 6
TypedParameters_Multiply 4 6.56     # Rounds up to 7
TypedParameters_Multiply 4 "3"      # Automatic coercion
#TypedParameters_Multiply 4 hello    # Failure


function NoOverloading([int] $a, [int] $b)
{
    $a * $b
}
function NoOverloading([int] $a, [int] $b, $c)    # This replaces the first version
{
    $a - $b
}

NoOverloading 5 3


function VariableArgs([int] $a, [int] $b)
{
    "VariableArgs: `$a = $a, `$b = $b, `$args = $args"
}
VariableArgs 1
VariableArgs 1 2
VariableArgs 1 2 3
VariableArgs 1 2 3 4 hello


function DefaultArgumentValues([int] $a = 1, [int] $b = 5)
{
    "DefaultArgumentValues: `$a = $a, `$b = $b, `$args = $args"
}
DefaultArgumentValues
DefaultArgumentValues 50
DefaultArgumentValues 51 52
DefaultArgumentValues 51 52 53
DefaultArgumentValues 51 52 53 54 hello


function DefaultArgumentValues_CanBeExpressions([datetime] $d = $(get-date))
{
    $d.dayofweek
}
DefaultArgumentValues_CanBeExpressions


function Switches_AreOptional([switch] $please)
{
    if ($please)
    {
        "You're welcome"
    } 
    else
    {
        "Don't be rude"
    }
}
Switches -please
Switches


function Booleans_AreMandatoryIfSpecified([bool] $x)
{
    $x
}

Booleans_AreMandatory
#Booleans_AreMandatory -x            # Error
Booleans_AreMandatory -x $true


function Functions_ReturnValuesAsAnArray()
{
    # The result of a function is the result of each expression.
    # They are captured and returned as an array.
    1
    2
    3.14
    999
}
Functions_ReturnValuesAsAnArray
$result = Functions_ReturnValuesAsAnArray
$result.length                      # Prints 4
$result[2]


function Functions_Scalar()
{
    # Except for scalar functions, which return scalar values.
    72
}
$result = Functions_Scalar
$result.length                      # Prints 4
$result


function Functions_BewareOfPhantomReturns()
{
    $al = new-object system.collections.arraylist
    $args | foreach { $al.add($_) }
    $al
}
# Returns 0 1 2 3 because that is the value returned by add(), which is then
# collected into the return array.
Functions_BewareOfPhantomReturns a b c d    


function Functions_BewareOfPhantomReturnsFixed()
{
    $al = new-object system.collections.arraylist
    $args | foreach { [void] $al.add($_) }
    $al
}
# Returns 0 1 2 3 because that is the value returned by add(), which is then
# collected into the return array.
Functions_BewareOfPhantomReturnsFixed a b c d    


function Pipeline_SpecialInputVariable()
{
    # $input is an enumerator over all inputs from the pipeline
    $total = 0
    $input | foreach { $total += $_ }
    $total
}
1..5 | Pipeline_SpecialInputVariable
Pipeline_SpecialInputVariable


# A filter has the same declaration syntax as a function, but uses "filter" instead of "function".
# Function: when used in a pipeline halts streaming - the previous element runs to completion before the function runs ONCE. Uses $input.
# Filter: is run once FOR EACH element in the pipeline. Uses $_ to contain the current pipeline element.
#    >>>> In practice, for "foreach" cmdlet and the process block remove the need for "filter".


function MyCmdlet($x)
{
    begin {
        $c = 0
        "In Begin, c is $c, x is $x"
    }
    process {
        $c++
        "In Process, c is $c, x is $x, `$_ is $_"
    }
    end {
        "In End, c is $c, x is $x"
    }
}
1..5 | MyCmdlet 22
MyCmdlet 22              # Runs the Process block once.



###################################################################################
# Scripts
# To run a script from the command line
# (good) because it inteprets "C:\my scripts\script.ps1" as the command
#   powershell.exe File "C:\my scripts\script.ps1" data.csv

# or (bad, because it interprets "C:\my" as the command and everyting else as arguments.
#   powershell.exe Command "C:\my scripts\script.ps1" data.csv           # gives 2 args, splut at "C:\my"


###################################################################################
# Advanced functions


function AllParameterMetaData()
{
    # Help is only displayed when the shell is prompting for missing parameter
    # values, so it isn't very useful.
    param(
        # All possible values.
        [Parameter(Mandatory=$true,
        Position=0,
        ParameterSetName="set1",
        ValueFromPipeline=$false,
        ValueFromPipelineByPropertyName=$true,
        ValueFromRemainingArguments=$false,
        HelpMessage="some help this is")]
        [int]
        $p1 = 0
    )    
    begin {
    }
    process {
    }
    end {
    }
}


function TypicalParameterMetaData()
{
    param(
        [Parameter(Position = 0, Mandatory = $true)][int] $p1,
        [Parameter(Position = 1, Mandatory = $true)][int] $p2,
        [Parameter(Position = 2, Mandatory = $true)][int] $p3
    )
}


function ValueFromPipelineOrParam()
{
    param(
        [Parameter(ValueFromPipeline = $true)] $x
    )
    process {
        $x
    }
}
ValueFromPipelineOrParam 123
123, 12 | ValueFromPipelineOrParam


function ValueFromPipelineByPropertyName()
{
    param(
        # Instead of binding the entire object in the pipeline, just bind 1 property (called DayOfWeek)
        [Parameter(ValueFromPipelineByPropertyName=$true)] $DayOfWeek
    )
    process {
        $DayOfWeek
    }
}
Get-Date | ValueFromPipelineByPropertyName
ValueFromPipelineByPropertyName (Get-Date)    # But this still binds the entire date object
ValueFromPipelineByPropertyName ((Get-Date).DayOfWeek)    # So you have to extract it yourself


