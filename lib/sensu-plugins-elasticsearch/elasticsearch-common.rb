#
# DESCRIPTION:
#   Common helper methods
#
# DEPENDENCIES:
#   gem: elasticsearch
#   gem: sensu-plugin
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Brendan Gibat <brendan.gibat@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require_relative 'elasticsearch-query.rb'

module ElasticsearchCommon
  include ElasticsearchQuery
  def initialize
    super()
  end

  def client
    transport_class = if config[:transport] == 'AWS'
                        Elasticsearch::Transport::Transport::HTTP::AWS
                      else
                        Elasticsearch::Transport::Client::DEFAULT_TRANSPORT_CLASS
                      end
    url = ENV.fetch('ELASTICSEARCH_URL', nil)

    if url.nil?
      host = {
        host:               config[:host],
        port:               config[:port],
        request_timeout:    config[:timeout],
        scheme:             config[:scheme]
      }

      if !config[:user].nil? && !config[:password].nil?
        host[:user] = config[:user]
        host[:password] = config[:password]
        host[:scheme] = 'https' unless config[:scheme]
      end

      @client ||= Elasticsearch::Client.new(transport_class: transport_class, hosts: [host], region: config[:region])
    else
      @client ||= Elasticsearch::Client.new(transport_class: transport_class, url: url, region: config[:region])
    end
  end
end
