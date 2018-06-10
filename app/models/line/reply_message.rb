class ReplyMessage

  RANDOM_EMOJI = [
      "(^^)",
      "(^_^)",
      "(^-^)",
      "(*^^*)",
      "(^ ^)",
      "(^.^)"
  ]

  class << self
    def create(user_name)
      {
          type: 'text',
          text: "#{user_name}さん、よろしくお願いします#{random_emoji}"
      }
    end

    def random_emoji
      RANDOM_EMOJI[rand(6)]
    end
  end
end
