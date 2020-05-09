require 'bundler'
require 'bundler/vendored_thor'
require 'yaml'
require 'lnrpc'

module Bundler
  module Thankyou
    class CLI < Thor
      include Thor::Actions
      MINIMUM_AMOUNT = 100 # minimum amount in sats for each recipient

      CONFIG_FILE = File.join(ENV['HOME'], '.bundle-thankyou.yml')
      attr_accessor :recipients, :amount

      default_task :gemfile

      method_option :amount,  type: :numeric, aliases: '-a'
      method_option :only,    type: :array,   aliases: '-o'
      method_option :verbose, type: :boolean, aliases: '-v'
      desc 'gemfile', 'Send a payment to gems in the Gemfile'
      def gemfile
        say "Analyzing Gemfile: #{Bundler.default_gemfile}"
        say '...'

        self.recipients = Bundler::Thankyou.recipients_from_bundler(options)
        disburse!
      end

      method_option :amount,  type: :numeric, aliases: '-a'
      method_option :only,    type: :array,   aliases: '-o'
      method_option :verbose, type: :boolean, aliases: '-v'
      desc 'fund <names>', 'Send to to specific gems'
      def fund(*names)
        if names.empty?
          invoke :gemfile
        else
          self.recipients = Bundler::Thankyou.recipients_from_rubygems(names)
          disburse!
        end
      end

      desc 'setup', 'Setup your lnd connection'
      def setup
        say 'Connecting your LND node'
        config = {}
        config['address'] = ask('Address of your LND node (e.g. localhost:10009):')
        config['macaroon_path'] = ask('Macaroon file path: (e.g. /path/to/admin.macaroon):', path: true)
        config['credentials_path'] = ask('Credentials file path: (e.g. /path/to/tls.cert):', path: true)
        add_file(CONFIG_FILE, YAML.dump(config))
        node_info = lnd_client.lightning.get_info
        say "Successfully connected to #{node_info['alias']} #{node_info['identity_pubkey']}"
      end

      no_commands do

        def disburse!
          say "Found #{recipients.count} fundable gems", Shell::Color::BLUE
          if recipients.count < 1
            exit
          end
          shell.print_table(recipients.to_a, indent: 4, truncate: true)
          say

          if options[:amount].nil?
            self.amount = ask('How much sats do you want do send in total?', Shell::Color::RED).to_i
            say
          end
          Bundler::Thankyou.lnd_client = lnd_client

          say "Sending #{amount} sats split among #{recipients.count} recipients"
          say
          if amount / recipients.count < MINIMUM_AMOUNT
            say "A minimum of #{MINIMUM_AMOUNT * recipients.count} sats is required", Shell::Color::RED
            exit
          end

          disbursment = Disbursement.new(recipients: recipients, total_amount: amount)

          shell.indent do
            disbursment.pay! do |result|
              states = result[:payment_states].map(&:status)
              if states.include?(:SUCCEEDED)
                say "Sent #{result[:amount]} to #{result[:name]}"
              else
                say "Failed to send to #{result[:name]}"
                result[:payment_states].each do |r|
                  say r.inspect
                end if options[:verbose]
              end
            end
          end

          say
          say 'Done! Thank you!', Shell::Color::BLUE
        end

        def lnd_config
          if File.exist?(CONFIG_FILE)
            YAML.safe_load(File.read(CONFIG_FILE)).transform_keys(&:to_sym)
          else # TODO: check env variables
            {}
          end
        end

        def lnd_client
          @lnd_client ||= Lnrpc::Client.new(lnd_config)
        end

        def amount
          @amount || options[:amount]
        end
      end
    end
  end
end
