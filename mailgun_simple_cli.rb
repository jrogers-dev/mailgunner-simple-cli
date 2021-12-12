#!/usr/bin/env ruby

#Require basic libraries for parsing command line arguments and JSON payload,
#and communicating with the Mailgun API
require 'optparse'
require 'json'
require 'restclient'

#Hash to hold command line arguments to utilize as flags 
args = {p: false}


#Attempt to parse JSON payload
def parse_payload(payload)
  begin
    parsed_payload = JSON.parse(payload, {:symbolize_names => true})
  rescue => e
    puts "Could not parse JSON payload"
    puts e.message
  else
    return parsed_payload
  end
end


#Check JSON payload to ensure it contains the three primary keys necessary 
#for Mailgun's API
def valid_payload?(payload)
  if payload.key?(:api_key) && payload.key?(:domain) && payload.key?(:from) && payload.key?(:to)\
    && payload.key?(:subject) && payload.key?(:body)
    return true
  else
    puts "Invalid payload: JSON Payload must include key/value pairs for \"to\", \"subject\", and \"body\""
    return false
  end
end


#Post processed payload to Mailgun API, which should successfully send an email
def deliver_payload(payload)
  begin
    RestClient.post(
      "https://api:#{payload[:api_key]}"\
      "@api.mailgun.net/v3/#{payload[:domain]}/messages",
      :from => payload[:from],
      :to => payload[:to],
      :subject => payload[:subject],
      :html => payload[:body]
    )
  rescue => e
    puts "Error posting payload to Mailgun API\n"
    puts e.message
  else
    puts "Successfully posted payload to Mailgun API"
  end
end

#Parse command line arguments using OptionParser and use the -p argument
#block to call all other functions
OptionParser.new do |parser|
  parser.on("-p", "--payload PAYLOAD", "A JSON payload encapsulated in single quotes containing 'to', 'subject', and 'body' key/value pairs at its root") do |payload|
    args[:p] = true
    parsed_payload = parse_payload(payload)
    if valid_payload?(parsed_payload) == true
      deliver_payload(parsed_payload)
    end
  end
end.parse!


#Exit the script gracefully
if args[:p] == false 
  puts "Exiting: No payload given. Execute script with '-p' argument and a valid JSON payload"
else
  puts "Exiting"
end