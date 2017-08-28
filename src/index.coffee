require('colors')

AES   = require("crypto-js/aes")
bip38 = require('bip38')
wif   = require('wif')

console.log(`'\033[2J'`)               # Clear
console.log(`'\033[0;0H'`)             # To top
console.log("CoinCrypt".cyan + "\n")


questions =
  1:
    name: 'method'
    type: 'list'
    message: 'Method'
    choices: ['AES', 'BIP38']
  2:
    name: 'operation'
    type: 'list'
    message: 'Operation'
    choices: ['Encrypt', 'Decrypt']
  3:
    name: 'use_editor'
    type: 'confirm'
    default: false
    message: 'Use editor for input?'
  4:
    name: 'input'
    type: 'editor'
    message: 'Input'
    when: (answers) -> answers.use_editor
    validate: (input) -> input isnt ''
  5:
    name: 'input'
    type: 'input'
    message: 'Input'
    when: (answers) -> not answers.use_editor
    validate: (input) -> input isnt ''
  6:
    name: 'pass_first'
    type: 'password'
    message: 'Passphrase'
    validate: (input) -> input isnt ''
  7:
    name: 'pass_second'
    type: 'password'
    message: 'Passphrase (again)'
    when: (answers) -> answers.operation is 'Encrypt'
    validate: (input) -> input isnt ''


engines =
  'AES':
    'Encrypt': (input, passphrase) ->
      AES.encrypt(input, passphrase).toString().red

    'Decrypt': (input, passphrase) ->
      hex = AES.decrypt(input, passphrase).toString()
      require('buffer').Buffer.from(hex, "hex").toString().green

  'BIP38':
    'Encrypt': (input, passphrase) ->
      decoded = wif.decode(input)
      bip38.encrypt(decoded.privateKey, decoded.compressed, passphrase)

    'Decrypt': (input, passphrase) ->
      decryptedKey = bip38.decrypt(input, passphrase, (status) -> return)
      wif.encode(0x80, decryptedKey.privateKey, decryptedKey.compressed)


module.exports = ->
  require('inquirer').prompt((v for k,v of questions)).then((a) ->

    if a.operation is 'Encrypt' and a.pass_first isnt a.pass_second
      console.log("Error: The supplied passphrases do not match")
      return

    output = engines[a.method][a.operation](a.input, a.pass_first)
    console.log("\n" + output + "\n")
  )
