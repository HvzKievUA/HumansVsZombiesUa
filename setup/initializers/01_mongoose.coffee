mongoose = require 'mongoose'
requireTree = require('require-tree')
config = require 'cnf'
mongoConnectionString = config.mongo
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
		mongoose.connect(mongoConnectionString)
		log.info('Started connection on ' + (mongoConnectionString).cyan + ', waiting for it to open...'.grey);
	catch e
		log.error(('Setting up failed to connect to ' + mongoConnectionString).red, err.message);

