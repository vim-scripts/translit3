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
                \"load": {},
                \"main": {},
                \ "trs": {"plug":{}},
                \ "tof": {"plug":{}},
                \"stuf": {},
                \"json": {},
                \"comm": {},
                \ "mod": {},
                \"prnt": {},
                \ "out": {},
                \ "mng": {},
                \ "ext": {},
                \ "int": {},
                \"comp": {},
            \}
    "{{{3 Глобальная переменная
    let s:g={}
    let s:g.load={}
    let s:g.pluginloaded=0
    let s:g.srccmd="source ".expand("<sfile>")
    "{{{4 Настройки по умолчанию
    let s:g.defaultOptions={
                \"BrkSeq": '@',
                \"EscSeq": '\',
                \"StopTrSymbs":  {'%': '',},
                \"StartTrSymbs": {'%': '',},
                \"NoTransWord": {'%%': '',},
                \"CmdPrefix": "Tr3",
                \"FuncPrefix": "Tr3",
                \"Plugs": {
                \   "Before": ["brk"],
                \   "After":  ["esc", "notransword", "notrans"],
                \},
                \"ToFPlugs": ["notransword", "notrans", "brk"],
                \"DefaultTranssymb":
                \           $HOME."/.vim/config/translit3/transsymb.json",
                \"UsePython": 1,
            \}
    " Так как я люблю map(), то лучше на всякий случай заблокировать всё, что 
    " можно использовать в map()
    lockvar! s:g.defaultOptions
    "{{{4 Аргументы для command
    " Порядок аргументов будет (благодаря сортировке по алфавиту):
    "   "'<bang>'", "'<reg>'", "<LINE1>, <LINE2>", "<count>", "<f-args>"
    let s:g.load.cmdfargs={
                \   "nargs": "<f-args>",
                \   "range": "<LINE1>, <LINE2>",
                \   "count": "<count>",
                \    "bang": "'<bang>'",
                \     "reg": "'<reg>'",
                \  "buffer": "",
                \"complete": ""
            \}
    lockvar! s:g.load.cmdfargs
    "{{{3 Команды и функции
    " Определяет команды. Для значений ключей словаря см. :h :command. Если 
    " некоторому ключу «key» соответствует непустая строка «str», то в аргументы 
    " :command передаётся -key=str, иначе передаётся -key. Помимо ключей 
    " :command, в качестве ключа словаря также используется строка «func». Ключ 
    " «func» является обязательным и содержит функцию, которая будет вызвана при 
    " запуске команды (без префикса s:F.).
    let s:F.Cmd={
                \"Command": {
                \      "nargs": '+',
                \      "range": "",
                \       "bang": "",
                \       "func": "mng.main",
                \   "complete": "customlist,s:_complete",
                \},
            \}
    lockvar! s:F.Cmd
    lockvar 1 s:F
    " Список видимых извне функции
    let s:g.load.ExtFunc=["transliterate", "add", "del", "setoption",
                \"deloption", "print"]
    lockvar s:g.load.ExtFunc
    "{{{4 Приставки
    function s:F.load.getprefix(prefix)
        " В отличие от main.option() не выкидывает исклучение, если значение 
        " неправильное, а просто возвращается к варианту по умолчанию.
        if exists("g:tr3Options.".a:prefix."Prefix") &&
                    \type(g:tr3Options[a:prefix."Prefix"])==type("") &&
                    \g:tr3Options[a:prefix."Prefix"]=~#'^\u\w*$'
            return g:tr3Options[a:prefix."Prefix"]
        endif
        return s:g.defaultOptions[a:prefix."Prefix"]
    endfunction
    let s:g.load.prefix={ "cmd": s:F.load.getprefix("Cmd"),
                \        "func": s:F.load.getprefix("Func")}
    "{{{2 Команды
    let s:g.commands=[]
    function s:SID()
        return matchstr(expand('<sfile>'), '\d\+\ze_SID$')
    endfun
    let s:g.load.sid=s:SID()
    delfunction s:SID
    "{{{3 load.cmdadd
    " Добавить аргумент
    function s:F.load.cmdadd(key, value, cmdargs)
        let result='-'.a:key
        if a:key==#"complete" && a:value=~'^custom'
            let funcname=matchstr(a:value, ',\@<=s:.*')
            let intfuncname='s:F.comp.'.funcname[2:]
            if s:g.pluginloaded
                execute      "function ".funcname."(...)\n".
                            \"    return call(".intfuncname.", a:000, {})\n".
                            \"endfunction"
                let s:F.int[funcname]=function(funcname)
            else
                execute "autocmd Tr3BeforeLoadComp FuncUndefined ".
                            \"*P".s:g.load.sid."_".funcname[2:]." ".
                            \s:g.srccmd
            endif
        endif
        if a:value!=""
            let result.='='.a:value
        endif
        call add(a:cmdargs, result)
        return result
    endfunction
    "{{{3 load.mkcmd
    " Создать команду {cmd}
    function s:F.load.mkcmd(cmd)
        augroup Tr3BeforeLoadComp
            autocmd!
        augroup END
        let cmdargs=[]
        let fargs=[]
        let cmddescr=s:F.Cmd[a:cmd]
        for key in keys(cmddescr)
            if has_key(s:g.load.cmdfargs, key)
                call s:F.load.cmdadd(key, cmddescr[key], cmdargs)
                if s:g.load.cmdfargs[key]!=""
                    call add(fargs, s:g.load.cmdfargs[key])
                endif
            endif
        endfor
        let cmd=s:g.load.prefix.cmd . a:cmd
        if !s:g.pluginloaded
            call add(s:g.commands, cmd)
        endif
        execute "command! ".join(cmdargs, " ")." ".cmd." ".
                    \((s:g.pluginloaded)?(""):(s:g.srccmd." | ")).
                    \"call ".("s:F.".(cmddescr.func)).
                    \"(".join(sort(fargs), ", ").")"
    endfunction
    "{{{3 load.cmd
    " Создать команды
    function s:F.load.cmd()
        call map(keys(s:F.Cmd), 's:F.load.mkcmd(v:val)')
    endfunction
    "}}}3
    call s:F.load.cmd()
    "{{{2 Функции
    "{{{3 load.func
    " Создать функции или события FuncUndefined. Событие создаётся, если 
    " s:g.pluginloaded==0
    function s:F.load.funcs()
        augroup Tr3BeforeLoad
            autocmd!
        augroup END
        for functail in s:g.load.ExtFunc
            let funcname=(s:g.load.prefix.func).functail
            if s:g.pluginloaded
                execute      "function ".funcname."(...)\n".
                            \"    return call(s:F.out._runfunc, ".
                            \           "['".functail."']+a:000, s:F)\n"
                            \"endfunction"
                let s:F.ext[funcname]=function(funcname)
            else
                execute "autocmd Tr3BeforeLoad FuncUndefined ".funcname." ".
                            \s:g.srccmd
            endif
        endfor
    endfunction
    "}}}3
    call s:F.load.funcs()
    "}}}2
    finish
endif
"{{{1 Вторая загрузка
let s:g.pluginloaded=1
"{{{2 Команды и функции
call s:F.load.cmd()
call s:F.load.funcs()
"{{{2 Чистка
" Удаляем функции, которые были нужны только для загрузки
unlet s:F.load
" и переменные
unlet s:g.load
"{{{2 Выводимые сообщения
let s:g.p={
            \"emsg": {
            \     "str": "Value must be of a type “string”",
            \    "dict": "Value must be of a type “dictionary”",
            \    "list": "Value must be of a type “list”",
            \    "bool": "Value must be number, equal to either 0 or 1",
            \       "r": "File not readable",
            \       "w": "File not writable",
            \   "yfile": "Failed to load JSON file",
            \    "uopt": "Unknown option",
            \    "uval": "Unknown value",
            \    "uact": "Unknown action",
            \     "var": "Variable does not exist",
            \   "mnone": "Misplaced “none” key: ".
            \            "it mustn’t occur in the root of transsymb",
            \   "trans": "If transliteration table is a string, ".
            \            "it must be either a variable name, ".
            \            "starting with g: or b:, or a filename",
            \    "cols": "Column number must be equal to -2, -1 or 0, or".
            \            "be greater than zero",
            \   "onfnd": "Option not found",
            \     "opt": "Option already exists",
            \    "narg": "Wrong number of arguments",
            \   "margs": "Too many arguments",
            \   "largs": "Not enough arguments",
            \   "tsubj": "Unknown transliteration subject",
            \    "trex": "Transliteration sequence already exists",
            \    "trnf": "Transliteration sequence not found",
            \    "trnd": "Unable to delete transliteration sequence",
            \   "varrx": "Variable name must start with g: or b:, ".
            \            "and a latin letter, and contain ".
            \            "latin letters, decimal digits, ".
            \            "periods and underscores",
            \   "plstr": "Only two keys are possible in Plugs dictionary: ".
            \            "“Before” and “After”",
            \    "tofs": "ToF already started",
            \   "tofgs": "ToF already started for all buffers",
            \   "tofns": "ToF not started yet",
            \      "py": "Vim must be compiled with +python feature",
            \    "json": "Simplejson must be installed in your system",
            \   "rjson": "Failed to read JSON file",
            \    "jstr": "Invalid JSON string",
            \     "jse": "JSON string must end with “\"”",
            \     "jsu": "“\u” must be followed by four hex digits",
            \    "jsie": "Invalid escape: backslash must be followed by ".
            \            "“u” and four hex digits or ".
            \            "one of the following characters: ".
            \            "“\”, “/”, “b”, “f”, “n”, “r”, “t”",
            \    "jobj": "Invalid JSON object",
            \    "jkey": "Key in JSON object must be of a type “string”",
            \    "jdup": "Duplicate key",
            \     "jdt": "“:” not found",
            \   "jcoma": "Missing comma",
            \     "joe": "Object must end with “}”",
            \   "jlist": "Invalid JSON list",
            \     "jle": "List must end with “]”",
            \   "vlock": "Variable is locked",
            \},
            \"etype": {
            \     "value": "InvalidValue",
            \    "action": "InvalidAction",
            \    "uknkey": "UnknownKey",
            \      "file": "BadFile",
            \       "utf": "InvalidCharacter",
            \    "syntax": "SyntaxErr",
            \      "args": "WrongArguments",
            \      "perm": "ActionForbidden",
            \      "nfnd": "NotFound",
            \},
            \"cache": {
            \   "th": {
            \        "file": ["File", "Modification time"],
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
"{{{1 Вторая загрузка — основная часть
"{{{2 stuf
" Некоторые полезные вещи, не относящиеся непосредственно к плагину
"{{{3 s:Eval: доступ к внутренним переменным
" Внутренние переменные, в том числе s:F, недоступны в привязках
function s:Eval(var)
    return eval(a:var)
endfunction
let s:F.int["s:Eval"]=function("s:Eval")
"{{{3 stuf.readfile: прочитать файл
function s:F.stuf.readfile(fname)
    " Как ни странно, такой вариант работает быстрее, чем все придуманные мною 
    " альтернативы на чистом Vim
    let result=system("cat ".shellescape(a:fname))
    if v:shell_error
        let result=join(readfile(a:fname, 'b'), "\n")
    endif
    return result
    " Если в аргументах readfile не указывать 'b', то файл, не содержащий 
    " переводов строки, прочитается как будто он пустой.
    " return join(readfile(fname, 'b'), "\n")
    " Есть ещё варианты через открытие буфера, но они всё равно медленнее 
    " данного. Тем не менее, даже они могут быть быстрее join(readfile) (в 
    " зависимости от автокоманд).
endfunction
"{{{3 stuf.strlen: получение длины строки
function s:F.stuf.strlen(str)
    return len(split(a:str, '\zs'))
endfunction
"{{{3 stuf.printl: printf{'%-*s', ...}
" Напечатать {str}, шириной {len}, выровненное по левому краю, оставшееся 
" пространство заполнив пробелами (вместо printf('%-*s', len, str)).
function s:F.stuf.printl(len, str)
    return a:str . repeat(" ", a:len-s:F.stuf.strlen(a:str))
endfunction
"{{{3 stuf.mapprepare: экранировать для execute+map
function s:F.stuf.mapprepare(str)
    return escape(
                \substitute(
                \   substitute(a:str, '<', '<LT>', 'g'),
                \   ' ', '<SPACE>', 'g'),
                \'|')
endfunction
"{{{3 stuf.printtline: печать строки таблицы
" Напечатать одну линию таблицы
"   {line} — список строк таблицы,
" {lenlst} — список длин
function s:F.stuf.printtline(line, lenlst)
    let result=""
    let i=0
    while i<len(a:line)
        let result.=s:F.stuf.printl(a:lenlst[i], a:line[i])
        let i+=1
        if i<len(a:line)
            let result.="\t"
        endif
    endwhile
    return result
endfunction
"{{{3 stuf.printtable: напечатать таблицу
" Напечатать таблицу с заголовками рядов {headers} и линиями {lines}.
" {headers}: список строк
"   {lines}: список списков строк
function s:F.stuf.printtable(header, lines)
    let lineswh=a:lines+[a:header]
    let columns=max(map(copy(lineswh), 'len(v:val)'))
    let lenlst=[]
    let i=0
    while i<columns
        call add(lenlst, max(map(copy(lineswh), 's:F.stuf.strlen(v:val[i])')))
        let i+=1
    endwhile
    echohl PreProc
    echo s:F.stuf.printtline(a:header, lenlst)
    echohl None
    echo join(map(copy(a:lines), 's:F.stuf.printtline(v:val, lenlst)'), "\n")
    return 1
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
"{{{3 stuf.regescape: экранировать для регулярного выражения
" Вернуть строку, экранированную для использования в качестве регулярного 
" выражения Vim
function s:F.stuf.regescape(str)
    return escape(a:str, '^$.*~[]\')
endfunction
"{{{3 stuf.checkwr: проверить возможность записи в файл
function s:F.stuf.checkwr(fname)
    let fwr=filewritable(a:fname)
    return (fwr==1 || (fwr!=2 && !filereadable(a:fname) &&
                \filewritable(fnamemodify(a:fname, ":p:h"))==2))
endfunction
"{{{3 stuf.checklod: проверить весь словарь или список
function s:F.stuf.checklod(subj, chk)
    return ((type(a:subj)==type({}))?
                \(index(values(map(copy(a:subj), a:chk)), 0)!=-1):
                \(index(map(copy(a:subj), a:chk), 0)!=-1))
endfunction
"{{{3 stuf.writevar: записать в переменную
", возможно, являющуюся частью несуществующего словаря, или имеющую другой тип 
"по сравнению с тем, что мы собираемся туда записать
function s:F.stuf.writevar(varname, what)
    let selfname="stuf.writevar"
    if a:varname=~#'\.'
        if !exists(a:varname)
            let dct=matchstr(a:varname, '^.*\.\@=')
            if !exists(dct) || type(eval(dct))!=type({})
                let lastret=s:F.stuf.writevar(dct, {})
                if !lastret
                    return 0
                endif
            endif
        endif
    elseif exists(a:varname) && !islocked(a:varname)
        execute "unlet ".a:varname
    endif
    if exists(a:varname) && islocked(a:varname)
        return s:F.main.eerror(selfname, "perm", s:g.p.emsg.vlock, a:varname)
    endif
    execute "let ".a:varname."=a:what"
    return 1
endfunction
"{{{2 json: dump, load, cload
"{{{3 s:g.json
"  values — значения соответствующих объектов
" escapes — список символов, которые можно экранировать и соответствующих им
"           «реальных» символов
" lstinner, objinner — значения по умолчанию для внутренних функций
"           json.getlst и json.getobj соответственно. Нужны, так как в функцию 
"           json.end необходимо передавать ссылки на переменные (все функции 
"           принадлежат парсеру JSON) (перенесены в начало соответствующих 
"           функций).
let s:g.json={
            \"values": {
            \    "null": "",
            \    "true": 1,
            \   "false": 0,
            \},
            \"escapes": {
            \   '"': '"',
            \   '\': '\',
            \   '/': '/',
            \   'b': "\b",
            \   'f': "\f",
            \   'n': "\n",
            \   'r': "\r",
            \   't': "\t",
            \},
        \}
" reg — регулярные выражения:
"  val — для получения объектов из json.values,
"  num — для выделения числа из строки,
"  str — для выделения строкового объекта JSON,
"  var — регулярное выражение для определения имени переменной, в которую
"        разрешено писать.
let s:g.json.reg={
            \"val": join(keys(s:g.json.values), '\|'),
            \"num": '^-\=\([1-9]\d*\|0\)\(\.\d\+\)\=\([eE][+\-]\=\d\+\)\=',
            \"str": '^"\([^\\"]\|\\\(u\x\{4}\|'.
            \       '['.escape(join(keys(s:g.json.escapes), ''), '\[]-').']'.
            \       '\)\)*"',
            \"var": '[gb]:[a-zA-Z_]\(\w\@<=\.\w\|\w\)*',
        \}
"{{{3 JSON dumper/vimscript
"{{{4 json.strstr: String->JSON
"{{{5 s:g.json.escrev
"  escrev — «обращённая» escapes, содержит соответствие реальных символов их
"           текстовым представлениям (под «реальным» здесь понимается то, что 
"           содержалось в памяти до перевода в JSON).
let s:g.json.escrev={}
call map(copy(s:g.json.escapes),
            \'extend(s:g.json.escrev, {v:val : "\\".v:key})')
"}}}5
function s:F.json.strstr(str)
    let selfname="json.strstr"
    "{{{5 Пустая строка
    if !len(a:str)
        return "null"
    endif
    "{{{5 Объявление переменных
    let result='"'
    let idx=0
    let slen=len(a:str)
    "{{{5 Представление
    while idx<slen
        " Так мы получим следующий символ без диакритики (а на следующей 
        " итерации получим диакритику без символа).
        let chnr=char2nr(a:str[(idx):])
        let char=nr2char(chnr)
        let clen=len(char)
        let chkchar=a:str[(idx):(idx+clen-1)]
        if chkchar!=#char
            call s:F.main.eerror(selfname, "utf", strtrans(chkchar))
            throw "InvalidCharacter"
        endif
        let idx+=clen
        if clen>1
            " На случай, если char2nr вернёт число, большее, чем 0xFFFF.
            if chnr<0x10000
                let result.=printf('\u%0.4x', chnr)
            " Следующий код производит корректный JSON, однако преобразование 
            " его обратно в Vim происходит некорректно (код производит 
            " суррогатную пару utf-16, обозначаующую один символ, но результатом 
            " обратного преобразования является пара символов, не 
            " соответствующая стандарту UTF-8).
            elseif chnr<=0x10FFFF
                let U=chnr-0x10000
                let Uh=U/1024
                let W1=0xD800+Uh
                let W2=0xDC00+(U-(Uh*1024))
                let result.=printf('\u%0.4x\u%0.4x', W1, W2)
            else
                let result.=char
            endif
        elseif has_key(s:g.json.escrev, char)
            " Экранирование
            let result.=s:g.json.escrev[char]
        else
            let result.=char
        endif
    endwhile
    "}}}5
    return result.'"'
endfunction
"{{{4 json.strlst: List->JSON
function s:F.json.strlst(lst)
    return '['.join(map(copy(a:lst), 's:F.json.str(v:val)'), ',').']'
endfunction
"{{{4 json.strdct: Dictionary->JSON
function s:F.json.strdct(dct)
    return '{'.join(values(map(copy(a:dct),
                \'s:F.json.strstr(v:key).":".s:F.json.str(v:val)')),
                \',').'}'
endfunction
"{{{4 json.strfunc: Funcref->JSON(null)
" Представить функцию в виде JSON
function s:F.json.strfunc(func)
    return "null"
endfunction
"{{{4 json.str: *->JSON
function s:F.json.str(obj)
    return call(s:g.json.conv.tojstrfunc[type(a:obj)], [a:obj], {})
endfunction
"{{{4 json.dumps
function s:F.json.dumps(obj)
    return s:F.json.str(a:obj)
endfunction
"{{{4 s:g.json.conv.tojstrfunc
" Функции, представляющие произвольный объект. Отсортированы в соответствии 
" с типом объекта
let s:g.json.conv={}
let s:g.json.conv.tojstrfunc=[function("string"), s:F.json.strstr,
            \s:F.json.strfunc, s:F.json.strlst, s:F.json.strdct,
            \function("string")]
"{{{3 Парсер JSON на vimscript
"{{{4 json.getnum: JSON->(Number|Float)
function s:F.json.getnum(str)
    let numstr=matchstr(a:str, s:g.json.reg.num)
    if numstr=~?'e'
        " 0e0 → 0.0e0 (Vim не поддерживает запись чисел с плавающей запятой
        "              без десятичной точки)
        let numstr=substitute(numstr, '^-\=\d\+[eE]\@=', '\0.0', '')
    endif
    return      { "delta": len(numstr),
                \"result": eval(numstr),}
endfunction
"{{{4 json.getstr: JSON->String
function s:F.json.getstr(str)
    let selfname='json.getstr'
    let str=matchstr(a:str, s:g.json.reg.str)
    let delta=len(str)
    if !delta
        return s:F.main.eerror(selfname, 'syntax',
                    \s:g.p.emsg.jstr)
    endif
    " Здесь необходимо добавить поддержку суррогатных пар.
    return      { "delta": delta,
                \"result": eval(str),}
endfunction
"{{{4 json.getobj: JSON->Dictionary
"{{{5 s:g.json.objinner
let s:g.json.objinner={
            \ "result": {},
            \  "delta": 1,
            \  "endch": '}',
            \"errargs": ["json.getobj", "syntax", s:g.p.emsg.jobj,
            \            s:g.p.emsg.joe],
            \}
"}}}5
function s:F.json.getobj(str)
    "{{{5 Объявление переменных
    let selfname="json.getobj"
    let tlen=len(a:str)
    let inner=deepcopy(s:g.json.objinner)
    let inner.str=a:str
    "{{{5 Основной цикл
    while inner.delta<tlen
        "{{{6 Ключ
        " Ключ — строка, поэтому начинается с «"»
        let keystart=match(a:str, '^\_\s*\zs"', inner.delta)
        if keystart==-1
            return s:F.json.end(inner)
        endif
        let inner.delta=keystart
        " Получить строку
        let lastret=s:F.json.getstr(a:str[(inner.delta):])
        if type(lastret)==type(0)
            return s:F.main.eerror(selfname, 'syntax',
                        \s:g.p.emsg.jobj,
                        \s:g.p.emsg.jkey)
        endif
        let inner.delta+=lastret.delta
        let key=lastret.result
        unlet lastret

        if has_key(inner.result, key)
            return s:F.main.eerror(selfname, 'syntax',
                        \s:g.p.emsg.jobj,
                        \s:g.p.emsg.jdup, key)
        endif
        "{{{6 Двоеточие
        let resstart=match(a:str, '^\_\s*\zs:', inner.delta)
        if resstart==-1
            return s:F.main.eerror(selfname, 'syntax',
                        \s:g.p.emsg.jobj,
                        \s:g.p.emsg.jdt)
        endif
        let inner.delta=resstart+1
        "{{{6 Получить значение
        let lastret=s:F.json.get(a:str[(inner.delta):])
        if type(lastret)==type(0)
            return lastret
        endif
        let inner.delta+=lastret.delta
        let inner.result[key]=lastret.result
        unlet lastret
        "{{{6 Запятая или конец объекта после значения
        let comma=match(a:str, '^\_\s*\zs,', inner.delta)
        if (comma)==-1
            return s:F.json.end(inner)
        endif
        let inner.delta=(comma+1)
        "}}}6
    endwhile
    "}}}5
    return s:F.main.eerror(selfname, 'syntax',
                \s:g.p.emsg.jobj,
                \s:g.p.emsg.joe)
endfunction
"{{{4 json.getlst: JSON->List
"{{{5 s:g.json.lstinner
let s:g.json.lstinner={
            \ "result": [],
            \  "delta": 1,
            \  "endch": ']',
            \"errargs": ["json.getlst", "syntax", s:g.p.emsg.jlist,
            \            s:g.p.emsg.jle],
            \}
"}}}5
function s:F.json.getlst(str)
    "{{{5 Объявление переменных
    let selfname="json.getlst"
    let tlen=len(a:str)
    let inner=deepcopy(s:g.json.lstinner)
    let inner.str=a:str
    "{{{5 Основной цикл
    while inner.delta<tlen
        "{{{6 Следующий объект
        let lastret=s:F.json.get(a:str[(inner.delta):])
        if type(lastret)==type(0)
            return s:F.json.end(inner)
        endif
        let inner.delta+=lastret.delta
        call add(inner.result, lastret.result)
        unlet lastret
        "{{{6 Запятая
        let comma=match(a:str, '^\_\s*\zs,', inner.delta)
        if (comma)==-1
            return s:F.json.end(inner)
        endif
        let inner.delta=(comma+1)
        "}}}6
    endwhile
    "}}}5
    return s:F.main.eerror(selfname, 'syntax',
                \s:g.p.emsg.jlist,
                \s:g.p.emsg.jle)
endfunction
"{{{4 json.get: JSON->vim
" Получить объект произвольного типа из JSON
function s:F.json.get(str)
    "{{{5 Объявление переменных
    let selfname="json.get"
    let delta=match(a:str, '\_\s*\zs[\[{"tfn[:digit:].\-]')
    if delta==-1
        return 0
    endif
    let char=a:str[(delta)]
    "{{{5 Строка, список или объект
    if has_key(s:g.json.acts, char)
        let lastret=call(s:g.json.acts[char], [a:str[(delta):]], {})
        if type(lastret)==type({})
            let lastret.delta+=delta
        endif
        return lastret
    "{{{5 Число
    elseif char=~#'[[:digit:].\-]'
        let lastret=s:F.json.getnum(a:str[(delta):])
        if type(lastret)==type({})
            let lastret.delta+=delta
        endif
        return lastret
    "{{{5 Другое
    else
        let str=matchstr(a:str, s:g.json.reg.val, delta)
        let lstr=len(str)
        if !lstr
            return 0
        endif
        return      { "delta": delta+lstr,
                    \"result": s:g.json.values[str], }
    endif
    "}}}5
    return 0
endfunction
"{{{4 json.end
" Проверить, не конец ли это текущего объекта (словаря или списка)
function s:F.json.end(inner)
    let end=match(a:inner.str, '^\_\s*\zs'.a:inner.endch, a:inner.delta)
    if (end)!=-1
        return      { "delta": (end+1),
                    \"result": a:inner.result,}
    endif
    return call(s:F.main.eerror, a:inner.errargs, {})
endfunction
"{{{4 json.loads: JSON->vim, throws on error
function s:F.json.loads(str)
    let selfname="json.loads"
    let lastret=s:F.json.get(a:str)
    if type(lastret)==type(0)
        call s:F.main.eerror(selfname, "file", s:g.p.emsg.rjson)
        throw "JSONNotReadable"
    endif
    return lastret.result
endfunction
"{{{4 s:g.json.acts
let s:g.json.acts={
            \'"': s:F.json.getstr,
            \'[': s:F.json.getlst,
            \'{': s:F.json.getobj,
            \}
"{{{3 json.load: JSON file->vim
" Загрузка переменной из JSON-файла 
function s:F.json.load(fname)
    "{{{4 Объявление переменных
    let selfname="json.load"
    " Python не понимает «~», а Vim понимает
    let fname=fnamemodify(a:fname, ':p')
    "{{{4 Проверка возможности чтения
    if !filereadable(fname)
        call s:F.main.eerror(selfname, "file", s:g.p.emsg.r, fname)
        throw "JSONNotReadable"
    endif
    "{{{4 Использовать ли Python?
    if !has("python") || !s:F.main.option("UsePython")
        return s:F.json.loads(s:F.stuf.readfile(fname))
    endif
    "{{{4 null, true и false
    for O in keys(s:g.json.values)
        execute "let ".O."=s:g.json.values[O]"
    endfor
    "{{{4 Собственно, загрузка
    try
        python import vim
        python import demjson as json
        python fd=open(vim.eval("fname"), "r")
        python jstr=json.encode(json.decode(fd.read()))
        " Simplejson не поддерживает UTF-8 символы выше 0x10FFFF, а demjson не 
        " сваливается с ошибкой, если встречается неверный UTF-8.
        " //Кроме того, demjson выдаёт UTF-8 строку, которую, если она содержит 
        " //не-ASCII символы, не удаётся засунуть в vim.command, тогда как 
        " //строка, выдаваемая simplejson не содержит не-ASCII символов.
        " Удаётся, через bytearray(jstr, "utf-8") или через 
        " jstr.encode("ascii", "backslashreplace")
        " //И ещё, при попытке использовать в файле суррогатные пары получается 
        " //не тот результат, на который мы рассчитывали (simplejson).
        python vim.command("let tmp="+bytearray(jstr, "utf-8"))
    catch
        return s:F.json.loads(s:F.stuf.readfile(fname))
    endtry
    python fd.close()
    "}}}4
    return tmp
endfunction
"{{{3 json.dump: vim->JSON file
" Выгрузка переменной в JSON-файл 
function s:F.json.dump(fname, what)
    "{{{4 Объявление переменных
    let selfname="json.dump"
    " Python не понимает «~», а Vim понимает
    let fname=fnamemodify(a:fname, ':p')
    "{{{4 Проверка возможности записи
    if !s:F.stuf.checkwr(fname)
        return s:F.main.eerror(selfname, "file", s:g.p.emsg.w)
    endif
    "{{{4 Использовать ли Python?
    if !has("python") || !s:F.main.option("UsePython")
        return writefile([s:F.json.dumps(a:what)], fname)!=-1
    endif
    "{{{4 Собственно, выгрузка
    try
        python import vim
        python import demjson as json
        python fd=open(vim.eval("fname"), "w")
        python var=vim.eval("a:what")
        " Simplejson не поддерживает UTF-8 символы выше 0x10FFFF, а demjson не 
        " сваливается с ошибкой, если встречается неверный UTF-8.
        python fd.write(json.encode(var))
    catch
        return writefile([s:F.json.dumps(a:what)], fname)!=-1
    endtry
    python fd.close()
    "}}}4
    return 1
endfunction
"{{{3 json.cload: cached JSON file->vim
" Загрузить информацию из файла, если этот файл не загружался ранее или 
" изменился со времени последней загрузки. Иначе вернуть значение из кэша
function s:F.json.cload(fname)
    let ftime=getftime(a:fname)
    if has_key(s:g.cache.transf, a:fname) &&
                \s:g.cache.transf[a:fname][0]==ftime
        return s:g.cache.transf[a:fname][1]
    endif
    let result=s:F.json.load(a:fname)
    let s:g.cache.transf[a:fname]=[ftime, result]
    return result
endfunction
"{{{2 main: eerror, option, destruct
"{{{3 main.eerror: вывести ошибку
function s:F.main.eerror(from, type, ...)
    let comm=((len(a:000))?
                \("(".(join(map(copy(a:000),
                \       '(type(v:val)==type(""))? v:val : string(v:val)'),
                \   ': ')).")"):
                \(""))
    echohl Error
    echo "tr3/".a:from.":".(s:g.p.etype[(a:type)]).(comm)
    echohl None
    return 0
endfunction
"{{{3 main.option: получить настройку с именем option
function s:F.main.option(option)
    let selfname="main.option"
    "{{{4 Получить настройку
    if exists("b:tr3Options") && has_key(b:tr3Options, a:option)
        let src='b'
        let retopt=b:tr3Options[a:option]
    elseif exists("g:tr3Options") && has_key(g:tr3Options, a:option)
        let src='g'
        let retopt=g:tr3Options[a:option]
    else
        return s:g.defaultOptions[a:option]
    endif
    "{{{4 Проверить правильность
    let optstr=a:option."/".src
    "{{{5 Настройки, являющиеся строками
    if index(s:g.opts.str, a:option)!=-1 && type(retopt)!=type("")
        call s:F.main.eerror(selfname, "value", (s:g.p.emsg.str),
                    \optstr)
        throw "InvalidOption:".optstr
    "{{{5 Настройки, являющиеся словарями со строковыми значениями
    elseif index(s:g.opts.dictstrstr, a:option)!=-1
        if type(retopt) != type({})
            call s:F.main.eerror(selfname, "value",
                        \(s:g.p.emsg.dict),
                        \optstr)
            throw "InvalidOption:".optstr
        elseif s:F.stuf.checklod(retopt,
                    \    'type(v:val)==type("")')
            call s:F.main.eerror(selfname, "value",
                        \(s:g.p.emsg.str),
                        \optstr)
            throw "InvalidOption:".optstr
        endif
    "{{{5 Настройки да/нет
    elseif index(s:g.opts.bool, a:option)!=-1
        if type(retopt)!=type(0) || (retopt!=0 && retopt!=1)
            call s:F.main.eerror(selfname, "value",
                        \(s:g.p.emsg.bool),
                        \optstr)
            throw "InvalidOption:".optstr
        endif
    "{{{5 Таблица транслитерации
    " elseif a:option==#"DefaultTranssymb"
        " Do nothing, just return retopt
    "{{{5 Плагины для обычной транслитерации
    elseif a:option==#"Plugs"
        if type(retopt)!=type({})
            call s:F.main.eerror(selfname, "value",
                        \(s:g.p.emsg.dict),
                        \optstr)
            throw "InvalidOption:".optstr
        elseif s:F.stuf.checklod(retopt,
                    \           'v:key==#"Before" || v:key==#"After"')
            call s:F.main.eerror(selfname, "value",
                        \(s:g.p.emsg.plstr), optstr)
            throw "InvalidOption:".optstr
        " type 2 — Funcref
        else
            for key in keys(retopt)
                if s:F.stuf.checklod(retopt[key],
                            \'(type(v:val)==type("") && '.
                            \   'index(keys(s:F.trs.plug), v:val)!=-1) || '.
                            \'(type(v:val)==type([]) && len(v:val)==2 && '.
                            \   'type(v:val[0])==2 && type(v:val[1])==type(""))'
                            \)
                    call s:F.main.eerror(selfname, "value", optstr, key)
                    throw "InvalidOption:".optstr
                    break
                endif
            endfor
        endif
    "{{{5 Плагины для транслитерации по мере ввода
    elseif a:option==#"ToFPlugs"
        if type(retopt)!=type([])
            call s:F.main.eerror(selfname, "value",
                        \(s:g.p.emsg.lst),
                        \optstr)
            throw "InvalidOption:".optstr
        elseif s:F.stuf.checklod(retopt,
                    \'(type(v:val)==type("") && '.
                    \   'index(keys(s:F.tof.plug), v:val)!=-1) || '.
                    \'(type(v:val)==type([]) && len(v:val)==2 && '.
                    \   'type(v:val[0])==2 && type(v:val[1])==type([]))')
            call s:F.main.eerror(selfname, "value", optstr)
            throw "InvalidOption:".optstr
        else
            for P in retopt
                if type(P)==type([]) && s:F.stuf.checklod(P, 'v:val=~"^.$"')
                    call s:F.main.eerror(selfname, "value", optstr)
                    throw "InvalidOption:".optstr
                    break
                endif
            endfor
        endif
    endif
    "}}}4
    return retopt
endfunction
"{{{3 main.destruct: выгрузить плагин
function s:F.main.destruct()
    let acts={
                \"delcommand": s:g.commands,
                \"delfunction": keys(s:F.ext)+keys(s:F.int),
                \"unlet": ["s:g", "s:F"]
            \}
    let srccmd=s:g.srccmd
    for action in keys(acts)
        for subject in acts[action]
            execute action." ".subject
        endfor
    endfor
    return srccmd
endfunction
"{{{2 comm: save, getresult, gettranssymb
" Функции, нужные для транслитерации
"{{{3 comm.save: сохранить изменения
function s:F.comm.save(transsymb)
    let src=(a:transsymb.source[0])
    if src=="file"
        return s:F.json.dump(a:transsymb.source[1], a:transsymb.origin)
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
                call s:F.main.eerror(selfname, "value",
                            \(s:g.p.emsg.str),
                            \a:where, a:value)
                return 1
            elseif a:where==#'/none'
                call s:F.main.eerror(selfname, "value",
                            \(s:g.p.emsg.mnone))
                return 1
            else
                return 0
            endif
        "{{{5 Ключ «options»
        elseif a:key==#"options"
            "{{{6 Значение — словарь,
            if vtype!=type({})
                call s:F.main.eerror(selfname, "value",
                            \(s:g.p.emsg.dict),
                            \a:where, a:value)
                return 1
            "{{{6 имеющий не менее одного ключа,
            elseif !len(keys(a:value))
                return 0
            "{{{6 имеющего строковый тип и значение «capital»,
            elseif s:F.stuf.checklod(copy(a:value),
                        \       'type(v:key)==type("") && v:key==#"capital"')
                call s:F.main.eerror(selfname, "uknkey",
                            \a:where."/...")
                return 1
            "{{{6 которому соответствует строковое значение,
            elseif type(a:value.capital)!=type("")
                call s:F.main.eerror(selfname, "value",
                            \(s:g.p.emsg.str),
                            \a:where."/capital", a:value.capital)
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
            call s:F.main.eerror(selfname, "value",
                        \((s:g.p.emsg.str)."|".
                        \   (s:g.p.emsg.dict)),
                        \a:where, a:value)
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
        for key in keys(a:transsymb)
            "{{{6 Односимвольный ключ
            if key=~'^.$'
                let lower=tolower(key)
                "{{{7 Такой ключ уже есть
                if has_key(result, lower)
                    let result[lower][(key!=#lower)]=
                                \s:F.comm.formattr(a:transsymb[key])
                "{{{7 Такого ключа нет
                else
                    "{{{8 Ключ в верхем регистре
                    if lower!=#key
                        let result[lower]=
                                    \[0, s:F.comm.formattr(a:transsymb[key])]
                    "{{{8 В нижнем
                    else
                        let result[lower]=
                                    \[s:F.comm.formattr(a:transsymb[key]), 1]
                        "{{{9 Проверка настроек
                        if type(a:transsymb[key])==type({}) &&
                                    \has_key(a:transsymb[key], "options") &&
                                    \has_key(a:transsymb[key].options,
                                    \                               "capital")
                            let cap=a:transsymb[key].options.capital
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
                let result.none=a:transsymb[key]
            endif
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
    if !len(a:000)
        let trans=s:F.main.option("DefaultTranssymb")
    else
        let trans=a:000[0]
    endif
    let rettrans={}
    if type(trans)==type("")
        if trans=~#'^'.s:g.json.reg.var.'$'
            if exists(trans)
                let rettrans=eval(trans)
                let src=["var", trans]
            else
                return s:F.main.eerror(selfname, "value",
                            \s:g.p.emsg.trans)
            endif
        elseif filereadable(trans)
            let fname=fnamemodify(trans, ":p")
            let rettrans=s:F.json.cload(fname)
            let src=["file", fname]
        else
            return s:F.main.eerror(selfname, "value",
                        \s:g.p.emsg.trans)
        endif
    elseif type(trans)==type({})
        let rettrans=trans
        let src=["dict", rettrans]
        " 2 — Funcref
    elseif type(trans)==2
        let rettrans=call(trans, [], {})
        let src=["func", trans]
    else
        return s:F.main.eerror(selfname, "value")
    endif
    "{{{4 Кэш
    let idx=index(s:g.cache.trans[0], rettrans)
    let docheck=1
    if idx!=-1 && s:g.cache.trans[1][idx]!={}
        let docheck=0
        let fidx=idx
        while s:g.cache.trans[1][idx].source!=src && idx!=-1
            let idx=index(s:g.cache.trans[0], rettrans, idx+1)
        endwhile
        if idx!=-1
            return s:g.cache.trans[1][idx]
        endif
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
        let optregex=s:F.stuf.regescape(opt)
        call extend(cache, {(O): {"value": opt, "regex": optregex}})
    endfor
    let cache.EscSeq.len=len(cache.EscSeq.value)
    unlet opt
    "{{{5 Словарь {строка: строка, …}
    for O in s:g.trs.dictstrstropt
        let opt=s:F.main.option(O)
        let optregexs =  map(copy(opt), "s:F.stuf.regescape(v:key)")
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
            \"initvars": { "notrans": 0, "notransword": 0, },
            \"mutable": {"bufdicts":{}},
        \}
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
    " col('.')-1 используется для того, чтобы когда курсор находится «за 
    " строкой» всё работало нормально.
    if synIDattr(synIDtrans(synID(line('.'), col('.')-1, 0)), "name") =~?
                \"comment"
        return s:g.tof.failresult
    endif
    return      {"status": "success",
                \"result": s:F.tof.getuntrans(a:bufdict, a:char)}
endfunction
"{{{4 tof.plug.notransword: Не транслитерировать следующее слово
function s:F.tof.plug.notransword(bufdict, char)
    if a:bufdict.vars.notransword
        if a:char!~#'^\k*$'
            let a:bufdict.vars.notransword=0
            return {"status": "stopped"}
        endif
        return      {"status": "success",
                    \"result": s:F.tof.getuntrans(a:bufdict, a:char)}
    endif
    if has_key(a:bufdict.opts.NoTransWord.value, a:char)
        let a:bufdict.vars.notransword=1
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
        return eval('"'.escape(a:bufdict.exmaps[a:char][1], '\<"').'"')
    endif
    return a:char
endfunction
"{{{3 tof.transchar: обработать полученный символ
function s:F.tof.transchar(bufdict, char)
    let lower=tolower(a:char)
    "{{{4 Плагины
    "{{{5 Если сейчас действует плагин
    let plugresult=""
    if len(a:bufdict.curplugs)
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
    endif
    "{{{5 Если нет действующего плагина
    if len(a:bufdict.curtrans)==1
        let i=0
        while i<len(a:bufdict.plugs)
            let P=a:bufdict.plugs[i]
            if           (type(P[1])==type([]) && index(P[1], a:char)!=-1) ||
                        \(type(P[1])==type("") && a:char=~#P[1])
                let retstatus=s:F.tof.plugrun(a:bufdict, a:char, P, i)
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
    if len(a:bufdict.curtrans)>1 &&
                \((a:bufdict.lastline!=curline &&
                \  a:bufdict.lastline != curline-1) ||
                \ curlinestr!~#s:F.stuf.regescape(a:bufdict.curtrseq).'$' ||
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
            let bsseq=repeat("\<BS>", s:F.stuf.strlen(a:bufdict.curtrseq))
            "{{{7 Combining diacritics
            "{{{8 !delcombine
            " В этом случае нужно заботится только о том, является ли диакритика 
            " первым символом
            if !&delcombine
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
            "{{{8 delcombine
            " Здесь нужен <BS> на каждый диакритический знак, кроме самого 
            " первого
            else
                let fstr=a:bufdict.curtrseq
                let a:bufdict.curtrseq=result
                " Игнорируем первый символ
                let fch=s:F.stuf.nextchar_nr(fstr)
                let fstr=fstr[(len(fch)):]
                while len(fstr)
                    let fch=s:F.stuf.nextchar_nr(fstr)
                    let fstr=fstr[(len(fch)):]
                    if s:F.stuf.iscombining(fch)
                        let bsseq.="\<BS>"
                    endif
                endwhile
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
    let char=s:F.stuf.mapprepare(a:char)
    let exmap=maparg(a:char, "i")
    if len(exmap)
        redir => eximapredir
        silent! execute "imap ".char
        redir END
        let eximapredir=eximapredir[1:-2]
        let eximaptype=eximapredir[(-len(exmap)-2)][0]
        if eximaptype==#'*'
            let mapcmd="inoremap"
        else
            let mapcmd="imap"
        endif
        let a:bufdict.exmaps[a:char]=[mapcmd, exmap]
    endif
    execute 'inoremap <special> <expr> <buffer> '.char.' '.
                \'call(<SID>Eval("s:F.tof.transchar"), '.
                \'[<SID>Eval("s:g.tof.mutable.bufdicts['.
                \   (a:bufdict.bufnr).']"), '.
                \'"'.escape(a:char, '|"\').'"], {})'
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
    let curbuf=bufnr('%')
    execute "buffer ".(a:bufdict.bufnr)
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
    let plugs=s:F.main.option("ToFPlugs")
    call map(copy(plugs), 's:F.tof.addplugin(a:bufdict, v:val)')
    "{{{4 Блокировка
    lockvar! a:bufdict.chlist
    lockvar! a:bufdict.opts
    lockvar! a:bufdict.plugs
    "{{{4 Создание привязок
    call map(copy(a:bufdict.chlist), 's:F.tof.map(a:bufdict, v:val)')
    "}}}4
    execute "buffer ".curbuf
    return 1
endfunction
"{{{3 tof.setup: включить транслитерацию по мере ввода
function s:F.tof.setup(buffer, transsymb)
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
                \  "curplugs": [],
            \}
    lockvar! bufdict.bufnr
    let s:g.tof.mutable.bufdicts[bufdict.bufnr]=bufdict
    augroup Tr3ToF
        execute "autocmd! * <buffer=".(bufdict.bufnr).">"
        execute "autocmd BufWipeout <buffer=".(bufdict.bufnr)."> call ".
                    \"s:F.tof.stop(copy(s:g.tof.mutable.bufdicts[".
                    \   (bufdict.bufnr)."]))"
    augroup END
    return s:F.tof.makemaps(bufdict)
endfunction
"{{{3 tof.unmap: удалить привязки
function s:F.tof.unmap(bufdict)
    for M in a:bufdict.chlist
        let curch=s:F.stuf.mapprepare(M)
        execute 'silent! iunmap <special> <buffer> '.curch
        if has_key(a:bufdict.exmaps, M)
            execute a:bufdict.exmaps[M][0].' <special> <buffer> '.curch.' '.
                        \s:F.stuf.mapprepare(a:bufdict.exmaps[M][1])
        endif
    endfor
    return 1
endfunction
"{{{3 tof.stop: выключить транслитерацию по мере ввода
function s:F.tof.stop(bufdict)
    let curbuf=bufnr('%')
    execute "buffer ".(a:bufdict.bufnr)
    call s:F.tof.unmap(a:bufdict)
    unlet s:g.tof.mutable.bufdicts[(a:bufdict.bufnr)]
    execute "buffer ".curbuf
    return 1
endfunction
"{{{2 mod:  add, del, setoption, main: изменение таблицы транслитерации
"{{{3 mod.formattotr
" Превратить пару ("...", "smth") в {'.': {'.': {'.': "smth"} } }.
function s:F.mod.formattotr(srcstr, trstr)
    if !len(a:srcstr)
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
            return s:F.main.eerror(selfname, "perm",
                        \s:g.p.emsg.trex)
        endif
    elseif has_key(a:transsymb, curch)
        if type(a:transsymb[curch])==type("")
            if a:replace
                let a:transsymb[curch]=s:F.mod.formattotr(tail, a:trstr)
                return 1
            elseif len(tail)
                let a:transsymb[curch]=extend(s:F.mod.formattotr(tail,
                            \                                       a:trstr),
                            \                   {"none": a:transsymb[curch]})
                return 1
            else
                return s:F.main.eerror(selfname, "perm",
                            \s:g.p.emsg.trex)
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
                return s:F.main.eerror(selfname, "nfnd",
                            \s:g.p.emsg.trnf, a:trstr)
            endif
        else
            return s:F.main.eerror(selfname, "nfnd",
                        \s:g.p.emsg.trnf, a:trstr)
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
        return s:F.main.eerror(selfname, "perm", s:g.p.emsg.trnd,
                    \a:trstr)
    endif
    return 0
endfunction
"{{{3 mod.setoption: установить или удалить настройку
function s:F.mod.setoption(srcstr, option, value, replace, transsymb)
    "{{{4 Объявление переменных
    let selfname="mod.setoption"
    let trlist=split(a:srcstr, '\zs')
    let deloption=!len(a:value)
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
                                unlet trans["options"][a:option]
                                if !len(keys(trans.options))
                                    unlet trans["options"]
                                endif
                                break
                            else
                                return s:F.main.eerror(selfname, "nfnd",
                                            \(s:g.p.emsg.onfnd),
                                            \ a:option)
                            endif
                        else
                            if !a:replace &&
                                        \has_key(trans.options, a:option) &&
                                        \(trans.options[a:option]!=a:value)
                                return s:F.main.eerror(selfname, "perm",
                                            \(s:g.p.emsg.opt),
                                            \a:option,
                                            \(trans.options[a:option]))
                            else
                                call extend(trans.options, opt, "force")
                                break
                            endif
                        endif
                    else
                        if deloption
                            return s:F.main.eerror(selfname, "nfnd",
                                        \(s:g.p.emsg.onfnd),
                                        \a:option)
                        else
                            let trans["options"]=(opt)
                            break
                        endif
                    endif
                endif
            elseif i == len(trlist)-1
                if deloption
                    return s:F.main.eerror(selfname, "nfnd",
                                \(s:g.p.emsg.onfnd),
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
        return s:F.main.eerror(selfname, "nfnd", s:g.p.emsg.trnf,
                    \a:srcstr)
    endwhile
    "}}}4
    return s:F.comm.save(a:transsymb)
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
                    \'s:F.stuf.strlen(v:val)'))
        let   trlen=max(map(values(plaintrans),
                    \'s:F.stuf.strlen(v:val[0])-(v:val[1]=~"d")'))
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
        let printlist=cache[1]
    else
        let printstr=map(copy(printlist),
                    \"s:F.stuf.printl( srclen, v:val[0]).' '.".
                    \"s:F.stuf.printl(  trlen, v:val[1]).' '.".
                    \"s:F.stuf.printl(flaglen, v:val[2])")
        call sort(printstr)
        let cache[1]=printstr
    endif
    if columns==0
        return copy(printstr)
    endif
    "{{{4 Третья часть — получение вывода в колонках
    if has_key(cache[2], string(columns))
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
"{{{3 out.add
function s:F.out.add(srcstr, trstr, replace, transsymb)
    return s:F.mod.main('add', a:transsymb, a:srcstr, a:trstr, a:replace)
endfunction
"{{{3 out.del
function s:F.out.del(srcstr, recurse, transsymb)
    return s:F.mod.main('del', a:transsymb, a:srcstr, a:recurse)
endfunction
"{{{3 out.setoption
function s:F.out.setoption(option, value, srcstr, replace, transsymb)
    return s:F.mod.main('setoption', a:transsymb, a:srcstr,
                \a:option, a:value, a:replace)
endfunction
"{{{3 out.deloption
function s:F.out.deloption(option, srcstr, transsymb)
    return s:F.mod.main('setoption', a:transsymb, a:srcstr, a:option, "", 1)
endfunction
"{{{3 out.print
function s:F.out.print(columns, transsymb)
    let selfname="out.print"
    "{{{4 Проверка ввода
    if !(a:columns>=-2)
        return s:F.main.eerror(selfname, "args",
                    \s:g.p.emsg.cols)
    endif
    "}}}4
    return s:F.prnt.main(a:columns, a:transsymb)
endfunction
"{{{3 out.transliterate
function s:F.out.transliterate(str, transsymb)
    return s:F.trs.main(a:str, a:transsymb)
endfunction
"{{{3 out._runfunc: проверить аргументы и запустить функцию
function s:F.out._runfunc(funcname, ...)
    let transsymb=s:F.out._checkargs(a:funcname, a:000, s:g.act.func)
    if type(transsymb)==type(0)
        return transsymb
    elseif type(transsymb)==type("")
        return call(s:F.out[a:funcname], a:000, s:F)
    else
        if len(a:000)>s:g.act.func[a:funcname][0]
            return call(s:F.out[a:funcname], a:000[:-2]+[transsymb], s:F)
        else
            return call(s:F.out[a:funcname], a:000+[transsymb], s:F)
        endif
    endif
endfunction
"{{{3 out._checkargs: проверить аргументы
function s:F.out._checkargs(action, args, argchk)
    "{{{4 Объявление переменных
    let selfname="out._checkargs"
    let l000=len(a:args)
    "{{{4 Проверка ввода
    "{{{5 Наличие действия
    if !has_key(a:argchk, a:action)
        return s:F.main.eerror(selfname, "action", s:g.p.emsg.uact,
                    \a:action)
    endif
    "}}}5
    let actchk=a:argchk[a:action]
    "{{{5 Переадресация
    if actchk[0]==-1
        return call(s:F.mng[a:action], a:args, s:F)
    endif
    "{{{5 Объявление переменных
    let maxlen=actchk[0]
    if actchk[1]
        let trpr=(len(actchk[3])>0)
        let maxlen += 1+trpr
    endif
    "{{{5 Превышение длины
    if l000 > maxlen
        return s:F.main.eerror(selfname, "args", s:g.p.emsg.margs)
    "{{{5 Если есть таблица транслитерации в аргументах
    elseif l000 > actchk[0]
        if l000!=maxlen
            return s:F.main.eerror(selfname, "args",
                        \s:g.p.emsg.narg)
        elseif trpr && a:args[-2]!=?actchk[3]
            return s:F.main.eerror(selfname, "syntax", a:action, a:args[-2])
        endif
    "{{{5 Недостаточно аргументов
    elseif l000<actchk[0]
        return s:F.main.eerror(selfname, "args", s:g.p.emsg.largs)
    endif
    "{{{5 Проверка аргументов
    let i=0
    while i<actchk[0]
        let chk=actchk[2][i]
        if type(chk)==type("")
            if a:args[i] !~# '^'.actchk[2][i].'$'
                return s:F.main.eerror(selfname, "syntax", a:action, a:args[i])
            endif
        elseif type(chk)==type([])
            if index(chk, a:args[i])==-1
                return s:F.main.eerror(selfname, "syntax", a:action, a:args[i])
            endif
        elseif chk>=0
            if type(a:args[i])!=chk
                return s:F.main.eerror(selfname, "syntax", a:action, a:args[i])
            endif
        elseif chk==-1
            if index(s:g.comp.lst.optval[a:args[i-1]], a:args[i])!=-1
                return s:F.main.eerror(selfname, "args",
                            \s:g.p.emsg.uval, a:args[i])
            endif
        elseif chk==-2
            if !filereadable(a:args[i])
                return s:F.main.eerror(selfname, "file",
                            \s:g.p.emsg.r, a:args[i])
            endif
        elseif chk==-3
            if !s:F.stuf.checkwr(a:args[i])
                return s:F.main.eerror(selfname, "file",
                            \s:g.p.emsg.w, a:args[i])
            endif
        elseif chk==-4
            if a:args[i]!~'^\w' || !exists(a:args[i])
                return s:F.main.eerror(selfname, "nfnd",
                            \s:g.p.emsg.var, a:args[i])
            endif
        endif
        unlet chk
        let i+=1
    endwhile
    "{{{4 Получение таблицы транслитерации
    if actchk[1]
        if l000>actchk[0]
            let transsymb=s:F.comm.gettranssymb(a:args[-1])
        else
            let transsymb=s:F.comm.gettranssymb()
        endif
        if type(transsymb)!=type({})
            return s:F.main.eerror(selfname, "value",
                        \s:g.p.emsg.dict, "transsymb")
        endif
    else
        return ""
    endif
    "}}}4
    return transsymb
endfunction
"{{{3 out._trlines: транслитерировать строчки(у) целиком
function s:F.out._trlines(startline, endline, transsymb)
    let savedureg=@"
    let [startline, endline]=sort([a:startline, a:endline])
    let s:g.tmp=a:transsymb
    execute "normal! ".startline."gg\"t".(endline-startline+1)."S".
                \"\<C-r>=s:F.trs.main(@t,s:g.tmp)\<CR>"
    unlet s:g.tmp
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
    let action=tolower(a:action)
    "{{{4 Проверка ввода
    let transsymb=s:F.out._checkargs(action, a:000, s:g.act.tof)
    if type(transsymb)==type(0)
        return transsymb
    endif
    "{{{4 Запуск
    if action==#"start"
        if a:bang
            if exists("s:g.tof.mutable.transsymb")
                return s:F.main.eerror(selfname, "action",
                            \s:g.p.emsg.tofgs)
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
            return s:F.main.eerror(selfname, "action",
                        \s:g.p.emsg.tofs)
        endif
        return s:F.tof.setup(bufnr('%'), transsymb)
    "{{{4 Перезагрузка и остановка
    else
        "{{{5 Остановка
        if action==#"stop"
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
                return s:F.tof.stop(copy(s:g.tof.mutable.bufdicts[bufnr('%')]))
            endif
        "{{{5 Перезагрузка
        elseif action==#"restart"
            let buf=bufnr('%')
            unlet transsymb
            if has_key(s:g.tof.mutable.bufdicts, buf)
                let transsymb=s:g.tof.mutable.bufdicts[(buf)].transsymb
                call s:F.tof.stop(s:g.tof.mutable.bufdicts[buf])
            else
                let transsymb=s:F.comm.gettranssymb()
                if type(transsymb)!=type({})
                    return s:F.main.eerror(selfname, "value",
                                \s:g.p.emsg.dict, "transsymb")
                endif
            endif
            return s:F.tof.setup(bufnr('%'), transsymb)
        endif
    endif
    "}}}4
    return 0
endfunction
"{{{3 mng.cache: управление кэшем
function s:F.mng.cache(action, target)
    "{{{4 Объявление переменных
    let selfname="mng.cache"
    let action=tolower(a:action)
    "{{{4 Проверка ввода
    let chkresult=s:F.out._checkargs(action, [a:target], s:g.act.cache)
    if type(chkresult)==type(0)
        return chkresult
    endif
    "{{{4 Очистка кэша
    if action==#"purge"
        if a:target==?"file"
            let s:g.cache.transf={}
        elseif a:target==?"innertrans" || a:target==?"trans"
            let s:g.cache.trans=deepcopy(s:g.cache.init.trans)
        elseif a:target==?"printtrans"
            call map(s:g.cache.trans[2],
                        \'deepcopy(s:g.cache.init.print)')
        elseif a:target==?"toftrans"
            call map(s:g.cache.trans[3], '[]')
        elseif a:target==?"all"
            let s:g.cache.transf={}
            let s:g.cache.trans=deepcopy(s:g.cache.init.trans)
        endif
    "{{{4 Печать кэша
    elseif action==#"show"
        "{{{5 Печать списка файлов и времён их изменений
        if a:target==?"file"
            let header=(s:g.p.cache.th.file)
            if exists("*strftime")
                let lines=values(map(copy(s:g.cache.transf),
                            \'[v:key, strftime("%c", v:val[0])]'))
            else
                let lines=values(map(copy(s:g.cache.transf),
                            \'[v:key, v:val[0]]'))
            endif
            return s:F.stuf.printtable(header, lines)
        "{{{5 Печать кэшей таблиц
        elseif a:target==?"innertrans" || a:target==?"trans" ||
                    \a:target==?"printtrans" || a:target==?"toftrans"
            "{{{6 Объявление переменных
            let header=(s:g.p.cache.th.trans)
            let i=0
            let clen=len(s:g.cache.trans[1])
            let lines=[]
            "{{{6 Получение строк
            while i<clen
                call add(lines, [])
                "{{{7 Первый столбец — источник таблицы
                let source=(s:g.cache.trans[1][i].source)
                if index(["var", "file", "func"], source[0])!=-1
                    call add(lines[-1],
                                \(s:g.p.cache.other[source[0]])." ".
                                \(source[1]))
                else
                    call add(lines[-1], s:g.p.cache.trsrc.dict)
                endif
                "{{{7 Второй столбец — заполненность кэша для печати
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
                "{{{7 Третий столбец — наличие кэша для ToF
                if len(s:g.cache.trans[3][i])
                    call add(lines[-1], s:g.p.cache.other.yes)
                else
                    call add(lines[-1], s:g.p.cache.other.no)
                endif
                "}}}7
                let i+=1
            endwhile
            "}}}6
            return s:F.stuf.printtable(header, lines)
        "{{{5 Печать всех кэшей
        elseif a:target==?"all"
            call s:F.mng.cache("show", "file")
            echo
            call s:F.mng.cache("show", "trans")
        endif
        "}}}5
    endif
    "}}}4
    return 1
endfunction
"{{{3 mng.main
"{{{4 s:g.mng.main
let s:g.mng={}
let s:g.mng.main={
            \"add": 's:F.mod.main("add", transsymb, a:000[0], a:000[1], bang)',
            \"del": 's:F.mod.main("del", transsymb, a:000[0], bang)',
            \"setoption": 's:F.mod.main("setoption", transsymb, '.
            \                           'a:000[3], a:000[0], a:000[1], bang)',
            \"deloption": 's:F.mod.main("setoption", transsymb, '.
            \                           'a:000[2], a:000[0], 0, 1)',
            \"load": 's:F.stuf.writevar(a:000[0], '.
            \                          's:F.json[((bang)?(""):("c"))."load"]('.
            \                                   'fnamemodify(a:000[2], ":p")))',
            \"dump": 's:F.json.dump(fnamemodify(a:000[2], ":p"), '.
            \                      'eval(a:000[0]))',
            \"save": 's:F.comm.save(transsymb)',
        \}
let s:g.mng.main.delete=s:g.mng.main.del
"}}}4
function s:F.mng.main(bang, startline, endline, action, ...)
    "{{{4 Объявление переменных
    let selfname="mng.main"
    let bang=(a:bang=='!')
    let action=tolower(a:action)
    "{{{4 Проверка ввода
    let args=a:000
    if a:action==?"tof"
        let args=[bang]+a:000
    endif
    let transsymb=s:F.out._checkargs(action, args, s:g.act.cmd)
    if type(transsymb)==type(0)
        return transsymb
    endif
    "{{{4 Действия
    "{{{5 Выгрузить дополнение
    if action==#"unload"
        call s:F.mng.tof(1, "stop")
        return !!len(s:F.main.destruct())
    "{{{5 Перезагрузить дополнение
    elseif action==#"reload"
        call s:F.mng.tof(1, "stop")
        execute s:F.main.destruct()
        return 1
    "{{{5 Транслитерировать
    elseif action==#"transliterate"
        "{{{6 Транслитерировать строчки(у) целиком
        if a:000[0]==?"lines"
            return s:F.out._trlines(a:startline, a:endline, transsymb)
            "{{{6 Транслитерировать выделение
        elseif a:000[0]==?"selection"
            "{{{7 Построчное выделение
            if visualmode()==#"V"
                return s:F.out._trlines(line("'<"), line("'>"),
                            \transsymb)
            "{{{7 Выделенный диапозон
            elseif visualmode()==#"v"
                let savedureg=@"
                let s:g.tmp=transsymb
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
                let s:g.tmp=transsymb
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
        echo s:F.prnt.main(-2, transsymb)
        return 1
    "{{{5 Действия, описанные в s:g.mng.main
    elseif has_key(s:g.mng.main, action)
        return eval(s:g.mng.main[action])
    endif
    "}}}4
    return 0
endfunction
"{{{2 comp: автодополнение
"{{{3 comp.deloption
function s:F.comp.deloption(arglead, cmd, pos)
    let cmd=a:cmd[:(a:pos)]
    if cmd=~#'^\S*$'
        return s:F.comp._toarglead(a:arglead, s:g.comp.lst.opt)
    else
        let opt=matchstr(cmd, '^\('.s:g.comp.reg.opt.'\)')
        let lcmd=len(cmd)
        let cmd=substitute(cmd, '^'.opt.'\s\+', '', '')
        let pos=2*len(cmd)-lcmd
        if !len(opt)
            return []
        elseif cmd=~#'^\S*$'
            return [s:g.act.cmd.deloption[2][1]]
        elseif cmd=~#'^'.s:g.act.cmd.deloption[2][1].'\s\+\S*$'
            return s:F.comp._srcstr(a:arglead, a:cmd, pos)
        elseif cmd=~#'^'.s:g.act.cmd.deloption[2][1].'\s\+\S\+\s\+\S*$'
            return [s:g.act.cmd.deloption[3]]
        elseif cmd=~#'^'.s:g.act.cmd.deloption[2][1].'\s\+\S\+\s\+'.
                    \s:g.act.cmd.deloption[3].'\s\+\S*$'
            return s:F.comp._transsymb(a:arglead, cmd, pos)
        endif
    endif
    return []
endfunction
"{{{3 comp.setoption
function s:F.comp.setoption(arglead, cmd, pos)
    let cmd=a:cmd[:(a:pos)]
    if cmd=~#'^\S*$'
        return s:F.comp._toarglead(a:arglead, s:g.comp.lst.opt)
    else
        let opt=matchstr(cmd, '^\('.s:g.comp.reg.opt.'\)')
        let lcmd=len(cmd)
        let cmd=substitute(cmd, '^'.opt.'\s\+', '', '')
        let pos=2*len(cmd)-lcmd
        if !len(opt)
            return []
        elseif cmd=~#'^\S*$'
            return s:F.comp._toarglead(a:arglead, s:g.comp.lst.optval[opt])
        elseif cmd=~#'^\('.s:g.comp.reg.optval[opt].'\)\s\+\S*$'
            return [s:g.act.cmd.setoption[2][2]]
        elseif cmd=~#'^\('.s:g.comp.reg.optval[opt].'\)\s\+'.
                    \s:g.act.cmd.setoption[2][2].'\s\+\S*$'
            return s:F.comp._srcstr(a:arglead, a:cmd, pos)
        elseif cmd=~#'^\('.s:g.comp.reg.optval[opt].'\)\s\+'.
                    \s:g.act.cmd.setoption[2][2].'\s\+\S\+\s\+\S*$'
            return [s:g.act.cmd.setoption[3]]
        elseif cmd=~#'^\('.s:g.comp.reg.optval[opt].'\)\s\+'.
                    \s:g.act.cmd.setoption[2][2].'\s\+\S\+\s\+'.
                    \s:g.act.cmd.setoption[3].'\s\+\S*$'
            return s:F.comp._transsymb(a:arglead, cmd, pos)
        endif
    endif
    return []
endfunction
"{{{3 comp.tof
function s:F.comp.tof(arglead, cmd, pos)
    let cmd=a:cmd[:(a:pos)]
    if cmd=~#'^\S*$'
        return s:F.comp._toarglead(a:arglead, s:g.comp.lst.act.tof)
    else
        let act=matchstr(cmd, '^\('.s:g.comp.reg.act.tof.'\)')
        if act==#"start"
            return s:F.comp._transsymb(a:arglead, a:cmd, a:pos)
        endif
    endif
    return []
endfunction
"{{{3 comp._get
function s:F.comp._get(arglead, cmd, pos, action)
    let cmd=a:cmd[:(a:pos)]
    let regex=""
    for [R,E] in s:g.comp.act[a:action]
        let regex=R.((len(R))?('\s\+'):(''))
        let mlen=match(cmd, '^'.regex.'\zs\S*')
        if mlen==-1
            return []
        endif
        if len(cmd)==mlen || cmd[(mlen):]==#a:arglead
            if type(E)==type("")
                return eval(E)
            else
                return E
            endif
        endif
        let cmd=cmd[(mlen):]
        unlet E
    endfor
    return []
endfunction
"{{{3 comp._transsymb
function s:F.comp._transsymb(arglead, cmd, pos)
    let trans=map(copy(s:g.cache.trans[1]),
                \'(type(v:val.source[1])==type(""))?(v:val.source[1]):0')
    return       s:F.comp._toarglead(a:arglead, trans)+
                \s:F.comp._file(a:arglead, a:cmd, a:pos)+
                \split(glob($HOME."/.vim/config/translit3/*.json"), "\n")
endfunction
"{{{3 comp._file
function s:F.comp._file(arglead, cmd, pos)
    " Если в имени файла содержится перенос строки, то это будет проблемой 
    " пользователя, так как вызывать system — слишком долго, а glob ничего не 
    " экранирует
    return split(glob(escape(a:arglead, '*?[]')."*"), "\n")
endfunction
"{{{3 comp._srcstr
function s:F.comp._srcstr(arglead, cmd, pos)
    let transsymb=s:F.comm.gettranssymb()
    let list=map(s:F.prnt.main(-1, transsymb), 'v:val[0]')
    return s:F.comp._toarglead(a:arglead, list)
endfunction
"{{{3 comp._trstr
function s:F.comp._trstr(arglead, cmd, pos)
    let transsymb=s:F.comm.gettranssymb()
    let list=map(s:F.prnt.main(-1, transsymb), 'v:val[1]')
    return s:F.comp._toarglead(a:arglead, list)
endfunction
"{{{3 comp._toarglead
function s:F.comp._toarglead(arglead, list)
    " Здесь мы пользуемся тем, что, согласно документации, все нестроковые 
    " значения игнорируются и просто превращаем лишние значения в ноль
    return map(copy(a:list),
                \'(type(v:val)==type("") && '.
                \       'v:val=~#"^".s:F.stuf.regescape(a:arglead))?(v:val):0')
endfunction
"{{{3 comp._complete
function s:F.comp._complete(arglead, cmd, pos)
    "{{{4 Объявление переменных
    let cmdpos=match(a:cmd, '\('.s:g.comp.reg.cmd.'\)!\=\zs')
    let curpos=a:pos+0
    let cmd=a:cmd[(cmdpos):(curpos)]
    let curpos-=cmdpos
    "{{{4 Первый аргумент — действие
    let action=matchstr(cmd, '^\s\+\zs\('.(s:g.comp.reg.act.cmd).'\)\>')
    "{{{5 Действие не указано
    if !len(action)
        if match(cmd, '^\s\+\w*$')!=-1
            return s:F.comp._toarglead(a:arglead, s:g.comp.lst.act.cmd)
        endif
        return []
    endif
    "{{{5 Действие указано и после него не требуется никаких аргументов
    if index(s:g.comp.nocomp, action)!=-1
        return []
    endif
    "{{{4 Следующий аргумент
    "{{{5 Убираем всё до следующего за действием аргумента
    let spos=match(cmd, '^\s\+'.action.'\s\+\zs')
    if spos==-1
        return []
    endif
    "{{{5 Дополнение следующего аргумента в зависимости от действия
    let args=[a:arglead, cmd[(spos):], curpos-spos]
    if has_key(s:g.comp.act, action)
        return call(s:F.comp._get, args+[action], {})
    endif
    if index(s:g.comp.transsymb, action)!=-1
        return call(s:F.comp._transsymb, args, {})
    endif
    return call(s:F.comp[action], args, {})
    "}}}4
endfunction
"{{{3 s:g.comp
" lst — списки возможных вариантов
" reg — соответствующие значения
let s:g.comp={
            \"lst": {
            \    "cachesubj": ["file", "innertrans", "trans", "printtrans",
            \                  "all"],
            \       "trsubj": ["selection", "lines"],
            \          "opt": ["capital"],
            \          "cmd": s:g.commands,
            \       "optval": {"capital": ["none", "first"]},
            \}
        \}
let s:g.comp.reg={
            \   "optval": map(copy(s:g.comp.lst.optval), 'join(v:val, "\\|")'),
        \}
" Получение регулярных выражений из списков. Запускается ради побочного эффекта 
" функции extend().
call map(copy(s:g.comp.lst),
            \'(type(v:val)==type([]))?(extend(s:g.comp.reg, '.
            \   '{v:key : join(v:val, "\\|")})):(0)')
"{{{2 Глобальная переменная
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
" Файловый кэш, словарь, в котором ключами являются имена файлов, а значениями — 
" пара (в виде списка) из даты изменения и загруженного значения.
let s:g.cache.transf={}
"{{{3 s:g.act, s:g.act.func: действия
" act:
"   {<action>: [<number_of_arguments>, <last_argument-transliteration_table?>,
"             [<argument_list>], 
"             <before_specifiing_transsymb_you_should_write_this>]}
"   argument_list: list of tests
"       test = Num>=0 : check type
"       test = Num<0  : see below
"       test = String : check type==String and argument=~#'^'.test.'$'
"       test = List   : check argument in test
"       test = Func   : check test(argument)!=0
"
" -1 — настройка
" -2 — файл для чтения
" -3 — файл для записи
" -4 — существующая переменная
"{{{4 Аргументы команд
let s:g.act={
            \"cmd": {
            \    "unload":[ 0, 0, []],
            \    "reload":[ 0, 0, []],
            \    "transliterate":
            \       [ 1, 1, [s:g.comp.lst.trsubj],                   'using'],
            \    "setoption":
            \       [ 4, 1, [s:g.comp.lst.opt, -1, 'for', type("")], 'in'   ],
            \    "deloption":
            \       [ 3, 1, [s:g.comp.lst.opt,     'for', type("")], 'in'   ],
            \    "add":
            \       [ 2, 1, [type(""), type("")],                    'to'   ],
            \    "del":
            \       [ 1, 1, [type("")],                              'from' ],
            \    "save":  [ 0, 1, [], ''],
            \    "print": [ 0, 1, [], ''],
            \    "load":  [ 3, 0, [s:g.json.reg.var, 'from', -2]],
            \    "dump":  [ 3, 0, [-4,               'to',   -3]],
            \    "tof":   [-1],
            \    "cache": [-1],
            \},
            \"tof": {
            \    "start": [ 0, 1, [], ''],
            \     "stop": [ 0, 0, []],
            \    "restart":[0, 0, []],
            \},
            \"cache": {
            \     "show": [ 1, 0, [s:g.comp.lst.cachesubj]],
            \    "purge": [ 1, 0, [s:g.comp.lst.cachesubj]],
            \},
        \}
let s:g.act.cmd.delete=s:g.act.cmd.del
"{{{4 Аргументы функций
" То же, что и выше, но используется для функций
let s:g.act.func={
            \"add":          [ 3, 1, ['.\+', type(""),             [0, 1]], ''],
            \"del":          [ 2, 1, ['.\+',                       [0, 1]], ''],
            \"setoption":    [ 3, 1, [s:g.comp.lst.opt, -1, '.\+', [0, 1]], ''],
            \"deloption":    [ 2, 1, [s:g.comp.lst.opt,     '.\+'],         ''],
            \"transliterate":[ 1, 1, [type("")],                            ''],
            \"print":        [ 1, 1, [type(0)],                             ''],
        \}
"{{{3 Автодополнение действий
" Списки и регулярные выражения для действий
let s:g.comp.lst.act=map(copy(s:g.act),          'keys(v:val)'       )
let s:g.comp.reg.act=map(copy(s:g.comp.lst.act), 'join(v:val, "\\|")')
" Действия: список списков ([[regex, value]]), каждый элемент верхнего списка 
" проверяется последовательно: от команды отрезается regex.'\s\+' (или ничего, 
" если regex пуст). Если команда без regex’а не содержит пробельных символов, то 
" функция возвращает <value>, причём если <value> — строка, то возвращается 
" eval(<value>). То, что возвращается должно быть списком из строк, содержащих 
" информацию для автодополнения.
let s:g.comp.act={
            \"add": [
            \   ['',     's:F.comp._srcstr(a:arglead, a:cmd, a:pos)'          ],
            \   ['\S\+', 's:F.comp._trstr( a:arglead, a:cmd, a:pos)'          ],
            \   ['\S\+',  [s:g.act.cmd.add[3]]                                ],
            \   [s:g.act.cmd.add[3],
            \            's:F.comp._transsymb(a:arglead, a:cmd, a:pos)'       ],
            \],
            \"del": [
            \   ['',     's:F.comp._srcstr(a:arglead, a:cmd, a:pos)'          ],
            \   ['\S\+',  [s:g.act.cmd.del[3]]                                ],
            \   [s:g.act.cmd.del[3],
            \            's:F.comp._transsymb(a:arglead, a:cmd, a:pos)'       ],
            \],
            \"dump": [
            \   ['\S\+',  [s:g.act.cmd.dump[2][1]]                            ],
            \   [s:g.act.cmd.dump[2][1],
            \            's:F.comp._file(a:arglead, a:cmd, a:pos)'            ],
            \],
            \"load": [
            \   ['\('.s:g.json.reg.var.'\)', [s:g.act.cmd.load[2][1]]         ],
            \   [s:g.act.cmd.load[2][1],
            \            's:F.comp._file(a:arglead, a:cmd, a:pos)'            ],
            \],
            \"transliterate": [
            \   ['',     's:F.comp._toarglead(a:arglead, s:g.comp.lst.trsubj)'],
            \   ['\('.s:g.comp.reg.trsubj.'\)', [s:g.act.cmd.transliterate[3]]],
            \   [s:g.act.cmd.transliterate[3],
            \            's:F.comp._transsymb(a:arglead, a:cmd, a:pos)'       ],
            \],
            \"cache": [
            \   ['',     's:g.comp.lst.act.cache'                             ],
            \   ['\('.s:g.comp.reg.act.cache.'\)', 's:g.comp.lst.cachesub'    ],
            \],
        \}
let s:g.comp.act.delete=s:g.comp.act.del
" nocomp — действия, не принимающие аргументов
let s:g.comp.nocomp=[]
" transsymb — действия, принимающие таблицу транслитерации в качестве 
" единственного аргумента
let s:g.comp.transsymb=[]
for s:A in keys(s:g.act.cmd)
    if !s:g.act.cmd[s:A][0]
        if s:g.act.cmd[s:A][1]
            call add(s:g.comp.transsymb, s:A)
        else
            call add(s:g.comp.nocomp, s:A)
        endif
    endif
endfor
unlet s:A
"{{{3 Блокировка s:g
" Блокировать любую запись в глобальную переменную, затем разблокировать 
" конкретные ключи.
lockvar! s:g
for s:U in  ["cache.trans", "cache.transf", "tof.mutable"]
    execute "unlockvar! s:g.".s:U
endfor
unlet s:U
"{{{1
lockvar! s:F
let tr3=s:F
" vim: ft=vim:ts=8:fdm=marker:fenc=utf-8

