mongoose = require('mongoose')

Medicine = new mongoose.Schema
	code:
		type: String,
		required: yes,
		unique: yes
	generated:
		type: Date
		required: yes
	usedBy:
		type: String
	usedTime:
		type: Date

mongoose.model('medicine', Medicine)