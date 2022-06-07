﻿#Include WindHumanMouse.ahk
#SingleInstance, force
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

;****************************************************************************************
;---------------------------------------------------------------------------------------;
; Credits:																				;
; Arsenicus - marker code from OSRS Tool       				      						;
; 	Link: https://github.com/Arsenicus/AHK-Bot-Functions/blob/master/OSRS%20Tool.ahk	;
; ibieel - ListBox control code															;
; 	Link: https://www.autohotkey.com/boards/viewtopic.php?style=7&p=444489				;
;---------------------------------------------------------------------------------------;
; Future Improvements:																	;
; Save/Load file																		;
;---------------------------------------------------------------------------------------;
;****************************************************************************************

NameList := ""
NameArr := StrSplit(NameList, "|")

WinGet, window_, List 

Loop, %window_%{
	WinGetTitle, title, % "ahk_id" window_%A_Index%
	winlist.= title ? title "|" : ""
}

Gui, Font, s8, Verdana
Gui, +hwndGUIHwnd +AlwaysOnTop
Gui, Add, Button,xm y+40 w80 gButton_Play, Play
Gui, Add, Button,xm y+35 w80 gButton_Click_Box, Click Box
Gui, Add, Button,xs y+4 w80 gButton_Sleep, Sleep
Gui, Add, Button,xs y+4 w80 gButton_Delete, Delete
Gui, Add, ListBox,ys w190 r10 vItemChoice, %NameList%
Gui, Add, DropDownList,x10 y10 w280 h20 r7 vtitle gWinTitle choose1,%winlist%
Gui, Show, w300 h200, WQ Macro Maker
return


; ===============================================================================
; Labels
; ===============================================================================
Button_Click_Box:
	Toggle := True
	Gui, Submit, NoHide
	WinActivate, %title%
#if Toggle
LButton::

    WinGetPos xtemp, ytemp, , , A
    MouseGetPos x1, y1
    x1+=xtemp, y1+=ytemp
	
    While GetKeyState("LButton","P") {
       MouseGetPos x2, y2
       x2+=xtemp, y2+=ytemp
       x:= (x1<x2)?(x1):(x2)    ;x-coordinate of the top left corner
       y:= (y1<y2)?(y1):(y2)    ;y-coordinate of the top left corner
       
       w:= Abs(x2-x1), h:= Abs(y2-y1)
       ;ToolTip % "Coords " x - xtemp "," y - ytemp "  Dim " w "x" h
       
       marker(x, y, w, h, 3)

    }
	Toggle := False
	
	action_to_add := "clickbox " x - xtemp " " y - ytemp " " x+w-xtemp " " y+h-ytemp  
	NameArr.Push(action_to_add)
	Transform_Array_to_ListBox()
	GuiControl,, ItemChoice, % NameList
	
	
Return


Button_Sleep:
	WinGetPos current_window_x, current_window_y, , , A
	Gui +OwnDialogs
	Inputbox, sleep_duration, Add Sleep, Sleep: start end`nExample: 100 200, , 180, 150, current_window_x+75, current_window_y+20
	if !ErrorLevel{
		temp_sleep_array := strsplit(sleep_duration, " ")
		if (temp_sleep_array[2] == "")
			action_to_add := "sleep " temp_sleep_array[1] " " temp_sleep_array[1]
		else
			action_to_add := "sleep " temp_sleep_array[1] " " temp_sleep_array[2]
			
		NameArr.Push(action_to_add)
		Transform_Array_to_ListBox()
		GuiControl,, ItemChoice, % NameList
	}
return


Button_Delete:
	Gui, Submit, NoHide
	GuiControl, +AltSubmit, ItemChoice
	GuiControlGet, toDelete,, ItemChoice
	
		
	if (ItemChoice == ""){
		return
	}
	
	NameArr.RemoveAt(toDelete)
	Transform_Array_to_ListBox()
		
	GuiControl,, ItemChoice, % NameList
	GuiControl, -AltSubmit, ItemChoice
	
 	GuiControl, Choose, ItemChoice, % toDelete - 1
return


Button_Play:
	Gui, 3: Destroy
	Sleep 1000
	Gui, Submit, NoHide
	WinActivate, %title%
	for index, value in NameArr{
		GuiControl, Choose, ItemChoice, %index%
		action_array := strsplit(value, " ")
		
		; Switch case based on action
		switch action_array[1]{
			case "clickbox":
				click_box(action_array[2], action_array[3], action_array[4], action_array[5])
			case "sleep":
				Sleep, rand_range(action_array[2],action_array[3])
		}
	}
return

WinTitle:
	Gui, Submit, NoHide
return

GuiClose:
	ExitApp
return

; ===============================================================================
; Functions
; ===============================================================================
Transform_Array_to_ListBox() {
GLOBAL
	if (NameArr.MaxIndex() == ""){
		NameList := "|"
		return
	}
	NameList := ""		;clean listbox
	for index, value in NameArr	;search for each string in array
		NameList .= "|" value		;format array to listbox
}


marker(X:=0, Y:=0, W:=0, H:=0, n:=2){
	T:=3, ; Thickness of the Border
	w2:=W-T,
	h2:=H-T

	Gui, %n%:-Caption +AlwaysOnTop +LastFound +ToolWindow +E0x80020 +E0x08000000 
	Gui, %n%:Color, Red
	Gui, %n%:Show, w%W% h%H% x%X% y%Y% NA

	WinSet, Transparent, 150
	WinSet, Region, 0-0 %W%-0 %W%-%H% 0-%H% 0-0 %T%-%T% %w2%-%T% %w2%-%h2% %T%-%h2% %T%-%T%
}


; ===============================================================================
; Hotkeys
; ===============================================================================
#If
~Shift & LButton::
    WinGetPos xtemp, ytemp, , , A
    MouseGetPos x1, y1
    x1+=xtemp, y1+=ytemp
	
    While GetKeyState("LButton","P") {
       MouseGetPos x2, y2
       x2+=xtemp, y2+=ytemp
       x:= (x1<x2)?(x1):(x2)    ;x-coordinate of the top left corner
       y:= (y1<y2)?(y1):(y2)    ;y-coordinate of the top left corner
       
       w:= Abs(x2-x1), h:= Abs(y2-y1)
       ;ToolTip % "Coords " x - xtemp "," y - ytemp "  Dim " w "x" h
       
       marker(x, y, w, h, 3)

    }
	
	action_to_add := "clickbox " x - xtemp " " y - ytemp " " x+w-xtemp " " y+h-ytemp  
	NameArr.Push(action_to_add)
	Transform_Array_to_ListBox()
	GuiControl,, ItemChoice, % NameList
return 

#If
f9::reload
