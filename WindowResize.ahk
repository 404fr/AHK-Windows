#Requires AutoHotkey v2.0
; Optimization Settings
SetWinDelay -1
SetControlDelay -1
SetMouseDelay -1
SetDefaultMouseSpeed 0
ProcessSetPriority "Realtime" ; Critical for smooth resizing

CoordMode "Mouse", "Screen"

; --- WIN + LEFT CLICK: MOVE ---
#LButton::
{
    ; Get Window ID
    MouseGetPos ,, &id
    if !id
        return

    ; Check for Double Click (Maximize)
    if (A_PriorHotkey == "#LButton" && A_TimeSincePriorHotkey < 400)
    {
        if WinGetMinMax("ahk_id " id)
            WinRestore "ahk_id " id
        else
            WinMaximize "ahk_id " id
        return
    }

    ; Prepare for Move
    ; Only restore if it's maximized, otherwise we might mess up minimized windows
    if (WinGetMinMax("ahk_id " id) == 1)
        WinRestore "ahk_id " id 
        
    WinGetPos &wx, &wy, &ww, &wh, "ahk_id " id
    MouseGetPos &mx, &my
    
    ; Calculate offset from window corner
    off_x := mx - wx
    off_y := my - wy

    ; Move Loop
    while GetKeyState("LButton", "P") and (GetKeyState("LWin", "P") or GetKeyState("RWin", "P"))
    {
        MouseGetPos &curr_mx, &curr_my
        
        ; Only move if mouse actually moved (Reduces jitter)
        if (curr_mx != mx or curr_my != my)
        {
            WinMove curr_mx - off_x, curr_my - off_y,,, "ahk_id " id
            mx := curr_mx
            my := curr_my
        }
        ; Sleep 0 yields CPU but keeps loop tight
        Sleep 0 
    }
}

; --- WIN + RIGHT CLICK: RESIZE ---
#RButton::
{
    MouseGetPos ,, &id
    if !id
        return

    ; Prepare for Resize
    if (WinGetMinMax("ahk_id " id) == 1)
        WinRestore "ahk_id " id
        
    WinGetPos &wx, &wy, &ww, &wh, "ahk_id " id
    MouseGetPos &mx, &my
    
    ; Determine Quadrant (Left/Right/Top/Bottom)
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
            
            ; Calculate new dimensions
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

            ; Apply (with min size check)
            if (final_w > 50 && final_h > 50)
                WinMove final_x, final_y, final_w, final_h, "ahk_id " id
        }
        Sleep 0
    }
}