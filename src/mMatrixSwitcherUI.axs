MODULE_NAME='mMatrixSwitcherUI'     (
                                        dev dvTP,
                                        dev vdvObject,
                                        dev dvDevice[]
                                    )

(***********************************************************)
#include 'NAVFoundation.ModuleBase.axi'
#include 'NAVFoundation.UIUtils.axi'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

constant integer MAX_IO = 16

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile integer iSelectedSwitchType
volatile integer iSelectedInput

volatile integer iOutput[2][MAX_IO]

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)



(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT
timeline_event[TL_NAV_FEEDBACK] {
    [dvTP, 201] = (iSelectedSwitchType == NAV_SWITCH_LEVEL_VID)
    [dvTP, 202] = (iSelectedSwitchType == NAV_SWITCH_LEVEL_AUD)

    if (1) {
    stack_var integer x
    for (x = 1; x <= MAX_IO; x++) {
        [dvTP, x] = (iSelectedInput == x)
        [dvTP, x + 20] = (iSelectedInput && (iOutput[iSelectedSwitchType][x] = iSelectedInput));
    }
    }
}

button_event[dvTP, 1]
button_event[dvTP, 2]
button_event[dvTP, 3]
button_event[dvTP, 4]
button_event[dvTP, 5]
button_event[dvTP, 6]
button_event[dvTP, 7]
button_event[dvTP, 8]
button_event[dvTP, 9]
button_event[dvTP, 10]
button_event[dvTP, 11]
button_event[dvTP, 12]
button_event[dvTP, 13]
button_event[dvTP, 14]
button_event[dvTP, 15]
button_event[dvTP, 16] {
    push: {
    iSelectedInput = button.input.channel
    }
}


button_event[dvTP, 21]
button_event[dvTP, 22]
button_event[dvTP, 23]
button_event[dvTP, 24]
button_event[dvTP, 25]
button_event[dvTP, 26]
button_event[dvTP, 27]
button_event[dvTP, 28]
button_event[dvTP, 29]
button_event[dvTP, 30]
button_event[dvTP, 31]
button_event[dvTP, 32]
button_event[dvTP, 33]
button_event[dvTP, 34]
button_event[dvTP, 35]
button_event[dvTP, 36] {
    push: {
    //NAVSwitch(vdvObject, iSelectedInput, button.input.channel - 20, iSelectedSwitchType)
    send_level dvDevice[button.input.channel - 20], iSelectedSwitchType + 49, iSelectedInput
    }
}


button_event[dvTP, 201] {
    push: {
    iSelectedSwitchType = NAV_SWITCH_LEVEL_VID
    }
}

button_event[dvTP, 202] {
    push: {
    iSelectedSwitchType = NAV_SWITCH_LEVEL_AUD
    }
}


level_event[dvDevice, 50] {
    iOutput[NAV_SWITCH_LEVEL_VID][get_last(dvDevice)] = level.value
}

level_event[dvDevice, 51] {
    iOutput[NAV_SWITCH_LEVEL_AUD][get_last(dvDevice)] = level.value
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
