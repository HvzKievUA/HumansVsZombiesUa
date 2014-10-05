config = require 'cnf'
request = require 'request'
attempt = require 'attempt'

module.exports =
	createUser: ->
	app: ->
		before (done) ->
			attempt
				interval: 300
				retries: 4
			, ->
				console.log 'Trying to reach app..'
				request.get config.baseUrl + 'ping', this
			, (err, results) ->
				if err
					console.log "failed to start app. Attempts: 5"
				done(err, results)