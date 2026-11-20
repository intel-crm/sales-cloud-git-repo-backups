public class AI_OpportunityDataWrapper {
    public class OpportunityWrapper implements Pricing_RestAPI_SuccessContent{
        //public Opportunity opportunity { get; set; }
        public List<Opportunity> opportunities { get; set; }
        public List<OpportunityProducts> opportunityProducts { get; set; }
        public List<OpportunityPartners> opportunityPartners { get; set; }
        public List<OpportunityChatter> opportunityChatter { get; set; }
        public List<OpportunityTasks> opportunityTasks { get; set; }
        
        public OpportunityWrapper() {
            opportunities = new List<Opportunity>();
            opportunityProducts = new List<OpportunityProducts>();
            opportunityPartners = new List<OpportunityPartners>();
            opportunityChatter = new List<OpportunityChatter>();
            opportunityTasks = new List<OpportunityTasks>();
        }
    }
    
    public class Opportunity {
        public Id opportunityId;
        public String opportunityName;
        public Id accountId;
        public String accountName;
        public String sellerName;
        public Date closedDate;        
        public String description;
        public String riskReason;
        public String statusUpdate;
        public String Stage;
        public String opportunityStatus;
        public String opportunityType;
        public Decimal WinAmount;
        public Decimal lostAmount;
        public DateTime createdDate;
        public String createdByName;
        public Decimal quantity;
        public String productApplication;
        public String competitiveArchitecture;
        public String intelPlatform;
        public String ownerGeo;
    }
    
    public class OpportunityProducts {
        public Id opportunityId;
        public String opportunityName;
        public Id accountId;
        public String accountName;
        public String opportunityProductName;
        public String opportunityProductStatus;
        public Decimal opportunityProductSalesPrice;
        public Decimal opportunityProductQuantity;
        public Decimal opportunityProductTotalPrice;
        public String opportunityProductBU;
        public String opportunityProductSegment;
        public String competitor;
        public String competitorProduct;
        public String otherCompetitor;
        public String lossCancelDetails;
        public String lossCancelReason;
        public String riskCategory;
        public String riskDetails;
        public DateTime createdDate;
        public String createdByName;
    }
    
    public class OpportunityPartners {
        public Id opportunityId;
        public String opportunityName;
        public Id accountId;
        public String accountName;
        public String partnerAccountName;
        public String partnerRole;
        public String partnerType;
        public DateTime createdDate;
        public String createdByName;
    }
    
    public class OpportunityChatter {
        public Id opportunityId;
        public String opportunityName;
        public Id accountId;
        public String accountName;
        public String Body;
        public DateTime createdDate;
        public String createdByName;
    }
    
    public class OpportunityTasks {
        public Id opportunityId;
        public String opportunityName;
        public Id accountId;
        public String accountName;
        public String subject;
        public String description;
        public String status;
        public String priority;
        public DateTime createdDate;
        public String createdByName;
    }
}