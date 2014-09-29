var developmentConfig = require('./development.app.config');
var testConfig = JSON.parse(JSON.stringify(developmentConfig));

testConfig.mongoUrl = 'mongodb://localhost/hvzTest';
testConfig.http.port = process.env.PORT || 5899;
testConfig.baseUrl = 'http://127.0.0.1:' + testConfig.http.port + '/';

module.exports = testConfig;