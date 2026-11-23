public without sharing class Core_ACM_PayloadWrapper {
    public PersonAccountProfile PersonAccountProfile { get; set; }
    public String ChgAgtLoginId { get; set; }
    public String ChangeAgent { get; set; }
    public Boolean blnPublish { get; set; }
    public Boolean blnNotify { get; set; }
    
    public Core_ACM_PayloadWrapper() {
        this.PersonAccountProfile = new PersonAccountProfile();
        this.ChangeAgent = Core_ACM_Constants.CHANGE_AGENT;
        this.blnPublish = true;
        this.blnNotify = true;
        this.ChgAgtLoginId = Core_ACM_Constants.CHANGE_AGENT_LOGIN_ID;
    }
    
    public class PersonAccountProfile {
        public List<Subscription> Subscriptions { get; set; }
        public String SalesDoNotContactFlag { get; set; }
        public DateTime SalesDoNotContactDate { get; set; }
        public String PersonTitle { get; set; }
        public String PersonRegistrationTypeCode { get; set; }
        public List<PersonPhysicalAddress> PersonPhysicalAddresses { get; set; }
        public String PersonID { get; set; }
        public List<PersonElectronicAddress> PersonElectronicAddresses { get; set; }
        public List<Membership> Memberships { get; set; }
        public String LoginID { get; set; }
        public String LastName { get; set; }
        public String LanguageCode { get; set; }
        public String JobFunction { get; set; }
        public String FirstName { get; set; }
        public ExternalAttributes ExternalAttributes { get; set; }
        public String EnterpriseID { get; set; }
        public String EnglishLastName { get; set; }
        public String EnglishFirstName { get; set; }
        public String EmailID { get; set; }
        public String DoNotContactFlag { get; set; }
        public String CountryCode { get; set; }
        public DateTime AllIntelDoNotContactDate { get; set; }
        
        public PersonAccountProfile() {
            this.Subscriptions = new List<Subscription>();
            this.PersonPhysicalAddresses = new List<PersonPhysicalAddress>();
            this.PersonElectronicAddresses = new List<PersonElectronicAddress>();
            this.Memberships = new List<Membership>();
            this.ExternalAttributes = new ExternalAttributes();
        }
    }
    
    public class Subscription {
        public String SubscriptionCode { get; set; }
        public String SubscriptionName { get; set; }
        public String SubscriptionStatusCode { get; set; }
        public String UnSubscriptionReason { get; set; }
    }
    
    public class PersonPhysicalAddress {
        public String State { get; set; }
        public String PostalCode { get; set; }
        public String CountryCode { get; set; }
        public String City { get; set; }
        public String AddressLine1 { get; set; }
    }
    
    public class PersonElectronicAddress {
        public String LocationType { get; set; }
        public String ElectronicAddressType { get; set; }
        public String ElectronicAddressText { get; set; }
        
        public PersonElectronicAddress(String addressType, String addressText) {
            this.ElectronicAddressType = addressType;
            this.ElectronicAddressText = addressText;
            this.LocationType = Core_ACM_Constants.LOCATION_TYPE_HOME;
        }
    }
    
    public class Membership {
        public String EnggStatus { get; set; }
        public String EngagementCode { get; set; }

        public Membership(String engCode, String engStatus) {
             this.EngagementCode = engCode;
            this.EnggStatus = engStatus;
        }
    }
    
    public class ExternalAttributes {
        public String ProfessionCode { get; set; }
    }

    public class ResponseWrapper{
        public String Status { get; set; }
        public String ErrorCode {get; set;}
        public String ErrorType {get; set;}
        public String ErrorText {get; set;}
        public String ErrorDetails {get; set;}
        public String PersonID {get; set;}
        public String EnterpriseID {get; set;}
        public String EmailID {get; set;}
    }
    
    	//Ganesh Changes
public class RoleRequestPayload {
    public Requestee requestee { get; set; }
    public List<RequestItem> requestItems { get; set; }
}

public class Requestee {
    public String enterpriseId { get; set; }

    public Requestee(String enterpriseId) {
        this.enterpriseId = enterpriseId;
    }
}

public class RequestItem {
    public String operation { get; set; }
    public Access access { get; set; }
    public String justification { get; set; }

    public RequestItem(
        String operation,
        Access access,
        String justification
    ) {
        this.operation = operation;
        this.access = access;
        this.justification = justification;
    }
}

public class Access {
    public String type { get; set; }
    public String name { get; set; }

    public Access(String type, String name) {
        this.type = type;
        this.name = name;
    }
}
//Ganesh Changes End
}