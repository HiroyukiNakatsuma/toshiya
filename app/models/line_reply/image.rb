class Image

  GIVE_UP_IMAGE_PATH = '/assets/lines/reply_images/give_up_1024_1024.jpg'
  GIVE_UP_SMALL_IMAGE_PATH = '/assets/lines/reply_images/give_up_240_240.jpg'

  class << self
    def create(original_image_url, preview_image_url)
      {
          type: 'image',
          originalContentUrl: original_image_url,
          previewImageUrl: preview_image_url
      }
    end

    def give_up_reply_create
      create(GIVE_UP_IMAGE_PATH, GIVE_UP_SMALL_IMAGE_PATH)
    end
  end
end
