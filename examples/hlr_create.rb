#!/usr/bin/env ruby

$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib/')
require 'messagebird'

ACCESS_KEY = 'test_gshuPaZoeEG6ovbc8M79w0QyM'

begin
  # Create a MessageBird client with the specified ACCESS_KEY.
  client = MessageBird::Client.new(ACCESS_KEY)

  # Create a new HLR object.
  hlr = client.hlr_create('31612345678', 'MyReference')

  # Print the object information.
  puts
  puts "The following information was returned as an HLR object:"
  puts
  puts "  id              : #{hlr.id}"
  puts "  href            : #{hlr.href}"
  puts "  msisdn          : #{hlr.msisdn}"
  puts "  reference       : #{hlr.reference}"
  puts "  status          : #{hlr.status}"
  puts "  createdDatetime : #{hlr.createdDatetime}"
  puts "  statusDatetime  : #{hlr.statusDatetime}"
  puts

rescue MessageBird::ErrorException => ex
  puts
  puts 'An error occured while requesting an HLR object:'
  puts

  ex.errors.each do |error|
    puts "  code        : #{error.code}"
    puts "  description : #{error.description}"
    puts "  parameter   : #{error.parameter}"
    puts
  end
end
