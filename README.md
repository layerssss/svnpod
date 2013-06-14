svnpod
======

xxx, 帮我开个svn账号。

## 这货有啥功能？

* 让用户自己登陆后自己改密码
* 帮他/她开（重置/删除）个svn账号
* 支持svnserve和apache_svndav(因为它俩格式不一样，svnserve用的passwd不加密，而apache_svndav用的passwd加密)

## 这货长啥样？

![undefined](http://ww1.sinaimg.cn/large/7a464815jw1e5nlkwgdauj20h60dz756.jpg)
![undefined](http://ww2.sinaimg.cn/large/7a464815jw1e5nll5f89fj20h60gqjsn.jpg)
![undefined](http://ww2.sinaimg.cn/large/7a464815jw1e5nllb544wj20ti0k4q6b.jpg)

## 咋用？

* 安装nodejs
* 安装这货: `sudo npm install svnpod`
* 跑起来↓ 

```bash
PORT=8000 TITLE=有标题的svnpod ADMIN=admin PASSWD_SVNSERVE=/path/to/your/svnserve/passwd PASSWD_APACHE=/path/to/your/apache/passwd svnpod
```

## 这货看起来不错，赏个star!

* 鸡血+10: [https://github.com/layerssss/svnpod](https://github.com/layerssss/svnpod)
