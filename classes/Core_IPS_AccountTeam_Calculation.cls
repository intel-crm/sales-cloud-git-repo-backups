public without sharing class Core_IPS_AccountTeam_Calculation {
    public Id accId{get;set;}
    List<AccountShare> ashareList;
    List<AccountShare> aShareInsertList;
    List<Core_Account_Team__c> custom_atmList;    
    List<Core_Account_Team__c> toUpdateList;
    List<Core_Account_Team__c> toInsertList;
    List<Core_Account_Team__c> toDeleteList;
    public string context{get;set;}
    public String successStatus {get;set;} /* US967150 --- 02/06/21--- Sai krishna--- Stored XSS--- appsec security vulnerability */
    public Batch_Processing_Line_Item__c lineItem{get;set;}
    public id batchProcessingId{get;set;}
    public Core_IPS_AccountTeam_Calculation(ApexPages.StandardController controller) {
        accId = ApexPages.currentPage().getParameters().get('id');
        ashareList = new List<AccountShare>();
        aShareInsertList = new List<AccountShare>();
        
        custom_atmList = new List<Core_Account_Team__c>();
        toUpdateList = new List<Core_Account_Team__c>();
        toInsertList = new List<Core_Account_Team__c>();
        toDeleteList = new List<Core_Account_Team__c>();
    }
    
    public Core_IPS_AccountTeam_Calculation(){
        ashareList = new List<AccountShare>();
        aShareInsertList = new List<AccountShare>();
        custom_atmList = new List<Core_Account_Team__c>();
        toUpdateList = new List<Core_Account_Team__c>();
        toInsertList = new List<Core_Account_Team__c>();
        toDeleteList = new List<Core_Account_Team__c>();
    }
    public pagereference calculateTeam(){      
      if(accId <> null){
          if(Test.isRunningTest()){
              //FLS Check Added - Yasasvi
              if(accountshare.SObjectType.getDescribe().isAccessible()){
              aShareList = [select rowcause, caseaccesslevel, opportunityaccesslevel, accountaccesslevel, userorgroupid, accountid from accountshare where accountid in(select AccountId from Accountteammember) and userorgroupid in(select userid from Accountteammember) and AccountId =:accId];
                  }
          }else{
              //FLS Check Added - Yasasvi
              if(accountshare.SObjectType.getDescribe().isAccessible()){
              aShareList = [select rowcause, caseaccesslevel, opportunityaccesslevel, accountaccesslevel, userorgroupid, accountid from accountshare where accountid in(select AccountId from Accountteammember) and userorgroupid in(select userid from Accountteammember) and AccountId =:accId and Rowcause = 'Team'];
                  }
          }
          //FLS Check Added - Yasasvi
          if(Core_Account_Team__c.SObjectType.getDescribe().isAccessible()){
          custom_atmList = [select Id,Core_Team_Member__c,Core_Case_Access__c,Core_Account__c,Core_Opportunity_Access__c,Core_Account_Access__c from Core_Account_Team__c where Core_Account__c =:accId];
          }
      }
      if(aShareList <> null && aShareList.size() > 0){
          for(AccountShare actShareObj:aShareList){
              Boolean isMatched = False; 
              if(custom_atmList <> null && custom_atmList.size() > 0){
                  for(Core_Account_Team__c custATObj:custom_atmList){
                      if(actShareObj.UserOrGroupId == custATObj.Core_Team_Member__c){
                          isMatched =True;                         
                          //[March/16/2016 : Added below if condition to only update the related Custom Account Team records when there is any change in Opportunity/Case/Account AccessLevel.]
                          if(custATObj.Core_Opportunity_Access__c <> actShareObj.opportunityaccesslevel
                          || custATObj.Core_Case_Access__c <> actShareObj.caseaccesslevel || custATObj.Core_Account_Access__c <> actShareObj.accountaccesslevel){
                              custATObj.Core_Opportunity_Access__c = actShareObj.opportunityaccesslevel;
                              custATObj.Core_Case_Access__c = actShareObj.caseaccesslevel;
                              custATObj.Core_Account_Access__c = actShareObj.accountaccesslevel;
                              toUpdateList.add(custATObj);                                                            
                          }
                      }
                  }
              }
              if(isMatched == False){
                  aShareInsertList.add(actShareObj);
              }
          }
          if(aShareInsertList <> null && aShareInsertList.size() > 0){
              for(AccountShare aShareObj : aShareInsertList){
                  Core_Account_Team__c custom_AT = new Core_Account_Team__c(Core_Account__c = aShareObj.AccountId, 
                                                                            Core_Team_Member__c=aShareObj.UserOrGroupId,
                                                                            Core_Opportunity_Access__c = aShareObj.opportunityaccesslevel, 
                                                                            Core_Case_Access__c = aShareObj.caseaccesslevel,
                                                                            Core_Account_Access__c = aShareObj.accountaccesslevel                                                                            
                                                                            );
                  toInsertList.add(custom_AT);                  
              }                
          }
      }  
      if(custom_atmList <> null && custom_atmList.size() > 0){        
            for(Core_Account_Team__c custATObj:custom_atmList){      
                  Boolean isMatched = False; 
                  if(aShareList <> null && aShareList.size() > 0){
                      for(AccountShare actShareObj:aShareList){
                          if(actShareObj.UserOrGroupId == custATObj.Core_Team_Member__c){
                              isMatched =True;                                                            
                          }
                      }
                  }
                  if(isMatched == False){
                      toDeleteList.add(custATObj);
                  }
            }              
      }      
         
      try{
          if(toInsertList <> null && toInsertList.size() > 0){
              if(context=='Batch'){
                lineItem.Core_Change_Log__c+='<tr><th>New AccountTeam Members</th><th>'+toInsertList.size()+'</th></tr>';
                lineItem.Core_Number_of_Inserts__c = toInsertList.size();
              }
              insert toInsertList;
              
          }
          if(toUpdateList <> null && toUpdateList.size() > 0){

            if(context=='Batch'){
                lineItem.Core_Change_Log__c+='<tr><th>Updated AccountTeam Members</th><th>'+toUpdateList.size()+'</th></tr>';
                lineItem.Core_Number_of_Updates__c = toUpdateList.size();
              }
              update toUpdateList;
          }
          if(toDeleteList <> null && toDeleteList.size() > 0){

            if(context=='Batch'){
                lineItem.Core_Change_Log__c+='<tr><th>Deleted AccountTeam Members</th><th>'+toDeleteList.size()+'</th></tr>';
                lineItem.Core_Number_of_Deletes__c = toDeleteList.size();
              }
              delete toDeleteList;
          }
          if(context=='Batch'){
               lineItem.Core_Change_Log__c+='</table>';
               insert lineItem;
           }
          successStatus = 'true'; /* US967150 --- 02/06/21--- Sai krishna--- Stored XSS--- appsec security vulnerability */
          return null;
      }catch(Exception e){
        lineItem.Exception_Log__c = e.getMessage();
        return null;
      }
    }

    public void calcuateTeam(String accountId,String context, Id batchProcessingId){
        this.batchProcessingId=batchProcessingId;
        this.context=context;
        lineItem=new Batch_Processing_Line_Item__c();
        lineItem.Batch_Processing__c = batchProcessingId;
        lineItem.Core_Change_Log__c='<table><tr><th>Batch Started</th><th>'+accountId+'</th></tr>';
        accId = accountId;
        calculateTeam();
    }
 
    /***************************************************************************************************
    Method Name:  CancelAction
    Method Type: Action Method 
    Version     : 1.0 
    Created Date: 14 Nov 2015
    Function    : used to return to the case tab
    Input Parameters: None 
    Output Parameters: None
    Description:   used to return to the case tab
    Used in     : Case Escalate
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              Nov/12/2015              Created
    ****************************************************************************************************/     
    //public PageReference CancelAction(){
       /*PageReference pg = new PageReference('/'+csRecord.id); 
       pg.setRedirect(true);
       return pg;*/
    //   return null;
    //}

}