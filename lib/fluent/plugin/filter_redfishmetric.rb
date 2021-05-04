require 'fluent/plugin/filter'

module Fluent::Plugin
  class RedfishMetricFilter < Filter
    # Register filter as 'redfishmetric'
    Fluent::Plugin.register_filter('redfishmetric', self)

    # config_param for the plugins
    config_param :namespace, :string, :default => 'ColomanagerFluentdRedfish'
    config_param :coloregion, :string, :default => 'CentralusEUAP'
    config_param :filtering, :array, :default => [], value_type: :string
	
    def configure(conf)
      super
        @metrics = []
        @counterMap = Hash.new(0)
        @valueMap = Hash.new(0)
        @tofilter = []
    end
	  
    def map_by_label()
      @metrics&.each do |val|
        key = val['Oem']['Dell']['Label']
        @counterMap[key] += 1 
        @valueMap[key] += (val['MetricValue']).to_i
	  end
	end
	
    def to_filter_report(reportid)
      if !@filtering&.empty?
        @filtering&.each do |val|
        if val.split('.')[0] == reportid
          @tofilter << (val.split('.'))[1]
          end
        end		  
      end
    end
    
    def purge_param()
      @counterMap.clear()
      @valueMap.clear()
      @tofilter.clear
    end
	
    def filter_stream(tag, es)
  
      new_es = Fluent::MultiEventStream.new
      es.each { |time, record|
        @metrics = record['MetricValues']
        
        to_filter_report(record['Id'])
        if !@tofilter&.empty?
          map_by_label()
        end

        @valueMap&.each do |key, val|
          begin
            myRecord = {}
            myRecord['Namespace'] = @namespace
            myRecord['Metric'] = key
            myRecord['Dimensions'] = {'Region' => @coloregion, 'Report'=>record['Id'],'IP' => record['REMOTE_ADDR']}
            myRecord['Value'] = (val/@counterMap[key]).to_s
            if @tofilter&.include?(key.split[-1])
              new_es.add(time, myRecord)
            end
          rescue => e
          router.emit_error_event(tag, time, record, e)
          end
        end
        purge_param()
      }
      new_es
    end
  end
end