id = 0
buffer = []

require "webrick"
server = WEBrick::HTTPServer.new Port: 8001, Logger: WEBrick::Log.new("/dev/null"), AccessLog: []
server.mount_proc "/" do |req, res|
  case req.request_method
  when "HEAD"
    if req["id"]
      buffer.push << req["id"]
    else  # webrick can't DELETE, see https://stackoverflow.com/q/4996170/322020
      res["id"] = id += 1
      buffer.push << [id.to_s, req["type"]]
    end
  when "GET"
    require "json"
    res.body = JSON.dump buffer
    buffer.clear
  when "POST"
    buffer.push << [req["id"], req.query]
  end
end
server.start
