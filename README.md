

# Bundler::Thankyou
## lightning donation system for rubygems (and other package managers)


## Background

### What the author needs to do:

The gem authoer adds a funding details to the gemspec (in the metadata hash). This currently either can be a lightning node pubkey (that can receive keysend payments) or a LNURL.

That's it. That is all the author needs to do. 

Because of the funding details are in the gemspec we can be sure it is where the author/maintainer wants the money to go to. 

The author could also decide to dedicate the donations to somebody else. For example the rails gems could say thankyous should go to RailsGirls or similar projects. 

### What the user has to do:

Use this tool and basically run `bundle thankyou` and specify a desired amount. The amount will automatically be split among all the used gems.

### Advantages

* No signup whatsover
* User and maintainer do not need to agree on a service (like paypal) to perform the transaction
* No central directories
* Based on existing tools (rubygems)
* Implemented on a "protocol level" - additional service can be built and integrated. (like subscriptions, etc.)
* Works internationally
* Usable at the moment where the user interacts with the gems (in the terminal running a bundle command)
* Minimal fees and all the Bitcoin/Lightning advantages

## Questions?

### Why Bitcoin? 

It is pretty much the only adopted solution to build such things.

### But I want to pay with credit card (or whatever else)

Bitcoin is used as a method/"protocol" to transfer value. 

We could provide additional services (for both user and project separately) to better fit their needs - for example different payment methods, subscriptions, etc. 

### But I want to receive payments on my credit card

Again Bitcoin is the "protocol". There are already plenty tools out there that for example give you a visa/master card for spending the received bitcoins. 

## A comment about money

I am very critical about the human perception of the "payment". I do not want it to feel like I've "paid" somebody for something.   
The tone/message is super important and it should not be "payment" but a way of saying "thank you"... thus bundle thankyou. 


## Installation


## Usage


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bumi/bundler-thankyou.


## Contact

If you have questions, feedback, ideas please contact me... or even better open an issue. 

Michael Bumann  
[@bumi](http://twitter.com/bumi)  

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
