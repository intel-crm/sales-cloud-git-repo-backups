/**************************************************************************************************************
Apex Class Name:  PartnerRoleInfo
Version     : 1.0 
Created Date: 28 Jan 2020
Function    : It act as wrapper class which is used in PRM_CIMAccountSearch.apxc and PRM_searchsfdcAccounts.apxc
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Prasant Sahu         02/06/2020        Initial version
***************************************************************************************************************/
global class PartnerRoleInfo{
        public String PartnerRole;
        public String Tier;
        public String status;
        public Datetime statusChangeDt;
        public PartnerRoleInfo(String ptnrRole, String inputTier, String inputStatus, Datetime inputChangeDt){
            PartnerRole = ptnrRole;
            Tier = inputTier;
            status = inputStatus;
            statusChangeDt = inputChangeDt;
        }
    }