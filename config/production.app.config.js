module.exports = {
	http: {
		siteUrl: process.env.SITE_URL,
		port: process.env.PORT
	},
	baseUrl: process.env.HVZ_BASE_URL,
	mongoUrl: process.env.MONGOHQ_URL,
	vk: {
		appId: process.env.HVZ_VK_APP_ID,
		appSecret: process.env.HVZ_VK_SECRET
	},
	cookieSecret: process.env.HVZ_COOKIE_SECRET,
	sessionSecret: process.env.HVZ_SESSION_SECRET
};
