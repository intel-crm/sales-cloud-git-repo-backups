global class ER_ENT_PRG_CIMAccountSearchInfo {

    public String AccountName;
        public Address AccountAddress;
    	//public List<PRM_CIMAccountSearch.AccountLegalAgreement> AccountLegalAgreements;
    public List<ER_ENT_PRG_AccountSearch.AccountLegalAgreement> AccountLegalAgreements;
            
    public List<PartnerRoleInfo> partnerRolesInfo;
        public String AccountID;
        public String CimID;
        public String IPABadge; 
     // public CIMAccountSearchInfo(String accName, Address add, List<PRM_CIMAccountSearch.AccountLegalAgreement> legalAgreement, List<PartnerRoleInfo> roles, String sfdId, String cimIds, String badge){
    public ER_ENT_PRG_CIMAccountSearchInfo(String accName, Address add, List<ER_ENT_PRG_AccountSearch.AccountLegalAgreement> legalAgreement, List<PartnerRoleInfo> roles, String sfdId, String cimIds, String badge){
         
    		AccountName = accName;
            AccountAddress = add;
            AccountLegalAgreements =legalAgreement;
            partnerRolesInfo = roles;
            AccountID = sfdId;
            CimID = cimIds;
            IPABadge = badge;
        }
    public ER_ENT_PRG_CIMAccountSearchInfo(String accName, Address add, String sfdId, String cimIds){
        AccountName = accName;
        AccountAddress = add;
        AccountID = sfdId;
        CimID = cimIds;
    }
    
}