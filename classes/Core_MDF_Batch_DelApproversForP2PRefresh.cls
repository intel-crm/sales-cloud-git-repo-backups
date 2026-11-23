public without sharing class Core_MDF_Batch_DelApproversForP2PRefresh implements Database.Batchable<sObject>, Database.Stateful{
    public Integer successCount = 0;
    public String emailId = 'sridhar.swaminathan@intel.com';
    public Map<Id, String> failedApprovalCriteriaIdMap = new Map<Id, String>();
    public organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization LIMIT 1];
    public String limitStr = '5';
    public Core_MDF_Batch_DelApproversForP2PRefresh(Integer limitInt, String emailId) {
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
        String queryStr = 'SELECT Id FROM Core_MDF_Criteria__c ';
        if(limitStr != NULL){
            queryStr += 'LIMIT ' + limitStr;
        }

        System.debug('queryStr : ' + queryStr);
        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext bc, List<Core_MDF_Criteria__c> approvalCriteriaList){
        System.debug('approvalCriteriaList: ' + approvalCriteriaList);
        if(currorg.isSandbox){
            try{
                if(approvalCriteriaList != NULL && approvalCriteriaList.size() > 0){
                    Database.DeleteResult[] srList = Database.delete(approvalCriteriaList,false);
                    //successCount = 0;
                    //failedCount = 0;
                    // Iterate through each returned result
                    Integer count = 0;
                    for (Database.DeleteResult sr : srList) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully deleted Approver records.');
                            successCount++;
                        }
                        else {
                            // Operation failed, so get all errors
                            for(Database.Error err : sr.getErrors()) {
                                failedApprovalCriteriaIdMap.put(approvalCriteriaList[count].Id, 'Field: ' + err.getFields() + ' - Message: ' + err.getMessage());
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
                if(emailId == NULL && emailId != 'sridhar.swaminathan@intel.com'){
                    ccTo.add('sridhar.swaminathan@intel.com');
                }
                if(ccTo != NULL && ccTo.size() > 0){
                    mail.setCcAddresses(ccTo);
                }
                mail.setSubject('Approver Delete Failed');
                mail.setHtmlBody('Exception in deleting Approvers: ' + e.getMessage());
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
            System.debug('mail.setToAddresses: ' + mail);
            mail.setReplyTo(emailId);
            mail.setSenderDisplayName('System Admin');

            List<String> ccTo = new List<String>();
            //ccTo.add('nuzhathx.zaiba@intel.com');
            //ccTo.add('amal.thomas@intel.com');
            if(emailId == NULL || emailId != 'sohamx.banerjee@intel.com'){
                ccTo.add('sohamx.banerjee@intel.com');
            }
            if(ccTo != NULL && ccTo.size() > 0){
                mail.setCcAddresses(ccTo);
            }
            System.debug('mail.ccTo: ' + ccTo);

            String messageBody = '';
            if(failedApprovalCriteriaIdMap != NULL && failedApprovalCriteriaIdMap.size() > 0){
                mail.setSubject('Approval Criteria Records Delete Failed');
                messageBody += 'Failed Approver Ids: <style>table, th, td {border: 1px solid black;border-collapse: collapse;align: center;}';
                messageBody += '<table style="width:100%"><tr><th>Failed Approval Criteria Id</th><th>Error Message</th></tr>';
                for(Id approvalCriteriaId : failedApprovalCriteriaIdMap.keySet()){
                    messageBody += '<tr><td>' + approvalCriteriaId + '</td><td>' + failedApprovalCriteriaIdMap.get(approvalCriteriaId) + '</td></tr>';
                }
                messageBody += '</table>';
            }
            else{
                mail.setSubject('Approval Criteria Records Deleted Successfully');
                messageBody += 'No Failed Approver Ids. ';
            }
            messageBody += successCount + ' Approval Criteria Records deleted successfully.';
            System.debug('messageBody: ' + messageBody);
            mail.setHtmlBody(messageBody);
            System.debug('mail: ' + mail);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }
    }
}