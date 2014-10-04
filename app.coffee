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
fs = require 'fs'
path = require 'path'
jade = require 'jade'
Promise = require 'promise'

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
		teams = {zombie: [], human: [], dead: [], pending: []}
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

app.get '/admin/cards', authorize('admin'),
(req, res, next) ->
	UserCode = mongoose.model 'usercode'
	UserCode.find (err, codes) ->
		if err then return next err
		res.render 'cards', codes: codes

app.post '/admin/generatemedcine', authorize('admin'), (req, res, next) ->
	count = parseInt(req.body.count) || 0
	unless 0 < count < 101
		return next(new Error("Сірьожа, '#{count}' не канає, не більше 100, не менше 1"))
	validTo = moment("2014-#{req.body.validTo} +03:00" , "YYYY-MM-DD HH:mm Z")
	if !validTo.isValid
		return next(new Error("Сірьожа, Годен до '#{req.body.validTo}' не канає, шот ні то"))
	Medicine = mongoose.model 'medicine'
	createCode = (cb) ->
		medicine = new Medicine
			code: uuid.v4().substr(0, 13)
			generated: new Date()
			description: req.body.description
			unlimited: !!req.body.unlimited
			validTo: validTo,
			action: req.body.action
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
		return next(new Error("Сірьожа, '#{count}' не канає, не більше 500, не менше 1"))
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

app.post '/admin/setnumber', authorize('admin'), (req, res, next) ->
	number = parseInt(req.body.number)
	vkId = req.body.vkId
	async.parallel
		usercode: (cb) ->
			UserCode = mongoose.model 'usercode'
			UserCode.findOne {number: number, usedBy: {$exists: no}}, cb
		user: (cb) ->
			User = mongoose.model 'user'
			User.findOne {vkontakteId: vkId, number: {$exists: no}}, cb
	, (err, results) ->
		if err then return next err
		unless results.user and results.usercode
			return next(new Error('Номер не найден или использован. Или юзер не найден или ему назначен номер'))
		results.user.number = results.usercode.number
		results.user.hash = results.usercode.hash
		results.user.lastActionDate = new Date()
		results.usercode.usedBy = results.user.vkontakteId
		async.parallel [
			(cb) -> results.user.save cb
			(cb) -> results.usercode.save cb
		] , (err, results) ->
			if err then return next err
			res.redirect '/admin'

#app.get '/admin/submitmedicineforallhumans', authorize('admin'), (req, res, next) ->
#	User = mongoose.model 'user'
#	User.find (err, users) ->
#		for user in users
#			u = UserFactory(user.toObject()).getInfo()
#			if u.role is 'human'
#				user.lastActionDate = new Date()
#				user.save();
#		res.send('ok')

app.post '/human/submitMedicine', authorize('any'), (req, res, next) ->
	code = req.body.code
	Medicine = mongoose.model 'medicine'
	User = mongoose.model 'user'
	if !code then return next(new Error 'Code should be provided')
	Medicine.findOne {'code': code, 'usedBy': { $exists: no }}, (err, medicine) ->
		if err then return next(err)
		if !medicine
			res.viewData.profileMessage = "Извините, код уже использован или не существует."
			return res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)
		if moment(medicine.validTo).diff(moment()) < 0
			res.viewData.profileMessage = "Извините, код просрочен."
			return res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)
		medicines = res.viewData.user.medicines or []
		if medicine.description in medicines
			res.viewData.profileMessage = "Нельзя использовать вакцину с етой раздачи дважды."
			return res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)
		if medicine.action is 'zombieToHuman' and res.viewData.user.role isnt 'zombie'
			res.viewData.profileMessage = 'Код для зомби может использовать только зомби';
			return res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)
		else if (not medicine.action or medicine.action is 'healHuman') and res.viewData.user.role isnt 'human'
			res.viewData.profileMessage = 'Код для людей может использовать только человек';
			return res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)
		medicines.push medicine.description
		medicine.usedBy = req.user.vkontakteId
		medicine.usedTime =  new Date()
		medicine.save (err) ->
			if err then return next(err)
			User.findOneAndUpdate { 'vkontakteId': req.user.vkontakteId }, {
					lastActionDate: new Date()
					medicines: medicines,
					getZombie: null,
					eatenHours: null
			}, (err, user) ->
				if err then return next(err)
				res.viewData.user = UserFactory(user.toObject()).getInfo()
				res.viewData.profileMessage = "Код сработал!"
				res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)

app.post '/zombie/submitHuman', authorize('zombie'), (req, res, next) ->
	hash = req.body.hash
	User = mongoose.model 'user'
	if !hash then return next(new Error 'Hash should be provided')
	User.findOne {'hash': hash}, (err, user) ->
		if err then return next(err)
		if !user
			res.viewData.profileMessage = "Извините, человек не найден"
			return res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)
		userObj = user.toObject()
		UserFactory(userObj).getInfo()
		if userObj.role isnt 'human'
			res.viewData.profileMessage = "Можно схавать только живого человека (не зомби, не труп)"
			return res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)
		user.getZombie = new Date()
		user.lastActionDate = new Date()
		user.save (err) ->
			if err then return next(err)
			User.findOne { 'vkontakteId': req.user.vkontakteId }, (err, thisUser) ->
				if err then return next(err)
				if thisUser.getZombie #normal zombie eat human
					thisUser.eatenHours = (thisUser.eatenHours || 0) + 36
				else #zombie from hunger eat human
					thisUserObj = thisUser.toObject()
					UserFactory(thisUserObj).getInfo()
					thisUser.getZombie = new Date()
					thisUser.eatenHours = 12 + Math.ceil(thisUserObj.timer/(1000 * 3600))
				thisUser.save (err, user) ->
					if err then return next(err)
					res.viewData.user = UserFactory(user.toObject()).getInfo()
					res.viewData.profileMessage = "Код сработал"
					res.render((if req.cookies.mobile then 'mobile' else 'profile'), res.viewData)

app.get '/eat/:hash', authorize('zombie'), (req, res) ->
	res.viewData.hash = req.params.hash
	res.render('eat', res.viewData)

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

app.get '/teamHuman', authorize('human'), (req, res) ->
	tmpl_dir = __dirname + '/views/news/forHuman/'
	# read all news in the directory
	fs.readdir tmpl_dir, (err, news) ->
		_news = []
		if news?
			for _new in news
				if path.extname(_new) == '.jade'
					try
						_news.unshift jade.compile(fs.readFileSync(tmpl_dir + _new, 'utf8'))()
					catch e
						_news.unshift '<p class="error_message">Ай-яй-яй! Хтось невалідний шаблон "' + _new + '" закомітив. Треба сказати адмінам.</p>'
			res.viewData.news = _news

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

app.get '/teamZombie', authorize('zombie'), (req, res) ->
	tmpl_dir = __dirname + '/views/news/forZombie/'
	# read all news in the directory
	fs.readdir tmpl_dir, (err, news) ->
		_news = []
		if news?
			for _new in news
				if path.extname(_new) == '.jade'
					try
						_news.unshift jade.compile(fs.readFileSync(tmpl_dir + _new, 'utf8'))()
					catch e
						_news.unshift '<p class="error_message">Ай-яй-яй! Хтось невалідний шаблон "' + _new + '" закомітив. Треба сказати адмінам.</p>'
			res.viewData.news = _news

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
	tmpl_dir_z = __dirname + '/views/news/forZombie/'
	tmpl_dir_h = __dirname + '/views/news/forHuman/'


	humanNews = new Promise (resolve, reject) ->
		# read all news in the directory
		fs.readdir tmpl_dir_h, (err, news) ->
			_new = null

			if news?
				try
					while __new = news.pop()
						if path.extname(__new) == '.jade'
							_new = jade.compile(fs.readFileSync(tmpl_dir_h + __new, 'utf8'))()
							break
				catch e
					_new = '<p class="error_message">Остання новина крива. Скажи адмінам.</p>'

			resolve _new


	zombieNews = new Promise (resolve, reject) ->
		# read all news in the directory
		fs.readdir tmpl_dir_z, (err, news) ->
			_new = null

			if news?
				try
					while __new = news.pop()
						if path.extname(__new) == '.jade'
							_new = jade.compile(fs.readFileSync(tmpl_dir_z + __new, 'utf8'))()
							break
				catch e
					_new = '<p class="error_message">Остання новина крива. Скажи адмінам.</p>'

			resolve _new


	Promise.all [Promise.resolve(humanNews), Promise.resolve(zombieNews)]
		.then (p_res) ->
			res.viewData.h_new = p_res[0]
			res.viewData.z_new = p_res[1]
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
