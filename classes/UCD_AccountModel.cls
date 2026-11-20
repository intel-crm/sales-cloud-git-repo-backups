public class UCD_AccountModel implements Comparable {
    //public class UCD_AccountModel{
    @AuraEnabled
    public String accName{get;set;}
    @AuraEnabled
    public String SFaccName{get;set;}
    @AuraEnabled
    public String accType{get;set;}
    @AuraEnabled
    public String accNTier{get;set;}
    @AuraEnabled
    public String Industry{get;set;}
    @AuraEnabled
    public String accId{get;set;}
    @AuraEnabled
    public String accOwner{get;set;}
    @AuraEnabled
    public Boolean IPAFlag{get;set;}
    @AuraEnabled
    public Boolean accountDeactivated{get;set;}
    @AuraEnabled
    public Boolean noRecordsFromCim{get;set;}
    @AuraEnabled
    public String bizOrgType{get;set;}
    @AuraEnabled
    public String partnerRole{get;set;}
    @AuraEnabled
    public System.Address primaryAddress{get;set;}
    @AuraEnabled
    public string primaryAddressAcc{get;set;}
    @AuraEnabled
    public string address{get;set;}
    @AuraEnabled
    public String cimID{get;set;}
    @AuraEnabled
    public Boolean sourceSystemCIM{get;set;}
    @AuraEnabled
    public String searchScore{get;set;}
    @AuraEnabled
    public String Country{get;set;}
    @AuraEnabled
    public String State{get;set;}
    @AuraEnabled
    public String CountryCode{get;set;}
    @AuraEnabled
    public String StateCode{get;set;}
    @AuraEnabled
    public String City{get;set;}
    @AuraEnabled
    public String postalCode{get;set;}
    @AuraEnabled
    public String fullAddress{get;set;}
    @AuraEnabled
    public Boolean salescouldAccount{get;set;}
    @AuraEnabled
    public String RecordTypeId{get;set;}
    
    public UCD_AccountModel(){
        //Intentionally created constructor
    }
    
    public UCD_AccountModel(String accid, String searchScore){
        this.accId = accId;
        this.searchScore = searchScore;
        if(String.isNotEmpty(accId)){
            salescouldAccount = true;
        } else {
            salescouldAccount = false;
        }
    }
    /*Logic for performing Sorting on the results where:
    * 1st pref if record has Salesforce id and Searchscore is FullDulp
	* 2nd pref if record has Salesforce id and Searchscore is PartDup
	* 3rd pref if record has NO Salesforce id and Searchscore is FullDup
	* 2nd pref if record has NO Salesforce id and Searchscore is PartDup
	*/
    public Integer compareTo(Object compareTo){
        UCD_AccountModel otherContact = (UCD_AccountModel)compareTo;
        if(salescouldAccount == otherContact.salescouldAccount){
            if(searchScore == otherContact.searchScore){
                return 0;
            } else if(searchScore != 'FullDup' && otherContact.searchScore == 'FullDup'){
                return 1;
            } else {
                return -1;
            }
        } else if(salescouldAccount != otherContact.salescouldAccount){
         //   } else if(salescouldAccount && otherContact.salescouldAccount){
            if(searchScore == otherContact.searchScore){
                return 0;
            } else if(searchScore != 'FullDup' && otherContact.searchScore == 'FullDup'){
                return 1;
            } else {
                return -1;
            }
        } else {
            return -1;
        }
    }
}