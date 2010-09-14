if !exists('b:tr3Options')
    let b:tr3Options={}
endif
if !has_key(b:tr3Options, 'WriteFunc')
    let b:tr3Options.WriteFunc='@conque'
endif
