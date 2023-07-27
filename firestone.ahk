;------------------------------------------------------------------------------
; Copyright (c) William J. Thompson
; 27 July 2023 @ 00:00am PST
;
; Automate boring bits of Firestone Idle RPG by Holiday Games.
; https://holydaygames.com/firestone-idle-rpg/
;
; Run in full-screen mode, any resolution.
;
; Use the Ctrl+` key (Ctrl+backtick) to activate and ` key (backtick by itself) to deactivate
;
; Actions this script performs:
; -----------------------------
; - Upgrade special, guardian, all heroes
; - Train guardian (Free)
; - Collect map missions (does not start new ones)
; - Collect daily mystery box and daily check-in (once after 10am)
; - Play tavern beer games every 6 hours
; - Claim daily & weekly quests
; - Collect Firestone research (does not start new ones)
; - (Level 50+) Collect pickaxes
; - (Level 50+) Claim campaign bonus
; - (Level 120+) Collect Alchemist research (does not start new ones)
;------------------------------------------------------------------------------

;----------------------------
; Title of the game window
;----------------------------
WindowTitle := "Firestone"

; Kongregate website title
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
; play tavern games
;----------------------------
TavernPlay := true
TavernReady := false
TavernPeriod := 6

;----------------------------
; daily and weekly quest claim
;----------------------------
QuestCollect := true
QuestReady := false
QuestPeriod := 3

;----------------------------
; collect research
;----------------------------
ResearchCollect := true
ResearchReady := true
ResearchPeriod := 5 ; minutes

;----------------------------
; will change automatically
;----------------------------
AboveLv50 := false
AboveLv120 := false

TinyBlock := 0
BigBlock := 0
Max_TinyBlock := 8 ; cycles between open/close upgrade panel
Max_BigBlock := 20 ; minimum seconds between big block run time
BigBlockMark := 0 ; current time in seconds
StopScript := true ; default is true

ColorOrange := { r:237, g:145, b:64 }
ColorGreen := { r:10, g:160, b:8 }
ColorTeal := { r:27, g:112, b:159 }
ColorBrown := { r:127, g:94, b:41 }
ColorGray := { r:190, g:190, b:190 }

#SingleInstance force ; silently kill any other instance and start new one
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;----------------------------------------------------------
; Stop when user presses ` key (backtick)
;----------------------------------------------------------
`::
if !WinExist(WindowTitle)
{
  ExitApp
}

StopScript := true
return

;----------------------------------------------------------
; Activate when user presses ` key (backtick)
;----------------------------------------------------------
^`::
; find and focus on Firestone window
if WinExist(WindowTitle)
{
  WinActivate
  WinGetPos, , , wide, high
}
else
{
  MsgBox, "Cannot find Firestone"
  return
}

;----------------------------
; setup everything to run
;----------------------------

; count seconds since last BigBlock occurred
DllCall("QueryPerformanceCounter", "UInt64*", BigBlockMark)

; script is running
StopScript := false

; screen coordinates of things
middle_screen := {x:Floor(wide * 0.42), y:Floor(high * 0.30)}
close_full := {x:Floor(wide * 0.958), y:Floor(high * 0.052)}
close_inset := {x:Floor(wide * 0.924), y:Floor(high * 0.081)}
upgrade_special := {x:Floor(wide * 0.981), y:Floor(high * 0.207)}
upgrade_guard := {x:Floor(wide * 0.981), y:Floor(high * 0.31)}
upgrade_hero1 := {x:Floor(wide * 0.981), y:Floor(high * 0.41)}
upgrade_hero2 := {x:Floor(wide * 0.981), y:Floor(high * 0.52)}
upgrade_hero3 := {x:Floor(wide * 0.981), y:Floor(high * 0.62)}
upgrade_hero4 := {x:Floor(wide * 0.981), y:Floor(high * 0.73)}
upgrade_hero5 := {x:Floor(wide * 0.981), y:Floor(high * 0.83)}
train_guardian := {x:Floor(wide * 0.54), y:Floor(high * 0.74)}
shop_button := {x:Floor(wide * 0.96), y:Floor(high * 0.55)}
shop_gift := {x:Floor(wide * 0.35), y:Floor(high * 0.60)}
shop_calendar := {x:Floor(wide * 0.737), y:Floor(high * 0.100)}
shop_checkin := {x:Floor(wide * 0.705), y:Floor(high * 0.801)}
tavern_icon := {x:Floor(wide * 0.406), y:Floor(high * 0.861)}
tavern_market := {x:Floor(wide * 0.903), y:Floor(high * 0.074)}
tavern_tokens := {x:Floor(wide * 0.343), y:Floor(high * 0.407)}
tavern_play := {x:Floor(wide * 0.599), y:Floor(high * 0.926)}
tavern_card := {x:Floor(wide * 0.5), y:Floor(high * 0.7)}
quest_daily := {x:Floor(wide * 0.375), y:Floor(high * 0.129)}
quest_weekly := {x:Floor(wide * 0.589), y:Floor(high * 0.129)}
quest_claim1 := {x:Floor(wide * 0.744), y:Floor(high * 0.296)}
quest_claim2 := {x:Floor(wide * 0.744), y:Floor(high * 0.463)}
guild_button := {x:Floor(wide * 0.96), y:Floor(high * 0.43)}
guild_shop := {x:Floor(wide * 0.325), y:Floor(high * 0.237)}
guild_shop_supplies := {x:Floor(wide * 0.130), y:Floor(high * 0.712)}
guild_shop_pickaxes := {x:Floor(wide * 0.357), y:Floor(high * 0.394)}
expeditions := {x:Floor(wide * 0.14), y:Floor(high * 0.35)}
exped_button := {x:Floor(wide * 0.659), y:Floor(high * 0.300)}
map_claim := {x:Floor(wide * 0.10), y:Floor(high * 0.30)}
map_okay := {x:Floor(wide * 0.567), y:Floor(high * 0.453)}
map_free := {x:Floor(wide * 0.585), y:Floor(high * 0.903)}
campaign_button := {x:Floor(wide * 0.96), y:Floor(high * 0.57)}
campaign_claim := {x:Floor(wide * 0.11), y:Floor(high * 0.91)}

check50 := {x:Floor(wide * 0.190), y:Floor(high * 0.272)}
check120 := {x:Floor(wide * 0.246), y:Floor(high * 0.805)} ; 474 x 870
alchemist_blood := {x:Floor(wide * 0.464), y:Floor(high * 0.762)}
alchemist_dust := {x:Floor(wide * 0.660), y:Floor(high * 0.762)}
alchemist_coin := {x:Floor(wide * 0.853), y:Floor(high * 0.762)}
library_icon := {x:Floor(wide * 0.172), y:Floor(high * 0.611)}
firestone_research := {x:Floor(wide * 0.95), y:Floor(high * 0.90)}
firestone_1 := {x:Floor(wide * 0.263), y:Floor(high * 0.898)}
firestone_2 := {x:Floor(wide * 0.599), y:Floor(high * 0.898)} ; 1150 x 970

;----------------------------
; Main clicker loop
;----------------------------
Loop
{
  if (StopScript)
    break

  if (TinyBlock >= Max_TinyBlock)
  {
    ;----------------------------
    ; special upgrade button
    ;----------------------------
    ClickPoint(upgrade_special, ColorGreen)
    Send {u} ; toggle upgrade pane
    TinyBlock := 0
  }
  else
  {
    ;----------------------------
    ; middle of the screen
    ;----------------------------
    ClickPoint(middle_screen, false, 0)
    TinyBlock += 1
  }
  Sleep 120
  Send {3} ; keep party leader ability #3 active

  if (StopScript)
    break

  ;----------------------------
  ; daily mystery box & check-in
  ;----------------------------
  if (DailyCollect)
  {
    if(DailyReady && A_Hour == 10)
    {
      Send {space down}
      DailyReady := false
      ClickPoint(shop_button)
      ClickPoint(shop_gift)
      ClickPoint(shop_calendar)
      ClickPoint(shop_checkin)
      ClickPoint(close_full)
      Send {space up}
    }
    else if (not DailyReady && A_Hour != 10)
    {
      DailyReady := true
    }
  }

  ;----------------------------
  ; collect finished research
  ;----------------------------
  if (ResearchCollect)
  {
    if(ResearchReady && !Mod(A_Min, ResearchPeriod))
    {
      ResearchReady := false

      Send {space down}
      Send {t}
      Sleep 200
      TestColor := GetColorAt(check120.x, check120.y)
      if(!CompareColors(TestColor, ColorGray))
      {
        AboveLv120 := true
        AboveLv50 := true
      }
      else
      {
        AboveLv120 := false
      }
      TestColor := GetColorAt(check50.x, check50.y)
      if(!CompareColors(TestColor, ColorGray))
      {
        AboveLv50 := true
      }
      else
      {
        AboveLv50 := false
      }

      ; collect alchemist research
      if (AboveLv120)
      {
        ClickPoint(check120)
        ClickPoint(alchemist_blood, ColorOrange)
        ClickPoint(alchemist_blood, ColorGreen)
        ClickPoint(alchemist_dust, ColorOrange)
        ClickPoint(alchemist_dust, ColorGreen)
        ClickPoint(alchemist_coin, ColorOrange)
        ClickPoint(alchemist_coin, ColorGreen)
        ClickPoint(close_full)
      }

      ; collect library research
      ClickPoint(library_icon)
      ClickPoint(firestone_2, ColorGreen)
      ClickPoint(firestone_2, ColorOrange)
      ClickPoint(firestone_1, ColorGreen)
      ClickPoint(firestone_1, ColorOrange)
      ClickPoint(close_full)
      ClickPoint(close_full)
      Send {space up}
    }
    else if (!ResearchReady && Mod(A_Min, ResearchPeriod))
    {
      ResearchReady := true
    }
  }

  if (StopScript)
    break

  ;----------------------------
  ; tavern games
  ;----------------------------
  if (TavernPlay)
  {
    if(TavernReady && !Mod(A_Hour, TavernPeriod))
    {
      Send {space down}
      TavernReady := false
      Send {t}
      Sleep 200
      ClickPoint(tavern_icon)
      TestColor := GetColorAt(tavern_play.x, tavern_play.y)
      if(CompareColors(TestColor, ColorGreen))
      {
        ClickPoint(tavern_play, false, 2500)
        ClickPoint(tavern_card, false, 5000)
      }
      else
      {
        ClickPoint(tavern_market)
        ClickPoint(tavern_tokens, ColorTeal)
        ClickPoint(close_inset)
      }
      TestColor := GetColorAt(tavern_play.x, tavern_play.y)
      if(CompareColors(TestColor, ColorGreen))
      {
        ClickPoint(tavern_play, false, 2500)
        ClickPoint(tavern_card, false, 5000)
      }
      ClickPoint(close_full)
      ClickPoint(close_full)
      Send {space up}
    }
    else if (!TavernReady && Mod(A_Hour, TavernPeriod))
    {
      TavernReady := true
    }
  }

  if (StopScript)
    break

  ;----------------------------
  ; daily and weekly quests
  ;----------------------------
  if (QuestCollect)
  {
    if(QuestReady && !Mod(A_Hour, QuestPeriod))
    {
      QuestReady := false
      Send {space down}
      Send {q}
      Sleep 200
      ClickPoint(quest_daily)
      ClickPoint(quest_claim2, ColorGreen)
      ClickPoint(map_okay, ColorGreen) ; verify this is same location
      ClickPoint(quest_claim1, ColorGreen)
      ClickPoint(map_okay, ColorGreen)
      ClickPoint(quest_weekly)
      ClickPoint(quest_weekly)
      ClickPoint(quest_claim2, ColorGreen)
      ClickPoint(map_okay, ColorGreen)
      ClickPoint(quest_claim1, ColorGreen)
      ClickPoint(map_okay, ColorGreen)
      ClickPoint(quest_weekly)
      ClickPoint(close_inset)
      Send {space up}
    }
    else if (!QuestReady && Mod(A_Hour, QuestPeriod))
    {
      QuestReady := true
    }
  }

  if (StopScript)
    break

  ;----------------------------
  ; approx. every ~20 seconds
  ;----------------------------
  DllCall("QueryPerformanceCounter", "UInt64*", BigBlock)
  BigBlock := (BigBlock - BigBlockMark) // 10000000 ; seconds since script started

  if (BigBlock >= Max_BigBlock)
  {
    DllCall("QueryPerformanceCounter", "UInt64*", BigBlockMark)

    ;----------------------------
    ; train guardian (free)
    ;----------------------------
    Send {space down}
    Send {g}
    Sleep 500
    ClickPoint(train_guardian, ColorGreen)
    ClickPoint(close_full)
    Send {space up}

    if (StopScript)
      break

    ;----------------------------
    ; guild expeditions
    ;----------------------------
    Send {space down}
    ClickPoint(guild_button)
    ClickPoint(expeditions)
    TestColor := GetColorAt(exped_button.x, exped_button.y)
    if(CompareColors(TestColor, ColorGreen))
    {
      ClickPoint(exped_button)
      ClickPoint(exped_button)
    }
    ClickPoint(close_inset)

    ;----------------------------
    ; collect free pickaxes
    ;----------------------------
    ClickPoint(guild_shop)
    TestColor := GetColorAt(guild_shop_supplies.x, guild_shop_supplies.y)
    if(CompareColors(TestColor, ColorBrown))
    {
      AboveLv50 := true
      ClickPoint(guild_shop_supplies)
      ClickPoint(guild_shop_pickaxes, ColorGreen)
    }
    else
    {
      AboveLv50 := false
      AboveLv120 := false
    }
    ClickPoint(close_full)

    ;----------------------------
    ; close guild window
    ;----------------------------
    ClickPoint(close_full)
    Send {space up}

    if (StopScript)
      break

    ;----------------------------
    ; claim map mission on top
    ;----------------------------
    Send {space down}
    Send {m}
    Sleep 200
    ClickPoint(map_claim)
    ClickPoint(map_free, ColorOrange)
    ClickPoint(map_okay)

    ; claim campaign bonus
    if (AboveLv50 == true)
    {
      ClickPoint(campaign_button)
      ClickPoint(campaign_claim, ColorGreen)
    }

    ClickPoint(close_full)
    Send {space up}

    if (StopScript)
      break

    ;----------------------------
    ; upgrade guardian and heroes
    ;----------------------------
    Send {space down}
    Send {u}
    Sleep 200
    ClickPoint(upgrade_special, ColorGreen)
    ClickPoint(upgrade_guard, ColorGreen)
    ClickPoint(upgrade_hero1, ColorGreen)
    ClickPoint(upgrade_hero2, ColorGreen)
    ClickPoint(upgrade_hero3, ColorGreen)
    ClickPoint(upgrade_hero4, ColorGreen)
    ClickPoint(upgrade_hero5, ColorGreen)
    Send {u}
    Sleep 200
    Send {space up}
  }
}
return

ClickPoint(TestPoint, TheColor:=false, DelayTime:=200)
{
  global WindowTitle
  if not WinExist(WindowTitle)
  {
    ExitApp ; if we can't find the game then end the script
  }

  Xpos := TestPoint.x
  Ypos := TestPoint.y

  Result := GetColorAt(Xpos, Ypos)

  if(TheColor == false)
  {
    Click, %Xpos%, %Ypos%
    if (DelayTime > 0)
      Sleep %DelayTime%
    return
  }

  if(CompareColors(Result, TheColor))
  {
    Click, %Xpos%, %Ypos%
    if (DelayTime > 0)
      Sleep %DelayTime%
    return
  }
}

;-------------------------------------------------
; Takes 2 RGB arrays, returns true if similar enough
;-------------------------------------------------
CompareColors(c1, c2, params:=false)
{
  r := Abs(c1.r - c2.r)
  g := Abs(c1.g - c2.g)
  b := Abs(c1.b - c2.b)

  if (params == false)
  {
    if (r > 20 || g > 20 || b > 20)
      return false
    else
      return true
  }

  if (r > params.r || g > params.g || b > params.b)
    return false
  else
    return true
}

GetColorAt(Xpos, Ypos)
{
  PixelGetColor, ColorVariableName, Xpos, Ypos, RGB
  return ColorArray(ColorVariableName)
}

;-------------------------------------------------
; expects string (8 digit hex), returns object
;-------------------------------------------------
ColorArray(HexStr)
{
  MyObj := {}
  MyObj.r := Hex2Dec(SubStr(HexStr, 3, 2))
  MyObj.g := Hex2Dec(SubStr(HexStr, 5, 2))
  MyObj.b := Hex2Dec(SubStr(HexStr, 7, 2))

  return MyObj
}

;-------------------------------------------------
; expects 2 digit hex number, returns decimal
;-------------------------------------------------
Hex2Dec(MyString)
{
  MyNum := 0

  ; convert first digit
  MyDigit := SubStr(MyString, 1, 1)
  Switch (MyDigit)
  {
    Case "F":
      MyNum := 240
    Case "E":
      MyNum := 224
    Case "D":
      MyNum := 208
    Case "C":
      MyNum := 192
    Case "B":
      MyNum := 176
    Case "A":
      MyNum := 160
    Default:
      MyNum := MyDigit * 16
  }

  ; convert second digit
  MyDigit := SubStr(MyString, 2, 1)
  Switch (MyDigit)
  {
    Case "F":
      MyNum += 15
    Case "E":
      MyNum += 14
    Case "D":
      MyNum += 13
    Case "C":
      MyNum += 12
    Case "B":
      MyNum += 11
    Case "A":
      MyNum += 10
    Default:
      MyNum += MyDigit * 1
  }

  return MyNum
}

TellColor(TheColor)
{
  r := TheColor.r
  g := TheColor.g
  b := TheColor.b

  MsgBox, R: %r%, G: %g%, B: %b%
}