require 'json'
require 'bundler'
require 'bundler/thankyou/version'
require 'bundler/thankyou/disbursement'

module Bundler
  module Thankyou
    class Error < StandardError; end

    @lnd_client = nil

    def self.lnd_client
      @lnd_client ||= Lnrpc::Client.new
    end

    def self.lnd_client=(client)
      @lnd_client = client
    end

    def self.specs_from_bundler(options = {})
      Bundler.load.specs.to_a.tap do |specs|
        specs.filter! { |s| s.metadata['funding'] && s.metadata['funding'].match?(/^lightning:/) }
        if options[:only]&.any?
          specs.filter! { |s| options[:only].include?(s.name) }
        end
      end
    end

    def self.recipients_from_bundler(options = {})
      specs_from_bundler(options).each_with_object({}) do |spec, memo|
        memo[spec.name] = spec.metadata['funding'].gsub(/^lightning:/, '')
      end
    end

    def self.specs_from_rubygems(names)
      specs = names.collect do |name|
        uri = URI("https://rubygems.org/api/v1/gems/#{name}.json")
        response = Net::HTTP.get_response(uri)
        if response.is_a?(Net::HTTPSuccess) # ignore gems that are not found
          JSON.parse(response.body)
        end
      end.compact
      specs.filter { |s| s['metadata'] && s['metadata']['funding'] && s['metadata']['funding'].match?(/^lightning:/) }
    end

    def self.recipients_from_rubygems(names)
      specs_from_rubygems(names).each_with_object({}) do |spec, memo|
        memo[spec['name']] = spec['metadata']['funding'].gsub(/^lightning:/, '')
      end
    end
  end
end
