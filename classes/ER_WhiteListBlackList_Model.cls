global class ER_WhiteListBlackList_Model 
{
    global class WhitelistBlackListResult
    {
        public String ProgramCode {set;get;}
        public String EntitlementName{set;get;}
        public List<WhiteListedWrapper> AcceptableDomainList {set;get;}
        public List<WhiteListedWrapper> RestrictedDomains {set;get;}
        public List<ProjectBudgetWrapper> ProjectBudgetDetails {set;get;}
        public List<String> AllowedDomains{set;get;}
        public ExceptionWrapper ExceptionDetails {set;get;}
        public Long ResponseTimeMS {set;get;}
    }
    
    public class ProjectBudgetWrapper
    {
        public String ProjectSubType {set;get;}
        public String MinBudget {set;get;}
        public String MaxBudget {set;get;}
        public String Geo {set;get;}
        public String Country {set;get;}
        public String MinBudgetDisplayName {set;get;}
        public String MaxBudgetDisplayName {set;get;}
    }
	
	  
    public class WhiteListedWrapper
    {
        public String Domains {set;get;}
        public String GeoList {set;get;}
        public String Countries {set;get;}
       // public String Level {set;get;}
    }
    
    public class ExceptionWrapper {
        public String Status {set;get;}
        public Integer StatusCode {set;get;}
        public String Message {set;get;}
    }    
    
}