class UriColumn

  SHEMES = [:ssh, :git, :ftp, :http, :https, :irc]
  DEFAULT_MAXLEN = @maxlen = 255
  DEFAULT_SHEMES = @schemes = [:http, :https]
  DEFAULT_PING = @ping = false
  DEFAULT_EXIST = @exist = false
  DEFAULT_CONNECT = @connect = false
  
  def self.maxlen; @maxlen; end
  def self.schemes(); @schemes; end
  def self.ping; @ping; end
  def self.exists; @exists; end
  def self.connect; @connect; end
  def self.maxlen=(max); @maxlen = max; end
  def self.schemes=(schemes); @schemes = schemes; end
  def self.ping=(ping); @ping = ping; end
  def self.exists=(exists); @exists = exists; end
  def self.connect=(connect); @connect = connect; end
  
end
