class LineReply::Message

  EMOJI = [
      "(^^)",
      "(^_^)",
      "(^-^)",
      "(*^^*)",
      "(^ ^)",
      "(^.^)",
      "！！"
  ]

  AMAZING = [
      "すげーっす！！",
      "まじすげーっす！！",
      "ほんとにすげーっす！！"
  ]

  LGTM = [
      "いいっすね！！",
      "まじいいっすね！！"
  ]

  class << self
    def create(reply_text)
      {
          type: 'text',
          text: reply_text
      }
    end

    def random_reply(random_texts)
      random_texts[rand(random_texts.length)]
    end

    def first_greeting_reply_create
      create("よろしくお願いします#{random_reply(EMOJI)}")
    end

    def amazing_reply_create
      create(random_reply(AMAZING))
    end

    def lgtm_reply_create
      create(random_reply(LGTM))
    end
  end
end
