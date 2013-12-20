class Upload < ActiveRecord::Base
  attr_accessible :image
  has_attached_file :image
  # styles: { thumb1: "50X50>", thumb2: "70X70>", thumb3: "80X80", thumb4: "60X60" }
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  validates :image, presence: true
  
  after_update :reprocess_image, if: :cropping?

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  private

  def reprocess_image
    image.reprocess!
  end
end
