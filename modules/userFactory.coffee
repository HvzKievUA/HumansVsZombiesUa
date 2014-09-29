moment = require 'moment'
config = require 'cnf'
mongoose = require 'mongoose'
uuid = require 'node-uuid'

userFactory = (user) ->
	moment

	getInfo = ->
		if user.getZombie or user.selfZombie #normal zombie
			user.timer = moment(user.lastActionDate).add(90, 'hours').diff(moment())
			user.isDead = user.timer < 0
			user.role = 'zombie'
		else
			start = moment(config.startDate, "YYYY-MM-DD HH-mm Z")
			hasStarted = start.diff(moment()) < 0
			if hasStarted
				timer = moment(user.lastActionDate).add(30, 'hours').diff(moment())
				if moment(user.lastActionDate).diff(start) < 0
					timer = moment(start).add(30, 'hours').diff(moment())
			else
				timer = moment.duration(30, 'hours').asMilliseconds()
			if timer > 0 #normalHuman
				user.timer = timer
				user.role = 'human'
				user.isDead = no
			else #zombie from hunger
				user.role = 'zombie'
				user.timer = moment(user.lastActionDate).add(120, 'hours').diff(moment())
				user.isDead = user.timer < 0
		if user.isDead then user.role = 'zombie'
		user

	return {
		getInfo: getInfo
	}

userFactory.findOrCreateUser = (vkProfile, callback) ->
	User = mongoose.model 'user'
	User.findOne { vkontakteId: vkProfile.id }, (err, user) ->
		if user or err
			return callback(err, user)
		newUser = new User
			vkontakteId: vkProfile.id
			profile: vkProfile
			role: 'human'
			hash: uuid.v4().substr(0, 13)
			registered: new Date()
			lastActionDate: new Date()
		newUser.save (err) ->
			callback(err, newUser)


module.exports = userFactory
