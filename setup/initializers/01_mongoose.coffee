mongoose = require 'mongoose'
requireTree = require('require-tree')
config = require 'cnf'
mongoUrl = config.mongoUrl
log = require('winston-wrapper')(module)
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
		log.info('Started connection on ' + (mongoUrl).cyan + ', waiting for it to open...'.grey);
	catch e
		log.error(('Setting up failed to connect to ' + mongoUrl).red, err.message);

