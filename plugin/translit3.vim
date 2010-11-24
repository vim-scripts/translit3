"{{{1 Начало
scriptencoding utf-8
" Пользователь может запретить загрузку плагина, но только на этом этапе
if (exists("s:g.pluginloaded") && s:g.pluginloaded) ||
            \exists("g:tr3Options.DoNotLoad")
    finish
"{{{1 Первая загрузка
elseif !exists("s:g.pluginloaded")
    "{{{2 Объявление переменных
    "{{{3 Словари с функциями
    " Функции для внутреннего использования
    let s:F={
                \"plug": {},
                \"main": {},
                \ "trs": {"plug":{}},
                \ "tof": {"plug":{}},
                \"stuf": {},
                \"comm": {},
                \ "mod": {},
                \"prnt": {},
                \ "out": {},
                \ "mng": {},
                \"comp": {},
                \ "map": {},
                \ "int": {},
            \}
    "{{{3 Глобальная переменная
    let s:g={}
    let s:g.load={}
    let s:g.pluginloaded=0
    let s:g.load.scriptfile=expand("<sfile>")
    let s:g.srccmd="source ".(s:g.load.scriptfile)
    "{{{4 Настройки по умолчанию
    let s:g.defaultOptions={
                \"BrkSeq": '@',
                \"EscSeq": '\',
                \"StopTrSymbs":  {'%': '',},
                \"StartTrSymbs": {'%': '',},
                \"NoTransWord": {'%%': '',},
                \"Plugs": {
                \   "Before": ["brk"],
                \   "After":  ["esc", "notransword", "notrans"],
                \},
                \"ToFPlugs": ["notransword", "notrans", "brk"],
                \"DefaultTranssymb": "transsymb",
                \"ConfigDir": fnamemodify(s:g.load.scriptfile, ':h:h').
                \               "/config/translit3",
                \"WriteFunc": 0,
            \}
    "{{{3 Команды и функции
    let s:g.load.commands={
                \"Command": {
                \      "nargs": '+',
                \      "range": "",
                \       "bang": "",
                \       "func": "mng.main",
                \   "complete": "customlist,s:_complete",
                \},
            \}
    lockvar 1 s:F
    " Список видимых извне функции
    let s:g.ExtFunc=["transliterate", "add", "del", "setoption",
                \"deloption", "print"]
    call map(s:g.ExtFunc, '[v:val, "out.".v:val, {}]')
    "{{{3 Привязки
    let s:g.load.mappings={}
    let s:mappings=[["Transliterate",     'i', '' ],
                \   ["CmdTransliterate",  'c', '' ],
                \   ["TransliterateWord", 'i', 'w'],
                \   ["TransliterateWORD", 'i', 'W'],
                \   ["StartToF",          'n', 's'],
                \   ["StopToF",           'n', 'S'],
                \   ["TranslitReplace",   ' ', 'r'],
                \   ["TranslitToNext",    ' ', 't'],
                \   ["TranslitToPrev",    ' ', 'T'],
                \   ["TranslitNext",      ' ', 'f'],
                \   ["TranslitPrev",      ' ', 'F'],
                \]
    for [s:map, s:mode, s:key] in s:mappings
        let s:g.load.mappings[s:map]={
                    \"type": s:mode,
                    \"function": 'map.runmap',
                    \"default": s:key,
                    \"leader": 1,
                \}
        unlet s:map s:mode s:key
    endfor
    unlet s:mappings
    "{{{3 sid
    function s:SID()
        return matchstr(expand('<sfile>'), '\d\+\ze_SID$')
    endfun
    let s:g.scriptid=s:SID()
    delfunction s:SID
    "{{{3 Регистрация дополнения
    let s:F.plug.load=load#LoadFuncdict()
    let s:g.reginfo=s:F.plug.load.registerplugin({
                \     "funcdict": s:F,
                \     "globdict": s:g,
                \      "oprefix": "tr3",
                \      "cprefix": "Tr3",
                \      "fprefix": "Tr3",
                \          "sid": s:g.scriptid,
                \   "scriptfile": s:g.load.scriptfile,
                \     "mappings": s:g.load.mappings,
                \     "commands": s:g.load.commands,
                \    "functions": s:g.ExtFunc,
                \   "apiversion": "0.1",
                \       "leader": '\t',
                \     "requires": [["stuf", '0.4'],
                \                  ["comp", '0.2'],
                \                  ["load", '0.0'],
                \                  ["json", '0.0'],
                \                  ["chk",  '0.3']],
            \})
    let s:F.main.eerror=s:g.reginfo.functions.eerror
    let s:F.main.option=s:g.reginfo.functions.option
    "}}}2
    finish
endif
"{{{1 Вторая загрузка
let s:g.pluginloaded=1
"{{{2 Чистка
unlet s:g.load
"{{{2 Выводимые сообщения
if v:lang[:4]==#'ru_RU' "{{{3
let s:g.p={
            \"emsg": {
            \     "sdt": "Значение должно быть либо строкой, либо словарём",
            \     "str": "Значение должно быть строкой",
            \    "dict": "Значение должно быть словарём",
            \    "list": "Значение должно быть списком",
            \    "bool": "Значение должно быть числом, равным либо нулю, ".
            \            "либо единице",
            \   "mnone": "Ключ «none» не должен встречаться в корне ".
            \            "таблицы транслитерации",
            \   "trans": "Если в качестве таблицы транслитерации указана ".
            \            "строка, то она должна быть либо именем файла, либо".
            \            "именем глобальной или локальной (для буфера) ".
            \            "переменной",
            \   "onfnd": "Требуемая настройка не найдена",
            \     "opt": "Данная настройка уже указана",
            \    "narg": "Неверное количество аргументов",
            \   "margs": "Слишком большое количество аргументов",
            \   "largs": "Недостаточно аргументов",
            \    "trex": "Транслитерируемая последовательность уже существует",
            \    "trnf": "Транслитерируемая последовательность не найдена",
            \    "trnd": "Не удалось удалить транслитерируемую ".
            \            "последовательность",
            \    "tofs": "Транслитерация по мере ввода уже запущена",
            \   "tofgs": "Транслитерация по мере ввода уже запущена ".
            \            "для всех буферов",
            \   "tofns": "Транслитерация по мере ввода ещё не запущена",
            \     "fnc": "Невозможно вызвать функцию по предоставленной ссылке",
            \    "bnnf": "Не удалось найти буфер с именем «%s»",
            \},
            \"etype": {
            \     "value": "InvalidValue",
            \    "action": "InvalidAction",
            \    "uknkey": "UnknownKey",
            \      "nfnd": "NotFound",
            \      "perm": "PermissionDenied",
            \},
            \"cache": {
            \   "th": {
            \       "trans": ["Источник", "Кэш вывода на экран",
            \                 "Кэш для транслитерации по мере ввода"],
            \   },
            \   "trsrc": {
            \        "var": "Переменная",
            \       "file": "Файл",
            \       "func": "Функция",
            \       "dict": "Анонимный словарь",
            \   },
            \   "other": {
            \        "col": "Для следующих количеств колонок:",
            \       "strl": "Список строк",
            \         "ll": "Список списков",
            \         "no": "Отсутствует",
            \        "yes": "Существует",
            \   },
            \},
        \}
else "{{{3
let s:g.p={
            \"emsg": {
            \     "sdt": "Value must be either string or dictionary",
            \     "str": "Value must be of a type “string”",
            \    "dict": "Value must be of a type “dictionary”",
            \    "list": "Value must be of a type “list”",
            \    "bool": "Value must be number, equal to either 0 or 1",
            \   "mnone": "Misplaced “none” key: ".
            \            "it mustn’t occur in the root of transsymb",
            \   "trans": "If transliteration table is a string, ".
            \            "it must be either a variable name, ".
            \            "starting with g: or b:, or a filename",
            \   "onfnd": "Option not found",
            \     "opt": "Option already exists",
            \    "narg": "Wrong number of arguments",
            \   "margs": "Too many arguments",
            \   "largs": "Not enough arguments",
            \    "trex": "Transliteration sequence already exists",
            \    "trnf": "Transliteration sequence not found",
            \    "trnd": "Unable to delete transliteration sequence",
            \    "tofs": "ToF already started",
            \   "tofgs": "ToF already started for all buffers",
            \   "tofns": "ToF not started yet",
            \     "fnc": "Provided function reference is not callable",
            \    "bnnf": "Buffer “%s” not found",
            \},
            \"etype": {
            \     "value": "InvalidValue",
            \    "action": "InvalidAction",
            \    "uknkey": "UnknownKey",
            \      "nfnd": "NotFound",
            \      "perm": "PermissionDenied",
            \},
            \"cache": {
            \   "th": {
            \       "trans": ["Table source", "Print cache", "ToF cache"],
            \   },
            \   "trsrc": {
            \        "var": "Variable",
            \       "file": "File",
            \       "func": "Function reference",
            \       "dict": "Unnamed dictionary",
            \   },
            \   "other": {
            \        "col": "For column numbers:",
            \       "strl": "String list",
            \         "ll": "List of lists only",
            \         "no": "Absent",
            \        "yes": "Exists",
            \   },
            \},
        \}
endif
"{{{1 Вторая загрузка — основная часть
"{{{2 s:g
let s:g.c={"options": {}}
"{{{2 Внешние дополнения
let s:F.plug.json=s:F.plug.load.getfunctions("json")
let s:F.plug.stuf=s:F.plug.load.getfunctions("stuf")
let s:F.plug.comp=s:F.plug.load.getfunctions("comp")
let s:F.plug.chk= s:F.plug.load.getfunctions("chk")
"{{{2 stuf
" Некоторые полезные вещи, не относящиеся непосредственно к плагину
"{{{3 s:Eval: доступ к внутренним переменным
" Внутренние переменные, в том числе s:F, недоступны в привязках
function s:Eval(var)
    return eval(a:var)
endfunction
let s:F.int["s:Eval"]=function("s:Eval")
"{{{3 stuf.strlen: получение длины строки
function s:F.stuf.strlen(str)
    return len(split(a:str, '\zs'))
endfunction
"{{{3 stuf.iscombining: проверить, является ли символ диакритикой
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
"{{{3 stuf.nextchar: получить следующий символ (reg('.'))
" Получить следующий символ. Если дан второй аргумент, то получить следующий за 
" позицией, данной во втором аргументе, символ.
function s:F.stuf.nextchar(str, ...)
    return matchstr(a:str, '.', ((len(a:000))?(a:000[0]):(0)))
endfunction
"{{{3 stuf.nextchar_nr получить следующий символ (nr2char(char2nr))
" То же, что и предыдущая функция, но получение следующего символа выполняется 
" с помощью nr2char(char2nr)
function s:F.stuf.nextchar_nr(str, ...)
    return nr2char(char2nr(a:str[((len(a:000))?(a:000[0]):(0)):]))
endfunction
"{{{3 stuf.checklod: проверить весь словарь или список
function s:F.stuf.checklod(subj, chk)
    return ((type(a:subj)==type({}))?
                \(index(values(map(copy(a:subj), a:chk)), 0)!=-1):
                \(index(map(copy(a:subj), a:chk), 0)!=-1))
endfunction
"{{{2 main: eerror, option, destruct, session
"{{{3 main.destruct: выгрузить плагин
function s:F.main.destruct()
    call s:F.mng.tof(1, "stop")
    call s:F.plug.comp.delcomp(s:g.comp._cname)
    call s:F.plug.comp.delcomp(s:g.comp._inputcname)
    call s:g.map.delinput()
    for F in keys(s:F.int)
        execute "delfunction ".F
    endfor
    unlet s:g
    unlet s:F
    return 1
endfunction
"{{{3 main.session: поддержка LoadCommand mksession
function s:F.main.session(...)
    if empty(a:000)
        let r={}
        let r.tof={}
        let r.tof.bufinfo={}
        for [bufnr, bufinfo] in items(s:g.tof.mutable.bufdicts)
            let r.tof.bufinfo[bufnr]=copy(bufinfo)
            let r.tof.bufinfo[bufnr].bufname=bufname(bufnr)
            unlet r.tof.bufinfo[bufnr].plugs
            unlet r.tof.bufinfo[bufnr].opts
            unlet r.tof.bufinfo[bufnr].chlist
            unlet r.tof.bufinfo[bufnr].bufnr
        endfor
        return r
    else
        let s=a:000[0]
        " Очистим словарь, не изменяя ссылку
        for bufnr in keys(s:g.tof.mutable.bufdicts)
            unlet s:g.tof.mutable.bufdicts[bufnr]
        endfor
        " Проверка ввода слишком сложна, поэтому я опускаю её
        for [bufnr, bufinfo] in items(s.tof.bufinfo)
            call s:F.tof.setup(0, 0, bufinfo)
        endfor
    endif
endfunction
"{{{2 comm: save, getresult, gettranssymb
" Функции, нужные для транслитерации
"{{{3 comm.remove: Удалить указанный id из кэша
function s:F.comm.remove(id)
    for cache in s:g.cache.trans
        call remove(cache, a:id)
    endfor
    for i in range(a:id, len(s:g.cache.trans[0])-1)
        unlockvar s:g.cache.trans[1][i].id
        let s:g.cache.trans[1][i].id-=1
        lockvar s:g.cache.trans[1][i].id
    endfor
endfunction
"{{{3 comm.save: сохранить изменения
function s:F.comm.save(transsymb)
    let id=a:transsymb.id
    if a:transsymb.origin!=#s:g.cache.trans[0][id]
        call s:F.comm.remove(id)
    endif
    let src=(a:transsymb.source[0])
    if src=="file"
        return s:F.plug.json.dump(a:transsymb.source[1], a:transsymb.origin)
    elseif src=="var"
        execute "let ".a:transsymb.source[1]."=a:transsymb.origin"
        return 1
    elseif src=="func"
        return call(a:transsymb.source[1], [a:transsymb.origin], {})
    endif
    return 0
endfunction
"{{{3 comm.getresult: преобразовать результат в соответствие с флагами
function s:F.comm.getresult(result, flags)
    " Что-то изменяем, только если есть флаг верхнего регистра
    if a:flags.upper==1
        "{{{4 Если изменять регистр должна только первая буква
        if a:flags.fstupper==1
            " К сожалению, regex «\l» работает далеко не всегда
            let slist=split(a:result, '\zs')
            let slen=len(slist)
            let idx=0
            while idx<slen
                let upper=toupper(slist[idx])
                if upper!=#slist[idx]
                    let slist[idx]=upper
                    break
                endif
                let idx+=1
            endwhile
            return join(slist, "")
        "{{{4 Если такого нет, но есть флаг верхнего регистра
        else
            return toupper(a:result)
        endif
        "}}}
    endif
    return a:result
endfunction
"{{{3 comm.checktrkey: проверить ключ
function s:F.comm.checktrkey(key, value, where)
    "{{{4 Объявление переменных
    let selfname="comm.checktrkey"
    let vtype=type(a:value)
    "{{{4 Если ключ — не один символ
    if a:key!~'^.$'
        "{{{5 Ключ «none»
        if a:key==#"none"
            if vtype!=type("")
                call s:F.main.eerror(selfname, "value", ["str"], a:where,
                            \s:F.plug.stuf.string(a:value))
                return 1
            elseif a:where==#'/none'
                call s:F.main.eerror(selfname, "value", ["mnone"])
                return 1
            else
                return 0
            endif
        "{{{5 Ключ «options»
        elseif a:key==#"options"
            "{{{6 Значение — словарь,
            if vtype!=type({})
                call s:F.main.eerror(selfname, "value", ["dict"],
                            \a:where, s:F.plug.stuf.string(a:value))
                return 1
            "{{{6 не являющийся пустым,
            elseif a:value=={}
                return 0
            "{{{6 имеющего строковый тип и значение «capital»,
            elseif s:F.stuf.checklod(copy(a:value),
                        \       'type(v:key)==type("") && v:key==#"capital"')
                call s:F.main.eerror(selfname, "uknkey",
                            \a:where."/...")
                return 1
            "{{{6 которому соответствует строковое значение,
            elseif type(a:value.capital)!=type("")
                call s:F.main.eerror(selfname, "value", ["str"],
                            \a:where."/capital",
                            \s:F.plug.stuf.string(a:value.capital))
                return 1
            "{{{6 равное одной из строк: «none» или «first».
            elseif       a:value.capital!="none" &&
                        \a:value.capital!="first"
                call s:F.main.eerror(selfname, "value", a:where."/capital",
                            \a:value.capital)
                return 1
            endif
        "{{{5 Неизвестный ключ
        else
            call s:F.main.eerror(selfname, "uknkey", a:where)
            return 1
        endif
    "{{{4 Односимвольный ключ
    else
        if vtype==type("")
            return 0
        elseif vtype==type({})
            return s:F.comm.checktranssymb(a:value, a:where)
        else
            call s:F.main.eerror(selfname, "value", ["sdt"],
                        \a:where, s:F.plug.stuf.string(a:value))
            return 1
        endif
    endif
    "}}}
    return 0
endfunction
"{{{3 comm.checktranssymb: проверить таблицу транслитерации
function s:F.comm.checktranssymb(transsymb, where)
    let errclist=values(map(copy(a:transsymb),
                \'s:F.comm.checktrkey(v:key, v:val, a:where."/".v:key)'))
    let result=0
    for errc in errclist
        let result+=errc
    endfor
    return result
endfunction
"{{{3 comm.formattr: перевести таблицу транслитерации во внутренний формат
function s:F.comm.formattr(transsymb)
    "{{{4 Таблица — словарь
    if type(a:transsymb)==type({})
        "{{{5 Объявление переменных
        let result={}
        "{{{5 Обход ключей
        for [key, value] in items(a:transsymb)
            "{{{6 Односимвольный ключ
            if key=~'^.$'
                let lower=tolower(key)
                "{{{7 Такой ключ уже есть
                if has_key(result, lower)
                    let result[lower][(key!=#lower)]=
                                \s:F.comm.formattr(value)
                "{{{7 Такого ключа нет
                else
                    "{{{8 Ключ в верхем регистре
                    if lower!=#key
                        let result[lower]=
                                    \[0, s:F.comm.formattr(value)]
                    "{{{8 В нижнем
                    else
                        let result[lower]=
                                    \[s:F.comm.formattr(value), 1]
                        "{{{9 Проверка настроек
                        if type(value)==type({}) &&
                                    \has_key(value, "options") &&
                                    \has_key(value.options,
                                    \                               "capital")
                            let cap=value.options.capital
                            if cap==#"none"
                                let result[lower][1]=0
                            elseif cap==#"first"
                                let result[lower][1]=2
                            endif
                        endif
                        "}}}9
                    endif
                    "}}}8
                endif
            "{{{6 Ключ «none»
            elseif key==#"none"
                let result.none=value
            endif
            "}}}6
            unlet value
        endfor
        "}}}5
        return result
    "{{{4 Таблица — не словарь (строка)
    else
        return {"none": a:transsymb}
    endif
    "}}}
endfunction
"{{{3 comm.gettranssymb: получить таблицу транслитерации
function s:F.comm.gettranssymb(...)
    let selfname="comm.gettranssymb"
    "{{{4 Получение таблицы внешнего формата
    if a:000==[]
        let l:Trans=s:F.main.option("DefaultTranssymb")
    else
        let l:Trans=a:000[0]
    endif
    let rettrans={}
    if type(l:Trans)==type("")
        if l:Trans=~#'^[gb]:[a-zA-Z_]\(\w\@<=\.\w\|\w\)*$'
            if exists(l:Trans)
                let rettrans=eval(l:Trans)
                let src=["var", l:Trans]
            else
                return s:F.main.eerror(selfname, "value", ["trans"])
            endif
        elseif l:Trans=~#'^\.\|\.json$\|[\\/]' && filereadable(l:Trans)
            let fname=fnamemodify(l:Trans, ":p")
            let rettrans=s:F.plug.json.load(fname)
            let src=["file", fname]
        else
            let fname=s:F.main.option("ConfigDir").'/'.l:Trans.".json"
            let fname=fnamemodify(fname, ":p")
            if filereadable(fname)
                let rettrans=s:F.plug.json.load(fname)
                let src=["file", fname]
            else
                return s:F.main.eerror(selfname, "value", ["trans"])
            endif
        endif
    elseif type(l:Trans)==type({})
        let rettrans=l:Trans
        let src=["dict", rettrans]
        " 2 — Funcref
    elseif type(l:Trans)==2
        if !exists('*l:Trans')
            return s:F.main.eerror(selfname, "value",
                        \          ["fnc"])
        endif
        let rettrans=call(l:Trans, [], {})
        let src=["func", l:Trans]
    else
        return s:F.main.eerror(selfname, "value")
    endif
    "{{{4 Кэш
    let idx=index(s:g.cache.trans[0], rettrans)
    let docheck=1
    if idx!=-1 && s:g.cache.trans[1][idx]!={}
        let docheck=0
        let fidx=idx
        while s:g.cache.trans[1][idx].source!=#src && idx!=-1
            let idx=index(s:g.cache.trans[0], rettrans, idx+1)
        endwhile
        if idx!=-1
            return s:g.cache.trans[1][idx]
        endif
    elseif idx==-1
        let idx=0
        while idx<len(s:g.cache.trans[1])
            if s:g.cache.trans[1][idx].source==#src
                call s:F.comm.remove(idx)
            else
                let idx+=1
            endif
        endwhile
    endif
    "{{{4 Получение таблицы транслитерации внут. формата и запись её в кэш
    if docheck
        "{{{5 Проверка правильности
        if s:F.comm.checktranssymb(rettrans, "")
            return 0
        endif
        let curtrans=s:F.comm.formattr(rettrans)
        "}}}5
    else
        let curtrans=deepcopy(s:g.cache.trans[1][fidx])
        unlet curtrans.origin
        unlet curtrans.source
    endif
    let result=extend(curtrans,
                \{"origin": rettrans,
                \ "source": src})
    " Делая глубокое копирование здесь, мы защищаемся от устаревания словаря: 
    " когда изменения в исходный словарь внесены, но ещё не внесены 
    " в преобразованный словарь
    let result.id=len(s:g.cache.trans[0])
    call add(s:g.cache.trans[0], deepcopy(rettrans))
    call add(s:g.cache.trans[1], result)
    call add(s:g.cache.trans[2], deepcopy(s:g.cache.init.print))
    call add(s:g.cache.trans[3], [])
    if index(["file", "var"], curtrans.source[0])!=-1 &&
                \index(s:g.comp.lst.transsymb, curtrans.source[1])==-1
        call add(s:g.comp.lst.transsymb, curtrans.source[1])
    endif
    lockvar! result
    unlockvar! result.origin
    "}}}4
    return result
endfunction
"{{{2 trs:  main(transliterate): обычная транслитерация
"{{{3 s:g.trs
let s:g.trs={
            \"defaultflags": {
            \      "upper": -1,
            \   "fstupper": 0,
            \   "transbeg": 0,
            \},
            \"defaultstatus": {
            \     "status": "failure",
            \     "result": "",
            \      "delta":  0,
            \},
        \}
"{{{3 trs.plug: дополнения для обычной транслитерации
"{{{4 trs.plug.esc: экранировать следующий символ
function s:F.trs.plug.esc(match, str, transsymb, cache, flags)
    let result=s:F.stuf.nextchar(a:str)
    let rlen=len(result)
    if !rlen
        let result=a:match
    endif
    return {
                \"status": "success",
                \"result":     result,
                \ "delta": len(result),
                \ "flags": a:flags,
            \}
endfunction
"{{{4 trs.plug.notransword: не транслитерировать следующее слово
function s:F.trs.plug.notransword(match, str, transsymb, cache, flags)
    let result=a:cache.NoTransWord.value[a:match]
    let ntr=matchstr(a:str, '^\S*')
    let delta=len(ntr)
    let result.=ntr
    return {
                \"status": "success",
                \"result":  result,
                \ "delta":  delta,
                \ "flags": copy(s:g.trs.defaultflags),
            \}
endfunction
"{{{4 trs.plug.notrans: временное прерывание транслитерации
function s:F.trs.plug.notrans(match, str, transsymb, cache, flags)
    let  result=a:cache.StopTrSymbs.value[a:match]
    let ntrstr=""
    let delta=0
    let slen=len(a:str)
    let startstr=""
    while delta<slen
        let ntr=matchlist(a:str,
                    \'^\(\_.\{-}\)\C\(\('.a:cache.EscSeq.regex.'\)*\)\@>'.
                    \'\('.(a:cache.StartTrSymbs.regex).'\|\%$\)', delta)
        let esccount=len(ntr[2])/a:cache.EscSeq.len
        let delta+=len(ntr[0])
        if esccount%2==0
            let ntrstr.=ntr[1].ntr[2]
            let startstr=ntr[4]
            break
        endif
        let ntrstr.=ntr[0]
    endwhile
    let ntrstr=substitute(ntrstr, a:cache.EscSeq.regex.'\(.\)', '\1', 'g')
    if len(startstr)
        let ntrstr.=a:cache.StartTrSymbs.value[startstr]
    endif
    return {
                \"status": "success",
                \"result":  (result).(ntrstr),
                \ "delta":   delta,
                \ "flags": copy(s:g.trs.defaultflags),
            \}
endfunction
"{{{4 trs.plug.brk: прерывание транслитерируемой последовательности
"{{{5 s:g.trs.brkresult
let s:g.trs.brkresult={
                \"status": "success",
                \"result": "",
                \ "delta":  0,
                \ "flags": s:g.trs.defaultflags,
            \}
"}}}5
function s:F.trs.plug.brk(match, str, transsymb, cache, flags)
    return deepcopy(s:g.trs.brkresult)
endfunction
"{{{3 trs.plugrun: запуск дополнений
function s:F.trs.plugrun(plug, str, transsymb, cache, flags)
    let matchidx=match(a:str, '^\C\('.(a:plug[1]).'\)')
    if matchidx==0
        let match=matchstr(a:str, '^\C\('.(a:plug[1]).'\)')
        let lastret=call(a:plug[0], [match, a:str[len(match):], a:transsymb,
                    \a:cache, a:flags], {})
        let lastret.delta+=len(match)
        return lastret
    endif
    return s:g.trs.defaultstatus
endfunction
"{{{3 trs.setstatus: изменение возвращаемого результата
function s:F.trs.setstatus(retstatus, lastret)
    if a:lastret.status!=#"failure"
        let result=s:F.comm.getresult(a:lastret.result,
                    \                  a:lastret.flags)
        if a:retstatus.status==#"plugsuccess" ||
                    \a:lastret.status==#"plugsuccess"
            let a:retstatus.result=result.(a:retstatus.result)
        else
            let a:retstatus.result.=result
        endif
        let a:retstatus.status = a:lastret.status
        let a:retstatus.delta += a:lastret.delta
        let a:retstatus.flags  = copy(s:g.trs.defaultflags)
    endif
    return a:retstatus
endfunction
"{{{3 trs.transliterate: транслитерация одной последовательности
function s:F.trs.transliterate(str, transsymb, cache, flags)
    "{{{4 Объявление переменных
    let retstatus=copy(s:g.trs.defaultstatus)
    let retstatus.flags=a:flags
    let chknone=!retstatus.flags.transbeg
    "{{{4 Плагины, которые надо запускать до транслитерации
    for plug in a:cache.Plugs.Before
        let lastret=s:F.trs.plugrun(plug, a:str[(retstatus.delta):],
                    \a:transsymb, a:cache, retstatus.flags)
        call s:F.trs.setstatus(retstatus, lastret)
        if retstatus.status==#"success"
            if !retstatus.flags.transbeg
                let chknone=1
                let retstatus.status="plugsuccess"
            endif
            break
        endif
    endfor
    "{{{4 Транслитерация
    "{{{5 Объявление переменных
    let curch=s:F.stuf.nextchar(a:str, retstatus.delta)
    let lower=tolower(curch)
    "{{{5 Если есть ключ, соответствующий следующему символу
    if has_key(a:transsymb, lower) && retstatus.status!=#"success" &&
                \retstatus.status!=#"plugsuccess"
        let [lwtrans, uptrans]=a:transsymb[lower]
        "{{{6 Флаги
        if type(uptrans)==type(0)
            if uptrans==2
                let retstatus.flags.fstupper=1
            elseif uptrans==0
                let retstatus.flags.upper=-2
            endif
        endif
        let isupper=(lower!=#curch)
        let hasupper=(lower!=#toupper(curch))
        if  retstatus.flags.upper==-1 && hasupper
            let retstatus.flags.upper=isupper
        endif
        "{{{6 Транслитерация
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
            let lastret=s:g.trs.defaultstatus
        endif
        "{{{6 Успешное завершение
        if lastret.status!=#"failure"
            let transbeg=retstatus.flags.transbeg
            call s:F.trs.setstatus(retstatus, lastret)
            if retstatus.status!=#"plugsuccess"
                let retstatus.delta+=len(curch)
            else
                let retstatus.flags.transbeg=transbeg
            endif
            let chknone=0
        endif
        "}}}6
    endif
    "{{{5 Если есть ключ «none» и его надо проверить
    " Проверять его надо в случае, если это не первая итерация (за это 
    " ответственен флаг transbeg), и транслитерация не завершилась успехом 
    " ранее
    if (chknone || retstatus.status==#"plugsuccess") &&
                \has_key(a:transsymb, "none")
        call s:F.trs.setstatus(retstatus, {
                    \"status": "success",
                    \ "delta":  0,
                    \"result": a:transsymb.none,
                    \ "flags": retstatus.flags,
                \})
    endif
    "{{{4 Плагины, которые надо запускать после транслитерации
    if retstatus.status!=#"success" && retstatus.flags.transbeg
        if retstatus.status!=#"plugsuccess"
            for plug in a:cache.Plugs.After
                let lastret=s:F.trs.plugrun(plug, a:str[(retstatus.delta):],
                            \a:transsymb, a:cache, retstatus.flags)
                call s:F.trs.setstatus(retstatus, lastret)
                if lastret.status==#"success"
                    break
                endif
            endfor
        endif
        if (retstatus.status==#"failure" && !retstatus.delta && len(curch)) ||
                    \retstatus.status==#"plugsuccess"
            call s:F.trs.setstatus(retstatus, {
                        \"status": "success",
                        \ "delta":  len(curch),
                        \"result":      curch,
                        \ "flags": copy(s:g.trs.defaultflags),
                    \})
            let retstatus.status="failure"
        endif
    endif
    "}}}4
    return retstatus
endfunction
"{{{3 trs.getplugin
"{{{4 s:g.trs.plugregex
" plugregex — словарь, в котором написано для каких плагинов нужны какие
"             регулярные выражения, полученные из настроек
let s:g.trs.plugregex={
            \   "notransword": "NoTransWord",
            \           "brk": "BrkSeq",
            \           "esc": "EscSeq",
            \       "notrans": "StopTrSymbs",
            \}
"}}}4
function s:F.trs.getplugin(plugin, cache)
    if type(a:plugin)==type("")
        return      [s:F.trs.plug[a:plugin],
                    \a:cache[s:g.trs.plugregex[a:plugin]].regex]
    endif
    return a:plugin
endfunction
"{{{3 trs.main: транслитерация всей строки
"{{{4 s:g.trs: stropt, dictstrstropt
"    stropt — перечисление настроек строкового типа, которые нужно превратить
"             в регулярные выражения
" dictstrstropt — то же самое для настроек-словарей с парами строка-строка
"}}}4
let s:g.trs.stropt=["EscSeq", "BrkSeq"]
let s:g.trs.dictstrstropt=["StartTrSymbs", "StopTrSymbs", "NoTransWord"]
function s:F.trs.main(str, transsymb)
    "{{{4 Кэш: настройки
    let cache={}
    "{{{5 Простые строковые
    for O in s:g.trs.stropt
        let opt=s:F.main.option(O)
        let optregex=s:F.plug.stuf.regescape(opt)
        call extend(cache, {(O): {"value": opt, "regex": optregex}})
    endfor
    let cache.EscSeq.len=len(cache.EscSeq.value)
    unlet opt
    "{{{5 Словарь {строка: строка, …}
    for O in s:g.trs.dictstrstropt
        let opt=s:F.main.option(O)
        let optregexs =  map(copy(opt), "s:F.plug.stuf.regescape(v:key)")
        let optregex  = join(values(optregexs), '\|')
        call extend(cache, {(O): {"value": opt, "regex": optregex}})
    endfor
    let cache.StartTrSymbs.esccreg='\('.(cache.EscSeq.regex).'\)\+'.
                \ '\('.(cache.StartTrSymbs.regex).'\)\@='
    "{{{5 Плагины
    let plugs=s:F.main.option("Plugs")
    let cache.Plugs={"Before": [], "After": []}
    for key in keys(plugs)
        call map(copy(plugs[key]),
                    \'add(cache.Plugs[key], s:F.trs.getplugin(v:val, cache))')
    endfor
    "}}}5
    lockvar! cache
    "{{{4 Объявление переменных
    let result=""
    let str=a:str
    let flags=copy(s:g.trs.defaultflags)
    let flags.transbeg=1
    "{{{4 Основной цикл
    while len(str)
        let lastret=s:F.trs.transliterate(str, a:transsymb, cache, copy(flags))
        let result.=lastret.result
        let str=str[(lastret.delta):]
    endwhile
    "}}}4
    return result
endfunction
"{{{2 tof:  setup, stop, transchar: транслитерация по мере ввода
"{{{3 s:g.tof
" В mutable содержатся изменяемые данные: словари, привязанные к буферу 
" и таблица транслитерации (только в случае, если транслитерация по мере ввода 
" включена для всех буферов)
let s:g.tof={
            \"defaultflags": {
            \      "upper": -1,
            \   "fstupper": 0,
            \},
            \"failresult": {"status": "failure",},
            \"initvars": { "notrans": 0, "notransword": 0, "ntword": "",
            \              "ntwline": 0, },
            \"mutable": {"bufdicts":{}},
            \"bs": "\ecl",
        \}
"{{{3 tof.*_w: Поддержка нестандартных способов ввода
function s:F.tof.conque_w(str)
    if exists('b:ConqueTerm_Var')
        let lbs=len(s:g.tof.bs)
        let str=a:str
        let start=""
        while str[0:(lbs-1)]==#s:g.tof.bs
            let start.="\<C-h>"
            let str=str[(lbs):]
        endwhile
        let str=start.str
        execute 'python '.b:ConqueTerm_Var.'.write(vim.eval("str"))'
    else
        call 'normal! i'.a:str
    endif
endfunction
"{{{3 tof.plug: плагины для транслитерации по мере ввода
"{{{4 tof.plug.notrans: временно прервать транслитерацию
function s:F.tof.plug.notrans(bufdict, char)
    if a:bufdict.vars.notrans
        if has_key(a:bufdict.opts.StartTrSymbs.value, a:char)
            let a:bufdict.vars.notrans=0
            return      {"status": "stopped",
                        \"result": a:bufdict.opts.StartTrSymbs.value[a:char]}
        endif
        return      {"status": "success",
                    \"result": s:F.tof.getuntrans(a:bufdict, a:char)}
    endif
    if has_key(a:bufdict.opts.StopTrSymbs.value, a:char)
        let a:bufdict.vars.notrans=1
        return      {"status": "started",
                    \"result": a:bufdict.opts.StopTrSymbs.value[a:char]}
    endif
    return s:g.tof.failresult
endfunction
"{{{4 tof.plug.brk: прервать транслитерируемую последовательность
let s:g.tof.brkresult={"status": "success",
            \          "result": ""}
function s:F.tof.plug.brk(bufdict, char)
    return s:g.tof.brkresult
endfunction
"{{{4 tof.plug.comm: Транслитерировать только внутри комментария
function s:F.tof.plug.comm(bufdict, char)
    " synstack cannot work if line is empty
    if col('$')==1
        let stack=[synID(line('.'), 1, 0)]
    else
        let col=col('.')
        if col>=col('$')
            let col=col('$')-1
        endif
        try
            let stack=synstack(line('.'), col)
            if type(stack)!=type([])
                unlet stack
                let stack=[synID(line('.'), 1, 0)]
            endif
        catch
            let stack=[synID(line('.'), 1, 0)]
        endtry
    endif
    while !empty(stack)
        if synIDattr(remove(stack, -1), "name")=~?"comment"
            return s:g.tof.failresult
        endif
    endwhile
    return      {"status": "success",
                \"result": s:F.tof.getuntrans(a:bufdict, a:char)}
endfunction
"{{{4 tof.plug.notransword: Не транслитерировать следующее слово
function s:F.tof.plug.notransword(bufdict, char)
    if a:bufdict.vars.notransword
        let curline=line('.')
        let curcol=col('.')
        let curlinestr=getline(curline)
        let curlinestr=substitute(curlinestr, '\%'.curcol.'c.*', '', '')
        if a:char!~#'^\k*$' ||
                    \((a:bufdict.vars.ntwline!=curline &&
                    \  a:bufdict.vars.ntwline!=curline-1) ||
                    \ curlinestr!~#s:F.plug.stuf.regescape(
                    \                   a:bufdict.vars.ntword).'$')
            let a:bufdict.vars.notransword=0
            return {"status": "stopped"}
        endif
        let a:bufdict.vars.ntword.=a:char
        return      {"status": "success",
                    \"result": s:F.tof.getuntrans(a:bufdict, a:char)}
    endif
    if has_key(a:bufdict.opts.NoTransWord.value, a:char)
        let a:bufdict.vars.notransword=1
        let a:bufdict.vars.ntwline=line('.')
        let a:bufdict.vars.ntword=""
        return      {"status": "started",
                    \"result": a:bufdict.opts.NoTransWord.value[a:char]}
    endif
    return s:g.tof.failresult
endfunction
"{{{3 tof.plugrun: запустить плагин
function s:F.tof.plugrun(bufdict, char, plug, idx)
    let retstatus=call(a:plug[0], [a:bufdict, a:char], {})
    if retstatus.status==#"started" && index(a:bufdict.curplugs, a:idx)==-1
        call insert(a:bufdict.curplugs, a:idx)
    elseif retstatus.status==#"stopped"
        call remove(a:bufdict.curplugs, index(a:bufdict.curplugs, a:idx))
    endif
    return retstatus
endfunction
"{{{3 tof.getuntrans: получить нетранслитерированный результат
function s:F.tof.getuntrans(bufdict, char)
    if has_key(a:bufdict.exmaps, a:char)
        let exmap=a:bufdict.exmaps[a:char]
        " Не парим себе мозги относительно того, что надо вернуть, чтобы 
        " привязка работала как будто транслитерация по мере ввода не запущена
        execute  "i".((exmap.noremap)?("nore"):     (""))."map <special> ".
                    \"<buffer> ".
                    \((exmap.silent)? ("<silent> "):("")).
                    \((exmap.expr)?   ("<expr> "):  ("")).
                    \"<Plug>Translit3TempMap ".
                    \substitute(exmap.rhs, '<SID>', '<SNR>'.exmap.sid.'_', 'g')
        " По непонятной причине feedkeys непосредственно в скрипте не работает, 
        " поэтому используется следующий хак
        return "\<C-\>\<C-o>:call feedkeys(\"\\<Plug>Translit3TempMap\")\<CR>"
    endif
    return a:char
endfunction
"{{{3 tof.transchar: обработать полученный символ
function s:F.tof.transchar(bufdict, char)
    let lower=tolower(a:char)
    "{{{4 Плагины
    "{{{5 Если сейчас действует плагин
    let plugresult=""
    for idx in a:bufdict.curplugs
        let retstatus=s:F.tof.plugrun(a:bufdict, a:char,
                    \a:bufdict.plugs[idx], idx)
        if retstatus.status==#"pass"
            if has_key(retstatus, "result")
                let plugresult.=retstatus.result
            endif
        elseif retstatus.status!=#"failure"
            if has_key(retstatus, "result")
                return retstatus.result
            endif
        endif
    endfor
    "{{{5 Если нет действующего плагина
    if len(a:bufdict.curtrans)==1
        let i=0
        while i<len(a:bufdict.plugs)
            let l:P=a:bufdict.plugs[i]
            if           (type(l:P[1])==type([]) && index(l:P[1], a:char)!=-1) ||
                        \(type(l:P[1])==type("") && a:char=~#l:P[1])
                let retstatus=s:F.tof.plugrun(a:bufdict, a:char, l:P, i)
                if retstatus.status==#"pass"
                    if has_key(retstatus, "result")
                        let plugresult.=retstatus.result
                    endif
                elseif retstatus.status!=#"failure"
                    if has_key(retstatus, "result")
                        return retstatus.result
                    endif
                endif
            endif
            let i+=1
        endwhile
    endif
    "{{{4 Транслитерация
    "{{{5 Объявление переменных
    let isupper=(lower!=#a:char)
    let [curline, curcol]=getpos('.')[1:2]
    let curlinestr=getline(curline)
    if curcol<=len(curlinestr)
        let curlinestr=substitute(curlinestr, '\%'.curcol.'c.*', '', '')
    endif
    "{{{5 Прерывание последовательности
    if a:bufdict.bufnr!=0 && len(a:bufdict.curtrans)>1 &&
                \((a:bufdict.lastline!=curline &&
                \  a:bufdict.lastline != curline-1) ||
                \ curlinestr!~#s:F.plug.stuf.regescape(a:bufdict.curtrseq).'$'||
                \
                \ (isupper && a:bufdict.flags.upper==0 &&
                \  !(has_key(a:bufdict.curtrans[-1], lower) &&
                \    type(a:bufdict.curtrans[-1][lower][1])==type({}))))
        return s:F.tof.transbreak(a:bufdict, a:char, plugresult)
    endif
    let a:bufdict.lastline=curline
    "{{{5 Собственно, транслитерация
    if has_key(a:bufdict.curtrans[-1], lower)
        "{{{6 Таблица транслитерации
        let [lwtrans, uptrans]=a:bufdict.curtrans[-1][lower]
        "{{{7 Верхний регистр
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
        "{{{7 Не верхий регистр
        elseif type(lwtrans)==type({})
            let curtrans=lwtrans
            if a:bufdict.flags.upper==-1 && lower!=#toupper(a:char)
                let a:bufdict.flags.upper=0
            endif
            if type(uptrans)==type(0)
                if uptrans==0
                    let a:bufdict.flags.upper=0
                elseif uptrans==2
                    let a:bufdict.flags.fstupper=1
                endif
            endif
        "{{{7 Символ отсутствует в таблице транслитерации
        else
            return s:F.tof.transbreak(a:bufdict, a:char, plugresult)
        endif
        "}}}7
        call add(a:bufdict.curtrans, curtrans)
        let bsseq=""
        "{{{6 Транслитерация символа
        if has_key(curtrans, "none")
            " Результат транслитерации
            let result=s:F.comm.getresult(curtrans.none, a:bufdict.flags)
            " Замена предыдущего результата транслитерации
            let bsseq=repeat(s:g.tof.bs, s:F.stuf.strlen(a:bufdict.curtrseq))
            "{{{7 Combining diacritics
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
                let ch=matchstr(curlinestr, '.$')
                let result=(ch[:(-1-combdlen)]).result
            endif
            "}}}7
        else
            let a:bufdict.curtrseq.=(a:char)
            let result=a:char
        endif
        return bsseq.plugresult.result
        "}}}6
    else
        return s:F.tof.transbreak(a:bufdict, a:char, plugresult)
    endif
    "{{{4 Несколько символов
    let clist=split(a:char, '\zs')
    if len(clist)>1
        return join(map(clist, 's:F.tof.transchar(a:bufdict, v:val)'), '')
    endif
    "}}}4
endfunction
"{{{3 tof.transbreak: прервать последовательность
" Прервать последовательность и, возможно, вызвать tof.transchar
function s:F.tof.transbreak(bufdict, char, ...)
    let dotrans=(len(a:bufdict.curtrans)>1)
    call s:F.tof.breakseq(a:bufdict)
    if dotrans
        return s:F.tof.transchar(a:bufdict, a:char)
    else
        return ((len(a:000))?(a:000[0]):("")).a:char
    endif
endfunction
"{{{3 tof.breakseq: прервать последовательность
function s:F.tof.breakseq(bufdict)
    let a:bufdict.curtrans=[a:bufdict.transsymb]
    let a:bufdict.curtrseq=""
    let a:bufdict.flags=copy(s:g.tof.defaultflags)
    let a:bufdict.lastline=-2
    let a:bufdict.vars=deepcopy(s:g.tof.initvars)
    return 1
endfunction
"{{{3 tof.map: создать привязку
function s:F.tof.map(bufdict, char)
    let char=s:F.plug.stuf.mapprepare(a:char)
    let hasdictmap=(v:version==703 && has("patch32")) || v:version>703
    if hasdictmap
        let exmap=maparg(a:char, "i", 0, 1)
    else
        let exmap=maparg(a:char, "i")
    endif
    if !empty(exmap)
        if hasdictmap
            let a:bufdict.exmaps[a:char]=exmap
        else
            redir => eximapredir
            silent! execute "imap ".char
            redir END
            let eximapredir=eximapredir[1:-2]
            let eximaptype=eximapredir[(-len(exmap)-2)][0]
            let noremap=0
            if eximaptype==#'*'
                let mapcmd=1
            endif
            let a:bufdict.exmaps[a:char]={
                        \    "lhs": a:char,
                        \    "rhs": exmap,
                        \ "silent": 0,
                        \"noremap": noremap,
                        \   "expr": 0,
                        \ "buffer": 2,
                        \   "mode": "i",
                        \    "sid": 0,
                    \}
        endif
    endif
    let charexpr='call(<SID>Eval("s:F.tof.transchar"), '.
                \     '[<SID>Eval("s:g.tof.mutable.bufdicts['.
                \               (a:bufdict.bufnr).']"),'.
                \      '"'.substitute(escape(a:char, '>|"\'),
                \                     "\n", '\\n', 'g').'"], {})'
    if type(a:bufdict.writefunc)==type(0)
        execute 'inoremap <special> <expr> <buffer> '.char.' '.charexpr
    else
        execute 'inoremap <special> <buffer> '.char.' '.
                    \'<C-\><C-o>:call call('.a:bufdict.writefunc.', '.
                    \                     '['.charexpr.'], {})<CR>'
    endif
    return 1
endfunction
"{{{3 tof.formattrlistch: список всех символов
" Создать список всех символов в таблице транслитерации
function s:F.tof.formattrlistch(transsymb)
    " Словарь выбран для того, чтобы не заботится об уникальности символа.
    let result={}
    for key in keys(a:transsymb)
        if key=~'^.$'
            let [lwtrans, uptrans]=a:transsymb[key]
            let upper=toupper(key)
            if key!=#upper
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
"{{{3 tof.addtochlist: добавить символы к списку символов
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
"{{{3 tof.addoption: добавить настройку
function s:F.tof.addoption(bufdict, option)
    let opt=s:F.main.option(a:option)
    let a:bufdict.opts[a:option]={"value": (opt),}
    if index(s:g.opts.str, a:option)!=-1
        call s:F.tof.addtochlist(a:bufdict, opt)
    elseif index(s:g.opts.dictstrstr, a:option)!=-1
        call map(keys(opt), 's:F.tof.addtochlist(a:bufdict, v:val)')
    endif
    return 1
endfunction
"{{{3 tof.addplugin: добавить плагин
"{{{4 s:g.tof: plug, plugopts, blankkeys
let s:g.tof.blankkeys=[' ', "\<C-m>"]
let s:g.tof.plugopts={
            \ "notrans"     : ["StartTrSymbs", "StopTrSymbs"],
            \ "notransword" : ["NoTransWord"],
            \ "brk"         : ["BrkSeq"],
        \}
" То, что должно оказаться в качестве второго элемента списка из списка 
" bufdict.plugs
let s:g.tof.plug={
            \   "comm": "'.'",
            \   "notrans": "keys(a:bufdict.opts.StopTrSymbs.value)",
            \   "notransword": "keys(a:bufdict.opts.NoTransWord.value)+".
            \                  "s:g.tof.blankkeys",
            \   "brk": "[a:bufdict.opts.BrkSeq.value]",
            \}
"}}}4
function s:F.tof.addplugin(bufdict, plugin)
    if type(a:plugin)==type("")
        if has_key(s:g.tof.plugopts, a:plugin)
            call map(copy(s:g.tof.plugopts[a:plugin]),
                        \'s:F.tof.addoption(a:bufdict, v:val)')
        endif
        call add(a:bufdict.plugs,
                    \[s:F.tof.plug[a:plugin], eval(s:g.tof.plug[a:plugin])])
        if a:plugin=="notransword"
            call map(copy(s:g.tof.blankkeys),
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
"{{{3 tof.makemaps: создать привязки
function s:F.tof.makemaps(bufdict)
    "{{{4 Переход к буферу
    let curbuf=bufnr('%')
    if curbuf!=a:bufdict.bufnr
        execute "buffer ".(a:bufdict.bufnr)
    endif
    "{{{4 Кэш
    let id=a:bufdict.transsymb.id
    if len(s:g.cache.trans[3][id])
        let chars=s:g.cache.trans[3][id]
    else
        let chars=keys(s:F.tof.formattrlistch(a:bufdict.transsymb))
        let s:g.cache.trans[3][id]=chars
        lockvar! chars
    endif
    let a:bufdict.chlist=copy(chars)
    "{{{4 Плагины
    let a:bufdict.opts={}
    if !empty(a:bufdict.originplugs)
        let plugs=a:bufdict.originplugs
    else
        let plugs=s:F.main.option("ToFPlugs")
        let a:bufdict.originplugs=plugs
    endif
    call map(copy(plugs), 's:F.tof.addplugin(a:bufdict, v:val)')
    "{{{4 Блокировка
    lockvar! a:bufdict.chlist
    lockvar! a:bufdict.opts
    lockvar! a:bufdict.plugs
    "{{{4 Создание привязок
    call map(copy(a:bufdict.chlist), 's:F.tof.map(a:bufdict, v:val)')
    "{{{4 Обратный переход
    if curbuf!=a:bufdict.bufnr
        execute "buffer ".curbuf
    endif
    "}}}4
    return 1
endfunction
"{{{3 tof.setup: включить транслитерацию по мере ввода
"{{{4 s:g.tof.rewritefunc
let s:g.tof.rewritefunc={
            \'@conque': '<SID>Eval("s:F.tof.conque_w")',
        \}
lockvar! s:g.tof.rewritefunc
"}}}4
function s:F.tof.setup(buffer, transsymb, ...)
    let selfname="tof.setup"
    if empty(a:000)
        let bufdict={
                    \"transsymb": a:transsymb,
                    \ "curtrans": [a:transsymb],
                    \ "curtrseq": "",
                    \    "flags": copy(s:g.tof.defaultflags),
                    \ "lastline": -2,
                    \    "bufnr": a:buffer,
                    \   "exmaps": {},
                    \     "vars": deepcopy(s:g.tof.initvars),
                    \    "plugs": [],
                    \ "curplugs": [],
                    \"writefunc": s:F.main.option("WriteFunc"),
                    \   "chlist": [],
                    \     "opts": {},
                    \"originplugs": [],
                \}
        if has_key(s:g.tof.rewritefunc, bufdict.writefunc)
            let bufdict.writefunc=s:g.tof.rewritefunc[bufdict.writefunc]
        elseif type(bufdict.writefunc)!=type(0)
            let bufdict.writefunc="'".bufdict.writefunc."'"
        endif
    else
        let bufdict=a:000[0]
        " Здесь приходится идентифицировать буфер по имени, что не всегда 
        " надёжно
        let bufdict.bufnr=bufnr(bufdict.bufname)
        if empty(bufdict.bufnr)
            return s:F.main.eerror(selfname, "nfnd", ["bnnf", bufdict.bufname])
        endif
        unlet bufdict.bufname
    endif
    lockvar! bufdict.bufnr
    lockvar 1 bufdict
    if bufdict.bufnr!=0
        let s:g.tof.mutable.bufdicts[bufdict.bufnr]=bufdict
        augroup Tr3ToF
            execute "autocmd! * <buffer=".(bufdict.bufnr).">"
            execute "autocmd BufWipeout <buffer=".(bufdict.bufnr)."> call ".
                        \"s:F.tof.stop(copy(s:g.tof.mutable.bufdicts[".
                        \   (bufdict.bufnr)."]))"
        augroup END
        return s:F.tof.makemaps(bufdict)
    else
        return bufdict
    endif
endfunction
"{{{3 tof.unmap: удалить привязки
function s:F.tof.unmap(bufdict)
    for M in a:bufdict.chlist
        let curch=s:F.plug.stuf.mapprepare(M)
        execute 'silent! iunmap <special> <buffer> '.curch
        " Если привязка локально, то ничего восстанавливать не надо
        if has_key(a:bufdict.exmaps, M) && !a:bufdict.exmaps[M].buffer==1
            let exmap=a:bufdict.exmaps[M]
            execute  "i".((exmap.noremap)?("nore"):     (""))."map <special> ".
                        \((exmap.buffer)? ("<buffer> "):("")).
                        \((exmap.silent)? ("<silent> "):("")).
                        \((exmap.expr)?   ("<expr> "):  ("")).
                        \curch." ".
                        \substitute(exmap.rhs, '<SID>', '<SNR>'.exmap.sid.'_',
                        \           'g')
        endif
    endfor
    return 1
endfunction
"{{{3 tof.stop: выключить транслитерацию по мере ввода
function s:F.tof.stop(bufdict)
    let curbuf=bufnr('%')
    if curbuf!=a:bufdict.bufnr
        execute "buffer ".(a:bufdict.bufnr)
    endif
    augroup Tr3ToF
        execute "autocmd! * <buffer=".(a:bufdict.bufnr).">"
    augroup END
    call s:F.tof.unmap(a:bufdict)
    unlet s:g.tof.mutable.bufdicts[(a:bufdict.bufnr)]
    if curbuf!=a:bufdict.bufnr
        execute "buffer ".curbuf
    endif
    return 1
endfunction
"{{{2 mod:  add, del, setoption, main: изменение таблицы транслитерации
"{{{3 mod.formattotr
" Превратить пару ("...", "smth") в {'.': {'.': {'.': "smth"} } }.
function s:F.mod.formattotr(srcstr, trstr)
    if a:srcstr==#""
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
"{{{3 mod.add: добавить транслитерируемую последовательность
function s:F.mod.add(srcstr, trstr, replace, transsymb)
    let selfname="mod.add"
    let curch=s:F.stuf.nextchar(a:srcstr)
    let tail=a:srcstr[(len(curch)):]
    if curch==""
        if a:replace || !has_key(a:transsymb, "none")
            let a:transsymb.none=s:F.mod.formattotr(tail, a:trstr)
            return 1
        else
            return s:F.main.eerror(selfname, "perm", ["trex"])
        endif
    elseif has_key(a:transsymb, curch)
        if type(a:transsymb[curch])==type("")
            if len(tail)
                let a:transsymb[curch]=extend(s:F.mod.formattotr(tail,
                            \                                       a:trstr),
                            \                   {"none": a:transsymb[curch]})
                return 1
            elseif a:replace
                let a:transsymb[curch]=s:F.mod.formattotr(tail, a:trstr)
                return 1
            else
                return s:F.main.eerror(selfname, "perm", ["trex"])
            endif
        else
            return s:F.mod.add(tail, a:trstr, a:replace, a:transsymb[curch])
        endif
    else
        let a:transsymb[curch]=s:F.mod.formattotr(tail, a:trstr)
        return 1
    endif
endfunction
"{{{3 mod.del: удалить транслитерируемую последовательность
function s:F.mod.del(trstr, recurse, transsymb)
    let selfname="mod.del"
    let transsymb=a:transsymb
    let trlist=split(a:trstr, '\zs')
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
                return s:F.main.eerror(selfname, "nfnd", ["trnf"], a:trstr)
            endif
        else
            return s:F.main.eerror(selfname, "nfnd", ["trnf"], a:trstr)
        endif
        let i+=1
    endwhile
    if a:recurse
        unlet transsymb[curch]
        return 1
    elseif has_key(transsymb[curch], "none")
        unlet transsymb[curch].none
        return 1
    else
        return s:F.main.eerror(selfname, "perm", ["trnd"], a:trstr)
    endif
    return 0
endfunction
"{{{3 mod.setoption: установить или удалить настройку
function s:F.mod.setoption(srcstr, option, value, replace, transsymb)
    "{{{4 Объявление переменных
    let selfname="mod.setoption"
    let trlist=split(a:srcstr, '\zs')
    let deloption=(a:replace==2)
    let trans=a:transsymb
    let opt={(a:option): a:value}
    let i=0
    "{{{4 Цикл
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
                    if has_key(trans, "options")
                        if deloption
                            if has_key(trans.options, a:option)
                                unlet trans.options[a:option]
                                if trans.options=={}
                                    unlet trans.options
                                endif
                                break
                            else
                                return s:F.main.eerror(selfname, "nfnd",
                                            \["onfnd"], a:option)
                            endif
                        else
                            if !a:replace &&
                                        \has_key(trans.options, a:option) &&
                                        \(trans.options[a:option]!=a:value)
                                return s:F.main.eerror(selfname, "perm",
                                            \["opt"], a:option,
                                            \trans.options[a:option])
                            else
                                call extend(trans.options, opt, "force")
                                break
                            endif
                        endif
                    else
                        if deloption
                            return s:F.main.eerror(selfname, "nfnd",
                                        \["onfnd"], a:option)
                        else
                            let trans.options=opt
                            break
                        endif
                    endif
                endif
            elseif i == len(trlist)-1
                if deloption
                    return s:F.main.eerror(selfname, "nfnd", ["onfnd"],
                                \a:option)
                else
                    let trans[trlist[i]]={
                                \   "none": trans[trlist[i]],
                                \"options": (opt)
                            \}
                    break
                endif
            endif
        endif
        return s:F.main.eerror(selfname, "nfnd", ["trnf"], a:srcstr)
    endwhile
    "}}}4
    return 1
endfunction
"{{{3 mod.main
" Добавить/удалить транслитерируемую последовательность или настройку
function s:F.mod.main(action, transsymb, ...)
    let retstatus=call(s:F.mod[a:action], a:000+[a:transsymb.origin], s:F)
    if !retstatus
        return 0
    endif
    return s:F.comm.save(a:transsymb)
endfunction
"{{{2 prnt: main(print): печать таблицы транслитерации
"{{{3 prnt.formattrplain: получить список всех последовательностей
" В качестве аргументов принимает таблицу транслитерации во внутреннем формате, 
" начало последовательности (нужно для рекурсии) и флаги (нужно для рекурсии). 
" Вызывайте со вторым и третьим аргументами, равными пустым строкам.
function s:F.prnt.formattrplain(transsymb, beginning, flags)
    let result={}
    for key in keys(a:transsymb)
        "{{{4 Ключ «none»
        if key=="none"
            let trstr=a:transsymb.none
            let flags=a:flags
            "{{{5 Верхний регистр
            " Если нет никаких различий между регистрами, то не имеет смысла 
            " писать флаги, влияющие на результат транслитерации верхнего 
            " регистра
            if toupper(a:beginning)==#tolower(a:beginning)
                let flags=substitute(flags, '[cf]', '', 'g')
            endif
            "{{{5 Combining diacritics
            if s:F.stuf.iscombining(
                        \s:F.stuf.nextchar_nr(a:transsymb.none))
                let trstr="a".trstr
                let flags.="d"
            endif
            "}}}5
            let result[a:beginning]=[trstr, flags]
        "{{{4 Односимвольный ключ
        elseif key=~'^.$'
            let [lwtrans, uptrans]=(a:transsymb[key])
            "{{{5 Таблица транслитерации для нижнего или обоих регистров
            if type(lwtrans)==type({})
                let beginning=(a:beginning).key
                let flags=a:flags
                if type(uptrans)==type(0)
                    if uptrans==0
                        let flags="c"
                    elseif uptrans==2
                        let flags="f"
                    endif
                endif
                call extend(result, (s:F.prnt.formattrplain(lwtrans,
                            \                           beginning, flags)))
            endif
            "{{{5 Таблица транслитерации для верхнего регистра
            if type(uptrans)==type({})
                call extend(result, (s:F.prnt.formattrplain(uptrans,
                            \((a:beginning).(toupper(key))), a:flags)))
            endif
            "}}}5
            unlet lwtrans
            unlet uptrans
        endif
        "}}}4
    endfor
    return result
endfunction
"{{{3 prnt.main: напечатать таблицу транслитерации
function s:F.prnt.main(columns, transsymb)
    let selfname="prnt.main"
    "{{{4 Первая часть — получение списка списков
    let cache=s:g.cache.trans[2][a:transsymb.id]
    if len(cache[0])
        let [printlist, srclen, trlen, flaglen]=cache[0]
    else
        let plaintrans=s:F.prnt.formattrplain(a:transsymb, "", "")
        let  srclen=max(map(  keys(plaintrans),
                    \'s:F.stuf.strlen(strtrans(v:val))'))
        let   trlen=max(map(values(plaintrans),
                    \'s:F.stuf.strlen(strtrans(v:val[0]))-(v:val[1]=~"d")'))
        let flaglen=max(map(values(plaintrans),
                    \'len(v:val[1])'))
        let printlist=values(map(copy(plaintrans), '[v:key]+v:val'))
        let cache[0]=[printlist, srclen, trlen, flaglen]
    endif
    if a:columns==-1
        return deepcopy(printlist)
    endif
    "{{{4 Количество колонок
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
    "{{{4 Вторая часть — получение списка строк
    if len(cache[1])
        let printstr=cache[1]
    else
        let printstr=map(copy(printlist),
                    \"s:F.plug.stuf.printl( srclen, strtrans(v:val[0])).' '.".
                    \"s:F.plug.stuf.printl(  trlen, strtrans(v:val[1])).' '.".
                    \"s:F.plug.stuf.printl(flaglen, v:val[2])")
        call sort(printstr)
        let cache[1]=printstr
    endif
    if columns==0
        return copy(printstr)
    endif
    "{{{4 Третья часть — получение вывода в колонках
    if has_key(cache[2], s:F.plug.stuf.string(columns))
        let result=cache[2][columns]
    else
        let result=[]
        let curcol=0
        let curline=0
        let lastlinelen = len(printstr)%columns
        let lines=len(printstr)/columns
        while len(printstr)
            if curcol==0
                call add(result, "")
            endif
            let result[curline].=printstr[0]
            let printstr=printstr[1:]
            if curcol != columns-1
                let result[curline].=" | "
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
    "}}}4
endfunction
"{{{2 out:  внешние функции
"{{{3 s:g.out
let s:g.out={
            \"add": 'call(s:F.mod.main, ["add", a:000[-1]]+a:000[0:2], {})',
            \"del": 'call(s:F.mod.main, ["del", a:000[-1]]+a:000[0:1], {})',
            \"setoption": 'call(s:F.mod.main, ["setoption", '.
            \                                 'a:000[-1], a:000[2], a:000[0], '.
            \                                 'a:000[1], a:000[3]], {})',
            \"deloption": 'call(s:F.mod.main, ["setoption", '.
            \                                 'a:000[-1], a:000[1], a:000[0], '.
            \                                 '"", 2], {})',
            \"print": 'call(s:F.prnt.main, a:000, {})',
            \"transliterate": 'call(s:F.trs.main, a:000, {})',
        \}
for [s:key, s:val] in items(s:g.out)
    execute      "function s:F.out.".s:key."(...)\n".
                \"    return ".s:val."\n".
                \"endfunction"
endfor
unlet s:key
unlet s:val
"{{{3 out._trlines: транслитерировать строчки(у) целиком
function s:F.out._trlines(startline, endline, transsymb)
    let savedureg=@"
    let [startline, endline]=sort([a:startline, a:endline])
    let s:g.tmp=a:transsymb
    execute "normal! ".startline."gg\"t".(endline-startline+1)."S".
                \"\<C-r>=s:F.trs.main(@t,s:g.tmp)\<CR>"
    let s:g.tmp={}
    " Удалить лишную новую строку
    delete _
    let @"=savedureg
    return @t
endfunction
"{{{2 mng:  управление плагином
"{{{3 mng.tof: управление транслитерацией по мере ввода
function s:F.mng.tof(bang, action, ...)
    "{{{4 Объявление переменных
    let selfname="mng.tof"
    "{{{4 Запуск
    if a:action==#"start"
        let transsymb=a:000[0]
        if a:bang
            if exists("s:g.tof.mutable.transsymb")
                return s:F.main.eerror(selfname, "action", ["tofgs"])
            endif
            let mbuf=bufnr('$')
            let i=1
            while i<=mbuf
                if bufexists(i) && !has_key(s:g.tof.mutable.bufdicts, i)
                    call s:F.tof.setup(i, transsymb)
                endif
                let i+=1
            endwhile
            let s:g.tof.mutable.transsymb=transsymb
            augroup Tr3ToFbangstart
                autocmd!
                autocmd BufAdd * call s:F.tof.setup(expand("<abuf>")+0,
                            \s:g.tof.mutable.transsymb)
            augroup END
            return 1
        endif
        if has_key(s:g.tof.mutable.bufdicts, bufnr('%'))
            return s:F.main.eerror(selfname, "action", ["tofs"])
        endif
        return s:F.tof.setup(bufnr('%'), transsymb)
    "{{{4 Перезагрузка и остановка
    else
        "{{{5 Остановка
        if a:action==#"stop"
            if a:bang
                augroup Tr3ToFbangstart
                    autocmd!
                augroup END
                if exists("s:g.tof.mutable.transsymb")
                    unlet s:g.tof.mutable.transsymb
                endif
                return !s:F.stuf.checklod(values(s:g.tof.mutable.bufdicts),
                            \'s:F.tof.stop(copy(v:val))')
            elseif has_key(s:g.tof.mutable.bufdicts, bufnr('%'))
                return s:F.tof.stop(s:g.tof.mutable.bufdicts[bufnr('%')])
            endif
        "{{{5 Перезагрузка
        elseif a:action==#"restart"
            let buf=bufnr('%')
            if has_key(s:g.tof.mutable.bufdicts, buf)
                let transsymb=s:g.tof.mutable.bufdicts[(buf)].transsymb
                call s:F.tof.stop(s:g.tof.mutable.bufdicts[buf])
            else
                let transsymb=s:F.comm.gettranssymb()
            endif
            return s:F.tof.setup(bufnr('%'), transsymb)
        endif
    endif
    "}}}4
    return 0
endfunction
"{{{3 mng.cache: управление кэшем
function s:F.mng.cache(action, ...)
    let selfname="mng.cache"
    "{{{4 Очистка кэша
    if a:action==#"purge"
        let target=a:000[0]
        if target==?"innertrans" || target==?"trans"
            let s:g.cache.trans=deepcopy(s:g.cache.init.trans)
        elseif target==?"printtrans"
            call map(s:g.cache.trans[2],
                        \'deepcopy(s:g.cache.init.print)')
        elseif target==?"toftrans"
            call map(s:g.cache.trans[3], '[]')
        elseif target==?"all"
            let s:g.cache.transf={}
            let s:g.cache.trans=deepcopy(s:g.cache.init.trans)
        endif
    "{{{4 Печать кэша
    elseif a:action==#"show"
        "{{{5 Объявление переменных
        let header=(s:g.p.cache.th.trans)
        let i=0
        let clen=len(s:g.cache.trans[1])
        let lines=[]
        "{{{5 Получение строк
        while i<clen
            call add(lines, [])
            "{{{6 Первый столбец — источник таблицы
            let source=(s:g.cache.trans[1][i].source)
            if source[0]==#"var"
                call add(lines[-1], s:g.p.cache.trsrc.var." ".source[1])
            elseif source[0]==#"func"
                call add(lines[-1], s:g.p.cache.trsrc.func." ".
                            \       substitute(string(source[1]),
                            \                 '^.\{-}''\(.*\)''.*$', '\1', ''))
            elseif source[0]==#"file"
                call add(lines[-1], s:g.p.cache.trsrc.file." ".
                            \       fnamemodify(source[1], ':~:.'))
            elseif source[0]==#"dict"
                call add(lines[-1], s:g.p.cache.trsrc.dict)
            endif
            "{{{6 Второй столбец — заполненность кэша для печати
            let printcache=s:g.cache.trans[2][i]
            if printcache[2]!={}
                call add(lines[-1], (s:g.p.cache.other.col)." ".
                            \join(keys(printcache[2]), ", "))
            elseif len(printcache[1])
                call add(lines[-1], s:g.p.cache.other.strl)
            elseif len(printcache[0])
                call add(lines[-1], s:g.p.cache.other.ll)
            else
                call add(lines[-1], s:g.p.cache.other.no)
            endif
            "{{{6 Третий столбец — наличие кэша для ToF
            if len(s:g.cache.trans[3][i])
                call add(lines[-1], s:g.p.cache.other.yes)
            else
                call add(lines[-1], s:g.p.cache.other.no)
            endif
            "}}}7
            let i+=1
        endwhile
        "}}}5
        return s:F.plug.stuf.printtable(header, lines)
    endif
    "}}}4
    return 1
endfunction
"{{{3 mng.main
"{{{4 s:g.mng.main
let s:g.mng={}
let s:g.mng.main={
            \"add": 's:F.mod.main("add", args[-1].to, args[1], args[2], bang)',
            \"del": 's:F.mod.main("del", args[-1].from, args[0], bang)',
            \"setoption": 's:F.mod.main("setoption", args[-1].in, '.
            \                           'args[-1].for, args[1], args[2], bang)',
            \"deloption": 's:F.mod.main("setoption", args[-1].in, '.
            \                           'args[-1].for, args[1], 0, 2)',
            \"save": 's:F.comm.save(transsymb)',
            \"tof": 'call(s:F.mng.tof, [bang]+args[1:], {})',
            \"cache": 'call(s:F.mng.cache, args[1:], {})',
        \}
let s:g.mng.main.delete=s:g.mng.main.del
"}}}4
function s:F.mng.main(bang, startline, endline, ...)
    "{{{4 Объявление переменных
    let bang=(a:bang=='!')
    "{{{4 Проверка ввода
    let args=s:F.plug.chk.checkarguments(s:g.c.cmd, a:000)
    let action=args[0]
    if type(args)!=type([])
        return 0
    endif
    "{{{4 Действия
    "{{{5 Транслитерировать
    if action==#"transliterate"
        "{{{6 Транслитерировать строчки(у) целиком
        if a:000[0]==?"lines"
            return s:F.out._trlines(a:startline, a:endline, args[-1].using)
            "{{{6 Транслитерировать выделение
        elseif a:000[0]==?"selection"
            "{{{7 Построчное выделение
            if visualmode()==#"V"
                return s:F.out._trlines(line("'<"), line("'>"),
                            \args[-1].using)
            "{{{7 Выделенный диапозон
            elseif visualmode()==#"v"
                let savedureg=@"
                let s:g.tmp=args[-1].using
                execute "normal! gv\"tc\<C-r>=".
                            \"s:F.trs.main(@t,s:g.tmp)\<CR>"
                unlet s:g.tmp
                let @"=savedureg
            "{{{7 Выделенный блок
            elseif visualmode()==#"\<C-v>"
                let savedureg=@"
                normal! gv"ty
                let savedtreg=@t
                let [startline, endline]=sort([line("'<"), line("'>")])
                let   curline=startline
                let [startcol, endcol]=sort([virtcol("'<"), virtcol("'>")])
                let  enddiff=endcol-(&selection=="exclusive")-
                            \startcol+1
                let s:g.tmp=args[-1].using
                while curline<=endline
                    execute "normal! ".curline."gg".
                                \startcol."|\"t".enddiff."s\<C-r>=".
                                \   "s:F.trs.main(@t,s:g.tmp)\<CR>"
                    let curline+=1
                endwhile
                unlet s:g.tmp
                let @t=savedtreg
                let @"=savedureg
            endif
        endif
    "{{{5 Напечатать таблицу транслитерации
    elseif action==#"print"
        echo s:F.prnt.main(args[-1].columns, args[-1].transsymb)
        return 1
    "{{{5 Действия, описанные в s:g.mng.main
    elseif has_key(s:g.mng.main, action)
        return eval(s:g.mng.main[action])
    endif
    "}}}4
endfunction
"{{{2 Глобальная переменная
"{{{3 s:g.comp
" lst — списки возможных вариантов
" reg — соответствующие значения
let s:g.comp={
            \"lst": {
            \    "cachesubj": ["innertrans", "trans", "printtrans"],
            \       "trsubj": ["selection", "lines"],
            \          "opt": ["capital"],
            \       "optval": {"capital": ["none", "first"]},
            \}
        \}
let s:g.tmp={}
"{{{3 s:g.opts: типы настроек
let s:g.opts={
            \"str": ["EscSeq", "BrkSeq", "CmdPrefix"],
            \"dictstrstr": ["StartTrSymbs", "StopTrSymbs", "NoTransWord"],
            \"bool": ["UsePython"],
        \}
"{{{3 s:g.cache: кэш
let s:g.cache={"init":{}}
" init — значения, которыми инициализируется пустой кэш.
let s:g.cache.init.trans=[[], [], [], []]
let s:g.cache.init.print=[[], [], {}]
" trans — кэш преобразований таблицы транслитерации. Состоит из трёх колонок:
" Первая — непреобразованная таблица, используется для определения индекса;
" Вторая — соответствующая таблица, преобразованная во внутреннее
"          представление;
" Третья — некоторые преобразования функции вывода на печать;
let s:g.cache.trans=deepcopy(s:g.cache.init.trans)
"{{{3 s:g.c: Проверки
"{{{4 Общие значения
let s:g.c.transsymb=[{"trans": ["func", s:F.comm.gettranssymb],
            \         "transchk": ["type", type({})]},
            \        {"trans": ["call", []],
            \         "transchk": ["type", type({})]},
            \         s:F.comm.gettranssymb]
let s:g.c.tronly={"model": "optional",
            \     "optional": [s:g.c.transsymb]}
let s:g.c.nothing={"model": "optional"}
"{{{4 Аргументы функций
" То же, что и выше, но используется для функций
            \          s:F.comm.gettranssymb]
let s:g.c.func={
            \"add": {   "model": "optional",
            \        "required": [["regex", '.'],
            \                     ["type", type("")]],
            \        "optional": [[["bool", ""], {}, 0],
            \                     s:g.c.transsymb]},
            \"del": {   "model": "optional",
            \        "required": [["regex", '.']],
            \        "optional": [[["bool", ""], {}, 0],
            \                     s:g.c.transsymb]},
            \"setoption": {"model": "optional",
            \           "required": [["in", s:g.comp.lst.opt],
            \                        ["in", ["first", "none"]],
            \                        ["regex", '.']],
            \           "optional": [[["bool", ""], {}, 0],
            \                        s:g.c.transsymb]},
            \"deloption": {"model": "optional",
            \           "required": [["in", s:g.comp.lst.opt],
            \                        ["regex", '.']],
            \           "optional": [s:g.c.transsymb]},
            \"transliterate": {"model": "optional",
            \               "required": [["type", type("")]],
            \               "optional": [s:g.c.transsymb]},
            \"print": {"model": "optional",
            \       "optional": [[["num", [-2]], {}, -1],
            \                    s:g.c.transsymb]},
        \}
unlockvar s:g.ExtFunc
call map(s:g.ExtFunc, '[v:val[0], "out.".v:val[0], s:g.c.func[v:val[0]]]')
"{{{4 Аргументы команд
let s:g.c.cmd={"model": "actions",
            \  "actions": {}}

let s:g.c.cmd.actions.transliterate={"model": "prefixed",
            \"required": [["in", s:g.comp.lst.trsubj]],
            \"prefoptional": {"using": s:g.c.transsymb}}

let s:g.c.cmd.actions.setoption={"model": "prefixed",
            \"required": [["in", s:g.comp.lst.opt],
            \             ["in", ["first", "none"]]],
            \"prefrequired": {"for": {}},
            \"prefoptional": {"in": s:g.c.transsymb}}

let s:g.c.cmd.actions.deloption={"model": "prefixed",
            \"required": [["in", s:g.comp.lst.opt]],
            \"prefrequired": {"for": {}},
            \"prefoptional": {"in": s:g.c.transsymb}}

let s:g.c.cmd.actions.add={"model": "prefixed",
            \"required": [["any", ""],
            \             ["any", ""]],
            \"prefoptional": {"to": s:g.c.transsymb}}

let s:g.c.cmd.actions.del={"model": "prefixed",
            \"required": [["any", ""]],
            \"prefoptional": {"from": s:g.c.transsymb}}
let s:g.c.cmd.actions.delete=s:g.c.cmd.actions.del

let s:g.c.cmd.actions.save=s:g.c.tronly

let s:g.c.cmd.actions.print={"model": "prefixed",
            \"prefoptional": {"transsymb": s:g.c.transsymb,
            \                   "columns": [["nums", [-2]], {}, -2]}}

let s:g.c.cmd.actions.tof={"model": "actions",
            \              "actions": {}}

let s:g.c.cmd.actions.tof.actions.restart=s:g.c.nothing
let s:g.c.cmd.actions.tof.actions.start=s:g.c.tronly
let s:g.c.cmd.actions.tof.actions.stop=s:g.c.nothing

let s:g.c.cmd.actions.cache={"model": "actions",
            \                "actions": {"purge": {"model": "simple",
            \                                     "required": [["in",
            \                                       s:g.comp.lst.cachesubj]]},
            \                            "show": s:g.c.nothing}}
"{{{4 Настройки
let s:g.c.str=["type", type("")]
let s:g.c.reg=["isreg", '']
let s:g.c.ssd=["dict", [[s:g.c.str, s:g.c.str]]]
let s:g.c.plugs=["alllst", ["or", [["in", keys(s:F.trs.plug)],
            \                      ["chklst", [["isfunc", 0],
            \                                  s:g.c.reg]]]]]
let s:g.c.tof=["or", [["alllst", s:g.c.str],
            \         s:g.c.reg]]
let s:g.c.tofplugs=["alllst", ["or", [["in", keys(s:F.tof.plug)],
            \                         ["chklst", [["isfunc", 0],
            \                                     s:g.c.tof]]]]]
call extend(s:g.c.options, {
            \      "BrkSeq": s:g.c.str,
            \      "EscSeq": s:g.c.str,
            \ "StopTrSymbs": s:g.c.ssd,
            \"StartTrSymbs": s:g.c.ssd,
            \ "NoTransWord": s:g.c.ssd,
            \       "Plugs": ["dict", [[["in", ["Before", "After"]],
            \                           s:g.c.plugs]]],
            \    "ToFPlugs": s:g.c.tofplugs,
            \"DefaultTranssymb": ["any", ""],
            \"ConfigDir": ["file", 'd'],
            \"WriteFunc": ["or", [["equal", 0],
            \                     ["keyof", s:g.tof.rewritefunc],
            \                     ["and", [["type", type("")],
            \                              ["isfunc", 1]]]]],
        \})
"{{{3 Автодополнение строки ввода
let s:g.comp.inputwords={}
let s:g.comp.ia={
            \"model": "inputwords",
            \"words": ["keyof", s:g.comp.inputwords],
        \}
"{{{3 Автодополнение действий
let s:g.comp.lst.transsymb=[]
function s:F.comp.trfiles(...)
    return map(split(expand(fnamemodify(s:F.main.option("ConfigDir"), ':p').
                \           '/*.json'),
                \    "\n"),
                \'substitute(v:val, ''^.*/\([^/]*\)\.json$'', ''\1'', "")')
endfunction
let s:g.comp.transsymb=["first", [["list", s:g.comp.lst.transsymb],
            \                     ["func", s:F.comp.trfiles],
            \                     ["file", ".json"]]]
let s:g.comp.trsrc=["list", []]
let s:g.comp.trres=["list", []]

let s:g.comp.a={"model": "actions"}
let s:g.comp.a.actions=map(copy(s:g.c.cmd.actions),
            \'{"model": "pref"}')

let s:g.comp.a.actions.transliterate.arguments=[["list", s:g.comp.lst.trsubj]]
let s:g.comp.a.actions.transliterate.prefix={"using": s:g.comp.transsymb}

let s:g.comp.a.actions.setoption.arguments=[["list", s:g.comp.lst.opt],
            \                               ["list", ["first", "none"]]]
let s:g.comp.a.actions.setoption.prefix={"in": s:g.comp.transsymb,
            \                            "for": s:g.comp.trsrc}

let s:g.comp.a.actions.deloption.arguments=[["list", s:g.comp.lst.opt]]
let s:g.comp.a.actions.deloption.prefix={"in": s:g.comp.transsymb,
            \                            "for": s:g.comp.trsrc}

let s:g.comp.a.actions.add.arguments=[s:g.comp.trsrc,
            \                         s:g.comp.trres]
let s:g.comp.a.actions.add.prefix={"to": s:g.comp.transsymb}

let s:g.comp.a.actions.del.arguments=[s:g.comp.trsrc]
let s:g.comp.a.actions.del.prefix={"from": s:g.comp.transsymb}
let s:g.comp.a.actions.delete=s:g.comp.a.actions.del

let s:g.comp.a.actions.save.arguments=[s:g.comp.transsymb]

let s:g.comp.a.actions.print.prefix={"transsymb": s:g.comp.transsymb,
            \                          "columns": ["list", []]}

let s:g.comp.a.actions.tof.model="actions"
let s:g.comp.a.actions.tof.actions={}
let s:g.comp.a.actions.tof.actions.restart={"model": "simple"}
let s:g.comp.a.actions.tof.actions.stop={"model": "simple"}
let s:g.comp.a.actions.tof.actions.start={"model": "simple"}
let s:g.comp.a.actions.tof.actions.start.arguments=[s:g.comp.transsymb]

let s:g.comp.a.actions.cache.model="actions"
let s:g.comp.a.actions.cache.actions={}
let s:g.comp.a.actions.cache.actions.purge={"model": "simple"}
let s:g.comp.a.actions.cache.actions.purge.arguments=[["list",
            \                                          s:g.comp.lst.cachesubj]]
let s:g.comp.a.actions.cache.actions.show={"model": "simple"}
"{{{2 comp: автодополнение
let s:g.comp._cname="translit3"
let s:g.comp._inputcname="translit3input"
redir => g:_messages
try
let s:F.comp._complete=s:F.plug.comp.ccomp(s:g.comp._cname, s:g.comp.a)
let s:F.comp._completeinput=s:F.plug.comp.ccomp(s:g.comp._inputcname,
            \                                   s:g.comp.ia)
finally
redir END
endtry
"{{{2 map: Функции для привязок
"{{{3 s:g.map
let s:g.map={}
let s:g.map.twregs=[
            \['\(\k*\)',           '\(\k\+\|\%$\)'          ],
            \['\(\%(\k\@!\S\)*\)', '\(\%(\k\@!\S\)\+\|\%$\)'],
            \['\(\s*\)',           '\(\s*\)'                ],
        \]
let s:g.map.tWregs=[
            \['\(\S*\)', '\(\S\+\|\%$\)'],
            \['\(\s*\)', '\(\s*\)'      ],
        \]
let s:g.map.actions={
            \"Transliterate":     's:F.map.doinput(transsymb)',
            \"TransliterateWord": 's:F.map.lrset(transsymb, s:g.map.twregs)',
            \"TransliterateWORD": 's:F.map.lrset(transsymb, s:g.map.tWregs)',
            \"TranslitReplace":   's:F.map.doonchar("r", transsymb)',
            \"TranslitToNext":    's:F.map.doonchar("t", transsymb)',
            \"TranslitToPrev":    's:F.map.doonchar("T", transsymb)',
            \"TranslitNext":      's:F.map.doonchar("f", transsymb)',
            \"TranslitPrev":      's:F.map.doonchar("F", transsymb)',
        \}
let s:g.map.actions.CmdTransliterate=s:g.map.actions.Transliterate
"{{{3 map.input
let [s:F.map.input, s:g.map.delinput]=
            \s:F.plug.stuf.cinput("translit", "Translit: ",
            \                     s:F.comp._completeinput)
"{{{3 map.doinput
function s:F.map.doinput(transsymb)
    try
        let r=s:F.map.input()
    catch /^Interrupted$/
        return ""
    catch
        throw "Failed to input characters: ".v:exception
    " finally
        " redraw!
    endtry
    let l=split(r, '\(\\\@<!\(\\.\)*\\\)\@<! ')
    for s in l
        let s:g.comp.inputwords[s]=1
    endfor
    return s:F.trs.main(r, a:transsymb)
endfunction
"{{{3 map.lrset
function s:F.map.lrset(transsymb, patlist)
    let line=getline('.')
    let column=col('.')
    let match=[]
    let i=0
    let lpatlist=len(a:patlist)
    while i<lpatlist && (match==[] || match[0]=='')
        let pattern=a:patlist[i][0].'\%'.column.'c'.a:patlist[i][1]
        let match=matchlist(line, pattern)
        let i+=1
    endwhile
    let lmatch=match[1]
    let rmatch=match[2]
    let r=s:F.trs.main((lmatch.rmatch), a:transsymb)
    let matchstart=column-len(lmatch)-2
    let lline=""
    if matchstart>=0
        let lline=line[:(matchstart)]
    endif
    let matchend=column+len(rmatch)-1
    let rline=""
    if matchend>=0
        let rline=line[(matchend):]
    endif
    let curline=line('.')
    let vcolstart=virtcol([curline, column-len(lmatch)])
    let vcolend=virtcol([curline, column+len(rmatch)])
    return "\<C-o>".vcolstart."|\<C-\>\<C-o>\"_d".vcolend."|".
                \((vcolend==virtcol('$'))?("\<C-\>\<C-o>\"_x"):("")).r
endfunction
"{{{3 map.getchar
function s:F.map.getchar(transsymb)
    let char=getchar()
    if type(char)==type(0)
        let char=nr2char(char)
    endif
    if &timeout
        let timeout=&timeoutlen/1000.0
    else
        let timeout=-1
    endif
    let bufdict=s:F.tof.setup(0, a:transsymb)
    let oldbclen=1
    let result=s:F.tof.transchar(bufdict, char)
    let bufdict.curtrseq=""
    let time=reltime()
    let addchar=""
    while ((timeout>0)?(eval(reltimestr(reltime(time)))<timeout):(1)) &&
                \len(bufdict.curtrans)>oldbclen
        if getchar(1)
            if oldbclen==1
                let oldbclen=2
            endif
            let char=getchar()
            if type(char)==type(0)
                let char=nr2char(char)
            endif
            let newresult=s:F.tof.transchar(bufdict, char)
            if len(bufdict.curtrans)<=oldbclen
                let addchar=char
                break
            endif
            let bufdict.curtrseq=""
            let result=newresult
            let oldbclen+=1
            let time=reltime()
        else
            sleep 50m
        endif
    endwhile
    return [result, addchar]
endfunction
"{{{3 map.doonchar
function s:F.map.doonchar(command, transsymb)
    let result=s:F.map.getchar(a:transsymb)
    if a:command==#'r'
        return 's'.result[0]."\e".result[1]
    else
        if result[0]=~#'^.$'
            return a:command.result[0].result[1]
        else
            let line=getline('.')
            let l:count=v:count1
            let col=col('.')-1
            let vcol=virtcol('.')
            if a:command==#'f' || a:command==#'t'
                while l:count && col!=-1
                    let col=stridx(line, result[0], col+1)
                    let l:count-=1
                endwhile
                if col!=-1
                    if a:command==#'f'
                        let col+=len(result[0])
                    endif
                    let vcol=virtcol([line('.'), col+1])
                    let vcol-=1
                endif
            elseif a:command==#'F' || a:command==#'T'
                let line=line[:col]
                if a:command==#'F'
                    let line=substitute(line, '.$', '', '')
                endif
                let lres=len(result[0])
                let mcol=len(line)-1-lres
                while mcol>0
                    let col=stridx(line, result[0], mcol)
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
                    if a:command==#'T'
                        let vcol=virtcol([line('.'), col+1+lres])
                    else
                        let vcol=virtcol([line('.'), col+1])
                    endif
                endif
            endif
            if col==-1
                return result[1]
            endif
            " First bar is used only to discard count:
            " 2,tta will turn into 2{vcol}|а, so if {vcol}=10, you will try to 
            " move to 210'th virtual column instead of 10'th. Here I will move 
            " twice, but this fact can be ignored
            return '|'.vcol.'|'.result[1]
        endif
    endif
    return a:command.join(result, "")
endfunction
"{{{3 map.runmap
function s:F.map.runmap(type, mapname, mapstring, buffer)
    let transsymb=s:F.comm.gettranssymb()
    if a:mapname==#"StartToF"
        call s:F.tof.setup(bufnr('%'), transsymb)
        return ""
    elseif a:mapname==#"StopToF"
        let curbuf=bufnr('%')
        if has_key(s:g.tof.mutable.bufdicts, curbuf)
            call s:F.tof.stop(s:g.tof.mutable.bufdicts[curbuf])
        endif
        return ""
    endif
    return eval(s:g.map.actions[a:mapname])
endfunction
"{{{2 Блокировка s:g
" Блокировать любую запись в глобальную переменную, затем разблокировать 
" конкретные ключи.
lockvar! s:g
unlockvar! s:g.cache.trans
unlockvar! s:g.tof.mutable
unlockvar! s:g.tmp
unlockvar! s:g.comp.lst.transsymb
unlockvar! s:g.comp.inputwords
"{{{1
lockvar! s:F
" vim: ft=vim:ts=8:fdm=marker:fenc=utf-8

