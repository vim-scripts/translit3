" U+0021 is !
" U+007E is ~
" Range: !"#$%&'()*+,-./  0-9  :;<=>?@  A-Z  [\]^_`  a-z  {|}~
let diff=char2nr('ａ')-char2nr('a')
let table={}
for nr in range(0x0021, 0x007E)
    let lhs=nr2char(nr)
    let rhs=nr2char(nr+diff)
    let table[lhs]=rhs
endfor
let filename=expand('<sfile>:h:h').'/config/translit3/fullwidth.trpart.json'
python << EOF
import json
with open(vim.eval('filename'), 'w') as f:
    json.dump(vim.eval('table'), f)
EOF
