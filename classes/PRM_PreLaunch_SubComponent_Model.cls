global class PRM_PreLaunch_SubComponent_Model {
    public string type {get;set;}
    public List<SubComponent> subComponent {get;set;}
    
    public class SubComponent {
        public string component {get; set;}
        public SubComponentSeparateServiceCall subComponentSeparateServiceCall {get;set;}
    }
    
    public class SubComponentSeparateServiceCall{
        public string stepId {get;set;}
        public HeaderContent content {get;set;}
        public PreviousGroup previousGroup {get;set;}
        public PreviousGroup newGroup {get;set;}
        public CompanyInfo companyInfo {get;set;}
        public FooterLinkData footerLinkData {get;set;}        
    }
    
    public class HeaderContent {
        public string type {get;set;}
        public string body {get;set;}        
    }
    
    public class PreviousGroup {
        public string title {get;set;} 
        public List<Cards> cards {get;set;}
    }
    
    public class Cards{
        public string title {get;set;} 
        public List<Members> members {get;set;}
    }
    
    public class Members{
        public string name {get;set;} 
        public string entitlement {get;set;} 
    }
    
    public class CompanyInfo {
        public string icon {get;set;} 
        public string tier {get;set;} 
        public string company {get;set;} 
        public string role {get;set;} 
    }
    
    public class FooterLinkData {
        public string label {get;set;} 
        public string externalUrl {get;set;} 
        public string communityPage {get;set;} 
        public string objectPage {get;set;} 
        public string recordId {get;set;}
    }
}