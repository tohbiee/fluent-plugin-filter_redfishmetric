# Fluent::Plugin::Redfish::Alert

## Installation

build with gem build
    $ gem build fluent-plugin-redfishmetric.gemspec
install with gem install
    $ gem install fluent-plugin-filter_redfishmetric

## Configuration

```

<filter **>
  type redfishmetric
</filter>

```

converts a single json chunk of metric into indiviual streams of metric
Also has capacity to discard/filter desired redfish metric


## Contributing
Please Read Contributing.md (coming)