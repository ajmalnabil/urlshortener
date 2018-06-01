class Link < ApplicationRecord
  # multiple level validation to check link provided is valid original URL -- one here in Model using regex
  VALID_URL_REGEX = /\A(?:(?:http|https):\/\/)?([-a-zA-Z0-9.]{2,256}\.[a-z]{2,4})\b(?:\/[-a-zA-Z0-9@,!:%_\+.~#?&\/\/=]*)?\z/
  validates :original_url, presence: true, format: { with: VALID_URL_REGEX }, uniqueness: true
  before_create :create_short_url
  before_create :clean_up_url

  # For hashing algorithm, after doing some research, I choose urlsafe_base64.
  # I considered using MD5 or SHA1 (with truncation of first 6 characters) and even used SecureRandom.hex(3) previously,
  # but prefer the 1/(26+26+10+2)^6 chances.
  def create_short_url
    urlstring = SecureRandom.urlsafe_base64(4.5)
    old_url = Link.where(short_url: urlstring).last
    if old_url.present?
      self.create_short_url
    else
      self.short_url = urlstring
    end
  end

  # Cleaning up the original URL to include http://. if the input does not include one. I use module URI and check "http" using scheme as per below.
  def clean_up_url
    self.original_url.strip!
    stripped_url = URI(self.original_url)
    if stripped_url.scheme.nil?
      self.clean_url = "http://#{self.original_url}"
    elsif stripped_url.scheme == "https"
      self.clean_url = self.original_url.gsub(/(https?:\/\/)/,"")
      self.clean_url = "http://#{self.clean_url}"
    else
      self.clean_url = self.original_url
    end
  end

  # As validation only check the original URL uniqueness, I want to check if clean URL is unique too before saving it in DB.
  # Use case: www.google.com and http://www.google.com to be considered as the same URL.
  # Additionally, I am using url_field in View, so users need to include http:// before submitting any link.
  def find_duplicate_url
    Link.find_by_clean_url(self.clean_url)
  end

  def new_url?
    find_duplicate_url.nil?
  end

end
