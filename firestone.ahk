;------------------------------------------------------------------------------
; Copyright (c) William J. Thompson
; 23 July 2023 @ 02:33PM PST
;
; Automate some of Firestone Idle RPG by R2 games. Run in full-screen mode, any resolution.
;
; Use the Ctrl+` key (Ctrl+backtick) to activate and ` key (backtick by itself) to deactivate
;
; Actions this script performs:
; -----------------------------
; - Upgrade special, guardian, all heroes
; - Train guardian (Free)
; - Collect map missions (does not start new ones)
; - Collect daily mystery box and daily check-in (once after 10am)
; - Play tavern beer gave every 2 hours
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
;WindowTitle := "Play Firestone"

;----------------------------
; collect daily mystery gift and check-in
; after 10am occurs
;
; NOTE: will only collect if running when
; 10am occurs, otherwise will wait until
; next day.
;----------------------------
DailyCollect := true
DailyReady := false

;----------------------------
; play tavern every 2 hours
;----------------------------
TavernPlay := true
TavernReady := false

;----------------------------
; daily and weekly quest claim
;----------------------------
QuestCollect := true
QuestReady := false

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

RunScript := false
TinyLoop := 0
BigLoop := 0
Max_TinyLoop := 9
Max_BigLoop := 150

;----------------------------------------------------------
; Stop when user presses = key (equals)
;----------------------------------------------------------
`::
if not WinExist(WindowTitle)
{
  MsgBox, "Cannot find Firestone"
}

RunScript := false
return

;----------------------------------------------------------
; Activate when user presses ` key (backtick)
;----------------------------------------------------------
^`::
if WinExist(WindowTitle)
{
  ; find and focus on Firestone window
  WinActivate
  WinGetPos, Xpos, Ypos, wide, high
}
else
{
  MsgBox, "Cannot find Firestone"
  return
}

;----------------------------
; setup everything to run
;----------------------------

; script is running
RunScript := true

; keep track of how many cycles we've done, start half way
BigLoop := Floor(Max_BigLoop / 2)

; middle of the screen (beer dragon and meteor guy path)
x_middle_screen := Floor(wide * 0.42)
y_middle_screen := Floor(high * 0.30)

; normal close button
x_close_full := Floor(wide * 0.958)
y_close_full := Floor(high * 0.052)

; inset close button
x_close_inset := Floor(wide * 0.924)
y_close_inset := Floor(high * 0.081)

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

; shop button in town
x_shop := Floor(wide * 0.96)
y_shop := Floor(high * 0.55)

; shop mystery gift
x_shop_gift := Floor(wide * 0.35)
y_shop_gift := Floor(high * 0.60)

; shop calendar tab
x_shop_calendar := Floor(wide * 0.737)
y_shop_calendar := Floor(high * 0.100)

; shop check-in button on calendar
x_shop_checkin := Floor(wide * 0.705)
y_shop_checkin := Floor(high * 0.801)

; tavern in town
x_tavern := Floor(wide * 0.396)
y_tavern := Floor(high * 0.889)

; tavern get token / play 10 button
x_tavern_get := Floor(wide * 0.563)
y_tavern_get := Floor(high * 0.926)

; tavern get token / play 10 button
x_tavern_play5 := Floor(wide * 0.599)
y_tavern_play5 := Floor(high * 0.926)

; tavern get game tokens button
x_tavern_tokens := Floor(wide * 0.182)
y_tavern_tokens := Floor(high * 0.509)

; tavern get game tokens button
x_tavern_card := Floor(wide * 0.5)
y_tavern_card := Floor(high * 0.7)

; quest daily button
x_quest_daily := Floor(wide * 0.375)
y_quest_daily := Floor(high * 0.129)

; quest weekly button
x_quest_weekly := Floor(wide * 0.589)
y_quest_weekly := Floor(high * 0.129)

; quest claim button
x_quest_claim := Floor(wide * 0.807)
y_quest_claim := Floor(high * 0.284)

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
x_map_okay := Floor(wide * 0.500)
y_map_okay := Floor(high * 0.435)

; campaign button on the map
x_campaign := Floor(wide * 0.96)
y_campaign := Floor(high * 0.57)

; campaign button on the map
x_campaign_claim := Floor(wide * 0.11)
y_campaign_claim := Floor(high * 0.91)

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
    Send {u} ; toggle upgrade pane
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
  ; collect daily mystery box and check-in
  ;----------------------------
  if (DailyCollect == true)
  {
    Send {space down}
    if(A_Hour == 10 && DailyReady == true)
    {
      DailyReady == false
      Click, %x_shop%, %y_shop%
      Sleep 200
      Click, %x_shop_gift%, %y_shop_gift%
      Sleep 200
      Click, %x_shop_calendar%, %y_shop_calendar%
      Sleep 200
      Click, %x_shop_checkin%, %y_shop_checkin%
      Sleep 200
      Click, %x_close_full%, %y_close_full%
      Sleep 200
    }
    else if (A_Time != 10)
    {
      DailyReady == true
    }
    Send {space up}
  }

  ;----------------------------
  ; play tavern games
  ;----------------------------
  if (TavernPlay == true)
  {
    Send {space down}
    if(Mod(A_Hour, 2) == 0 && TavernReady == true)
    {
      TavernReady == false
      Send {t}
      Sleep 200
      Click, %x_tavern%, %y_tavern%
      Sleep 200
      Click, %x_tavern_get%, %y_tavern_get%
      Sleep 200
      Click, %x_tavern_tokens%, %y_tavern_tokens%
      Sleep 2000
      Click, %wide%, %high%
      Sleep 200
      Click, %x_tavern_play5%, %y_tavern_play5%
      Sleep 2500
      Click, %x_tavern_card%, %y_tavern_card%
      Sleep 5000
      Click, %x_close_full%, %y_close_full%
      Sleep 200
      Click, %x_close_full%, %y_close_full%
      Sleep 200
    }
    else if (Mod(A_Hour, 2) == 0)
    {
      TavernReady == true
    }
    Send {space up}
  }

  ;----------------------------
  ; daily and weekly quests
  ;----------------------------
  if (QuestCollect == true)
  {
    Send {space down}
    if(Mod(A_Hour, 2) == 0 && QuestReady == true)
    {
      QuestReady == false
      Send {q}
      Sleep 200
      Click, %x_quest_daily%, %y_quest_daily%
      Sleep 200
      Click, %x_quest_claim%, %y_quest_claim%
      Sleep 200
      Click, %x_quest_weekly%, %y_quest_weekly%
      Sleep 200
      Click, %x_quest_claim%, %y_quest_claim%
      Sleep 200
      Click, %x_close_inset%, %y_close_inset%
      Sleep 200
    }
    else if (Mod(A_Hour, 2) == 0)
    {
      QuestReady == true
    }
    Send {space up}
  }

  ;----------------------------
  ; approx. every ~18 seconds
  ;----------------------------
  if (BigLoop > Max_BigLoop)
  {
    BigLoop := 0

    ;----------------------------
    ; claim map mission on top
    ;----------------------------
    Send {space down}
    Send {m}
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
    Send {space up}

    if (RunScript == false)
      break

    ;----------------------------
    ; guild expeditions
    ;----------------------------
    Send {space down}
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
    Send {space up}

    if (RunScript == false)
      break

    ;----------------------------
    ; train guardian (free)
    ;----------------------------
    Send {space down}
    Send {g}
    Sleep 500
    Click, %x_train%, %y_train%
    Sleep 500
    Click, %x_close_full%, %y_close_full%
    Sleep 500
    Send {space up}

    if (RunScript == false)
      break

    ;----------------------------
    ; upgrade guardian and heroes
    ;----------------------------
    Send {space down}
    Send {u}
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
    Send {u}
    Sleep 200
    Send {space up}
  }
  else
  {
    ; keep counting
    BigLoop += 1
  }
}
return