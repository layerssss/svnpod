process.env.PASSWD_SVNSERVE?= 'test_passwd_svnserve'
process.env.PASSWD_APACHE?= 'test_passwd_apache'
process.env.ADMIN?= 'admin'
process.env.TITLE?= '忘记设置标题的 svnpod'
process.env.PORT?= 3000
###
Module dependencies.
###
express = require("express")
http = require("http")
path = require("path")
fs = require 'fs'
app = express()
{
  exec
} = require 'child_process'

app.set "port", Number process.env.PORT
app.set "views", path.join __dirname, 'views'
app.set "view engine", "jade"
app.use express.bodyParser()
app.use (req, res, cb)->
  req.body[k] = v for k, v of req.query
  cb()
app.use express.methodOverride()
app.use express.methodOverride()
app.use express.cookieParser()
app.use '/components', express.static path.join __dirname, 'components'
app.locals.title = process.env.TITLE
app.locals.pretty = true
app.locals.version = (require './package.json').version
app.locals.wrapper = 'well'

app.post '/signin', (req, res, cb)->
  res.cookie 'login', req.body.signin_login
  res.cookie 'pass', req.body.signin_pass
  cb()
app.get '/signout', (req, res)->
  res.cookie 'login', ''
  res.cookie 'pass', ''
  res.redirect '/'


app.all '*', (req, res, cb)->
  login = req.body.signin_login||req.cookies.login
  pass = req.body.signin_pass||req.cookies.pass
  if login && pass
    await fs.readFile process.env.PASSWD_SVNSERVE, 'utf8', defer e, svnserve
    res.locals.user =(svnserve.match(new RegExp("(#{login}) = #{pass}$",'m'))||[])[1]
  unless res.locals.user
    return cb new Error "用户名和密码不对，你可以联系管理员“#{process.env.ADMIN}'”帮助你重置密码" if req.method=='POST' && req.url=='/signin'
    res.statusCode = 403
    return res.render 'signin'
  return res.redirect 'back' if req.method=='POST' && req.url=='/signin'
  cb()


setPass = (login, pass, cb)->

  await fs.exists process.env.PASSWD_APACHE, defer exists
  unless exists
    await fs.writeFile process.env.PASSWD_APACHE, '', 'utf8', defer e
    return cb e if e

  await exec "htpasswd -b #{process.env.PASSWD_APACHE} \"#{login}\" \"#{pass}\"", defer e
  return cb e if e



  await fs.exists process.env.PASSWD_SVNSERVE, defer exists
  unless exists
    await fs.writeFile process.env.PASSWD_SVNSERVE, '', 'utf8', defer e
    return cb e if e
    

  await fs.readFile process.env.PASSWD_SVNSERVE, 'utf8', defer e, svnserve
  return cb e if e

  svnserve = svnserve.replace (new RegExp "^#{login} = .*$",'m'), ""
  svnserve += "#{login} = #{pass}\n" if login && pass

  await fs.writeFile process.env.PASSWD_SVNSERVE, svnserve,'utf8', defer e
  return cb e if e
  cb()

app.get '/', (req, res, cb)->
  res.render 'index'

app.post '/', (req, res, cb)->
  req.body.pass = req.body.pass.trim().replace /[^0-9a-z]/gi, ''
  return cb new Error '两次密码输入不一致' unless req.body.pass == req.body.pass2


  await setPass res.locals.user, req.body.pass, defer e
  return cb e if e

  res.cookie 'pass', req.body.pass

  res.redirect 'back'

app.all '/users/*', (req, res, cb)->
  return cb new Error '没有权限' unless process.env.ADMIN == res.locals.user
  cb()
app.get '/users/', (req, res, cb)->
  await fs.readFile process.env.PASSWD_SVNSERVE, 'utf8', defer e, svnserve
  return cb e if e
  res.locals.users = []
  for line in svnserve.match(new RegExp("^.+ = .+$",'mg'))
    [dummy, user] = line.match(new RegExp("^(.+) = .+$"))
    res.locals.users.push user
  res.render 'users'

app.post '/users/', (req, res, cb)->
  req.body.login = req.body.login.trim().replace /[^0-9a-z]/gi, ''
  req.body.pass = req.body.pass.trim().replace /[^0-9a-z]/gi, ''
  return cb new Error '密码和用户名都不能为空字符串' unless req.body.pass && req.body.login
  return cb new Error '两次密码输入不一致' unless req.body.pass == req.body.pass2

  await setPass req.body.login, req.body.pass, defer e
  return cb e if e
  if req.body.login==res.locals.user
    res.cookie 'pass', req.body.pass

  res.redirect 'back'

app.all '/users/:login', (req, res, cb)->
  if req.method is 'DELETE'
    return cb new Error '不能删除管理员' if req.params.login == process.env.ADMIN
    await setPass req.params.login, '', defer e
    return cb e if e
    return res.redirect 'back'

  if req.method is 'PUT'
    req.body.pass = req.body.pass.trim().replace /[^0-9a-z]/gi, ''
    return cb new Error '密码不能为空字符串' unless req.body.pass
    return cb new Error '两次密码输入不一致' unless req.body.pass == req.body.pass2
    await setPass req.params.login, req.body.pass, defer e
    return cb e if e
    if req.params.login == res.locals.user
      res.cookie 'pass', req.body.pass
    return res.redirect 'back'
  return cb()

app.use (err, req, res, cb)->
  res.render 'error', 
    message: err.message
    wrapper: 'alert alert-error'


await http.createServer(app).listen app.get("port"), defer e
throw e if e
console.log "svnpod listening on port " + app.get("port")
