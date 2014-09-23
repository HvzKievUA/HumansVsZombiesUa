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
	cookieSecret: process.env.HVZ_COOKIE_SECRET,
	sessionSecret: process.env.HVZ_SESSION_SECRET,
	startDate: "2014-10-2 17-00 +03:00",
	endDate: "2014-10-8 16-00 +03:00"
};
