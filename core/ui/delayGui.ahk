class DelayGui extends Gui {
  ; just a simple gui

  __New(time) {
    super.__New('+AlwaysOnTop -Caption +Border +ToolWindow')
    this.SetFont('s30')
    this.text := this.AddText('xm', time)
  }

  static Show(time) {
    g := DelayGui(time)
    g.Show('NA y' A_ScreenHeight / 3)
    loop time
      Sleep(1000), g.text.Value := time - A_Index
    g.Destroy()
  }

}