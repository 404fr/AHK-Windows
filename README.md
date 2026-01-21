# AHK-Windows

A lightweight AutoHotkey v2 script that brings Linux-style window management to Windows. Easily move and resize windows using the Windows key and mouse clicks, without needing to target the window's title bar or borders.

## Features

- **Easy Window Moving**: Hold `Win` and drag with the `Left Mouse Button` anywhere on a window to move it.
- **Quick Maximize/Restore**: Double-click `Win` + `Left Mouse Button` on a window to toggle between Maximized and Restored states.
- **Easy Window Resizing**: Hold `Win` and drag with the `Right Mouse Button` anywhere on a window to resize it.
    - The resize direction depends on which quadrant of the window you click (e.g., clicking the top-left area resizes the top-left corner).
- **Smoother Experience**: Optimized for performance with reduced delay and realtime priority.

## Prerequisites

- [AutoHotkey v2.0](https://www.autohotkey.com/v2/) or later.

## Installation

1. Download and install AutoHotkey v2.
2. Download `AHKwindows.ahk` from this repository.
3. Double-click `AHKwindows.ahk` to run the script.

## Usage

| Action | Shortcut | Description |
| :--- | :--- | :--- |
| **Move Window** | `Win` + `Left Click` + Drag | Moves the window under the cursor. |
| **Maximize/Restore** | `Win` + `Left Click` (Double) | Toggles the window maximized state. |
| **Resize Window** | `Win` + `Right Click` + Drag | Resizes the window. Direction depends on click position relative to window center. |

To stop the script, find the green "H" icon in your system tray, right-click it, and select "Exit".
