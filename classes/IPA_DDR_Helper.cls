public with sharing class IPA_DDR_Helper {

    public class Wrapper {
        @AuraEnabled public String customerName;
        @AuraEnabled public String website;
        @AuraEnabled public String country;
        @AuraEnabled public String decisionMaker;
        @AuraEnabled public String oppName;
        @AuraEnabled public String oppSummary;
        @AuraEnabled public Date decisionDate;
        @AuraEnabled public Decimal budget;
        @AuraEnabled public List<ProductRow> products = new List<ProductRow>();
    }

    public class ProductRow {
        @AuraEnabled public String productId;
        @AuraEnabled public String productName;
        @AuraEnabled public Integer quantity;
    }
    
    // Example: Fetch active products
    @AuraEnabled(cacheable=true)
    public static List<Product2> getActiveProducts(String searchKey) {
        return [
            SELECT Id, Name
            FROM Product2
            WHERE IsActive = TRUE AND Name LIKE :('%' + searchKey + '%')
            LIMIT 50
        ];
    }

    @AuraEnabled
    public static void saveLeadAndProducts(String jsonData) {
      System.debug('--- saveLeadAndProducts START ---');
        System.debug('Raw JSON received: ' + jsonData);

        if(String.isBlank(jsonData)) {
            throw new AuraHandledException('No data received from LWC.');
        }

        // Deserialize JSON string into Wrapper
        Wrapper data;
        try {
            data = (Wrapper) JSON.deserialize(jsonData, Wrapper.class);
        } catch(Exception ex) {
            throw new AuraHandledException('Failed to parse JSON: ' + ex.getMessage());
        }

        System.debug('Deserialized wrapper: ' + JSON.serializePretty(data));

        // Validate required fields
        if(String.isBlank(data.customerName)) {
            throw new AuraHandledException('Customer Name is required.');
        }
        System.debug('Customer Name: ' + data.customerName);
        System.debug('Website: ' + data.website);
        System.debug('Decision Maker: ' + data.decisionMaker);
        System.debug('Opportunity Name: ' + data.oppName);
        System.debug('Opportunity Summary: ' + data.oppSummary);
        System.debug('Decision Date: ' + data.decisionDate);
        System.debug('Budget: ' + data.budget);
        System.debug('Products count: ' + (data.products != null ? data.products.size() : 0));

        // Example: Insert Lead
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
        Id rtId = rtMap.get('Deal_Registration').getRecordTypeId();

        User u = [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Id partnerAccountId = u.Contact != null ? u.Contact.AccountId : null;

        Lead l = new Lead(
            LastName = data.customerName,
            Company = data.customerName,
            Status = 'Open - Not Contacted',
            LeadSource = 'Partner Portal',
            Website = data.website,
            Country = data.country,
            Partner_Account__c = partnerAccountId,
            RecordTypeId = rtId
        );

        insert l;

        if(data.products != null && !data.products.isEmpty()) {
            List<Lead_Products__c> listLP = new List<Lead_Products__c>();
            for(ProductRow p : data.products) {
                if(p.productId != null) {
                    listLP.add(new Lead_Products__c(
                        Lead__c = l.Id,
                        Product__c = p.productId,
                        Name = p.productName,
                        Quantity__c = p.quantity
                    ));
                }
            }
            if(!listLP.isEmpty()) {
                insert listLP;
            }
        }
    }
}