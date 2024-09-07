class HistoryGui extends BaseGui {

  static _cache := Map()

  __New(id, p) {
    super.__New('+Border') ; add 1px border
    this.id := id, this.savePath := p
    this.CreateTime(FileGetTime(this.savePath)).Border(1)
  }

  static FlushCache() => HistoryGui._cache.Clear()

  ; Adapt to the display position of the gui and do not overlap each other in a small number of tiles
  Show(w, h, id, *) {
    ; This method use only the left part of the screen

    getPoint(w, h, &nx, &ny) {
      x := 0, y := 0
      if w <= A_ScreenWidth - 80
        x := 80
      if h <= A_ScreenHeight
        y := 0
      nx := x, ny := y
    }

    if hit := HistoryGui._cache.Get(id, '') {
      x := hit.x
      y := hit.y
    } else {
      if HistoryGui._cache.Has(id + 1) {
        point := HistoryGui._cache.Get(id + 1)
        x := point.x
        y := point.y + point.h
        if y + h > A_ScreenHeight || x + w > A_ScreenWidth
          getPoint(w, h, &x, &y)
      } else {
        getPoint(w, h, &x, &y)
      }
      HistoryGui._cache.Set(id, { x: x, y: y, h: h })
    }

    super.Show('NA x' x ' y' y ' w' w ' h' h)
    WinSetTransparent(255, this)  ; lock
    this.RegisterEvent()
  }

  OnDestroy(*) {
    History.ReturnToPool(this.id)
    super.OnDestroy()
  }
}