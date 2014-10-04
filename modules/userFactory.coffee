moment = require 'moment'
config = require 'cnf'
mongoose = require 'mongoose'

humanBaseTimeH = 24 + 48
zombieBaseTimeH = 24 + 48

userFactory = (user) ->
	moment

	getInfo = ->
		user.eatenHours = user.eatenHours or 0
		if !user.number
			user.role = 'pending'
		else if user.getZombie #normal zombie, that was eaten by zombie
			user.timer = moment(user.getZombie).add(zombieBaseTimeH + user.eatenHours, 'hours').diff(moment())
			user.role = 'zombie'
		else
			start = moment(config.startDate, "YYYY-MM-DD HH-mm Z")
			hasStarted = start.diff(moment()) < 0
			if hasStarted
				if moment(user.lastActionDate).diff(start) < 0 #registered before start
					timer = moment(start).add(humanBaseTimeH, 'hours').diff(moment())
				else #registered after start
					timer = moment(user.lastActionDate).add(humanBaseTimeH, 'hours').diff(moment())
			else #Game has not started human with timer base
				timer = moment.duration(humanBaseTimeH, 'hours').asMilliseconds()
			if timer > 0 #normalHuman
				user.timer = timer
				user.role = 'human'
			else #zombie from hunger
				user.role = 'zombie'
				user.timer = moment.duration(timer).add(zombieBaseTimeH, 'hours').asMilliseconds()
		user.isDead = user.timer < 0
		if user.isDead then user.role = 'dead'
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
			registered: new Date()
			lastActionDate: new Date()
		newUser.save (err) ->
			callback(err, newUser)


module.exports = userFactory
