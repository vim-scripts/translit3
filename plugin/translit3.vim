scriptencoding utf-8
"{{{2 Регистрация дополнения
execute frawor#Setup('0.2', {'@/mappings': '0.1',
            \                '@/commands': '0.0',
            \               '@/functions': '0.1',})
let s:aufuncarg=['@%translit3', [0,3]]
"{{{2 Commands
call s:_f.command.add('Tr3Command', {
            \   'function': s:aufuncarg+['cmd'],
            \}, {
            \      'nargs': '+',
            \      'range': 1,
            \       'bang': 1,
            \   'complete': {
            \       'function': s:aufuncarg+['comp'],
            \   },
            \   'usedictcompsplitfunc': 1,
            \})
"{{{2 Функции
let s:extfunctionslst=[
            \'Tr3transliterate',
            \'Tr3add',
            \'Tr3include',
            \'Tr3exclude',
            \'Tr3del',
            \'Tr3setoption',
            \'Tr3deloption',
            \'Tr3print',
        \]
let s:extfunctions={}
for s:key in s:extfunctionslst
    let s:extfunctions[s:key]={'function': s:aufuncarg+[s:key]}
endfor
unlet s:key
call s:_f.addextfunctions(s:extfunctions)
unlet s:extfunctions s:extfunctionslst
"{{{2 Привязки
let s:mappings=[['Transliterate',         'i', '' ],
            \   ['CmdTransliterate',      'c', '' ],
            \   ['TransliterateWord',     'i', 'w'],
            \   ['TransliterateWORD',     'i', 'W'],
            \   ['TransliterateMotion',  'nx', 'v'],
            \   ['StartToF',              'n', 's'],
            \   ['StopToF',               'n', 'S'],
            \   ['TranslitReplace',      'nx', 'r'],
            \   ['TranslitToNext',      'nxo', 't'],
            \   ['TranslitToPrev',      'nxo', 'T'],
            \   ['TranslitNext',        'nxo', 'f'],
            \   ['TranslitPrev',        'nxo', 'F'],
            \]
let s:mgroup={}
let s:strfunc={'function': s:aufuncarg+['str']}
for [s:map, s:mode, s:key] in s:mappings
    let s:mgroup[s:map]={
                \'mode': s:mode,
                \ 'rhs': ['%mname'],
                \ 'lhs': s:key,
            \}
    if s:map[:7] is# 'Translit' && s:map[8] isnot# 'e'
        let s:mgroup[s:map].strfunc=s:strfunc
        let s:mgroup[s:map].rhs+=['%str']
    endif
endfor
unlet s:map s:mode s:key s:mappings
unlet s:strfunc
let s:mgroup.TransliterateMotion.operator=1
let s:mgroup.TransliterateMotion.rhs={'function': s:aufuncarg+['trmotion']}
call s:_f.mapgroup.add('Tr3', s:mgroup, {
            \   'func': {'function': s:aufuncarg+['map']},
            \   'leader': '<Leader>t',
            \})
unlet s:mgroup
"}}}2
"{{{1
call frawor#Lockvar(s:, '_r')
" vim: ft=vim:ts=8:fdm=marker:fenc=utf-8
