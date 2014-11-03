process.env.NODE_ENV = process.env.NODE_ENV || 'test'
process.env.APP_ENV = process.env.APP_ENV || 'test'
global.config = require 'cnf'

chai = require('chai')
chai.config.includeStack = yes
global.expect = chai.expect
global.testUtil = require './testUtil'
require("../app")