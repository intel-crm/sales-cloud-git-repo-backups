public class ChartController {
    public String chartUrl { get; set; }

    public ChartController() {
        // Define the chart configuration
        String chartConfig = '{'
            + '  type: "bar",'
            + '  data: {'
            + '    labels: ["January", "February", "March", "April"],'
            + '    datasets: [{'
            + '      label: "Sales",'
            + '      data: [10, 20, 30, 40]'
            + '    }]'
            + '  }'
            + '}';

        // URL-encode the configuration
        String encodedConfig = EncodingUtil.urlEncode(chartConfig, 'UTF-8');

        // Construct the chart URL
        chartUrl = 'https://quickchart.io/chart?c=' + encodedConfig;
    }
}