class Que < ActiveRecord::Base
  validates :name, presence: true
  validates :email, presence: true
  has_attached_file :image
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  before_create :send_que_email

  def send_que_email
    QueMailer.new_que_email(self).deliver
  end

  # What this is saying:
  # Let's find all of the names that contain ?
  # scope :funk_names, -> { where("name like ?", "%Funk%") }

  scope :search_names, -> search { where( "name like ?", "%#{search}%") }

  # Que.all.search_names("Adolf")

  # @hospital = Hospital.find 
  # @patients = hospital.patients
  # @patients.search_names("Adolf")

  # def self.search_names(search)
  #   where("name like ?", "%#{search}%")
  # end

  def display_name
    "Mr. #{name}"

  include Workflow
  workflow do
    state :new do
      event :nick_visit, transitions_to: :in_progress
    end
    state :in_progress do
      event :nick_tried_helping, transitions_to: :still_confused
    end
    state :still_confused do
      event :nick_visit, transitions_to: :in_progress
    end
    state :completed
  end
end
