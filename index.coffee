
###
Module dependencies.
###
express = require("express")
http = require("http")
path = require("path")
fs = require 'fs'
app = express()
childprocess = require 'child_process'

app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "passwd_apache", process.env.PASSWD_APACHE or 'test_passwd_apache'
  app.set "passwd_svnserve", process.env.PASSWD_SVNSERVE or 'test_passwd_svnserve'
  app.set "views", __dirname
  app.set "view engine", "jade"
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.static path.join __dirname,'public'

  
app.configure "development", ->
  app.use express.errorHandler()

app.use express.basicAuth (user, pass, next)->
  fs.readFile app.get('passwd_svnserve'),'utf8',(err, text)->
    next err, (text.match(new RegExp("(#{user}) = #{pass}$",'m'))||[])[1]

app.get '/', (req, res, next)->
  res.render 'index'
    user: req.user

app.post '/', (req, res, next)->
  fs.exists app.get('passwd_apache'), (exists)->
    return next() if exists
    fs.writeFile app.get('passwd_apache'),'','utf8',next

app.post '/', (req, res, next)->
  childprocess.exec "htpasswd -b #{app.get 'passwd_apache'} \"#{req.user}\" \"#{req.body.password}\"",next

app.post '/', (req, res, next)->
  fs.readFile app.get('passwd_svnserve'),'utf8',(err, text)->
    req.passwd = text
    next err

app.post '/', (req, res, next)->
  fs.writeFile app.get('passwd_svnserve'),req.passwd.replace(new RegExp("#{req.user} = .*$",'m'),"#{req.user} = #{req.body.password}"),'utf8',next


app.post '/', (req, res, next)->
  res.redirect 'back'



http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
