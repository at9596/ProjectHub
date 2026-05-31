class Label < ApplicationRecord
  belongs_to :organization

  has_many :task_labels, dependent: :destroy
  has_many :tasks, through: :task_labels

  validates :name,
            presence: true,
            uniqueness: {
              scope: :organization_id,
              case_sensitive: false
            }

  validates :color,
            presence: true,
            format: {
              with: /\A#[0-9A-Fa-f]{6}\z/,
              message: "must be a valid hex color (e.g. #4f46e5)"
            }

  # Default palette for new organizations
  DEFAULTS = [
    { name: "Bug", color: "#ef4444" },
    { name: "Feature", color: "#8b5cf6" },
    { name: "Improvement", color: "#3b82f6" },
    { name: "Documentation", color: "#10b981" },
    { name: "Design", color: "#f59e0b" }
  ].freeze
end
