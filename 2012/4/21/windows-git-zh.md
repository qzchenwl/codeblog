# 解决Windows Git Bash中文乱码问题

网上找的，备份一下

1. /etc/gitconfig：

```bash
[gui]
    encoding = utf-8 #代码库统一用urf-8,在git gui中可以正常显示中文
[i18n]
    commitencoding = GB2312 #log编码，window下默认gb2312,声明后发到服务器才不会乱码
[svn]
    pathnameencoding = GB2312 #支持中文路径
```

2. /etc/git-completion.bash:

```bash
alias ls='ls --show-control-chars --color=auto'  #ls能够正常显示中文
```

3. /etc/inputrc:

```bash
set output-meta on   #bash中可以正常输入中文
set convert-meta off
```

4. /etc/profile:

```bash
export LESSCHARSET=utf-8   #$ git log 命令不像其它 vcs 一样，n 条 log 从头滚到底，它会恰当地停在第一页，按 space 键再往后翻页。这是通过将 log 送给 less 处理实现的。以上即是设置 less 的字符编码，使得 $ git log 可以正常显示中文。
```
