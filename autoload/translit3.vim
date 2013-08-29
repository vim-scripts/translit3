"{{{1 Начало
scriptencoding utf-8
execute frawor#Setup('0.2', {'@/options': '0.0',
            \               '@/mappings': '0.0',
            \              '@/functions': '0.0',
            \                     '@/os': '0.0',
            \                  '@/table': '0.1',
            \   '@/decorators/altervars': '0.0',
            \                '@/history': '0.0',
            \              '@/resources': '0.0',
            \                   '@%json': '0.0',})
call map(['trs', 'tof', 'stuf', 'comm', 'mod', 'prnt', 'map', 'mng', 'comp',
            \], 'extend(s:F, {v:val : {}})')
let s:F.trs.plug={}
let s:F.tof.plug={}
"{{{1 Настройки
let s:_oprefix='tr3'
let s:_options={
            \'BrkSeq': {'default': '@', 'checker': 'type ""'},
            \'EscSeq': {'default': '\', 'checker': 'type ""'},
            \'StopTrSymbs': {'default': {'%': ''},
            \                'checker': 'dict {?type ""  type ""}'},
            \'StartTrSymbs': {'default': {'%': ''},
            \                 'checker': 'dict {?type ""  type ""}'},
            \'NoTransWord': {'default': {'%%': ''},
            \                'checker': 'dict {?type ""  type ""}'},
            \'Plugs': {'default': {'Before': ['brk'],
            \                       'After': ['esc', 'notransword', 'notrans']},
            \          'checker': 'dict {/\vBefore|After$/  '.
            \                              'list (either (key F.trs.plug, '.
            \                                     'tuple (isfunc 1, isreg)))}'},
            \'ToFPlugs': {'default': ['notransword', 'notrans', 'brk'],
            \             'checker': 'list (either '.
            \                              '(key F.tof.plug, '.
            \                               'tuple (isfunc 1, '.
            \                                      'either (list (type ""), '.
            \                                              'isreg))))'},
            \'DefaultTranssymb': {'default': 'transsymb'},
            \'ConfigDir': {'default': s:_r.os.path.join(expand('<sfile>:h:h'),
            \                                           'config', 'translit3'),
            \              'checker': 'path d'},
            \'WriteFunc': {'default': 0,
            \              'checker': 'either (is=(0), '.
            \                                 'key rewritefunc, '.
            \                                 '(type "" isfunc))'},
            \'BreakFunc': {'default': 0,
            \              'checker': 'either (is=(0), isfunc 1)'},
        \}
"{{{1 Выводимые сообщения
if v:lang=~?'ru' "{{{2
    let s:_messages={
            \    'list': 'Значение должно быть списком',
            \    'bool': 'Значение должно быть числом, равным либо нулю, '.
            \            'либо единице',
            \   'mnone': 'Ключ «none» не должен встречаться в корне '.
            \            'таблицы транслитерации',
            \   'trans': 'Если в качестве таблицы транслитерации указана '.
            \            'строка, то она должна быть либо именем файла, либо '.
            \            'именем глобальной или локальной (для буфера) '.
            \            'переменной',
            \   'onfnd': 'Требуемая настройка не найдена',
            \     'opt': 'Данная настройка уже указана',
            \    'narg': 'Неверное количество аргументов',
            \   'margs': 'Слишком большое количество аргументов',
            \   'largs': 'Недостаточно аргументов',
            \    'trex': 'Транслитерируемая последовательность уже существует',
            \    'trnf': 'Транслитерируемая последовательность не найдена',
            \    'trnd': 'Не удалось удалить транслитерируемую '.
            \            'последовательность',
            \    'tofs': 'Транслитерация по мере ввода уже запущена',
            \   'tofgs': 'Транслитерация по мере ввода уже запущена '.
            \            'для всех буферов',
            \   'tofns': 'Транслитерация по мере ввода ещё не запущена',
            \     'fnc': 'Невозможно вызвать функцию по предоставленной ссылке',
            \    'bnnf': 'Не удалось найти буфер с именем «%s»',
            \  'itrans': 'Неверная таблица транслитерации',
            \ 'incfail': 'Не удалось подключить одну из таблиц транслитерации',
            \  'notinc': '«%s» не включено',
            \     'nex': 'Нечего удалять',
            \    'ainc': '«%s» уже включено',
            \'cache': {
            \   'th': {
            \       'trans': ['Источник', 'Кэш вывода на экран',
            \                 'Кэш для транслитерации по мере ввода'],
            \   },
            \   'trsrc': {
            \       'gvar': 'Переменная',
            \       'bvar': 'Переменная %s буфера',
            \       'file': 'Файл',
            \       'func': 'Функция',
            \       'dict': 'Анонимный словарь',
            \   },
            \   'other': {
            \        'col': 'Для следующих количеств колонок:',
            \       'strl': 'Список строк',
            \         'll': 'Список списков',
            \         'no': 'Отсутствует',
            \        'yes': 'Существует',
            \   },
            \},
        \}
    call extend(s:_messages, map({
            \     'str': 'значение должно быть строкой',
            \   'klist': 'значение должно быть списком',
            \    'dict': 'значение должно быть словарём',
            \  'uknkey': 'неизвестрый ключ',
            \'invvalue': 'неверное значение: %s',
            \     'sdt': 'значение должно быть либо строкой, либо словарём',
            \}, '"Ошибка проверки «%s»: ".v:val'))
else "{{{2
    let s:_messages={
            \    'list': 'Value must be of a type “list”',
            \    'bool': 'Value must be number, equal to either 0 or 1',
            \   'mnone': 'Misplaced “none” key: '.
            \            'it mustn’t occur in the root of transsymb',
            \   'trans': 'If transliteration table is a string, '.
            \            'it must be either a variable name, '.
            \            'starting with g: or b:, or a filename',
            \   'onfnd': 'Option not found',
            \     'opt': 'Option already exists',
            \    'narg': 'Wrong number of arguments',
            \   'margs': 'Too many arguments',
            \   'largs': 'Not enough arguments',
            \    'trex': 'Transliteration sequence already exists',
            \    'trnf': 'Transliteration sequence not found',
            \    'trnd': 'Unable to delete transliteration sequence',
            \    'tofs': 'ToF already started',
            \   'tofgs': 'ToF already started for all buffers',
            \   'tofns': 'ToF not started yet',
            \     'fnc': 'Provided function reference is not callable',
            \    'bnnf': 'Buffer “%s” not found',
            \  'itrans': 'Invalid transliteration table',
            \ 'incfail': 'Failed to include one of transliteration tables',
            \  'notinc': '“%s” was not included',
            \     'nex': 'Nothing to exclude',
            \    'ainc': '“%s” already included',
            \'cache': {
            \   'th': {
            \       'trans': ['Table source', 'Print cache', 'ToF cache'],
            \   },
            \   'trsrc': {
            \       'gvar': 'Variable',
            \       'bvar': 'Variable %s local to buffer',
            \       'file': 'File',
            \       'func': 'Function reference',
            \       'dict': 'Unnamed dictionary',
            \   },
            \   'other': {
            \        'col': 'For column numbers:',
            \       'strl': 'String list',
            \         'll': 'List of lists only',
            \         'no': 'Absent',
            \        'yes': 'Exists',
            \   },
            \},
        \}
    call extend(s:_messages, map({
            \     'str': 'value must be of a type “string”',
            \   'klist': 'value must be of a type “list”',
            \    'dict': 'value must be of a type “dictionary”',
            \  'uknkey': 'unknown key',
            \'invvalue': 'invalid value: %s',
            \     'sdt': 'Value must be either string or dictionary',
            \}, '"Error while processing “%s”: ".v:val'))
endif
"{{{1 _unload
function s:._unload()
    call map(values(s:tofbufdicts), 's:F.tof.stop(v:val)')
endfunction
"{{{1 stuf
" Некоторые полезные вещи, не относящиеся непосредственно к плагину
"{{{2 stuf.strlen: получение длины строки
function s:F.stuf.strlen(str)
    return len(split(a:str, '\v.@='))
endfunction
"{{{2 stuf.iscombining: проверить, является ли символ диакритикой
" Если да, то вернуть его длину в байтах
" Unicode: combining diacritical marks: определение
" Wikipedia: http://en.wikipedia.org/wiki/Combining_character:
"   Combining Diacritical Marks (0300–036F)
"   Combining Diacritical Marks Supplement (1DC0–1DFF)
"   Combining Diacritical Marks for Symbols (20D0–20FF)
"   Combining Half Marks (FE20–FE2F)
function s:F.stuf.iscombining(char)
    let chnr=char2nr(a:char)
    if           (0x0300<=chnr && chnr<=0x036F) ||
                \(0x1DC0<=chnr && chnr<=0x1DFF) ||
                \(0x20D0<=chnr && chnr<=0x20FF) ||
                \(0xFE20<=chnr && chnr<=0xFE2F)
        return len(nr2char(chnr))
    endif
    return 0
endfunction
"{{{2 stuf.nextchar: получить следующий символ (reg('.'))
" Получить следующий символ. Если дан второй аргумент, то получить следующий за 
" позицией, данной во втором аргументе, символ.
function s:F.stuf.nextchar(str, ...)
    return matchstr(a:str, '\v.', ((len(a:000))?(a:000[0]):(0)))
endfunction
"{{{2 stuf.nextchar_nr получить следующий символ (nr2char(char2nr))
" То же, что и предыдущая функция, но получение следующего символа выполняется 
" с помощью nr2char(char2nr)
function s:F.stuf.nextchar_nr(str, ...)
    return nr2char(char2nr(a:str[((len(a:000))?(a:000[0]):(0)):]))
endfunction
"{{{2 stuf.checklod: проверить весь словарь или список
function s:F.stuf.checklod(subj, chk)
    return ((type(a:subj)==type({}))?
                \(index(values(map(copy(a:subj), a:chk)), 0)!=-1):
                \(index(map(copy(a:subj), a:chk), 0)!=-1))
endfunction
"{{{1 main: session
"{{{2 session: поддержка LoadCommand mksession
function s:F.session(...)
    if empty(a:000)
        let r={}
        let r.tof={}
        let r.tof.bufdict={}
        for [bufnr, bufdict] in items(s:tofbufdicts)
            let r.tof.bufdict[bufnr]=copy(bufdict)
            let r.tof.bufdict[bufnr].bufname=bufname(bufnr)
            unlet r.tof.bufdict[bufnr].plugs
            unlet r.tof.bufdict[bufnr].opts
            unlet r.tof.bufdict[bufnr].chlist
            unlet r.tof.bufdict[bufnr].bufnr
        endfor
        if exists('s:toftranssymb')
            let r.tof.transsymb=s:toftranssymb
        endif
        return r
    else
        let s=a:000[0]
        " Проверка ввода слишком сложна, поэтому я опускаю её
        if exists('s.tof.transsymb')
            call s:F.mng.tof(1, 'start', s.tof.transsymb)
        endif
        " Отменим все действующие транслитерации по мере ввода
        call s:F.mng.tof(1, 'stop')
        " Очистим кэш
        call s:F.mng.cache('purge', 'all')
        for [bufnr, bufdict] in items(s.tof.bufdict)
            let bufdict.chlist=[]
            let bufdict.opts={}
            let bufdict.plugs=[]
            " Здесь приходится идентифицировать буфер по имени, что не всегда 
            " надёжно
            let bufdict.bufnr=bufnr(bufdict.bufname)
            if empty(bufdict.bufnr)
                call s:_f.warn('bnnf', bufdict.bufname)
                continue
            endif
            unlet bufdict.bufname
            call s:F.comm.newcache(bufdict.transsymb.origin, bufdict.transsymb)
            call s:F.tof.setup(0, 0, bufdict)
        endfor
    endif
endfunction
"{{{1 comm: save, getresult, gettranssymb
" Функции, нужные для транслитерации
"{{{2 comm.remove: Удалить указанный id из кэша
function s:F.comm.remove(id)
    for cache in s:cache.trans
        call remove(cache, a:id)
    endfor
    for i in range(a:id, len(s:cache.trans[0])-1)
        unlockvar s:cache.trans[1][i].id
        let s:cache.trans[1][i].id-=1
        lockvar s:cache.trans[1][i].id
    endfor
endfunction
"{{{2 comm.save: сохранить изменения
function s:F.comm.save(transsymb)
    let id=a:transsymb.id
    if a:transsymb.origin isnot# s:cache.trans[0][id]
        call s:F.comm.remove(id)
    endif
    let src=(a:transsymb.source[0])
    if src is# 'file'
        return s:_r.json.dump(a:transsymb.source[1], a:transsymb.origin)
    elseif src is# 'gvar'
        execute 'let '.a:transsymb.source[1].'=a:transsymb.origin'
    elseif src is# 'bvar'
        if bufexists(a:transsymb.source[1][0])
            call call('setbufvar', a:transsymb.source[1]+[a:transsymb.origin])
            return 1
        endif
    elseif src is# 'func'
        return call(a:transsymb.source[1], [a:transsymb.origin], {})
    endif
    return 0
endfunction
"{{{2 comm.getresult: преобразовать результат в соответствие с флагами
function s:F.comm.getresult(result, flags)
    " Что-то изменяем, только если есть флаг верхнего регистра
    if a:flags.upper==1
        "{{{3 Если изменять регистр должна только первая буква
        if a:flags.fstupper==1
            " К сожалению, regex «\l» работает далеко не всегда
            let slist=split(a:result, '\zs')
            let slen=len(slist)
            let idx=0
            while idx<slen
                let upper=toupper(slist[idx])
                if upper isnot# slist[idx]
                    let slist[idx]=upper
                    break
                endif
                let idx+=1
            endwhile
            return join(slist, '')
        "{{{3 Если такого нет, но есть флаг верхнего регистра
        else
            return toupper(a:result)
        endif
        "}}}
    endif
    return a:result
endfunction
"{{{2 comm.checktrkey: проверить ключ
function s:F.comm.checktrkey(key, value, where)
    "{{{3 Объявление переменных
    let vtype=type(a:value)
    "{{{3 Если ключ — не один символ
    if a:key!~'^.$'
        "{{{4 Ключ «none»
        if a:key is# 'none'
            if vtype!=type('')
                call s:_f.warn('str', a:where)
                return 1
            elseif a:where is# '/none'
                call s:_f.warn('mnone')
                return 1
            else
                return 0
            endif
        "{{{4 Ключ «options»
        elseif a:key is# 'options'
            "{{{5 Значение — словарь,
            if vtype!=type({})
                call s:_f.warn('dict', a:where)
                return 1
            "{{{5 не являющийся пустым,
            elseif a:value=={}
                return 0
            "{{{5 имеющего строковый тип и значение «capital»,
            elseif s:F.stuf.checklod(copy(a:value),
                        \       'type(v:key)==type("") && v:key is# "capital"')
                call s:_f.warn('uknkey', a:where.'/...')
                return 1
            "{{{5 которому соответствует строковое значение,
            elseif type(a:value.capital)!=type('')
                call s:_f.warn('str', a:where.'/capital')
                return 1
            "{{{5 равное одной из строк: «none» или «first».
            elseif       a:value.capital isnot# 'none' &&
                        \a:value.capital isnot# 'first'
                call s:_f.warn('invvalue', a:where.'/capital', a:value.capital)
                return 1
            endif
        "{{{4 Ключ «include»
        elseif a:key is# 'include'
            if type(a:value)!=type([])
                call s:_f.warn('klist', a:where)
                return 1
            endif
        "{{{4 Неизвестный ключ
        else
            call s:_f.warn('uknkey', a:where)
            return 1
        endif
    "{{{3 Односимвольный ключ
    else
        if vtype==type('')
            return 0
        elseif vtype==type({})
            return s:F.comm.checktranssymb(a:value, a:where)
        else
            call s:_f.warn('sdt', a:where)
            return 1
        endif
    endif
    "}}}
    return 0
endfunction
"{{{2 comm.checktranssymb: проверить таблицу транслитерации
function s:F.comm.checktranssymb(transsymb, where)
    let errclist=values(map(copy(a:transsymb),
                \'s:F.comm.checktrkey(v:key, v:val, a:where."/".v:key)'))
    let result=0
    for errc in errclist
        let result+=errc
    endfor
    return result
endfunction
"{{{2 comm.formattr: перевести таблицу транслитерации во внутренний формат
function s:F.comm.formattr(transsymb)
    "{{{3 Таблица — словарь
    if type(a:transsymb)==type({})
        "{{{4 Объявление переменных
        let result={}
        "{{{4 Обход ключей
        for [key, value] in items(a:transsymb)
            "{{{5 Односимвольный ключ
            if key=~'^.$'
                let lower=tolower(key)
                "{{{6 Такой ключ уже есть
                if has_key(result, lower)
                    let result[lower][(key isnot# lower)]=
                                \s:F.comm.formattr(value)
                "{{{6 Такого ключа нет
                else
                    "{{{7 Ключ в верхем регистре
                    if lower isnot# key
                        let result[lower]=
                                    \[0, s:F.comm.formattr(value)]
                    "{{{7 В нижнем
                    else
                        let result[lower]=
                                    \[s:F.comm.formattr(value), 1]
                        "{{{8 Проверка настроек
                        if type(value)==type({}) &&
                                    \has_key(value, 'options') &&
                                    \has_key(value.options, 'capital')
                            let cap=value.options.capital
                            if cap is# 'none'
                                let result[lower][1]=0
                            elseif cap is# 'first'
                                let result[lower][1]=2
                            endif
                        endif
                        "}}}8
                    endif
                    "}}}7
                endif
            "{{{5 Ключ «none»
            elseif key is# 'none'
                let result.none=value
            "{{{5 Ключ «include»
            elseif key is# 'include'
                let newtrs=map(copy(value),'copy(s:F.comm.gettranssymb(v:val))')
                for transsymb in newtrs
                    if transsymb is 0
                        call s:_f.warn('incfail')
                        return 0
                    endif
                    unlet transsymb.origin
                    unlet transsymb.source
                    call extend(result, deepcopy(transsymb), 'keep')
                    unlet transsymb
                endfor
                unlet newtrs
            endif
            "}}}5
            unlet value
        endfor
        "}}}4
        return result
    "{{{3 Таблица — не словарь (строка)
    else
        return {'none': a:transsymb}
    endif
    "}}}
endfunction
"{{{2 comm.newcache:     добавить запись в кэш
function s:F.comm.newcache(srctrans, innertrans)
    let a:innertrans.id=len(s:cache.trans[0])
    call add(s:cache.trans[0], deepcopy(a:srctrans))
    call add(s:cache.trans[1], a:innertrans)
    call add(s:cache.trans[2], deepcopy(s:cache.init.print))
    call add(s:cache.trans[3], [])
endfunction
"{{{2 comm.gettranssymb: получить таблицу транслитерации
let s:usedtranssymbs=[]
function s:F.comm.gettranssymb(...)
    "{{{3 Получение таблицы внешнего формата
    let d={}
    if a:0 && a:1 isnot 0
        let d.Trans=a:1
    else
        let d.Trans=s:_f.getoption('DefaultTranssymb')
    endif
    let rettrans={}
    if type(d.Trans)==type('')
        if d.Trans=~#'^[gb]:[a-zA-Z_]\(\w\@<=\.\w\|\w\)*$'
            if exists(d.Trans)
                let rettrans=eval(d.Trans)
                if d.Trans[0] is# 'b'
                    let src=['bvar', [bufnr('%'), d.Trans[2:]]]
                else
                    let src=['gvar', d.Trans]
                endif
            else
                call s:_f.warn('trans')
                return 0
            endif
        elseif d.Trans=~#'\v^\.|\.json$|[\\/]' && filereadable(d.Trans)
            let fname=fnamemodify(d.Trans, ':p')
            let rettrans=s:_r.json.load(fname)
            let src=['file', fname]
        else
            let fname=s:_r.os.path.join(s:_f.getoption('ConfigDir'),
                        \               d.Trans.'.json')
            let fname=fnamemodify(fname, ':p')
            if filereadable(fname)
                let rettrans=s:_r.json.load(fname)
                let src=['file', fname]
            else
                call s:_f.warn('trans')
                return 0
            endif
        endif
    elseif type(d.Trans)==type({})
        let rettrans=d.Trans
        let src=['dict', rettrans]
        " 2 — Funcref
    elseif type(d.Trans)==2
        if !exists('*d.Trans')
            call s:_f.warn('fnc')
            return 0
        endif
        let rettrans=call(d.Trans, [], {})
        let src=['func', d.Trans]
    else
        call s:_f.warn('itrans')
        return 0
    endif
    "{{{3 Кэш
    let idx=index(s:cache.trans[0], rettrans)
    let docheck=1
    if idx!=-1 && s:cache.trans[1][idx]!={}
        let docheck=0
        let fidx=idx
        while s:cache.trans[1][idx].source isnot# src && idx!=-1
            let idx=index(s:cache.trans[0], rettrans, idx+1)
        endwhile
        if idx!=-1
            return s:cache.trans[1][idx]
        endif
    elseif idx==-1
        let idx=0
        while idx<len(s:cache.trans[1])
            if s:cache.trans[1][idx].source is# src
                call s:F.comm.remove(idx)
            else
                let idx+=1
            endif
        endwhile
    endif
    "{{{3 Получение таблицы транслитерации внут. формата и запись её в кэш
    if docheck
        "{{{4 Проверка правильности
        if s:F.comm.checktranssymb(rettrans, '')
            return 0
        endif
        let curtrans=s:F.comm.formattr(rettrans)
        if curtrans is 0
            return 0
        endif
        "}}}4
    else
        let curtrans=deepcopy(s:cache.trans[1][fidx])
        unlet curtrans.origin
        unlet curtrans.source
    endif
    let result=extend(curtrans,
                \{'origin': rettrans,
                \ 'source': src})
    " Делая глубокое копирование здесь, мы защищаемся от устаревания словаря: 
    " когда изменения в исходный словарь внесены, но ещё не внесены 
    " в преобразованный словарь
    call s:F.comm.newcache(rettrans, result)
    if index(['file', 'gvar', 'bvar'], curtrans.source[0])!=-1 &&
                \index(s:usedtranssymbs, curtrans.source[1])==-1
        call add(s:usedtranssymbs, curtrans.source[1])
    endif
    lockvar! result
    unlockvar! result.origin
    "}}}3
    return result
endfunction
call s:_f.postresource('usedtranssymbs', s:usedtranssymbs)
function s:F.comm.gettranssymb_throw(...)
    let r=call(s:F.comm.gettranssymb, a:000, {})
    if type(r)!=type({})
        call s:_f.throw('itrans')
    endif
    return r
endfunction
"{{{1 trs:  main(transliterate): обычная транслитерация
"{{{2 Default flags and status
let s:trsdefflags={
            \      'upper': -1,
            \   'fstupper': 0,
            \   'transbeg': 0,
            \}
let s:trsdefstatus={
            \     'status': 'failure',
            \     'result': '',
            \      'delta':  0,
            \}
"{{{2 trs.plug: дополнения для обычной транслитерации
"{{{3 trs.plug.esc: экранировать следующий символ
function s:F.trs.plug.esc(match, str, transsymb, cache, flags)
    let result=s:F.stuf.nextchar(a:str)
    let rlen=len(result)
    if !rlen
        let result=a:match
    endif
    return {
                \'status': 'success',
                \'result':     result,
                \ 'delta': len(result),
                \ 'flags': a:flags,
            \}
endfunction
"{{{3 trs.plug.notransword: не транслитерировать следующее слово
function s:F.trs.plug.notransword(match, str, transsymb, cache, flags)
    let result=a:cache.NoTransWord.value[a:match]
    let ntr=matchstr(a:str, '\v^\S*')
    let delta=len(ntr)
    let result.=ntr
    return {
                \'status': 'success',
                \'result':  result,
                \ 'delta':  delta,
                \ 'flags': copy(s:trsdefflags),
            \}
endfunction
"{{{3 trs.plug.notrans: временное прерывание транслитерации
function s:F.trs.plug.notrans(match, str, transsymb, cache, flags)
    let result=a:cache.StopTrSymbs.value[a:match]
    let ntrstr=''
    let startstr=''
    let delta=0
    let escreg=a:cache.EscSeq.regex
    let startreg=a:cache.StartTrSymbs.regex
    if !empty(startreg)
        let startreg.='|%$'
    else
        let startreg='%$'
    endif
    if empty(escreg)
        let ntr=matchlist(a:str, '\v^(\_.{-})\C('.startreg.')')
        let delta+=len(ntr[0])
        let ntrstr=ntr[1]
        let startstr=ntr[2]
    else
        let slen=len(a:str)
        let startstr=''
        while delta<slen
            " XXX (%()@>) is not the same as ()@> due to NFA regexp engine bug 
            " present in recent vim versions as reported in
            "   https://groups.google.com/forum/#!topic/vim_dev/DTA0LrEFBDc
            " : “[BUG] New regexp engine bug: capturing group with @> voids all 
            " preceding capturing groups contents”
            let ntr=matchlist(a:str,
                        \'\v^(\_.{-})\C(%(%('.escreg.')*)@>)'.
                        \   '('.startreg.')', delta)
            let esccount=len(ntr[2])/a:cache.EscSeq.len
            let delta+=len(ntr[0])
            if esccount%2==0
                let ntrstr.=ntr[1].ntr[2]
                let startstr=ntr[3]
                break
            endif
            let ntrstr.=ntr[0]
        endwhile
        let ntrstr=substitute(ntrstr, escreg.'\v(.)', '\1', 'g')
    endif
    if !empty(startstr)
        let ntrstr.=a:cache.StartTrSymbs.value[startstr]
    endif
    return {
                \'status': 'success',
                \'result':  (result).(ntrstr),
                \ 'delta':   delta,
                \ 'flags': copy(s:trsdefflags),
            \}
endfunction
"{{{3 trs.plug.brk: прерывание транслитерируемой последовательности
"{{{4 s:trsbrkresult
let s:trsbrkresult={
                \'status': 'success',
                \'result': '',
                \ 'delta':  0,
                \ 'flags': s:trsdefflags,
            \}
"}}}4
function s:F.trs.plug.brk(match, str, transsymb, cache, flags)
    return deepcopy(s:trsbrkresult)
endfunction
"{{{2 trs.plugrun: запуск дополнений
function s:F.trs.plugrun(plug, str, transsymb, cache, flags)
    let matchidx=match(a:str, '\v^\C%('.(a:plug[1]).')')
    if matchidx==0
        let match=matchstr(a:str, '\v^\C%('.(a:plug[1]).')')
        let lastret=call(a:plug[0], [match, a:str[len(match):], a:transsymb,
                    \a:cache, a:flags], {})
        let lastret.delta+=len(match)
        return lastret
    endif
    return s:trsdefstatus
endfunction
"{{{2 trs.setstatus: изменение возвращаемого результата
function s:F.trs.setstatus(retstatus, lastret)
    if a:lastret.status isnot# 'failure'
        let result=s:F.comm.getresult(a:lastret.result,
                    \                  a:lastret.flags)
        if a:retstatus.status is# 'plugsuccess' ||
                    \a:lastret.status is# 'plugsuccess'
            let a:retstatus.result=result.(a:retstatus.result)
        else
            let a:retstatus.result.=result
        endif
        let a:retstatus.status = a:lastret.status
        let a:retstatus.delta += a:lastret.delta
        let a:retstatus.flags  = copy(s:trsdefflags)
    endif
    return a:retstatus
endfunction
"{{{2 trs.transliterate: транслитерация одной последовательности
function s:F.trs.transliterate(str, transsymb, cache, flags)
    "{{{3 Объявление переменных
    let retstatus=copy(s:trsdefstatus)
    let retstatus.flags=a:flags
    let chknone=!retstatus.flags.transbeg
    "{{{3 Плагины, которые надо запускать до транслитерации
    for plug in a:cache.Plugs.Before
        let lastret=s:F.trs.plugrun(plug, a:str[(retstatus.delta):],
                    \a:transsymb, a:cache, retstatus.flags)
        call s:F.trs.setstatus(retstatus, lastret)
        if retstatus.status is# 'success'
            if !retstatus.flags.transbeg
                let chknone=1
                let retstatus.status='plugsuccess'
            endif
            break
        endif
    endfor
    "{{{3 Транслитерация
    "{{{4 Объявление переменных
    let curch=s:F.stuf.nextchar(a:str, retstatus.delta)
    let lower=tolower(curch)
    "{{{4 Если есть ключ, соответствующий следующему символу
    if has_key(a:transsymb, lower) && retstatus.status isnot# 'success' &&
                \retstatus.status isnot# 'plugsuccess'
        let [lwtrans, uptrans]=a:transsymb[lower]
        "{{{5 Флаги
        if type(uptrans)==type(0)
            if uptrans==2
                let retstatus.flags.fstupper=1
            elseif uptrans==0
                let retstatus.flags.upper=-2
            endif
        endif
        let isupper=(lower isnot# curch)
        let hasupper=(lower isnot# toupper(curch))
        if  retstatus.flags.upper==-1 && hasupper
            let retstatus.flags.upper=isupper
        endif
        "{{{5 Транслитерация
        let dlen=retstatus.delta+len(curch)
        let flags=copy(retstatus.flags)
        let flags.transbeg=0
        if isupper && type(uptrans)==type({})
            let lastret=s:F.trs.transliterate(a:str[(dlen):], uptrans, a:cache,
                        \flags)
        elseif type(lwtrans)==type({}) &&
                    \!(isupper &&
                    \   !(retstatus.flags.upper==-1 ||
                    \       retstatus.flags.upper==1))
            let lastret=s:F.trs.transliterate(a:str[(dlen):], lwtrans, a:cache,
                        \flags)
        else
            let lastret=s:trsdefstatus
        endif
        "{{{5 Успешное завершение
        if lastret.status isnot# 'failure'
            let transbeg=retstatus.flags.transbeg
            call s:F.trs.setstatus(retstatus, lastret)
            if retstatus.status isnot# 'plugsuccess'
                let retstatus.delta+=len(curch)
            else
                let retstatus.flags.transbeg=transbeg
            endif
            let chknone=0
        endif
        "}}}5
    endif
    "{{{4 Если есть ключ «none» и его надо проверить
    " Проверять его надо в случае, если это не первая итерация (за это 
    " ответственен флаг transbeg), и транслитерация не завершилась успехом 
    " ранее
    if (chknone || retstatus.status is# 'plugsuccess') &&
                \has_key(a:transsymb, 'none')
        call s:F.trs.setstatus(retstatus, {
                    \'status': 'success',
                    \ 'delta':  0,
                    \'result': a:transsymb.none,
                    \ 'flags': retstatus.flags,
                \})
    endif
    "{{{3 Плагины, которые надо запускать после транслитерации
    if retstatus.status isnot# 'success' && retstatus.flags.transbeg
        if retstatus.status isnot# 'plugsuccess'
            for plug in a:cache.Plugs.After
                let lastret=s:F.trs.plugrun(plug, a:str[(retstatus.delta):],
                            \a:transsymb, a:cache, retstatus.flags)
                call s:F.trs.setstatus(retstatus, lastret)
                if lastret.status is# 'success'
                    break
                endif
            endfor
        endif
        if (retstatus.status is# 'failure' && !retstatus.delta && len(curch)) ||
                    \retstatus.status is# 'plugsuccess'
            call s:F.trs.setstatus(retstatus, {
                        \'status': 'success',
                        \ 'delta':  len(curch),
                        \'result':      curch,
                        \ 'flags': copy(s:trsdefflags),
                    \})
            let retstatus.status='failure'
        endif
    endif
    "}}}3
    return retstatus
endfunction
"{{{2 trs.getplugin
"{{{3 s:plugregex
" plugregex — словарь, в котором написано для каких плагинов нужны какие
"             регулярные выражения, полученные из настроек
let s:plugregex={
            \   'notransword': 'NoTransWord',
            \           'brk': 'BrkSeq',
            \           'esc': 'EscSeq',
            \       'notrans': 'StopTrSymbs',
            \}
"}}}3
function s:F.trs.getplugin(plugin, cache)
    if type(a:plugin)==type('')
        let regex=a:cache[s:plugregex[a:plugin]].regex
        if empty(regex)
            return 0
        endif
        return [s:F.trs.plug[a:plugin], regex]
    endif
    return a:plugin
endfunction
"{{{2 trs.main: транслитерация всей строки
"{{{3 s:stropt, s:dictstrstropt
"    stropt — перечисление настроек строкового типа, которые нужно превратить
"             в регулярные выражения
" dictstrstropt — то же самое для настроек-словарей с парами строка-строка
"}}}3
let s:stropt=['EscSeq', 'BrkSeq']
let s:dictstrstropt=['StartTrSymbs', 'StopTrSymbs', 'NoTransWord']
function s:F.trs.main(str, transsymb)
    "{{{3 Кэш: настройки
    let cache={}
    "{{{4 Простые строковые
    for O in s:stropt
        let opt=s:_f.getoption(O)
        if !empty(opt)
            let optregex='\V'.escape(opt, '\').'\v'
        else
            let optregex=''
        endif
        call extend(cache, {(O): {'value': opt, 'regex': optregex}})
    endfor
    let cache.EscSeq.len=len(cache.EscSeq.value)
    unlet opt
    "{{{4 Словарь {строка: строка, …}
    for O in s:dictstrstropt
        let opt=s:_f.getoption(O)
        let optregexs = map(copy(opt), 'escape(v:key, "\\")')
        let optregex  = join(values(optregexs), '\|')
        if !empty(optregex)
            let optregex='\V'.optregex.'\v'
        endif
        call extend(cache, {(O): {'value': opt, 'regex': optregex}})
    endfor
    "{{{4 Плагины
    let plugs=s:_f.getoption('Plugs')
    let cache.Plugs={'Before': [], 'After': []}
    for key in keys(plugs)
        let cache.Plugs[key]=filter(map(copy(plugs[key]),
                    \                   's:F.trs.getplugin(v:val, cache)'),
                    \               'type(v:val)=='.type([]))
    endfor
    "}}}4
    lockvar! cache
    "{{{3 Объявление переменных
    let result=''
    let str=a:str
    let flags=copy(s:trsdefflags)
    let flags.transbeg=1
    "{{{3 Основной цикл
    while len(str)
        let lastret=s:F.trs.transliterate(str, a:transsymb, cache, copy(flags))
        let result.=lastret.result
        let str=str[(lastret.delta):]
    endwhile
    "}}}3
    return result
endfunction
"{{{1 tof:  setup, stop, transchar: транслитерация по мере ввода
"{{{2 augroup ToFBufDict
let s:tofbufdicts={}
function s:F.tof.adddict(bufnr)
    if exists('s:toftranssymb') && !has_key(s:tofbufdicts, a:bufnr)
        let s:tofbufdicts[a:bufnr]=s:F.tof.setup(a:bufnr, s:toftranssymb)
    endif
endfunction
function s:F.tof.wipeoutbuf(bufnr)
    if has_key(s:tofbufdicts, a:bufnr)
        call s:F.tof.stop(s:tofbufdicts[a:bufnr])
    endif
endfunction
augroup ToFBufDict
    autocmd BufWipeOut * :call s:F.tof.wipeoutbuf(expand('<abuf>'))
    autocmd BufAdd     * :call s:F.tof.adddict(expand('<abuf>'))
augroup END
let s:_augroups=get(s:, '_augroups', [])+['ToFBufDict']
"{{{2 Some globals
let s:tofuntrcp={'time': 0, 'buffer': 0}
let s:tofuntrcpchars=[]
let s:tofdefflags={
            \      'upper': -1,
            \   'fstupper': 0,
            \}
let s:failresult={'status': 'failure',}
let s:tofinitvars={'notrans': 0, 'notransword': 0, 'ntword': '',
            \      'ntwline': 0,}
let s:bs="\ecl"
"{{{2 tof.*_w: Поддержка нестандартных способов ввода
function s:F.tof.conque_w(str)
    let str=''
    if type(a:str)==type('')
        let str=a:str
    else
        let str=eval('"'.escape(a:str.lhs, '"<').'"')
    endif
    if &filetype is# 'conque_term'
        let lbs=len(s:bs)
        let start=''
        while str[0:(lbs-1)] is# s:bs
            let start.="\<C-h>"
            let str=str[(lbs):]
        endwhile
        let str=start.str
        call conque_term#get_instance().write(str)
    else
        call 'normal! i'.str
    endif
endfunction
"{{{2 tof.plug: плагины для транслитерации по мере ввода
"{{{3 tof.plug.notrans: временно прервать транслитерацию
function s:F.tof.plug.notrans(bufdict, char)
    if a:bufdict.vars.notrans
        if ((a:bufdict.vars.notrans==2)?
                    \   (s:F.tof.insyn('.', '.', 'comment')):
                    \   (1)) &&
                    \has_key(a:bufdict.opts.StartTrSymbs.value, a:char)
            let a:bufdict.vars.notrans=0
            return      {'status': 'stopped',
                        \'result': a:bufdict.opts.StartTrSymbs.value[a:char]}
        endif
        return      {'status': 'success',
                    \'result': s:F.tof.getuntrans(a:bufdict, a:char)}
    endif
    if has_key(a:bufdict.opts.StopTrSymbs.value, a:char)
        let a:bufdict.vars.notrans=1
        let d={}
        for [d.Func, d.Dummy] in a:bufdict.plugs
            if d.Func==s:F.tof.plug.comm
                let a:bufdict.vars.notrans=2
                break
            elseif d.Func==s:F.tof.plug.notrans
                break
            endif
        endfor
        return      {'status': 'started',
                    \'result': a:bufdict.opts.StopTrSymbs.value[a:char]}
    endif
    return s:failresult
endfunction
"{{{3 tof.plug.brk: прервать транслитерируемую последовательность
let s:tofbrkresult={'status': 'success',
            \       'result': ''}
function s:F.tof.plug.brk(bufdict, char)
    return s:tofbrkresult
endfunction
"{{{3 tof.plug.comm: Транслитерировать только внутри комментария
function s:F.tof.plug.comm(bufdict, char)
    if s:F.tof.insyn('.', '.', 'comment')
        return s:failresult
    endif
    return      {'status': 'success',
                \'result': s:F.tof.getuntrans(a:bufdict, a:char)}
endfunction
"{{{3 tof.plug.notransword: Не транслитерировать следующее слово
function s:F.tof.plug.notransword(bufdict, char)
    if a:bufdict.vars.notransword
        let curline=line('.')
        let curcol=col('.')
        let curlinestr=getline(curline)
        let curlinestr=substitute(curlinestr, '\%'.curcol.'c.*', '', '')
        if a:char!~#'^\k*$' ||
                    \((a:bufdict.vars.ntwline!=curline &&
                    \  a:bufdict.vars.ntwline!=curline-1) ||
                    \ curlinestr!~#'\V'.escape(a:bufdict.vars.ntword, '\').'\$')
            let a:bufdict.vars.notransword=0
            return {'status': 'stopped'}
        endif
        let a:bufdict.vars.ntword.=a:char
        return      {'status': 'success',
                    \'result': s:F.tof.getuntrans(a:bufdict, a:char)}
    endif
    if has_key(a:bufdict.opts.NoTransWord.value, a:char)
        let a:bufdict.vars.notransword=1
        let a:bufdict.vars.ntwline=line('.')
        let a:bufdict.vars.ntword=''
        return      {'status': 'started',
                    \'result': a:bufdict.opts.NoTransWord.value[a:char]}
    endif
    return s:failresult
endfunction
"{{{2 tof.insyn
function s:F.tof.insyn(line, col, reg)
    let line=line(a:line)
    let col=col(a:col)
    let stack=[]
    " synstack cannot work if line is empty
    if col([line, '$'])==1
        call add(stack, synID(line, 1, 0))
    else
        let lastcol=col([line, '$'])
        if col>=lastcol
            let col=lastcol-1
        endif
        try
            " It will emit type error if synstack will return something other 
            " then a list
            let stack=synstack(line, col)
            " But it may emit other error as well
        catch
            call add(stack, synID(line, 1, 0))
        endtry
    endif
    while !empty(stack)
        if synIDattr(remove(stack, -1), 'name')=~?a:reg
            return 1
        endif
    endwhile
    return 0
endfunction
"{{{2 tof.plugrun: запустить плагин
function s:F.tof.plugrun(bufdict, char, plug, idx)
    let retstatus=call(a:plug[0], [a:bufdict, a:char], {})
    if retstatus.status is# 'started' && index(a:bufdict.curplugs, a:idx)==-1
        call insert(a:bufdict.curplugs, a:idx)
    elseif retstatus.status is# 'stopped'
        call remove(a:bufdict.curplugs, index(a:bufdict.curplugs, a:idx))
    endif
    return retstatus
endfunction
"{{{2 tof.getuntrans: получить нетранслитерированный результат
function s:F.tof.getuntrans(bufdict, char)
    if has_key(a:bufdict.exmaps, a:char)
        let exmap=a:bufdict.exmaps[a:char]
        if type(a:bufdict.writefunc)==type(0)
            "{{{3 Попытка предотвращения рекурсивных вызовов
            if a:bufdict.bufnr>0
                let untrcp= {  'time': localtime(),
                            \'buffer': a:bufdict.bufnr}
                if untrcp==s:tofuntrcp
                    if index(s:tofuntrcpchars, a:char)!=-1
                        return a:char
                    else
                        call add(s:tofuntrcpchars, a:char)
                    endif
                else
                    call extend(s:tofuntrcp, untrcp, 'force')
                    if !empty(s:tofuntrcpchars)
                        call remove(s:tofuntrcpchars, 0, -1)
                    endif
                    call add(s:tofuntrcpchars, a:char)
                endif
            endif
            "}}}3
            " Не парим себе мозги относительно того, что надо вернуть, чтобы 
            " привязка работала как будто транслитерация по мере ввода не 
            " запущена
            let newmap=copy(exmap)
            let newmap.lhs='<Plug>Translit3TempMap'
            let newmap.buffer=1
            call s:_r.map.map(newmap)
            " По непонятной причине feedkeys непосредственно в скрипте не 
            " работает, поэтому используется следующий хак
            return "\<C-r>=[feedkeys(\"\\<Plug>Translit3TempMap\"), ''][1]\n"
        else
            " Если WriteFunc определена, то она должна также и заботиться 
            " о старых привязках
            return exmap
        endif
    endif
    return a:char
endfunction
"{{{2 tof.testbreak: определить, надо ли завершать последовательность
function s:F.tof.testbreak(bufdict, char)
    let [curline, curcol]=getpos('.')[1:2]
    if a:bufdict.lastline!=curline && a:bufdict.lastline!=curline-1
        return 1
    endif
    let curlinestr=''
    if curcol==col('$')
        let curlinestr=getline(curline)
    else
        let curlinestr=substitute(getline(curline)[:(curcol-1)], '.$', '', '')
    endif
    if curlinestr[(-len(a:bufdict.curtrseq)):] is# a:bufdict.curtrseq
        return 0
    endif
    return 1
endfunction
function s:F.tof.testbreakdummy(...)
    return 0
endfunction
"{{{2 tof.transchar: обработать полученный символ
function s:F.tof.transchar(bufdict, char)
    let lower=tolower(a:char)
    "{{{3 Плагины
    "{{{4 Если сейчас действует плагин
    let plugresult=''
    for idx in a:bufdict.curplugs
        let retstatus=s:F.tof.plugrun(a:bufdict, a:char,
                    \a:bufdict.plugs[idx], idx)
        if retstatus.status is# 'pass'
            if has_key(retstatus, 'result')
                let plugresult.=retstatus.result
            endif
        elseif retstatus.status isnot# 'failure'
            if has_key(retstatus, 'result')
                return retstatus.result
            endif
        endif
    endfor
    "{{{4 Если нет действующего плагина
    if len(a:bufdict.curtrans)==1
        let i=0
        while i<len(a:bufdict.plugs)
            let d={}
            let d.P=a:bufdict.plugs[i]
            if           (type(d.P[1])==type([]) && index(d.P[1],a:char)!=-1) ||
                        \(type(d.P[1])==type('') && a:char=~#d.P[1])
                let retstatus=s:F.tof.plugrun(a:bufdict, a:char, d.P, i)
                if retstatus.status is# 'pass'
                    if has_key(retstatus, 'result')
                        let plugresult.=retstatus.result
                    endif
                elseif retstatus.status isnot# 'failure'
                    if has_key(retstatus, 'result')
                        return retstatus.result
                    endif
                endif
            endif
            let i+=1
        endwhile
    endif
    "{{{3 Транслитерация
    "{{{4 Объявление переменных
    let isupper=(lower isnot# a:char)
    let [curline, curcol]=getpos('.')[1:2]
    let curlinestr=''
    if curcol==col('$')
        let curlinestr=getline(curline)
    else
        let curlinestr=substitute(getline(curline)[:(curcol-1)], '.$', '', '')
    endif
    "{{{4 Прерывание последовательности
    if len(a:bufdict.curtrans)>1 && (a:bufdict.testbreak(a:bufdict, a:char) ||
                \ (isupper && a:bufdict.flags.upper==0 &&
                \  !(has_key(a:bufdict.curtrans[-1], lower) &&
                \    type(a:bufdict.curtrans[-1][lower][1])==type({}))))
        return s:F.tof.transbreak(a:bufdict, a:char, plugresult)
    endif
    let a:bufdict.lastline=curline
    "{{{4 Собственно, транслитерация
    if has_key(a:bufdict.curtrans[-1], lower)
        "{{{5 Таблица транслитерации
        let [lwtrans, uptrans]=a:bufdict.curtrans[-1][lower]
        "{{{6 Верхний регистр
        if isupper
            let a:bufdict.flags.upper=(1 && a:bufdict.flags.upper!=0)
            " Есть вариант для символа в верхем регистре
            if type(uptrans)==type({})
                let curtrans=uptrans
            " Такого варианта нет, смены регистра нижний → верхний не было
            elseif uptrans==1 || uptrans==2
                let curtrans=lwtrans
                let a:bufdict.flags.fstupper=
                            \(uptrans==2 || a:bufdict.flags.fstupper)
            " Произошла смена регистра
            elseif uptrans==0
                return s:F.tof.transbreak(a:bufdict, a:char, plugresult)
            endif
        "{{{6 Не верхий регистр
        elseif type(lwtrans)==type({})
            let curtrans=lwtrans
            if a:bufdict.flags.upper==-1 && lower isnot# toupper(a:char)
                let a:bufdict.flags.upper=0
            endif
            if type(uptrans)==type(0)
                if uptrans==0
                    let a:bufdict.flags.upper=0
                elseif uptrans==2
                    let a:bufdict.flags.fstupper=1
                endif
            endif
        "{{{6 Символ отсутствует в таблице транслитерации
        else
            return s:F.tof.transbreak(a:bufdict, a:char, plugresult)
        endif
        "}}}6
        call add(a:bufdict.curtrans, curtrans)
        let bsseq=''
        "{{{5 Транслитерация символа
        if has_key(curtrans, 'none')
            " Результат транслитерации
            let result=s:F.comm.getresult(curtrans.none, a:bufdict.flags)
            " Замена предыдущего результата транслитерации
            let bsseq=repeat(s:bs, s:F.stuf.strlen(a:bufdict.curtrseq))
            "{{{6 Combining diacritics
            let fch=s:F.stuf.nextchar(a:bufdict.curtrseq)
            let a:bufdict.curtrseq=result
            let combd=s:F.stuf.iscombining(fch)
            if combd
                let combdlen=combd
                let combdcount = !!combd
                while combd
                    let combd=s:F.stuf.iscombining(fch[(combdlen):])
                    let combdlen+=combd
                    let combdcount += !!combd
                endwhile
                let ch=matchstr(curlinestr, '\v.$')
                let result=(ch[:(-1-combdlen)]).result
            endif
            "}}}6
        else
            let a:bufdict.curtrseq.=(a:char)
            let result=a:char
        endif
        return bsseq.plugresult.result
        "}}}5
    else
        return s:F.tof.transbreak(a:bufdict, a:char, plugresult)
    endif
    "{{{3 Несколько символов
    let clist=split(a:char, '\zs')
    if len(clist)>1
        return join(map(clist, 's:F.tof.transchar(a:bufdict, v:val)'), '')
    endif
    "}}}3
endfunction
"{{{2 tof.transbreak: прервать последовательность
" Прервать последовательность и, возможно, вызвать tof.transchar
function s:F.tof.transbreak(bufdict, char, ...)
    let dotrans=(len(a:bufdict.curtrans)>1)
    call s:F.tof.breakseq(a:bufdict)
    if dotrans
        return s:F.tof.transchar(a:bufdict, a:char)
    else
        return ((len(a:000))?(a:000[0]):('')).a:char
    endif
endfunction
"{{{2 tof.breakseq: прервать последовательность
function s:F.tof.breakseq(bufdict)
    let a:bufdict.curtrans=[a:bufdict.transsymb]
    let a:bufdict.curtrseq=''
    let a:bufdict.flags=copy(s:tofdefflags)
    let a:bufdict.lastline=-2
    let a:bufdict.vars=deepcopy(s:tofinitvars)
    return 1
endfunction
"{{{2 tof.map: создать привязку
function s:F.tof.map(bufdict, char)
    if empty(a:char)
        return 0
    endif
    let exmap=s:_r.map.maparg(a:char, 'i', 0)
    if !empty(exmap)
        let a:bufdict.exmaps[a:char]=exmap
    endif
    let rhs='call(<SID>Eval("s:F.tof.transchar"), '.
                \     '[<SID>Eval("s:tofbufdicts['.
                \               (a:bufdict.bufnr).']"),'.
                \      '"'.substitute(
                \           substitute(escape(a:char, '>|"\'),
                \                     "\n", '\\n', 'g'),
                \           "\r", '\\r', 'g').'"], {})'
    if type(a:bufdict.writefunc)!=type(0)
        let rhs='<C-\><C-o>:call call('.a:bufdict.writefunc.',['.rhs.'],{})<CR>'
    endif
    call s:_r.map.map({
                \    'lhs': a:char,
                \    'rhs': rhs,
                \ 'silent': 0,
                \'noremap': 1,
                \   'expr': (type(a:bufdict.writefunc)==type(0)),
                \ 'buffer': 1,
                \   'mode': 'i',
                \    'sid': s:_sid,
                \   'type': 'map',
            \})
    return 1
endfunction
"{{{2 tof.formattrlistch: список всех символов
" Создать список всех символов в таблице транслитерации
function s:F.tof.formattrlistch(transsymb)
    " Словарь выбран для того, чтобы не заботится об уникальности символа.
    let result={}
    for key in keys(a:transsymb)
        if key=~'^.$'
            let [lwtrans, uptrans]=a:transsymb[key]
            let upper=toupper(key)
            if key isnot# upper
                if type(uptrans)==type(0) && uptrans!=0
                    let result[upper]=''
                elseif type(uptrans)==type({})
                    let result[upper]=''
                    call extend(result, s:F.tof.formattrlistch(uptrans))
                endif
            endif
            if type(lwtrans)!=type(0)
                let result[key]=''
                call extend(result, s:F.tof.formattrlistch(lwtrans))
            endif
            unlet lwtrans
            unlet uptrans
        endif
    endfor
    return result
endfunction
"{{{2 tof.addtochlist: добавить символы к списку символов
function s:F.tof.addtochlist(bufdict, char)
    if index(a:bufdict.chlist, a:char)==-1
        call add(a:bufdict.chlist, a:char)
    endif
    if s:F.stuf.strlen(a:char)>1
        call map(split(a:char, '\zs'),
                    \'s:F.tof.addtochlist(a:bufdict, v:val)')
    endif
    return 1
endfunction
"{{{2 tof.addoption: добавить настройку
"{{{3 s:opttypes: типы настроек
let s:opttypes={
            \'str': ['EscSeq', 'BrkSeq', 'CmdPrefix'],
            \'dictstrstr': ['StartTrSymbs', 'StopTrSymbs', 'NoTransWord'],
            \'bool': ['UsePython'],
        \}
"}}}3
function s:F.tof.addoption(bufdict, option)
    let opt=s:_f.getoption(a:option)
    let a:bufdict.opts[a:option]={'value': (opt),}
    if index(s:opttypes.str, a:option)!=-1
        call s:F.tof.addtochlist(a:bufdict, opt)
    elseif index(s:opttypes.dictstrstr, a:option)!=-1
        call map(keys(opt), 's:F.tof.addtochlist(a:bufdict, v:val)')
    endif
    return 1
endfunction
"{{{2 tof.addplugin: добавить плагин
"{{{3 s:tofplug, s:plugopts, s:blankkeys
let s:blankkeys=[' ', "\<C-m>"]
let s:plugopts={
            \'notrans'    : ['StartTrSymbs', 'StopTrSymbs'],
            \'notransword': ['NoTransWord'],
            \'brk'        : ['BrkSeq'],
        \}
" То, что должно оказаться в качестве второго элемента списка из списка 
" bufdict.plugs
let s:tofplug={
            \   'comm': '"."',
            \   'notrans': 'keys(a:bufdict.opts.StopTrSymbs.value)',
            \   'notransword': 'keys(a:bufdict.opts.NoTransWord.value)+'.
            \                  's:blankkeys',
            \   'brk': '[a:bufdict.opts.BrkSeq.value]',
            \}
"}}}3
function s:F.tof.addplugin(bufdict, plugin)
    if type(a:plugin)==type('')
        if has_key(s:plugopts, a:plugin)
            call map(copy(s:plugopts[a:plugin]),
                        \'s:F.tof.addoption(a:bufdict, v:val)')
        endif
        call add(a:bufdict.plugs,
                    \[s:F.tof.plug[a:plugin], eval(s:tofplug[a:plugin])])
        if a:plugin is# 'notransword'
            call map(copy(s:blankkeys),
                        \'s:F.tof.addtochlist(a:bufdict, v:val)')
        endif
    else
        call add(a:bufdict.plugs, a:plugin)
        if type(a:plugin[1])==type([])
            call map(copy(a:plugin[1]), 's:F.tof.addtochlist(a:bufdict, v:val)')
        endif
    endif
    return 1
endfunction
"{{{2 tof.makemaps: создать привязки
function s:F.tof.makemaps(bufdict)
    "{{{3 Кэш
    let id=a:bufdict.transsymb.id
    if !empty(s:cache.trans[3][id])
        let chars=s:cache.trans[3][id]
    else
        let chars=keys(s:F.tof.formattrlistch(a:bufdict.transsymb))
        let s:cache.trans[3][id]=chars
        lockvar! chars
    endif
    let a:bufdict.chlist=copy(chars)
    "{{{3 Плагины
    if !empty(a:bufdict.originplugs)
        let plugs=a:bufdict.originplugs
    else
        let plugs=s:_f.getoption('ToFPlugs')
        let a:bufdict.originplugs=plugs
    endif
    call map(copy(plugs), 's:F.tof.addplugin(a:bufdict, v:val)')
    "{{{3 Создание привязок
    call map(copy(a:bufdict.chlist), 's:F.tof.map(a:bufdict, v:val)')
    "{{{3 Блокировка
    lockvar! a:bufdict.chlist
    lockvar! a:bufdict.opts
    lockvar! a:bufdict.plugs
    lockvar! a:bufdict.exmaps
    return 1
endfunction
"{{{2 tof.setup: включить транслитерацию по мере ввода
"{{{3 s:rewritefunc
let s:rewritefunc={
            \'@conque': '<SID>Eval("s:F.tof.conque_w")',
        \}
lockvar! s:rewritefunc
"}}}3
function s:F.tof.setup(buffer, transsymb, ...)
    if empty(a:000)
        if a:buffer>0
            let curbuf=bufnr('%')
            if curbuf!=a:buffer
                execute 'buffer' a:buffer
            else
                unlet curbuf
            endif
        endif
        let bufdict={
                    \'transsymb': a:transsymb,
                    \ 'curtrans': [a:transsymb],
                    \ 'curtrseq': '',
                    \    'flags': copy(s:tofdefflags),
                    \ 'lastline': -2,
                    \    'bufnr': a:buffer,
                    \   'exmaps': {},
                    \     'vars': deepcopy(s:tofinitvars),
                    \    'plugs': [],
                    \ 'curplugs': [],
                    \'writefunc': s:_f.getoption('WriteFunc'),
                    \   'chlist': [],
                    \     'opts': {},
                    \'originplugs': [],
                    \'testbreak': s:_f.getoption('BreakFunc'),
                \}
        if type(bufdict.writefunc)==type('') &&
                    \has_key(s:rewritefunc, bufdict.writefunc)
            let bufdict.writefunc=s:rewritefunc[bufdict.writefunc]
        elseif type(bufdict.writefunc)!=type(0)
            let bufdict.writefunc='"'.bufdict.writefunc.'"'
        endif
        if type(bufdict.testbreak)==type(0)
            let bufdict.testbreak=
                        \s:F.tof['testbreak'.((bufdict.bufnr)?(''):('dummy'))]
        endif
    else
        let bufdict=a:000[0]
    endif
    lockvar! bufdict.bufnr
    lockvar! bufdict.writefunc
    lockvar! bufdict.testbreak
    lockvar 1 bufdict
    if bufdict.bufnr>0
        let s:tofbufdicts[bufdict.bufnr]=bufdict
        call s:F.tof.makemaps(bufdict)
        if exists('curbuf')
            execute 'buffer' curbuf
        endif
    endif
    return bufdict
endfunction
"{{{2 tof.unmap: удалить привязки
function s:F.tof.unmap(bufdict)
    for M in a:bufdict.chlist
        if empty(M)
            continue
        endif
        call s:_r.map.unmap({'lhs': M,
                    \     'buffer': 1,
                    \       'type': 'map',
                    \       'mode': 'i',
                    \        'sid': s:_sid,})
        " Если привязка локально, то ничего восстанавливать не надо
        if has_key(a:bufdict.exmaps, M) && !a:bufdict.exmaps[M].buffer==1
            call s:_r.map.map(a:bufdict.exmaps[M])
        endif
    endfor
    return 1
endfunction
"{{{2 tof.stop: выключить транслитерацию по мере ввода
function s:F.tof.stop(bufdict)
    let curbuf=bufnr('%')
    if curbuf!=a:bufdict.bufnr
        execute 'buffer' (a:bufdict.bufnr)
    endif
    call s:F.tof.unmap(a:bufdict)
    unlet s:tofbufdicts[(a:bufdict.bufnr)]
    if curbuf!=a:bufdict.bufnr
        execute 'buffer' curbuf
    endif
    return 1
endfunction
"{{{1 mod:  add, del, setoption, main: изменение таблицы транслитерации
"{{{2 mod.formattotr
" Превратить пару ("...", "smth") в {'.': {'.': {'.': "smth"} } }.
function s:F.mod.formattotr(srcstr, trstr)
    if empty(a:srcstr)
        return a:trstr
    endif
    let srcstr=reverse(split(a:srcstr, '\zs'))
    let result={(srcstr[0]): a:trstr}
    let srcstr=srcstr[1:]
    for curch in srcstr
        let result={(curch): result}
    endfor
    return result
endfunction
"{{{2 mod.add: добавить транслитерируемую последовательность
function s:F.mod.add(srcstr, trstr, replace, transsymb)
    let curch=s:F.stuf.nextchar(a:srcstr)
    let tail=a:srcstr[(len(curch)):]
    if empty(curch)
        if a:replace || !has_key(a:transsymb, 'none')
            let a:transsymb.none=s:F.mod.formattotr(tail, a:trstr)
            return 1
        else
            call s:_f.warn('trex')
            return 0
        endif
    elseif has_key(a:transsymb, curch)
        if type(a:transsymb[curch])==type('')
            if !empty(tail)
                let a:transsymb[curch]=extend(s:F.mod.formattotr(tail, a:trstr),
                            \                 {'none': a:transsymb[curch]})
                return 1
            elseif a:replace
                let a:transsymb[curch]=s:F.mod.formattotr(tail, a:trstr)
                return 1
            else
                call s:_f.warn('trex')
                return 0
            endif
        else
            return s:F.mod.add(tail, a:trstr, a:replace, a:transsymb[curch])
        endif
    else
        let a:transsymb[curch]=s:F.mod.formattotr(tail, a:trstr)
        return 1
    endif
endfunction
"{{{2 mod.inc: добавить ключ «include»
function s:F.mod.inc(srcstr, incstr, exclude, transsymb)
    let curch=s:F.stuf.nextchar(a:srcstr)
    let tail=a:srcstr[(len(curch)):]
    if empty(curch)
        if has_key(a:transsymb, 'include')
            if a:exclude
                let oldinclen=len(a:transsymb.include)
                call filter(a:transsymb.include, 'v:val isnot# a:incstr')
                let inclen=len(a:transsymb.include)
                if inclen==oldinclen
                    call s:_f.warn('notinc', a:incstr)
                    return 0
                elseif !inclen
                    unlet a:transsymb.include
                endif
                return 1
            elseif index(a:transsymb.include, a:incstr)!=-1
                call s:_f.warn('ainc', a:incstr)
                return 0
            endif
        elseif a:exclude
            call s:_f.warn('nex')
            return 0
        else
            let a:transsymb.include=[]
        endif
        let a:transsymb.include+=[a:incstr]
        return 1
    elseif has_key(a:transsymb, curch)
        if type(a:transsymb[curch])==type('')
            if a:exclude
                call s:_f.warn('nex')
                return 0
            elseif empty(tail)
                let a:transsymb[curch]={'none': a:transsymb[curch],
                            \        'include': [a:incstr]}
            else
                let a:transsymb[curch]=extend(s:F.mod.formattotr(tail,
                            \                          {'include': [a:incstr]}),
                            \                 {'none': a:transsymb[curch]})
            endif
            return 1
        else
            let r=s:F.mod.inc(tail, a:incstr, a:exclude, a:transsymb[curch])
            if r && empty(a:transsymb[curch])
                unlet a:transsymb[curch]
            endif
            return r
        endif
    elseif a:exclude
        call s:_f.warn('nex')
        return 0
    else
        let a:transsymb[curch]=s:F.mod.formattotr(tail, {'include': [a:incstr]})
        return 1
    endif
endfunction
"{{{2 mod.del: удалить транслитерируемую последовательность
function s:F.mod.del(srcstr, recurse, transsymb)
    let transsymb=a:transsymb
    let trlist=split(a:srcstr, '\zs')
    let i=0
    while i<len(trlist)
        let curch=trlist[i]
        if has_key(transsymb, curch)
            if type(transsymb[curch])==type({})
                if i<len(trlist)-1
                    let transsymb=transsymb[curch]
                endif
            elseif len(trlist)-i==1
                unlet transsymb[curch]
                return 1
            else
                call s:_f.warn('trnf')
                return 0
            endif
        else
            call s:_f.warn('trnf')
            return 0
        endif
        let i+=1
    endwhile
    if a:recurse
        unlet transsymb[curch]
        return 1
    elseif has_key(transsymb[curch], 'none')
        unlet transsymb[curch].none
        return 1
    else
        call s:_f.warn('trnd')
        return 0
    endif
    return 0
endfunction
"{{{2 mod.setoption: установить или удалить настройку
function s:F.mod.setoption(srcstr, option, value, replace, transsymb)
    "{{{3 Объявление переменных
    let trlist=split(a:srcstr, '\zs')
    let deloption=(a:replace==2)
    let trans=a:transsymb
    let opt={(a:option): a:value}
    let i=0
    "{{{3 Цикл
    while 1
        if has_key(trans, trlist[i])
            if type(trans[trlist[i]])==type({})
                if i < len(trlist)-1
                    let trans=trans[trlist[i]]
                    let i+=1
                    continue
                else
                    if i==len(trlist)-1
                        let trans=trans[trlist[i]]
                    endif
                    if has_key(trans, 'options')
                        if deloption
                            if has_key(trans.options, a:option)
                                unlet trans.options[a:option]
                                if trans.options=={}
                                    unlet trans.options
                                endif
                                break
                            else
                                call s:_f.warn('onfnd')
                                return 0
                            endif
                        else
                            if !a:replace &&
                                        \has_key(trans.options, a:option) &&
                                        \(trans.options[a:option]!=a:value)
                                call s:_f.warn('opt')
                                return 0
                            else
                                call extend(trans.options, opt, 'force')
                                break
                            endif
                        endif
                    else
                        if deloption
                            call s:_f.warn('onfnd')
                            return 0
                        else
                            let trans.options=opt
                            break
                        endif
                    endif
                endif
            elseif i == len(trlist)-1
                if deloption
                    call s:_f.warn('onfnd')
                    return 0
                else
                    let trans[trlist[i]]={
                                \   'none': trans[trlist[i]],
                                \'options': (opt)
                            \}
                    break
                endif
            endif
        endif
        call s:_f.warn('trnf')
        return 0
    endwhile
    "}}}3
    return 1
endfunction
"{{{2 mod.main
" Добавить/удалить транслитерируемую последовательность или настройку
function s:F.mod.main(action, transsymb, ...)
    let retstatus=call(s:F.mod[a:action], a:000+[a:transsymb.origin], s:F)
    if !retstatus
        return 0
    endif
    return s:F.comm.save(a:transsymb)
endfunction
"{{{1 prnt: main(print): печать таблицы транслитерации
"{{{2 prnt.formattrplain: получить список всех последовательностей
" В качестве аргументов принимает таблицу транслитерации во внутреннем формате, 
" начало последовательности (нужно для рекурсии) и флаги (нужно для рекурсии). 
" Вызывайте со вторым и третьим аргументами, равными пустым строкам.
function s:F.prnt.formattrplain(transsymb, beginning, flags)
    let result={}
    for key in keys(a:transsymb)
        "{{{3 Ключ «none»
        if key is# 'none'
            let trstr=a:transsymb.none
            let flags=a:flags
            "{{{4 Верхний регистр
            " Если нет никаких различий между регистрами, то не имеет смысла 
            " писать флаги, влияющие на результат транслитерации верхнего 
            " регистра
            if toupper(a:beginning) is# tolower(a:beginning)
                let flags=substitute(flags, '[cf]', '', 'g')
            endif
            "{{{4 Combining diacritics
            if s:F.stuf.iscombining(
                        \s:F.stuf.nextchar_nr(a:transsymb.none))
                let trstr='a'.trstr
                let flags.='d'
            endif
            "}}}4
            let result[a:beginning]=[trstr, flags]
        "{{{3 Односимвольный ключ
        elseif key=~#'^.$'
            let [lwtrans, uptrans]=(a:transsymb[key])
            "{{{4 Таблица транслитерации для нижнего или обоих регистров
            if type(lwtrans)==type({})
                let beginning=(a:beginning).key
                let flags=a:flags
                if type(uptrans)==type(0)
                    if uptrans==0
                        let flags='c'
                    elseif uptrans==2
                        let flags='f'
                    endif
                endif
                call extend(result, (s:F.prnt.formattrplain(lwtrans,
                            \                           beginning, flags)))
            endif
            "{{{4 Таблица транслитерации для верхнего регистра
            if type(uptrans)==type({})
                call extend(result, (s:F.prnt.formattrplain(uptrans,
                            \((a:beginning).(toupper(key))), a:flags)))
            endif
            "}}}4
            unlet lwtrans
            unlet uptrans
        endif
        "}}}3
    endfor
    return result
endfunction
"{{{2 prnt.main: напечатать таблицу транслитерации
"{{{3 prnt.printl
function s:F.prnt.printl(len, str)
    return a:str . repeat(' ', a:len-s:_r.strdisplaywidth(a:str, 0))
endfunction
"}}}3
function s:F.prnt.main(columns, transsymb)
    "{{{3 Первая часть — получение списка списков
    let cache=s:cache.trans[2][a:transsymb.id]
    if len(cache[0])
        let [printlist, srclen, trlen, flaglen]=cache[0]
    else
        let plaintrans=s:F.prnt.formattrplain(a:transsymb, '', '')
        let  srclen=max(map(  keys(plaintrans),
                    \'s:_r.strdisplaywidth(strtrans(v:val), 0)'))
        let   trlen=max(map(values(plaintrans),
                    \'s:_r.strdisplaywidth(strtrans(v:val[0]), 0)-'.
                    \'(stridx(v:val[1], "d")!=-1)'))
        let flaglen=max(map(values(plaintrans),
                    \'len(v:val[1])'))
        let printlist=values(map(copy(plaintrans), '[v:key]+v:val'))
        let cache[0]=[printlist, srclen, trlen, flaglen]
    endif
    if a:columns==-1
        return deepcopy(printlist)
    endif
    "{{{3 Количество колонок
    if a:columns==-2
        " columns=(Ширина_окна+Ширина разделителя-1)/
        "           (Максимальная_длина_транслитерируемой последовательности+
        "            Максимальная_длина_результата_транслитерации+
        "            Ширина_разделителя+Количество_промежутков_между_колонками+
        "            Длина_последней_колонки), где
        "               Колонка — колонка внутренней части. Их три:
        "                         транслитерируемая последовательность, 
        "                         результат транслитерации и специалыный флаг
        "               Ширина разделителя=len(" | ")=3
        "               Длина_последней_колонки=1 (колонка флагов)
        let columns=(&columns+2)/(srclen+trlen+flaglen+5)
    else
        let columns=a:columns
    endif
    "{{{3 Вторая часть — получение списка строк
    if len(cache[1])
        let printstr=cache[1]
    else
        let printstr=map(copy(printlist),
                    \'s:F.prnt.printl( srclen, strtrans(v:val[0]))." ".'.
                    \'s:F.prnt.printl(  trlen, strtrans(v:val[1]))." ".'.
                    \'s:F.prnt.printl(flaglen, v:val[2])')
        call sort(printstr)
        let cache[1]=printstr
    endif
    if columns==0
        return copy(printstr)
    endif
    "{{{3 Третья часть — получение вывода в колонках
    if has_key(cache[2], columns)
        let result=cache[2][columns]
    else
        let result=[]
        let curcol=0
        let curline=0
        let lastlinelen = len(printstr)%columns
        let lines=len(printstr)/columns
        while len(printstr)
            if curcol==0
                call add(result, '')
            endif
            let result[curline].=printstr[0]
            let printstr=printstr[1:]
            if curcol != columns-1
                let result[curline].=' | '
            endif
            let curline+=1
            if          (curline==lines && curcol>=lastlinelen) ||
                        \curline==lines+1
                let curline=0
                let curcol+=1
            endif
        endwhile
        let cache[2][columns]=result
    endif
    return join(result, "\n")
    "}}}3
endfunction
"{{{1 Внешние функции
let s:efbodies={
            \'add':     'call(s:F.mod.main,["add",args[-1]]+args[0:2],    {})',
            \'include': 'call(s:F.mod.main,["inc",args[-1]]+args[0:1]+[0],{})',
            \'exclude': 'call(s:F.mod.main,["inc",args[-1]]+args[0:1]+[1],{})',
            \'del':     'call(s:F.mod.main,["del",args[-1]]+args[0:1],    {})',
            \'setoption': 'call(s:F.mod.main, ["setoption", '.
            \                                 'args[-1], args[2], args[0], '.
            \                                 'args[1], args[3]], {})',
            \'deloption': 'call(s:F.mod.main, ["setoption", '.
            \                                 'args[-1], args[1], args[0], '.
            \                                 '"", 2], {})',
            \'print': 'call(s:F.prnt.main, args, {})',
            \'transliterate': 'call(s:F.trs.main, args, {})',
        \}
let s:extfunctions={}
for [s:key, s:val] in items(s:efbodies)
    execute      'function s:extfunctions.Tr3'.s:key."(...)\n".
                \"    let args=copy(a:000)\n".
                \"    let args[-1]=s:F.comm.gettranssymb_throw(args[-1])\n".
                \'    if type(args[-1])!='.type({})"\n".
                \"        call s:_f.throw('itrans')\n".
                \"    endif\n".
                \'    return '.s:val."\n".
                \'endfunction'
endfor
unlet s:key s:val s:efbodies
call s:_f.postresource('extfunctions', s:extfunctions)
unlet s:extfunctions
"{{{1 mng:  управление плагином
"{{{2 mng.tof: управление транслитерацией по мере ввода
function s:F.mng.tof(bang, action, ...)
    "{{{3 Объявление переменных
    "{{{3 Запуск
    if a:action is# 'start'
        let transsymb=s:F.comm.gettranssymb_throw(a:000[0])
        if a:bang
            if exists('s:toftranssymb')
                call s:_f.warn('tofgs')
                return 0
            endif
            let mbuf=bufnr('$')
            let i=1
            while i<=mbuf
                if bufexists(i) && !has_key(s:tofbufdicts, i)
                    call s:F.tof.setup(i, transsymb)
                endif
                let i+=1
            endwhile
            let s:toftranssymb=transsymb
            return 1
        endif
        if has_key(s:tofbufdicts, bufnr('%'))
            call s:_f.warn('tofs')
            return 0
        endif
        return s:F.tof.setup(bufnr('%'), transsymb)
    "{{{3 Перезагрузка и остановка
    else
        "{{{4 Остановка
        if a:action is# 'stop'
            if a:bang
                if exists('s:toftranssymb')
                    unlet s:toftranssymb
                endif
                return !s:F.stuf.checklod(values(s:tofbufdicts),
                            \'s:F.tof.stop(v:val)')
            elseif has_key(s:tofbufdicts, bufnr('%'))
                return s:F.tof.stop(s:tofbufdicts[bufnr('%')])
            endif
        "{{{4 Перезагрузка
        elseif a:action is# 'restart'
            let buf=bufnr('%')
            if has_key(s:tofbufdicts, buf)
                let transsymb=s:tofbufdicts[(buf)].transsymb
                call s:F.tof.stop(s:tofbufdicts[buf])
            else
                let transsymb=s:F.comm.gettranssymb_throw()
            endif
            return s:F.tof.setup(bufnr('%'), transsymb)
        endif
    endif
    "}}}3
    return 0
endfunction
"{{{2 mng.cache: управление кэшем
function s:F.mng.cache(action, ...)
    "{{{3 Очистка кэша
    if a:action is# 'purge'
        let target=a:1
        if a:1 is# 'innertrans' || a:1 is# 'trans' || a:1 is# 'all'
            let s:cache.trans=deepcopy(s:cache.init.trans)
        elseif a:1 is# 'printtrans'
            call map(s:cache.trans[2], 'deepcopy(s:cache.init.print)')
        elseif a:1 is# 'toftrans'
            call map(s:cache.trans[3], '[]')
        endif
    "{{{3 Печать кэша
    elseif a:action is# 'show'
        "{{{4 Объявление переменных
        let header=(s:_messages.cache.th.trans)
        let i=0
        let clen=len(s:cache.trans[1])
        let lines=[]
        "{{{4 Получение строк
        while i<clen
            call add(lines, [])
            "{{{5 Первый столбец — источник таблицы
            let source=(s:cache.trans[1][i].source)
            if source[0] is# 'gvar'
                call add(lines[-1], s:_messages.cache.trsrc.gvar.' '.source[1])
            elseif source[0] is# 'bvar'
                call add(lines[-1], printf(s:_messages.cache.trsrc.bvar,
                            \              source[1][1]).' '.source[1][0])
            elseif source[0] is# 'func'
                call add(lines[-1], s:_messages.cache.trsrc.func.' '.
                            \       substitute(string(source[1]),
                            \                 '^.\{-}''\(.*\)''.*$', '\1', ''))
            elseif source[0] is# 'file'
                call add(lines[-1], s:_messages.cache.trsrc.file.' '.
                            \       fnamemodify(source[1], ':~:.'))
            elseif source[0] is# 'dict'
                call add(lines[-1], s:_messages.cache.trsrc.dict)
            endif
            "{{{5 Второй столбец — заполненность кэша для печати
            let printcache=s:cache.trans[2][i]
            if printcache[2]!={}
                call add(lines[-1], (s:_messages.cache.other.col).' '.
                            \join(keys(printcache[2]), ', '))
            elseif len(printcache[1])
                call add(lines[-1], s:_messages.cache.other.strl)
            elseif len(printcache[0])
                call add(lines[-1], s:_messages.cache.other.ll)
            else
                call add(lines[-1], s:_messages.cache.other.no)
            endif
            "{{{5 Третий столбец — наличие кэша для ToF
            if len(s:cache.trans[3][i])
                call add(lines[-1], s:_messages.cache.other.yes)
            else
                call add(lines[-1], s:_messages.cache.other.no)
            endif
            "}}}6
            let i+=1
        endwhile
        "}}}4
        call s:_f.printtable(lines, {'header': header})
    endif
    "}}}3
    return 1
endfunction
"{{{2 cmdfun.function
"{{{3 s:cmdactions, s:rewritemode
let s:cmdactions={
            \'add':     's:F.mod.main("add",'.
            \                        's:F.comm.gettranssymb_throw(a:3.to),'.
            \                        'a:1, a:2, a:bang)',
            \'include': 's:F.mod.main("inc",'.
            \                        's:F.comm.gettranssymb_throw(a:3.to),'.
            \                        'a:1, a:2, 0     )',
            \'exclude': 's:F.mod.main("inc",'.
            \                        's:F.comm.gettranssymb_throw(a:3.to),'.
            \                        'a:1, a:2, 1     )',
            \'delete':  's:F.mod.main("del",'.
            \                        's:F.comm.gettranssymb_throw(a:2.from),'.
            \                        'a:1,      a:bang)',
            \'setoption': 's:F.mod.main("setoption", '.
            \                          's:F.comm.gettranssymb_throw(a:3.in), '.
            \                          'a:3.for, a:1, a:2, a:bang)',
            \'deloption': 's:F.mod.main("setoption", '.
            \                          's:F.comm.gettranssymb_throw(a:2.in), '.
            \                          'a:2.for, a:1,  0,   2)',
            \'save':  's:F.comm.save(s:F.comm.gettranssymb_throw(a:1))',
            \'tof':   'call(s:F.mng.tof,  [a:bang]+a:000, {})',
            \'cache': 'call(s:F.mng.cache,         a:000, {})',
        \}
let s:rewritemode={"v": 'char',
            \      "V": 'line',
            \ "\<C-v>": 'block',}
"}}}3
let s:cmdfun={}
function s:cmdfun.function(bang, startline, endline, action, ...)
    "{{{3 Действия
    "{{{4 Транслитерировать
    if a:action is# 'transliterate'
        if a:1 is# 'lines'
            return s:F.map.translitselection('line', [0, 1, a:startline, 0],
                        \                            [0, 1, a:endline,   0],
                        \                s:F.comm.gettranssymb_throw(a:2.using))
        elseif a:1 is# 'selection'
            return s:F.map.translitselection(s:rewritemode[visualmode()],
                        \                    getpos("'<"), getpos("'>"),
                        \                s:F.comm.gettranssymb_throw(a:2.using))
        endif
    "{{{4 Напечатать таблицу транслитерации
    elseif a:action is# 'print'
        echo s:F.prnt.main(a:1.columns,
                    \      s:F.comm.gettranssymb_throw(a:1.transsymb))
        return 1
    "{{{4 Действия, описанные в s:cmdactions
    elseif has_key(s:cmdactions, a:action)
        return eval(s:cmdactions[a:action])
    endif
    "}}}3
endfunction
call s:_f.postresource('cmd', s:cmdfun.function)
unlet s:cmdfun
"{{{1 s:cache: кэш
let s:cache={'init':{}}
" init — значения, которыми инициализируется пустой кэш.
let s:cache.init.trans=[[], [], [], []]
let s:cache.init.print=[[], [], {}]
" trans — кэш преобразований таблицы транслитерации. Состоит из трёх колонок:
" Первая — непреобразованная таблица, используется для определения индекса;
" Вторая — соответствующая таблица, преобразованная во внутреннее
"          представление;
" Третья — некоторые преобразования функции вывода на печать;
let s:cache.trans=deepcopy(s:cache.init.trans)
"{{{1 map: Функции для привязок
"{{{2 map.getvrange
function s:F.map.getvrange(start, end)
    let [sline, scol]=a:start
    let [eline, ecol]=a:end
    let text=[]
    let ellcol=col([eline, '$'])
    let slinestr=getline(sline)
    if sline==eline
        if ecol>=ellcol
            call extend(text, [slinestr[(scol-1):], ''])
        else
            call add(text, slinestr[(scol-1):(ecol-1)])
        endif
    else
        call add(text, slinestr[(scol-1):])
        let elinestr=getline(eline)
        if (eline-sline)>1
            call extend(text, getline(sline+1, eline-1))
        endif
        if ecol<ellcol
            call add(text, elinestr[:(ecol-1)])
        else
            call extend(text, [elinestr, ''])
        endif
    endif
    return text
endfunction
"{{{2 map.delvrange
function s:F.map.delvrange(start, end)
    let [sline, scol]=a:start
    let [eline, ecol]=a:end
    let ellcol=col([eline, '$'])
    let slinestr=getline(sline)
    let slinestart=''
    if scol>1
        let slinestart=slinestr[:(scol-2)]
    endif
    if sline==eline
        if ecol>=ellcol
            call setline(sline, slinestart.getline(sline+1))
            execute (sline+1).'delete _'
        else
            call setline(sline, slinestart.slinestr[(ecol):])
        endif
    else
        call setline(sline, slinestart)
        let elinestr=getline(eline)
        if ecol<ellcol
            call setline(eline, elinestr[(ecol):])
        else
            execute eline.'delete _'
        endif
        if (eline-sline)>1
            execute (sline+1).','.(eline-1).'delete _'
        endif
        execute sline.'normal! gJ'
    endif
endfunction
"{{{2 map.insertatposition
function s:F.map.insertatposition(pos, text)
    if empty(a:text)
        return
    endif
    let [line, col]=a:pos
    let linestr=getline(line)
    let lstr=linestr[:(col-2)]
    let rstr=linestr[(col-1):]
    if len(a:text)==1
        call setline(line, lstr.a:text[0].rstr)
    else
        call setline(line, lstr.a:text[0])
        call append(line, a:text[1:-2]+[a:text[-1].rstr])
    endif
endfunction
"{{{2 map.nullnl
" Convert between lines (NL separated strings with NULLs represented as NLs) and 
" NULL separated strings with NLs represented by NLs.
function s:F.map.nullnl(text)
    let r=[]
    for line in a:text
        let nlsplit=split(line, "\n", 1)
        if empty(r)
            call extend(r, nlsplit)
        else
            let r[-1].="\n".nlsplit[0]
            call extend(r, nlsplit[1:])
        endif
    endfor
    return r
endfunction
"{{{2 map.trwithnulls
function s:F.map.trwithnulls(str, transsymb)
    return join(map(split(a:str, "\n", 1), 's:F.trs.main(v:val, a:transsymb)'),
                \"\n")
endfunction
"{{{2 map.getcol
function s:F.map.getcol(linestr, vcol)
    if s:_r.strdisplaywidth(a:linestr, 0)<a:vcol
        return ['$', 0, 0]
    endif
    let col=1
    let width=0
    while 1
        let lchar=len(matchstr(a:linestr, '\v^.', col-1))
        let lastwidth=s:_r.strdisplaywidth(a:linestr[(col-1):(col+lchar-2)],
                    \                      width)
        let width+=lastwidth
        if width>=a:vcol
            break
        endif
        let col+=lchar
    endwhile
    return [col-1, a:vcol-width+lastwidth-1, lastwidth]
endfunction
"{{{2 map.translitselection
function s:F.map.translitselection(type, start, end, ...)
    "{{{3 transsymb
    if !a:0
        let transsymb=s:F.comm.gettranssymb_throw()
    else
        let transsymb=a:1
    endif
    "{{{3 Сохранение позиции курсора
    let view=winsaveview()
    let vcol=virtcol('.')
    "{{{3 Объявление переменных
    let [sline, scol, soff]=a:start[1:]
    let [eline, ecol, eoff]=a:end[1:]
    "{{{3 Транслитерация набора линий
    if a:type is# 'line'
        if sline>eline
            let [sline, eline]=[eline, sline]
        endif
        let line=sline
        while line<=eline
            call setline(line, s:F.map.trwithnulls(getline(line), transsymb))
            let line+=1
        endwhile
    "{{{3 Транслитерация символьного диапозона
    elseif a:type is# 'char'
        if sline>eline || (sline==eline && scol>ecol)
            let [sline, scol, eline, ecol]=[eline, ecol, sline, scol]
        endif
        let lchar=len(matchstr(getline(eline), '\v%'.ecol.'c.'))
        if lchar>1
            let ecol+=lchar-1
        endif
        let text=s:F.map.getvrange([sline, scol], [eline, ecol])
        call s:F.map.delvrange([sline, scol], [eline, ecol])
        let ttext=s:F.map.nullnl(map(s:F.map.nullnl(text),
                    \                's:F.trs.main(v:val, transsymb)'))
        call s:F.map.insertatposition([sline, scol], ttext)
    "{{{3 Транслитерация прямоугольного блока
    elseif a:type is# 'block'
        "{{{4 Объявление переменных
        let svcol=virtcol([sline, scol])+soff
        let evcol=virtcol([eline, ecol])+eoff
        if sline>eline
            let [sline, eline]=[eline, sline]
        endif
        if svcol>evcol
            let [svcol, evcol]=[evcol, svcol]
        endif
        let line=sline-1
        "{{{4 Основной цикл
        while line<=eline
            let line+=1
            let linestr=getline(line)
            let [cscol, csoff, csw]=s:F.map.getcol(linestr, svcol)
            if cscol is# '$'
                continue
            endif
            "{{{5 lstr (Строка до транслитерируемой части)
            let lstr=((cscol>0)?(linestr[:(cscol-1)]):(''))
            if csoff>0
                let lstr.=repeat(' ', csoff)
            endif
            "}}}5
            let [cecol, ceoff, cew]=s:F.map.getcol(linestr, evcol+1)
            "{{{5 rstr (Строка после транслитерируемой части)
            let rstr=((cecol isnot# '$')?(linestr[(cecol):]):(''))
            if ceoff>0
                let rstr=substitute(rstr, '\v^.', repeat(' ', cew-ceoff), '')
            endif
            "{{{5 tstr (Транслитерируемая часть)
            let tstr=((cecol is# '$')?
                        \   (linestr[(cscol):]):
                        \   ((cecol>cscol)?
                        \       (linestr[(cscol):(cecol-1)]):
                        \       ('')))
            if csoff>0
                let tstr=substitute(tstr, '\v^.', repeat(' ', csw-csoff), '')
            endif
            if ceoff>0
                let tstr.=repeat(' ', ceoff)
            endif
            "}}}5
            let tstr=s:F.map.trwithnulls(tstr, transsymb)
            call setline(line, lstr.tstr.rstr)
            "{{{5 undojoin
            if line<=eline
                undojoin
            endif
            "}}}5
        endwhile
        "}}}4
    endif
    "{{{3 Восстановление позиции курсора
    call winrestview(view)
    keepjumps execute 'normal!' vcol.'|'
    "}}}3
endfunction
call s:_f.postresource('trmotion', s:F.map.translitselection)
"{{{2 map.input
let s:inputhistory=[]
let g:TR3_INPUT_HISTORY=s:inputhistory
let s:inputwords={}
function s:F.map.input()
    let histlock=islocked('s:inputhistory')
    lockvar s:inputhistory
    call inputsave()
    try
        let r=input('Translit: ', '')
        return r
    catch /^Vim:Interrupt$/
        return 0
    finally
        call inputrestore()
        if !histlock
            unlockvar s:inputhistory
            let s:inputhistory+=s:_r.history.get('input')
        endif
    endtry
endfunction
let s:F.map.input=s:_f.wrapfunc({'function': s:F.map.input,
            \                  '@altervars': [['+history(@)', s:inputhistory]]})
"{{{2 map.doinput
function s:F.map.doinput(transsymb)
    try
        let r=s:F.map.input()
    catch
        throw 'Failed to input characters: '.v:exception
    " finally
        " redraw!
    endtry
    if r is 0
        return ''
    endif
    let l=split(r, '\(\\\@<!\(\\.\)*\\\)\@<! ')
    for s in l
        let s:inputwords[s]=1
    endfor
    return s:F.trs.main(r, a:transsymb)
endfunction
"{{{2 map.lrset
function s:F.map.lrset(transsymb, patlist)
    let line=getline('.')
    let column=col('.')
    let match=[]
    let i=0
    let lpatlist=len(a:patlist)
    while i<lpatlist && (match==[] || match[0]=='')
        let pattern='\v'.a:patlist[i][0].'%'.column.'c'.a:patlist[i][1]
        let match=matchlist(line, pattern)
        let i+=1
    endwhile
    let lmatch=match[1]
    let rmatch=match[2]
    let r=s:F.trs.main((lmatch.rmatch), a:transsymb)
    let matchstart=column-len(lmatch)-2
    let lline=''
    if matchstart>=0
        let lline=line[:(matchstart)]
    endif
    let matchend=column+len(rmatch)-1
    let rline=''
    if matchend>=0
        let rline=line[(matchend):]
    endif
    let curline=line('.')
    let vcolstart=virtcol([curline, column-len(lmatch)])
    let vcolend=virtcol([curline, column+len(rmatch)])
    return "\<C-o>".vcolstart."|\<C-\>\<C-o>\"_d".vcolend.'|'.
                \((vcolend==virtcol('$'))?("\<C-\>\<C-o>\"_x"):('')).r
endfunction
"{{{2 strfunc.function
let s:strfunc={}
function s:strfunc.function(char, ...)
    if a:0
        let addarg=a:1
    else
        let transsymb=s:F.comm.gettranssymb()
        if transsymb is 0
            return [0, 0, 0]
        endif
        let addarg={}
        let addarg.bufdict=s:F.tof.setup(0, transsymb)
        let addarg.bclen=0
        let addarg.result=''
    endif
    let newresult=s:F.tof.transchar(addarg.bufdict, a:char)
    let bclen=len(addarg.bufdict.curtrans)
    if bclen<=addarg.bclen
        return [0, addarg.result, addarg]
    endif
    let addarg.bufdict.curtrseq=''
    let addarg.result=newresult
    if !addarg.bclen
        let addarg.bclen=1
    endif
    let addarg.bclen+=1
    return [2, addarg.result, addarg]
endfunction
call s:_f.postresource('str', s:strfunc.function)
unlet s:strfunc
"{{{2 map.doonchar
function s:F.map.doonchar(command, char)
    if a:command is# 'r'
        if a:char=~#'^.$'
            return 'r'.a:char
        endif
        let c=((v:count>1)?(v:count):(1)):
        return 's'.repeat(a:char, c)."\e"
    else
        if a:char=~#'^.$'
            return a:command.a:char
        else
            let line=getline('.')
            let l:count=v:count1
            let col=col('.')-1
            let vcol=virtcol('.')
            if a:command is# 'f' || a:command is# 't'
                while l:count && col!=-1
                    let col=stridx(line, a:char, col+1)
                    let l:count-=1
                endwhile
                if col!=-1
                    if a:command is# 'f'
                        let col+=len(a:char)
                    endif
                    let vcol=virtcol([line('.'), col+1])
                    let vcol-=1
                endif
            elseif a:command is# 'F' || a:command is# 'T'
                let line=line[:col]
                if a:command is# 'F'
                    let line=substitute(line, '.$', '', '')
                endif
                let lres=len(a:char)
                let mcol=len(line)-1-lres
                while mcol>0
                    let col=stridx(line, a:char, mcol)
                    if col!=-1
                        let l:count-=1
                        if !l:count
                            break
                        endif
                        let line=line[:col]
                    endif
                    let mcol-=lres
                    if mcol<0
                        let mcol=0
                    endif
                endwhile
                if col!=-1
                    if a:command is# 'T'
                        let vcol=virtcol([line('.'), col+1+lres])
                    else
                        let vcol=virtcol([line('.'), col+1])
                    endif
                endif
            endif
            " First bar is used only to discard count:
            " 2,tta will turn into 2{vcol}|а, so if {vcol}=10, you will try to 
            " move to 210'th virtual column instead of 10'th. Here I will move 
            " twice, but this fact can be ignored
            return '|'.vcol.'|'
        endif
    endif
    return a:command.a:char
endfunction
"{{{2 mapfunc.function
"{{{3 s:mapactions
let s:twregs=[
            \['\v(\k*)',        '\v(\k+|%$)'       ],
            \['\v(%(\k@!\S)*)', '\v(%(\k@!\S)+|%$)'],
            \['\v(\s*)',        '\v(\s*)'          ],
        \]
let s:tWregs=[
            \['\v(\S*)', '\v(\S+|%$)'],
            \['\v(\s*)', '\v(\s*)'   ],
        \]
let s:mapactions={
            \'Transliterate':     's:F.map.doinput(transsymb)',
            \'TransliterateWord': 's:F.map.lrset(transsymb, s:twregs)',
            \'TransliterateWORD': 's:F.map.lrset(transsymb, s:tWregs)',
            \'TranslitReplace':   's:F.map.doonchar("r", a:1[1])',
            \'TranslitToNext':    's:F.map.doonchar("t", a:1[1])',
            \'TranslitToPrev':    's:F.map.doonchar("T", a:1[1])',
            \'TranslitNext':      's:F.map.doonchar("f", a:1[1])',
            \'TranslitPrev':      's:F.map.doonchar("F", a:1[1])',
        \}
let s:mapactions.CmdTransliterate=s:mapactions.Transliterate
"}}}3
let s:mapfunc={}
function s:mapfunc.function(mapname, ...)
    if a:0!=1
        let transsymb=s:F.comm.gettranssymb_throw()
    endif
    if a:mapname is# 'StartToF'
        call s:F.tof.setup(bufnr('%'), transsymb)
        return ''
    elseif a:mapname is# 'StopToF'
        let curbuf=bufnr('%')
        if has_key(s:tofbufdicts, curbuf)
            call s:F.tof.stop(s:tofbufdicts[curbuf])
        endif
        return ''
    endif
    return eval(s:mapactions[a:mapname])
endfunction
call s:_f.postresource('map', s:mapfunc.function)
unlet s:mapfunc
"{{{1
call frawor#Lockvar(s:, 'usedtranssymbs,cache,tofbufdicts,'.
            \           'tofuntrcp,tofuntrcpchars,inputhistory,inputwords')
" vim: ft=vim:ts=8:fdm=marker:fenc=utf-8
