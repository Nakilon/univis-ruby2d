require "net/http"
restart = lambda do
  UNIVIS_HTTP = begin
    Net::HTTP.start "localhost", 8001, open_timeout: 1
  rescue Errno::ECONNREFUSED, Net::OpenTimeout
    retry
  end
end.tap &:call

require "ruby2d"
set title: "Universal Visualiser"

UNIVIS = {}

require "json"
update do
  next unless t = catch(:_) do
    JSON.load begin
      UNIVIS_HTTP.request Net::HTTP::Get.new "http://localhost:8001/"
    rescue Errno::ECONNREFUSED
      throw :_
    end.body
  end
  t.each do |e|
    next UNIVIS.fetch(e.to_i).remove if e.is_a? String
    id, params = e[0].to_i, e[1]
    case params
    when "text"
      UNIVIS[id] = Text.new ""
      next
    when "circle"
      UNIVIS[id] = Circle.new
      next
    end
    params.each{ |k, v| UNIVIS.fetch(id).method(k + ?=).call JSON.load v }
  end
end

show

