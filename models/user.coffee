mongoose = require('mongoose')

UserSchema = new mongoose.Schema
	vkontakteId:
		type: String,
		required: yes,
		unique: yes
	profile:
		type: Object
	role:
		type: String
	lastActionDate:
		type: Date
	hash:
		type: String

mongoose.model('user', UserSchema)