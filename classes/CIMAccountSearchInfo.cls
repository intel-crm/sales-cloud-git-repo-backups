/**************************************************************************************************************
Apex Class Name:  CIMAccountSearchInfo
Version     : 1.0 
Created Date: 28 Jan 2020
Function    : This wrapper class holds the response of the filtered result
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Prasant Sahu         01/28/2020        Initial version
***************************************************************************************************************/

global class CIMAccountSearchInfo {
        public String AccountName;
        public Address AccountAddress;
        public List<POC_CIMAccountSearch.AccountLegalAgreement> AccountLegalAgreements; //Added by Agate Team as part of TWC729-125
        public List<PartnerRoleInfo> partnerRolesInfo;
        public String AccountID;
        public String CimID;
        public String IPABadge; 
        public CIMAccountSearchInfo(String accName, Address add,List<POC_CIMAccountSearch.AccountLegalAgreement> inputAccountLegalAgreements, List<PartnerRoleInfo> roles, String sfdId, String cimIds, String badge){
            AccountName = accName;
            AccountAddress = add;
            AccountLegalAgreements=inputAccountLegalAgreements;
            partnerRolesInfo = roles;
            AccountID = sfdId;
            CimID = cimIds;
            IPABadge = badge;
        }       
    }