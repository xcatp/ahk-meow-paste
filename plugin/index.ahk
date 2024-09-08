#Requires AutoHotkey v2.0

#Include ./plugin.ahk
#Include ./timestampGenerator.ahk

tsp := TimestampPlugin('B180D7')

Plugin
  .Load(tsp)
  .Exec()