require 'line/bot'

class LinesController < ApplicationController

  def client
    @client ||= Line::Bot::Client.new {|config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def message
    body = request.body.read

    if client.validate_signature(body, request.env['HTTP_X_LINE_SIGNATURE'])
      events = client.parse_events_from(body)

      events.each {|event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            message = {
                type: 'text',
                text: event.message['text']
            }
            client.reply_message(event['replyToken'], message)
          end
        end
      }

      "OK"
    end
  else
    render status: 400, json: {status: 400, message: 'Bad Request'}
  end
end
