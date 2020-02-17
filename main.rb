Thread.abort_on_exception = true
Thread.new{ require "./webrick" }

require "net/http"
begin
  UNIVIS_HTTP = Net::HTTP.start "localhost", 8001
rescue Errno::ECONNREFUSED
  retry
end

UNIVIS_HTTP_mutex = Mutex.new
require "json"
def init type
  id = UNIVIS_HTTP_mutex.synchronize{ UNIVIS_HTTP.request(Net::HTTP::Head.new("http://localhost:8001/").tap{ |r| r["type"] = type }) }["id"][0]
  Struct.new(:id, :delete).new(id, lambda{ UNIVIS_HTTP.request Net::HTTP::Head.new("http://localhost:8001/").tap{ |r| r["id"] = id } }).tap do |s|
    s.define_singleton_method :method_missing do |*args|
      r = Net::HTTP::Post.new("http://localhost:8001/")
      r["id"] = id
      r.set_form_data args[0][0..-2] => JSON.dump(args[1])
      UNIVIS_HTTP_mutex.synchronize{ UNIVIS_HTTP.request r }
      s.define_singleton_method(args[0][0..-2]){ args[1] }
      args[1]
    end
  end
end
