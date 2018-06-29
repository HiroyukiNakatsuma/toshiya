require 'line/bot'

class LinesController < ApplicationController
  before_action :set_line_client
  protect_from_forgery :except => [:message]

  FIRST_GREETING_WORDS = %w(よろしく よろしこ 宜しく 初めまして はじめまして)
  AMAZING_WORDS = %w(すごい すごすぎ すご過ぎ すげー すご！ すごー)
  LGTM_WORDS = %w(いいね いいと いいです いいでしょう いいかな いいよ いい感じ いいー いい。 いい！ いい？ 良いね 良いと 良いです 良いでしょう 良いかな 良いよ 良い感じ 良いー 良い。 良い！ 良い？)
  OKAY_WORDS = %w(おっけ おけ オッケ オケー ok OK)
  THANKS_WORDS = %w(ありがとう ありがた あざす あざっ あざます さんくす サンクス さんきゅ サンキュ せんきゅ センキュ)

  def message
    body = request.body.read

    if client.validate_signature(body, request.env['HTTP_X_LINE_SIGNATURE'])
      events = client.parse_events_from(body)

      events.each {|event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            if include_hook_word?(event.message['text'], FIRST_GREETING_WORDS)
              reply_message = LineReply::Message.first_greeting_reply_create
            elsif include_hook_word?(event.message['text'], AMAZING_WORDS)
              reply_message = LineReply::Message.amazing_reply_create
            elsif include_hook_word?(event.message['text'], LGTM_WORDS)
              reply_message = LineReply::Message.lgtm_reply_create
            elsif include_hook_word?(event.message['text'], OKAY_WORDS)
              reply_message = LineReply::Message.ok_reply_create
            elsif include_hook_word?(event.message['text'], THANKS_WORDS)
              reply_message = LineReply::Message.thanks_reply_create
            else
              return
            end
            Rails.logger.info "///////////////////////////////////////////////// #{client.get_profile(event.source['userId'])} /////////////////////////////////////////////////"
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

  def include_hook_word?(message_text, hook_words)
    hook_words.any? do |word|
      message_text.include?(word)
    end
  end
end
