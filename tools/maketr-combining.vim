function! TrAdd() range abort
    for line in range(a:firstline, a:lastline)
        let linestr=getline(line)
        let [dummy, rhs, lhs; dummy2]=matchlist(linestr, '^ *\(\S\+\) \+\(\S\+\)')
        let rhs=rhs[1:]
        execute "Tr3Command add   ".lhs." ".rhs." to transsymb-combining"
        execute "Tr3Command add $D".lhs." ".rhs." to transsymb"
        execute "Tr3Command add $D".lhs." ".rhs." to transsymb-ru"
    endfor
endfunction
