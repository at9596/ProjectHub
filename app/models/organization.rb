class Organization < ApplicationRecord
  after_create :create_default_labels

  has_many :users, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :labels, dependent: :destroy

  validates :name, presence: true


  private

  def create_default_labels
    Label::DEFAULTS.each do |attrs|
      labels.create!(attrs)
    end
  end
end
