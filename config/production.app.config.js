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
	startDate: "2014-05-29 17-00",
	endDate: "2014-06-03 18-00"
};
