userFactory = (user) ->
	moment

	getInfo = ->
		if user.getZombie #normal zombie
			user.timer = moment(user.lastActionDate).add(24, 'hours').diff(moment())
			user.isDead = user.timer < 0
			user.role = 'zombie'
		else
			timer =  moment(user.lastActionDate).add(30, 'hours').diff(moment())
			if timer > 0 #normalHuman
				user.timer = timer
				user.role = 'human'
				user.isDead = no
			else #zombie from hunger
				user.role = 'zombie'
				user.timer = moment(user.lastActionDate).add(54, 'hours').diff(moment())
				user.isDead = user.timer < 0
		user

	return {
		getInfo: getInfo
	}

if module and module.exports
	moment = require('moment')
	return module.exports = userFactory
else
	window.userFactory = userFactory