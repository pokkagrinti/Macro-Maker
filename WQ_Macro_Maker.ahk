#Include WindHumanMouse.ahk
#SingleInstance, force
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

;=======================================================================================;
; Credits:                                                                              ;
; Arsenicus - marker code from OSRS Tool                                                ;
;     Link: https://github.com/Arsenicus/AHK-Bot-Functions/blob/master/OSRS%20Tool.ahk  ;
; ibieel - ListBox control code                                                         ;
;     Link: https://www.autohotkey.com/boards/viewtopic.php?style=7&p=444489            ;
; tally - Stopwatch Code                                                                ;
;     Link: https://www.autohotkey.com/board/topic/31360-ahk-stopwatch/                 ;
;---------------------------------------------------------------------------------------;
; Future Improvements:                                                                  ;
; Chance of running actions                                                             ;
;---------------------------------------------------------------------------------------;
; Version Changes:                                                                      ;
; 1.0	Basic Macro Maker. Play, Sleep, ClickBox, Delete actions                        ;
;                                                                                       ;
; 1.1	Added insertion of actions into specific position in the macro                  ;
;       Added refreshing of Window Titles with F5                                       ;
;       Added Loop support                                                              ;
;       Added Hotkey to Play and Stop                                                   ;
;                                                                                       ;
; 1.2	Added Time Elapsed and Iterations counter                                       ;
;                                                                                       ;
; 1.3	Added Save/Load button and labelled gui as main for future child windows        ;
;       Added Save prompt                                                               ;
;=======================================================================================;

NameList := ""
loaded_file := ""
NameArr := StrSplit(NameList, "|")
prompt_save := False

WinGet, window_, List 

Loop, %window_%{
	WinGetTitle, title, % "ahk_id" window_%A_Index%
	winlist.= title ? title "|" : ""
}

Gui, Font, s8, Verdana
Gui, main:New, +hwndGUIHwnd +AlwaysOnTop
Gui, main:Add, Button,xm y+40 w80 vplay_button gButton_Play, Play [F1]
Gui, main:Add, Edit,x11 y+4 w77 vRepeat_Edit +Center 
Gui, main:Add, UpDown, vRepeat Range0-999 Centre, 0
Gui, main:Add, Button,xm y+35 w80 gButton_Click_Box, Click Box
Gui, main:Add, Button,xs y+4 w80 gButton_Sleep, Sleep
Gui, main:Add, Button,xs y+4 w80 gButton_Delete, Delete
Gui, main:Add, ListBox,ys w190 r12 vItemChoice, %NameList%

Gui, main:Add, Button, w90 Section gButton_Save, Save
Gui, main:Add, Button,xp+100 ys w90 gButton_Load, Load

Gui, main:Add, Text, x10 y45 w80 h30 +Center vStop_Text hidden, Stop [F2]`nIteration: 1
Gui, main:Add, Text, x10 y90 w80 h30 vTText +Center hidden, Time Elapsed`n00:00
Gui, main:Add, DropDownList,x10 y10 w280 h20 r7 vddltitle hwndddl_id choose1,%winlist%
Gui, main:Show, w300 h240, WQ Macro Maker

;Gui pixel:New, +Ownermain +AlwaysOnTop
;Gui,pixel:Show,w200 h150
return


; ===============================================================================
; Labels
; ===============================================================================
Button_Click_Box:
	click_toggle := True
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
	
	insert_to_NameArr(action_to_add)
return


Button_Sleep:
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
			

		insert_to_NameArr(action_to_add)
	}
return


Button_Delete:
	prompt_save := True
	Gui, main:Submit, NoHide
	GuiControl, main:+AltSubmit, ItemChoice
	GuiControlGet, toDelete, main:, ItemChoice
	
		
	if (ItemChoice == ""){
		return
	}
	
	NameArr.RemoveAt(toDelete)
	transform_array_to_ListBox()
		
	GuiControl, main:, ItemChoice, % NameList
	GuiControl, main:-AltSubmit, ItemChoice
	
	if (toDelete > 1)
		toDelete -= 1
	
 	GuiControl, main:Choose, ItemChoice, % toDelete
return


Button_Play:
	GuiControl, main:Hide, play_button
	GuiControl, main:Hide, Repeat_Edit
	GuiControl, main:Hide, Repeat
	GuiControl, main:Show, Stop_Text
	GuiControl, main:Show, TText
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
	GuiControl,main:, Stop_Text, Stop [F2]`nIteration: 1
	GuiControl, main:Hide, Stop_Text
	GuiControl, main:Show, play_button
	GuiControl, main:Show, Repeat_Edit
	GuiControl, main:Show, Repeat
	
	Settimer, Stopwatch, Off
return


Button_Save:
	prompt_save := False
	save_file()
return


Button_Load:
	Gui, main: +Disabled
	if (prompt_save){
		SetTimer, WinMoveMsgBox, -50
		MsgBox, 4147, Save Macro, Do you want to save changes to the Macro?
		IfMsgBox, No
			prompt_save := False
		else IfMsgBox Yes
			prompt_save := False
		else{
			Gui, main: -Disabled
			return
		}
	}
	load_file()
	Gui, main: -Disabled
return

WinMoveMsgBox:
	WinGetPos, x, y,,, WQ Macro Maker
	ID:=WinExist("Save Macro")
	WinMove, ahk_id %ID%, , x-10, y+40
Return

Stopwatch:
	timers += 1
	if(timers > 59){
		timerm += 1
		timers := "0"
		GuiControl, main:, TText ,  Time Elapsed`n%timerm%:%timers%
	}
	if(timers < 10){
		GuiControl, main:, TText ,  Time Elapsed`n%timerm%:0%timers%
	}
	else{
		GuiControl, main:, TText ,  Time Elapsed`n%timerm%:%timers%
	}
return

mainGuiClose:
	Gui, main: +Disabled
	if (prompt_save){
		SetTimer, WinMoveMsgBox, -50
		MsgBox, 4147, Save Macro, Do you want to save changes to the Macro?
		IfMsgBox, No
			prompt_save := False
		else IfMsgBox Yes
			prompt_save := False
		else{
			Gui, main: -Disabled
			return
		}
	}
	ExitApp
return

; ===============================================================================
; Functions
; ===============================================================================
transform_array_to_ListBox() {
GLOBAL
	if (NameArr.MaxIndex() == ""){
		NameList := "|"
		return
	}
	NameList := ""		;clean listbox
	for index, value in NameArr	;search for each string in array
		NameList .= "|" value		;format array to listbox
}

insert_to_NameArr(action_to_add){
GLOBAL
	prompt_save := True
	Gui, main:Submit, NoHide
	GuiControl, main:+AltSubmit, ItemChoice
	GuiControlGet, insertAt, main:, ItemChoice
	
	; if nothing is selected or actions empty
	if (insertAt == ""){
		if (NameArr.MaxIndex() == "")
			insertAt := 0
		else 
			insertAt := NameArr.MaxIndex()
	}
	NameArr.insert(insertAt+1, action_to_add)
	transform_array_to_ListBox()
	GuiControl, main:, ItemChoice, % NameList
	GuiControl, main:Choose, ItemChoice, % insertAt + 1
	GuiControl, main:-AltSubmit, ItemChoice
}


save_file(){
GLOBAL
	Gui, main: +Disabled -AlwaysOnTop
	
	if (loaded_file == "")
		FileSelectFile, save_location, S26 , %A_ScriptDir%\Macro.wqm , Save as, WQ Macro (*.wqm)
	else
		FileSelectFile, save_location, S26 , %A_ScriptDir%\%loaded_file% , Save as, WQ Macro (*.wqm)
	if (save_location == ""){
		Gui, main: -Disabled +AlwaysOnTop
		return
	}
	
	file_handle := FileOpen(save_location,"w")
	if !IsObject(file_handle){
		Gui, main: -Disabled +AlwaysOnTop
		return
	}
	
	for index, value in NameArr{
		file_handle.write(value)
		file_handle.write("`n")
	}
	
	file_handle.close()
	
	temp_array := StrSplit(save_location, "\")
	filename := temp_array[temp_array.MaxIndex()]
	
	if (SubStr(filename, -3) != ".wqm"){
		FileMove, %save_location%, %save_location%.wqm
	}
	
	loaded_file := filename ".wqm"
	
	Gui, main: -Disabled +AlwaysOnTop
}

load_file(){
GLOBAL
	Gui, main: +Disabled -AlwaysOnTop
	FileSelectFile, load_location, 3, %A_ScriptDir% , Load Macro, WQ Macro (*.wqm)
	if (load_location == ""){
		Gui, main: -Disabled +AlwaysOnTop
		return
	}
	
	FileRead, file_content, % load_location
	if ErrorLevel{
		Gui, main: -Disabled +AlwaysOnTop
		Msgbox, Unable to read Macro file
		return
	}
	
	NameArr := []
	Loop, parse, file_content, `n, `r 
	{	
		NameArr.push(A_LoopField)
	}
	
	temp_array := StrSplit(load_location, "\")
	filename := temp_array[temp_array.MaxIndex()]
	loaded_file := filename
	
	transform_array_to_ListBox()
	GuiControl, main:, ItemChoice, % NameList
	GuiControl, main:Choose, ItemChoice, 1
	GuiControl, main:-AltSubmit, ItemChoice
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
	
	insert_to_NameArr(action_to_add)
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

