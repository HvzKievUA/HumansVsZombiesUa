module.exports = {
	mongo: 'mongodb://localhost/hvz',
	vk: {
		appId: process.env.HVZ_VK_APP_ID || 4334105,
		appSecret: process.env.HVZ_VK_SECRET,
	},
	cookieSecret: process.env.HVZ_COOKIE_SECRET || 'this is super duper secret string'

};
