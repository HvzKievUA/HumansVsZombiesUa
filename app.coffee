express = require('express')
http = require('http')
passport = require('passport')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
expressSession = require('express-session')
VKontakteStrategy = require('passport-vkontakte').Strategy

vkAppId = process.env.HVZ_VK_APP_ID || 4334105

app = express();
server = http.createServer(app)

app.set('views', __dirname + '/views')
app.set('view engine', 'jade')
app.use(express.static(__dirname + '/client'))
app.use(cookieParser(process.env.HVZ_COOKIE_SECRET or 'this is super duper secret string'))
app.use(bodyParser())
app.use(expressSession({ secret: process.env.HVZ_SESSION_SECRET or 'keyboard cat' }))
app.use(passport.initialize())
app.use(passport.session())

app.get '/', (req, res) ->
	res.send('hello world')

app.get '/auth/vkontakte',
	passport.authenticate('vkontakte'),
	(req, res) ->
		res.end('LOOOL')

app.get '/auth/vkontakte/callback',
	passport.authenticate('vkontakte', { failureRedirect: '/login' }),
(req, res) ->
	# Successful authentication, redirect home.
	res.redirect('/');

app.get '/login', (req, res) ->
	res.render('login')

passport.use new VKontakteStrategy
	clientID: vkAppId # VK.com docs call it 'API ID'
	clientSecret: process.env.HVZ_VK_SECRET
	callbackURL: "http://localhost:5000/auth/vkontakte/callback"
, (accessToken, refreshToken, profile, done) ->
#	User.findOrCreate
#		vkontakteId: profile.id
#	, (err, user) ->
#		done err, user
	console.log('User.findOrCreate', accessToken, refreshToken, profile)
	done()

# Simple route middleware to ensure user is authenticated.
#   Use this route middleware on any resource that needs to be protected.  If
#   the request is authenticated (typically via a persistent login session),
#   the request will proceed.  Otherwise, the user will be redirected to the
#   login page.
ensureAuthenticated = (req, res, next)  ->
	if req.isAuthenticated()
		next()
	else
		res.redirect('/login')

port = process.env.PORT || 5000;
server.listen(port)
