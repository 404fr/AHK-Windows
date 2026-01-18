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

; Optimization Settings for smoother window interactions
SetWinDelay -1
SetControlDelay -1
SetMouseDelay -1
SetDefaultMouseSpeed 0
ProcessSetPriority "Realtime" ; Critical for smooth resizing to prevent lag

CoordMode "Mouse", "Screen" ; Use absolute screen coordinates

; ==============================================================================
; Hotkey: WIN + LEFT CLICK (Move / Maximize)
; ==============================================================================
#LButton::
{
    ; Get the unique ID (HWND) of the window under the mouse
    MouseGetPos ,, &id
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
    ; Moving a maximized window directly usually doesn't work well in Windows.
    if (WinGetMinMax("ahk_id " id) == 1)
        WinRestore "ahk_id " id 
        
    ; Get initial window position and size
    WinGetPos &wx, &wy, &ww, &wh, "ahk_id " id
    ; Get initial mouse position
    MouseGetPos &mx, &my
    
    ; Calculate the offset of the mouse relative to the window's top-left corner.
    ; This ensures the window doesn't "snap" its top-left corner to the mouse position.
    off_x := mx - wx
    off_y := my - wy

    ; Move Loop: Continue while Left Mouse Button and Windows Key are held down
    while GetKeyState("LButton", "P") and (GetKeyState("LWin", "P") or GetKeyState("RWin", "P"))
    {
        MouseGetPos &curr_mx, &curr_my
        
        ; Only perform the move if the mouse has actually changed position.
        ; This reduces unnecessary system calls and jitter.
        if (curr_mx != mx or curr_my != my)
        {
            WinMove curr_mx - off_x, curr_my - off_y,,, "ahk_id " id
            mx := curr_mx
            my := curr_my
        }
        ; Sleep 0 yields the rest of the CPU time slice to other processes,
        ; preventing this loop from monopolizing the CPU.
        Sleep 0 
    }
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
    ; If mouse is on the left half, we modify the X/Width (Left resize).
    ; If mouse is on the right half, we modify Width only (Right resize).
    ; Same logic applies for Top/Bottom.
    resize_L := (mx < wx + (ww / 2))
    resize_T := (my < wy + (wh / 2))

    ; Resize Loop
    while GetKeyState("RButton", "P") and (GetKeyState("LWin", "P") or GetKeyState("RWin", "P"))
    {
        MouseGetPos &curr_mx, &curr_my

        if (curr_mx != mx or curr_my != my)
        {
            dx := curr_mx - mx
            dy := curr_my - my
            
            ; Calculate new dimensions based on the delta
            final_x := wx
            final_y := wy
            final_w := ww
            final_h := wh

            if (resize_L) {
                final_x += dx
                final_w -= dx
            } else {
                final_w += dx
            }

            if (resize_T) {
                final_y += dy
                final_h -= dy
            } else {
                final_h += dy
            }

            ; Apply changes, ensuring the window doesn't become too small (minimum 50x50)
            if (final_w > 50 && final_h > 50)
                WinMove final_x, final_y, final_w, final_h, "ahk_id " id
        }
        Sleep 0
    }
}
