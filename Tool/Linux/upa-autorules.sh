#!/bin/bash
echo '########################################'
echo '# UpgradeAll跟踪项配置文件自动生成脚本 #'
echo '# 作者:坂本dalao                       #'
echo '# 版本:1.0                             #'
echo '########################################'

#        ┏┓　　　┏┓+ +
#　　　┏┛┻━━━┛┻┓ + +
#　　　┃　　　　　　　┃ 　
#　　　┃　　　━　　　┃ ++ + + +
#　　 ████━████ ┃+
#　　　┃　　　　　　　┃ +
#　　　┃　　　┻　　　┃
#　　　┃　　　　　　　┃ + +
#　　　┗━┓　　　┏━┛
#　　　　　┃　　　┃　　　　　　　　　　　
#　　　　　┃　　　┃ + + + +
#　　　　　┃　　　┃　　　　Codes are far away from bugs with the animal protecting　　　
#　　　　　┃　　　┃ + 　　　　神兽保佑,代码无bug　　
#　　　　　┃　　　┃
#　　　　　┃　　　┃　　+　　　　　　　　　
#　　　　　┃　 　　┗━━━┓ + +
#　　　　　┃ 　　　　　　　┣┓
#　　　　　┃ 　　　　　　　┏┛
#　　　　　┗┓┓┏━┳┓┏┛ + + + +
#　　　　　　┃┫┫　┃┫┫
#　　　　　　┗┻┛　┗┻┛+ + + +

# 基本参数输入
read -p "请输入跟踪项名称：" APPNAME
# 判断变量是否为空，为空则报错，反之将结果输出至/dev/null
echo "${APPNAME:?跟踪项名称不能为空}" > /dev/null && clear
read -p "跟踪项的软件项目地址：" APPURL
# 判断变量是否为空，为空则报错，反之将结果输出至/dev/nul
echo ${APPURL:?项目地址不能为空} > /dev/null && clear

# 自动填写包名
case ${APPURL} in
  *www.coolapk.com*) APKNAME=$(echo ${APPURL} | sed 's/^http.*apk\///')
  ;;
  *play.google.com*) APKNAME=$(echo ${APPURL} | sed 's/^http.*=//')
  ;;
  *f-droid.org*) APKNAME=$(echo ${APPURL} | sed 's/^http.*packages\///' | sed 's/\///')
  ;;
  *) read -p "APP包名 或 Magisk模块文件夹名 或 Shell命令：" APKNAME
  ;;
esac
# 判断变量是否为空，为空则报错，反之将结果输出至/dev/null
echo ${APKNAME:?APP包名|Magisk模块文件夹名|Shell命令 不能为空} > /dev/null && clear

# 自动选择api
case ${APPURL} in
  *www.coolapk.com*|*soft.shouji.com.cn*|*f-droid.org*) API=App_Package
  ;;
  *) read -p "1. App_Package（软件包名）
2. Magisk_Module（Magisk 模块文件夹名）
3. Shell（自定义 Shell 命令）
4. Shell_Root（具有 Root 权限的自定义 Shell 命令
通过哪个 API 获取被跟踪的软件的本地信息，输入序号或直接输入API
(留空为App_Package):" TEMPAPI && clear
    case ${TEMPAPI} in
    1) API=App_Package
    ;;
    2) API=Magisk_Module
    ;;
    3) API=Shell
    ;;
    4) API=Shell_Root
    ;;
    *) API=${TEMPAPI}
    ;;
    esac
    ;;
esac

# 自动选择软件源
case ${APPURL} in
  *github.com*)  HUBUUID=fd9b2602-62c5-4d55-bd1e-0d6537714ca0
  ;;
  *play.google.com*) HUBUUID=65c2f60c-7d08-48b8-b4ba-ac6ee924f6fa
  ;;
  *www.coolapk.com*) HUBUUID=1c010cc9-cff8-4461-8993-a86cd190d377
  ;;
  *soft.shouji.com.cn*) HUBUUID=1c010cc9-cff8-4461-8993-a86mm190d377
  ;;
  *f-droid.org*) HUBUUID=6a6d590b-1809-41bf-8ce3-7e3f6c8da945
  ;;
  *gitlab.com*) HUBUUID=a84e2fbe-1478-4db5-80ae-75d00454c7eb
  ;;
  *repo.xposed.info*) HUBUUID=e02a95a2-af76-426c-9702-c4c39a01f891
  ;;
  *) read -p "软件源无法自动匹配，请输入软件源UUID:" HUBUUID
esac
# 判断变量是否为空，为空则报错，反之将结果输出至/dev/nul
echo ${HUBUUID:?软件源不能为空} > /dev/null && clear

# 输出结果
echo "{
  \"base_version\": 1,
  \"uuid\": \"$(cat /proc/sys/kernel/random/uuid)\",
  \"info\": {
    \"app_name\": \"${APPNAME}\",
    \"config_version\": 1,
    \"url\": \"${APPURL}\"
  },
  \"app_config\": {
    \"hub_info\": {
      \"hub_uuid\": \"${HUBUUID}\"
    },
    \"target_checker\": {
      \"api\": \"${API:-App_Package}\",
      \"extra_string\": \"${APKNAME}\"
    }
  }
}" > "${APPNAME}".json && echo "已在当前目录生成${APPNAME}.json"