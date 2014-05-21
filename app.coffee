express = require('express')
http = require('http')
passport = require('passport')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
session = require('express-session')
expressWinston = require('express-winston')
log = require('winston-wrapper')(module)
winston = require('winston')
config = require('cnf')
bootable = require 'bootable'
favicon = require('serve-favicon')
mongoose = require 'mongoose'
authorize = require './middleware/authorizeRole'
moment = require 'moment'
uuid = require 'node-uuid'
async = require 'async'
MongoStore = require('connect-mongo')(session)

app = bootable(express())
server = http.createServer(app)

app.use(favicon(__dirname + '/client/img/favicon.png'))
app.set('views', __dirname + '/views')
app.set('view engine', 'jade')
app.use(express.static(__dirname + '/client'))
app.use(cookieParser(config.cookieSecret))
app.use(bodyParser())
app.use session
	secret: config.sessionSecret
	store: new MongoStore url: config.mongoUrl
	maxAge: 3600 * 24 * 2
app.use(passport.initialize())
app.use(passport.session())

app.phase(bootable.initializers('setup/initializers/'))

app.all '/', (req, res, next) ->
	res.header("Access-Control-Allow-Origin", "*")
	res.header("Access-Control-Allow-Headers", "X-Requested-With")
	next()

app.get '/', authorize(), (req, res) ->
	User = mongoose.model('user')
	User.find (err, users) ->
		res.viewData.users = users
		res.render('home', res.viewData)

app.get '/admin', authorize('admin'),
(req, res, next) ->
	User = mongoose.model 'user'
	Medicine = mongoose.model 'medicine'
	User.find (err, users) ->
		if err then return next(err)
		res.viewData.users = users
		Medicine.find (err, medicines) ->
			if err then return next(err)
			res.viewData.medicines = medicines
			res.render 'admin', res.viewData

app.post '/admin/generatemedcine', authorize('admin'), (req, res, next) ->
	count = parseInt(req.body.count) || 0
	unless 0 < count < 101
		return next(new Error("Сірьожа, '#{count}' не канає, не більше 100, не менше 1"))
	Medicine = mongoose.model 'medicine'
	createCode = (cb) ->
		medicine = new Medicine
			code: uuid.v4().substr(0, 13)
			generated: new Date()
		medicine.save cb

	async.times count, (n, next) ->
		createCode(next)
	, (err, codes) ->
		if err
			return next(err)
		console.log("generated #{codes.length} medicine codes")
		res.redirect '/admin'

app.post '/human/submitMedicine', authorize('human'), (req, res, next) ->
	code = req.body.code
	Medicine = mongoose.model 'medicine'
	User = mongoose.model 'user'
	if !code then return next(new Error 'Code should be provided')
	Medicine.findOneAndUpdate {'code': code, 'usedBy': { $exists: no }}, {usedBy: req.user.vkontakteId, usedTime: new Date()}, (err, data) ->
		if err then return next(err)
		if data
			User.findOneAndUpdate { 'vkontakteId': req.user.vkontakteId }, { lastActionDate: new Date() }, (err, data) ->
				if err then return next(err)
				res.viewData.data = "Все збс"
				res.render('profile', res.viewData)
		else
			res.viewData.err = "Миша, все хуйня"
			res.render('profile', res.viewData)

app.post '/zombie/submitHuman', authorize('zombie'), (req, res, next) ->
	hash = req.body.hash
	User = mongoose.model 'user'
	if !hash then return next(new Error 'Hash should be provided')
	User.findOneAndUpdate {'hash': hash}, {getZombie: new Date()}, (err, data) ->
		if err then return next(err)
		if data
			User.findOneAndUpdate { 'vkontakteId': req.user.vkontakteId }, { lastActionDate: new Date() }, (err, data) ->
				if err then return next(err)
				res.viewData.data = "Все збс"
				res.render('profile', res.viewData)
		else
			res.viewData.err = "Миша, все хуйня"
			res.render('profile', res.viewData)

app.get '/auth/vkontakte',
	passport.authenticate('vkontakte', { scope: ['friends'] }),
	(req, res) ->
		res.redirect('/')

app.get '/auth/vkontakte/callback',
	passport.authenticate('vkontakte', { failureRedirect: '/' }),
	(req, res) ->
		res.redirect('/')

app.get '/logout', (req, res) ->
	req.logout()
	res.redirect('/')

app.get '/teamHuman', authorize('human'), (req, res) ->
	res.render('team', res.viewData)
app.get '/teamZombie', authorize('zombie'), (req, res) ->
	res.render('team', res.viewData)

app.get '/profile', authorize('any'), (req, res) ->
	res.viewData.timer = 3600 * 24;
	res.render('profile', res.viewData)

app.get '/rules', authorize(), (req, res) ->
	res.render('rules', res.viewData)

app.use (req, res) ->
	res.status(404).render('404', {title: '404: Page Not Found'})

app.use expressWinston.errorLogger
	transports: [
		new winston.transports.Console({
			colorize: true
		})
	]

app.use (err, req, res, next) ->
	res.status(500).render('500', {title: '500: server error', message: err})

app.boot (err) ->
	if err
		console.error err
	port = config.http.port
	server.listen port
	console.info('server started at ' + config.http.siteUrl + ' '.green)
