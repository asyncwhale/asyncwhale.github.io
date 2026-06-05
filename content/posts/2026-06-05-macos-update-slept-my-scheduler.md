+++
title = "sleep 0 防不住强制睡眠：我的 Mac mini 被半夜更新睡死了"
date = 2026-06-05
tags = ["macos", "launchd", "pmset", "踩坑"]
draft = false
+++

我那几个定时任务，有一阵子日志一片空白。不是报错，是压根没跑。

它们靠 launchd 每分钟拉一趟，每趟开头会写一行检查记录。可日志在某个后半夜停了，之后接连好几次该生成的文件干脆都不在。不是空文件，是没生成。机器没关、没重启，手动跑都正常。

## 锁不是元凶

我先怀疑是它自己卡死了。那脚本有个锁文件防重入，哪趟跑挂了锁没清掉，后面每趟来都会被挡住、直接退出。我对着那段处理 stale 锁的逻辑看了好一会儿，越看越觉得是这儿——像个侦探在错的房间里翻箱倒柜，还翻得挺带劲。

后来才反应过来：每趟最开头那行检查记录，是在碰锁之前就写的。那两天连这行都没有。锁的问题再大，这行也该写。它一行都没有，就只能是这两天 launchd 根本没拉起过它。

launchd 的定时器睡眠时不触发，醒了才补一发，这我知道。所以是机器睡了。

## 设了永不睡眠，它还是睡了

可这台我特意设过永不睡眠。`pmset -g custom`，sleep 0、standby 0 都在，插着电，没有定时睡眠计划。

`pmset -g log` 翻那两天，满屏 DarkWake，powernap 每小时醒一下跑点杂活再睡。`pmset -g assertions` 看睡前谁按着不让睡，coreaudiod 攥着一个 PreventUserIdleSystemSleep，从睡前一直攥着没松手。

idle 睡眠这条路，sleep 0 关了一道，coreaudiod 的 assertion 又额外按着一道。两道锁，它还是睡了。那它就不是从 idle 这条路睡的。

idle 之外还有另一类：强制睡眠。合盖、`pmset sleepnow`、谁直接调 IOPMSleepSystem、系统自己的维护，都走这条。而我手里这些工具——sleep 0、caffeinate——全都只管 idle。药全堆在了错的那条路上。

caffeinate 我本想拿来兜底，翻了下 man 又放下了。它 `-s` 建的是 PreventSystemSleep，听着像管得宽，其实跟 coreaudiod 那个 assertion 一个货，只挡 idle。

这地方我之前一直没分清，单独记一句：**sleep 0、caffeinate、PreventSystemSleep 全都只挡 idle 睡眠；要把合盖、sleepnow、系统维护这类强制睡眠也一起摁死，得用内核级的 `pmset disablesleep 1`。** sleep 0 和 disablesleep 我一直当近义词，其实差着一整层。

## 抓现行：半夜的更新窗口

剩下就是抓是谁把它放倒的。日志断在后半夜某次维护窗口，我把那一分钟前后的 log 一行行过，正好压着这几条：

```
dasd ... "com.apple.duetactivityscheduler.triggersRestart"
softwareupdated ... "com.apple.SoftwareUpdate.TonightActivityTrigger"
SoftwareUpdateNotificationManager ... "RestartCountdownOperation"
```

dasd 是 DuetActivityScheduler，管后台维护排程的。softwareupdated 是更新守护进程，TonightActivityTrigger 就是它半夜起来准备装更新那一下。三条凑一块：那场"今夜自动装更新"被触发，走重启倒计时那套流程，顺手把机器带进了一条 sleep 0 管不着的睡眠。`/Library/Updates` 里压着个没装完的包，`AutomaticallyInstallMacOSUpdates` 开着。

严格说我没真盖棺。能一锤定音的是 `pmset -g log` 里那行 "Entering Sleep ... due to:"，会直接写明这次睡是谁触发的。可那行早被日志轮转冲掉了——pmset 的日志攒不了多久就滚没，这种事后无法复现的时点证据，等你想起来去看基本就晚了。所以这是条凑出来的证据链，不是铁证。但更新维护那几条恰好压在入睡前一分钟、又确实有挂起的更新，够我信了。

## 监控的眼睛不能长在被监控的机器上

它睡了我不意外，意外的是睡了这么久，没一个人吭声。

我以为有兜底，另起了个东西盯着它。可那个东西也在同一台机器上、也靠 launchd 拉。机器睡死，它跟着睡死，自己都喊不出声。

盯一台机器的眼睛，长在这台机器上，机器一倒它先瞎。要有用，那只眼睛得待在机器外头——它停发心跳超过一阵子，外面的东西替它喊。

睡眠本身我没硬扛。disablesleep 能堵死所有路，但它连我自己想让机器睡都一起禁了，为更新这点事上一道内核锁，重了。真正该补的是把那只眼睛挪出机器，那个我知道怎么做，还没做。所以这事到现在也没真了结，先记在这儿。

## 顺手：怎么判断你的机器也偷偷睡过

```
pmset -g log | grep -i "Entering Sleep"                          # 有没有 idle 之外的睡眠，due to 写了原因
pmset -g log | grep -iE "softwareupdate|duetactivityscheduler"   # 睡的时点是不是压在更新维护窗口
defaults read /Library/Preferences/com.apple.SoftwareUpdate | grep -i AutomaticallyInstall   # 自动装更新是不是开着
```

第一条要是翻出 idle 之外的睡眠、due-to 又指向维护，基本就是这个坑。
