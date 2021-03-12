require 'fluent/plugin/filter'

module Fluent::Plugin
  class RedfishMetricFilter < Filter
    # Register this filter as "redfishmetric"
    Fluent::Plugin.register_filter('redfishmetric', self)

    # config_param works like other plugins

    def configure(conf)
      super
      @metricValueList = []
      # Do the usual configuration here
    end

    def customredfishmetricfilter(record)
      @metricValueList = record["MetricValues"]
      res = []
      @metricValueList.each do |val|
          myRecord = {}
          myRecord["Namespace"] = "ColomanagerFluentdRedfish"
          label = val["Oem"]["Dell"]["Label"]
          myRecord["Metric"] = label.delete(val["MetricId"]).strip()
          myRecord["Value"] = val["MetricValue"]
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