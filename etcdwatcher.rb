require 'em-http-request'

class EtcdWatcher

  def initialize(url)
    @url = url
    listen
  end

  def onchange(&action_block)
    @action_block = action_block
  end

  def listen

    http = EM::HttpRequest.new(@url, :inactivity_timeout => 0).get({
      :query => { "wait" => "true",
                  "recursive" => "true" }
    })

    http.errback { p http.error; EM.stop }

    http.callback {
      @action_block.call http.response
      listen
    }

  end

end
