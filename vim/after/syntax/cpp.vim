
" Functions
syn match   cCustomParen    transparent "(" contains=cParen contains=cCppParen
syn match   cCustomFunc     "\~\\\?\w\+\s*(\@="
hi def link cCustomFunc  Function

" Class and namespace scope
syn match   cCustomScope    "::"
syn match   cCustomClass    "\w\+\s*::" contains=cCustomScope
hi def link cCustomClass Function

" Clear cppStructure and replace "class" with matches based on user configuration
syn clear cppStructure
syn keyword cppStructure typename namespace template

" Class name declaration
syn match cCustomClassKey "\<class\>"
hi def link cCustomClassKey cppStructure

" Match the parts of a class declaration
syn match cCustomClassName "\<class\_s\+\w\+\>" contains=cCustomClassKey
hi def link cCustomClassName Function
