/**************************************************************************************************************
Apex Class Name:  PRM_SearchAccountsNew  
Version     : 1.0 
Created Date: Jan 2022
Function    : Wrapper to sort the SBC Results
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
*Sathya                Jan 2022           Initial version
***************************************************************************************************************/
global class PRM_SearchAccountsNew implements Comparable{
    public Id AccountId{ get;  set;}
    public String accCIMId{ get; set;}
    public String accUnifiedId{get ; set;}//TWC729-7726 : Cim Prime EOL
    public Account acc{ get;set;}
    public Integer searchScore{get;set;}
    public string ipabadge{get;set;}
    public integer priority{get;set;}
    public integer IPARank{get;set;}   
    public list<PartnerRoleInfo> partnerrolesinfo{get;set;}
    public list<AccountLegalAgreement> AccountLegalAgreements{set;get;}
   
    public class PartnerRoleInfo{
        public String PartnerRole;    
        public String Tier;
        public String status;
        public Datetime statusChangeDt;
        public PartnerRoleInfo(string pr,string tir,string sta,DateTime stdt){
            this.PartnerRole=pr;
            this.Tier=tir;
            this.status=sta;
            this.statusChangeDt=stdt;
        }
        
    }
    public class AccountLegalAgreement{   
        public DateTime AgreementSignedDate;
            public AccountLegalAgreement(DateTime inputAgreementSignedDate){
                AgreementSignedDate = inputAgreementSignedDate;           
            }
    }   
   
    public PRM_SearchAccountsNew(Id AccountId,String cimId,String unifiedid, Account acc, Integer searchScore,string ipabadge2,integer pri,integer IPARak,list<PartnerRoleInfo> partnerrolesinfo2){
        this.AccountId = AccountId;
        this.acc = acc;
        this.searchScore = searchScore;
        this.accCIMId = cimId;
        this.accUnifiedId = unifiedid;//TWC729-7726 : Cim Prime EOL
        this.ipabadge = ipabadge2;
        this.priority=pri;
        this.IPARank=IPARak;
        this.partnerrolesinfo = partnerrolesinfo2;
    }
    
/***********************************Comparable method to Sort the Accounts************************************************/
    public Integer compareTo(Object obj) {
        PRM_SearchAccountsNew compareToRec = (PRM_SearchAccountsNew)(obj);
       if (this.priority > compareToRec.priority ) {
           return 1;
       } else if (this.priority  < compareToRec.priority ) {
            return -1;
        } 
        else  {
            // First value the same, consider second value
            if (this.searchScore > compareToRec.searchScore) {
            return -1;
            } else if (this.searchScore < compareToRec.searchScore) {
            return 1;
            } else {
                // If Second value the same, consider third value
                if(this.IPARank > compareToRec.IPARank){
                return 1;
                }
                else if (this.IPARank < compareToRec.IPARank) {
                return -1;
                }
                else{
                return 0;
                }
            }          
        }  
   }
}