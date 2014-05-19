passport = require('passport')
VKontakteStrategy = require('passport-vkontakte').Strategy
mongoose = require 'mongoose'
User = mongoose.model('user')
config = require 'cnf'
uuid = require 'node-uuid'

module.exports = (done) ->
	passport.use new VKontakteStrategy
		clientID: config.vk.appId # VK.com docs call it 'API ID'
		clientSecret: config.vk.appSecret
		callbackURL: config.http.siteUrl + "auth/vkontakte/callback"
	, (accessToken, refreshToken, profile, callback) ->
		User.findOne { vkontakteId: profile.id }, (err, user) ->
			if user or err
				return callback(err, user)
			newUser = new User
				vkontakteId: profile.id
				profile: profile
				role: 'human'
				hash: uuid.v4().substr(0,13)
				registered: new Date()
			newUser.save (err) ->
				callback(err, newUser)

	passport.serializeUser (user, done) ->
		done(null, user.id)

	passport.deserializeUser (id, done) ->
		User.findById id, (err, user) ->
			done err, user

	done()