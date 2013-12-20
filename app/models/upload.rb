class Upload < ActiveRecord::Base
  attr_accessible :image
  has_attached_file :image
  # styles: { thumb1: "50X50>", thumb2: "70X70>", thumb3: "80X80", thumb4: "60X60" }
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  attr_accessible :crop_x, :crop_y, :crop_w, :crop_h

  validates :image, presence: true
  
  after_update :reprocess_image, if: :cropping?

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  private

  def crop_data
    {
      path: "#{image.path}",
      height: "#{crop_h}",
      width: "#{crop_w}",
      crop_x: "#{crop_x}",
      crop_y: "#{crop_y}"
    }
  end

  def reprocess_image
    conn = Bunny.new(:automatically_recover => false)
    conn.start
    ch   = conn.create_channel
    image_queue    = ch.queue("image_cropper")
    # q2   = ch.queue('image_cropper')

    ch.default_exchange.publish(crop_data.to_yaml, :routing_key => image_queue.name)
    puts " [x] Sent Image description"

  end
end
