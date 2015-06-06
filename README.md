#automatic.vim

ウィンドウを開いた時にそのウィンドウに対して設定を行うプラグインです。

##Requirement

* Vim version 7.3.895 以上

##Screencapture
![capture](https://f.cloud.github.com/assets/214488/942527/bd4795b6-01b9-11e3-9190-0200ab4d54f8.gif)

##Example
```vim
" g:automatic_config に対してどのような設定を行うのかを記述する
" "match" でどのウィンドウに対する設定かを指定し、
" "set" でその値を設定する
let g:automatic_config = [
\	{
\		"match" : {
\			"buftype" : "help",
\		},
\		"set" : {
\			"height" : 10,
\			"move" : "bottom",
\		},
\	},
\	{
\		"match" : {
\			"bufname" : '\[quickrun output\]',
\		},
\		"set" : {
\			"height" : 5,
\		}
\	},
\]
```

