function! MakeTr() range abort
    for line in range(a:firstline, a:lastline)
        let linestr=getline(line)
        if linestr=~'dash\|diagonal'
            continue
        endif
        let props=split(matchstr(linestr, '\( \w\+\)\+$')[1:])
        let r=""
        let type="none"
        let types={
                    \"light":      "v:val",
                    \"single":     "v:val",
                    \"heavy":      "toupper(v:val)",
                    \"double":     "'b'.v:val",
                    \"arc":        "'a'.v:val",
                    \"none":       "v:val",
                \}
        let symbols=[]
        while !empty(props)
            let prop=remove(props, 0)
            if has_key(types, prop)
                let type=prop
            elseif index(["up", "down", "left", "right",
                        \ "horizontal", "vertical"],
                        \prop)!=-1
                call add(symbols, prop[0])
            elseif prop=="and"
                call map(symbols, types[type])
                let r.=join(symbols, "")
                call remove(symbols, 0, -1)
            endif
        endwhile
        if !empty(symbols)
            call map(symbols, types[type])
            let r.=join(symbols, "")
            call remove(symbols, 0, -1)
        endif
        let r=substitute(r, '^\([ba]\).\%(\1.\)\+$',
                    \'\=toupper(submatch(1)).'.
                    \   'substitute(submatch(0), submatch(1), "", "g")', '')
        let linestr=substitute(linestr, '^ \+\S \zs \{'.len(r).'}', r, '')
        call setline(line, linestr)
    endfor
endfunction
function! TrAdd() range abort
    for line in range(a:firstline, a:lastline)
        let linestr=getline(line)
        let [dummy, rhs, lhs; dummy2]=matchlist(linestr, '^ *\(\S\+\) \+\(\S\+\)')
        execute "Tr3Command add   ".fnameescape(lhs)." ".fnameescape(rhs)." to transsymb-box"
        execute "Tr3Command add $t".fnameescape(lhs)." ".fnameescape(rhs)." to transsymb"
        execute "Tr3Command add $t".fnameescape(lhs)." ".fnameescape(rhs)." to transsymb-ru"
    endfor
endfunction
