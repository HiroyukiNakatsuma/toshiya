class Message

  RANDOM_EMOJI = [
      "(^^)",
      "(^_^)",
      "(^-^)",
      "(*^^*)",
      "(^ ^)",
      "(^.^)",
      "！！"
  ]

  class << self
    def create!
      {
          type: 'text',
          text: "よろしくお願いします#{random_emoji}"
      }
    end

    def random_emoji
      RANDOM_EMOJI[rand(RANDOM_EMOJI.length)]
    end
  end
end
