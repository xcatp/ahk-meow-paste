/*
  2024/09/06 xcatp null4cat@gmail.com
  Licensed under MIT
*/
#Requires AutoHotkey v2.0
#SingleInstance Force

TraySetIcon '.\MeowPaste.ico'
CoordMode 'Mouse', 'Screen'

#Include _lib\log.ahk
#Include _lib\MeowConfEx.ahk

logger := Log('./log.txt'), logger.level := Log.LogLevel.Info
OnError((e, *) => (logger.Err(e.What ':' e.Message ':' e.File ':' e.Line), 0))

#Include core/conf.ahk
mcf := MeowConfEx.Of('./config.txt'), cfg := Conf()

#Include core/history.ahk
History.Init(cfg.historyPath)

#Include plugin\index.ahk
#Include core\main.ahk

#Esc:: logger.Info('热键退出程序'), ExitApp()