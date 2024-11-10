#Include ..\_lib\Path.ahk

Meta := {
  name: 'MeowPaste'
}

class Conf {

  __New() {
    this.Init()
    this._Fix()
    this._EnsureDirectoryExists()
  }

  Init() {
    ; color, transparent
    this.frameBgc := mcf.Get('frameBgc', 'abcabc')
    this.frameTRP := mcf.Get('frameTRP', 150)
    this.maskBgc := mcf.Get('maskBgc', '000000')
    this.maskTRP := mcf.Get('maskTRP', 100)
    ; switches
    this.noBgc := mcf.Get('noBgc', false)
    this.useRandomBgc := mcf.Get('useRandomColor', false)
    this.showMask := mcf.Get('showMask', false)
    this.showMaskIST := mcf.Get('maskIST', false)
    this.autoSave := mcf.Get('autoSave', true)
    this.pasteInstantly := mcf.Get('pasteIST', false)
    this.withTip := mcf.Get('tip', false)
    ; settings
    this.clickCount := mcf.Get('trayClick', 1)
    this.saveSuffix := mcf.Get('saveSuffix', '.png')
    ; hotkeys
    this.clipHK := mcf.Get('clipHK', '!``')
    this.cancelHK := mcf.Get('cancelHK', 'Esc')
    this.clearAllHK := mcf.Get('clearAllHK', '!Esc')
    this.lastHK := mcf.Get('lastHK', '!1')
    ; some path
    this.groupRoot := mcf.Get('groupRoot', Path.Join(A_ScriptDir, 'group'))
    this.historyPath := mcf.Get('historyPath', Path.Join(this.groupRoot, 'history'))
    this.defaultSavePath := mcf.Get('defaultSave', Path.Join(this.groupRoot, 'group\default'))
    this.groupsList := mcf.Get('group').Get('names', [])
  }

  Sync() {
    mcf.Set('frameBgc', this.frameBgc)
    mcf.Set('frameTRP', this.frameTRP)
    mcf.Set('maskBgc', this.maskBgc)
    mcf.Set('maskTRP', this.maskTRP)
    mcf.Set('noBgc', this.noBgc)

    mcf.Set('showMask', this.showMask)
    mcf.Set('maskIST', this.showMaskIST)
    mcf.Set('autoSave', this.autoSave)
    mcf.Set('pasteIST', this.pasteInstantly)
    mcf.Set('tip', this.withTip)

    mcf.Sync()
  }

  _Fix() {
    ; 如果是透明色，打开遮罩
    if !this.showMask && this.noBgc
      this.showMask := true
  }

  _EnsureDirectoryExists() {
    for v in Array(_r := this.groupRoot, this.historyPath, this.defaultSavePath) {
      if !DirExist(v) {
        DirCreate(v)
        logger.Warn('创建文件夹 ' v)
      }
    }
    for v in this.groupsList {
      if !DirExist(_r '\' v) {
        DirCreate(_r '\' v)
        logger.Warn('创建分组文件夹 ' v)
      }
    }
  }

}