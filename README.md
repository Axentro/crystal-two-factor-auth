# crystal-two-factor-auth

[![Build Status](https://travis-ci.org/SushiChain/crystal-two-factor-auth.svg?branch=master)](https://travis-ci.org/SushiChain/crystal-two-factor-auth)

Two (2) Factor Authentication (2FA) Crystal code which uses the Time-based One-time Password (TOTP) algorithm. You can use this code with the Google Authenticator mobile app or the Authy mobile or browser app.

* See the [wikipedia page about TOTP](https://en.wikipedia.org/wiki/Time-based_One-time_Password_algorithm)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crystal-two-factor-auth:
    github: SushiChain/crystal-two-factor-auth
```

## Usage

```crystal
require "crystal-two-factor-auth"

# TOTP.generate_base32_secret
base32_secret = "NY4A5CPJZ46LXZCP"

# this is the name of the key which can be displayed by the authenticator program
key_id = "kings@sushichain.io"

# generate the QR code
# we can display this image to the user to let them load it into their auth program
puts "Image url: #{TOTP.qr_code_url(key_id, base32_secret)}"

# we can use the code here and compare it against user input
# code = TOTP.generate_number_string(base32_secret)

# this loop shows how the number changes over time
while true
  diff = TOTP::DEFAULT_TIME_STEP_SECONDS - ((Time.now.epoch_ms / 1000) % TOTP::DEFAULT_TIME_STEP_SECONDS)
  code = TOTP.generate_number_string(base32_secret)
  puts "Secret code = #{code}, change in #{diff} seconds"
  sleep 1
end
```

See the example in `spec/two_factort_auth_example.cr`

### To get this to work for you:

1. Use `generate_base32_secret()` to generate a secret key in base32 format for the user. For example: `"NY4A5CPJZ46LXZCP"`
2. Store the secret key in the database associated with the user account
3. Display the QR image URK returned by `qr_code_url(...)` to the user. Here's a sample which uses GoogleAPI's:
![Sample QR Image](https://chart.googleapis.com/chart?chs=200x200&cht=qr&chl=200x200&chld=M|0&cht=qr&chl=otpauth://totp/user@j256.com%3Fsecret%3DNY4A5CPJZ46LXZCP)
4. User uses the image to load the secret key into their authenticator application (google auth / authy)

### Whenever the user logs in:

1. The user enters the number from the authenticator application into the login form
2. Read the secret associated with the user account from the database
3. The server compares the user input with the output from `generate_current_number_string(...)`
4. If they are equal then the user is allowed to log in


## Contributing

1. Fork it ( https://github.com/SushiChain/crystal-two-factor-auth/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [kingsleyh](https://github.com/kingsleyh) Kingsley Hendrickse - creator, maintainer
