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
	eatenHours:
		type: Number
	registered:
		type: Date
	getZombie:
		type: Date
	hash:
		type: String
	number:
		type: Number
	history:
		type: Array

mongoose.model('user', UserSchema)