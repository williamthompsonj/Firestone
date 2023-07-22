;------------------------------------------------------------------------------
; Copyright (c) William J. Thompson
; 22 July 2023 @ 08:30AM PST
;
; Automate some of Firestone Idle RPG by R2 games. Run in full-screen mode, any resolution.
;
; Use the ` key (backtick) to activate and = key (equals) to deactivate
;
; Actions this script performs:
; -----------------------------
; - Upgrade special, guardian, all heroes
; - Train guardian (Free)
; - Collect map missions (does not start new ones)
; - (Level 50+) Collect pickaxes
; - (Level 50+) Claim campaign bonus
;------------------------------------------------------------------------------

;----------------------------
; set to false if below lv 50
;----------------------------
AboveLv50 := true

;----------------------------
; Title of the game window
;----------------------------
WindowTitle := "Firestone"

; use this title if playing on Kongregate
;WindowTitle := "Play Firestone Idle RPG"


#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

RunScript := false
TinyLoop := 0
BigLoop := 0
Max_TinyLoop := 8
Max_BigLoop := 150

; middle of screen (path for beer dragon and meteor guy)
x_middle_screen := 0
y_middle_screen := 0

; close button (full screen window)
x_close_full := 0
y_close_full := 0

; upgrade special
x_upgrade_special := 0
y_upgrade_special := 0

; upgrade guardian
x_upgrade_guard := 0
y_upgrade_guard := 0

; upgrade hero #1
x_upgrade_hero1 := 0
y_upgrade_hero1 := 0

; upgrade hero #2
x_upgrade_hero2 := 0
y_upgrade_hero2 := 0

; upgrade hero #3
x_upgrade_hero3 := 0
y_upgrade_hero3 := 0

; upgrade hero #4
x_upgrade_hero4 := 0
y_upgrade_hero4 := 0

; upgrade hero #5
x_upgrade_hero5 := 0
y_upgrade_hero5 := 0

; train guardian (magic quarter)
x_train := 0
y_train := 0

; guild button on main page
x_guild := 0
y_guild := 0

; guild shop
x_guild_shop := 0
y_guild_shop := 0

; guild shop supplies
x_guild_shop_supplies := 0
y_guild_shop_supplies := 0

; guild shop pickaxes
x_guild_shop_pickaxes := 0
y_guild_shop_pickaxes := 0

; guild expedition button
x_exped := 0
y_exped := 0

; map claim button
x_map_claim := 0
y_map_claim := 0

; map okay button
x_map_okay := 0
y_map_okay := 0

; campaign button on map
x_campaign := 0
y_campaign := 0

; claim campaign award button
x_campaign_claim := 0
y_campaign_claim := 0

;----------------------------------------------------------
; Activate when user presses ` key (backtick)
;----------------------------------------------------------
`::
RunScript := true
BigLoop := Floor(Max_BigLoop / 2) ; keep track of how many cycles we've done

if WinExist(WindowTitle)
{
  ;----------------------------
  ; environment variables
  ;----------------------------

  WinActivate
  WinGetPos, Xpos, Ypos, wide, high

  ; middle of the screen (beer dragon and meteor guy path)
  x_middle_screen := Floor(wide * 0.42)
  y_middle_screen := Floor(high * 0.30)

  ; normal close button
  x_close_full := Floor(wide * 0.958)
  y_close_full := Floor(high * 0.052)

  ; upgrade special button
  x_upgrade_special := Floor(wide * 0.92)
  y_upgrade_special := Floor(high * 0.20)

  ; upgrade guardian button
  x_upgrade_guard := Floor(wide * 0.92)
  y_upgrade_guard := Floor(high * 0.31)

  ; upgrade hero #1 button
  x_upgrade_hero1 := Floor(wide * 0.92)
  y_upgrade_hero1 := Floor(high * 0.41)

  ; upgrade hero #2 button
  x_upgrade_hero2 := Floor(wide * 0.92)
  y_upgrade_hero2 := Floor(high * 0.52)

  ; upgrade hero #3 button
  x_upgrade_hero3 := Floor(wide * 0.92)
  y_upgrade_hero3 := Floor(high * 0.62)

  ; upgrade hero #4 button
  x_upgrade_hero4 := Floor(wide * 0.92)
  y_upgrade_hero4 := Floor(high * 0.73)

  ; upgrade hero #5 button
  x_upgrade_hero5 := Floor(wide * 0.92)
  y_upgrade_hero5 := Floor(high * 0.83)

  ; train guardian (magic quarter)
  x_train := Floor(wide * 0.60)
  y_train := Floor(high * 0.73)

  ; guild button on main screen
  x_guild := Floor(wide * 0.96)
  y_guild := Floor(high * 0.43)

  ; guild shop
  x_guild_shop := Floor(wide * 0.325)
  y_guild_shop := Floor(high * 0.237)

  ; guild shop supplies
  x_guild_shop_supplies := Floor(wide * 0.091)
  y_guild_shop_supplies := Floor(high * 0.722)

  ; guild shop pickaxes
  x_guild_shop_pickaxes := Floor(wide * 0.367)
  y_guild_shop_pickaxes := Floor(high * 0.444)

  ; expedition tent in guild screen
  x_exped := Floor(wide * 0.14)
  y_exped := Floor(high * 0.35)

  ; expedition button complete/start
  x_exped_button := Floor(wide * 0.69)
  y_exped_button := Floor(high * 0.30)

  ; map claim button
  x_map_claim := Floor(wide * 0.10)
  y_map_claim := Floor(high * 0.30)

  ; map okay button
  x_map_okay := Floor(wide * 0.498) ;956
  y_map_okay := Floor(high * 0.435) ;470


  ; campaign button on the map
  x_campaign := Floor(wide * 0.96)
  y_campaign := Floor(high * 0.57)

  ; campaign button on the map
  x_campaign_claim := Floor(wide * 0.11)
  y_campaign_claim := Floor(high * 0.91)
}
else
{
  MsgBox, "Firestone is not running"
  return
}

;----------------------------
; Main clicker loop
;----------------------------
Loop
{
  if (RunScript == false)
    break

  if (TinyLoop > Max_TinyLoop)
  {
    ;----------------------------
    ; special upgrade button
    ;----------------------------
    Click, %x_upgrade_special%, %y_upgrade_special%
    Send {U}
    TinyLoop := 0
  }
  else
  {
    ;----------------------------
    ; click middle of the screen
    ;----------------------------
    Click, %x_middle_screen%, %y_middle_screen%
    TinyLoop += 1
  }
  Sleep 120
  Send {3} ; keep party leader ability #3 active

  ;----------------------------
  ; approx. every ~18 seconds
  ;----------------------------
  if (BigLoop > Max_BigLoop)
  {
    BigLoop := 0

    ;----------------------------
    ; train guardian (free)
    ;----------------------------
    Send {G}
    Sleep 500
    Click, %x_train%, %y_train%
    Sleep 500
    Click, %x_close_full%, %y_close_full%
    Sleep 500

    if (RunScript == false)
      break

    ;----------------------------
    ; guild expeditions
    ;----------------------------
    Click, %x_guild%, %y_guild%
    Sleep 200
    Click, %x_exped%, %y_exped%
    Sleep 200
    Click, %x_exped_button%, %y_exped_button%
    Sleep 200
    Click, %x_exped_button%, %y_exped_button%
    Sleep 200
    Click, %wide%, %high%
    Sleep 200

    ;----------------------------
    ; collect free pickaxes
    ;----------------------------
    if (AboveLv50 == true)
    {
      Click, %x_guild_shop%, %y_guild_shop%
      Sleep 200
      Click, %x_guild_shop_supplies%, %y_guild_shop_supplies%
      Sleep 200
      Click, %x_guild_shop_pickaxes%, %y_guild_shop_pickaxes%
      Sleep 200
      Click, %x_close_full%, %y_close_full%
      Sleep 200
    }

    ;----------------------------
    ; close guild window
    ;----------------------------
    Click, %x_close_full%, %y_close_full%
    Sleep 200

    if (RunScript == false)
      break

    ;----------------------------
    ; claim map mission on top
    ;----------------------------
    Send {M}
    Sleep 200
    Click, %x_map_claim%, %y_map_claim%
    Sleep 200
    Click, %x_map_okay%, %y_map_okay%
    Sleep 200

    ;----------------------------
    ; claim campaign bonus
    ;----------------------------
    if (AboveLv50 == true)
    {
      Click, %x_campaign%, %y_campaign%
      Sleep 200
      Click, %x_campaign_claim%, %y_campaign_claim%
      Sleep 200
    }

    Click, %x_close_full%, %y_close_full%
    Sleep 200

    if (RunScript == false)
      break

    ;----------------------------
    ; upgrade guardian and heroes
    ;----------------------------
    Send {U}
    Sleep 200
    Click, %x_upgrade_special%, %y_upgrade_special%
    Sleep 200
    Click, %x_upgrade_guard%, %y_upgrade_guard%
    Sleep 200
    Click, %x_upgrade_hero1%, %y_upgrade_hero1%
    Sleep 200
    Click, %x_upgrade_hero2%, %y_upgrade_hero2%
    Sleep 200
    Click, %x_upgrade_hero3%, %y_upgrade_hero3%
    Sleep 200
    Click, %x_upgrade_hero4%, %y_upgrade_hero4%
    Sleep 200
    Click, %x_upgrade_hero5%, %y_upgrade_hero5%
    Sleep 200
    Send {U}
    Sleep 200
  }
  else
  {
    ; keep counting
    BigLoop += 1
  }
}
return

;----------------------------------------------------------
; Stop when user presses = key (equals)
;----------------------------------------------------------
=::
if WinExist(WindowTitle)
{
  ;----------------------------
  ; stop the main clicker loop
  ;----------------------------
  RunScript := false
}
else
{
  MsgBox, "Firestone is not running"
}
return