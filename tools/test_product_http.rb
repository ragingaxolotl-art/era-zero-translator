#!/usr/bin/env ruby
# frozen_string_literal: true

require "webrick"
require "net/http"
require "json"
require_relative "../app/api"

api = EraZeroApp::API.new
public_root = File.join(EraZeroValidation::ROOT, "pages")
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
  raise "index failed" unless index.code == "200" && index.body.include?("Era Zero Translator Workbench") && index.body.include?("v1.15.0") && index.body.include?('data-app-tab="conversation"') && index.body.include?('id="conversationScript"') && index.body.include?('id="lorePresetKey"') && index.body.include?('id="lorePresetDetail"') && index.body.include?('data-app-tab="dictionary"') && index.body.include?('data-app-tab="documents"') && index.body.include?('data-rig-layer="head"') && index.body.include?('data-rig-layer="eyes"') && index.body.include?('data-rig-layer="mouth"') && index.body.include?('id="soundVoice"') && index.body.include?('id="soundMode"') && index.body.include?('id="catalogJump"') && index.body.include?('id="conceptInput"') && index.body.include?('id="selfCheckAudio"') && index.body.include?('id="conceptQueue"')
  documents = Net::HTTP.get_response(URI("#{base}/data/documents.json"))
  raise "document manifest failed" unless documents.code == "200" && JSON.parse(documents.body)["count"] >= 300
  request = Net::HTTP::Post.new("/api/analyze", { "Content-Type" => "application/json" })
  request.body = JSON.generate("input" => "leave [1]")
  analysis = Net::HTTP.start("127.0.0.1", port) { |http| http.request(request) }
  data = JSON.parse(analysis.body)
  raise "analysis failed" unless analysis.code == "200" && data.dig("decision", "auto_resolution_allowed") == true && data.dig("translation", "round_trip_equal") == true
  puts "Product HTTP smoke: PASS (v1.15.0 recognition performance decoding, meaning-rich dictionary, persistent concept review, complete plain-English matching, conversations, selectable voices, layered character rig, health, analyze, exact round trip)"
ensure
  server.shutdown
  thread.join(5)
end
