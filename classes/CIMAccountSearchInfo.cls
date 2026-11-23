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
        public List<PartnerRoleInfo> partnerRolesInfo;
        public String AccountID;
        public String CimID;
        public String IPABadge; 
        public CIMAccountSearchInfo(String accName, Address add, List<PartnerRoleInfo> roles, String sfdId, String cimIds, String badge){
            AccountName = accName;
            AccountAddress = add;
            partnerRolesInfo = roles;
            AccountID = sfdId;
            CimID = cimIds;
            IPABadge = badge;
        }		
    }