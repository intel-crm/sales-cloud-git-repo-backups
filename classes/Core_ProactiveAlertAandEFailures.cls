/******************************************************************************************************************************************
    Class Name  : Core_ProactiveAlertAandEFailures
    Version     : 1.0
    Created Date: 05 JULY 2022
    Function    : Business logic for sending Proactive Alerts Email upon consecutive A&E Failures from external system and Integration   
    
    Modification Log :
    * Developer                 	Date [DD/MM/YYYY]           	Description
    * ----------------------------------------------------------------------------
    * Akshay More [Team: DRACO]			05/07/2022              	Original version
    *****************************************************************************************************************************************/
    
    public without sharing class Core_ProactiveAlertAandEFailures {
        
        public static final String LOG_ENTRY_ORIGIN = 'SFDC';
        public static final String LOG_ENTRY_ERROR = 'error';
        public static final String AGS_RESPONSE ='AGS Response';
        public static final String LOG_ENT_PROJ_ALERT = 'AccessAndEntitlement';
        public static final String LOG_ENT_SCOPE_ALERT = 'A&EFailureAlert';
        public static final String LOG_ENT_OBJ_ALERT = 'Contact';
        public static final String OTHER_ERROR = 'Other Errors';
        public static Boolean triggerProActiveAlert = false;
        
        // Main method for sending Proactive Alerts based on certail criteria
        @InvocableMethod(label='Send Proactive Alert' description='Sends the e-mail notification as a part of Proactive Alert feature in case of A&E failure')
        public static void processLogEntry() {
            processLogEntryFuture(); //Call separate future method as InvocableMethod cannot be a future one
        }
    
        @future
        public static void processLogEntryFuture() {
            //Get Custom Settings data to check the time frame for Alert and query log entries within that time frame
            Core_AE_Proactive_Alerts__c customSett = Core_AE_Proactive_Alerts__c.getOrgDefaults();
            String addMinutesString = '-' + customSett.Alert_Frequency__c;
            Integer addMinutesToDate = integer.valueof(addMinutesString);
            DateTime currentDateTime = system.now();
            DateTime queryFromDateTime = currentDateTime.addMinutes(addMinutesToDate);
    
            List<AlertDetails> AlertDetailsList = new List<AlertDetails>();
            
            //Get the list of Log Entries that match our criteria and time period
            List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
            logEntryList = [SELECT Id, Core_Details__c, Core_sObjectId__c, Core_Tags__c FROM Core_Log_Entry__c WHERE Core_Project__c =: LOG_ENT_PROJ_ALERT AND Core_Scope__c =: LOG_ENT_SCOPE_ALERT AND (CreatedDate > :queryFromDateTime OR Core_When__c > :queryFromDateTime)];
            
            //Add Contact Ids to a set and query Contact details of all error contacts
            Set<Id> errorConIdSet = new Set<Id>();
            for(Core_Log_Entry__c logEnt : logEntryList){
                if(logEnt.Core_sObjectId__c != null){
                    errorConIdSet.add(logEnt.Core_sObjectId__c);
                }
            }
            Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, Name, Email, Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c FROM Contact WHERE Id IN :errorConIdSet]);
            system.debug('Contact Map: ' + contactMap);
            
            //Get the list of Custom Metadata containing the Error String 
            List<Proactive_Alerts_on_A_E_Integration__mdt> lstProactiveAlertMtd = new List<Proactive_Alerts_on_A_E_Integration__mdt>();
            lstProactiveAlertMtd = Proactive_Alerts_on_A_E_Integration__mdt.getall().values();
            Decimal otherErrorThreshold = Proactive_Alerts_on_A_E_Integration__mdt.getInstance('Other_Errors').Core_Minimum_count_for_Alert__c;
            
            //Loop through the Log Entries and add them to respective categories
            Set<Id> errorContactIdSet = new Set<Id>();
            Map<String,Map<String,Contact>> mapErrorNContact = new Map<String,Map<String,Contact>>();
            Map<String,List<AlertDetails>> mapErrorAlertDetail = new Map<String,List<AlertDetails>>();
            for(Core_Log_Entry__c logEntry : logEntryList) {
                // Proceed further only when AGS Integration status is still Failed, else ignore that log entry
                if(contactMap.get(logEntry.Core_sObjectId__c).Core_AGS_Integration_Status__c != 'Successful'){
                    Boolean errorCategorised = false;
                    Boolean errorTobeIgnored = false;
                    String inboundMessageId	= 'Inbound message Id not found for this record ' + logEntry.Id;
                    Id someId = logEntry.Id;
                    //Get the inbound message if from the tag
                    if(logEntry.Core_Tags__c != null && logEntry.Core_Tags__c.contains(';')){
                        for(String splitString : logEntry.Core_Tags__c.split(';')){
                            if(splitString instanceOf Id){
                                someId = splitString;
                                if(someId.getSObjectType().getDescribe().getName() == 'Core_Integration_Inbound_Message__c'){
                                    inboundMessageId = '' + someId;
                                }
                            }
                        }
                    }
                    //Loop across the metadata and see if we can categorise the error from Log Entry into a category
                    for(Proactive_Alerts_on_A_E_Integration__mdt ProActAlert : lstProactiveAlertMtd){
                        if(ProActAlert.Core_Is_Active__c && ProActAlert.DeveloperName != 'Other_Errors'){                    
                            //If error in the log entry is found in custom metadata, add its details under that category
                            if(logEntry.Core_Details__c != null && logEntry.Core_Details__c.containsIgnoreCase(ProActAlert.Core_Error_Text__c) && !ProActAlert.IsIgnore__c){
                                AlertDetails alrtDet = new AlertDetails();
                                alrtDet.ErrorCategory = ProActAlert.label;
                                alrtDet.contactId = contactMap.get(logEntry.Core_sObjectId__c).Id;
                                alrtDet.contactName = contactMap.get(logEntry.Core_sObjectId__c).Name;
                                alrtDet.contactEmail = contactMap.get(logEntry.Core_sObjectId__c).Email;
                                alrtDet.contactAGSIntStatus = contactMap.get(logEntry.Core_sObjectId__c).Core_AGS_Integration_Status__c;
                                alrtDet.InboundMsgId = inboundMessageId;
                                alrtDet.EntitlementName = logEntry.Core_Details__c.split('-->').get(0);
                                alrtDet.EntitlementError = logEntry.Core_Details__c.split('-->').get(1);
    
                                if(mapErrorAlertDetail.containsKey(ProActAlert.label)) {
                                    mapErrorAlertDetail.get(ProActAlert.label).add(alrtDet);
                                } else {
                                    List<AlertDetails> tempAlertDetList = new List<AlertDetails>();
                                    tempAlertDetList.add(alrtDet);
                                    mapErrorAlertDetail.put(ProActAlert.label,tempAlertDetList);
                                }
                                errorCategorised = true;
                            } else if(logEntry.Core_Details__c != null && logEntry.Core_Details__c.containsIgnoreCase(ProActAlert.Core_Error_Text__c) && ProActAlert.IsIgnore__c){
                                errorTobeIgnored = true;
                            }
                        }
                        //For current custom metadata, check if count of errors logged is more than its threshold. If yes, then mark triggerProActiveAlert flag to TRUE
                        if(mapErrorAlertDetail.containsKey(ProActAlert.label) && mapErrorAlertDetail.get(ProActAlert.label).size() >=  ProActAlert.Core_Minimum_count_for_Alert__c){
                            system.debug('The error ' + ProActAlert.label + ' has size of ' + mapErrorAlertDetail.get(ProActAlert.label).size() + ' hence triggering Proactive Alert mechanism');
                            triggerProActiveAlert = true;
                        }
                    }
                    //If error in the log entry is not found in custom metadata, add its details under "Other Errors" category
                    if(!errorCategorised && !errorTobeIgnored){
                        AlertDetails alrtDet = new AlertDetails();
                        alrtDet.ErrorCategory = OTHER_ERROR;
                        alrtDet.contactId = contactMap.get(logEntry.Core_sObjectId__c).Id;
                        alrtDet.contactName = contactMap.get(logEntry.Core_sObjectId__c).Name;
                        alrtDet.contactEmail = contactMap.get(logEntry.Core_sObjectId__c).Email;
                        alrtDet.contactAGSIntStatus = contactMap.get(logEntry.Core_sObjectId__c).Core_AGS_Integration_Status__c;
                        alrtDet.InboundMsgId = inboundMessageId;
                        alrtDet.EntitlementName = logEntry.Core_Details__c.split('-->').get(0);
                        alrtDet.EntitlementError = logEntry.Core_Details__c.split('-->').get(1);
    
                        if(mapErrorAlertDetail.containsKey(OTHER_ERROR)) {
                            mapErrorAlertDetail.get(OTHER_ERROR).add(alrtDet);
                        } else {
                            List<AlertDetails> tempAlertDetList = new List<AlertDetails>();
                            tempAlertDetList.add(alrtDet);
                            mapErrorAlertDetail.put(OTHER_ERROR,tempAlertDetList);
                        }
                        //For "Other Errors" custom metadata, check if count of errors logged is more than its threshold. If yes, then mark triggerProActiveAlert flag to TRUE
                        if(mapErrorAlertDetail.containsKey('Other Errors') && mapErrorAlertDetail.get('Other Errors').size() >=  otherErrorThreshold){
                            system.debug('The "Other Errors" has size of ' + mapErrorAlertDetail.get('Other Errors').size() + ' hence triggering Proactive Alert mechanism');
                            triggerProActiveAlert = true;
                        }
                    }
                }
            }
            system.debug('Following is the entire set of errors and details: ' + mapErrorAlertDetail);
            if(triggerProActiveAlert){
                sendProactiveAlert(mapErrorAlertDetail,lstProactiveAlertMtd);
                System.debug('Email sent out..!!!!!');
            }
        }
        
        // Method for sending Proactive Alert Email to the support team
        public static void sendProactiveAlert(Map<String,List<AlertDetails>> alertErrorDetailMap,List<Proactive_Alerts_on_A_E_Integration__mdt> lstProactiveAlertMtd) {
            
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{};
                for(String toAddress : System.label.Core_ProactiveAlertAddresses.split(';')){
                    toAddresses.add(toAddress);
                }
            //String[] ccAddresses = new String[] {'akshayx.bhimrao@intel.com'};
            mail.setToAddresses(toAddresses);
            //mail.setCcAddresses(ccAddresses); 
            mail.setReplyTo('team.draco@intel.com ');
            mail.setSenderDisplayName('A&E Proactive Alert');
            
            // Specify the subject line for your email address.
            mail.setSubject('SalesCRM- A&E Integration Failures Proactive Alert');
            
            //Attach excel sheet in the mail alert
            String header ='Error,Contact Id,Name,Email,AGS Integration Status,Inbound Message Id,Entitlement Name,Error \n';
            String excelHeader = '<table border="1" style="border-collapse: collapse"><tr><th>Error</th><th>Contact Id</th><th>Name</th><th>Email</th><th>AGS Integration Status</th><th>Inbound Message Id</th><th>Entitlement Name</th><th>Error</th></tr>';
            String finalstr = excelHeader;
            String Recordstring = '';
            Map<String,Integer> errorCountMap = new Map<String,Integer>();
            for(Proactive_Alerts_on_A_E_Integration__mdt proActAler : lstProactiveAlertMtd){
                if(alertErrorDetailMap.containsKey(proActAler.MasterLabel) && alertErrorDetailMap.get(proActAler.MasterLabel).size() >= proActAler.Core_Minimum_count_for_Alert__c){
                    List<AlertDetails> alertDetailEntryList = alertErrorDetailMap.get(proActAler.MasterLabel);
                    String error = proActAler.MasterLabel;
                    errorCountMap.put(error,alertErrorDetailMap.get(error).size());
                    //Map<String,Contact> innerMap = alertErrorContactMap.get(error);
                    for(AlertDetails alertDetailEntry : alertDetailEntryList){
                        Recordstring += '<tr>';
                        Recordstring += '<td>' + alertDetailEntry.ErrorCategory + '</td>';
                        Recordstring += '<td>' + alertDetailEntry.contactId + '</td>';
                        Recordstring += '<td>' + alertDetailEntry.contactName + '</td>';
                        Recordstring += '<td>' + alertDetailEntry.contactEmail + '</td>';
                        Recordstring += '<td>' + alertDetailEntry.contactAGSIntStatus + '</td>';
                        Recordstring += '<td>' + alertDetailEntry.InboundMsgId + '</td>';
                        Recordstring += '<td>' + alertDetailEntry.EntitlementName + '</td>';
                        Recordstring += '<td>' + alertDetailEntry.EntitlementError + '</td>';
                        Recordstring += '</tr>';
                    }
                }
            }
            
            finalstr = finalstr + Recordstring + '</table>';
            System.debug('This is the content of the attached xls file: ' + finalstr);
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            blob excel = blob.valueOf(finalstr);
            attach.setBody(excel);
            Datetime myDT = system.now();
            String myDate = myDT.format('dd-MM-yyyy h.mm a','GMT+05:30');
            attach.setFileName('Proactive Alert Failures at ' + myDate + ' IST.xls');
            attach.setContentType('application/vnd.ms-excel'); 
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            
            // Get the list of errors and their counts for mail body
            String errorList = '<ul>';
            for(String errorName : errorCountMap.keySet()){
                errorList += '<li>' + errorName + ' - ' + errorCountMap.get(errorName) + ' Nos </li>';
            }
            errorList += '</ul>';
            
            // Specify the text content of the email.
            String msgBody = system.label.Core_ProactiveAlertMsgBody;
            String target = 'OrgName';
            String replacement = UserInfo.getUserName().substringAfterLast('.');
            Core_AE_Proactive_Alerts__c customSett = Core_AE_Proactive_Alerts__c.getOrgDefaults();
            Integer mns = Integer.valueof(customSett.Alert_Frequency__c);
            integer days = mns / 60 / 24 ;
            integer hours = (mns - days * 60 * 24) / 60 ;
            integer mins = mns - days * 60 * 24 - hours * 60 ;
            String timeInterval = '';
            timeInterval = hours != 0 ? hours +' hours '+ mins +' minutes' : mins +' minutes';
            
            msgBody = msgBody.replace('OrgName', UserInfo.getUserName().substringAfterLast('.'));
            msgBody = msgBody.replace('xxx', timeInterval);
            msgBody = msgBody.replace('ErrorName', errorList);
            System.debug('This is the body of Proactive Alert Mail: ' + msgBody);
            mail.setPlainTextBody(msgBody);
            mail.setHtmlBody(msgBody);
            
            // Send the Proactive Alert email you have created.
            Messaging.SendEmailResult [] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            system.debug('Result of sending email for Proactive Alert: ' + emailResult);
        }
    
        // Wrapper class to hold the error category, contact details and entitlement details
        public class AlertDetails {
            public String ErrorCategory;
            public String contactId;
            public String contactName;
            public String contactEmail;
            public String contactAGSIntStatus;
            public String InboundMsgId;
            public String EntitlementName;
            public String EntitlementError;
        }
    }