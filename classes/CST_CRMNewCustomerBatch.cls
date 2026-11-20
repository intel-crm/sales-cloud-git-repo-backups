public without sharing class CST_CRMNewCustomerBatch implements Database.Batchable<sObject>,Database.Stateful  {
    
     public String loggedUserEmail = UserInfo.getUserEmail();
     public set<id> allFailedId=new set<id>();
     public set<id> allSuccessId=new set<id>();
     public Map<Id,String> errorMap = new Map<Id,String>();
     public Set<Id> duplicateId = new Set<Id>();
     public set<id> allFailedCustomerId=new set<id>();
     public set<id> allSuccessCustomerId=new set<id>();
 
   public Database.QueryLocator start(Database.BatchableContext context) {
       
        //List<SPM_Planning_Period__c> planningRec = [Select Id,Name,Active__c,Planning_Period__c  FROM SPM_Planning_Period__c WHERE Active__c=true ORDER BY CreatedDate DESC LIMIT 1];
        String planningPeriod =  '';
        //system.debug('Planning period rec is:'+planningPeriod);
        String soqlQuery = 'SELECT Id,Name,SF_Account__c,GM_Feedback__c,New_Account_Owner__c,New_Sales_Group__c,Customer_category__c,Coverage__c,CRM_CST_Planning_Period__c FROM SPM_New_Accounts__c  WHERE GM_Feedback__c =\'Approved\' AND SF_Account__c!=NULL AND SF_Account_Updated__c=FALSE AND CRM_CST_Planning_Period__c=:planningPeriod AND (New_Account_Owner__c!=NULL OR New_Sales_Group__c!=NULL OR Customer_category__c!=NULL OR Coverage__c!=NULL) ORDER BY SF_Account__c';
        return Database.getQueryLocator(soqlQuery);
    }
    
    public void execute(Database.BatchableContext context, List<SPM_New_Accounts__c> scope) {
     //   system.debug('Inside scope:'+scope);
     //   system.debug('Inside scope size:'+scope.size());
        
        Map<Id,SPM_New_Accounts__c> sfAccounIdNewCustomerMap = new  Map<Id,SPM_New_Accounts__c>();
        List<Account> accList = new List<Account>();
        List<Account> finalAccList = new List<Account>();
        Map<Id,SPM_New_Accounts__c> newCustomerMap = new Map<Id,SPM_New_Accounts__c>();
        Set<Id> uniqueAccId = new Set<Id>();
        List<SPM_New_Accounts__c> customerList = new List<SPM_New_Accounts__c>();
        List<SPM_New_Accounts__c> customerListUpdated = new List<SPM_New_Accounts__c>();
       	Map<String, CST_New_Customer_Account_Sync__mdt> customerMetadata = CST_New_Customer_Account_Sync__mdt.getAll();
        
        for(SPM_New_Accounts__c newCustomer: scope){
            if(newCustomerMap.containsKey(newCustomer.SF_Account__c) && ( (newCustomer.New_Account_Owner__c!=newCustomerMap.get(newCustomer.SF_Account__c).New_Account_Owner__c || newCustomer.New_Sales_Group__c!=newCustomerMap.get(newCustomer.SF_Account__c).New_Sales_Group__c
               || newCustomer.Customer_category__c!=newCustomerMap.get(newCustomer.SF_Account__c).Customer_category__c) ||
               newCustomer.Coverage__c!=newCustomerMap.get(newCustomer.SF_Account__c).Coverage__c)){
                       duplicateId.add(newCustomer.SF_Account__c);
              //     	system.debug('DID IS:'+newCustomer.SF_Account__c);
              }
             else{

                Account acc = new Account(Id= newCustomer.SF_Account__c);
                acc.Core_Account_Owner_Preview__c = newCustomer.New_Account_Owner__c;
            	acc.Core_Sales_Group_Preview__c = newCustomer.New_Sales_Group__c;
                 //API Name for Picklist values are different in New Customer and Account Object
                 //Inorder to handle it CST_New_Customer_Account_Sync__mdt metadata is created where API Names of Picklist are saved
                 if(newCustomer.Coverage__c == customerMetadata.get('CST_Intel_Led').New_Customer_Value__c){
                 	 acc.Core_Account_Primary_Coverage_Preview__c  = customerMetadata.get('CST_Intel_Led').Account_Value__c;
                 }
                 else{
                 	acc.Core_Account_Primary_Coverage_Preview__c = newCustomer.Coverage__c;
                 }
                 String categoryPreview='';
             //    system.debug('CST CATEGORY'+customerMetadata);
                 for(String category:newCustomer.Customer_category__c.split(';')){
               //     system.debug('CAT ACC ID:'+newCustomer.SF_Account__c+'Category'+category);
                     if(category== customerMetadata.get('CST_B2B_End_user').New_Customer_Value__c ){
                        categoryPreview += customerMetadata.get('CST_B2B_End_user').Account_Value__c+';';
                     }
                    else if(category== customerMetadata.get('CST_Indirect_Billings').New_Customer_Value__c ){
          				 categoryPreview += customerMetadata.get('CST_Indirect_Billings').Account_Value__c+';';
                     }
                     else if(category== customerMetadata.get('CST_Regional_GSI_ISV_MSP').New_Customer_Value__c ){
                         categoryPreview += customerMetadata.get('CST_Regional_GSI_ISV_MSP').Account_Value__c+';';
                     }
                     else if(category== customerMetadata.get('CST_Region_Direct_OxMs').New_Customer_Value__c ){
                         categoryPreview += customerMetadata.get('CST_Region_Direct_OxMs').Account_Value__c+';';
                     }
                     else if(category== customerMetadata.get('CST_Distributors').New_Customer_Value__c ){
                         categoryPreview += customerMetadata.get('CST_Distributors').Account_Value__c+';';
                     }
                      else if(category== customerMetadata.get('CST_Regional_Retailer').New_Customer_Value__c ){
                          categoryPreview += customerMetadata.get('CST_Regional_Retailer').Account_Value__c+';';
                      }
                     else if(category== customerMetadata.get('CST_Region_Branded_Disti').New_Customer_Value__c ){
                         categoryPreview += customerMetadata.get('CST_Region_Branded_Disti').Account_Value__c+';';
                      }
                 }
             
            //    system.debug('CAT PREVIEW:'+acc.Id+' '+categoryPreview);
                acc.Core_Account_Category_Preview__c = categoryPreview;
                newCustomerMap.put(newCustomer.SF_Account__c,newCustomer);
                //Avoid adding same Account twice to accList
                if(!uniqueAccId.contains(acc.Id)){
                  accList.add(acc);
                  uniqueAccId.add(acc.Id);
                }
            }
                
        }
     //   system.debug('DUP IS:'+duplicateId);
      //  system.debug('DUP SIZDE IS:'+duplicateId.size());
         for(Account acc:accList){
            if(!duplicateId.contains(acc.Id)){
             //   system.debug('UNIQUE:'+acc.Id);
                finalAccList.add(acc);
            }
        }
        
         Database.SaveResult[] myResult=Database.update(finalAccList,false);
	   
           for(Integer i=0; i < myResult.size(); i++) {
                if(myResult.get(i).isSuccess()) {
                    allSuccessId.add(myResult.get(i).Id);
                   //     System.debug('Records are updated Successfully'+allSuccessId);
                } 
                else if(!myResult.get(i).isSuccess()) {
                    Database.Error errors =  myResult.get(i).getErrors().get(0);
               //     System.debug('Error Occurs While Processing The Record'+errors.getMessage());
                    allFailedId.add(finalAccList.get(i).Id);
                    errorMap.put(finalAccList.get(i).Id,errors.getMessage());
                }        
 
    	}
       //Update Customer records-> SF_Account_Updated__c= true for processed records
       for(SPM_New_Accounts__c customerRec:scope ){
             if(allSuccessId.contains(customerRec.SF_Account__c)){
                 	customerRec.SF_Account_Updated__c = true;
            		customerListUpdated.add(customerRec);
             }
        }
        /*Database.SaveResult[] customerResults;
        if(customerListUpdated.size()>0){
            customerResults= Database.update(customerListUpdated,false);
        }*/
        //added for testing
        Database.SaveResult[] customerResults;
        if(customerListUpdated.size()>0){
            customerResults = Database.update(customerListUpdated,false);
           // system.debug('customerResults --'+customerResults);
        }
        if(customerResults != null && !customerResults.isEmpty()){
            for(Integer i=0; i < customerResults.size(); i++) {
                if(customerResults.get(i).isSuccess()) {
                    allSuccessCustomerId.add(customerResults.get(i).Id);
                //    System.debug('NEWCUSTOMER Records are updated Successfully'+allSuccessId);
                } 
                else if(!customerResults.get(i).isSuccess()) {
                    Database.Error errors =  customerResults.get(i).getErrors().get(0);
                  //  System.debug('NEWCUSTOMER Error Occurs While Processing The Record'+errors.getMessage());
                    allFailedCustomerId.add(customerResults.get(i).Id);
                }        
    	}

        }
        
       // system.debug('CUSTOMER SUCCESS ID:'+allSuccessCustomerId);
        //added for testing end
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
        String mailBody='CRM New Customer Update is completed'+'<br/>';
        if(allSuccessId.size()>0){
          mailBody+='The following CRM Accounts were updated successfully:';   
          mailBody += '<table border="1" style="width:50%"><tr><th>Account Id</th><th>Account Name</th></tr>';
           List<Account> successList =[select Id,Name from Account where Id IN:allSuccessId];
            for(Account successAccRec: successList){
                mailBody+= '<tr><td>'+successAccRec.Id+'</td><td>'+successAccRec.Name+'</td></tr>';
            }
         mailBody += '</table>';
        }
        if(duplicateId.size()>0){
           mailBody += 'Duplicate customer exist for the same customer with different values for Account Owner,Sales Group,Account Category,Coverage' +'<br/>'+'Please ensure the values are unqiue across all customers<br/>';
           mailBody += '<table border="1" style="width:50%"><tr><th>Account Id</th><th>Account Name</th></tr>';
           List<Account> dupList =[select Id,Name from Account where Id IN:duplicateId];
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
                 mailBody+= '<tr><td>'+failedAccRec.Id+'</td><td>'+failedAccRec.Name+'</td><td>'+errorMap.get(failedAccRec.Id)+'</td></tr>';
            }
            mailBody += '</table>';
         }
        
       //  system.debug('Logged in user is'+loggedUserEmail);
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         String fromEmailAddress = System.Label.Core_SetFromEmailAddress;
         mail.setToAddresses(new String[] {loggedUserEmail});
         mail.setReplyTo('wsm-postmaster@intel.com');
         //mail.setSenderDisplayName('Intel Corporation-NoReply');
         mail.setSubject(orgName.toUpperCase()+' CST CRM Customer Update');
         mail.setHtmlBody(mailBody);
         mail.setOrgWideEmailAddressId(fromEmailAddress);  
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        
    }  
    
    @invocablemethod(label='executeCRMCustomerBatch')

    public static void executeCRMCustomerBatch()

    {
        Integer batchSize= Integer.valueOf(Core_CRM_Utility.getCRMLabel('CST_CRMAccounUpdateBatchSize'));
		
        Id jobId = Database.executeBatch(new CST_CRMNewCustomerBatch(),batchSize);

    }
    
}