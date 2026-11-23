/**************************************************************************************
Apex Class Name:  Core_Platform_Event_Producer
Version     : 1.0 
Created Date: 18 DEC 2020
Function    : Function to Publish Object Details to Platform Event Bus
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------------------------------------------------                 
* Gireesh K             18/12/2020              publish_On_Account_Update() publish Account Detailstp Platform Event Bus
************************************************************************************************************************/

public  with sharing class Core_Platform_Event_Producer {
    
    //Gireesh:US860013:Publish Account Details to Platform Event Bus on Update or Insert
    @InvocableMethod(label='Core_Platform_Event_Producer' description='To Publish Account Details to Platform Event Bus on Update or Insert')
    public Static void publish_On_Account_Update(List<Account> updatedAccountList){
        try{
            final String OBJECT_NAME = 'Account';
            
            List<Core_Attributes_List__mdt> attributeList = [SELECT Id, QualifiedApiName, Core_Attribute_List__c FROM Core_Attributes_List__mdt where QualifiedApiName='Account' WITH SECURITY_ENFORCED];
            List<String> unTrimmedAttributeList = new List<String>();
            if(attributeList!=null && attributeList.size()>0 && attributeList[0].Core_Attribute_List__c!=null && attributeList[0].Core_Attribute_List__c.contains(',')){
                
                unTrimmedAttributeList = attributeList[0].Core_Attribute_List__c.split(',');
            }
            List<String> fields = new List<String>();
            for(String field: unTrimmedAttributeList){
                fields.add(field.trim());
            }
            
            //Get Account SalesforceIds
            List<Id> accountSalesforceIdList = new List<Id>();
            for(Account accountId:updatedAccountList){
                accountSalesforceIdList.add(accountId.Id);
            }
            
            List<String> xmlMessageList = generate_XML_Messages(updatedAccountList, OBJECT_NAME, fields);  
            if(xmlMessageList!=null && xmlMessageList.size()>0){
                publish_Platform_Event(OBJECT_NAME, xmlMessageList, accountSalesforceIdList, False, Null, Null);            
            } 
        }
        catch(Exception e){
            system.debug('#ex:Message:'+e.getMessage());
            system.debug('#ex:LineNumber:'+e.getLineNumber());
        }
    }
    
    //Publish to platform Event Bus
    public static void publish_Platform_Event(String objectName, List<String> xmlMessageList, List<Id> accountSalesforceIdList, Boolean rePublish, List<Id> platFormEventLogidList, List<Integer> attemptList){
        Boolean publishStatus;
        List<Core_Platform_Event_Log__c> platformEventLogList = new List<Core_Platform_Event_Log__c>();
        try{
            List<Core_Platform_Event_Bus__e> platformEventBusList = new List<Core_Platform_Event_Bus__e>();
            for(Integer pIdx=0; pIdx<xmlMessageList.size(); pIdx++){
                Core_Platform_Event_Bus__e platformEventBus = new Core_Platform_Event_Bus__e();
                platformEventBus.Core_IsActive__c = True;
                platformEventBus.Core_Message__c = xmlMessageList[pIdx];
                platformEventBus.Core_Object_Type__c = objectName;
                platformEventBusList.add(platformEventBus);
                
                //Logging
                Core_Platform_Event_Log__c platformEventLog = new Core_Platform_Event_Log__c();
                platformEventLog.Core_Object_API_Name__c = objectName;
                platformEventLog.Core_Message__c = xmlMessageList[pIdx];
                platformEventLog.Core_Number_Of_Attempts__c = 0;
                platformEventLog.Core_IsActive__c = True;
                platformEventLog.Account__c = accountSalesforceIdList[pIdx];
                
                platformEventLogList.add(platformEventLog);
                //Logging end                
            }
            EventBus.publish(platformEventBusList);
            //Logging
            publishStatus=True;
            //Logging end
        }
        catch(Exception e){
            
            //Logging
            publishStatus=False;
            //Logging end
            
            system.debug('#ex:Message:'+e.getMessage());
            system.debug('#ex:LineNumber:'+e.getLineNumber());
        }
        finally{
            List<Id> failedRecordIds = new List<Id>();
            List<String> toEmailAddressList = new List<String>();
            Integer maxAttempts=2;
            try{
                //Query Custom Setting for max number of attempts
                List<Core_Platform_Event_Attempts__c> platFormEventAttempList = [SELECT Id, Core_Number_Of_Attempts__c, Core_Support_Email_Address__c FROM Core_Platform_Event_Attempts__c WITH SECURITY_ENFORCED limit 1];
                if(platFormEventAttempList!=null && platFormEventAttempList.size()>0 && platFormEventAttempList[0]!=null && platFormEventAttempList[0].Core_Number_Of_Attempts__c!=null){
                    maxAttempts = Integer.valueOf(platFormEventAttempList[0].Core_Number_Of_Attempts__c);
                }
                
                //Get ToEmail Address from custom settings
                if(platFormEventAttempList!=null && platFormEventAttempList.size()>0 && platFormEventAttempList[0]!=null && platFormEventAttempList[0].Core_Support_Email_Address__c!=null){
                    if ((platFormEventAttempList[0].Core_Support_Email_Address__c).contains(',')){
                        List<String> unTrimmedToEmailAddressList=(platFormEventAttempList[0].Core_Support_Email_Address__c).split(',');
                        for(String unTrimmedToEmailAddress : unTrimmedToEmailAddressList){
                        	toEmailAddressList.add(unTrimmedToEmailAddress.trim());
                        }                        
                    }
                    else{
                        toEmailAddressList.add(platFormEventAttempList[0].Core_Support_Email_Address__c);
                    }                    
                }
                //Logging
                for(Integer idx=0; idx<platformEventLogList.size(); idx++){
                    platformEventLogList[idx].Core_Status__c = publishStatus ? 'success' : 'failed';
                    if(rePublish){
                        platformEventLogList[idx].Core_Number_Of_Attempts__c=attemptList[idx]+1;
                        platformEventLogList[idx].Id = platFormEventLogidList[idx];
                        
                        if(Test.isRunningTest()){
                            publishStatus=False;
                        }
                        //if we are republishing failed message again and if the max attempts are reached then send an email to Support Team
                        if(!publishStatus && attemptList[idx]+1 >= maxAttempts){	//failed message  and max attempts reached
                            failedRecordIds.add(platformEventLogList[idx].Account__c);					
                        }
                    } 
                }
                
                //Before Upsert, inactivate any records with same Account SalesforceId exist
                List<Core_Platform_Event_Log__c> activeLogList = [Select Id, Core_IsActive__c from Core_Platform_Event_Log__c where Account__c IN :accountSalesforceIdList and Core_IsActive__c=True WITH SECURITY_ENFORCED];
                if(activeLogList!=null && activeLogList.size()>0){
                    for(Core_Platform_Event_Log__c activeLog : activeLogList){
                        activeLog.Core_IsActive__c=False;                        
                    }
                    if(Core_Platform_Event_Log__c.SObjectType.getDescribe().isUpdateable()){
                        update activeLogList;
                    }
                }
                
                if(platformEventLogList.size()>0 && (Core_Platform_Event_Log__c.SObjectType.getDescribe().isUpdateable() || Core_Platform_Event_Log__c.SObjectType.getDescribe().isCreateable())){
                    upsert platformEventLogList;
                }
                
                if(failedRecordIds!=null && failedRecordIds.size()>0){
                    sendEmailOnFailure(failedRecordIds, toEmailAddressList);
                }
                
                
                
                //Logging end
                //
                
            }
            catch(Exception e){
                system.debug('#ex:Message:'+e.getMessage());
                system.debug('#ex:LineNumber:'+e.getLineNumber());
            }
            
        }
        
    }
    
    public static void sendEmailOnFailure(List<Id> failedRecordIds, List<String> toEmailAddressList){

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = toEmailAddressList;
            message.optOutPolicy = 'FILTER';
        message.subject = 'SF to iPaaS Failure Record Notification';
        message.plainTextBody = 'Hi Everyone,';
        message.plainTextBody +='\n\nPlease find the details of failed records:';
        message.plainTextBody += '\nRecord Ids:'+failedRecordIds;
        message.plainTextBody += '\n\n\nThanks, \nIntel Support Team';

        
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
        
    }
    
    //Genreate XML for the SObject for selected fields    
    public static List<String> generate_XML_Messages(List<sObject> sObjectRecordList, string objName, List<String> fields){
        List<String> xmlMessageList = new List<String>();
        try{
            Map<String, Schema.sObjectField> sObjectFieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
            List<String> fieldList = new List<String>();
            
            for(Schema.SObjectField sfield: sObjectFieldMap.Values()){
                Schema.DescribeFieldResult fieldDesc = sfield.getDescribe();
                if(fields.contains(fieldDesc.getName())){
                    fieldList.add(fieldDesc.getName());
                }
            }
            
            String soapNS = 'sf:'+objName;
            String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
            String serviceNS = 'urn:sobject.enterprise.soap.sforce.com';
            String outboundNS = 'http://soap.sforce.com/2005/09/outbound';
            
            //Generate XML
            for(sObject sObj: sObjectRecordList){
                Dom.Document doc = new Dom.Document();            
                Dom.Xmlnode rootNode = doc.createRootElement('Notification', outboundNS, '');            
                rootNode.addChildElement('Id', null, null)
                    .addTextNode(sObj.Id);            
                
                dom.XmlNode body = rootNode.addChildElement('sObject', null, null);
                body.setNamespace('sf', serviceNS);
                body.setNamespace('xsi', xsi);
                body.setAttributeNS('type', soapNS, xsi, null);
                
                for(String field: fieldList){
                    if(sObj.get(field) != null){
                        body.addChildElement(field, serviceNS, 'sf')
                            .addTextNode(String.ValueOf(sObj.get(field)));
                    }                    
                }      
                xmlMessageList.add(doc.toXmlString());
            }
        }
        Catch(Exception e){
            system.debug('#ex:Message:'+e.getMessage());
            system.debug('#ex:LineNumber:'+e.getLineNumber());
        }
        
        return xmlMessageList;
        
    }
    
}