express = require('express')
http = require('http')
passport = require('passport')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
expressSession = require('express-session')
expressWinston = require('express-winston')
log = require('winston-wrapper')(module)
winston = require('winston')
config = require('cnf')
bootable = require 'bootable'
favicon = require('serve-favicon')
mongoose = require 'mongoose'

app = bootable(express())
server = http.createServer(app)

app.use(favicon(__dirname + '/client/img/favicon.png'))
app.set('views', __dirname + '/views')
app.set('view engine', 'jade')
app.use(express.static(__dirname + '/client'))
app.use(cookieParser(config.cookieSecret))
app.use(bodyParser())
app.use(expressSession({ secret: config.sessionSecret }))
app.use(passport.initialize())
app.use(passport.session())

app.phase(bootable.initializers('setup/initializers/'))

app.all '/',  (req, res, next) ->
	res.header("Access-Control-Allow-Origin", "*")
	res.header("Access-Control-Allow-Headers", "X-Requested-With")
	next()

app.get '/', (req, res) ->
	User = mongoose.model('user')
	User.find (err, users) ->
		res.render('home', isAuth: req.isAuthenticated(), users: users, user: req.user)

app.get '/secure',
#	passport.authenticate('vkontakte'),
	(req, res) ->
		res.send('secure')

app.get '/auth/vkontakte',
	passport.authenticate('vkontakte', { scope: ['friends'] }),
	(req, res) ->
		res.end('LOOOL')

app.get '/auth/vkontakte/callback',
	passport.authenticate('vkontakte', { failureRedirect: '/login' }),
	(req, res) ->
		res.redirect('/');

app.get '/login', (req, res) ->
	res.render('login')

app.get '/rules', (req, res) ->
	res.render('rules')

app.use (req, res) ->
	res.status(404).render('404', {title: '404: Page Not Found'})

app.use expressWinston.errorLogger
	transports: [
		new winston.transports.Console({
			colorize: true
		})
	]

app.use (err, req, res, next) ->
	if err.code is "VKSecurity"
		return res.render 'vkFinish', vkRedirect: err.redirect_uri
	res.status(500).render('500', {title: '500: server errro', message: err})

app.boot (err) ->
	if err
		console.error err
	port = config.http.port
	server.listen port
	console.info('server started at ' + config.http.siteUrl + ' '.green)
