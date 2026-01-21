#Requires AutoHotkey v2.0
; ==============================================================================
; AHK-Windows
;
; Description:
;   This script provides Linux-style window management for Windows.
;   It allows moving and resizing windows using the Windows key + Mouse buttons,
;   without requiring the cursor to be on the title bar or window borders.
;
; Usage:
;   - Win + Left Click + Drag: Move window.
;   - Win + Left Double Click: Maximize/Restore window.
;   - Win + Right Click + Drag: Resize window (quadrant-based).
;
; Author: [Your Name/Handle]
; ==============================================================================

; Optimization Settings
SetWinDelay -1
SetControlDelay -1
SetMouseDelay -1
SetDefaultMouseSpeed 0

CoordMode "Mouse", "Screen" ; Use absolute screen coordinates

; ==============================================================================
; Hotkey: WIN + LEFT CLICK (Move / Maximize)
; ==============================================================================
#LButton::
{
    ; Get the unique ID (HWND) of the window under the mouse
    MouseGetPos &mx, &my, &id
    if !id
        return

    ; Check for Double Click (Maximize Toggle)
    ; If the same hotkey was pressed less than 400ms ago, treat it as a double-click.
    if (A_PriorHotkey == "#LButton" && A_TimeSincePriorHotkey < 400)
    {
        if WinGetMinMax("ahk_id " id)
            WinRestore "ahk_id " id
        else
            WinMaximize "ahk_id " id
        return
    }

    ; Prepare for Move operation
    ; If the window is currently maximized, restore it first.
    if (WinGetMinMax("ahk_id " id) == 1)
        WinRestore "ahk_id " id 
    
    ; Post WM_NCLBUTTONDOWN message (0xA1) with HTCAPTION (2)
    ; This tells the OS that the user clicked the title bar, initiating a native move loop.
    ; This is much smoother than manual WinMove loops.
    ; lParam must contain the screen coordinates of the mouse click (packed X in low word, Y in high word).
    PostMessage 0xA1, 2, (my << 16) | (mx & 0xFFFF), , "ahk_id " id
}

; ==============================================================================
; Hotkey: WIN + RIGHT CLICK (Resize)
; ==============================================================================
#RButton::
{
    MouseGetPos ,, &id
    if !id
        return

    ; Prepare for Resize
    ; Restore if maximized, as you can't resize a maximized window.
    if (WinGetMinMax("ahk_id " id) == 1)
        WinRestore "ahk_id " id
        
    WinGetPos &wx, &wy, &ww, &wh, "ahk_id " id
    MouseGetPos &mx, &my
    
    ; Determine Quadrant (Left/Right/Top/Bottom)
    ; This decides which edge(s) of the window get resized.
    resize_L := (mx < wx + (ww / 2))
    resize_T := (my < wy + (wh / 2))

    ; Determine HitTest value for WM_NCLBUTTONDOWN
    ; HTTOPLEFT = 13, HTTOPRIGHT = 14, HTBOTTOMLEFT = 16, HTBOTTOMRIGHT = 17
    hit_test := 0
    if (resize_T) {
        if (resize_L)
            hit_test := 13 ; Top-Left
        else
            hit_test := 14 ; Top-Right
    } else {
        if (resize_L)
            hit_test := 16 ; Bottom-Left
        else
            hit_test := 17 ; Bottom-Right
    }

    ; Initiate native resize
    ; lParam must contain the screen coordinates of the mouse click.
    PostMessage 0xA1, hit_test, (my << 16) | (mx & 0xFFFF), , "ahk_id " id
}
