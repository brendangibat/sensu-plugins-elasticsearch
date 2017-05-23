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
    if !config[:host].nil?
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
      @client ||= Elasticsearch::Client.new(hosts: [host], region: config[:region])
    else
      url = ENV.fetch('ELASTICSEARCH_URL', 'localhost')
      @client ||= Elasticsearch::Client.new(url: url, region: config[:region])
    end
  end
end
