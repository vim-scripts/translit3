scriptencoding utf-8
"{{{2 Регистрация дополнения
execute frawor#Setup('0.2', {'@/mappings': '0.1',
            \                '@/commands': '0.0',
            \               '@/functions': '0.0',
            \                     '@/fwc': '0.4',
            \                      '@/os': '0.0',
            \                '@translit3': '0.0',})
let s:ctr=':0 _'
"{{{2 Commands
let s:cmdfun={'@FWC': ['-onlystrings '.
            \'<transliterate (in [selection lines] '.
            \                    '{using '.s:ctr.'}) '.
            \ 'setoption     (in [capital] '.
            \                'in [first none] '.
            \                '{for _ '.
            \                 'in '.s:ctr.'}) '.
            \ 'deloption     (in [capital] '.
            \                '{for _ '.
            \                 'in '.s:ctr.'}) '.
            \ 'add           (_ _ {to   '.s:ctr.'}) '.
            \ 'include       (_ _ {to   '.s:ctr.'}) '.
            \ 'exclude       (_ _ {from '.s:ctr.'}) '.
            \ 'delete        (_   {from '.s:ctr.'}) '.
            \ 'save          (['.s:ctr.']) '.
            \ 'print         {transsymb '.s:ctr.' '.
            \                'columns   :=(-2)  range -2 inf}'.
            \ 'tof           <restart - '.
            \                'stop    - '.
            \                'start   ['.s:ctr.']> '.
            \ 'cache         <purge   in [innertrans trans printtrans '.
            \                            'toftrans] ~start 1 '.
            \                'show    ->>',
            \'filter']}
let s:usedtranssymbs=[]
let s:cmdcomp=[substitute(s:cmdfun['@FWC'][0], '\V'.s:ctr,
            \             'first (in usedtranssymbs, '.
            \                    'in *F.trfiles(), '.
            \                    '(path      match #\\v%(\\.json|/)$#), '.
            \                    '(idof var  match /\\v^[gb]/))', 'g')]
let s:cmdfun['@FWC'][0]=substitute(s:cmdfun['@FWC'][0], ' ', ' _ _ _ ', '')
function s:F.load()
    call s:_f.require('autoload/translit3', [0, 0], 1)
    let s:usedtranssymbs=s:_r.usedtranssymbs
    unlockvar s:F
    call remove(s:F, 'load')
    function s:F.load()
    endfunction
    lockvar! s:F
endfunction
function s:cmdfun.function(...)
    call s:F.load()
    return call(s:_r.cmd, a:000, {})
endfunction
call s:_f.command.add('Tr3Command', s:cmdfun, {'nargs': '+',
            \                                  'range': 1,
            \                                   'bang': 1,
            \                               'complete': s:cmdcomp})
"{{{2 Функции
let s:extfunctions={
            \'Tr3transliterate': {'@FWC': ['type "" '.
            \                              '['.s:ctr.']',  'filter']},
            \'Tr3add':           {'@FWC': ['match /./ '.
            \                              'type "" '.
            \                              '[:=(0) bool '.
            \                              '['.s:ctr.']]', 'filter']},
            \'Tr3include':       {'@FWC': ['match /./ '.
            \                              'either (type ("",{}),|isfunc) '.
            \                              '['.s:ctr.']',  'filter']},
            \'Tr3exclude':       {'@FWC': ['match /./ '.
            \                              'either (type ("",{}),|isfunc) '.
            \                              '['.s:ctr.']',  'filter']},
            \'Tr3del':           {'@FWC': ['match /./ '.
            \                              '[:=(0) bool '.
            \                              '['.s:ctr.']]', 'filter']},
            \'Tr3setoption':     {'@FWC': ['in [capital] '.
            \                              'in [first none] '.
            \                              'match /./ '.
            \                              '[:=(0) bool '.
            \                              '['.s:ctr.']]', 'filter']},
            \'Tr3deloption':     {'@FWC': ['in [capital] '.
            \                              'match /./ '.
            \                              '['.s:ctr.']',  'filter']},
            \'Tr3print':         {'@FWC': ['range -2 inf '.
            \                              '['.s:ctr.']',  'filter']},
        \}
for [s:key, s:val] in items(s:extfunctions)
    execute      "function s:val.function(...)\n".
                \"    call s:F.load()\n".
                \'    return call(s:_r.extfunctions.'.s:key.", a:000, {})\n".
                \'endfunction'
endfor
unlet s:key s:val
call s:_f.addextfunctions(s:extfunctions)
unlet s:ctr s:extfunctions
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
let s:strfunc={}
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
let s:mapfunc={}
let s:mgroup.TransliterateMotion.operator=1
let s:mgroup.TransliterateMotion.rhs={}
function s:F.mapfunc(...)
    call s:F.load()
    return call(s:_r.map, a:000, {})
endfunction
function s:strfunc.function(...)
    call s:F.load()
    return call(s:_r.str, a:000, {})
endfunction
function s:mgroup.TransliterateMotion.rhs.function(...)
    call s:F.load()
    return call(s:_r.trmotion, a:000, {})
endfunction
unlet s:strfunc
call s:_f.mapgroup.add('Tr3', s:mgroup, {'func': s:F.mapfunc, 'leader': '\t'})
unlet s:F.mapfunc s:mgroup
"}}}2
function s:F.trfiles()
    return  map(filter(s:_r.os.listdir(s:_f.getoption('ConfigDir')),
                \      'v:val[-5:] is# ".json"'),
                \'v:val[:-6]')
endfunction
"{{{1
call frawor#Lockvar(s:, '_r,usedtranssymbs')
" vim: ft=vim:ts=8:fdm=marker:fenc=utf-8
