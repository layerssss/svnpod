svnpod
======

let users manage their svn passwords easily

config
========
configuration is done vie ENVs, eg.:

    # npm dependencies
    npm install
    # passwords file for svnserve
    export PASSWD_APACHE /srv/svnrepos/myproject/conf/passwd 
    # passwords file for apache
    export PASSWD_APACHE /srv/svnrepos/myproject/conf/passwd_apache
    # running port
    export PORT 80


launch
========

    node_modules/bin/coffee-script/bin/coffee .

