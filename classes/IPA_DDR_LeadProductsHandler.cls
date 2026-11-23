public without sharing class IPA_DDR_LeadProductsHandler {

    // Fetch Product2 records for LWC typeahead ---
    @AuraEnabled(cacheable=true)
    public static List<Product2> getActiveProducts(String searchKey) {
        String key = '%' + searchKey + '%';
        return [
            SELECT Id, Name
            FROM Product2
            WHERE IsActive = TRUE AND Name LIKE :key
            ORDER BY Name
            LIMIT 50
        ];
    }

    //Insert Lead Products from JSON (invocable for Flow) ---
    public class ProductWrapper {
        @InvocableVariable public String productId;
        @InvocableVariable public String productName;
        @InvocableVariable public Integer quantity;
    }

    public class Request {
        @InvocableVariable public String leadId;
        @InvocableVariable public String jsonProducts;
    }

    @InvocableMethod(label='Insert Lead Products from JSON')
    public static void insertLeadProducts(List<Request> requests) {
        System.debug('---- InsertLeadProducts START ----');
        for (Request req : requests) {
            System.debug('Lead Id: ' + req.leadId);
            System.debug('JSON Received: ' + req.jsonProducts);
            
            if (String.isBlank(req.jsonProducts)) {
                System.debug('No products JSON, skipping...');
                continue;
            }
            
            List<ProductWrapper> rows = (List<ProductWrapper>)JSON.deserialize(req.jsonProducts, List<ProductWrapper>.class);
            System.debug('Parsed Products: ' + rows);
            
            List<Lead_Products__c> productsToInsert = new List<Lead_Products__c>();
            for (ProductWrapper row : rows) {
                System.debug('Row ProductId: ' + row.productId + ', Name: ' + row.productName + ', Quantity: ' + row.quantity);
                
                productsToInsert.add(new Lead_Products__c(
                    Lead__c = req.leadId,
                    Product__c = row.productId,
                    Name = row.productName,
                    Quantity__c = row.quantity
                ));
            }
            
            if (!productsToInsert.isEmpty()) {
                System.debug('Inserting ' + productsToInsert.size() + ' Lead Products');
                insert productsToInsert;
            } else {
                System.debug('No products to insert');
            }
        }
        System.debug('---- InsertLeadProducts END ----');
    }
}