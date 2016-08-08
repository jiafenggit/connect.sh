## 使用connect.sh自动连接ssh或者telnet

> 其中配置文件conn.profile为json格式

### 配置样例：

```
{
   "test1": {
       "host": "192.168.0.1",
       "port": 22,
       "user": "root",
       "pass": "123456",
       "connecttype": "ssh",
       "sshtype": "pass",
       "language": "None"
   },
   "test2": {
       "host": "192.168.0.1",
       "port": 22,
       "user": "root",
       "pass": "123456",
       "connecttype": "ssh",
       "sshtype": "~/.ssh/test_rsa",
       "language": "en_US.UTF-8"
   },
   "test3": {
       "host": "192.168.0.1",
       "port": 23,
       "user": "root",
       "pass": "123456",
       "connecttype": "telnet",
       "language": "en_US.UTF-8"
   }
}
```

### 可以自定义设置别名

echo 'aliases="$HOME/Documents/ssh/connect.sh"' >> ~/.bashrc

### 之后执行

connect show test1

```
/test1/host           	192.168.0.1
/test1/port           	22
/test1/user           	root
/test1/pass           	123456
/test1/connecttype    	ssh
/test1/sshtype        	pass
/test1/language       	en_US.UTF-8
```

connect test1

```
Last login: Mon Aug  8 23:48:46 2016 from gateway
[root@clusterA31 ~]#
```


