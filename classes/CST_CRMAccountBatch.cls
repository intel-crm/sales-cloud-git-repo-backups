public class CST_CRMAccountBatch implements Database.Batchable<sObject>,Database.Stateful  {

     public Set<Id> duplicateAccIds = new Set<Id>();
     public String loggedUserEmail = UserInfo.getUserEmail();
     public set<id> allFailedId=new set<id>();
     public set<id> allSuccessId=new set<id>();
     public Map<Id,String> errorMap = new Map<Id,String>();
     public set<id> allFailedAFId=new set<id>();
     public set<id> allSuccessAFId=new set<id>();
 
   public Database.QueryLocator start(Database.BatchableContext context) {
        List<SPM_Planning_Period__c> planningRec = [Select Id,Name,Active__c,Planning_Period__c  FROM SPM_Planning_Period__c WHERE Active__c=true ORDER BY CreatedDate DESC LIMIT 1];
        String planningPeriod =  planningRec[0].Planning_Period__c;
       //	system.debug('ACC PLANNING PERIOD:'+planningPeriod);
        String soqlQuery = 'SELECT Id,Name,GM_Feedback__c,Customer_Name__c,Customer_ID__r.Planning_Period__c FROM SPM_Customer_Feedback__c WHERE GM_Feedback__c =\'Approved\' AND Customer_ID__r.Core_PlanningPeriod__c=:planningPeriod';
        return Database.getQueryLocator(soqlQuery);
    }
    
    public void execute(Database.BatchableContext context, List<SPM_Customer_Feedback__c> scope) {
        
        Set<Id> customerIdSet = new Set<Id>(); 
        List<SPM_Account_Feedback__c> accFeedbackList = new List<SPM_Account_Feedback__c>();
        List<Account> finalCRMAccountList = new List<Account>();
        List<Account> crmList = new List<Account>();
        Map<Id,SPM_Account_Feedback__c> accIdCRMAccount = new Map<Id,SPM_Account_Feedback__c>();
        List<SPM_Account_Feedback__c> accFeedBackUpdateList = new List<SPM_Account_Feedback__c>();
        List<Id> dupAccFeedbackId = new List<Id>();
        Set<Id> uniqueAccId = new Set<Id>();
        
       
      //  system.debug('Inside CST_CRMAccountUpdate_Batch execute:'+scope.size());
       
        //Populate customer ids from Customer Feedback Records 
        for(SPM_Customer_Feedback__c customerFeedback:scope){
            customerIdSet.add(customerFeedback.Customer_ID__c);
        }
               
        //Fetch Account Feedback records based on CustomerId 
        accFeedbackList = [SELECT Id,Account_ID__c,Account_Name__c,New_Account_Owner__c,New_Sales_Group__c,Account_ID__r.SF_Account__c,Feedback__c,CRM_CST_New_Core_Account_Category__c,Coverage_Type__c FROM SPM_Account_Feedback__c WHERE Account_ID__r.SPM_Customer_ID__c IN:customerIdSet AND (New_Account_Owner__c!=null OR New_Sales_Group__c!=null OR Coverage_Type__c!=null OR CRM_CST_New_Core_Account_Category__c!=null) AND SF_Account_Updated__c=false ORDER BY Account_ID__r.SF_Account__c];
        
      //  system.debug('Account feedback list is:'+accFeedbackList);
      //  system.debug('Account feedback list size is:'+accFeedbackList.size());
        
       Map<String, CST_CustomerFeedback_Account_Sync__mdt> coverageMetadata = CST_CustomerFeedback_Account_Sync__mdt.getAll();
      // system.debug('CST COVERAGE'+coverageMetadata);
        
        //Loop through Account Feedback Records and check if duplicate feedbacks exist with differnt sales grp or account owner
        //First time a record comes in the loop its account id will be populated as a key in accIdCRMAccount Map
        //If another feedback with same account id and different sales/owner then it would enter if condition and its id is added in duplicateAccIds
        for(SPM_Account_Feedback__c accFeedbackRec:accFeedbackList){
            if(accIdCRMAccount.containsKey(accFeedbackRec.Account_ID__r.SF_Account__c) && ((accFeedbackRec.New_Account_Owner__c!=accIdCRMAccount.get(accFeedbackRec.Account_ID__r.SF_Account__c).New_Account_Owner__c || accFeedbackRec.New_Sales_Group__c!=accIdCRMAccount.get(accFeedbackRec.Account_ID__r.SF_Account__c).New_Sales_Group__c
               || accFeedbackRec.CRM_CST_New_Core_Account_Category__c!=accIdCRMAccount.get(accFeedbackRec.Account_ID__r.SF_Account__c).CRM_CST_New_Core_Account_Category__c) ||
               accFeedbackRec.Coverage_Type__c!=accIdCRMAccount.get(accFeedbackRec.Account_ID__r.SF_Account__c).Coverage_Type__c)){
               duplicateAccIds.add(accFeedbackRec.Account_ID__r.SF_Account__c);
                 dupAccFeedbackId.add(accFeedbackRec.Id);
            }
            else{
      //      system.debug('AccFeedback is:'+ accFeedbackRec.Account_Name__c+'New owner:'+accFeedbackRec.New_Account_Owner__c+'New Sales grp:'+accFeedbackRec.New_Sales_Group__c);
                Account acc = new Account(Id= accFeedbackRec.Account_ID__r.SF_Account__c);
                acc.Core_Account_Owner_Preview__c = accFeedbackRec.New_Account_Owner__c;
                acc.Core_Sales_Group_Preview__c = accFeedbackRec.New_Sales_Group__c;
                String coverage='';
                if(accFeedbackRec.Coverage_Type__c== coverageMetadata.get('CST_Intel_Led').Account_Feedback_Value__c ){
                	coverage = coverageMetadata.get('CST_Intel_Led').Account_Value__c;
                 }
                 else if(accFeedbackRec.Coverage_Type__c== coverageMetadata.get('CST_Partner_Led').Account_Feedback_Value__c ){
          			coverage = coverageMetadata.get('CST_Partner_Led').Account_Value__c;
                  }
                 else if(accFeedbackRec.Coverage_Type__c== coverageMetadata.get('CST_Not_Covered_Account').Account_Feedback_Value__c ){
                 	coverage = coverageMetadata.get('CST_Not_Covered_Account').Account_Value__c;
                  }
                  else if(accFeedbackRec.Coverage_Type__c== coverageMetadata.get('CST_Other_led_Account').Account_Feedback_Value__c ){
                  	coverage = coverageMetadata.get('CST_Other_led_Account').Account_Value__c;
                  }
                acc.Core_Account_Primary_Coverage_Preview__c = coverage;
                acc.Core_Account_Category_Preview__c = accFeedbackRec.CRM_CST_New_Core_Account_Category__c;  
                accIdCRMAccount.put(accFeedbackRec.Account_ID__r.SF_Account__c,accFeedbackRec);
          //      system.debug('Map key is:'+accFeedbackRec.Account_ID__r.SF_Account__c+':Map value is:'+accFeedbackRec);
                //Avoid adding same Account twice to finalCRMAccountList
                if(!uniqueAccId.contains(acc.Id)){
                   finalCRMAccountList.add(acc);
                   uniqueAccId.add(acc.Id);
                }
                
            }
        }
    //    system.debug('Accountmap is:'+accIdCRMAccount);
      //  system.debug('Duplicate accIds is:'+duplicateAccIds);
    
         //If accId present in duplicateIds ignore those records
         //Add the remaining Account records to crmList to update
        for(Account acc:finalCRMAccountList){
              if(!duplicateAccIds.contains(acc.Id)){
                  crmList.add(acc);
                 }
            }
        
         Database.SaveResult[] myResult=Database.update(crmList,false);
        
        for(Integer i=0; i < myResult.size(); i++) {
          if(myResult.get(i).isSuccess()) {
              allSuccessId.add(myResult.get(i).Id);
      //          System.debug('Records are updated Successfully'+allSuccessId);
             } 
             else if(!myResult.get(i).isSuccess()) {
               Database.Error errors =  myResult.get(i).getErrors().get(0);
       //         System.debug('Error Occurs While Processing The Record'+errors.getMessage());
                allFailedId.add(crmList.get(i).Id);
                errorMap.put(crmList.get(i).Id,errors.getMessage());
             }
      	}
    
        //Update Account Feedback records-> SF_Account_Updated__c= true for processed records
        for(SPM_Account_Feedback__c afRec:accFeedbackList ){
          if(allSuccessId.contains(afRec.Account_ID__r.SF_Account__c)){
              afRec.SF_Account_Updated__c = true;
              accFeedBackUpdateList.add(afRec);
             }
        }
        Database.SaveResult[] afResults;
        if(accFeedBackUpdateList.size()>0){
            afResults = Database.update(accFeedBackUpdateList,false);
        //    system.debug('afResults --'+afResults);
        }
        for(Integer i=0; i < afResults.size(); i++) {
                if(afResults.get(i).isSuccess()) {
                    allSuccessAFId.add(afResults.get(i).Id);
       //             System.debug('AF Records are updated Successfully'+allSuccessId);
                } 
                else if(!afResults.get(i).isSuccess()) {
                    Database.Error errors =  afResults.get(i).getErrors().get(0);
         //           System.debug('AF Error Occurs While Processing The Record'+afResults.get(i).Id+' '+errors.getMessage());
                    allFailedAFId.add(afResults.get(i).Id);
                }        
 
    	}
     //   system.debug('AF SUCCESS ID:'+allSuccessAFId);
     //   system.debug('AF SUCCESS ID SIZE:'+allSuccessAFId.size());
     //   system.debug('AF FAILED ID:'+allFailedAFId);
     //   system.debug('AF FAILED ID SIZE:'+allFailedAFId.size());
        
    }
    
    public void finish(Database.BatchableContext context) {
        String orgName='';
        Organization org = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
        if(org.IsSandbox){
            orgName = DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName();
        }
        else{
            orgName = 'Production';
        }
        String mailBody = 'CRM Update is completed' +'<br/>';
        
     //   system.debug('Inside finish dupAccIds:'+duplicateAccIds.size());
         
        if(allSuccessId.size()>0){
          mailBody +='The following CRM Accounts were updated successfully';   
          mailBody += '<table border="1" style="width:50%"><tr><th>Account Id</th><th>Account Name</th></tr>';
           List<Account> successList =[select Id,Name from Account where Id IN:allSuccessId];
            for(Account successAccRec: successList){
                mailBody+= '<tr><td>'+successAccRec.Id+'</td><td>'+successAccRec.Name+'</td></tr>';
            }
         mailBody += '</table>';
        }
        
        if(duplicateAccIds.size()>0){
           mailBody += 'Duplicate feedback exist for the same account with different values for Account Owner,Sales Group,Account Category,Account Primary Coverage' +'<br/>'+'Please ensure the values are unqiue across all customers<br/>';
           mailBody += '<table border="1" style="width:50%"><tr><th>Account Id</th><th>Account Name</th></tr>';
           List<Account> dupList =[select Id,Name from Account where Id IN:duplicateAccIds];
            for(Account dupRec: dupList){
                mailBody+= '<tr><td>'+dupRec.Id+'</td><td>'+dupRec.Name+'</td></tr>';
            }
         mailBody += '</table>';
        }
        
        if(allFailedId.size()>0){
             mailBody +='<br/>The following CRM records failed during update:';
             mailBody += '<table border="1" style="width:50%"><tr><th>Account Id</th><th>Account Name</th><th>Error</th></tr>';
            List<Account> failedList =[select Id,Name from Account where Id IN:allFailedId];
             for(Account failedAccRec: failedList){
                 mailBody+= '<tr><td>'+failedAccRec.Id+'</td><td>'+failedAccRec.Name+'</td></tr>'+errorMap.get(failedAccRec.Id)+'</td></tr>';
            }
            mailBody += '</table>';
         }
        
     //    system.debug('Logged in user is'+loggedUserEmail);
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String fromEmailAddress = System.Label.Core_SetFromEmailAddress;
         mail.setToAddresses(new String[] {loggedUserEmail});
         mail.setReplyTo('wsm-postmaster@intel.com');
         //mail.setSenderDisplayName('Intel Corporation-NoReply');
         mail.setSubject('CST CRM Update');
         mail.setHtmlBody(mailBody);
         mail.setOrgWideEmailAddressId(fromEmailAddress);
            
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        
    }
    
    @invocablemethod(label='executeCRMAccountBatch')

    public static void executeCRMAccountBatch()

    {
        Integer batchSize= Integer.valueOf(Core_CRM_Utility.getCRMLabel('CST_CRMAccounUpdateBatchSize'));
    
        Id jobId = Database.executeBatch(new CST_CRMAccountBatch(),batchSize);

    }
    
}