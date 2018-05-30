" Functions
syn match    cCustomParen    transparent "(" contains=cParen contains=cCppParen
syn match    cCustomFunc     "\w\+\s*(\@=" contains=cCustomParen
hi def link cCustomFunc  Function

" Clear cppStructure and replace "class" with matches based on user configuration
syn clear cStructure
syn keyword cStructure union enum typedef

" Class name declaration
syn match cCustomStructKey "\<struct\>"
hi def link cCustomStructKey cStructure

" Match the parts of a class declaration
syn match cCustomStructName "\<struct\_s\+\w\+\>" contains=cCustomStructKey
hi def link cCustomStructName Function
