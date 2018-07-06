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
      "まじいいっすね！！",
      "最高っすね！！"
  ]

  OK = [
      "オッケーです！！",
      "おっけーです！！",
      "オッケーです(^^)",
      "おっけーです(^^)"
  ]

  THANKS = [
      "あざます！！",
      "あざます(^^)",
      "ありがとうございます！！",
      "ありがとうございます(≧▽≦)"
  ]

  TOSHIYA = [
      "はい！",
      "はい、なんでしょう？",
      "僕のことですか？",
      "呼びました？"
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

    def first_greeting_reply_create(user_name)
      create("#{user_name}さん、よろしくお願いします#{random_reply(EMOJI)}")
    end

    def amazing_reply_create
      create(random_reply(AMAZING))
    end

    def lgtm_reply_create
      create(random_reply(LGTM))
    end

    def ok_reply_create
      create(random_reply(OK))
    end

    def thanks_reply_create
      create(random_reply(THANKS))
    end

    def toshiya_reply_create
      create(random_reply(TOSHIYA))
    end
  end
end
