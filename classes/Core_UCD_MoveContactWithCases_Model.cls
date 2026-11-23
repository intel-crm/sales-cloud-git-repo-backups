public with sharing class Core_UCD_MoveContactWithCases_Model {
    public class initializeWrapper{

		public Account targetAccountObj {get{targetAccountObj = null; return targetAccountObj; }set;}
        public boolean gecCaseFound {get{gecCaseFound = false; return gecCaseFound; }set;}
        public boolean hasAccessToAcctSelection {get{hasAccessToAcctSelection = true; return hasAccessToAcctSelection; }set;}
        public boolean keepCases {get{keepCases = false; return keepCases; }set;}
        public boolean keepEntitlements {get{keepEntitlements = false; return keepEntitlements; }set;}
        public Case contactLookUp {
            get{
                contactLookUp.Id = [select Id from Case Limit 1].Id;
                return contactLookUp;

            }set;
        }
       
        public Contact targetAccount {get{targetAccount = new Contact(); return targetAccount; }set;}
        public Boolean userAuthorized{
			get{
					Map<String, Core_Move_Contact_Authorized_Profiles__c> lCSOpenCases = Core_Move_Contact_Authorized_Profiles__c.getAll();
					Profile currLoggedInUserProfile = [Select Name from Profile where Id = : UserInfo.getProfileId() limit 1];


					return lCSOpenCases.containsKey(currLoggedInUserProfile.Name); 
					
				}
			set;
		}
        public boolean hasSelectedEntitlements {get{hasSelectedEntitlements = false; return hasSelectedEntitlements; }set;}
        public String errorMsg {get{errorMsg = ''; return errorMsg; }set;}
		public List<contact> currContact {get;set;}
		public List<case> caseDetails {get;set;}
        public List<CaseWrapper> casesWithProjectId {get;set;}
        public List<CaseWrapper> casesWithOUTprojectId {get;set;}
		


	}
	
	  public class CaseWrapper{
        public Case cs {get;set;}
        public boolean keepCase {get;set;}
        public CaseWrapper(Case arg1, Boolean flag){
            cs = arg1;
            keepCase = flag;
        }
    }
	
	
	public class AssetWrapper{
            public Asset asst {get;set;}
            public boolean isAcct {get;set;}
            public AssetWrapper(Asset ac, String acctId){
                asst = ac;
                If(acctId != null && acctId.equals(ac.AccountId)){
                    isAcct = true;
                }else{
                    isAcct = false;
                }
            }
    }
	
	public class EntitlementWrapper{
        public boolean keepEntitlement {get;set;}
        public Core_Contact_Entitlement__c ent {get;set;}
        public EntitlementWrapper( Core_Contact_Entitlement__c cce, Boolean flag){
            keepEntitlement = flag;
            ent = cce;
        }
    }

    public class ResponseModel{
        public boolean IsError {get;set;}
        public String errorMessage {get;set;}
    }
}