class Widget::Card < ApplicationRecord
  include Imageable
  belongs_to :cardable, polymorphic: true

  translates :label,       touch: true
  translates :title,       touch: true
  translates :description, touch: true
  translates :link_text,   touch: true
  include Globalizable

  validates_translation :title, presence: true
  validates :link_url, presence: true, if: -> { !header? || link_text.present? }
  validates :order, numericality: { greater_than_or_equal_to: 1 }

  def self.header
    where(header: true)
  end

  def self.body
    where(header: false, cardable_id: nil).order(:created_at)
  end

  def header_or_sdg_header?
    header? || sdg_header?
  end

  def sdg_header?
    cardable == WebSection.find_by!(name: "sdg")
  end
end
