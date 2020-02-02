#!/usr/bin/env python
# -*- coding: utf-8 -*-
from configparser import ConfigParser
import os
import json
import uuid
import re


def isFile(path):
    rule_list = path + 'rules/rules_list.json'
    app_json = path + 'rules/apps/'
    if os.access(rule_list, os.F_OK):
        if os.access(rule_list, os.W_OK):
            if os.access(app_json, os.W_OK):
                return True
            else:
                print('apps文件夹不存在或不可写入!')
        else:
            print('rules_list.json不能写入!')
            return False
    else:
        print('rules_list.json文件不存在!')
        print('路径:' + rule_list)
        return False


def read_file(path):
    rule_list = path + 'rules/rules_list.json'
    with open(rule_list, 'r') as f:
        rule_list = json.load(f)
    uuid_dict = {}
    hub_dict = {}
    for index in range(len(rule_list['hub_list'])):
        hub_dict[rule_list['hub_list'][index]['hub_config_name']] = rule_list[
            'hub_list'][index]['hub_config_uuid']
        uuid_dict[rule_list['hub_list'][index]['hub_config_uuid']] = 'True'
    app_name_dict = {}
    for index in range(len(rule_list['app_list'])):
        app_name_dict[rule_list['app_list'][index]['app_config_name']] = 'True'
        uuid_dict[rule_list['app_list'][index]['app_config_uuid']] = 'True'
    return [hub_dict, app_name_dict, uuid_dict]


def mkrule(lists, path):
    item = {}
    index = 0
    print("\033[1;35;40m", "*" * 55, "请选择来源".center(45), "\n", "*" * 55,
          "\033[1;34;40m", "\n", "\t序号\t来源", "\033[1;36;40m", "\n")
    i = 0
    for key in lists[0]:
        print('\t', i, '\t', key)
        item[i] = key
        i += 1
    print('\nnote:输入exit退出!输入exit退出!输入exit退出!', '\033[1;33;40m')
    myuuid = uuid.uuid1()
    while myuuid in lists[2].keys():
        myuuid = uuid.uuid1()
    while True:
        select = input('序号:')
        if select == 'exit':
            os._exit(0)
        try:
            selectToint = int(select.replace(" ", ""))
            break
        except:
            print('输入正确的序号!')
    #来源名称
    get_name = item[selectToint]
    #得到hub_uuid
    selectToint = lists[0][item[selectToint]]
    #得到url
    while True:
        print('输入exit退出!')
        url = input("源地址: ")
        if url == 'exit':
            os._exit(0)
        if re.match(r'^https?:/{2}\w.+$', url):
            if get_name == '酷安':
                if url.endswith('/'):
                    url = url[:-1]
                packagename = url.split('www.coolapk.com')
                packagename = packagename[1].split('/')
                packagename = packagename[2]
                print(packagename)
                break
            elif get_name == 'F-droid':
                if url.endswith('/'):
                    url = url[:-1]
                packagename = url.split('f-droid.org')
                packagename = packagename[1].split('/')
                packagename = packagename[3]
                print(packagename)
                break
            else:
                packagename = ''
                break
        else:
            print('请输入完整的网址(http://...)')
    if packagename == '':
        packagename = input('包名: ')
    Flag = True
    while Flag:
        name = input('配置名称: ')
        Flag = name in lists[1].keys()
        #print('braek')
        #break

    myconfig = {}
    data = json.loads(json.dumps(myconfig))
    data['base_version'] = 1
    data['uuid'] = str(myuuid)
    info = {'app_name': name, 'config_version': 1, 'url': url}
    data['info'] = info
    hub_info = {'hub_uuid': selectToint}
    app_config = {'hub_info': hub_info}
    data['app_config'] = app_config
    target_checker = {'api': 'App_Package', 'extra_string': packagename}
    data['target_checker'] = target_checker
    with open(path + 'rules/apps/%s.json' % name, 'w') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    with open(path + 'rules/rules_list.json', 'r') as js:
        list = json.load(js)
        mylist = {}
        mylists = json.loads(json.dumps(mylist))
        mylists['app_config_name'] = name
        mylists['app_config_uuid'] = str(myuuid)
        mylists['app_config_file_name'] = name
        list['app_list'].append(mylists)
    with open(path + 'rules/rules_list.json', 'w') as f:
        json.dump(list, f, indent=2, ensure_ascii=False)


if __name__ == '__main__':
    try:
        config = ConfigParser()
        config.read('tool.config', encoding='UTF-8')
        project = config['path']['project']
    except:
        print('配置文件错误')

    if str(project).endswith('/') == False:
        project = project + '/'
    if isFile(project) != True:
        print('请检查tool.config中的路径!')
        os._exit(0)
    read_list = read_file(project)
    mkrule(read_list, project)
