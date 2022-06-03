#SingleInstance, force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines -1


Gui, Font, s8, Verdana
Gui, +AlwaysOnTop +hwndGUIHwnd
Gui, Add, Progress, Section w50 h50 BackgroundBlack cWhite hwndProgress, 100
num:=10
choices:= "Red|Green|Blue|Black|White"
Gui, Add, ListBox, AltSubmit r%num% ys vColorChoice, %choices%
Gui, Show,, WQ Macro


f1::
	Gui, Submit , NoHide
	Loop, Parse, ColorChoice, |
	{
		MsgBox Selection number %A_Index% is %A_LoopField%.
	}
	return
	
f2::
	MouseGetPos, xpos, ypos, MouseWin
	WinGetPos, xtemp, ytemp,,, A ; get the Active window's current location
	xpos:=xtemp+xpos
	ypos:=ytemp+ypos
	marker(xpos,ypos,50,50)
	return

f9::
	reload
	return
	
GuiClose:
	ExitApp
Return
	

marker(X:=0, Y:=0, W:=0, H:=0)
{
T:=3, ; Thickness of the Border
w2:=W-T,
h2:=H-T

static n := 1
n++
Gui, %n%:-Caption +AlwaysOnTop +LastFound +ToolWindow +E0x80020 +E0x08000000 
Gui, %n%:Color, Red
Gui, %n%:Show, w%W% h%H% x%X% y%Y% NA

WinSet, Transparent, 150
WinSet, Region, 0-0 %W%-0 %W%-%H% 0-%H% 0-0 %T%-%T% %w2%-%T% %w2%-%h2% %T%-%h2% %T%-%T%

Return  
}