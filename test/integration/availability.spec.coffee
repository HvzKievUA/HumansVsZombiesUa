request = require 'request'
baseUrl = config.baseUrl

describe 'availability of home page', ->
	for path in ['', 'rules']
		describe "load page for path /#{path}", ->
			resp = null
			before (done) ->
				request.get baseUrl + path, (err, _resp) ->
					resp = _resp
					done err
			it "should return status code 200", ->
				expect(resp.statusCode).to.be.eql 200
			it 'should return body', ->
				expect(resp.body).to.be.ok
