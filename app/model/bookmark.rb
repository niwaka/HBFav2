# -*- coding: utf-8 -*-
class Bookmark
  attr_reader :title, :profile_image_url, :link, :user_name, :created_at, :comment, :user, :count, :datetime, :thumbnail_url, :category, :description

  def self.new_from_data(entry, bookmark)
    Bookmark.new(
      {
        :eid   => entry['eid'],
        :title => entry['title'] || '',
        :link  => entry['url'],
        :count => entry['count'],
        :eid   => entry['eid'],
        :user => {
          :name => bookmark['user']
        },
        :comment    => bookmark['comment'] || '',
        :created_at => bookmark['timestamp'],
        # 2005/02/10 20:55:55 => 2005-02-10T20:55:55+09:00
        :datetime   =>  bookmark['timestamp'].gsub(/\//, '-').gsub(/ /, 'T') + '+09:00'
      }
    )
  end

  def self.date_formatter
    @@date_formatter ||= NSDateFormatter.alloc.initWithGregorianCalendar.tap do |f|
      f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
    end
  end

  def initialize(dict)
    @eid          = dict[:eid]
    @title        = dict[:title]
    @link         = dict[:link]
    @created_at   = dict[:created_at]
    @comment      = dict[:comment]
    @permalink    = dict[:permalink]
    @thumbnail_url = dict[:thumbnail_url]
    @category     = dict[:category]
    @description  = dict[:description]
    if @description
      @description = @description.gsub(/^\s+$/, "")
    end

    unless dict[:count].nil?
      @count = Count.new(dict[:count].to_i)
    end

    if dict[:user]
      @user              = User.new({:name => dict[:user][:name]})
      @user_name         = dict[:user][:name]
      @profile_image_url = dict[:user][:profile_image_url]
    end

    if dict[:datetime]
      @datetime = self.class.date_formatter.dateFromString(dict[:datetime])
    end
  end

  def id
    @id ||= self.permalink
  end

  def permalink
    if @permalink.present?
      return @permalink
    else
      formatter = NSDateFormatter.new
      formatter.dateFormat = "yyyyMMdd"
      yyyymmdd = formatter.stringFromDate(self.datetime)
      @permalink = "http://b.hatena.ne.jp/#{@user_name}/#{yyyymmdd}#bookmark-#{@eid}"
    end
  end

  def favicon_url
    return "http://favicon.st-hatena.com/?url=#{@link}"
  end

  # def dealloc
  #  NSLog("dealloc: " + self.class.name)
  #  super
  # end
end
