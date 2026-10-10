#!/usr/bin/env ruby
# frozen_string_literal: true

require "webrick"
require "json"
require_relative "api"

# Serve the same generated browser release that is published to GitHub Pages.
# `app/public` remains the source template used by tools/build_pages_release.rb;
# serving `pages` here prevents the local workbench from drifting from the
# audited public interface.
root = File.expand_path("../pages", __dir__)
port = Integer(ENV.fetch("ERA_ZERO_PORT", "8787"))
bind = ENV.fetch("ERA_ZERO_BIND", "127.0.0.1")
api = EraZeroApp::API.new
server = WEBrick::HTTPServer.new(Port: port, BindAddress: bind, DocumentRoot: root, AccessLog: [], Logger: WEBrick::Log.new($stderr, WEBrick::Log::WARN))
server.mount_proc("/api") do |request, response|
  result = api.dispatch(request.request_method, request.path, request.body.to_s)
  response.status = result.status
  result.headers.each { |key, value| response[key] = value }
  response.body = result.body
end
trap("INT") { server.shutdown }
trap("TERM") { server.shutdown }
puts "Era Zero Translator Workbench: http://#{bind}:#{port}"
server.start
