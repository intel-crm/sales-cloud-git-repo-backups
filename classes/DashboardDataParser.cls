public class DashboardDataParser {
public static void parseDashboardData(String jsonResponse) {
        // Deserialize the JSON response into a generic Map
        Map<String, Object> dashboardData = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);

        // Navigate to the components section
        List<Object> components = (List<Object>) ((Map<String, Object>) dashboardData.get('dashboardMetadata')).get('components');

        // Loop through components to find the data points
        for (Object componentObj : components) {
            Map<String, Object> component = (Map<String, Object>) componentObj;

            // Check if the component type is 'chart'
            if (component.get('type') == 'chart') {
                String componentName = (String) component.get('name');
                System.debug('Processing Chart: ' + componentName);

                // Extract metrics (data points)
                Map<String, Object> data = (Map<String, Object>) component.get('data');
                List<Object> metrics = (List<Object>) data.get('metrics');

                for (Object metricObj : metrics) {
                    Map<String, Object> metric = (Map<String, Object>) metricObj;
                    String label = (String) metric.get('label');
                    Decimal value = (Decimal) metric.get('value');

                    System.debug('Label: ' + label + ', Value: ' + value);
                }
            }
        }
    }
}