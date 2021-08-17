require 'fluent/plugin/filter'

module Fluent::Plugin
  class RedfishMetricFilter < Filter
    # Register filter as 'redfishmetric'
    Fluent::Plugin.register_filter('redfishmetric', self)

    # config_param for the plugins
    config_param :namespace, :string, :default => 'DellMetricReports'
	
    def configure(conf)
      super
        @metrics = []
      end
	  	
	
    def filter_stream(tag, es)
      new_es = Fluent::MultiEventStream.new
      es.each { |time, record|

        @metrics = record['MetricValues']
        @metrics&.each do |key, val|
          begin
            myRecord = {}
            myRecord['Namespace'] = @namespace
            myRecord['Metric'] = val['Oem']['Dell']['FQDD'] + ' ' + val['MetricId']
            myRecord['Dimensions'] = {'BaremetalMachineID' => record['machineID'], 'Report'=>record['Id']}
            myRecord['Value'] = val['MetricValue']
            new_es.add(time, myRecord)
          rescue => e
          router.emit_error_event(tag, time, record, e)
          end
        end
      }
      new_es
    end
  end
end