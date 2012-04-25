# 学习Bash

## 文本处理任务

### 统计最受欢迎的文章

来自 [《处理Apache日志的Bash脚本》](http://www.ruanyifeng.com/blog/2012/01/a_bash_script_of_apache_log_analysis.html) -- 阮一峰

日志格式:  
```txt
203.218.148.99 - - [01/Feb/2011:00:02:09 +0800] "GET /blog/2009/11/an_autobiography_of_yang_xianyi.html HTTP/1.1" 200 84058 "http://www.ruanyifeng.com/blog/2009/11/freenomics.html" "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-TW; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"
```
一个标准的Apache日志。任务是统计2011年访问量最高的文章，每篇文章对应一个url。
```txt
访问量1 网址1
访问量2 网址2
```
阮的脚本  
> 前面已经说过，最终的脚本我只用了20多行，处理10GB的日志，20秒左右就得到了结果。考虑到排序的巨大计算量，这样的结果非常令人满意，充分证明了Bash的威力。

```bash
#!/bin/bash
if ls ./*.result &> /dev/null #判断当前目录中是否有后缀名为result的文件存在
then
　　rm *.result #如果有的话，删除这些文件
fi
touch log.result #创建一个空文件
for i in www-*.log #遍历当前目录中所有log文件
do 
　　echo $i ... #输出一行字，表示开始处理当前文件
　　awk '$9 == "200" {print $7}' $i|grep -i '^/blog/2011/.*\.html$'|sort|uniq -c|sed 's/^ *//g' > $i.result #生成当前日志的处理结果
　　cat $i.result >> log.result #将处理结果追加到log.result文件
　　echo $i.result finished #输出一行字，表示结束处理当前文件
done
echo final.log.result ... #输出一行字，表示最终统计开始
sort -k2 log.result | uniq -f1 --all-repeated=separate |./log.awk |sort -rn > final.log.result #生成最终的结果文件final.log.result
echo final.log.result finished #输出一行字，表示最终统计结束
```
```awk
#!/usr/bin/awk -f
BEGIN {
    RS="" #将多行记录的分隔符定为一个空行
}
{
    sum=0 #定义一个表示总和的变量，初值为0
    for(i=1;i<=NF;i++){ #遍历所有字段
        if((i%2)!=0){ #判断是否为奇数字段
            sum += $i #如果是的话，累加这些字段的值
        }
    }
    print sum,$2 #输出总和，后面跟上对应的网址 
}
```
改进后的脚本
```bash
awk '$9 == 200 && $7 ~ /^\/blog\/2011\// { count[$7]++ } END { for (k in count) print k,count[k] }' | sort -rnk 2 < cat www-*.log
```
1. `$9 == "200" && $7 ~/\/blog\/2011\//`表示第9列值为200且第7列包含匹配`^/blog/2011/`的子串时才执行。即只处理成功访问的2011年的日志。
2. `count[$7]++`表示count是一个字典，第七列作为key的值加1。
3. `for (k in count) print k, count[k]`最后把count的KV对打印出来。
4. `sort -rnk 2`将打印结果送给sort进行排序，按照第二列`k 2`，作为数字`n`，倒序`r`排列。
5. `cat www-*.log`将合并www-\*.log多个文件送到标准输出。
6. `<`将`cat`的stdout重定向到`awk`的stdin。类似的有`>`，左边的stdout重定向到右边的stdin。

### 配置项变更

找出新增的、修改的配置项。

配置项格式：
```txt
key = value
```
新老配置项：
```txt
# 老配置
log4j.rootLogger         = INFO, A1
log4j.appender.A1        = org.apache.log4j.ConsoleAppender
log4j.appender.A1.layout = org.apache.log4j.PatternLayout
  
log4j.appender.A1.layout.ConversionPattern = %-4r %-5p [%t] %37c %3x - %m%n

# 新配置
log4j.rootLogger         = DEBUG, A1
log4j.appender.A1.layout = org.apache.log4j.PatternLayout
log4j.appender.A1 = org.apache.log4j.ConsoleAppender

log4j.appender.A1.layout.ConversionPattern = %-4r %-5p [%t] %37c %3x - %m%n
log4j.appender.stdout = org.apache.log4j.ConsoleAppender
```
脚本：
```bash
vimdiff <(grep -v '^\s*$' oldfile | sed 's/\s*=\s*/ = /g' | sort) <(grep -v '^\s*$' newfile | sed 's/\s*=\s*/ = /g' | sort)
comm -13 <(grep -v '^\s*$' oldfile | sed 's/\s*=\s*/ = /g' | sort) <(grep -v '^\s*$' newfile | sed 's/\s*=\s*/ = /g' | sort)
```
1. `grep -v '^\s*$'`去除文件中的空行（除了空白字符什么都没有的行）。
2. `sed 's/\s*=\s*/ = /g'`，等号左右统一成一个空格。
3. `sort`，排序
4. `<(cmd)`将cmd的stdout作为文件内容，返回文件名。
5. `vimdiff file1 file2`用vim查看file1，file2不同。
6. `comm -13 file1 file2`按行比较file1，file2的内容，仅显示file2独有的行。

## Bash基本语法

### 胶水

```
输出形式    输入形式    胶水           备注与示例
标准输出    标准输入    管道           grep foo file.txt | grep bar
标准输出    文件        进程替换       diff <(sort file1.txt) <(sort file2.txt)
标准输出    参数        管道+xargs     find /usr/bin | xargs file
文件        标准输入    重定向         ssh me@myhost.com 'cat >> ~/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub
字符串      标准输入    here string    base64 -d <<< NzU5Mzg1ODc=
```

### 变量

```bash
bash$ variable1=23
bash$ echo variable1
variable1
bash$ echo $variable1
23
bash$ [ -z "$unassigned" ] && echo "\$unassigned is NULL."
unassigned is NULL.
bash$ let "unassigned += 5"
bash$ [ -z "$unassigned" ] && echo "\$unassigned is NULL."
bash$ echo $unassigned
5
bash$ files=`ls`
bash$ content=$(cat file.txt)
bash$ a=100
bash$ let "a += 1"
bash$ echo $a
101
bash$ b=${a/01/22}
bash$ echo "b = $b"
b = 122
bash$ array=(0 1 2 3 [10]=10 [11]=11)
bash$ echo ${a[2]}
2
bash$ echo ${a[7]}

bash$ echo ${a[10]}
10
bash$ echo ${a[@]}
0 1 2 3 10 11
bash$ echo ${#a[@]}
6
bash$ filename=abc.abc.mp3.mp3
bash$ echo ${filename#a*c}
.abc.mp3.mp3
bash$ echo ${filename##a**c}
.mp3.mp3
bash$ echo ${filename%m*3}
abc.abc.mp3.
bash$ echo ${filename%%m*3}
abc.abc.
bash$ echo $PWD
/home/admin/test
bash$ echo $HOME
/home/admin
```

### 命令替换

命令替换有两种形式：  
1. \`...\`，简单形式，不支持嵌套
2. $(...)，支持嵌套

### 循环和分支

1. `for arg in [ list ] ; do command(s)...; done`
2. `while [ condition ] ; do command(s)...; done`
3. `until [ condition ] ; do command(s)...; done`
4. `case (in) / esac`
5. `if [ condition ] ; then command(s)...; else command(s)...; fi`

### 代数运算

1. ``z=`expr $z + 3` ``
2. `z=$((z+3))`
3. `let z=z+3`
4. `let "z += 3"`

### 命令

Bash + 命令 = 如虎添翼。

#### netcat

netcat号称TCP/IP瑞士军刀，通常用来测试网络以及错误排查。

##### 基本用法：

1. 查看帮助
```
$ nc -h
```

2. 连接远程主机
```
$ nc www.baidu.com 80
GET / HTTP/1.1
Host: www.baidu.com
```

3. 监听端口
```
$ nc -l -p 80
```

4. 扫描远程主机端口
```
$ nc -nvv -w2 -z 192.168.x.x 80-445
```

5. 为Shell开后门
```
$ nc -l -p 8787 -e /bin/bash
```

##### 高级用法：

1. 用作攻击
```
$ cat exploit.txt | nc 192.168.x.x 80
```

2. 用作蜜罐
```
$ cat honeypot.txt | nc -L -p 80 >> log.txt
```

#### awk

文本处理语言，面向记录（record）和域（field）。

##### 记录和域

awk脚本将输入视为记录的集合，每条记录由多个域组成。默认情况下，记录以换行符分隔，域以空白符分隔。记录分隔符和域分隔符分别由RS和FS变量定义。

##### 模式和操作

awk脚本是由一系列模式-操作组成的：  
    pattern { action statement }
如`awk '/ERROR/' app.log`,`awk '$9 == 200 { print $7 }' http.log`  
模式和操作是可选的，没有模式则将操作应用到每条记录，没有操作则打印匹配记录。

###### 模式

awk模式可以是以下任一种：  
* `BEGIN`
* `END`
* `BEGINFILE`
* `ENDFILE`
* `/`正则表达式`/`
* 关系表达式
* 模式 `&&` 模式
* 模式 `||` 模式
* 模式 `?` 模式 `:` 模式
* `(`模式`)`
* `!` 模式
* 模式`,`模式

`BEGIN`和`END`是两种特殊的模式，与输入无关。所有`BEGIN`的操作将在读取输入前执行。`END`则是在输入读取完毕，推出之前执行。

`BEGINFILE`和`ENDFILE`是另外两种特殊模式。他们的操作分别在每个文件读入前和读入完毕时执行。

`&&`，`||`，`!`代表逻辑与或非，和C语言一样。

`?:`同样和C语言一样。第一个模式成功则测试第二个，否则测试第三个。

模式1`,`模式2是区间表达式，匹配从模式1到模式2之间的所有记录。

###### 操作

操作语句括在{}之间。语法类似C语言。

##### 内建变量

* `$n` 当前记录的第n个域。
* `$0` 完整的当前记录。
* `ARGC` 命令行参数个数。
* `ARGIND` 命令行中当前文件的位置（从0算起）。
* `ARGV` 命令行参数数组。
* `CONVFMT` 数字转换格式（默认为%.6g）。
* `ENVIRON` 环境变量关联数组。
* `ERRNO` 最后一个系统错误号。
* `FIELDWIDTHS` 空格分隔的域宽度列表。
* `FILENAME` 当前文件名。
* `FNR` 当前文件中的记录号。
* `FS` 域分隔符，默认是空白字符。
* `IGNORECASE` 该值非0时，匹配时忽略大小写。
* `NF` 当前记录的域个数。
* `NR` 当前记录号（读入多少条记录了）。
* `OFMT` 数字输出格式（默认为%.6g）。
* `OFS` 输出域分隔符（默认是一个空格）。
* `ORS` 输出记录分隔符（默认是一个换行符）。
* `SUBSEP` 数组下标分隔符（默认值是\034)

##### 数组

awk的数组是关联数组，下标为字符串。

普通数组：  
```awk
ary["apple"] = 10;
ary["orange"] = 11;
```
文艺数组：
```awk
ary["fruit"]["apple"] = 10;
ary["fruit"]["orange"] = 11;
ary["foo"]["bar"] = "foobar";
```
二逼数组:
```awk
ary["fruit", "apple"] = 10;
```

#### sed

#### vim

## 附录: sed, awk, vim快速参考

### sed单行脚本快速参考 [1]

### 如何在Bash脚本中使用awk [2]

### 七个高效的文本编辑习惯 [3]

  [1]: http://sed.sourceforge.net/sed1line_zh-CN.html
  [2]: http://www.cyberciti.biz/faq/bash-scripting-using-awk/
  [3]: http://www.moolenaar.net/habits.html
