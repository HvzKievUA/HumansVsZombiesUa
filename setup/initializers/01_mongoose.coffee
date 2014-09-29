mongoose = require 'mongoose'
requireTree = require('require-tree')
config = require 'cnf'
mongoUrl = config.mongoUrl
requireTree('../../models/')

module.exports = (done) ->
	db = mongoose.connection
	db.on 'error', (err) ->
		console.error('connection error:' + err)
		done(err)
	db.once 'open', ->
		console.info 'successfully connected to db'.green
		done()

	try
		mongoose.connect(mongoUrl)
		console.info('Started connection on ' + mongoUrl +  ' waiting for it to open...');
	catch e
		console.error('Setting up failed to connect to ' + mongoUrl, e);

