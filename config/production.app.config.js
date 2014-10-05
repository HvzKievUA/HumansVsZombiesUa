module.exports = {
	http: {
		siteUrl: process.env.SITE_URL,
		port: process.env.PORT
	},
	mongoUrl: process.env.MONGOHQ_URL,
	vk: {
		appId: process.env.HVZ_VK_APP_ID,
		appSecret: process.env.HVZ_VK_SECRET
	},
    sentryURL: process.env.HVZ_SENTRY_URL,
	cookieSecret: process.env.HVZ_COOKIE_SECRET,
	sessionSecret: process.env.HVZ_SESSION_SECRET,
	startDate: "2014-10-2 17-00 +03:00",
	endDate: "2014-10-6 19-00 +03:00"
};
