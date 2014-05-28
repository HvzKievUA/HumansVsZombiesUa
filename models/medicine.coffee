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
	unlimited:
		type: Boolean
	description:
		type: String

mongoose.model('medicine', Medicine)