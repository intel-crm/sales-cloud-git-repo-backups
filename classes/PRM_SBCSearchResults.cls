/*********************************************************************************************************************
Apex Class Name  : PRM_SBCSearchResults
Version       : 1.0
Created Date  : jan 2022
Function      : Wrapper class to hold final search result to AEM on SBC API Callout

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Sathya                Jan 2022           Initial version
*********************************************************************************************************************/

public class PRM_SBCSearchResults{
    public list<SearchResults> SearchResults{get;set;}
    public class SearchResults{
            public String AccountID{get;set;}
            public list<PRM_SearchAccountsNew.AccountLegalAgreement> AccountLegalAgreements{get;set;}
            public String IPABadge{get;set;}
            public list<PRM_SearchAccountsNew.PartnerRoleInfo> partnerRolesInfo{get;set;}
            public String CimID{get;set;}
            public String UnifiedId{get;set;}//TWC729-7726 : Cim Prime EOL
            public Address AccountAddress{get;set;}
            public String AccountName{get;set;}
         	public String AccountURL{get;set;}
        public SearchResults(String accName, Address add,List<PRM_SearchAccountsNew.AccountLegalAgreement> inputAccountLegalAgreements, List<PRM_SearchAccountsNew.PartnerRoleInfo> roles, String sfdId, String cimIds,String unifiedIds, String badge,String website){
                AccountName = accName;
                AccountAddress = add;
                AccountLegalAgreements=inputAccountLegalAgreements;
                partnerRolesInfo = roles;
                AccountID = sfdId;
                CimID = cimIds;
                UnifiedId = unifiedIds;//TWC729-7726 : Cim Prime EOL
                IPABadge = badge;
            	AccountURL=website;
            }
        }
    
    public class partnerRolesInfo{
        public String PartnerRole{get;set;}
        public String status{get;set;}
        public String statusChangeDt{get;set;}
        public String Tier{get;set;}
    }
    public class AccountAddress{
        public String StateCode2{get;set;}
        public String City{get;set;}
        public String AddressLine2{get;set;}
        public String CountryCode2{get;set;}
        public String AddressLine1{get;set;}
        public String PostalCode{get;set;}
    }
}