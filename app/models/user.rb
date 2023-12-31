class User < ApplicationRecord
  extend FriendlyId
  friendly_id :email, use: :slugged
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates_uniqueness_of :email, case_sensitive: false
  has_many :courses
  after_create :assign_default_role
  validate :must_have_a_role, on: :update

  def assign_default_role
    if User.count == 1
      self.add_role(:admin) if self.roles.blank?
      self.add_role(:teacher)
      self.add_role(:student)
    else
      self.add_role(:teacher) if self.roles.blank?
      self.add_role(:student)
    end
  end

  def to_s
    email
  end

  def username
    email.split(/@/).first
  end

  def online?
    updated_at > 2.minutes.ago
  end

  private
  def must_have_a_role
    unless roles.any?
      errors.add(:roles, "must have at least one role")
    end
  end
end
