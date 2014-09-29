process.env.APP_ENV is 'production' and require('newrelic')
express = require('express')
http = require('http')
passport = require('passport')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
session = require('express-session')
config = require('cnf')
bootable = require 'bootable'
favicon = require('serve-favicon')
mongoose = require 'mongoose'
authorize = require './middleware/authorizeRole'
moment = require 'moment'
uuid = require 'node-uuid'
async = require 'async'
MongoStore = require('connect-mongo')(session)
UserFactory = require './modules/userFactory'
_ = require 'lodash'

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
	maxAge: 3600000 * 24 * 2
app.use(passport.initialize())
app.use(passport.session())

app.phase(bootable.initializers('setup/initializers/'))

app.all '/', (req, res, next) ->
	res.header("Access-Control-Allow-Origin", "*")
	res.header("Access-Control-Allow-Headers", "X-Requested-With")
	res.header("Cache-Control", "no-transform")
	next()

app.get '/', authorize(), (req, res) ->
	User = mongoose.model('user')
	User.find (err, users) ->
		res.viewData.section = 'home'
		res.viewData.users = users
		teams = {zombie: [], human: [], dead: []}
		for user in users
			u = UserFactory(user.toObject()).getInfo()
			teams[u.role].push u
		res.viewData.teams = teams
		res.render('home', res.viewData)

app.get '/admin', authorize('admin'),
(req, res, next) ->
	async.parallel
		users: (callback) ->
			User = mongoose.model 'user'
			User.find (err, users) ->
				if err then return callback err
				users = users.reduce (list, user) ->
					list.push UserFactory(user.toObject()).getInfo()
					list
				, []
				callback null, users
		medicines: (callback) ->
			Medicine = mongoose.model 'medicine'
			Medicine.find callback
		usercodes: (callback) ->
			UserCode = mongoose.model 'usercode'
			UserCode.find callback
	, (err, results) ->
		if err then return next(err)
		_.extend res.viewData, results
		res.viewData.section = 'admin'
		res.render 'admin', res.viewData

app.post '/admin/generatemedcine', authorize('admin'), (req, res, next) ->
	count = parseInt(req.body.count) || 0
	unless 0 < count < 101
		return next(new Error("Сірьожа, '#{count}' не канає, не більше 100, не менше 1"))
	Medicine = mongoose.model 'medicine'
	createCode = (cb) ->
		medicine = new Medicine
			code: uuid.v4().substr(0, 13)
			generated: new Date(),
			description: req.body.description
			unlimited: !!req.body.unlimited
		medicine.save cb

	async.times count, (n, next) ->
		createCode(next)
	, (err, codes) ->
		if err then return next(err)
		console.log("generated #{codes.length} medicine codes")
		res.redirect '/admin'

app.post '/admin/generateusercodes', authorize('admin'), (req, res, next) ->
	count = parseInt(req.body.count) || 0
	from = parseInt(req.body.from) || 0
	unless 0 < count < 501
		return next(new Error("Сірьожа, '#{count}' не канає, не більше 1000, не менше 1"))
	UserCode = mongoose.model 'usercode'
	createCode = (number, cb) ->
		usercode = new UserCode
			number: number
			hash: uuid.v4().substr(0, 13)
		usercode.save cb
	async.times count, (n, next) ->
			createCode(from + n, next)
	, (err, codes) ->
		if err then return next(err)
		console.log("generated #{codes.length} usercodes")
		res.redirect '/admin'

app.post '/human/submitMedicine', authorize('human'), (req, res, next) ->
	code = req.body.code
	Medicine = mongoose.model 'medicine'
	User = mongoose.model 'user'
	if !code then return next(new Error 'Code should be provided')
	Medicine.findOne {'code': code, 'usedBy': { $exists: no }}, (err, medicine) ->
		if err then return next(err)
		if medicine
			if !medicine.unlimited and moment().diff(moment(medicine.generated)) > 26 * 3600 * 1000
				res.viewData.profileMessage = "Извините, код просрочен"
				return res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)
			medicine.usedBy = req.user.vkontakteId
			medicine.usedTime =  new Date()
			medicine.save (err) ->
				if err then return next(err)
				User.findOneAndUpdate { 'vkontakteId': req.user.vkontakteId }, { lastActionDate: new Date() }, (err, user) ->
					if err then return next(err)
					res.viewData.user = UserFactory(user.toObject()).getInfo()
					res.viewData.profileMessage = "Код сработал!"
					res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)
		else
			res.viewData.profileMessage = "Извините, код уже использован или не существует."
			res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)

app.post '/zombie/submitHuman', authorize('zombie'), (req, res, next) ->
	hash = req.body.hash
	User = mongoose.model 'user'
	if !hash then return next(new Error 'Hash should be provided')
	User.findOne {'hash': hash}, (err, user) ->
		if err then return next(err)
		if user
			userObj = user.toObject()
			UserFactory(userObj).getInfo()
#			if userObj.isDead
#				res.viewData.profileMessage = "Нельзя съесть труп"
#				return res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)
			if userObj.getZombie or (userObj.role is 'zombie' and !userObj.selfZombie)
				res.viewData.profileMessage = "Нельзя съесть зомби"
				return res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)
			user.getZombie = new Date()
			if !userObj.isDead
				if userObj.selfZombie
					user.lastActionDate = userObj.selfZombie
				else
					user.lastActionDate = new Date()
			user.save (err) ->
				if err then return next(err)
				User.findOne { 'vkontakteId': req.user.vkontakteId }, (err, thisUser) ->
					if err then return next(err)
					thisUser.lastActionDate =  new Date()
					if !thisUser.getZombie
						thisUser.selfZombie = new Date()
					thisUser.save (err, user) ->
						if err then return next(err)
						res.viewData.user = UserFactory(user.toObject()).getInfo()
						res.viewData.profileMessage = "Код сработал"
						res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)
		else
			res.viewData.profileMessage = "Извините, человек не найден"
			res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)

app.post '/human/selfzombie', authorize('human'), (req, res, next) ->
	User = mongoose.model('user')
	User.findOneAndUpdate { 'vkontakteId': req.user.vkontakteId }, {selfZombie: new Date(), lastActionDate: new Date()}, (err, user) ->
		if err then return next err
		res.viewData.user = UserFactory(user.toObject()).getInfo()
		res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)

app.get '/auth/vkontakte',
	passport.authenticate('vkontakte', { scope: ['friends'] }),
	(req, res) ->
		res.redirect('/')

app.get '/login/mobile',
	passport.authenticate('vkontakte', { scope: ['friends'], successRedirect: '/m', failureRedirect: '/m' }),
	(req, res) ->
		res.redirect('/m')

app.get '/auth/vkontakte/callback',
	passport.authenticate('vkontakte', { failureRedirect: '/' }),
	(req, res) ->
		res.redirect(if req.cookies.mobile then '/m' else '/')

app.get '/logout', (req, res) ->
	req.logout()
	res.redirect(if req.cookies.mobile then '/m' else '/')

app.get '/teamHuman', authorize(), (req, res) ->
	res.viewData.vkAppId = config.vk.appId
	res.viewData.section = 'teamHuman'
	User = mongoose.model('user')
	User.find (err, users) ->
		teamUsers = []
		for user in users
			user = UserFactory(user).getInfo()
			if user.role is 'human'
				teamUsers.push user
		res.viewData.users = teamUsers
		res.render('teamHuman', res.viewData)

app.get '/teamZombie', authorize(), (req, res) ->
	res.viewData.vkAppId = config.vk.appId
	res.viewData.section = 'teamZombie'
	User = mongoose.model('user')
	User.find (err, users) ->
		teamUsers = []
		for user in users
			user = UserFactory(user).getInfo()
			if user.role is 'zombie'
				teamUsers.push user
		res.viewData.users = teamUsers
		res.render('teamZombie', res.viewData)

app.get '/profile', authorize('any'), (req, res) ->
	res.render('profile', res.viewData)

app.get '/rules', authorize(), (req, res) ->
	res.viewData.section = 'rules'
	res.render('rules', res.viewData)

app.get '/m', authorize(), (req, res) ->
	res.render 'mobile', res.viewData

app.use (req, res) ->
	authorize()(req, res, ->
		if req.cookies.mobile
			return res.status(404).render('messageMobile', message: '404, страница не найдена' )
		res.status(404).render('404', res.viewData)
	);

app.use (err, req, res, next) ->
	authorize()(req, res, ->
		if req.cookies.mobile
			return res.status(500).render('messageMobile', message: 'Непредвиденная ошибка на сайте, сообщите об этой ошибке администратору сайта' + err )
		res.viewData.message = err
		res.status(500).render('500', res.viewData)
	);

app.boot (err) ->
	if err
		console.error err
	port = config.http.port
	server.listen port
	console.info('Server started at ' + config.http.siteUrl + ' '.green)
