public with sharing class CST_ApproveRejectController {
  @InvocableMethod(label='Get getAccountDetails ' description='Returns the list of account detail')
  public static List<Account> getAccountDetails(List< flowRequest> flowRequests) {
     
      List<SPM_Account_Detail__c> accDetailList = new List<SPM_Account_Detail__c>();
      String strQuery='';
      for(flowRequest flowReq:flowRequests){
          strQuery ='SELECT Id,Name,VP__c,GM__c FROM SPM_Account_Detail__c WHERE SPM_Customer_ID__c IN:'+flowReq.customerId+' AND';
          
          if(flowReq.isVP || flowReq.isCM){
              strQuery+='VP__c=:'+flowReq.feedbackBy+' AND VP__c=NULL';
          }
           if(flowReq.isCM){
              strQuery+='VP__c=:'+flowReq.feedbackBy+' AND VP__c=NULL';
          }
          if(flowReq.isGM){
             strQuery+='GM__c=:'+flowReq.feedbackBy+' AND GM__c=NULL';
          }
      }
      system.debug('Strquery is:'+strQuery);
     return Database.query(strQuery);
     
  }
        public class flowRequest{
        
        @InvocableVariable(required=true)
        public Id customerId;
        
        @InvocableVariable
        public Id feedbackBy;
        
        @InvocableVariable
        public boolean isVP;
        
        @InvocableVariable
        public boolean isCM;
        
        @InvocableVariable
        public boolean isGM;
    }
}