require('colors')
AES = require("crypto-js/aes")

console.log(`'\033[2J'`)             # Clear
console.log(`'\033[0;0H'`)           # To top
console.log("AESCrypt".cyan + "\n")

questions =
	1:
		name: 'operation'
		type: 'list'
		message: 'Operation'
		choices: ['Encrypt', 'Decrypt']
	2:
		name: 'message'
		type: 'input'
		message: 'Message'
		validate: (input) -> input isnt ''
	3:
		name: 'pass'
		type: 'input'
		message: 'Passphrase'
		validate: (input) -> input isnt ''


require('inquirer').prompt((v for k,v of questions)).then((answers) ->

	output = ->
		if answers.operation is 'Encrypt'
			AES.encrypt(answers.message, answers.pass).toString().red
		else
			hex = AES.decrypt(answers.message, answers.pass).toString()
			require('buffer').Buffer.from(hex, "hex").toString().green

	console.log("\n" + output() + "\n")
)
