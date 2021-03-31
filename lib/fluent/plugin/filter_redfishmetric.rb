require 'fluent/plugin/filter'

module Fluent::Plugin
  class RedfishMetricFilter < Filter
    # Register this filter as "redfishmetric"
    Fluent::Plugin.register_filter('redfishmetric', self)

    def configure(conf)
      super
      @metricValueList = []
      # Do the usual configuration here
    end

    def customredfishmetricfilter(tag, time, record)
      @metricValueList = record["MetricValues"]
      res = []
      @metricValueList.each do |val|
          res.add(tag, time, val)
      end
      route.emit(res)
  end

    def filter(tag, time, record)
        customredfishmetricfilter(record)
    end
  end
end