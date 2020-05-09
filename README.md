

# Bundler::Thankyou
## Lightning donation system for rubygems (and other package managers)

### How does it work?

bundler-thankyou analyzes a project's [gem](https://rubygems.org/) dependencies, extracts recipient information from the gemspecs and sends donations through the Bitcoin [lightning network](http://lightning.network/). 

No additional central directory/service or signup is needed.

Thanks to lightning transactions happen anonymously directly between the funder and recipient.

[![asciicast](https://asciinema.org/a/9MfCfcKLaKu4mp4lT9w4XHr2d.svg)](https://asciinema.org/a/9MfCfcKLaKu4mp4lT9w4XHr2d?autoplay=1)

### Background

#### What the author needs to do:

The gem author adds funding details to the gemspec (in the [metadata hash](https://guides.rubygems.org/specification-reference/#metadata)). This currently can either be a lightning node pubkey (that can receive keysend payments) or a LNURL.

That's it. That is all the author needs to do. 

The author could also decide to dedicate the donations to somebody else. For example the rails gems could say thankyous should go to RailsGirls or similar projects. 


#### What the user/funder needs to do:

Connect `bundler-thankyou` to a [LND](https://github.com/lightningnetwork/lnd) lightning node.

Then run `bundle thankyou` and specify a desired amount. The amount will automatically be split among all the gems.

#### Advantages

* No signup whatsoever
* User and maintainer do not need to agree on a service (like paypal) to perform the transaction
* No central directories or custodial services
* Based solely on existing tools (rubygems)
* Implemented on a "protocol level" - additional service can be built on top of that (like subscriptions, etc.)
* Works internationally
* Usable at the moment where the user interacts with the gems (in the terminal running a bundle command)
* Minimal fees and all the Bitcoin/Lightning advantages



### Installation

Or install it yourself as:

    $ gem install bundler-thankyou

Or you can add it to your Gemfile

```ruby
gem 'bundler-thankyou'
```

### Usage for gem maintainers

bundler-thankyou builds on rubygems. Simply add a `funding` [metadata entry in your gemspec](https://guides.rubygems.org/specification-reference/#metadata).

The value is either your node's pubkey or a LNURL. 

#### For example:

```ruby
Gem::Specification.new do |spec|
  spec.metadata['funding'] = 'lightning:<YOUR NODE PUBKEY OR YOUR LNURL'
end
```

Full example: [bundler-thankyou.gemspec](https://github.com/bumi/bundler-thankyou/blob/01094cc4333be6ce65888de6ba0c4b1ff31ee384/bundler-thankyou.gemspec#L18)

Once the gem is pushed to [rubygems](https://rubygems.org) you're ready to receive thankyous.


### Usage for funders

use the `bundler-thankyou` command to fund your favorite gems. 

#### Send a thankyou to all gems in your Gemfile

    # in your project folder run:
    $ bundle thankyou 

Have a look at this [example screencast](https://asciinema.org/a/9MfCfcKLaKu4mp4lT9w4XHr2d)

#### Send a thankyou to a specific gem

    $ bundler-thankyou fund <gem name>
    
    $ bundler-thankyou fund lnurl
    
Have a look at this [example screencast](https://asciinema.org/a/Aki6htjyMcl3MbIWNUv7S1YgH)


#### Connect the lightning node

Have a look at this [how to screencast](https://asciitinyformsnema.org/a/0SefAba4EH9mtFq8V5lazH4yh)

    $ bundler-thankyou setup
    # follow the instructions and provide the host, cert file and macaroon file to your LND node


#### Help for more details

    $ bundler-thankyou --help


### Questions?

#### Why Bitcoin? 

It is pretty much the only adopted solution to build such things.

#### But I want to pay with credit card (or whatever else)

Bitcoin is used as a method/"protocol" to transfer value. 

We could provide additional services (for both user and project separately) to better fit their needs - for example different payment methods, subscriptions, etc. 

#### But I want to receive payments on my credit card

Again Bitcoin is the "protocol". There are already plenty tools out there that for example give you a visa/master card for spending the received bitcoins. 

#### Why is it called Bundler Thankyou

[Bundler](https://bundler.io/) is the tool to manage dependencies in the ruby world.


### A comment about money

I am very critical about the human perception of the "payment". I do not want it to feel like I've "paid" somebody for something.   
The tone/message is super important and it should not be "payment" but a way of saying "thank you"... thus bundle thankyou. 


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bumi/bundler-thankyou.


## Contact

If you have questions, feedback, ideas please contact me... or even better open an issue. 

Michael Bumann  
[@bumi](http://twitter.com/bumi)  

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
