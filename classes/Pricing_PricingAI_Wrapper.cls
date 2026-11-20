/**
 * @description       : Wrapper class for Mydeals Request Payload 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : Gravity
 * @last modified on  : 03-27-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Pricing_PricingAI_Wrapper {
    public class CalloutInputWrapper {
        public AccountWrapper accountDetails {set;get;}
        public ProductWrapper productDetails{set;get;}
        public String endCustomer{set;get;}
        public String application{set;get;}
        public String groupType{set;get;}
        public String approvedStartDate{set;get;}
        public String unifiedEndCustomer{set;get;}
        public String approvedEndDate{set;get;}
        public String productFamily{set;get;}
        public Decimal meetCompPrice{set;get;}
        public Decimal tentativeECAPPrice{set;get;}
        public Decimal requestedDiscountPrice{set;get;}
        public String unifiedCountryEndCustomerId{set;get;}
        public String competitorProductName{set;get;}
        public String effectivePricingStartDate{set;get;}
        public String endCustomerRegion{set;get;}
        public String endCustomerCountry{set;get;}
        public String unifiedEndCustomerId{set;get;}
        public String billingEndDate{set;get;}
        public String quoteLineId{set;get;}
        public String name{set;get;}
        public String processorNumber{set;get;}
        public String region{set;get;}
        public String marketSegment{set;get;}
        public String billingStartDate{set;get;}
        public Decimal approvedQuantity{set;get;}
        public String wwid{set;get;}
        public String quoteLineNumber{set;get;}
        public String productName{set;get;}
        public Decimal noOfCPUPerSystem{set;get;}
        public Decimal noOfCompCPUPerSystem{set;get;}
        public String quoteLineType{set;get;}
        public String formFactor{set;get;}
        public String competitorName{set;get;}
        public String intelAccountExecutiveEmail{set;get;}
        public Boolean sdmFastTrack{set;get;}
        
    }
    public class ProductWrapper {
        public String id {set;get;}
        public String epmId{set;get;}
        public String name{set;get;}
        public String processorNumber{set;get;}
    }
    public class AccountWrapper {
        public String name{set;get;}
        public String cimId{set;get;}
        public String CustomerMappingId{set;get;}
        public String id{set;get;}
    }
}