/****************************************************************************************************************************************
* Class Name  : Core_MDF_Batch_MaskBankForP2PRefresh
* Version     : 1.0
* Created Date: 05-06-2020
* Modification Log :
* Developer                Date                     Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – NZ         05/06/2020               Created Core_MDF_Batch_MaskBankForP2PRefresh for cleaning up Bank Supplier#
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Batch_MaskBankForP2PRefresh implements Database.Batchable<sObject>, Database.Stateful {
    public Integer supplierNumber = 1000000000;
    public Integer bankAccountNumber = 1000;
    public List<Id> successbankIdList = new List<Id>();
    public Map<Id, String> failedbankIdMap = new Map<Id, String>();
    public String emailId = 'amal.thomas@intel.com';
    public organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization LIMIT 1];
    public String limitStr = '5';

    //Put the LIMIT in the constructor
    public Core_MDF_Batch_MaskBankForP2PRefresh(Integer limitInt, String emailId){
        if(limitInt != NULL){
            this.limitStr = String.valueOf(limitInt);
        }
        else{
            this.limitStr = NULL;
        }
        if(emailId != NULL){
            this.emailId = emailId;
        }

        System.debug('this.limitStr: ' + this.limitStr);
        System.debug('this.emailId: ' + this.emailId);
    }

    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        //Add the Core_MDF_Swift_Code__c, Core_MDF_Bank_Account_Number__c, Core_MDF_Routing_Number__c, Core_MDF_DUNS__c
        String queryStr = 'SELECT Id, Core_MDF_Supplier_Number__c, Core_MDF_Supplier_Name__c, Core_MDF_Swift_Code__c, Core_MDF_Bank_Account_Number__c, Core_MDF_Routing_Number__c, Core_MDF_DUNS__c FROM Core_MDF_Bank__c ';
        if(limitStr != NULL){
            queryStr += 'LIMIT ' + limitStr;
        }

        System.debug('queryStr : ' + queryStr);
        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext bc, List<Core_MDF_Bank__c> bankList){
        System.debug('bankList: ' + bankList);
        if(currorg.isSandbox){
            for(Core_MDF_Bank__c bank : bankList) {
                System.debug('NZ-->Supplier Number : '+bank.Core_MDF_Supplier_Number__c);
                bank.Core_MDF_Supplier_Number__c = String.valueof(supplierNumber);
                bank.Core_MDF_Supplier_Name__c = 'Test ' + String.valueof(supplierNumber);
                bank.Core_MDF_Bank_Account_Number__c = String.valueof(bankAccountNumber);
                bank.Core_MDF_Routing_Number__c = String.valueof(bankAccountNumber);
                bank.Core_MDF_Swift_Code__c = 'ABCD' + String.valueof(bankAccountNumber) + 'EFG';
                bank.Core_MDF_DUNS__c = String.valueof(bankAccountNumber);
                supplierNumber++;
                bankAccountNumber++;
            }
            try{
                if(bankList!=null && bankList.size()>0){
                    Database.SaveResult[] srList = Database.update(bankList,false);
                    Integer count = 0;
                    // Iterate through each returned result
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted Bank ' + sr.getId());
                            successbankIdList.add(bankList[count].Id);
                        }
                        else {
                            // Operation failed, so get all errors
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('Failed -> bankList[count].Id: ' + bankList[count].Id);
                                failedbankIdMap.put(bankList[count].Id, 'Field: ' + err.getFields() + ' - Message: ' + err.getMessage());
                            }
                        }
                        count++;
                    }
                }
            }
            catch(Exception e){
                System.debug('Exception'+e);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{emailId});
                mail.setReplyTo(emailId);
                mail.setSenderDisplayName('System Admin');
                List<String> ccTo = new List<String>();
                //ccTo.add('nuzhathx.zaiba@intel.com');
                //ccTo.add('amal.thomas@intel.com');
                if(emailId == NULL && emailId != 'sohamx.banerjee@intel.com'){
                    ccTo.add('sohamx.banerjee@intel.com');
                    ccTo.add('sridhar.swaminathan@intel.com');
                }
                if(ccTo != NULL && ccTo.size() > 0){
                    mail.setCcAddresses(ccTo);
                }
                mail.setSubject('Bank Update Failed');
                mail.setHtmlBody('Exception in updating Banks: ' + e.getMessage());
                System.debug('Exception mail: ' + mail);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            }
        }
    }
    public void finish(Database.BatchableContext bc)
    {
        if(currorg.isSandbox){
            // Step 0: Create a master list to hold the emails we'll send
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{emailId});
            mail.setReplyTo(emailId);
            mail.setSenderDisplayName('System Admin');

            List<String> ccTo = new List<String>();
            ccTo.add('nuzhathx.zaiba@intel.com');
            //ccTo.add('amal.thomas@intel.com');
            if(emailId == NULL && emailId != 'sohamx.banerjee@intel.com'){
                ccTo.add('sohamx.banerjee@intel.com');
                ccTo.add('sridhar.swaminathan@intel.com');
            }
            if(ccTo != NULL && ccTo.size() > 0){
                mail.setCcAddresses(ccTo);
            }

            //mail.setSubject('Bank Updated');

            String messageBody = 'Banks Updated.<br/>';
            if(failedbankIdMap != NULL && failedbankIdMap.size() > 0){
                mail.setSubject('Bank Update Failed');
                messageBody += 'Failed Bank Ids: <style>table, th, td {border: 1px solid black;border-collapse: collapse;align: center;}';
                messageBody += '<table style="width:100%"><tr><th>Failed Bank Id</th><th>Error Message</th></tr>';
                for(Id bankId : failedbankIdMap.keySet()){
                    messageBody += '<tr><td>' + bankId + '</td><td>' + failedbankIdMap.get(bankId) + '</td></tr>';
                }
                messageBody += '</table>';
            }
            else{
                mail.setSubject('Bank Updated Successfully');
                messageBody += 'No Failed Bank Ids. ';
            }
            messageBody += successbankIdList.size() + ' Bank records updated successfully.';
            System.debug('messageBody: ' + messageBody);
            mail.setHtmlBody(messageBody);
            System.debug('mail: ' + mail);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }
    }
}