passport = require('passport')
VKontakteStrategy = require('passport-vkontakte').Strategy
mongoose = require 'mongoose'
User = mongoose.model('user')
config = require 'cnf'

module.exports = (done) ->
	passport.use new VKontakteStrategy
		clientID: config.vk.appId # VK.com docs call it 'API ID'
		clientSecret: config.vk.appSecret
		callbackURL: "http://localhost:5000/auth/vkontakte/callback"
	, (accessToken, refreshToken, profile, callback) ->
		console.log('User.findOrCreate', accessToken, refreshToken, profile)
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
		User.findById id, done

	done()