require 'fluent/plugin/filter'

module Fluent::Plugin
  class RedfishMetricFilter < Filter
    # Register this filter as "redfishmetric"
    Fluent::Plugin.register_filter('redfishmetric', self)

    # config_param works like other plugins
    config_param :Namespace, :string, :default => 'ColomanagerFluentdRedfish'
    config_param :Coloregion, :string, :default => 'CentralusEUAP'
    config_param :Filter, :bool, :default => false
    config_param :Metric, :Set, :default => {"TemperatureReading", "CompositeTemparature", "CriticalWarning", "Temperature", "DriveTemperature", "CRCErrorCount", "UncorrectableErrorCount", "PercentDriveLifeRemaining"}

    def configure(conf)
      super
      @metricValueList = []
      # Do the usual configuration here
    end

    def customredfishmetricfilter(tag, time, record)
      @metricValueList = record["MetricValues"]
      res = []
      @metricValueList.each do |val|
          myRecord = {}
          myRecord["Namespace"] = @Namespace
		      myRecord["Report"] = record["Id"]
          label = val["Oem"]["Dell"]["Label"]
          myRecord["Metric"] = label.delete(val["MetricId"]).strip()
          myRecord["Value"] = val["MetricValue"]
          myRecord["Dimension"] = {"Region" => @Coloregion, "IP" => record["REMOTE_ADDR"]}
		      if Filter
	            if Metric.include?(myRecord["Metric"])
			          res.add(tag, time, myRecord)
		      else
              res.add(tag, time, myRecord)
          end
        
      end
      route.emit(res)
    end

    def filter(tag, time, record)
        customredfishmetricfilter(tag, time, record)
    end
  end
end