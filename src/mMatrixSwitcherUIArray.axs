MODULE_NAME='mMatrixSwitcherUIArray'    (
                                            dev dvTP[],
                                            dev vdvObject
                                        )

(***********************************************************)
#include 'NAVFoundation.ModuleBase.axi'
#include 'NAVFoundation.UIUtils.axi'
#include 'NAVFoundation.ArrayUtils.axi'

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

constant integer MAX_IO = 64
constant integer MAX_LEVEL    = 2

constant integer BUTTON_INPUT[] =     {
                        01, 02, 03, 04, 05, 06, 07, 08, 09, 10,
                        11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                        21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
                        31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
                        41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
                        51, 52, 53, 54, 55, 56, 57, 58, 59, 60,
                        61, 62, 63, 64
                    }

constant integer BUTTON_OUTPUT[] =     {
                        201, 202, 203, 204, 205, 206, 207, 208, 209, 210,
                        211, 212, 213, 214, 215, 216, 217, 218, 219, 220,
                        221, 222, 223, 224, 225, 226, 227, 228, 229, 230,
                        231, 232, 233, 234, 235, 236, 237, 238, 239, 240,
                        241, 242, 243, 244, 245, 246, 247, 248, 249, 250,
                        251, 252, 253, 254, 255, 256, 257, 258, 259, 260,
                        261, 262, 263, 264
                    }

constant integer BUTTON_LEVEL[] =     {
                        401, 402
                    }

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile integer iSelectedLevel = NAV_SWITCH_LEVEL_VID
volatile integer iSelectedInput
volatile integer iCurrentInput[MAX_LEVEL][MAX_IO]
volatile integer iInputIsAudioSwicthingBoard[MAX_IO]
volatile integer iOutputIsAudioSwicthingBoard[MAX_IO]

volatile char cInputLabel[MAX_IO][NAV_MAX_CHARS]
volatile char cOutputLabel[MAX_IO][NAV_MAX_CHARS]

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
define_function EnableAudioIO(integer iState) {
    stack_var integer x

    for (x = 1; x <= MAX_IO; x++) {
    if (iInputIsAudioSwicthingBoard[x]) {
        NAVShowButtonArray(dvTP, BUTTON_INPUT[x], iState)
    }

    if (iOutputIsAudioSwicthingBoard[x]) {
        NAVShowButtonArray(dvTP, BUTTON_OUTPUT[x], iState)
    }
    }
}


define_function SelectLevel(integer iLevel) {
    iSelectedLevel = iLevel

    EnableAudioIO(iSelectedLevel == NAV_SWITCH_LEVEL_AUD)
}


define_function SelectInput(integer iInput) {
    iSelectedInput = iInput
}


define_function SelectOutput(integer iOutput) {
    if (iCurrentInput[iSelectedLevel][iOutput] != iSelectedInput) {
    NAVSwitch(vdvObject, iSelectedInput, iOutput, iSelectedLevel)
    } else {
    NAVSwitch(vdvObject, 0, iOutput, iSelectedLevel)
    }
}


define_function SendLabels() {
    stack_var integer x

    for (x = 1; x <= MAX_IO; x++) {
    if (length_array(cInputLabel[x])) {
        NAVTextArray(dvTP, BUTTON_INPUT[x], '0', cInputLabel[x])
    }
    else {
        NAVTextArray(dvTP, BUTTON_INPUT[x], '0', "'Input ', itoa(x)")
    }

    if (length_array(cOutputLabel[x])) {
        NAVTextArray(dvTP, BUTTON_OUTPUT[x], '0', cOutputLabel[x])
    }
    else {
        NAVTextArray(dvTP, BUTTON_OUTPUT[x], '0', "'Output ', itoa(x)")
    }
    }
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START {
    SelectLevel(iSelectedLevel)
}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT
timeline_event[TL_NAV_FEEDBACK] {
    stack_var integer x
    for (x = 1; x <= MAX_LEVEL; x++) {
    [dvTP, BUTTON_LEVEL[x]] = (iSelectedLevel == x)
    }

    for (x = 1; x <= MAX_IO; x++) {
    [dvTP, BUTTON_INPUT[x]] = (iSelectedInput == x)
    [dvTP, BUTTON_OUTPUT[x]] = (iSelectedInput && iSelectedLevel && (iCurrentInput[iSelectedLevel][x] = iSelectedInput));
    }
}

button_event[dvTP, BUTTON_INPUT] {
    push: {
    stack_var integer iInput

    iInput = get_last(BUTTON_INPUT)

    SelectInput(iInput)
    }
}

button_event[dvTP, BUTTON_OUTPUT] {
    push: {
    stack_var integer iOutput

    iOutput = get_last(BUTTON_OUTPUT)

    SelectOutput(iOutput)
    }
}


button_event[dvTP, BUTTON_LEVEL] {
    push: {
    stack_var integer iLevel

    iLevel = get_last(BUTTON_LEVEL)

    SelectLevel(iLevel)
    }
}

data_event[vdvObject] {
    string: {
    stack_var char cCmdHeader[NAV_MAX_CHARS]
    stack_var char cCmdParam[3][NAV_MAX_CHARS]

    NAVLog(NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_FROM, data.device, data.text))

    cCmdHeader = DuetParseCmdHeader(data.text)
    cCmdParam[1]    = DuetParseCmdParam(data.text)
    cCmdParam[2]    = DuetParseCmdParam(data.text)
    cCmdParam[3]    = DuetParseCmdParam(data.text)

    switch (cCmdHeader) {
        case 'SWITCH': {
        stack_var integer iLevel
        stack_var integer iInput
        stack_var integer iOutput

        iLevel = NAVFindInArraySTRING(NAV_SWITCH_LEVELS, cCmdParam[3])

        if (iLevel) {
            iInput = atoi(cCmdParam[1])
            iOutput = atoi(cCmdParam[2])
            iCurrentInput[iLevel][iOutput] = iInput
        }
        }
    }
    }
    command: {
    stack_var char cCmdHeader[NAV_MAX_CHARS]
    stack_var char cCmdParam[3][NAV_MAX_CHARS]

    NAVLog(NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_COMMAND_FROM, data.device, data.text))

    cCmdHeader = DuetParseCmdHeader(data.text)
    cCmdParam[1]    = DuetParseCmdParam(data.text)
    cCmdParam[2]    = DuetParseCmdParam(data.text)
    cCmdParam[3]    = DuetParseCmdParam(data.text)

    switch (cCmdHeader) {
        case 'AUDIO_SWITCHING_BOARD': {
        switch (cCmdParam[1]) {
            case 'INPUT': {
            switch (cCmdParam[3]) {
                case 'true': {
                iInputIsAudioSwicthingBoard[atoi(cCmdParam[2])] = true
                }
                case 'false': {
                iInputIsAudioSwicthingBoard[atoi(cCmdParam[2])] = false
                }
            }
            }
            case 'OUTPUT': {
            switch (cCmdParam[3]) {
                case 'true': {
                iOutputIsAudioSwicthingBoard[atoi(cCmdParam[2])] = true
                }
                case 'false': {
                iOutputIsAudioSwicthingBoard[atoi(cCmdParam[2])] = false
                }
            }
            }
        }

        EnableAudioIO(iSelectedLevel == NAV_SWITCH_LEVEL_AUD)
        }
        case 'LABEL': {
        switch (cCmdParam[1]) {
            case 'INPUT': {
            cInputLabel[atoi(cCmdParam[2])] = cCmdParam[3]
            }
            case 'OUTPUT': {
            cOutputLabel[atoi(cCmdParam[2])] = cCmdParam[3]
            }
        }

        SendLabels()
        }
    }
    }
}


define_event data_event[dvTP] {
    online: {
    SelectLevel(iSelectedLevel)
    SendLabels()
    EnableAudioIO(iSelectedLevel == NAV_SWITCH_LEVEL_AUD)
    }
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
