passport = require('passport')
VKontakteStrategy = require('passport-vkontakte').Strategy
mongoose = require 'mongoose'
User = mongoose.model('user')
config = require 'cnf'

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
			newUser.save (err) ->
				callback(err, newUser)

	passport.serializeUser (user, done) ->
		done(null, user.id)

	passport.deserializeUser (id, done) ->
		User.findById id, (err, user) ->
			done err, user

	done()