# == Schema Information
#
# Table name: shortened_urls
#
#  id        :bigint(8)        not null, primary key
#  long_url  :string           not null
#  short_url :string           not null
#  user_id   :integer          not null
#

require 'SecureRandom.rb'
class ShortenedUrl < ApplicationRecord 
  
  def self.create!(options) 
    options[:short_url] = ShortenedUrl.random_code
    new_entry = ShortenedUrl.new(options)
    new_entry.save
  end 
  
  def self.random_code
    random_code = SecureRandom.urlsafe_base64 
    until ShortenedUrl.exists?(short_url: random_code) == false  
      random_code = SecureRandom.urlsafe_base64 
    end 
    random_code
  end 
  
  def num_clicks
    Visit.where(shortened_url_id: @id).length
  end
  
  def num_uniques
    Visit.where(shortened_url_id: @id).map {|visit| visit.user_id}.uniq.length
  end
  
  def num_recent_uniques
    Visit.where(shortened_url_id: @id, created_at >: 10.minutes.ago).map {|visit| visit.user_id}.uniq.length
  end
  
  validates :user_id, :long_url, presence: true
  
  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: :User 
    
  has_many :visits,
    primary_key: :id,
    foreign_key: :shortened_url_id,
    class_name: :Visit
    
  has_many :visitors,
    through: :visits,
    source: :visitor
    
  
end 
