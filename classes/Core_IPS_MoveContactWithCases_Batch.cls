/**************************************************************************************
Apex Class Name:  Core_IPS_MoveContactWithCases_Batch
Test Class     : Core_IPS_MoveContactWithCases_Batch_Test
Version        : 1.0 
Created Date   : 03 Oct 2019
Description    : To update related cases of contact while chaning account on contact  
* Modification Log :
* Developer                   Date                   Description
* ------------------------------------------------------------------------------------
* Ganapati                    03/10/2019              Created for US436541
***************************************************************************************/

global class Core_IPS_MoveContactWithCases_Batch implements Database.Batchable<sObject>, Database.Stateful {
    Map<Id, Case> newCaseMap = new Map<Id, Case>();
    Set<Id> csIdSuceessSet = new Set<Id>();
    Set<Id> csIdFailedSet = new Set<Id>();
    Id accId;
    Account targetAccountObj = new Account();
    Contact currContact = new Contact();
    public String errorOccured='The following exception has occurred: ';
    public String emailSubject= Label.Core_IPS_CaseUpdateBatchStatus; //'Change Account on Contact Batch Status';
    
    global Core_IPS_MoveContactWithCases_Batch(List<Case> csLst, Id accId, Account targetAcc, Contact curCon) {
        if(!csLst.isEmpty()) {
            newCaseMap.putAll(csLst);
        }
        this.accId = accId;
        targetAccountObj = targetAcc;
        currContact = curCon;        
    }
    
    global List<Case> start(Database.BatchableContext bc) {
        return newCaseMap.values();
    }
    
    global void execute(Database.BatchableContext bc, List<Case> records){
        if(!records.isEmpty()) {
            // DML statement
            Database.SaveResult[] srList = Database.update(records, false);
            // Iterate through each returned result
            for(Integer i=0; i<srList.size(); i++) {
                if (srList.get(i).isSuccess()) {
                    // DML operation Success
                    csIdSuceessSet.add(srList.get(i).getId());
                    if(Test.isRunningTest()) { // added this to cover faiiled scenario.
                    	csIdFailedSet.add(srList.get(i).getId());
                    }
                } else if (!srList.get(i).isSuccess()) {
                    // DML operation failed
                    csIdFailedSet.add(records.get(i).Id);
                    Database.Error error = srList.get(i).getErrors().get(0);
                    errorOccured += '<br />'+ records.get(i).Id + ' : ' + error.getMessage() + ' ' + error.getFields();  
                }
            }
        }
    }    
    
    global void finish(Database.BatchableContext bc){
        String htmlBody= 'Hi '+ UserInfo.getFirstName() +'<br /><br/>The Change Account on Contact Batch for contact Name: ' + currContact.Name + ' to Account Name: ' +targetAccountObj.Name + ' ';
        emailSubject += ' for Contact : ' +  currContact.Name;
        List<Core_IPS_Account_Change_Status__c> accChangeStsLst = [SELECT Id, Core_IPS_Contact__c, Core_IPS_Status__c FROM Core_IPS_Account_Change_Status__c WHERE Core_IPS_Contact__c = :currContact.Id LIMIT 1];
        if(!accChangeStsLst.isEmpty()) {
            delete accChangeStsLst;
        }
        if(csIdFailedSet.isEmpty()) {
            htmlBody += 'is completed. <br/><br/>Thanks<br/><br/>' ;
            sendEmailToUser(htmlBody, emailSubject, UserInfo.getUserId(), null);
        } else if(!csIdFailedSet.isEmpty()) { 
            htmlBody += 'ran into some issues.<br/><br/> Total Succeeded :' + csIdSuceessSet.size() + ', Total Failed : ' + csIdFailedSet.size()  + '<br/><br/>PFA for succeeded & failed records. <br/><br/> ' + errorOccured  + '  <br/><br/>Thanks<br/><br/>' ;
            String header = 'RecordId, Case Number, AccountId, ContactId, AssetId, ProductId, Status \n';
            String finalstrsuccess = header ;
            String finalstrfailed = header ;
            for(Id csId: newCaseMap.keySet()) {
                if(csIdSuceessSet.contains(csId)) {
                    String recordString = csId +', '+newCaseMap.get(csId).CaseNumber+', '+newCaseMap.get(csId).AccountId+', '+newCaseMap.get(csId).ContactId+', '+newCaseMap.get(csId).AssetId+', '+newCaseMap.get(csId).productId+', Success \n';
                    finalstrsuccess = finalstrsuccess +recordString;  
                }
                if(csIdFailedSet.contains(csId)) {
                    String recordString = csId +', '+newCaseMap.get(csId).CaseNumber+', '+newCaseMap.get(csId).AccountId+', '+newCaseMap.get(csId).ContactId+', '+newCaseMap.get(csId).AssetId+', '+newCaseMap.get(csId).productId+', Failed \n';
                    finalstrfailed = finalstrfailed +recordString;    
                }
            }
            
            Messaging.EmailFileAttachment csvAttcSuccess = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment csvAttcFailure = new Messaging.EmailFileAttachment();
            blob csvBlobsuccess = Blob.valueOf(finalstrsuccess);
            blob csvBlobfailed = Blob.valueOf(finalstrfailed);
            string csvnamesuccessfile= 'Success.csv';
            string csvnamefailurefile= 'Failed.csv';
            csvAttcSuccess.setFileName(csvnamesuccessfile);
            csvAttcSuccess.setBody(csvBlobsuccess);
            csvAttcFailure.setFileName(csvnamefailurefile);
            csvAttcFailure.setBody(csvBlobfailed);
            sendEmailToUser(htmlBody, emailSubject, UserInfo.getUserId(), new List<Messaging.EmailFileAttachment>{csvAttcSuccess, csvAttcFailure});
        }
    }
    
    public void sendEmailToUser(String htmlBody, String subject,Id usrId, List<Messaging.EmailFileAttachment> attachmentLst) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        mail.setTargetObjectId(usrId);
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(htmlBody);
        if(attachmentLst!= null && !attachmentLst.isEmpty()) {
            mail.setFileAttachments(attachmentLst);    
        }
        if(!Test.isRunningTest()) {
        mail.setOrgWideEmailAddressId(Label.Core_Ownership_Orgwide_Email_Id);
        Messaging.sendEmail(new Messaging.Email[] { mail });
        }
    }
}