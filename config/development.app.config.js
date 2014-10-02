module.exports = {
	http: {
		port: process.env.PORT || 80,
		siteUrl: process.env.SITE_URL || 'http://localhost.e-conomic.ws/'
	},
	mongoUrl: 'mongodb://localhost/hvz',
	vk: {
		appId: process.env.HVZ_VK_APP_ID || '4353036',
		appSecret: process.env.HVZ_VK_SECRET || 'C4UZatKDeYGmI2BbPyFY'
	},
	cookieSecret: process.env.HVZ_COOKIE_SECRET || 'this is super duper secret string',
	sessionSecret: process.env.HVZ_SESSION_SECRET || 'keyboard cat ololo twice',
	startDate: "2014-10-1 17-00 +03:00",
	endDate: "2014-10-8 16-00 +03:00"
};
