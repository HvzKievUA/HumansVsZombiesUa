UserFactory = require '../modules/userFactory'

module.exports = (role) ->
	(req, res, next) ->
		res.viewData = res.viewData or {}
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