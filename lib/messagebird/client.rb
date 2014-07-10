require 'json'
require 'net/https'
require 'uri'

require 'messagebird/balance'
require 'messagebird/error'
require 'messagebird/hlr'
require 'messagebird/message'
require 'messagebird/voicemessage'

module MessageBird
  class ErrorException < Exception
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end
  end

  class Client
    attr_reader :access_key

    def initialize(access_key)
      @access_key = access_key
    end

    def request(method, path, params={})
      uri = URI.join(ENDPOINT, '/', path)

      # Set up the HTTP object.
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = true

      # Construct the HTTP GET or POST request.
      request = Net::HTTP::Get.new(uri.request_uri)  if method == :get
      request = Net::HTTP::Post.new(uri.request_uri) if method == :post
      request['Accept']        = 'application/json'
      request['Authorization'] = "AccessKey #{@access_key}"
      request['User-Agent']    = "MessageBird/ApiClient/#{CLIENT_VERSION} Ruby/#{RUBY_VERSION}"

      # If present, add the HTTP POST parameters.
      request.set_form_data(params) if method == :post && !params.empty?

      # Execute the request and fetch the response.
      response = http.request(request)

      # Parse the HTTP response.
      case response.code.to_i
      when 200, 201, 204, 401, 404, 405, 422
        json = JSON.parse(response.body)
      else
        raise Net::HTTPServerError.new 'Unknown response from server', response
      end

      # If the request returned errors, create Error objects and raise.
      if json.has_key?('errors')
        raise ErrorException, json['errors'].map { |e| Error.new(e) }
      end

      json
    end

    # Retrieve your balance.
    def balance
      Balance.new(request(:get, 'balance'))
    end

    # Retrieve the information of specific HLR.
    def hlr(id)
      HLR.new(request(:get, "hlr/#{id.to_s}"))
    end

    # Create a new HLR.
    def hlr_create(msisdn, reference)
      HLR.new(request(
        :post,
        'hlr',
        :msisdn    => msisdn,
        :reference => reference))
    end

    # Retrieve the information of specific message.
    def message(id)
      Message.new(request(:get, "messages/#{id.to_s}"))
    end

    # Create a new message.
    def message_create(originator, recipients, body, params={})
      # Convert an array of recipients to a comma-separated string.
      recipients = recipients.join(',') if recipients.kind_of?(Array)

      Message.new(request(
        :post,
        'messages',
        params.merge({
          :originator => originator.to_s,
          :body       => body.to_s,
          :recipients => recipients })))
    end

    # Retrieve the information of a specific voice message.
    def voice_message(id)
      VoiceMessage.new(request(:get, "voicemessages/#{id.to_s}"))
    end

    # Create a new voice message.
    def voice_message_create(recipients, body, params={})
      # Convert an array of recipients to a comma-separated string.
      recipients = recipients.join(',') if recipients.kind_of?(Array)

      VoiceMessage.new(request(
        :post,
        'voicemessages',
        params.merge({ :recipients => recipients, :body => body.to_s })))
    end
  end
end