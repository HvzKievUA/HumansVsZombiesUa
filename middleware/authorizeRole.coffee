UserFactory = require '../modules/userFactory'
moment = require 'moment'
config = require 'cnf'

module.exports = (role) ->
	(req, res, next) ->
		res.viewData = res.viewData or {}
		res.viewData.moment = moment
		start = moment(config.startDate, "YYYY-MM-DD HH-mm")
		end = moment(config.endDate, "YYYY-MM-DD HH-mm")
		res.viewData.toStart = start.diff(moment())
		res.viewData.toEnd = end.diff(moment())
		res.viewData.hasStarted = start.diff(moment()) < 0
		res.viewData.hasEnded = end.diff(moment) < 0
		res.viewData.formatDate = (date) -> if date then moment(date).format('YYYY-MM-DD HH:mm:ss') else ''
		isAuth = req.isAuthenticated()
		res.viewData.isAuth = isAuth
		user = req.user || {}
		user.isAdmin = isAuth and req.user.role is 'admin'
		if isAuth
			UserFactory(user).getInfo()
		userRole = req.user?.role
		res.viewData.user = user
		if isAuth and role is 'any'
			return next()
		if user.isAdmin or role is undefined
			return next()
		if userRole isnt role
			return res.redirect '/'
		next()