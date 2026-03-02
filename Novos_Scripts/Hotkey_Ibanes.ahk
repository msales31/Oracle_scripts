;---- alt + = --- abre guia
;---- crtl + f12 --- fixa tela
;---- crlt + enter --- joga na tela fixada


; --- INITIALIZATION -----------------------------------------------------------------------------

  #InstallKeybdHook
  #UseHook On
  #SingleInstance force
  #WinActivateForce
  #ClipboardTimeout 3000
  SetBatchLines, 20ms
  SetWinDelay, 50
  SetKeyDelay, 0
  SetKeyDelay, 0, 0, Play
  #MaxThreads 15
  #MaxThreadsPerHotkey 1
  #MaxThreadsBuffer Off
  DetectHiddenWindows, Off

  ecb_snippet_dir = C:\Users\matheus.sales\OneDrive - PRIME DB SOLUTIONS\Documentos\Scripts_SQL\SQL\Novos_Scripts


; --- INTERNAL VARIABLES -------------------------------------------------------------------------

  ecb_shortdate = 19830111
_mWidth = 500
_mHeight = 300
_mHalfW = 250
_mHalfH = 150
_mMidX = 250
_mMidY = 150

  ecb_syswin_active = 0
  ecb_aw_wid =
  ecb_aw_prev_wid =
  ecb_aw_prevprev_wid =
  ecb_aw_minmax =

  ecb_tap_count = 0
  ecb_tap_cum = 0
  ecb_grid_wid =
  ecb_grid_prev_wid =

; --- STARTUP ------------------------------------------------------------------------------------

  GoSub, ecb_getmonitorinfo
  GroupAdd, ecb_group_any

; --- COMMON FUNCTIONS ---------------------------------------------------------------------------

  ecb_getmonitorinfo:
    SysGet, _m, MonitorWorkArea
_mWidth = 2048
  _mHeight = 1000
  _mHalfW = 600
  _mHalfH = 6050
  _mMidX = 600
  _mMidY = 600
    return


  ecb_syswin_check:
    ecb_syswin_active = 0
    WinGetClass, ecb_syswin_wclass, A
    if ecb_syswin_wclass in Shell_TrayWnd,DV2ControlHost,WorkerW,Progman,AutoHotkeyGUI
      ecb_syswin_active = 1
    if ecb_syswin_wclass in tooltips_class32,BaseWindow_RootWnd
      ecb_syswin_active = 1
    IfInString, ecb_syswin_wclass, #
      ecb_syswin_active = 1
    return

; --- ALT+TAB TWEAKS -----------------------------------------------------------------------------

  RAlt & `::ShiftAltTab
  RAlt & Tab::AltTab

  LAlt & `::ShiftAltTab
  LAlt & Tab::AltTab

; --- PUTTY HOTKEYS ------------------------------------------------------------------------------

  #IfWinActive ahk_class PuTTY
    LControl & WheelUp::SendInput ^{PgUp}
    LControl & WheelDown::SendInput ^{PgDn}
  #IfWinActive

  AppsKey::
    SendInput, {AppsKey}
    return

  AppsKey & F1::
    SendInput, su - oracle;`n
    return

  AppsKey & F2::
    SendInput, ps -ef | grep pmon;`n
    return

  AppsKey & F3::
    SendInput, echo $ORACLE_SID;`n
    return

  AppsKey & F4::
    SendInput, export ORACLE_SID=
    return

  AppsKey & F5::
    SendInput, cat /etc/crontab`n
    return

  AppsKey & F6::
    SendInput, crontab -l oracle`n
    return

  AppsKey & F7::
    SendInput, egrep '\s*[1-9].*'  /etc/hosts`n
    return

  AppsKey & F8::
    SendInput, cat /etc/fstab`n
    return

  AppsKey & F9::
    SendInput, chown oracle:oinstall%A_Space%
    return

  AppsKey & F10::
    SendInput, ssh -g -R 2222:127.0.0.1:22 ibanes@
    return

  AppsKey & F11::
    SendInput, egrep '\s*[1-9].*'  /etc/hosts`n
    return

; --- MINIMIZE ALL WINDOWS -----------------------------------------------------------------------

  LAlt & Backspace::
  RAlt & Backspace::
    WinClose, ahk_class MSBLWindowClass
    WinMinimizeAll
    return

; --- MINIMIZE ACTIVE WINDOW ---------------------------------------------------------------------

  MButton::GoSub, ecb_minimize
  AppsKey & RControl::GoSub, ecb_minimize
  RControl & AppsKey::GoSub, ecb_minimize
  LAlt & AppsKey::GoSub, ecb_minimize
  ecb_minimize:
    WinGet, ecb_minimize_wid, ID, A
    GoSub, ecb_syswin_check
    if ecb_syswin_active
      return
    WinGet, ecb_minimize_minmax, MinMax, ahk_id %ecb_minimize_wid%
    if ecb_minimize_minmax = -1
      return
    WinGetClass, ecb_minimize_wclass, ahk_id %ecb_minimize_wid%
    if ecb_minimize_wclass in MSBLWindowClass
    {
      WinClose, ahk_class MSBLWindowClass
      return
    }
    ; --- 0x112 = WM_SYSCOMMAND
    ; --- 0xF020 = SC_MINIMIZE
    PostMessage, 0x112, 0xF020,,, ahk_id %ecb_minimize_wid%
    return

; --- MAXIMIZE ACTIVE WINDOW ---------------------------------------------------------------------

  LAlt & 0::GoSub, ecb_maximize
  RAlt & 0::GoSub, ecb_maximize
  ecb_maximize:
    WinGet, ecb_maximize_wid, ID, A
    GoSub, ecb_syswin_check
    if ecb_syswin_active
      return
    WinGetClass, ecb_maximize_wclass, ahk_id %ecb_maximize_wid%
    if (A_PriorHotkey != A_ThisHotKey or A_TimeSincePriorHotkey > 1000 or ecb_tap_count >= 8)
      ecb_tap_count = 0
    ecb_tap_count += 1
    WinRestore, ahk_id %ecb_maximize_wid%
    if (ecb_maximize_wclass = "SciCalc") {
      WinGetPos, ecb_maximize_win_x, ecb_maximize_win_y, ecb_maximize_win_w
               , ecb_maximize_win_h, ahk_id %ecb_maximize_wid%
      WinMove, ahk_id %ecb_maximize_wid%,, _mMidX - ecb_maximize_win_w / 2
             , _mMidY - ecb_maximize_win_h / 2
      return
    }
    if (ecb_maximize_wclass = "PuTTY") {
      WinMove, ahk_id %ecb_maximize_wid%,, _mLeft, _mTop, _mWidth, _mHeight
      WinMaximize, ahk_id %ecb_maximize_wid%
      return
    }
    ecb_tap_count -= 1
    WinMove, ahk_id %ecb_maximize_wid%,, _mLeft + (30 * ecb_tap_count)
           , _mTop + (30 * ecb_tap_count), _mWidth - 60 * ecb_tap_count
           , _mHeight - (60 * ecb_tap_count)
    ecb_tap_count += 1
    return

; --- CENTER ACTIVE WINDOW -----------------------------------------------------------------------

  LALt & 5::GoSub, ecb_grid_center
  RAlt & 5::GoSub, ecb_grid_center
  ecb_grid_center:
    WinGet, ecb_grid_wid, ID, A
    if (ecb_grid_prev_wid != ecb_grid_wid)
      ecb_tap_count = 0
    GoSub, ecb_syswin_check
    if ecb_syswin_active
      return
    WinRestore, ahk_id %ecb_grid_wid%
    WinGetClass, ecb_grid_wclass, ahk_id %ecb_grid_wid%
    if (ecb_grid_wclass = "PuTTY") {
      WinMaximize, ahk_id %ecb_grid_wid%
      return
    }
    if (A_PriorHotkey != A_ThisHotKey or A_TimeSincePriorHotkey > 1000 or ecb_tap_count >= 2)
      ecb_tap_count = 0
    ecb_tap_count += 1
    ecb_grid_w = 775
    ecb_grid_h = 550
    if (ecb_tap_count = 2) {
      ecb_grid_w = 974
      ecb_grid_h = 718
    }
    if (ecb_grid_wclass = "SciCalc") {
      WinGetPos, ecb_grid_win_x, ecb_grid_win_y, ecb_grid_win_w
               , ecb_grid_win_h, ahk_id %ecb_grid_wid%
      WinMove, ahk_id %ecb_grid_wid%,, _mMidX - ecb_grid_win_w / 2, _mMidY - ecb_grid_win_h / 2
      return
    }
    WinMove, ahk_id %ecb_grid_wid%,, _mMidX - ecb_grid_w / 2, _mMidY - ecb_grid_h / 2
           , ecb_grid_w, ecb_grid_h
    ecb_grid_prev_wid := ecb_grid_wid
    return

; --- GRID --------------------------------------------------------------------------------------

  LAlt & 1::GoSub, ecb_grid_left1
  RAlt & 1::GoSub, ecb_grid_left1
  ecb_grid_left1:
    WinGet, ecb_grid_wid, ID, A
    GoSub, ecb_syswin_check
    if (ecb_syswin_active)
      return
    WinRestore, ahk_id %ecb_grid_wid%
    WinGetClass, ecb_grid_wclass, ahk_id %ecb_grid_wid%
    if (ecb_grid_wclass = "PuTTY") {
      WinMaximize, ahk_id %ecb_grid_wid%
      return
    }
    ecb_grid_justmove := 0
    ecb_grid_x := _mLeft
    ecb_grid_y := _mTop
    ecb_grid_w := _mWidth / 4
    ecb_grid_h := _mHeight
    if (ecb_grid_wclass = "SciTEWindow" or ecb_grid_wclass = "MozillaUIWindowClass")
      ecb_grid_w := _mHalfW
    GoSub, ecb_grid_done
    return

  LAlt & 2::GoSub, ecb_grid_left2
  RAlt & 2::GoSub, ecb_grid_left2
  ecb_grid_left2:
    WinGet, ecb_grid_wid, ID, A
    GoSub, ecb_syswin_check
    if (ecb_syswin_active)
      return
    WinRestore, ahk_id %ecb_grid_wid%
    WinGetClass, ecb_grid_wclass, ahk_id %ecb_grid_wid%
    if (ecb_grid_wclass = "PuTTY") {
      WinMaximize, ahk_id %ecb_grid_wid%
      return
    }
    ecb_grid_justmove := 0
    ecb_grid_x := _mLeft
    ecb_grid_y := _mTop
    ecb_grid_w := _mWidth / 2
    ecb_grid_h := _mHeight
    if (ecb_grid_wclass = "SciTEWindow" or ecb_grid_wclass = "MozillaUIWindowClass")
      ecb_grid_w := 1000
    GoSub, ecb_grid_done
    return

  LAlt & 3::GoSub, ecb_grid_left3
  RAlt & 3::GoSub, ecb_grid_left3
  ecb_grid_left3:
    WinGet, ecb_grid_wid, ID, A
    GoSub, ecb_syswin_check
    if (ecb_syswin_active)
      return
    WinRestore, ahk_id %ecb_grid_wid%
    WinGetClass, ecb_grid_wclass, ahk_id %ecb_grid_wid%
    if (ecb_grid_wclass = "PuTTY") {
      WinMaximize, ahk_id %ecb_grid_wid%
      return
    }
    ecb_grid_justmove := 0
    ecb_grid_x := _mLeft + _mWidth / 4
    ecb_grid_y := _mTop
    ecb_grid_w := _mWidth / 4
    ecb_grid_h := _mHeight
    if (ecb_grid_wclass = "SciTEWindow" or ecb_grid_wclass = "MozillaUIWindowClass")
      ecb_grid_w := _mHalfW
    GoSub, ecb_grid_done
    return

  LAlt & 4::GoSub, ecb_grid_left4
  RAlt & 4::GoSub, ecb_grid_left4
  ecb_grid_left4:
    WinGet, ecb_grid_wid, ID, A
    GoSub, ecb_syswin_check
    if (ecb_syswin_active)
      return
    WinRestore, ahk_id %ecb_grid_wid%
    WinGetClass, ecb_grid_wclass, ahk_id %ecb_grid_wid%
    if (ecb_grid_wclass = "PuTTY") {
      WinMaximize, ahk_id %ecb_grid_wid%
      return
    }
    ecb_grid_justmove := 0
    ecb_grid_x := _mLeft + _mWidth / 4
    ecb_grid_y := _mTop
    ecb_grid_w := _mWidth / 2
    ecb_grid_h := _mHeight
    GoSub, ecb_grid_done
    return

  LAlt & 9::GoSub, ecb_grid_right1
  RAlt & 9::GoSub, ecb_grid_right1
  ecb_grid_right1:
    WinGet, ecb_grid_wid, ID, A
    GoSub, ecb_syswin_check
    if (ecb_syswin_active)
      return
    WinRestore, ahk_id %ecb_grid_wid%
    WinGetClass, ecb_grid_wclass, ahk_id %ecb_grid_wid%
    if (ecb_grid_wclass = "PuTTY") {
      WinMaximize, ahk_id %ecb_grid_wid%
      return
    }
    ecb_grid_justmove := 0
    ecb_grid_x := _mRight - _mWidth / 4
    ecb_grid_y := _mTop
    ecb_grid_w := _mWidth / 4
    ecb_grid_h := _mHeight
    GoSub, ecb_grid_done
    return

  LAlt & 8::GoSub, ecb_grid_right2
  RAlt & 8::GoSub, ecb_grid_right2
  ecb_grid_right2:
    WinGet, ecb_grid_wid, ID, A
    GoSub, ecb_syswin_check
    if (ecb_syswin_active)
      return
    WinRestore, ahk_id %ecb_grid_wid%
    WinGetClass, ecb_grid_wclass, ahk_id %ecb_grid_wid%
    if (ecb_grid_wclass = "PuTTY") {
      WinMaximize, ahk_id %ecb_grid_wid%
      return
    }
    ecb_grid_justmove := 0
    ecb_grid_x := _mRight - _mWidth / 2
    ecb_grid_y := _mTop
    ecb_grid_w := _mWidth / 2
    ecb_grid_h := _mHeight
    GoSub, ecb_grid_done
    return

  LAlt & 7::GoSub, ecb_grid_right3
  RAlt & 7::GoSub, ecb_grid_right3
  ecb_grid_right3:
    WinGet, ecb_grid_wid, ID, A
    GoSub, ecb_syswin_check
    if (ecb_syswin_active)
      return
    WinRestore, ahk_id %ecb_grid_wid%
    WinGetClass, ecb_grid_wclass, ahk_id %ecb_grid_wid%
    if (ecb_grid_wclass = "PuTTY") {
      WinMaximize, ahk_id %ecb_grid_wid%
      return
    }
    ecb_grid_justmove := 0
    ecb_grid_x := _mRight - _mWidth / 2
    ecb_grid_y := _mTop
    ecb_grid_w := _mWidth / 4
    ecb_grid_h := _mHeight
    if (ecb_grid_wclass = "SciTEWindow") {
      ecb_grid_x := _mLeft + _mWidth / 4
      ecb_grid_w := _mHalfW
    }
    GoSub, ecb_grid_done
    return

  LAlt & 6::GoSub, ecb_grid_right4
  RAlt & 6::GoSub, ecb_grid_right4
  ecb_grid_right4:
    WinGet, ecb_grid_wid, ID, A
    GoSub, ecb_syswin_check
    if (ecb_syswin_active)
      return
    WinRestore, ahk_id %ecb_grid_wid%
    WinGetClass, ecb_grid_wclass, ahk_id %ecb_grid_wid%
    if (ecb_grid_wclass = "PuTTY") {
      WinMaximize, ahk_id %ecb_grid_wid%
      return
    }
    ecb_grid_justmove := 0
    ecb_grid_x := _mLeft + _mWidth / 4
    ecb_grid_y := _mTop
    ecb_grid_w := _mWidth / 2
    ecb_grid_h := _mHeight
    GoSub, ecb_grid_done
    return

  ecb_grid_done:
    if (ecb_grid_wclass = "SciCalc")
      ecb_grid_justmove = 1
    if (ecb_grid_wclass = "IMWindowClass")
      ecb_grid_w := _mHalfW
    if (ecb_grid_x + ecb_grid_w > _mRight)
      ecb_grid_x := _mRight - ecb_grid_w
    if (ecb_grid_justmove = 1) {
      WinMove, ahk_id %ecb_grid_wid%,, ecb_grid_x, ecb_grid_y
    } else {
      WinMove, ahk_id %ecb_grid_wid%,, ecb_grid_x, ecb_grid_y, ecb_grid_w, ecb_grid_h
    }
    ecb_grid_prev_wid := ecb_grid_wid
    return

; --- ALT+/ ----------------------------------------------------------------------------------

  LAlt & =::
  RAlt & =::
    WinGet, ecb_snippet_menu_tmpwid, ID, A
    WinGetClass, ecb_snippet_menu_tmpwclass, ahk_id %ecb_snippet_menu_tmpwid%
    Gui, 5: Cancel
    Gui, 5: Destroy
    if (ecb_snippet_menu_tmpwclass = "AutoHotkeyGUI") {
      WinActivate, ahk_id %ecb_snippet_menu_wid%
      return
    }
    if ecb_snippet_menu_tmpwclass not in Toad for Oracle,TMobaXtermForm,Toad,Xshell,RDC,Remote Desktop Connection.app,GRANOSERVER02,Google,Chrome,PuTTY,TSSHELLWND,VNCMDI_Window,SciTEWindow,TOracleForm,SqlplusWClass,TPLSQLDevForm,Transparent Windows Client,oracle.sysman.emSDK.client.appContainer.ApplicationFrame,TscShellContainerClass,XWin_MobaX,MobaXterm,Notepad++
    {
      WinActivate, ahk_id %ecb_snippet_menu_tmpwid%
      SoundPlay, %ecb_sound_dir%\beep2.wav
      return
    }
    ecb_snippet_menu_wid := ecb_snippet_menu_tmpwid
    ecb_snippet_menu_wclass := ecb_snippet_menu_tmpwclass
    ecb_snippet_menu_x := _mLeft + 15
    ecb_snippet_menu_y := _mTop + 15
    ecb_snippet_menu_w := _mHalfW - 15
    ecb_snippet_menu_h := _mHeight - 150
    ecb_snippet_menu_opts = W%ecb_snippet_menu_w% H%ecb_snippet_menu_h% BackgroundFFFFD4 -Lines
    ecb_snippet_menu_w += 20
    ecb_snippet_menu_h += 20
    ecb_snippet_menu_prev_sel = 0
    Gui, 5: Default
    Gui, 5: +AlwaysOnTop -Border -SysMenu +ToolWindow
    Gui, 5: Font, C000000 S8 W400, Courier New
    Gui, 5: Add, TreeView, X10 Y10 +0x20 +0x1000 +0x400 %ecb_snippet_menu_opts% gecb_snippet_menu_kp
    TV_Add("", 0, "Sort")
    Loop, %ecb_snippet_dir%\*.*, 2
    {
      ecb_snippet_tv_item := TV_Add(A_LoopFileName, 0, "Sort")
      Loop, %ecb_snippet_dir%\%A_LoopFileName%\*.*
      {
        TV_Add(A_LoopFileName, ecb_snippet_tv_item, "Bold Sort")
      }
    }
    Gui, 5: Add, Button, gecb_snippet_menu_ok Hidden Default, OK
    Gui, 5: Show, X%ecb_snippet_menu_x% Y%ecb_snippet_menu_y% W%ecb_snippet_menu_w% H%ecb_snippet_menu_h%
       , ecb_snippet_gui
    WinSet, Transparent, 230, ecb_snippet_gui
    WinActivate, ahk_id %ecb_snippet_menu_wid%
    WinActivate, ecb_snippet_gui
    return

  5GuiEscape:
    IfWinNotActive, ahk_id %ecb_snippet_menu_wid%
      WinActivate, ahk_id %ecb_snippet_menu_wid%
    Gui, 5: Cancel
    Gui, 5: Destroy
    return

  ecb_snippet_menu_kp:
    if (A_GuiEvent = "S") {
      ecb_snippet_menu_fdir := TV_GetParent(A_EventInfo)
      if (ecb_snippet_menu_fdir = 0) {
        TV_Modify(ecb_snippet_menu_prev_sel, "-Expand")
        ecb_snippet_menu_prev_sel := A_EventInfo
        TV_Modify(A_EventInfo, "+Expand")
      }
    }
    if (A_GuiEvent = "DoubleClick") {
      GoSub, ecb_snippet_menu_edit
    }
    return

  ecb_snippet_menu_ok:
    TV_GetText(ecb_snippet_menu_fdir, TV_GetParent(TV_GetSelection()))
    TV_GetText(ecb_snippet_menu_fname, TV_GetSelection())
    ecb_snippet_file = %ecb_snippet_dir%\%ecb_snippet_menu_fdir%\%ecb_snippet_menu_fname%
    if (FileExist(ecb_snippet_file) = "D") {
      TV_Modify(TV_GetSelection(), "+Expand")
      return
    }
    IfWinNotActive, ahk_id %ecb_snippet_menu_wid%
      WinActivate, ahk_id %ecb_snippet_menu_wid%
    ClipboardSaved := Clipboard
    Gui, 5: Cancel
    Gui, 5: Destroy
    IfWinNotExist, ecb_snippet_meter
      Progress, 2:B2 ZH20 ZY10 W400 H40 CWBlack Y500 CBRed,,, ecb_snippet_meter
    Progress, 2:1
    Sleep, 250
    ecb_snippet_menu_str =
    ecb_snippet_menu_str_len = 0
    ecb_snippet_menu_pasted_len = 0
    FileGetSize, ecb_snippet_file_len, %ecb_snippet_file%
    Loop, read, %ecb_snippet_file%
    {
      ecb_snippet_menu_tmp = %A_LoopReadLine%
      StringLeft, ecb_snippet_menu_cmt, ecb_snippet_menu_tmp, 1
      if ecb_snippet_menu_cmt = #
        continue
      if ecb_snippet_menu_tmp =
        continue
      StringLen, ecb_snippet_menu_str_len, ecb_snippet_menu_str
      if ecb_snippet_menu_str_len >= 1000
      {
        WinActivate, ahk_id %ecb_snippet_menu_wid%
        WinWaitActive, ahk_id %ecb_snippet_menu_wid%,, 3
        if ErrorLevel != 0
        {
          SoundPlay, %ecb_sound_dir%\beep1.wav
          Clipboard := ClipboardSaved
          Sleep, 500
          Progress, 2:Off
          return
        }
        Clipboard := ecb_snippet_menu_str
        Sleep, 50
        Send, +{Insert}
        ecb_snippet_menu_pasted_len += ecb_snippet_menu_str_len
        ecb_snippet_menu_pasted_pct := (ecb_snippet_menu_pasted_len * 100) / ecb_snippet_file_len
        Progress, 2:%ecb_snippet_menu_pasted_pct%
        ecb_snippet_menu_str =
        ecb_snippet_menu_str_len = 0
      }
      ecb_snippet_menu_str = %ecb_snippet_menu_str%`n%ecb_snippet_menu_tmp%
    }
    WinActivate, ahk_id %ecb_snippet_menu_wid%
    WinWaitActive, ahk_id %ecb_snippet_menu_wid%,, 3
    if ErrorLevel != 0
    {
      SoundPlay, %ecb_sound_dir%\beep1.wav
      Clipboard := ClipboardSaved
      Sleep, 500
      Progress, 2:Off
      return
    }
    Progress, 2:100
    Clipboard := ecb_snippet_menu_str
    Sleep, 50
    Send, +{Insert}
    Sleep, 600
    Progress, 2:Off
    Clipboard := ClipboardSaved
    return

  ecb_snippet_menu_edit:
    TV_GetText(ecb_snippet_menu_fdir, TV_GetParent(TV_GetSelection()))
    TV_GetText(ecb_snippet_menu_fname, TV_GetSelection())
    ecb_snippet_file = %ecb_snippet_dir%\%ecb_snippet_menu_fdir%\%ecb_snippet_menu_fname%
    Gui, 5: Cancel
    Gui, 5: Destroy
    if (ecb_snippet_menu_fdir != "") {
      Run, edit %ecb_snippet_file%
      WinWaitActive, %ecb_snippet_menu_fname% ahk_class SciTEWindow,, 5
      if ErrorLevel = 0
        GoSub, ecb_grid_left2
    } else {
      Run, explorer.exe %ecb_snippet_dir%\%ecb_snippet_menu_fname%, %ecb_snippet_dir%\%ecb_snippet_menu_fname%
      Sleep, 100
      WinWaitActive, %ecb_snippet_menu_fname% ahk_class CabinetWClass,, 5
      if ErrorLevel = 0
        GoSub, ecb_grid_right1
    }
    return

; --- CALCULATOR HOTKEYS -------------------------------------------------------------------------

  !NumLock::
  RAlt & NumLock::
    IfWinNotExist, ahk_class SciCalc
      Run, calc.exe, %A_Desktop%
    Sleep, 300
    WinActivate, ahk_class SciCalc
    WinActivateBottom, ahk_class SciCalc
    IfWinActive, ahk_class SciCalc
    {
      GoSub, ecb_grid_right1
      WinSet, AlwaysOnTop, On, ahk_class SciCalc
    }
    return

; --- APPSKEY HOTKEY -----------------------------------------------------------------------------

  RAlt & /::
    CoordMode, Menu, Screen
    Menu, ecb_appskey_menu, Add, x, ecb_appskey_explorer
    Menu, ecb_appskey_menu, DeleteAll
    Menu, ecb_appskey_menu, Add, Z:\Dropbox\ibanes\CONEXOES, ecb_appskey_explorer
    Menu, ecb_appskey_menu, Add, Z:\Dropbox\ibanes\01-CONEXOES, ecb_appskey_explorer
    Menu, ecb_appskey_menu, Add, Z:\Dropbox\ibanes\atalhos, ecb_appskey_explorer
    Menu, ecb_appskey_menu, Add, c:\scite\scite.exe, ecb_appskey_explorer
    Menu, ecb_appskey_menu, Add, Z:\Dropbox\ibanes\atalhos, ecb_appskey_explorer
    Menu, ecb_appskey_menu, Add, Z:\Dropbox\ibanes\PLSQL Developer, ecb_appskey_explorer
    Menu, ecb_appskey_menu, Add, C:\oracle\product\12.2.0\client_1\network\admin\tnsnames.ora, ecb_appskey_explorer
    Menu, ecb_appskey_menu, Add

    ecb_appskey_menu_x := _mLeft +1000
    ecb_appskey_menu_y := _mTop + 10
    Menu, ecb_appskey_menu, Show, %ecb_appskey_menu_x%, %ecb_appskey_menu_y%

    return

  ecb_appskey_explorer:
    StringReplace, ecb_appskey_str, A_ThisMenuItem, &
    
    StringLen, pos_prev, ecb_appskey_str
    pos_prev += 1 ; Adjust to be the position after the last char.
    ; Search from the right for the Nth occurrence:
    StringGetPos, pos, ecb_appskey_str, \, R1
    length := pos_prev - pos - 1
    pos_prev := pos
    pos += 2  ; Adjust for use with StringMid.
    StringMid, path_component, ecb_appskey_str, %pos%, %length%
     
    IfWinExist, %path_component%
    {
       WinActivate, %path_component%
    } else {
       Run, explorer.exe "%ecb_appskey_str%", "%ecb_appskey_str%"
    }
    WinWaitActive, ahk_class CabinetWClass,, 3
    if ErrorLevel = 0
      GoSub, ecb_grid_right1
    return

  CapsLock & F12::
    ecb_wg_wid1=
    ecb_wg_wid2=
    ecb_wg_wid3=
    ecb_wg_wid4=
    ecb_wg_wid5=
    ecb_wg_wid6=
    ecb_wg_wid7=
    ecb_wg_wid8=
    ecb_wg_wid9=
    SoundPlay, %ecb_sound_dir%\shock1.wav
    return

  LControl & F12::
  RControl & F12::
    WinGet, ecb_wg_wid0, ID, A
    if (ecb_wg_wid0 = ecb_wg_wid1 || ecb_wg_wid0 = ecb_wg_wid2 || ecb_wg_wid0 = ecb_wg_wid3
      || ecb_wg_wid0 = ecb_wg_wid4 || ecb_wg_wid0 = ecb_wg_wid5 || ecb_wg_wid0 = ecb_wg_wid6
      || ecb_wg_wid0 = ecb_wg_wid7 || ecb_wg_wid0 = ecb_wg_wid8
      || ecb_wg_wid0 = ecb_wg_wid9) {
      SoundPlay, %ecb_sound_dir%\beep1.wav
      return
    }
    WinGetClass, ecb_wg_class0, ahk_id %ecb_wg_wid0%
    if (ecb_wg_class0 = "PuTTY") {
      ecb_wg_wid2=
      ecb_wg_wid3=
      ecb_wg_wid4=
      ecb_wg_wid5=
      ecb_wg_wid6=
      ecb_wg_wid7=
      ecb_wg_wid8=
      ecb_wg_wid9=
      if (ecb_wg_wid1 != "") {
        ecb_wg_wid1=
        SoundPlay, %ecb_sound_dir%\shock1.wav
        return
      }
      ecb_wg_wid1 := ecb_wg_wid0
      SoundPlay, %ecb_sound_dir%\beep3.wav
      return
    }
    if (ecb_wg_wid1 = "") {
      SoundPlay, %ecb_sound_dir%\beep2.wav
      return
    }
    if (ecb_wg_wid2 = "") {
      ecb_wg_wid2 := ecb_wg_wid0
    } else if (ecb_wg_wid3 = "") {
      ecb_wg_wid3 := ecb_wg_wid0
    } else if (ecb_wg_wid4 = "") {
      ecb_wg_wid4 := ecb_wg_wid0
    } else if (ecb_wg_wid5 = "") {
      ecb_wg_wid5 := ecb_wg_wid0
    } else if (ecb_wg_wid6 = "") {
      ecb_wg_wid6 := ecb_wg_wid0
    } else if (ecb_wg_wid7 = "") {
      ecb_wg_wid7 := ecb_wg_wid0
    } else if (ecb_wg_wid8 = "") {
      ecb_wg_wid8 := ecb_wg_wid0
    } else if (ecb_wg_wid9 = "") {
      ecb_wg_wid9 := ecb_wg_wid0
    } else {
      SoundPlay, %ecb_sound_dir%\beep2.wav
      return
    }
    SoundPlay, %ecb_sound_dir%\beep4.wav
    return

  F12::
    if (ecb_wg_wid1 = "") {
      SoundPlay, %ecb_sound_dir%\beep2.wav
      return
    }
    IfWinNotExist, ahk_id %ecb_wg_wid1%
    {
      ecb_wg_wid1=
      ecb_wg_wid2=
      ecb_wg_wid3=
      ecb_wg_wid4=
      ecb_wg_wid5=
      ecb_wg_wid6=
      ecb_wg_wid7=
      ecb_wg_wid8=
      ecb_wg_wid9=
      SoundPlay, %ecb_sound_dir%\beep2.wav
      return
    }
    WinGet, ecb_wg_wid0, ID, A
    if (ecb_wg_wid0 = ecb_wg_wid1) {
      if (ecb_wg_wid2 != "") {
        IfWinExist, ahk_id %ecb_wg_wid2%
        {
          WinActivate, ahk_id %ecb_wg_wid2%
          return
        }
        ecb_wg_wid2=
      }
    }
    if (ecb_wg_wid0 = ecb_wg_wid2) {
      if (ecb_wg_wid3 != "") {
        IfWinExist, ahk_id %ecb_wg_wid3%
        {
          WinActivate, ahk_id %ecb_wg_wid3%
          return
        }
        ecb_wg_wid3=
      }
    }
    if (ecb_wg_wid0 = ecb_wg_wid3) {
      if (ecb_wg_wid4 != "") {
        IfWinExist, ahk_id %ecb_wg_wid4%
        {
          WinActivate, ahk_id %ecb_wg_wid4%
          return
        }
        ecb_wg_wid4=
      }
    }
    if (ecb_wg_wid0 = ecb_wg_wid4) {
      if (ecb_wg_wid5 != "") {
        IfWinExist, ahk_id %ecb_wg_wid5%
        {
          WinActivate, ahk_id %ecb_wg_wid5%
          return
        }
        ecb_wg_wid5=
      }
    }
    if (ecb_wg_wid0 = ecb_wg_wid5) {
      if (ecb_wg_wid6 != "") {
        IfWinExist, ahk_id %ecb_wg_wid6%
        {
          WinActivate, ahk_id %ecb_wg_wid6%
          return
        }
        ecb_wg_wid6=
      }
    }
    if (ecb_wg_wid0 = ecb_wg_wid6) {
      if (ecb_wg_wid7 != "") {
        IfWinExist, ahk_id %ecb_wg_wid7%
        {
          WinActivate, ahk_id %ecb_wg_wid7%
          return
        }
        ecb_wg_wid7=
      }
    }
    if (ecb_wg_wid0 = ecb_wg_wid7) {
      if (ecb_wg_wid8 != "") {
        IfWinExist, ahk_id %ecb_wg_wid8%
        {
          WinActivate, ahk_id %ecb_wg_wid8%
          return
        }
        ecb_wg_wid8=
      }
    }
    if (ecb_wg_wid0 = ecb_wg_wid8) {
      if (ecb_wg_wid9 != "") {
        IfWinExist, ahk_id %ecb_wg_wid9%
        {
          WinActivate, ahk_id %ecb_wg_wid9%
          return
        }
        ecb_wg_wid9=
      }
    }
    WinActivate, ahk_id %ecb_wg_wid1%
    return

  #IfWinActive ahk_class SciTEWindow
    LControl & Enter::
    RControl & Enter::
      if (ecb_wg_wid1 = "") {
        SoundPlay, %ecb_sound_dir%\beep2.wav
        return
      }
      IfWinNotExist, ahk_id %ecb_wg_wid1%
      {
        ecb_wg_wid1=
        ecb_wg_wid2=
        ecb_wg_wid3=
        ecb_wg_wid4=
        ecb_wg_wid5=
        ecb_wg_wid6=
        ecb_wg_wid7=
        ecb_wg_wid8=
        ecb_wg_wid9=
        SoundPlay, %ecb_sound_dir%\beep1.wav
        return
      }
      WinGet, ecb_wg_wid0, ID, A
      WinGetClass, ecb_wg_class0, ahk_id %ecb_wg_wid0%
      if (ecb_wg_class0 != "SciTEWindow") {
        SoundPlay, %ecb_sound_dir%\beep2.wav
        return
      }
      if (ecb_wg_wid0 != ecb_wg_wid1 && ecb_wg_wid0 != ecb_wg_wid2
        && ecb_wg_wid0 != ecb_wg_wid3 && ecb_wg_wid0 != ecb_wg_wid4
        && ecb_wg_wid0 != ecb_wg_wid5 && ecb_wg_wid0 != ecb_wg_wid6
        && ecb_wg_wid0 != ecb_wg_wid7 && ecb_wg_wid0 != ecb_wg_wid8
        && ecb_wg_wid0 != ecb_wg_wid9) {
        if (ecb_wg_wid2 = "") {
          ecb_wg_wid2 := ecb_wg_wid0
        } else if (ecb_wg_wid3 = "") {
          ecb_wg_wid3 := ecb_wg_wid0
        } else if (ecb_wg_wid4 = "") {
          ecb_wg_wid4 := ecb_wg_wid0
        } else if (ecb_wg_wid5 = "") {
          ecb_wg_wid5 := ecb_wg_wid0
        } else if (ecb_wg_wid6 = "") {
          ecb_wg_wid6 := ecb_wg_wid0
        } else if (ecb_wg_wid7 = "") {
          ecb_wg_wid7 := ecb_wg_wid0
        } else if (ecb_wg_wid8 = "") {
          ecb_wg_wid8 := ecb_wg_wid0
        } else if (ecb_wg_wid9 = "") {
          ecb_wg_wid9 := ecb_wg_wid0
        }
        SoundPlay, %ecb_sound_dir%\beep4.wav
      }
      ecb_aw_prev_wid := ecb_wg_wid0
      ClipboardSaved := Clipboard
      Sleep, 100
      SendInput, ^c
      Sleep, 100
      ecb_wg_txt := Clipboard
      Sleep, 150
      IfWinNotExist, ecb_wg_meter
        Progress, 3:B2 ZH20 ZY10 W400 H40 CWBlack Y500 CBRed,,, ecb_wg_meter
      Progress, 3:1
      StringReplace, ecb_wg_txt, ecb_wg_txt, `r`n, `n, All
      StringReplace, ecb_wg_txt, ecb_wg_txt, `r, `n, All
      StringLen, ecb_wg_txt_len, ecb_wg_txt
      ecb_wg_str =
      ecb_wg_str_len = 0
      ecb_wg_pasted_len = 0
      Loop, Parse, ecb_wg_txt, `n
      {
        ecb_wg_tmp := A_LoopField
        StringLen, ecb_wg_str_len, ecb_wg_str
        if ecb_wg_str_len >= 150
        {
          WinActivate, ahk_id %ecb_wg_wid1%
          WinWaitActive, ahk_id %ecb_wg_wid1%,, 3
          if ErrorLevel != 0
          {
            SoundPlay, %ecb_sound_dir%\beep1.wav
            Clipboard := ClipboardSaved
            Sleep, 500
            Progress, 3:Off
            return
          }
          Clipboard := ecb_wg_str
          Sleep, 50
          Send, +{Insert}

          ecb_wg_pasted_len += ecb_wg_str_len
          ecb_wg_pasted_pct := (ecb_wg_pasted_len * 100) / ecb_wg_txt_len
          Progress, 3:%ecb_wg_pasted_pct%

          ecb_wg_str =
          ecb_wg_str_len = 0
        }
        ecb_wg_str .= ecb_wg_tmp
        ecb_wg_str .= "`n"
      }
      WinActivate, ahk_id %ecb_wg_wid1%
      WinWaitActive, ahk_id %ecb_wg_wid1%,, 3
      if ErrorLevel != 0
      {
        SoundPlay, %ecb_sound_dir%\beep1.wav
        Clipboard := ClipboardSaved
        Sleep, 500
        Progress, 3:Off
        return
      }
      StringTrimRight, ecb_wg_str, ecb_wg_str, 1
      Clipboard := ecb_wg_str
      Sleep, 50
      Send, +{Insert}
      Progress, 3:100
      Sleep, 600
      Clipboard := ClipboardSaved
      Progress, 3:Off
      return
  #IfWinActive



; --- MISC TWEAKS --------------------------------------------------------------------------------

  ;; nao remover o atalho a seguir, pois eh com ele que a tecla do windows
  ;; continua funcionando para os atalhos padroes do windows...

  ;LWin & ScrollLock::
  ;  Drive, Eject,,
  ;  return

; --- EoF ----------------------------------------------------------------------------------------
