#Include WindHumanMouse.ahk
#SingleInstance, force
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

;=======================================================================================;
; Credits:																				;
; Arsenicus - marker code from OSRS Tool       				      						;
; 	Link: https://github.com/Arsenicus/AHK-Bot-Functions/blob/master/OSRS%20Tool.ahk	;
; ibieel - ListBox control code															;
; 	Link: https://www.autohotkey.com/boards/viewtopic.php?style=7&p=444489				;
; tally - Stopwatch Code																;
; 	Link: https://www.autohotkey.com/board/topic/31360-ahk-stopwatch/					;
;---------------------------------------------------------------------------------------;
; Future Improvements:																	;
; Save/Load file																		;
;---------------------------------------------------------------------------------------;
; Version Changes:																		;
; 1.0	Basic Macro Maker. Play, Sleep, ClickBox, Delete actions						;
; 																						;
; 1.1	Added insertion of actions into specific position in the macro					;
;		Added refreshing of Window Titles with F5										;
;		Added Loop support																;
;		Added Hotkey to Play and Stop													;
;																						;
; 1.2	Added Time Elapsed and Iterations counter										;
;=======================================================================================;

NameList := ""
NameArr := StrSplit(NameList, "|")
run_status := False

WinGet, window_, List 

Loop, %window_%{
	WinGetTitle, title, % "ahk_id" window_%A_Index%
	winlist.= title ? title "|" : ""
}

Gui, Font, s8, Verdana
Gui, +hwndGUIHwnd +AlwaysOnTop
Gui, Add, Button,xm y+40 w80 vplay_button gButton_Play, Play [F1]
Gui, Add, Edit,x11 y+4 w77 vRepeat_Edit +Center 
Gui, Add, UpDown, vRepeat Range0-999 Centre, 0
Gui, Add, Button,xm y+35 w80 gButton_Click_Box, Click Box
Gui, Add, Button,xs y+4 w80 gButton_Sleep, Sleep
Gui, Add, Button,xs y+4 w80 gButton_Delete, Delete
Gui, Add, ListBox,ys w190 r12 vItemChoice, %NameList%
Gui, Add, Text, x10 y45 w80 h30 +Center vStop_Text hidden, Stop [F2]`nIteration: 1
Gui, Add, Text, x10 y90 w80 h30 vTText +Center hidden, Time Elapsed`n00:00
Gui, Add, DropDownList,x10 y10 w280 h20 r7 vddltitle hwndddl_id choose1,%winlist%
Gui, Show, w300 h220, WQ Macro Maker
return


; ===============================================================================
; Labels
; ===============================================================================
Button_Click_Box:
	click_toggle := True
	Gui, Submit, NoHide
	GuiControl, +AltSubmit, ItemChoice
	GuiControlGet, insertAt,, ItemChoice
	
	WinActivate, %ddltitle%
#if click_toggle
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
	click_toggle := False
	
	action_to_add := "clickbox " x - xtemp " " y - ytemp " " x+w-xtemp " " y+h-ytemp
	
	; if nothing is selected or actions empty
	if (insertAt == ""){
		if (NameArr.MaxIndex() == "")
			insertAt := 0
		else 
			insertAt := NameArr.MaxIndex()
	}
	
	NameArr.insert(insertAt+1, action_to_add)
	Transform_Array_to_ListBox()
	GuiControl,, ItemChoice, % NameList
	GuiControl, Choose, ItemChoice, % insertAt + 1
	GuiControl, -AltSubmit, ItemChoice
	
Return


Button_Sleep:
	Gui, Submit, NoHide
	GuiControl, +AltSubmit, ItemChoice
	GuiControlGet, insertAt,, ItemChoice
	
	WinGetPos current_window_x, current_window_y, , , A
	Gui +OwnDialogs
	Inputbox, sleep_duration, Add Sleep, Sleep: start end`nExample: 100 200, , 180, 150, current_window_x+75, current_window_y+20
	if !ErrorLevel{
		temp_sleep_array := strsplit(sleep_duration, " ")
		if (temp_sleep_array[1] == "")
			return
		else if(temp_sleep_array[2] == "")
			action_to_add := "sleep " temp_sleep_array[1] " " temp_sleep_array[1]
		else
			action_to_add := "sleep " temp_sleep_array[1] " " temp_sleep_array[2]
		
		; if nothing is selected or actions empty
		if (insertAt == ""){
			if (NameArr.MaxIndex() == "")
				insertAt := 0
			else 
				insertAt := NameArr.MaxIndex()
		}
		
		NameArr.insert(insertAt+1, action_to_add)
		Transform_Array_to_ListBox()
		GuiControl, Choose, ItemChoice, % insertAt + 1
		GuiControl,, ItemChoice, % NameList
		GuiControl, -AltSubmit, ItemChoice
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
	
	if (toDelete > 1)
		toDelete -= 1
	
 	GuiControl, Choose, ItemChoice, % toDelete
return


Button_Play:
	GuiControl, Hide, play_button
	GuiControl, Hide, Repeat_Edit
	GuiControl, Hide, Repeat
	GuiControl, Show, Stop_Text
	GuiControl, Show, TText
	Gui, 3: Destroy
			
	timerm := "00"
	timers := "00"
	Settimer, Stopwatch, 1000
	
	Sleep 1000
	Gui, Submit, NoHide
	stop_toggle := false
	while True{
		GuiControl,, Stop_Text, Stop [F2]`nIteration: %A_Index%
		for index, value in NameArr{
			WinActivate, %ddltitle%
			if (stop_toggle)
				break
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
		
		if (A_Index == Repeat or stop_toggle)
			break
	}
	GuiControl,, Stop_Text, Stop [F2]`nIteration: 1
	GuiControl, Hide, Stop_Text
	GuiControl, Show, play_button
	GuiControl, Show, Repeat_Edit
	GuiControl, Show, Repeat
	
	Settimer, Stopwatch, Off
return


Stopwatch:
timers += 1
if(timers > 59)
{
	timerm += 1
	timers := "0"
	GuiControl, , TText ,  Time Elapsed`n%timerm%:%timers%
}
if(timers < 10)
{
	GuiControl, , TText ,  Time Elapsed`n%timerm%:0%timers%
}
else
{
	GuiControl, , TText ,  Time Elapsed`n%timerm%:%timers%
}
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
	Gui, Submit, NoHide
	GuiControl, +AltSubmit, ItemChoice
	GuiControlGet, insertAt,, ItemChoice
	
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
	
	; if nothing is selected or actions empty
	if (insertAt == ""){
		if (NameArr.MaxIndex() == "")
			insertAt := 0
		else 
			insertAt := NameArr.MaxIndex()
	}
	
	NameArr.insert(insertAt+1, action_to_add)
	Transform_Array_to_ListBox()
	GuiControl,, ItemChoice, % NameList
	GuiControl, Choose, ItemChoice, % insertAt + 1
	GuiControl, -AltSubmit, ItemChoice
	
return 

#If
f9::reload

#If
	f1::goto, Button_Play
return

#If
f2::stop_toggle := True
return

#If
f5::
	WinGet, window_, List 
	winlist := ""
	offset := 0
	
	Loop, %window_%{
		WinGetTitle, title, % "ahk_id" window_%A_Index%
		if (title == "WQ Macro Maker")
			offset += 1
		if (title == "WQ_Macro_Maker.ahk")
			offset += 1
		winlist .= title ? title "|" : ""
	}

	GuiControl,, ddltitle, |%winlist%
	GuiControl, Choose, ddltitle, % offset + 1  
return
