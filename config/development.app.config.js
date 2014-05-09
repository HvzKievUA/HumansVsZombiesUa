var myIP = require('my-ip');

module.exports = {
	http: {
		port: process.env.PORT || 5000,
		siteUrl: process.env.SITE_URL || 'http://localhost:$(http.port)/'
	},
	baseUrl: process.env.HVZ_BASE_URL,
	mongoUrl: 'mongodb://localhost/hvz',
	vk: {
		appId: process.env.HVZ_VK_APP_ID,
		appSecret: process.env.HVZ_VK_SECRET
	},
	cookieSecret: process.env.HVZ_COOKIE_SECRET || 'this is super duper secret string',
	sessionSecret: process.env.HVZ_SESSION_SECRET || 'keyboard cat ololo twice'
};
