mongoose = require('mongoose')

UserSchema = new mongoose.Schema
	vkontakteId:
		type: String,
		required: true,
		unique: true
	profile:
		type: Object

mongoose.model('user', UserSchema);