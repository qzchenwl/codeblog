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
改进后的脚本
```bash
awk '$9 == 200 && $7 ~ /^\/blog\/2011\// { count[$7]++ } END { for (k in count) print k,count[k] }' | sort -rnk 2 < cat www-*.log
```
1. `$9 == "200" && $7 ~/\/blog\/2011\//`表示第9列值为200且第7列包含匹配`^/blog/2011/`的子串时才执行。即只处理成功访问的2011年的日志。
2. `count[$7]++`表示count是一个字典，第七列作为key的值加1。
3. `for (k in count) print k, count[k]`最后把count的KV对打印出来。
4. `sort -rnk 2`将打印结果送给sort进行排序，按照第二列`k 2`，作为数字`n`，倒序`r`排列。
5. `cat www-*.log`将合并www-*.log多个文件送到标准输出。
6. `<`将`cat`的stdout重定向到`awk`的stdin。类似的有`>`，左边的stdout重定向到右边的stdin。

### 配置项变更

找出新增的、修改的配置项。

配置项格式
```txt
key = value
```
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

## Bash基本语法与内建命令

## 外部命令组合

## vim,awk,sed,sort,uniq...小抄
