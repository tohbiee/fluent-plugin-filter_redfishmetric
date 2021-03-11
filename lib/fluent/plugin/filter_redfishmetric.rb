require 'fluent/plugin/filter'

module Fluent::Plugin
  class RedfishMetricFilter < Filter
    # Register this filter as "redfishmetric"
    Fluent::Plugin.register_filter('redfishmetric', self)

    # config_param works like other plugins

    def configure(conf)
      super
      # Do the usual configuration here
    end

    # def start
    #   super
    #   # Override this method if anything needed as startup.
    # end

    # def shutdown
    #   # Override this method to use it to free up resources, etc.
    #   super
    # end

    def customredfishmetricfilter(record)
      metricValueList = record["MetricValues"]
      res = []
      metricValueList.each do |val|
          myRecord = {}
          myRecord["Namespace"] = "ColomanagerFluentdRedfish"
          myRecord["Metric"] = val["MetricValue"]
          label = val["Oem"]["Dell"]["Label"]
          myRecord["Value"] = label.delete(val["MetricId"]).strip()
          myRecord["Report"] = record["Id"]
          myRecord["Dimension"] = {"Region" => "CentralusEUAP", "IP" => record["REMOTE_ADDR"]}
          res << myRecord
      end
      res
  end

    def filter(tag, time, record)
        customredfishmetricfilter(record)
    end
  end
end