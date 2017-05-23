#! /usr/bin/env ruby
#
#   check-es-cluster-health
#
# DESCRIPTION:
#   This plugin checks the ElasticSearch cluster health and status.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: elasticsearch
#
# USAGE:
#   Checks against the ElasticSearch api for cluster health using the
#     elasticsearch gem
#
# NOTES:
#
# LICENSE:
#   Brendan Gibat <brendan.gibat@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'elasticsearch'
require 'sensu-plugins-elasticsearch'

#
# ES Cluster Health
#
class ESClusterHealth < Sensu::Plugin::Check::CLI
  include ElasticsearchCommon

  option :host,
         description: 'Elasticsearch host',
         short: '-h HOST',
         long: '--host HOST'

  option :level,
         description: 'Level of detail to check returend information ("cluster", "indices", "shards").',
         short: '-l LEVEL',
         long: '--level LEVEL'

  option :local,
         description: 'Return local information, do not retrieve the state from master node.',
         long: '--local',
         boolean: true

  option :port,
         description: 'Elasticsearch port',
         short: '-p PORT',
         long: '--port PORT',
         proc: proc(&:to_i),
         default: 9200

  option :scheme,
         description: 'Elasticsearch connection scheme, defaults to https for authenticated connections',
         short: '-s SCHEME',
         long: '--scheme SCHEME'

  option :password,
         description: 'Elasticsearch connection password',
         short: '-P PASSWORD',
         long: '--password PASSWORD'

  option :user,
         description: 'Elasticsearch connection user',
         short: '-u USER',
         long: '--user USER'

  option :timeout,
         description: 'Elasticsearch query timeout in seconds',
         short: '-t TIMEOUT',
         long: '--timeout TIMEOUT',
         proc: proc(&:to_i),
         default: 30

  def run
    options = {}
    unless config[:level].nil?
      options[:level] = config[:level]
    end
    unless config[:local].nil?
      options[:local] = config[:local]
    end
    unless config[:index].nil?
      options[:index] = config[:index]
    end
    health = client.cluster.health options
    case health['status']
    when 'yellow'
      warning 'Cluster state is Yellow'
    when 'red'
      critical 'Cluster state is Red'
    when 'green'
      ok
    else
      unknown "Cluster state is in an unknown health: #{health['status']}"
    end
  end
end
