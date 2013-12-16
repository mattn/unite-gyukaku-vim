let s:save_cpo = &cpo
set cpo&vim

let s:source_gyukaku = { 'name': 'gyukaku' }
let s:yakiniku = []

function! unite#sources#gyukaku#open_url(url)
  if has('win32')
    exe "!start rundll32 url.dll,FileProtocolHandler " . a:url
  elseif has('mac')
    call system("open '" . a:url . "' &")
  elseif executable('xdg-open')
    call system("xdg-open '" . a:url  . "' &")
  else
    call system("firefox '" . a:url . "' &")
  endif
endfunction

function! s:get_menu()
  let res = webapi#http#get("http://www.gyukaku.ne.jp/menu/index.html")
  let dom = webapi#html#parse(iconv(res.content, 'utf-8', &encoding))
  for col in dom.find('div', {'id': 'Table_01'}).childNodes('div')
    let link = col.childNode('a')
    if empty(link)
      continue
    endif
    let url = 'http://www.gyukaku.ne.jp/menu/' . link.attr['href']
    let name = col.find('img').attr['alt']
    call add(s:yakiniku, [name, url])
  endfor
endfunction

function! s:source_gyukaku.gather_candidates(args, context)
  if empty(s:yakiniku) | call s:get_menu() | endif
  return map(copy(s:yakiniku), '{
        \ "word": v:val[0],
        \ "source": "gyukaku",
        \ "kind": "command",
        \ "action__command": "call unite#sources#gyukaku#open_url(''".v:val[1]."'')"
        \ }')
endfunction

function! unite#sources#gyukaku#define()
  return executable('curl') ? [s:source_gyukaku] : []
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
