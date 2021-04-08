require_relative 'helper'
require 'fluent/plugin/test/driver/filter'
require 'fluent/plugin/redfishmetricfilter'

class RedfishmetricfilterTest < Test::Unit::TestCase
    include Fluent

    def setup 
        Fluent::Test.setup
    end

    # default configuration for tests
    CONFIG = %[
        Metric false
      ]

    def create_driver(conf = CONFIG)
        Fluent::Test::Driver::Filter.new(Fluent::Plugin::RedfishMetricFilter).configure(conf)
    end

    def filter(config, messages)
        d = create_driver(config)
        d.run(default_tag: 'input.access') do
            messages.each do |message|
                d.feed(message)
            end
        end
        d.filtered_records
    end

    #sub_test_case 'configure' do
    sub_test_case 'configured with invalid configuration' do
        test 'empty configuration' do
            assert_raise(Fluent::ConfigError) do
                create_driver('')
            end
        end
        
        test 'param1 should reject too short string' do
            conf = %[
                param1 a
            ]
            assert_raise(Fluent::ConfigError) do
                create_driver(conf)
            end
        end
    end

    sub_test_case 'plugin will add some fields' do
        test 'filter metric and add dimension to record' do
            conf = CONFIG

            messages =
            {
                "@odata.type" => "#MetricReport.v1_2_0.MetricReport",
                "@odata.context" => "/redfish/v1/$metadata#MetricReport.MetricReport",
                "@odata.id" => "/redfish/v1/TelemetryService/MetricReports/MemorySensor",
                "Id" => "MemorySensor",
                "Name" => "Memory Sensor Metric Report Definition",
                "ReportSequence" => "2",
                "REMOTE_ADDR" => "1.1.2.2"
                "MetricReportDefinition" => {
                    "@odata.id" => "/redfish/v1/TelemetryService/MetricReportDefinitions/MemorySensor"
                },
                "Timestamp" => "2021-02-19T12:48:31-06:00",
                "MetricValues" => [
                    {
                        "MetricId" => "TemperatureReading",
                        "Timestamp" => "2021-02-19T12:48:30-06:00",
                        "MetricValue" => "31",
                        "Oem" => {
                            "Dell" => {
                                "ContextID" => "DIMM.Socket.A1",
                                "Label" => "DIMM Socket A1 TemperatureReading"
                            }
                        }
                    },
                ]
            }

            expected = [{"Namespace"=>"ColomanagerFluentdRedfish", "Report"=>"MemorySensor", "Metric"=>"30", "Value"=>"31", "Dimension"=>{"Region"=>"Ce
                ntralusEUAP", "IP"=>"1.1.2.2"}},]

            filtered_records = filter(conf, messages)
            assert_equal(expected, filtered_records)
        end
    end    
end