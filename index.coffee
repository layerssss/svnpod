
###
Module dependencies.
###
express = require("express")
http = require("http")
path = require("path")
fs = require 'fs'
app = express()

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

  
app.configure "development", ->
  app.use express.errorHandler()

    
app.all "*",(req,res,next)->
  console.log req.user
  res.render 'index'




http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
