#!/usr/bin/env ruby
# frozen_string_literal: true

require "webrick"
require "net/http"
require "json"
require_relative "../app/api"

api = EraZeroApp::API.new
public_root = File.join(EraZeroValidation::ROOT, "app/public")
server = WEBrick::HTTPServer.new(Port: 0, BindAddress: "127.0.0.1", DocumentRoot: public_root, AccessLog: [], Logger: WEBrick::Log.new(File::NULL))
server.mount_proc("/api") do |request, response|
  result = api.dispatch(request.request_method, request.path, request.body.to_s)
  response.status = result.status
  result.headers.each { |key, value| response[key] = value }
  response.body = result.body
end
thread = Thread.new { server.start }
begin
  port = server.listeners.first.addr[1]
  base = URI("http://127.0.0.1:#{port}")
  health = Net::HTTP.get_response(URI("#{base}/api/health"))
  raise "health failed" unless health.code == "200" && JSON.parse(health.body)["status"] == "ok"
  index = Net::HTTP.get_response(URI("#{base}/"))
  raise "index failed" unless index.code == "200" && index.body.include?("Era Zero Translator Workbench")
  request = Net::HTTP::Post.new("/api/analyze", { "Content-Type" => "application/json" })
  request.body = JSON.generate("input" => "leave [1]")
  analysis = Net::HTTP.start("127.0.0.1", port) { |http| http.request(request) }
  data = JSON.parse(analysis.body)
  raise "analysis failed" unless analysis.code == "200" && data.dig("decision", "auto_resolution_allowed") == true && data.dig("translation", "round_trip_equal") == true
  puts "Product HTTP smoke: PASS (static UI, health, analyze, exact round trip)"
ensure
  server.shutdown
  thread.join(5)
end
