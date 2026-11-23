/****************************************************************************************************
Apex Class Name : PSG_BulkQuoteRevisionDeactivationBatch
Version         : 1.0 
Created Date    : 11/06/2023
Function        : This class is used to process the Bulk Quote Deactivation & Revision requests through the Update Quote tab.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Adarsh Parashar             11/06/2023                Created
*****************************************************************************************************/
global class PSG_BulkQuoteRevisionDeactivationBatch implements Database.Batchable<Sobject>,Database.Stateful{
	public List<String> quoteNoList;
	public String action;
	global Map<Id,String> failedrecordMap = new Map<Id,String>();
    global Map<String,SBQQ__Quote__c> quoteNameToRecordMap = new Map<String,SBQQ__Quote__c>();
    public Map<String,PSG_QuoteCloneController.GlobalVariables> quoteNameToglobalVarMap = new Map<String,PSG_QuoteCloneController.GlobalVariables>();
	global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([select id, name,core_cpq_active_cb__c,core_cpq_quote_type_nm__c from SBQQ__Quote__c where Pricing_Quote_Program_Nm__c = 'PSG' AND Name IN :quoteNoList]);
	}
	global void execute(Database.BatchableContext bc, List<SObject> sobjLst){
        try{
            List<SBQQ__Quote__c> quoteToUpdateList = new List<SBQQ__Quote__c>();
            List<Database.SaveResult> result= new List<Database.SaveResult>();
            for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>) sobjLst){
                quoteNameToRecordMap.put(quote.Name,quote);
            }
            if(action=='De-activate'){
                for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>) sobjLst){
                    if(quote.core_cpq_active_cb__c == true){
                        quote.core_cpq_active_cb__c = false;
                        quoteToUpdateList.add(quote);
                    }else{
                        failedrecordMap.put(quote.Id,'Quote is not active');
                    }
                }
                if(!quoteToUpdateList.isEmpty()){
                    result=Database.update(quoteToUpdateList,false);
                    for(Integer i=0;i<result.size(); i++){
                        Database.SaveResult sr = result[i];
                        if(!sr.isSuccess()){
                            String msg = PSG_QuotewithopptyInactive_Batch.getErrorAsString(sr.getErrors());
                            failedrecordMap.put(sr.getId(),msg);
                        }                        
                    }
                }
            }else if(action=='Revise'){
                PSG_QuoteCloneController.GlobalVariables globalVar = new PSG_QuoteCloneController.GlobalVariables();
                for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>) sobjLst){
                    String newQuoteType = quote.core_cpq_quote_type_nm__c;
                    globalVar = PSG_QuoteCloneController.doClone(quote.Id,'revision',newQuoteType);
                    quoteNameToglobalVarMap.put(quote.Name,globalVar);
                }
            }
        }catch(Exception ex){
            PSG_Utility.logError(ex);
        }		
	}
	global void finish(Database.BatchableContext bc){
		if(!failedrecordMap.isEmpty()){
            PSG_Utility.createCoreLogEntry('PSG_BulkQuoteRevisionDeactivationBatch','PSG_BulkQuoteRevisionDeactivationBatch','Failed Record while processing through PSG_BulkQuoteRevisionDeactivationBatch',''+failedrecordMap
                                           ,'SBQQ__Quote__c','Info','');
        }
        if(quoteNoList != null && !quoteNoList.isEmpty()){
            //AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems From AsyncApexJob WHERE Id = :bc.getJobId()];
            Messaging.EmailFileAttachment csvAttcmnt = new Messaging.EmailFileAttachment();
            String csvname = 'Quote_BULKUPLOAD.csv';
            String mainContent = '';
            String data = '';
            Integer s = 0,t = 0;
            if(action=='De-activate'){
                data = 'Quote #,Quote SFID,Result,Reason\n';
                for(String quote : quoteNoList){
                    String d='';
                    t++;
                	if(!quoteNameToRecordMap.containsKey(quote)){
                    	d = ''+quote+','+''+',Failure,Invalid Quote Number\n';
                    }else if(failedrecordMap.containsKey(quoteNameToRecordMap.get(quote).Id)){
                        d = ''+quote+','+quoteNameToRecordMap.get(quote).Id+',Failure,"'+failedrecordMap.get(quoteNameToRecordMap.get(quote).Id)+'"\n';
                    }else{
                        d = ''+quote+','+quoteNameToRecordMap.get(quote).Id+',Success,'+''+'\n';
                        s++;
                    }
                    data += d;
                }
            }else if(action=='Revise'){
                data = 'Quote #,Quote SFID,Revised Quote #,Revised Quote SFID,Result,Reason\n';
                for(String quote : quoteNoList){
                    String d='';
                    t++;
                	if(!quoteNameToRecordMap.containsKey(quote)){
                    	d = ''+quote+',,,,Failure,Invalid Quote Number\n';
                    }else if(quoteNameToglobalVarMap.get(quote).isSuccess == false){
                        d = ''+quote+','+quoteNameToRecordMap.get(quote).Id+''+',,,Failure,"'+quoteNameToglobalVarMap.get(quote).messageResult+'"\n';
                    }else{
                        d = ''+quote+','+quoteNameToRecordMap.get(quote).Id+','+quoteNameToglobalVarMap.get(quote).quoteName+','+quoteNameToglobalVarMap.get(quote).quoteId+',Success,'+''+'\n';
                        s++;
                    }
                    data += d;
                }
            }
            mainContent +=  data;
            blob csvBlob = Blob.valueOf(mainContent);
            csvAttcmnt.setFileName (csvname);
        	csvAttcmnt.setBody (csvBlob);
            String quoteResultBody='<h4 style="color:black">';
            quoteResultBody += 'Total # of Records Uploaded: '+ t +'<br>';
            quoteResultBody += 'Total # of Successfully Uploaded Records: '+ s +'<br>';
            quoteResultBody += 'Total # of Failed Records: '+ (t - s) +'</h4>';
            EmailTemplate tempId = [SELECT Id, HTMLValue,Subject, Body, Name FROM EmailTemplate WHERE DeveloperName = 'PSG_Quote_Bulk_Upload_Result'];
            Savepoint sp = Database.setSavepoint();
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
			mail1.setTemplateId(tempId.Id);
            mail1.setTargetObjectId(Userinfo.getUserId());
            mail1.setToAddresses(new List<String>{UserInfo.getUserEmail()});
            mail1.setSaveAsActivity(false);
            mail1.setFileAttachments (new Messaging.EmailFileAttachment []{csvAttcmnt});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail1});
            Database.rollback(sp);
            String emailBody=mail1.getHtmlBody();
            emailBody=emailBody.replace('quote_details_body',quoteResultBody);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId([Select Id,address from OrgWideEmailAddress where address='wsm-postmaster@intel.com' Limit 1][0].Id);
            mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});
            mail.setHtmlBody(emailBody);
            mail.setSubject(tempId.Subject);
            mail.setFileAttachments (new Messaging.EmailFileAttachment []{csvAttcmnt});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            Database.executeBatch(new PSG_SendBulkSAPRequestBatch(),1);
        }
	}
}