require 'lnrpc'
require 'lnurl'
require 'lightning/invoice'

module Bundler
  module Thankyou
    class Disbursement
      attr_accessor :total_amount, :recipients

      def initialize(recipients:, total_amount:)
        self.recipients   = recipients
        self.total_amount = total_amount
      end

      def amount_per_recipient
        @amount_per_recipient ||= total_amount / recipients.count
      end

      def amount_per_recipient_msat
        amount_per_recipient * 1000
      end

      def pay!
        recipients.each do |name, pubkey_or_lnurl|
          result_array = if Lnurl.valid?(pubkey_or_lnurl)
                           pay_lnurl(pubkey_or_lnurl)
                         else
                           pay_keysend(pubkey_or_lnurl)
                         end
          yield({ name: name, payment_states: result_array, amount: amount_per_recipient }) if block_given?
        end
      end

      def pay_keysend(pubkey)
        dest = Lnrpc.to_byte_array(pubkey)
        Bundler::Thankyou.lnd_client.keysend(dest: dest, amt: amount_per_recipient).to_a
      end

      def pay_lnurl(lnurl)
        lnurl = Lnurl.decode(lnurl)
        lnurl_response = lnurl.response
        invoice_response = lnurl_response.request_invoice(amount: amount_per_recipient_msat )
        if invoice_response.status.to_s.downcase == 'error'
          return [OpenStruct.new(status: 'ERROR', lnurl_response: invoice_response)] # ignore for now. returning an error similar to the response from send_payment_v2
        end
        invoice = Lightning::Invoice.parse(invoice_response.pr)
        if invoice_valid?(invoice: invoice, lnurl_response: lnurl_response)
          args = { payment_request: invoice_response.pr }
          args[:amt] = amount_per_recipient if invoice.amount.nil? # if the invoice does not specify an amount
          Bundler::Thankyou.lnd_client.pay(args).to_a
        else
          [OpenStruct.new(status: 'ERROR', message: 'invoice invalid')] # ignoring invalid invoices but keeping the method signature, returning an error similar to the response from send_payment_v2
        end
      end

      def invoice_valid?(invoice:, lnurl_response:)
        # invalid if the amount is too high
        return false if !invoice.amount.nil? && invoice_amount_in_satoshi(invoice) > amount_per_recipient
        # invalid if it is expired
        return false if Time.now.to_i > invoice.timestamp + (invoice.expiry || 3600).to_i

        # if the invoice does not specify an amount we check if the amount_per_recipient is within the sendable amount defined in the lnurl
        return false if invoice.amount.nil? && (amount_per_recipient_msat < lnurl_response.minSendable || amount_per_recipient_msat > lnurl_response.maxSendable)

        return true # default
      end

      def invoice_amount_in_satoshi(invoice)
        return if invoice.amount.nil?
        multi = {
          'm' => 0.001,
          'u' => 0.000001,
          'n' => 0.000000001,
          'p' => 0.000000000001
        }[invoice.multiplier]
        (invoice.amount * multi * 100000000).to_i # amount in bitcoin * 100000000
      end
    end
  end
end
