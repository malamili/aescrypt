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
    name: 'input'
    type: 'input'
    message: 'Input'
    validate: (input) -> input isnt ''
  4:
    name: 'pass'
    type: 'input'
    message: 'Passphrase'
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
    output = engines[a.method][a.operation](a.input, a.pass)
    console.log("\n" + output + "\n")
  )
