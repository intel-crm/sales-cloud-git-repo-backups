/*********************************************************************************************************************
Class Name    : Sales_UpdateAccountOnContact_Queuable
Version       : 1.0
Created Date  : June 2022
Function      : This Queuable class will pick all those Contacts which were created 3 months prior to the current System date and check if there are 
                no Licenses, Hosts and Delegate Admin relation associated to them (identifying as a stale contact) and will move them to another Stale Account

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Bharath Kumar           13-June-2022            TWC3144-429 Card in Jira
* *********************************************************************************************************************/

global class Sales_UpdateAccountOnContact_Queuable implements Queueable {
    
     private static final string ORIGIN = 'Sales_UpdateAccountOnContact_Queuable';
     private static final string SEVERITY = 'info';
     private static final string PROJECT = 'Sales';
    // public static boolean isBatchClassRunning = false;

     global void execute(QueueableContext SC) {
           
        Set<Id> staleContactIds = new Set<Id>();
       
        Sales_Update_Account_On_Contact__mdt metaData = [Select Id,MasterLabel, Sales_Source_Account_ID__c, Sales_Target_Account_ID__c, Sales_Run_Account_Update__c, Sales_Created_Since_Days__c from Sales_Update_Account_On_Contact__mdt where Sales_Is_Mdt_Rec_Active__c = true LIMIT 1];
		
       if(metaData.Sales_Run_Account_Update__c){
         
         String sourceAccountID = metaData.Sales_Source_Account_ID__c;
         String targetAccountID = metaData.Sales_Target_Account_ID__c;
         Integer days = Integer.valueOf((metaData.Sales_Created_Since_Days__c));
           
         String query = 'Select Id from Contact where AccountID ='+' and CreatedDate != LAST_'+'_DAYS';
        // Extract all Stale Contact Ids         
         Map<Id,Contact> staleContactMap = new Map<Id,Contact>([Select Id from Contact where AccountID = '0012D00000WxLh2QAF'  and CreatedDate != LAST_90_DAYS]);
         staleContactIds.addAll(staleContactMap.keySet());
           
           if(!staleContactIds.isEmpty()){       
               
               Set<Id> contactsToBeExcludedSet1 = new Set<Id>();
                              
               // Pick all Contacts that are assocaited to a License and add them to the Set of Contacts that needs to be excluded
               
               for( Sales_License__c lic : [Select Id,Name,Sales_License_Primary_Admin_Contact__c,Sales_License_Lic_User_Contact_ID__c from Sales_License__c where (Sales_License_Primary_Admin_Contact__c != null OR Sales_License_Lic_User_Contact_ID__c != null ) 
                                                   AND ( (Sales_License_Primary_Admin_Contact__c IN:staleContactIds) OR (Sales_License_Lic_User_Contact_ID__c IN:staleContactIds)) ]){
               
                   
                   if( lic.Sales_License_Primary_Admin_Contact__c != null){           
                       contactsToBeExcludedSet1.add(lic.Sales_License_Primary_Admin_Contact__c);         
                   }else if(lic.Sales_License_Lic_User_Contact_ID__c != null){
                       contactsToBeExcludedSet1.add(lic.Sales_License_Lic_User_Contact_ID__c);         
                   }               
               
               }
               
               // Removing all the Contacts that are associated to a license from the stale contacts Set
               if(!contactsToBeExcludedSet1.isEmpty()){
                 staleContactIds.removeAll(contactsToBeExcludedSet1);
               }
               
               // Pick all Contacts that are assocaited to a Host and add them to the Set of Contacts that needs to be excluded
                Set<Id> contactsToBeExcludedSet2 = new Set<Id>();
               
               for( Sales_Host__c host : [Select Id,Sales_Contact__c from Sales_Host__c where (Sales_Contact__c != null) 
                                                                       AND ( Sales_Contact__c IN:staleContactIds) ]){
               
                   
                 contactsToBeExcludedSet2.add(host.Sales_Contact__c);    
               
               }
               
               // Removing all the Contacts that are associated to a Host from the stale contacts Set
               if(!contactsToBeExcludedSet2.isEmpty()){
                  staleContactIds.removeAll(contactsToBeExcludedSet2);
               }
             
           }
                   
             //Contact Batch Data Update Starts here
             
             if(!staleContactIds.isEmpty()){                  
                 
                 List<Contact> contactsToBeUpdated = null;
                 
                                        
                  try{              
                   System.debug('Contact Object Validation Rules Switched off for Batch Data Update ');
                   
                      for(Contact con : [Select Id,Name,AccountId from Contact where Id IN:staleContactIds ] ){
                          
                          con.AccountID = '0012D00000e8wroQAA';
                          contactsToBeUpdated.add(con);
                      }
                      
                   Database.SaveResult[] results = Database.update(contactsToBeUpdated, false);               
                   
                   for( Database.SaveResult sr : results){
                       if(sr.isSuccess()){
                           System.debug('Account updated succesfully for the Contacts - ');
                       }else{
                           for(Database.Error err : sr.getErrors()){
                              Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Line 93', SEVERITY,null, err.getMessage(),null,'', '');  
                           }
                       }
                   }
                   System.enqueueJob(new Sales_UpdateAccountOnContact_Queuable());
                   
               }catch(Exception e){
                    Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Line 100', SEVERITY,null, e.getMessage(),null,'', '');
               }
             }
         
    	 }
     }
}