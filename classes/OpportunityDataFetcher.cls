public class OpportunityDataFetcher {
    public static List<OpportunityWrapper> getOpportunityData() {
        //Request input = requests[0];
        id accountID = '001Df00000iaYQfIAM';
        List<Opportunity> opportunities = [
            SELECT Id, CloseDate, Name, Description, StageName, Type, Amount, 
            Decision_Date__c, Core_Status_Update__c, Account.Name,
            (SELECT Quantity, UnitPrice, TotalPrice, Product2.Name, Product2.Id 
             FROM OpportunityLineItems 
             WHERE Core_Status__c NOT IN ('Delete In Progress (<15 min)','Cancelled','Lost')),
            (SELECT Id, Core_UCD_Partner_Account_Name__c, Core_Partner_Role__c, Core_Partner_Type__c 
             FROM Opportunity_Partners__r)
            FROM Opportunity WHERE AccountId =: accountID
        ];
        
        List<OpportunityWrapper> wrappedOpportunities = new List<OpportunityWrapper>();
        for (Opportunity opp : opportunities) {
            OpportunityWrapper wrappedOpp = new OpportunityWrapper();
            wrappedOpp.oppId = opp.Id;
            wrappedOpp.closedDate = opp.CloseDate;
            wrappedOpp.name = opp.Name;
            wrappedOpp.description = opp.Description;
            wrappedOpp.stage = opp.StageName;
            wrappedOpp.type = opp.Type;
            wrappedOpp.amount = opp.Amount;
            
            for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                ProductWrapper wrappedProduct = new ProductWrapper();
                wrappedProduct.productName = oli.Product2.Name;
                wrappedProduct.productAmount = oli.TotalPrice;
                wrappedProduct.productQuantity = oli.Quantity;
                wrappedProduct.proSeg = determineProSeg(oli.Product2.Name); // Determine Pro_seg based on conditions
                
                wrappedOpp.products.add(wrappedProduct);
            }
            for (Core_Opportunity_Partner__c partner : opp.Opportunity_Partners__r) {
                PartnerWrapper wrappedPartner = new PartnerWrapper();
                wrappedPartner.partnerId = partner.Id;
                wrappedPartner.partnerAccountName = partner.Core_UCD_Partner_Account_Name__c;
                wrappedPartner.partnerRole = partner.Core_Partner_Role__c;
                wrappedPartner.partnerType = partner.Core_Partner_Type__c;
                
                wrappedOpp.partners.add(wrappedPartner);
            }
            
            wrappedOpportunities.add(wrappedOpp);
        }
        return wrappedOpportunities;
    }
    
    private static String determineProSeg(String productName) {
        if (productName.contains('Emerald Rapids') || productName.contains('Gaudi2') || 
            productName.contains('Granite Rapids AP 2S') || productName.contains('Public Cloud with 4th Gen Intel® Xeon®') ||
            productName.contains('Public Cloud with Intel® Xeon®') || productName.contains('Sapphire Rapids SP CPU') ||
            productName.contains('Sierra Forest SP 1S') || productName.contains('Base')) {
                return 'DCAI';
            } else if (productName.contains('Granulate™') || productName.contains('Intel® Developer Cloud') ||
                       productName.contains('One Edge') || productName.contains('Project Amber')) {
                           return 'Software';
                       } else if (productName.contains('Intel vPro® Platform') || productName.contains('Intel® Active Management Technology (Intel® AMT)')) {
                           return 'CCG';
                       }
        return null; // Default case if none of the conditions match
    }
    public class OpportunityWrapper {
        public Id oppId;
        public Date closedDate;
        public String name;
        public String description;
        public String statusUpdate;
        public String stage;
        public String type;
        public String productSegment;
        public Decimal amount;
        public Decimal lostAmount;
        public String opportunityURL;
        public List<ProductWrapper> products;
        public List<PartnerWrapper> partners;
        
        public OpportunityWrapper() {
            products = new List<ProductWrapper>();
            
            partners = new List<PartnerWrapper>();
        }
        
    }
    
    public class ProductWrapper {
        public String productName;
        public Decimal productAmount;
        public Decimal productQuantity;
        public String proSeg; // Additional field based on product name conditions
    }
    public class PartnerWrapper {
        public Id partnerId;
        public String partnerAccountName;
        public String partnerRole;
        public String partnerType;
        
        // Constructor, getters, and setters can be added as needed
    }
    
}