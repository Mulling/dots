" About: based, consistency is not something you find in vim/nvim.
" TODO: move this to Lua!?

highlight clear

if exists("syntax_on")
    syntax reset
endif

"  Group        Foreground   Background   Cterm              Term
hi Function     ctermfg=3
hi Boolean      ctermfg=5
hi Number       ctermfg=7
hi Float        ctermfg=7
hi Comment      ctermfg=8
hi Constant     ctermfg=2
hi CursorLine   ctermbg=0                 cterm=none
hi CursorLineNr ctermfg=3    ctermbg=0    cterm=none
hi Delimiter    ctermfg=7
hi Directory    ctermfg=4
hi Error        ctermfg=1    ctermbg=0
hi ErrorMsg     ctermfg=1    ctermbg=none
hi Identifier   ctermfg=7                 cterm=none
hi IncSearch                 ctermbg=none cterm=bold,reverse term=bold
hi LineNr       ctermfg=8                 cterm=bold
hi MatchParen   ctermfg=8    ctermbg=none cterm=reverse
hi ModeMsg      ctermfg=7
hi MoreMsg      ctermfg=2
hi NonText      ctermfg=8
hi Normal       ctermfg=none ctermbg=none
hi Operator     ctermfg=7
hi Pmenu        ctermfg=7    ctermbg=0    cterm=none
hi PmenuSbar    ctermbg=0                 cterm=none
" hi PmenuSel     ctermfg=4    ctermbg=none cterm=bold,reverse term=bold
hi PmenuThumb   ctermbg=8                 cterm=none
hi PreProc      ctermfg=3
hi Question     ctermfg=2
hi QuickFixLine              ctermbg=0
hi Search       ctermfg=none ctermbg=none cterm=bold,reverse term=bold
hi Special      ctermfg=6
hi SpecialKey   ctermfg=4
hi SpellBad                  ctermbg=none cterm=underline
hi SpellCap                  ctermbg=none cterm=underline
hi SpellLocal                ctermbg=none cterm=underline
hi SpellRare                 ctermbg=none cterm=underline
hi Statement    ctermfg=1
hi StatusLine   ctermfg=7    ctermbg=0    cterm=bold
hi StatusLineNC ctermfg=8    ctermbg=0    cterm=none
hi StorageClass ctermfg=1
hi Structure    ctermfg=1
hi Todo         ctermfg=3    ctermbg=none cterm=bold
hi Type         ctermfg=4
hi Typedef      ctermfg=1
hi Underlined   ctermfg=6
hi VertSplit    ctermfg=0                 cterm=none
hi Visual                    ctermbg=none cterm=bold,reverse term=bold
hi WarningMsg   ctermfg=1
hi StatusLineNU ctermfg=0    ctermbg=0

"        Target                Source
hi! link Title                 PreProc
hi! link diffAdded             String
hi! link diffRemoved           Comment
hi! link hsOperator            Type
hi! link makeTarget            PreProc
hi! link pythonBuiltin         Type
hi! link pythonOperator        Keyword
hi! link qfFileName            PreProc
hi! link qfLineNr              Keyword
" emacs gets it right
hi! link cConstant             Normal

hi! link TelescopeTitle        Comment

hi! link PmenuSel              Visual

hi! link CmpItemAbbrMatch      Normal
hi! link CmpItemAbbrMatchFuzzy Normal
hi! link CmpItemKind           Keyword
hi! link CmpItemKindFolder     Directory
hi! link CmpItemKindFunction   Function
hi! link CmpItemKindInterface  Type
hi! link CmpItemKindMethod     Function
hi! link CmpItemKindReference  Special
hi! link CmpItemKindText       Identifier
hi! link CmpItemKindVariable   Identifier

hi! link NvimTreeStatusLine    StatusLineNU
hi! link NvimTreeStatusLineNC  StatusLineNU

" sorry what!?
hi! link @error Comment

" FUCK OFF
hi! link @keyword.import PreProc
hi! link @keyword.directive PreProc
