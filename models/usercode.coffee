mongoose = require('mongoose')

UserCodeSchema = new mongoose.Schema
	number:
		type: Number
		required: yes,
		unique: yes
	hash:
		required: yes,
		unique: yes
		type: String,
	usedBy:
		type: String

mongoose.model('usercode', UserCodeSchema)