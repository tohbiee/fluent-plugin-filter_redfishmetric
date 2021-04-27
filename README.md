# Fluent::Plugin::Redfish::Alert

## Installation

build with gem build
    $ gem build fluent-plugin-redfishmetric.gemspec
install with gem install
    $ gem install fluent-plugin-filter_redfishmetric
unit

## Configuration

```

<filter **>
  type redfishmetric
</filter>

```

converts a single json chunk of metric into indiviual streams of metric
Also has capacity to discard/filter desired redfish metric thresholds
set @Filter flag to "true", and set @Metric to the desired threshold

Update to allow multiple thresholds to be filered in progress


## Contributing
Please Read Contributing.md (coming)