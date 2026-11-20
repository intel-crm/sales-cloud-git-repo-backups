global class Ent_Reg_eRPMApiModel {
    public class payload {
	    public PersonAccountProfile PersonAccountProfile { get; set; }
        public Boolean blnPublish;
        public Boolean blnNotify;
        public String changeAgent;
        public String chgAgtLoginId;
    
    public payload() {
        PersonAccountProfile = new PersonAccountProfile();
        blnPublish = true;
        blnNotify = true;
        changeAgent = 'SalesCloud';
        chgAgtLoginId = 'MAD\\testuser';
    }
    }


public class PersonAccountProfile {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string EmailID { get; set; }
        //public string PersonTitle { get; set; }
        public string JobFunction { get; set; }
        public string LanguageCode { get ; set; }
        //public string CountryCode { get ; set; }
        
        public List<PersonPhysicalAddresses> PersonPhysicalAddresses { get; set; }
        public List<PersonElectronicAddresses> PersonElectronicAddresses { get; set; }
        //List<AccountProfiles> AccountProfiles { get; set; }
        public List<Memberships> Memberships { get; set; }
        public ExternalAttributes ExternalAttributes { get; set; }
        public List<Subscription> Subscriptions = new List<Subscription>();
       
        public PersonAccountProfile() {
            this.PersonPhysicalAddresses = new List<PersonPhysicalAddresses>();
            this.PersonElectronicAddresses = new List<PersonElectronicAddresses>();
            //AccountProfiles = new List<AccountProfiles>();
            this.Memberships = new List<Memberships>();
            this.ExternalAttributes = new ExternalAttributes();          
            this.Subscriptions = new List<Subscription>();
        }
    }

public class PersonPhysicalAddresses {
        public String AddressLine1;
        public String City;
        public String State;
        public String CountryCode;
        public String PostalCode;
    public PersonPhysicalAddresses(string addrLine1, string city, string state, string ctryCode, string postalCode) {
        this.AddressLine1=addrLine1;
        this.City = city;
        this.State = state;
        this.CountryCode = ctryCode;
        this.PostalCode = postalCode;
    }
    }

public class PersonElectronicAddresses {
        public String ElectronicAddressType;
        public String LocationType;
        public String ElectronicAddressText;
        public PersonElectronicAddresses(String eAddressType, String eAddressText) {
            this.ElectronicAddressType = eAddressType;
            this.LocationType = 'HOME';
            this.ElectronicAddressText = eAddressText;
        }
    }
    
public class ExternalAttributes {
        public String ProfessionCode ;
        
    }
    
public class Memberships {
        public String EngagementCode;
        public String EnggStatus;
        public Memberships(String engCode, String engStatus) {
            this.EngagementCode = engCode;
            this.EnggStatus = engStatus;
        }
    }
    
    public class Subscription
    {
        public String SubscriptionCode { get; set; }
        //public String SubscriptionName { get; set; }
        public String SubscriptionStatusCode { get; set; }
        //public String UnSubscriptionReason { get; set; }
        public String EngagementCode { get; set; }
    }
}