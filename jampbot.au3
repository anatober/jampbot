#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=jampbot.ico
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#Tidy_Parameters=/tc 4 /sf /reel
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <File.au3>
#include <Array.au3>
#include <Color.au3>
#include <Inet.au3>
#include <Crypt.au3>

Global $consoleHandle = WinGetHandle("Jedi Knight Academy MP Console")
Global $paused = False
Global $pathToJampConfig
Global $interval
Global $classColors[2]
Global $saberColorsEx[4] = [0, 0, 0, 0]
Global $changeSaberColor
Global $changeSkinColor
Global $translate
Global $changeNameColor
Global $giveInfo
Global $info = StringSplit(StringReplace(_ArrayToString(StringSplit(FileRead("tips.txt"), @CRLF), "$"), "$$", "$"), "$", 2)
$info[0] = UBound($info) - 1
Global $changeName = 0
Global $triggers[$info[0] + 1]
Global $currentAnnoy = "4vnwvruqvyoerveqynivfadyfvsd6bvf9odsba"

If $consoleHandle = 0 Then
    MsgBox(16, "JampBot", "Jedi Academy not found!")
    Exit
EndIf

For $i = 1 To $info[0]
    If $info[$i] == "" Then ContinueLoop
    Local $temp = StringSplit($info[$i], "|")
    $triggers[$i] = StringSplit($temp[1], "/")
    $info[$i] = $temp[2]
Next

ReadIni()

While True
    CheckConsole()
WEnd

Func ChangeColors()
    SRandom(@SEC) ;set random seed
    Local $command = ""

;~     If $changeSaberColor = "Yes" Then
;~         Local $saturation = 100, $lightness = 50, $saberColors[4]
;~ 		   Local $minJediHue = 24.408, $maxJediHue = 306.21276, $minSithHue = 348.84, $maxSithHue = 367.56	;from MBII code
;~         Local $minJediHue = 25.2, $maxJediHue = 306, $minSithHue = 349.2, $maxSithHue = 367.2 ;from saber picking menu

;~         Local $hsl[3] = [Random($minJediHue, $maxJediHue), $saturation, $lightness]
;~         $saberColors[0] = _ColorSetRGB(_ColorConvertHSLtoRGB($hsl))

;~         $hsl[0] = Random($minJediHue, $maxJediHue)
;~         $saberColors[1] = _ColorSetRGB(_ColorConvertHSLtoRGB($hsl))

;~         $hsl[0] = Random($minSithHue, $maxSithHue)
;~         If $hsl[0] > 360 Then $hsl[0] -= 360
;~         $saberColors[2] = _ColorSetRGB(_ColorConvertHSLtoRGB($hsl))

;~         $hsl[0] = Random($minSithHue, $maxSithHue)
;~         If $hsl[0] > 360 Then $hsl[0] -= 360
;~         $saberColors[3] = _ColorSetRGB(_ColorConvertHSLtoRGB($hsl))

;~         For $i = 0 To 3
;~             $command &= "color" & $i + 1 & " " & Int($saberColors[$i]) & ";"
;~         Next
;~     EndIf

    If $changeSaberColor = "Yes" Then
        Local $saberColors[4]

        For $classIter = 0 To 1 Step +1
            For $colorIter = ($classIter * 2) To (($classIter * 2) + 1)
                Local $size = UBound($classColors[$classIter]) - 1
                $saberColors[$colorIter] = Int(Random(0, $size)) ;generate random value from 0 to array size
                If ($saberColors[$colorIter] = $saberColorsEx[$colorIter]) Then ;if new color is the same as previous one
                    If ($saberColors[$colorIter] = $size) Then ;if new color is the last one in array
                        $saberColors[$colorIter] = $saberColors[$colorIter] - 1 ;decrement it
                    Else
                        $saberColors[$colorIter] = $saberColors[$colorIter] + 1 ;increment it
                    EndIf
                EndIf
                $saberColorsEx[$colorIter] = $saberColors[$colorIter] ;previous = current
                $command = $command & "color" & ($colorIter + 1) & " " & ($classColors[$classIter])[$saberColors[$colorIter]] & ";"
            Next
        Next
    EndIf

    If $changeSkinColor = "Yes" Then ;skin color change
        Local $skinColors[3]
        Local $colorNames[3] = ["red", "green", "blue"]
        Local $color = 0
        For $i = 0 To 2
            ;sum of colors should always be > 100
            If ($i = 2 And ($skinColors[0] + $skinColors[1]) < 100) Then $color = 100 - ($skinColors[0] + $skinColors[1])
            $skinColors[$i] = Int(Random($color, 256))
            $command &= "char_color_" & $colorNames[$i] & " " & $skinColors[$i] & ";"
        Next
    EndIf

    If $changeNameColor = "Yes" Then
        $changeName += 1
        If $changeName = 4 Then
            $command &= "name ^" & Int(Random(0, 8)) & "H^" & Int(Random(0, 8)) & "e^" & Int(Random(0, 8)) & "l^" & Int(Random(0, 8)) & "i^" & Int(Random(0, 8)) & "x;"
            $changeName = 0
        EndIf
    EndIf

    SendCommand($command)
    Sleep($interval) ;put a delay here because if we change /userinfo cvars too often it'd just be ignored
EndFunc   ;==>ChangeColors

Func CheckConsole()
    Local $data = StringSplit(ControlGetText($consoleHandle, "", "Edit2"), @CRLF) ;get console output
    If $data[0] <> 0 Then
        ControlSetText($consoleHandle, "", "Edit2", "") ;clear the console to ease the future reading
        $data = StringSplit(StringReplace(_ArrayToString($data, "$"), "$$", "$"), "$", 2) ;delete empty lines
        For $i = 0 To (UBound($data) - 1)
            Local $commandString = StringSplit($data[$i], " ")
            Local $targetPos
            Local $splitted = StringSplit($data[$i], ":")
            Local $nnick = $splitted[1]
            If $splitted[0] > 1 And StringInStr($nnick, $currentAnnoy) And StringInStr($data[$i], "!annoy") = 0 Then
                ;Say(StringReverse($splitted[2]))
                Say(Yoda($splitted[2]))
            EndIf
            Switch True
                Case StringInStr($data[$i], ": !translate")
                    If $translate = "Yes" Then
                        Local $nick = ""
                        Local $message = ""
                        Local $translation = ""
                        For $j = 1 To $commandString[0]
                            If $commandString[$j] = "!translate" Then
                                $targetPos = $j ;find command position
                                ExitLoop
                            EndIf
                        Next
                        For $j = 1 To $targetPos - 1
                            $nick &= $commandString[$j] & " "
                        Next
                        For $j = $targetPos + 2 To $commandString[0]
                            $message &= $commandString[$j] & " "
                        Next
                        If $message = "" Then
                            Say("^7Example - ^1!translate ^4fr ^7I love you!")
                            ContinueLoop
                        EndIf
                        If $commandString[$targetPos + 1] = "ru" Or $commandString[$targetPos + 1] = "ua" Then
                            $translation = Translit(Translate($message, $commandString[$targetPos + 1]))
                        Else
                            $translation = Translate($message, $commandString[$targetPos + 1])
                        EndIf
                        If StringInStr($translation, "DOCTYPE") Then
                            Say("^5" & $nick & ", wrong language code.")
                            ContinueLoop
                        EndIf

                        Say("^5" & $nick & "^2" & $translation)
                        ContinueLoop
                    EndIf
                Case StringInStr($data[$i], ": !yoda")
                    Local $message = ""
                    Local $translation = ""
                    For $j = 1 To $commandString[0]
                        If $commandString[$j] = "!yoda" Then
                            $targetPos = $j ;find command position
                            ExitLoop
                        EndIf
                    Next
                    For $j = $targetPos + 1 To $commandString[0]
                        $message &= $commandString[$j] & " "
                    Next
                    Say(Yoda($message))
                Case StringInStr($data[$i], ": !annoy")
                    If $commandString[0] = 3 And StringInStr($commandString[3], "helix") = 0 Then
                        $currentAnnoy = $commandString[3]
                    EndIf
                Case StringInStr($data[$i], ": what is")
                    Say("^7baby don't hurt me, don't hurt me, no more...")
                Case StringInStr($data[$i], ": !info")
                    If $giveInfo = "Yes" Then
                        Local $message = ""
                        Local $nick = ""
                        Local $infoFound = False
                        For $j = 1 To $commandString[0]
                            If $commandString[$j] = "!info" Then
                                $targetPos = $j ;find command position
                                ExitLoop
                            EndIf
                        Next
                        For $j = $targetPos + 1 To $commandString[0]
                            $message &= $commandString[$j] & " "
                        Next
                        $message = StringTrimRight($message, 1)
                        If $message = "" Then
                            Say("^5Categories ^7- ^3players^7, ^3clans^7, ^3parameters^7, ^3mechanics^7, ^3rulebreaking^7, ^3maps^7")
                            ContinueLoop
                        ElseIf $message = "faggot" Then
                            For $j = 1 To $targetPos - 1
                                $nick &= $commandString[$j] & " "
                            Next
                            Say("^7There's only one ^1faggot ^7in ^3MBII ^7- ^5" & StringTrimRight($nick, 2) & "^7.")
                            ContinueLoop
                        EndIf
                        For $j = 1 To $info[0]
                            For $k = 1 To ($triggers[$j])[0]
                                If $message = ($triggers[$j])[$k] Then
                                    $infoFound = True
                                    If StringInStr($info[$j], "\") Then
                                        Local $multiSay = StringSplit($info[$j], "\")
                                        Say("^5" & ($triggers[$j])[1] & " ^7- " & $multiSay[1])
                                        For $m = 2 To $multiSay[0]
                                            Say("^5*^7" & $multiSay[$m])
                                        Next
                                    Else
                                        Say("^5" & ($triggers[$j])[1] & " ^7- " & $info[$j])
                                    EndIf
                                EndIf
                            Next
                        Next
                        If Not $infoFound Then
                            For $j = 1 To $targetPos - 1
                                $nick &= $commandString[$j] & " "
                            Next
                            SendCommand("tell " & StringTrimRight($nick, 2) & " ^7Sorry, no info found about ^1" & $message & " ^7:(")
                            Sleep(1000)
                        EndIf
                    EndIf
            EndSwitch
        Next
    EndIf
    ChangeColors()
EndFunc   ;==>CheckConsole

Func ClearConsole()
    SendCommand("echo ^3Cleared!")
    ControlSetText($consoleHandle, "", "Edit2", "")
EndFunc   ;==>ClearConsole

Func GetCvar($cvar)
    Local $jampconfig
    _FileReadToArray($pathToJampConfig, $jampconfig)
    For $i = 1 To $jampconfig[0]
        If StringInStr($jampconfig[$i], " " & $cvar & " ") Then
            Local $splitString = StringSplit($jampconfig[$i], " ")
            Return StringTrimLeft(StringTrimRight($splitString[3], 1), 1)
        EndIf
    Next
EndFunc   ;==>GetCvar

;~ Both POST and GET are taken from here:
;~ https://www.autoitscript.com/forum/topic/147621-http-get-and-post-request-as-simple-as-possible/
Func HttpGet($sURL, $sData = "")
    Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")

    $oHTTP.Open("GET", $sURL & "" & $sData, False)
    If (@error) Then Return SetError(1, 0, 0)

    $oHTTP.Send()
    If (@error) Then Return SetError(2, 0, 0)

    If ($oHTTP.Status <> 200) Then Return SetError(3, 0, 0)

    Return SetError(0, 0, $oHTTP.ResponseText)
EndFunc   ;==>HttpGet

Func HttpPost($sURL, $sData = "")
    Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")

    $oHTTP.Open("POST", $sURL, False)
    If (@error) Then Return SetError(1, 0, 0)

    $oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")

    $oHTTP.Send($sData)
    If (@error) Then Return SetError(2, 0, 0)

    If ($oHTTP.Status <> 200) Then Return SetError(3, 0, 0)

    Return SetError(0, 0, $oHTTP.ResponseText)
EndFunc   ;==>HttpPost

Func QuitScript()
    Exit
EndFunc   ;==>QuitScript

Func ReadIni()
    HotKeySet("{" & IniRead(@ScriptDir & "\jampbot.ini", "General", "PauseKey", "F3") & "}", "TogglePause")
    HotKeySet("{" & IniRead(@ScriptDir & "\jampbot.ini", "General", "ShutdownKey", "F5") & "}", "QuitScript")
    $pathToJampConfig = IniRead(@ScriptDir & "\jampbot.ini", "General", "PathToJampConfig", "")

    If Not FileExists($pathToJampConfig) Then
        Local $newPath = ""
        TrayTip("JampBot", "Please point me to" & @LF & "GameData\MBII\jampconfig.cfg", 5)
        $newPath = FileOpenDialog("JampBot", @ScriptDir, "Config files (*.cfg)", 1)
        IniWrite(@ScriptDir & "\jampbot.ini", "General", "PathToJampConfig", $newPath)
        $pathToJampConfig = $newPath
    EndIf

    $interval = IniRead(@ScriptDir & "\jampbot.ini", "General", "ColorChangeIntervalInMs", 2000)
    $changeSaberColor = IniRead(@ScriptDir & "\jampbot.ini", "Modules", "ChangeSaberColor", False)
    $changeNameColor = IniRead(@ScriptDir & "\jampbot.ini", "Modules", "ChangeNameColor", False)
    $giveInfo = IniRead(@ScriptDir & "\jampbot.ini", "Modules", "Info", False)
    If $changeSaberColor Then
        $classColors[0] = StringSplit(IniRead(@ScriptDir & "\jampbot.ini", "Colors", "Jedi", 0), "|", 2)
        $classColors[1] = StringSplit(IniRead(@ScriptDir & "\jampbot.ini", "Colors", "Sith", 0), "|", 2)
    EndIf
    $changeSkinColor = IniRead(@ScriptDir & "\jampbot.ini", "Modules", "ChangeSkinColor", False)
    $translate = IniRead(@ScriptDir & "\jampbot.ini", "Modules", "Translate", False)
EndFunc   ;==>ReadIni

Func Say($string)
    SendCommand("say " & $string)
    Sleep(1000) ;anti-anti-spam filter
EndFunc   ;==>Say

Func SendCommand($command)
    ControlSetText($consoleHandle, "", "Edit1", $command) ;send the command to console
    ControlSend($consoleHandle, "", "Edit1", "{ENTER}")
    Send("") ;unstuck CTRL, SHIFT, ALT
EndFunc   ;==>SendCommand

Func TogglePause()
    $paused = Not $paused
    If $paused Then
        SendCommand("echo ^1Paused")
    Else
        SendCommand("echo ^2Unpaused")
    EndIf
    While $paused
        Sleep(100)
    WEnd
EndFunc   ;==>TogglePause

Func Translate($string, $toLang)
    Return HttpGet("http://script.google.com/macros/s/AKfycbxp2M781a-OlT7uL1umGAUQSH2OCnA7oEmcIgXFqwuEr5-KPUI/exec?q=" & $string & "&target=" & $toLang)
EndFunc   ;==>Translate

Func Translit($iText)
    Local $aLetters[70][2] = [['а', 'a'], ['б', 'b'], ['в', 'v'], ['г', 'g'], ['д', 'd'], ['е', 'e'], ['ё', 'e'], ['ж', 'zh'], ['з', 'z'], ['и', 'i'], _
            ['й', 'y'], ['к', 'k'], ['л', 'l'], ['м', 'm'], ['н', 'n'], ['о', 'o'], ['п', 'p'], ['р', 'r'], ['с', 's'], ['т', 't'], _
            ['у', 'u'], ['ф', 'f'], ['х', 'h'], ['ц', 'ts'], ['ч', 'ch'], ['ш', 'sh'], ['щ', 'shch'], ['ъ', ''], ['ы', 'i'], ['ь', ''], _
            ['э', 'e'], ['ю', 'yu'], ['я', 'ya'], ['і', 'i'], ['ї', 'yi'], _
            ['А', 'A'], ['Б', 'B'], ['В', 'V'], ['Г', 'G'], ['Д', 'D'], ['Е', 'E'], ['Ё', 'E'], ['Ж', 'Zh'], ['З', 'Z'], ['И', 'I'], _
            ['Й', 'Y'], ['К', 'K'], ['Л', 'L'], ['М', 'M'], ['Н', 'N'], ['О', 'O'], ['П', 'P'], ['Р', 'R'], ['С', 'S'], ['Т', 'T'], _
            ['У', 'U'], ['Ф', 'F'], ['Х', 'H'], ['Ц', 'Ts'], ['Ч', 'Ch'], ['Ш', 'Sh'], ['Щ', 'Shch'], ['Ъ', ''], ['Ы', 'I'], ['Ь', ''], _
            ['Э', 'E'], ['Ю', 'Yu'], ['Я', 'Ya'], ['І', 'I'], ['Ї', 'Yi']]
    For $i = 0 To UBound($aLetters) - 1
        $iText = StringRegExpReplace($iText, $aLetters[$i][0], $aLetters[$i][1])
    Next
    Return $iText
EndFunc   ;==>Translit

Func Yoda($string)
    Return StringTrimLeft(StringTrimRight(StringSplit(HttpGet("http://yoda-api.appspot.com/api/v1/yodish?text=" & $string), ":")[2], 3), 2)
EndFunc   ;==>Yoda
