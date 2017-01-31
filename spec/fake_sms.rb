class FakeSMS
  Message = Struct.new(:from, :to, :body)

  cattr_accessor :messages
  self.messages = []

  def initialize(_account_sid, _auth_token)
  end

  def messages
    self
  end

  def create(options = {})
    self.class.messages << Message.new(options[:from], options[:to], options[:body])
  end
end
