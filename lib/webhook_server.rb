require 'codeship_api'
require 'process_webhook_job'
require 'sinatra/base'

class WebhookServer < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  get '/' do
    erb :homepage
  end

  post '/github' do
    request.body.rewind
    data = JSON.parse(request.body.read)

    unless data['deleted']
      ref = data['ref'].sub(/^refs\//, '')
      repo_url = data['repository']['html_url']
      commit_sha = data['head_commit']['id'] if data['head_commit']

      ProcessWebhookJob.perform_async(repo_url, ref, commit_sha)
    end

    [201, {'Content-Type' => 'application/json'}, {'status': 'OK'}.to_json]
  end

  template :layout do
    <<-EOF.gsub(/^        /, '')
      <!DOCTYPE html5 />
      <html>
      <body>
      <%= yield %>
      </body>
      </html>
    EOF
  end

  template :homepage do
    <<-EOF.gsub(/^        /, '')
      <h1>Hello!</h1>
    EOF
  end
end
