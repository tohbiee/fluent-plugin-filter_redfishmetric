require 'fluent/plugin/filter'

module Fluent::Plugin
  class RedfishMetricFilter < Filter
    # Register filter as "redfishmetric"
    Fluent::Plugin.register_filter('redfishmetric', self)

    # config_param for the plugins
    config_param :namespace, :string, :default => 'ColomanagerFluentdRedfish'
    config_param :coloregion, :string, :default => 'CentralusEUAP'
    config_param :metric, :array, :default => [], value_type: :string
	
    def configure(conf)
      super
      @metricValueList = []
	  end
	
    def filter_stream(tag, es)
      new_es = Fluent::MultiEventStream.new
      es.each { |time, record|
        @metricValueList = record["MetricValues"]
        @metricValueList&.each do |val|
          begin
            myRecord = {}
            myRecord["Namespace"] = @namespace
            myRecord["Metric"] = val["MetricId"]
            myRecord["Dimensions"] = {"Region" => @Coloregion, "Report"=>record["Id"],"IP" => record["REMOTE_ADDR"]}
            myRecord["Value"] = val["MetricValue"]
            if !@metric&.empty?
              if @metric&.include?(val["MetricId"])
                new_es.add(time, myRecord)
              end
            else
              new_es.add(time, myRecord)
            end
          rescue => e
          router.emit_error_event(tag, time, record, e)
          end
        end
      }
      new_es
    end
  end
end