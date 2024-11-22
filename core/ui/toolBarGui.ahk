class MyToolBar extends Gui {

  static btnW := 60, btnH := 30

  __New(nameList, x, y, cbs) {
    super.__New('+AlwaysOnTop +ToolWindow -Caption')
    this.SetFont('s14')
    this.btnCount := nameList.Length, this.posX := x, this.posY := y
    for i, v in nameList {
      this.AddButton(
        Format('xs w{} h{} x{} y0', MyToolBar.btnW, MyToolBar.btnH, (i - 1) * MyToolBar.btnW)
        , nameList[i]
      ).OnEvent('Click', cbs[i])
    }
  }

  Adapt(wx, wy, ww, wh) {
    y := wy + wh >= (A_ScreenHeight - MyToolBar.btnH) ? wy - MyToolBar.btnH : wy + wh
    y := wh >= (A_ScreenHeight - MyToolBar.btnH) ? wy + wh - 1.5 * MyToolBar.btnH : y
    x := ((wx + ww) < MyToolBar.btnW * this.btnCount) ? 0 : wx + ww - MyToolBar.btnW * this.btnCount
    this.posX := x, this.posY := y
    return this
  }

  Move(x := unset, y := unset) {
    IsSet(x) && this.posX := x
    IsSet(y) && this.posY := y
    super.Move(this.posX, this.posY)
  }

  Show(x := unset, y := unset) {
    IsSet(x) && this.posX := x
    IsSet(y) && this.posY := y
    super.Show(Format('x{} y{} w{} h{}', this.posX, this.posY, MyToolBar.btnW * this.btnCount, MyToolBar.btnH))
  }

}