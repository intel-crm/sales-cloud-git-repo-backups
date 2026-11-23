/**
* @description       : Created wrapper class to generate MyDeal Payload
* @author            : Rahul Maindalkar
* @group             : 
* @last modified on  : 04-14-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//** when ever an attribute is added in this class we have to make sure to add in Pricing_JSONString class as well */
public class Pricing_BulkCR_JSONString {
    public class Quote {
        public String Id;
        public String Name;
        public String FolioID;
        public Account Account;
        public String DealType;
        public String ProjectName;
        public Date ShipmentStartDate;
        public Date ShipmentEndDate;
        public String ServerDealType;
        public String MarketSegment;
        public String FolioName;
        public String EndCustomer;
        public String EndCustomerCountry;
        public String UnifiedEndCustomer;
        public String UnifiedEndCustomerId;
        public String UnifiedCountryEndCustomerId;
        public String UnifiedEndCustomerGlobalName;
        public Boolean IsUnifiedEndCustomer;
        public String ComplianceWatchList;
        public Boolean AIHostNode;
        public List<QuoteLine> QuoteLine;
    }
    
    public class Account {
        public String Id;
        public String Name;
        public String CIMId;
        public String CustomerMappingId;
    }
    
    public class PerformanceMetric {
        public String Id;
        public String Name;
        public String PerformanceMetric;
        public Decimal IntelSKUPerformance;
        public Decimal CompSKUPerformance;
        public Decimal Weighting;
    }
    
    public Header Header;
    public RecordDetails RecordDetails;
    
    public class Header {
        public String source_system;
        public String target_system;
        public String action;
        public String xid;
    }
    
    public class Product {
        public String Id;
        public String Name;
        public String ProductNameEPMID;
        public String ProductLevel;
        public String Family;
        public String DealProductName;
        public String ProcessorNumber;
        public String MaterialID;
    }
    
    public class QuoteLine {
        public String Id;
        public String Name;
        public Decimal  MeetCompPrice;
        public Decimal  ApprovedQuantity;
        public Decimal PayableQuantity;
        public Decimal  ApprovedECAPPrice;
        public Date ApprovedStartDate;
        public Date ApprovedEndDate;
        public String DealRFQId;
        public String ApprovedByInfo;
        public String Status;
        public string IntegrationStatus;
        public Product Product;
        public String OtherProduct;
        public String ProductType;
        public CompetitorProduct CompetitorProduct;
        public String OtherCompetitorProduct;
        public List<PerformanceMetric> PerformanceMetric;
        public string QuoteLineNumber;
        public string ReferenceQuoteLineNumber;
        public string DealRFQStatus;
        public String WWID;
        public String BackdateReason;
        public Date BillingEndDate;
        public Date BillingStartDate;
        public String GroupType;
        public String MarketSegment;
        public String AdditionalTandC;
        public Boolean ExcludeAutomation;
        public Date EffectivePricingStartDate;
        public String EndCustomerRegion;
        public String Region;
        public String DealDescription;
        public String CustomerDivision;
        public String ConsumptionCustomerPlatform;
        public String ConsumptionReportedSalesGeo;
        public String ConsumptionCountry;
        public String ConsumptionRegion;
        public String ConsumptionCustomerSegment;
        public List<ErrorMessages> ErrorMessages;
    }
    
    public class RecordDetails {
        public List<Quote> Quote;
    }
    
    public class CompetitorProduct {
        public String Id;
        public String Name;
    }
    
    public class ErrorMessages{
        public String code;
        public String Message;
        public String MessageDetails;
    }
    public static Pricing_BulkCR_JSONString parse(String json) {
        return (Pricing_BulkCR_JSONString) System.JSON.deserialize(json, Pricing_BulkCR_JSONString.class);
    }
}