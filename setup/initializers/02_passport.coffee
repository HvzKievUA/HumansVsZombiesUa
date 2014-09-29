passport = require('passport')
VKontakteStrategy = require('passport-vkontakte').Strategy
mongoose = require 'mongoose'
User = mongoose.model('user')
config = require 'cnf'
uuid = require 'node-uuid'
userFactory = require '../../modules/userFactory'

module.exports = (done) ->
	passport.use new VKontakteStrategy
		clientID: config.vk.appId # VK.com docs call it 'API ID'
		clientSecret: config.vk.appSecret
		callbackURL: config.http.siteUrl + "auth/vkontakte/callback"
	, (accessToken, refreshToken, vkProfile, callback) ->
		userFactory.findOrCreateUser vkProfile, callback

	passport.serializeUser (user, done) ->
		done(null, user.id)

	passport.deserializeUser (id, done) ->
		User.findById id, (err, user) ->
			done err, user

	done()