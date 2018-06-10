require 'line/bot'

class LinesController < ApplicationController
  before_action :set_line_client
  protect_from_forgery :except => [:message]

  def message
    body = request.body.read

    if client.validate_signature(body, request.env['HTTP_X_LINE_SIGNATURE'])
      events = client.parse_events_from(body)

      events.each {|event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            reply_message = Line::ReplyMessage.create("User Name")
            client.reply_message(event['replyToken'], reply_message)
          end
        end
      }

      "OK"
    else
      render status: 400, json: {status: 400, message: 'Bad Request'}
    end
  end

  private

  def set_line_client
    client
  end

  def client
    @client ||= Line::Bot::Client.new {|config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
