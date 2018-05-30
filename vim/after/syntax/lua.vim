
syn match luaFuncDef "\(\<function\>.*\)\@<=\(\w\+\s*(\)"me=e-1
syn match luaFuncCall "\(\<function\>.*\)\@<!\(\w\+\s*(\)"me=e-1
syn match luaClass "\(\w\+\)\(\s*\(:\|\.\)\s*\w\+\s*(\)\@="

hi def link luaFuncDef Function
hi def link luaFuncCall Function
hi def link luaClass Structure

syn region Myfold start="\<if\>" end="\<end\>" fold
syn sync fromstart

hi def link otherLuaKeyword Statement
syn keyword otherLuaKeyword __index
