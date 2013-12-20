class Upload < ActiveRecord::Base
  attr_accessible :image
  has_attached_file :image
  RESIZE_THUMBNAILS = { thumb1: "30X30", thumb2: "60X60", thumb3: "90X90", thumb4: "120X120" }
  
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  attr_accessible :crop_x, :crop_y, :crop_w, :crop_h

  validates :image, presence: true
  
  after_update :reprocess_image, if: :cropping?

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def generate_thumbnails
    conn = Bunny.new(:automatically_recover => false)
    conn.start
    resize_channel = conn.create_channel
    image_queue    = resize_channel.queue("image_cropper")
    resize_channel.default_exchange.publish(resize_data.to_yaml, :routing_key => image_queue.name)
    puts " [x] Sent Image For Resizing"
  end

  private

  def crop_data
    {
      path: "#{image.path}",
      height: "#{crop_h}",
      width: "#{crop_w}",
      crop_x: "#{crop_x}",
      crop_y: "#{crop_y}",
      type: "crop"
    }
  end

  def resize_data
    {
      path: "#{image.path}",
      styles: Upload::RESIZE_THUMBNAILS,
      type: "resize"
    }
  end

  def reprocess_image
    conn = Bunny.new(:automatically_recover => false)
    conn.start
    ch   = conn.create_channel
    image_queue    = ch.queue("image_cropper")
    ch.default_exchange.publish(crop_data.to_yaml, :routing_key => image_queue.name)
    puts " [x] Sent Image description"
    wait_for_reprocess(conn, ch)
  end

  def wait_for_reprocess(conn, ch)
    path_queue   = ch.queue('image_path')
    begin
    puts " [*] Waiting for messages. To exit press CTRL+C"
    path_queue.subscribe(:block => true) do |delivery_info, properties, body|
      puts " [x] Received file path - #{body}"
      conn.close
    end
  rescue Interrupt => _
    conn.close
    exit(0)
  end
  conn.close
  end
end