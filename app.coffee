express = require('express')
http = require('http')
passport = require('passport')
VkontakteStrategy = require('passport-vkontakte/strategy')

vkAppId = process.env.HVZ_VK_APP_ID || 4334105

app = express();
server = http.createServer(app)

app.get '/', (req, res) ->
	res.send('hello world')

passport.use new VKontakteStrategy
	clientID: vkAppId # VK.com docs call it 'API ID'
	clientSecret: process.env.HVZ_VK_SECRET
	callbackURL: "http://localhost:5000/auth/vkontakte/callback"
, (accessToken, refreshToken, profile, done) ->
	User.findOrCreate
		vkontakteId: profile.id
	, (err, user) ->
		done err, user


server.listen(process.env.PORT || 5000)