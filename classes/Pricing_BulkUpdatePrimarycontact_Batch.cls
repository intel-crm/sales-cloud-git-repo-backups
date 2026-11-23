/**
* @description       : Batch class to validate and update Primary Contact on Quotes in Bulk
* @author            : Sandeep Chamate
* @group             : Accenture
* @last modified on  : 04-15-2026
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Pricing_BulkUpdatePrimarycontact_Batch implements Database.Batchable<sObject>,Database.Stateful{
    public User oldPrimaryContactUser;
    public User newPrimaryContactUser;
    public Boolean isDrafterLimitedUser;
    public Integer quotesCount = 0;
    public integer countSuccessRecs = 0;
    public integer countErrorRecs = 0;
    public Map<Id,String> quoteIdToQuoteNumMap = new Map<Id,String>();
    public Map<Id,String> quoteIdToMsgMap = new Map<Id,String>();
    Map<id,SBQQ__Quote__c> quoteIdToQuoteRecMap = new Map<id,SBQQ__Quote__c>();

    //contructor for Batch class to set old and new Primary Contact User and Boolean drafter Limited User
    public Pricing_BulkUpdatePrimarycontact_Batch(User oldUser, User newUser, Boolean drafterLimitedUser){
        this.oldPrimaryContactUser = oldUser;
        this.newPrimaryContactUser = newUser;
        this.isDrafterLimitedUser = drafterLimitedUser;
    }
    
    /**
    * @description Method called from the Flow to Bulk Update Primary Contact
    * @author Sandeep Chamate | 09-29-2022 
    * @param flowInputsList 
    **/
    @InvocableMethod(label = 'performBulkUpdateonPrimaryContact' description = 'To update Primary Contact in bulk on Quotes')
    public static List<String> performBulkUpdateonPrimaryContact(List<FlowInputs> flowInputsList){
        String newPrimaryContactEmail = flowInputsList[0].newPrimaryContactInput;
        String oldPrimaryContactEmail = flowInputsList[0].oldPrimaryContactInput;
        String errorMsg;
        Boolean isLimitedUser = false;
        List<String> errorRespList = new List<String>();
        List<User> oldPrimaryContact = new List<User>();
        List<User> newPrimaryContact = new List<User>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        try{
            if(oldPrimaryContactEmail == newPrimaryContactEmail){
                errorMsg = Label.Pricing_BulkPrimaryContactUpdate_ErrorMsg;
                errorRespList.add(errorMsg);
                createCoreLogEntry(errorMsg, 'An error has occurred in '+Label.Pricing_IQR_SFDC_Environment+' when processing the Bulk Action - '+ Label.Pricing_PrimaryContact_BulkUpdate, Label.Pricing_PrimaryContact_BulkUpdate);
            }
            else{
                oldPrimaryContact = [SELECT Id,ContactId,AccountId,Contact.Name FROM User WHERE Contact.Email =: oldPrimaryContactEmail AND IsPortalEnabled = true];
            	newPrimaryContact = [SELECT Id,ContactId,AccountId,Email,Contact.Name,(SELECT PermissionSet.Name,AssigneeId FROM PermissionSetAssignments 
                                	WHERE PermissionSet.Name IN: Label.Pricing_Tender_PermissionSets_AllExternal.Split(':')) 
                                	FROM User WHERE Contact.Email =: newPrimaryContactEmail AND isActive = true AND IsPortalEnabled = true];

            	if(oldPrimaryContact.size() > 0){
                	quoteList = [SELECT Id,Name,SBQQ__PrimaryContact__c FROM SBQQ__Quote__c WHERE Pricing_Quote_Program_Nm__c =: Label.Pricing_Tender_Quote_Program
                             AND SBQQ__PrimaryContact__c =: oldPrimaryContact[0].ContactId AND Pricing_On_Hold_Cb__c = false];
            	}

            	if(oldPrimaryContact.size() == 0 || newPrimaryContact.size() == 0){
                	errorMsg = Label.Pricing_BulkPrimaryContactUpdate_ErrorMsg;
                	errorRespList.add(errorMsg);
                	createCoreLogEntry(errorMsg, 'An error has occurred in '+Label.Pricing_IQR_SFDC_Environment+' when processing the Bulk Action - '+Label.Pricing_PrimaryContact_BulkUpdate, Label.Pricing_PrimaryContact_BulkUpdate);        
            	}
            	else if(oldPrimaryContact[0].AccountId != newPrimaryContact[0].AccountId){
                	errorMsg = Label.Pricing_BulkPrimaryContactUpdate_ErrorMsg;
                	errorRespList.add(errorMsg);
                	createCoreLogEntry(errorMsg,'An error has occurred in '+Label.Pricing_IQR_SFDC_Environment+' when processing the Bulk Action - '+Label.Pricing_PrimaryContact_BulkUpdate, Label.Pricing_PrimaryContact_BulkUpdate);
            	}
            	else if(newPrimaryContact[0].PermissionSetAssignments.size() == 0){
                	errorMsg = Label.Pricing_BulkPrimaryContactUpdate_ErrorMsg;
                	errorRespList.add(errorMsg);
                	createCoreLogEntry(errorMsg,'An error has occurred in '+Label.Pricing_IQR_SFDC_Environment+' when processing the Bulk Action - '+Label.Pricing_PrimaryContact_BulkUpdate, Label.Pricing_PrimaryContact_BulkUpdate);           
            	}
            	else if(quoteList.size() == 0){
                	errorMsg = Label.Pricing_BulkPrimaryContactUpdate_ErrorMsg;
                	errorRespList.add(errorMsg);
                	createCoreLogEntry(errorMsg, 'An error has occurred in '+Label.Pricing_IQR_SFDC_Environment+' when processing the Bulk Action - '+ Label.Pricing_PrimaryContact_BulkUpdate, Label.Pricing_PrimaryContact_BulkUpdate);             
            	}
            	else if(quoteList.size() > 0){
                	for(PermissionSetAssignment psa: newPrimaryContact[0].PermissionSetAssignments){
                    	if(psa.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_TenderDrafterLimited){
                        	isLimitedUser = true;
                    	}
                	}
                	Id jobId = Database.executeBatch(new Pricing_BulkUpdatePrimarycontact_Batch(oldPrimaryContact[0], newPrimaryContact[0], isLimitedUser), Integer.valueof(Label.Pricing_PrimaryContact_BulkUpdate_BatchSize));
            	}
            }
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }
        return errorRespList;
    }

    public static void createCoreLogEntry(String details, String message, String origin){
        core_log_entry__c logEntry = new core_log_entry__c();
        logEntry.Core_Details__c = details;
        logEntry.Core_Message__c = message;
        logEntry.Core_Origin__c = origin;
        logEntry.Core_Project__c = Label.Pricing_IQR_Program_Name;
        logEntry.Core_Severity__c = 'Medium';
        logEntry.Core_Support_Email__c = Label.Pricing_IQR_Support_Email;
        logEntry.Core_Support_Link__c = Label.Pricing_IQR_Support_Link;
        logEntry.Core_When__c = system.now();
        insert logEntry;
    }
    
    /**
    * @description Query on Quotes where Primary Contact is same as flow's Old Primary Contact
    * @author Sandeep Chamate | 07-30-2023 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,Name,SBQQ__Account__c,SBQQ__Account__r.Name,Pricing_End_Customer_Name__c,RecordType.DeveloperName,SBQQ__Status__c,SBQQ__PrimaryContact__c,Pricing_Folio_ID_Nm__c,
                                            Pricing_End_Customer__c,Pricing_Customer_Nm__c,Pricing_End_Customer_Country_Nm__c,Pricing_Region_Nm__c,Pricing_Project_Name_Nm__c,Pricing_Account_Executive_Nm__c,
                                            Pricing_ShipmentStDate_Dt__c,Pricing_ShipmentEndDate_Dt__c,Pricing_Intel_Response_Requested_By_Date__c,Pricing_Bid_Dt__c,Pricing_Customer_Reference_Id__c FROM SBQQ__Quote__c
                                            WHERE Pricing_Quote_Program_Nm__c =: Label.Pricing_Tender_Quote_Program AND SBQQ__PrimaryContact__c =: oldPrimaryContactUser.ContactId AND Pricing_On_Hold_Cb__c = false]);
    }
    
    /**
    * @description Update Primary Contact on Quotes
    * @author Sandeep Chamate | 07-30-2023 
    * @param bc 
    * @param quoteRecsList - Quote Records list
    **/
    public void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> quoteRecsList){
        try
        {
            Map<String,String> successMap = new Map<String,String>();
            Map<String,Id> successQuoteNumToQuoteIdMap = new Map<String,Id>();
            Map<String,String> errorMap = new Map<String,String>();
            Map<String,Id> errorQuoteNumToQuoteIdMap = new Map<String,Id>();
            List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
            String logMsg;
            String errorMsg;
            List<Database.SaveResult> bulkUpdResults = new List<Database.SaveResult>();
            List<SBQQ__Quote__c> quotestobeUpdated = new List<SBQQ__Quote__c>();

            if(quoteRecsList.size() > 0){
                Pricing_BulkInsertUpdateAESalesRep_Batch.isBulkAEUpdateInsertOnQuoteQTM = true;
                for(SBQQ__quote__c quote: quoteRecsList){
                    quotesCount++;
                    quoteIdToQuoteNumMap.put(quote.Id, quote.Name);
                    quoteIdToQuoteRecMap.put(quote.Id, quote);
                    if(isDrafterLimitedUser && quote.SBQQ__Status__c != Label.Pricing_Tender_Quote_Status_Draft){
                        quoteIdToMsgMap.put(quote.Id, Label.Pricing_Tender_Drafter_Limited_Primary_Contact_Error_Message);
                        errorMap.put(quote.Id,Label.Pricing_Tender_Drafter_Limited_Primary_Contact_Error_Message);
                        countErrorRecs++;
                    }
                    else{
                        quote.SBQQ__PrimaryContact__c = newPrimaryContactUser.ContactId;
                        quotestobeUpdated.add(quote);
                    }
                }

                if(quotestobeUpdated.size() > 0 ){
                    SBQQ.TriggerControl.disable();
                    Database.SaveResult[] quoteUpdResults = database.update(quotestobeUpdated, false);
                    SBQQ.TriggerControl.enable();

                    bulkUpdResults.addAll(quoteUpdResults);
                    for(database.SaveResult sr : bulkUpdResults){
                        if(sr.issuccess()){
                            countSuccessRecs++;
                            if(quoteIdToQuoteNumMap.containsKey(sr.getId())){
                                quoteIdToMsgMap.put(sr.getId(),'Success');
                                logMsg = 'Record: '+quoteIdToQuoteNumMap.get(sr.getId())+' has been processed successfully.';
                                successMap.put(quoteIdToQuoteNumMap.get(sr.getId()),logMsg);
                                successQuoteNumToQuoteIdMap.put(quoteIdToQuoteNumMap.get(sr.getId()),sr.getId());
                            }
                        }
                        else{
                            for(Database.Error err : sr.getErrors()) {
                                errorMsg = err.getMessage();
                            }
                            countErrorRecs++;
                            if(quoteIdToQuoteNumMap.containsKey(sr.getId())){
                                quoteIdToMsgMap.put(sr.getId(),errorMsg);
                                errorMap.put(quoteIdToQuoteNumMap.get(sr.getId()),errorMsg);
                                errorQuoteNumToQuoteIdMap.put(quoteIdToQuoteNumMap.get(sr.getId()),sr.getId());
                            }
                        }
                    }
                }
            }
                
            
            if(successMap.size()>0 && successQuoteNumToQuoteIdMap.size()>0){
                logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectBulkUpdateInsertAE(successMap,successQuoteNumToQuoteIdMap,'Low','Primary Contact Update'));
            }
            if(errorMap.size()>0 && errorQuoteNumToQuoteIdMap.size()>0){
                logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectBulkUpdateInsertAE(errorMap,errorQuoteNumToQuoteIdMap,'Medium','Primary Contact Update'));
            }
            if(logEntryList.size() > 0){
                insert logEntryList;    
            }
        }    
        catch(exception ex){
            Pricing_Tender_Utility.logError(ex);
        }
    }
    
    /**
    * @description finish method to send email after execution
    * @author Sandeep Chamate | 07-30-2023 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc)
    {
        try{
            String csvColumnHeader;
            List<String> csvRowValues = new List<String>();
            String loggedInUserEmail = UserInfo.getUserEmail();
            String status = '';

            for(Id key: quoteIdToQuoteNumMap.keyset()){
                String row;
                status = quoteIdToMsgMap.containsKey(key)?quoteIdToMsgMap.get(key):'';
                status = (!String.isEmpty(status) && status.contains(','))?status.replace(',',''):!(String.isEmpty(status) && status.contains(','))?status:'';
                String accountName = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).SBQQ__Account__r.name)?((quoteIdToQuoteRecMap.get(Key)).SBQQ__Account__r.name).replace(',',''):'';
                String endCustName = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_End_Customer_Name__c)?((quoteIdToQuoteRecMap.get(Key)).Pricing_End_Customer_Name__c).replace(',',''):'';
                String endCustCountry = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_End_Customer_Country_Nm__c)?(quoteIdToQuoteRecMap.get(Key)).Pricing_End_Customer_Country_Nm__c:'';
                String endCustRegion = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_Region_Nm__c)?(quoteIdToQuoteRecMap.get(Key)).Pricing_Region_Nm__c:'';
                String proj = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_Project_Name_Nm__c)?((quoteIdToQuoteRecMap.get(Key)).Pricing_Project_Name_Nm__c).replace(',',''):'';
                String strDate = ((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentStDate_Dt__c) != null?(((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentStDate_Dt__c).month()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentStDate_Dt__c).day()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentStDate_Dt__c).year()):'';
                String endDate = ((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentEndDate_Dt__c) != null?(((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentEndDate_Dt__c).month()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentEndDate_Dt__c).day()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_ShipmentEndDate_Dt__c).year()):'';
                String respReqDate = ((quoteIdToQuoteRecMap.get(Key)).Pricing_Intel_Response_Requested_By_Date__c) != null?(((quoteIdToQuoteRecMap.get(Key)).Pricing_Intel_Response_Requested_By_Date__c).month()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_Intel_Response_Requested_By_Date__c).day()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_Intel_Response_Requested_By_Date__c).year()):'';
                String propDueDate = ((quoteIdToQuoteRecMap.get(Key)).Pricing_Bid_Dt__c) != null?(((quoteIdToQuoteRecMap.get(Key)).Pricing_Bid_Dt__c).month()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_Bid_Dt__c).day()+'-'+((quoteIdToQuoteRecMap.get(Key)).Pricing_Bid_Dt__c).year()):'';
                String refReqId = !String.isEmpty((quoteIdToQuoteRecMap.get(Key)).Pricing_Customer_Reference_Id__c)?((quoteIdToQuoteRecMap.get(Key)).Pricing_Customer_Reference_Id__c).replace(',',''):'';

                row = status + ',' + quoteIdToQuoteNumMap.get(key) + ',' + (quoteIdToQuoteRecMap.get(Key)).SBQQ__Status__c 
                    + ',' + accountName + ',' + endCustName + ',' + endCustCountry + ',' + endCustRegion + ',' + proj 
                    + ',' + strDate + ',' + endDate + ',' + respReqDate + ',' + propDueDate + ',' + refReqId;
                    csvRowValues.add(row);
            }
            
            List<OrgWideEmailAddress> orgWideEmailAdd = [SELECT Id from OrgWideEmailAddress where Address=:Label.Pricing_OrgWideEmailAddress];
            Id orgWideEmailAddId = orgWideEmailAdd[0].id;
            csvColumnHeader = 'Success/Error, Quote Number, Status, Account, End Customer, End Customer Country/Region, End Customer Sales Geography, Project Name, Pricing Start Date, Pricing End Date, Intel Response Requested By Date, Proposal Due Date, Reference Request ID \n';
            String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
            Blob b = Blob.valueOf(csvFile);
            //Send an email once the Batch finishes processing
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment attachedFile = new Messaging.EmailFileAttachment();

            String[] toAddresses = new String[] {loggedInUserEmail};
            String[] bccAddresses = new String[] {Label.Pricing_IQR_Support_Email};
            String body = 'Updating the Primary contact from '+ oldPrimaryContactUser.Contact.Name + ' to ' + newPrimaryContactUser.Contact.Name + ' is complete. Please forward the attached file to the requestor and advise to refer to the file to see the list of quotes updated and errors, if any.';
            attachedFile.setFileName('Bulk Primary Contact Update_'+string.valueOf(system.now())+'.csv');
            attachedFile.setBody(b);
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachedFile});
            mail.setToAddresses(toAddresses);
            mail.setbccAddresses(bccAddresses);
            mail.setOrgWideEmailAddressId(orgWideEmailAddId);
            mail.setSubject('Bulk Primary Contact Update');
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }
    }
    
    //Stores inputs from Flow 
    public class FlowInputs {
        @InvocableVariable public String newPrimaryContactInput;
        @InvocableVariable public String oldPrimaryContactInput;
        public FlowInputs(){
            
        }
    }
    
}