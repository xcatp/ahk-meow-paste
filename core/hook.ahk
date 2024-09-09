#Include ..\_lib\Extend_Merged.ahk

class Events {
  ; param: null
  static BeforeClip := 0x1
  ; param: null
  static AfterClip := 0x2
  ; param: g(object of paste gui)
  static BeforePaste := 0x3
  ; param: null
  static AfterPaste := 0x4
  ; param: [g(object of paste gui), clientX, clientY]
  static OnTimestampGenerate := 0x10      ; extend event
}

; Manages registration and execution of hook functions
class Hook {

  static tasks := {}

  ; Execute hook event callbacks.
  ; Note that all callbacks are still preserved.
  ; If want to clear them, call ```Hook.CleanEventCB()```
  static _Exec(event, attach?) {
    if !Hook.tasks[event]
      return false
    for task in Hook.tasks[event] {
      if IsFunction(task)
        task(attach?)
    }
    return true
  }

  ; Clear one or all hook event callbacks
  static CleanEventCB(event?) => IsSet(event) ? Hook.tasks[event] := '' : Hook.tasks := {}

  ; Register hook event callbacks
  static Register(event, callback) {
    if !Hook.tasks[event]
      Hook.tasks[event] := []
    Hook.tasks[event].Push(callback)
  }

}