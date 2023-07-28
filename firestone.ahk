;------------------------------------------------------------------------------
; Copyright (c) William J. Thompson
; 28 July 2023 @ 00:00am PST
;
; Automate boring bits of Firestone Idle RPG by Holiday Games.
; https://holydaygames.com/firestone-idle-rpg/
;
; Run in full-screen mode, any resolution (NO black bar on top,bottom ,or sides).
;
; Use the Ctrl+` key (Ctrl+backtick) to activate and ` key (backtick by itself) to deactivate
;
; Actions this script performs:
; -----------------------------
; - Upgrade special, guardian, all heroes
; - Train guardian (free, can train with dust too)
; - Collect map missions (does not start new ones)
; - Collect daily mystery box and daily check-in (once after 10am)
; - Play tavern beer games every 6 hours
; - Claim daily & weekly quests
; - Collect Firestone research (does not start new ones)
; - (Level 50+) Collect pickaxes
; - (Level 50+) Claim campaign bonus
; - (Level 120+) Collect Alchemist research (can start new ones, does not be default)
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
; spend dust to train guardian
;----------------------------
GuardianEnlightenment := false

;----------------------------
; collect research
;----------------------------
ResearchCollect := true
ResearchReady := false
ResearchPeriod := 5 ; minutes
NewAlchemistBlood := true
NewAlchemistDust := false
NewAlchemistCoin := false

;----------------------------
; levels change automatically
;----------------------------
AboveLv50 := false
AboveLv120 := false

TinyBlock := false
BigBlock := 0
Max_TinyBlock := 8 ; cycles between open/close upgrade panel
Max_BigBlock := 20 ; minimum seconds between big block run time
BigBlockMark := 0 ; current time in seconds
StopScript := true ; default is true
TimeDelay := 200
TimeDelayShort := 120

ColorOrange := { r:237, g:145, b:64 }
ColorGreen := { r:10, g:160, b:8 }
ColorDarkGreen := { r:27, g:165, b:105 }
ColorTeal := { r:27, g:112, b:159 }
ColorBrown := { r:127, g:94, b:41 }
ColorGray := { r:190, g:190, b:190 }
ColorRed := { r:244, g:0, b:0 }
ColorBeige := { r:240, g:221, b:197 }
ColorBlue := { r:16, g:137, b:255 }

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
middle_screen   := {x:Floor(wide * 0.420), y:Floor(high * 0.300)}
close_full      := {x:Floor(wide * 0.957), y:Floor(high * 0.075)}
close_inset     := {x:Floor(wide * 0.924), y:Floor(high * 0.105)}
close_upgrade   := {x:Floor(wide * 0.971), y:Floor(high * 0.069)}
upgrade_alert   := {x:Floor(wide * 0.758), y:Floor(high * 0.877)}
upgrade_special := {x:Floor(wide * 0.976), y:Floor(high * 0.186)}
upgrade_guard   := {x:Floor(wide * 0.976), y:Floor(high * 0.295)}
upgrade_hero1   := {x:Floor(wide * 0.976), y:Floor(high * 0.406)}
upgrade_hero2   := {x:Floor(wide * 0.976), y:Floor(high * 0.517)}
upgrade_hero3   := {x:Floor(wide * 0.976), y:Floor(high * 0.628)}
upgrade_hero4   := {x:Floor(wide * 0.976), y:Floor(high * 0.740)}
upgrade_hero5   := {x:Floor(wide * 0.976), y:Floor(high * 0.852)}
train_guardian  := {x:Floor(wide * 0.542), y:Floor(high * 0.757)}
train_dust      := {x:Floor(wide * 0.753), y:Floor(high * 0.757)}
shop_button     := {x:Floor(wide * 0.968), y:Floor(high * 0.555)}
shop_gift       := {x:Floor(wide * 0.350), y:Floor(high * 0.600)}
shop_calendar   := {x:Floor(wide * 0.734), y:Floor(high * 0.100)}
shop_checkin    := {x:Floor(wide * 0.707), y:Floor(high * 0.807)}
tavern_icon     := {x:Floor(wide * 0.395), y:Floor(high * 0.893)}
tavern_market   := {x:Floor(wide * 0.895), y:Floor(high * 0.043)}
tavern_tokens   := {x:Floor(wide * 0.343), y:Floor(high * 0.394)}
tavern_play     := {x:Floor(wide * 0.603), y:Floor(high * 0.903)}
tavern_card     := {x:Floor(wide * 0.500), y:Floor(high * 0.700)}
tavern_discard  := {x:Floor(wide * 0.525), y:Floor(high * 0.807)}
quest_daily     := {x:Floor(wide * 0.375), y:Floor(high * 0.130)}
quest_weekly    := {x:Floor(wide * 0.589), y:Floor(high * 0.130)}
quest_claim1    := {x:Floor(wide * 0.744), y:Floor(high * 0.285)}
quest_claim2    := {x:Floor(wide * 0.744), y:Floor(high * 0.463)}
quest_okay      := {x:Floor(wide * 0.672), y:Floor(high * 0.657)} ; 1290 x 710
guild_button    := {x:Floor(wide * 0.967), y:Floor(high * 0.427)}
guild_shop      := {x:Floor(wide * 0.320), y:Floor(high * 0.229)}
guild_supplies  := {x:Floor(wide * 0.130), y:Floor(high * 0.713)}
guild_pickaxes  := {x:Floor(wide * 0.302), y:Floor(high * 0.607)}
expeditions     := {x:Floor(wide * 0.140), y:Floor(high * 0.385)}
exped_button    := {x:Floor(wide * 0.638), y:Floor(high * 0.277)}
map_mission     := {x:Floor(wide * 0.023), y:Floor(high * 0.225)} ; 46 x 243
map_claim       := {x:Floor(wide * 0.100), y:Floor(high * 0.300)}
map_claim_big   := {x:Floor(wide * 0.500), y:Floor(high * 0.911)}
map_okay        := {x:Floor(wide * 0.520), y:Floor(high * 0.442)}
map_okay_bg     := {x:Floor(wide * 0.625), y:Floor(high * 0.345)}
map_free        := {x:Floor(wide * 0.592), y:Floor(high * 0.930)}
campaign_icon   := {x:Floor(wide * 0.960), y:Floor(high * 0.570)}
campaign_claim  := {x:Floor(wide * 0.117), y:Floor(high * 0.925)}
campaign_alert  := {x:Floor(wide * 0.974), y:Floor(high * 0.907)}
wm_missions     := {x:Floor(wide * 0.935), y:Floor(high * 0.945)}
wm_liberation   := {x:Floor(wide * 0.400), y:Floor(high * 0.760)}
wm_dungeon      := {x:Floor(wide * 0.600), y:Floor(high * 0.760)}
check50         := {x:Floor(wide * 0.190), y:Floor(high * 0.272)} ; 364 x 294?
check120        := {x:Floor(wide * 0.242), y:Floor(high * 0.815)}
alchemist_blood := {x:Floor(wide * 0.460), y:Floor(high * 0.750)}
alchemist_dust  := {x:Floor(wide * 0.660), y:Floor(high * 0.739)}
alchemist_coin  := {x:Floor(wide * 0.853), y:Floor(high * 0.739)}
alch_new_blood  := {x:Floor(wide * 0.440), y:Floor(high * 0.739)}
alch_new_dust   := {x:Floor(wide * 0.628), y:Floor(high * 0.739)}
alch_new_coin   := {x:Floor(wide * 0.821), y:Floor(high * 0.739)}
library_icon    := {x:Floor(wide * 0.144), y:Floor(high * 0.620)}
fire_research   := {x:Floor(wide * 0.940), y:Floor(high * 0.925)}
firestone_1     := {x:Floor(wide * 0.288), y:Floor(high * 0.910)}
firestone_2     := {x:Floor(wide * 0.638), y:Floor(high * 0.910)}

;----------------------------
; Main clicker loop
;----------------------------
Loop
{
  if(StopScript)
    break

  ClickPoint(middle_screen, false, 120)
  Send {3} ; keep party leader ability #3 active

  TestColor := GetColorAt(upgrade_alert.x, upgrade_alert.y)
  if(CompareColors(TestColor, ColorRed))
  {
    Send {space down}
    ; check if upgrade window open/close
    TestColor := GetColorAt(close_upgrade.x, close_upgrade.y)
    if(!CompareColors(TestColor, ColorRed))
    {
      Send {u} ; toggle upgrade pane
      Sleep %TimeDelay%
    }

    loop
    {
      TinyBlock := false
      if(ClickPoint(upgrade_special, ColorGreen, TimeDelayShort))
        TinyBlock := true
      if(ClickPoint(upgrade_guard, ColorGreen, TimeDelayShort))
        TinyBlock := true
      if(ClickPoint(upgrade_hero1, ColorGreen, TimeDelayShort))
        TinyBlock := true
      if(ClickPoint(upgrade_hero2, ColorGreen, TimeDelayShort))
        TinyBlock := true
      if(ClickPoint(upgrade_hero3, ColorGreen, TimeDelayShort))
        TinyBlock := true
      if(ClickPoint(upgrade_hero4, ColorGreen, TimeDelayShort))
        TinyBlock := true
      if(ClickPoint(upgrade_hero5, ColorGreen, TimeDelayShort))
        TinyBlock := true

      if(!TinyBlock)
        break

      if(StopScript)
        break
    }
    Send {u} ; toggle upgrade pane
    Sleep %TimeDelay%
    Send {space up}
  }

  if(StopScript)
    break

  ;----------------------------
  ; daily mystery box & check-in
  ;----------------------------
  if(DailyCollect)
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
    else if(not DailyReady && A_Hour != 10)
    {
      DailyReady := true
    }
  }

  ;----------------------------
  ; collect finished research
  ;----------------------------
  if(ResearchCollect)
  {
    if(ResearchReady && !Mod(A_Min, ResearchPeriod))
    {
      ResearchReady := false

      Send {space down}
      Send {t}
      Sleep %TimeDelay%
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
      if(AboveLv120)
      {
        ClickPoint(check120)
        if(!ClickPoint(alchemist_blood, ColorOrange))
          ClickPoint(alchemist_blood, ColorGreen)
        if(NewAlchemistBlood)
          ClickPoint(alch_new_blood)
        if(!ClickPoint(alchemist_dust, ColorOrange))
        ClickPoint(alchemist_dust, ColorGreen)
        if(NewAlchemistDust)
          ClickPoint(alch_new_dust)
        if(!ClickPoint(alchemist_coin, ColorOrange))
        ClickPoint(alchemist_coin, ColorGreen)
        if(NewAlchemistCoin)
          ClickPoint(alch_new_coin)
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
    else if(!ResearchReady && Mod(A_Min, ResearchPeriod))
    {
      ResearchReady := true
    }
  }

  if(StopScript)
    break

  ;----------------------------
  ; tavern games
  ;----------------------------
  if(TavernPlay)
  {
    if(TavernReady && !Mod(A_Hour, TavernPeriod))
    {
      Send {space down}
      TavernReady := false
      Send {t}
      Sleep %TimeDelay%
      ClickPoint(tavern_icon)
      TestColor := GetColorAt(tavern_play.x, tavern_play.y)
      if(CompareColors(TestColor, ColorGreen))
      {
        ClickPoint(tavern_play, false, 2500)
        ClickPoint(tavern_card)

        TestColor := GetColorAt(tavern_discard.x, tavern_discard.y)
        while(!CompareColors(TestColor, ColorBlue))
        {
          Sleep %TimeDelay%
          TestColor := GetColorAt(tavern_discard.x, tavern_discard.y)
        }
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
        ClickPoint(tavern_card)

        TestColor := GetColorAt(tavern_discard.x, tavern_discard.y)
        while(!CompareColors(TestColor, ColorBlue))
        {
          Sleep %TimeDelay%
          TestColor := GetColorAt(tavern_discard.x, tavern_discard.y)
        }
      }
      ClickPoint(close_full)
      ClickPoint(close_full)
      Send {space up}
    }
    else if(!TavernReady && Mod(A_Hour, TavernPeriod))
    {
      TavernReady := true
    }
  }

  if(StopScript)
    break

  ;----------------------------
  ; daily and weekly quests
  ;----------------------------
  if(QuestCollect)
  {
    if(QuestReady && !Mod(A_Hour, QuestPeriod))
    {
      QuestReady := false
      Send {space down}
      Send {q}
      Sleep %TimeDelay%
      ClickPoint(quest_daily)
      ClickPoint(quest_claim2, ColorGreen)
      ClickPoint(quest_okay, ColorGreen)
      ClickPoint(quest_claim1, ColorGreen)
      ClickPoint(quest_okay, ColorGreen)
      ClickPoint(quest_weekly)
      ClickPoint(quest_weekly)
      ClickPoint(quest_claim2, ColorGreen)
      ClickPoint(quest_okay, ColorGreen)
      ClickPoint(quest_claim1, ColorGreen)
      ClickPoint(quest_okay, ColorGreen)
      ClickPoint(quest_weekly)
      ClickPoint(close_inset)
      Send {space up}
    }
    else if(!QuestReady && Mod(A_Hour, QuestPeriod))
    {
      QuestReady := true
    }
  }

  if(StopScript)
    break

  ;----------------------------
  ; approx. every ~20 seconds
  ;----------------------------
  DllCall("QueryPerformanceCounter", "UInt64*", BigBlock)
  BigBlock := (BigBlock - BigBlockMark) // 10000000 ; seconds since script started

  if(BigBlock >= Max_BigBlock)
  {
    DllCall("QueryPerformanceCounter", "UInt64*", BigBlockMark)

    ;----------------------------
    ; train guardian (free & dust)
    ;----------------------------
    Send {space down}
    Send {g}
    Sleep 500
    ClickPoint(train_guardian, ColorGreen)
    if(GuardianEnlightenment)
      ClickPoint(train_dust, ColorGreen)
    ClickPoint(close_full)
    Send {space up}

    if(StopScript)
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
    TestColor := GetColorAt(guild_supplies.x, guild_supplies.y)
    if(CompareColors(TestColor, ColorBrown))
    {
      AboveLv50 := true
      ClickPoint(guild_supplies)
      ClickPoint(guild_pickaxes, ColorDarkGreen)
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

    if(StopScript)
      break

    ;----------------------------
    ; claim map mission on top
    ;----------------------------
    Send {space down}
    Send {m}
    Sleep %TimeDelay%
    TestColor := GetColorAt(map_mission.x, map_mission.y)
    if(CompareColors(TestColor, ColorBeige))
    {
      ClickPoint(map_claim)
      TestColor := GetColorAt(map_okay.x, map_okay_bg.y)
      if(CompareColors(TestColor, ColorBeige))
      {
        ClickPoint(map_claim_big, ColorGreen)
        ClickPoint(map_free, ColorOrange)
      }
      TestColor := GetColorAt(map_okay_bg.x, map_okay_bg.y)
      if(CompareColors(TestColor, ColorBeige))
        ClickPoint(map_okay, ColorGreen)
    }

    ; claim campaign bonus
    if(AboveLv50)
    {
      ClickPoint(campaign_icon)
      ; daily campaign missions
      ClickPoint(campaign_claim, ColorGreen)
    }

    ClickPoint(close_full)
    Send {space up}

    if(StopScript)
      break

    Send {space down}
    Send {u} ; toggle upgrade pane
    Sleep %TimeDelay%
    TinyBlock := false
    loop
    {
      if(StopScript)
        break

      if(ClickPoint(upgrade_special, ColorGreen, TimeDelayShort))
        TinyBlock := true
      if(ClickPoint(upgrade_guard, ColorGreen, TimeDelayShort))
        TinyBlock := true
      if(ClickPoint(upgrade_hero1, ColorGreen, TimeDelayShort))
        TinyBlock := true
      if(ClickPoint(upgrade_hero2, ColorGreen, TimeDelayShort))
        TinyBlock := true
      if(ClickPoint(upgrade_hero3, ColorGreen, TimeDelayShort))
        TinyBlock := true
      if(ClickPoint(upgrade_hero4, ColorGreen, TimeDelayShort))
        TinyBlock := true
      if(ClickPoint(upgrade_hero5, ColorGreen, TimeDelayShort))
        TinyBlock := true

      if(TinyBlock)
        TinyBlock := false
      else
        break
    }
    Send {u} ; toggle upgrade pane
    Sleep %TimeDelay%
    Send {space up}
  }
}
return

ClickPoint(TestPoint, TheColor:=false, TheDelay:=200)
{
  global WindowTitle
  if not WinExist(WindowTitle)
  {
    ExitApp ; if we can't find the game then end the script
  }

  Xpos := TestPoint.x
  Ypos := TestPoint.y

  Result := GetColorAt(Xpos, Ypos)

  if(!TheColor)
  {
    Click, %Xpos%, %Ypos%
    if(TheDelay)
      Sleep %TheDelay%
    return true
  }

  if(CompareColors(Result, TheColor))
  {
    Click, %Xpos%, %Ypos%
    if(TheDelay)
      Sleep %TheDelay%
    return true
  }

  return false
}

;-------------------------------------------------
; Takes 2 RGB arrays, returns true if similar enough
;-------------------------------------------------
CompareColors(c1, c2, params:=false)
{
  r := Abs(c1.r - c2.r)
  g := Abs(c1.g - c2.g)
  b := Abs(c1.b - c2.b)

  if(!params)
  {
    if(r > 20 || g > 20 || b > 20)
      return false
    else
      return true
  }

  if(r > params.r || g > params.g || b > params.b)
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