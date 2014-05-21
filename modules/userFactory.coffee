userFactory = (user) ->
	moment

	izZombie = ->
		if user.getZombie
			yes
		else
			moment().subtract(moment(user.lastActionDate)).subtract(1, 'days') < 0

	isOut = ->
		if user.getZombie
			moment().subtract(moment(user.lastActionDate)).subtract(1, 'days') < 0
		else
			moment().subtract(moment(user.lastActionDate)).subtract(2, 'days') < 0

	return {
		izZombie: izZombie
		izOut: isOut
	}

if userFactory and userFactory.exports
	moment = require 'moment'
	return userFactory.exports = userFactory
else
	moment = window.moment
	window.userFactory = userFactory