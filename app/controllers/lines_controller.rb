require 'line/bot'
require 'google/apis'

class LinesController < ApplicationController
  before_action :set_line_client
  protect_from_forgery :except => [:message]

  FIRST_GREETING_WORDS = %w(よろしく よろしこ 宜しく 初めまして はじめまして)
  AMAZING_WORDS = %w(すごい すごすぎ すご過ぎ すげー すご！ すごー)
  LGTM_WORDS = %w(いいね いいと いいです いいでしょう いいかな いいよ いい感じ いいー いい。 いい！ いい？ 良いね 良いと 良いです 良いでしょう 良いかな 良いよ 良い感じ 良いー 良い。 良い！ 良い？)
  OKAY_WORDS = %w(おっけ おけ オッケ オケー ok OK)
  THANKS_WORDS = %w(ありがとう ありがた あざす あざっ あざます さんくす サンクス さんきゅ サンキュ せんきゅ センキュ)
  GIVE_UP_WORDS = %w(あきらめ 諦め 無理 ムリ 不可能)
  TOSHIYA_WORDS = %w(としや toshiya TOSHIYA)
  SEARCH_YOUTUBE_WORDS = %w(おすすめの曲 オススメの曲)

  DEVELOPER_KEY = ENV["GOOGLE_API_KEY"]
  YOUTUBE_API_SERVICE_NAME = 'youtube'
  YOUTUBE_API_VERSION = 'v3'

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
              reply_message = LineReply::Message.first_greeting_reply_create(
                  posted_user_name(
                      event['source']['groupId'],
                      event['source']['roomId'],
                      event['source']['userId']
                  ))
            elsif include_hook_word?(event.message['text'], AMAZING_WORDS)
              reply_message = LineReply::Message.amazing_reply_create
            elsif include_hook_word?(event.message['text'], LGTM_WORDS)
              reply_message = LineReply::Message.lgtm_reply_create
            elsif include_hook_word?(event.message['text'], OKAY_WORDS)
              reply_message = LineReply::Message.ok_reply_create
            elsif include_hook_word?(event.message['text'], THANKS_WORDS)
              reply_message = LineReply::Message.thanks_reply_create
            elsif include_hook_word?(event.message['text'], TOSHIYA_WORDS)
              reply_message = LineReply::Message.toshiya_reply_create
            elsif include_hook_word?(event.message['text'], GIVE_UP_WORDS)
              reply_message = LineReply::Image.give_up_reply_create
            elsif include_hook_word?(event.message['text'], SEARCH_YOUTUBE_WORDS)
              urls = search_youtube_and_return_urls
              return if urls.blank?
              reply_message = urls[0]
            else
              return
            end
            client.reply_message(event['replyToken'], reply_message)
          end
        end
      }

      Rails.logger.info "OK"
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

  def posted_user_name(group_id = nil, room_id = nil, user_id)
    if group_id.present?
      profile = client.get_group_member_profile(group_id, user_id)
    elsif room_id.present?
      profile = client.get_room_member_profile(room_id, user_id)
    else
      profile = client.get_profile(user_id)
    end

    display_name = ''

    case profile
    when Net::HTTPSuccess then
      display_name = JSON.parse(profile.body)['displayName']
    else
      Rails.logger.info "#{response.code} #{response.body}"
    end

    display_name
  end

  def get_service
    client = Google::APIClient.new(
        :key => DEVELOPER_KEY,
        :authorization => nil,
        :application_name => 'toshiya',
        :application_version => '1.0.3'
    )
    youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)

    return client, youtube
  end

  def search_youtube_and_return_urls
    client, youtube = get_service

    begin
      search_response = client.execute!(
          :api_method => youtube.search.list,
          :parameters => {
              :part => 'snippet',
              :q => 'acappella',
              :maxResults => 1,
              :type => 'video'
          }
      )

      video_urls = []

      search_response.data.items.each do |search_result|
        case search_result.id.kind
        when 'youtube#video'
          video_urls << "https://www.youtube.com/watch?v=#{search_result.id.videoId}"
        end
      end
    end

    Rails.logger.info "Video URLs: #{video_urls}"
    return video_urls
  rescue Google::APIClient::TransmissionError => e
    Rails.logger.info e.result.body
  end
end
