#Include ..\_lib\MeowConf.ahk

lang := mcf.Get('local', 'zh')

; 文件换行符需为**CRLF**
f := MeowConf.Of(lang = 'zh' ? './local/zh.txt' : './local/en.txt', true)

_t(key) => key.split('.').reduce((o, c) => o && o[c], f.data)