/****************************************************************************************************************************************
* Class Name  : Core_MDF_CleanUpBank 
* Version     : 1.0 
* Created Date: 05-06-2020
* Modification Log :
* Developer                Date                     Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – SB         05/06/2020               Created Core_MDF_CleanUpBank for cleaning up Bank Supplier#
*****************************************************************************************************************************************/

public without sharing class Core_MDF_CleanUpBank implements Database.Batchable<sObject>, Database.Stateful {
    public static Integer supplierNumber = 1000000000;
    public static Integer bankAccountNumber = 1000;
    public static List<Id> bankIdList = new List<Id>();
    public static organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        //Add the Core_MDF_Swift_Code__c, Core_MDF_Bank_Account_Number__c, Core_MDF_Routing_Number__c, Core_MDF_DUNS__c
        String query = 'SELECT Id, Core_MDF_Supplier_Number__c, Core_MDF_Supplier_Name__c, Core_MDF_Swift_Code__c, Core_MDF_Bank_Account_Number__c, Core_MDF_Routing_Number__c, Core_MDF_DUNS__c FROM Core_MDF_Bank__c LIMIT 5';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Core_MDF_Bank__c> bankList) 
    {
        
        for(Core_MDF_Bank__c bank : bankList) 
        {
            System.debug('NZ-->Supplier Number : '+bank.Core_MDF_Supplier_Number__c);
            bank.Core_MDF_Supplier_Number__c = String.valueof(supplierNumber);
            bank.Core_MDF_Supplier_Name__c = 'Test ' + String.valueof(supplierNumber);
            bank.Core_MDF_Bank_Account_Number__c = String.valueof(bankAccountNumber);
            bank.Core_MDF_Routing_Number__c = String.valueof(bankAccountNumber);
            bank.Core_MDF_Swift_Code__c = 'ABCD' + String.valueof(bankAccountNumber) + 'EFG';
            bank.Core_MDF_DUNS__c = String.valueof(bankAccountNumber);
            supplierNumber++;
            bankAccountNumber++;
            bankIdList.add(bank.Id);
        }
        try 
        {
            //updating the banks in database
            //third parameter for Database.update - DMLOptions
            if(bankList!=null && bankList.size()>0){
                Database.SaveResult[] srList = Database.update(bankList,true);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted Bank ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Bank fields that affected this error: ' + err.getFields());
                        }
                    }
                }               
            }
        }
        catch(Exception e) 
        {
            System.debug('Exception'+e);
            //Core_MDF_CCP_UtilityClass.logError(e);
                
                
        }         
    }        
    public void finish(Database.BatchableContext BC) 
    {
                // Step 0: Create a master list to hold the emails we'll send
                List<Messaging.SingleEmailMessage> mails =
                new List<Messaging.SingleEmailMessage>();
                // Step 1: Create a new Email
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            
                // Step 2: Set list of people who should get the email
                List<String> sendTo = new List<String>();
                sendTo.add('nuzhathx.zaiba@intel.com');
                mail.setToAddresses(sendTo);
                  
                // Step 3: Set who the email is sent from
                mail.setReplyTo('nuzhathx.zaiba@intel.com');
                mail.setSenderDisplayName('Nuzhath Zaiba');
                  
                // (Optional) Set list of people who should be CC'ed
                List<String> ccTo = new List<String>();
                //ccTo.add('nuzhathx.zaiba@intel.com');
                mail.setCcAddresses(ccTo);
                  
                // Step 4. Set email contents - you can use variables!
                mail.setSubject('Bank Updated ');
                String body = 'Hi Bank Updated '+bankIdList ;
                mail.setHtmlBody(body);
                  
                // Step 5. Add your email to the master list
                mails.add(mail);
                Messaging.sendEmail(mails);
    }
}