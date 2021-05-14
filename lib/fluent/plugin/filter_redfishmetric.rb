require 'fluent/plugin/filter'

module Fluent::Plugin
  class RedfishMetricFilter < Filter
    # Register filter as 'redfishmetric'
    Fluent::Plugin.register_filter('redfishmetric', self)

    # config_param for the plugins
    config_param :namespace, :string, :default => 'ColomanagerFluentdRedfish'
    config_param :filtering, :array, :default => [], value_type: :string
	
    def configure(conf)
      super
        @metrics = []
        @counterMap = Hash.new(0)
        @valueMap = Hash.new("0")
        @tofilter = []
        @isTypeString = Hash.new(false)
      end
	  
    def map_by_label()
      @metrics&.each do |val|
        key = val['Oem']['Dell']['Label']
        tmp = Integer(val['MetricValue']) rescue nil
        if tmp.nil?
          @isTypeString[key] = true
          @valueMap[key] = val['MetricValue']
        else
          @counterMap[key] += 1 
          @valueMap[key] = (@valueMap[key]).to_i + tmp
        end
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
            myRecord['Dimensions'] = {'BaremetalMachineID' => record['machineID'], 'Report'=>record['Id']}
            if @isTypeString[key] 
              myRecord['Value'] = val
            else 
              myRecord['Value'] = ((val).to_i/@counterMap[key]).to_s
            end
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