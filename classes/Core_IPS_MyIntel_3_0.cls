/*********************************************
* Name : Core_IPS_MyIntel_3_0 
* Author : Chandrashekar Pallikonda
* Date Created : 21/05/2021
* Description : This class is called from Case Trigger whenever a case is created or updated with relevant changes inorder to send details to MyIntel.
* Test Class : Core_IPS_MyIntel_3_0_Test
*   
************************************************/
public class Core_IPS_MyIntel_3_0 implements Queueable, Database.AllowsCallouts {
    public String jsonString;
    public String operationType;
    public String name;
    static final String promoted = 'Promoted';
    public Integer retryCounter=0;
    public List<Id> casesIds = new List<Id>();
    // Start ------ Tushar Garg
    public List<Id> listCasesIds = new List<Id>();
    Integer batchSize = String.isBlank(System.Label.Core_IPS_MyIntel_3_0_Batch_Size) ? 20 : Integer.valueOf(System.Label.Core_IPS_MyIntel_3_0_Batch_Size);
    // End ------ Tushar Garg
    @testVisible
    private static Boolean doChainJob = true;
    public List<Core_IPS_Project_Member__c> projectMemberList = new List<Core_IPS_Project_Member__c>();
    public List<Core_IPS_Case_Interested_Party__c> intrestedPartiesList = new List<Core_IPS_Case_Interested_Party__c>();
    public Map<Id,List<Map<String,String>>> projectMemberMap = new Map<Id,List<Map<String,String>>>();
    public Map<Id,List<Map<String,String>>> intrestedPartiesMap = new Map<Id,List<Map<String,String>>>();
    //Constructor..1
    public Core_IPS_MyIntel_3_0(List<Id> caseIds, String operationMsg, List<Core_IPS_Project_Member__c> projMembers) {
        //casesIds = caseIds;
        listCasesIds = caseIds;// Start ------ Tushar Garg
        operationType = operationMsg; 
        this.projectMemberList = projMembers;
    }
    //Constructor..2
    // start----US1005799----23-06-2021----Niyazuddin----Initiated parametarized constructor
    public Core_IPS_MyIntel_3_0(List<Id> caseIds, String operationMsg,List<Core_IPS_Project_Member__c> projMembers,Integer retryCount) {
        //casesIds = caseIds;
        listCasesIds = caseIds;// Start ------ Tushar Garg
        operationType = operationMsg; 
        this.retryCounter= retryCount+1;
        this.projectMemberList = projMembers;
    }
    //Constructor..3
    // start----   ----25-06-2021----Farooq----Initiated parametarized constructor
    public Core_IPS_MyIntel_3_0(List<Id> caseIds, String operationMsg,List<Core_IPS_Project_Member__c> projMembers, List<Core_IPS_Case_Interested_Party__c> intrestedParties) {
        //casesIds = caseIds;
        listCasesIds = caseIds;// Start ------ Tushar Garg
        operationType = operationMsg; 
        this.intrestedPartiesList = intrestedParties;
        this.projectMemberList = projMembers;
    }
    //End----US1005799
    //Added By Tushar 02-April-2026
    Boolean reduceBatchSize = false;
    public Core_IPS_MyIntel_3_0(List<Id> caseIds, String operationMsg,List<Core_IPS_Project_Member__c> projMembers, List<Core_IPS_Case_Interested_Party__c> intrestedParties, Boolean reduceBatchSize) {
        //casesIds = caseIds;
        listCasesIds = caseIds;// Start ------ Tushar Garg
        operationType = operationMsg; 
        this.intrestedPartiesList = intrestedParties;
        this.projectMemberList = projMembers;
        this.reduceBatchSize = reduceBatchSize;
    }
    //Queueable Execute Method
    public void execute(QueueableContext context) {
         // Start ------ Tushar Garg
        casesIds = new List<Id>();
        List<Id> remainingCaseIds = new List<Id>();
        //checking if batch is called to reduce the batch size
        if(reduceBatchSize && batchSize > 3){
            batchSize = 3;
        }
        if (listCasesIds.size() > batchSize) {
            // Safely collect the first batch
            for (Integer i = 0; i < batchSize; i++) {
                casesIds.add(listCasesIds[i]);
            }
            
            // Add the remaining items after batchSize
            for (Integer j = batchSize; j < listCasesIds.size(); j++) {
                remainingCaseIds.add(listCasesIds[j]);
            }
        } else {
            casesIds = new List<Id>(listCasesIds);
            remainingCaseIds = new List<Id>();
        }
         // End ------ Tushar Garg
        jsonString =  generateJsonBody(casesIds,operationType);
        system.debug('jsonString.length()'+jsonString.length());
        //Checking if length is exeeded then calling same batch but with reducing the size of 2
        if (jsonString != null && jsonString.length() > 800000) {
            // Already reduced to minimum supported size 3 -> do not retry again
            if (reduceBatchSize) {
                return;
            }
            // If current size is still above minimum, reduce to 3 and retry
            // call batch again to calculate the size 
            if(batchSize > 3){
                System.enqueueJob(new Core_IPS_MyIntel_3_0(listCasesIds, operationType, projectMemberList, intrestedPartiesList, true));
                return ;
            }
            
        }
        if(!String.isBlank(jsonString)) {
            // start----US1005775----23-06-2021----Niyazuddin----IPS Exception Handling : Ability to store JSON in outbound msg
            MessageWrapper messageWrapperObj = sendCaseData(jsonString); 
            String myintelOutboundName = '';
            List<Core_IPS_MyIntel_Outbound_Message__c> myIntelOutboundList = new List<Core_IPS_MyIntel_Outbound_Message__c>();
            Core_IPS_MyIntel_Outbound_Message__c myIntelOutbound = new Core_IPS_MyIntel_Outbound_Message__c();
            String strListIds=casesIds != null ? string.join(casesIds,', ') : '';
            strListIds = (strListIds.length()>255) ? strListIds.substring(0,255) : strListIds;
            // start----US1005799----23-06-2021----Niyazuddin----on response failure upserting outbound record
            List<Core_IPS_MyIntel_Outbound_Message__c> OldMyIntelOutboundList;
                
                if(casesIds != null && casesIds.size()>0){
                    OldMyIntelOutboundList =[SELECT Id,Name,Core_IPS_Status__c,Core_IPS_Retry_Count__c, CreatedDate FROM Core_IPS_MyIntel_Outbound_Message__c WHERE Core_IPS_Case_ID__c =:strListIds AND Core_IPS_Status__c='Failed' LIMIT 1  ];
                }
            if(messageWrapperObj !=null &&  messageWrapperObj.status == 'Failed' ){
                
                if(OldMyIntelOutboundList != null && OldMyIntelOutboundList.size()>0){
                    /*US1038991 - 09/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Case_ID__c.isCreateable() || Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Case_ID__c.isUpdateable()){
                        OldMyIntelOutboundList[0].Core_IPS_Case_ID__c = (strListIds.length()>255) ? strListIds.substring(0,255) : strListIds;
                    }
                    /*US1038991 - 09/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Operation_Type__c.isCreateable() || Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Operation_Type__c.isUpdateable()){
                        OldMyIntelOutboundList[0].Core_IPS_Operation_Type__c = operationType;
                    }
                    /*US1038991 - 09/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Status__c.isCreateable() || Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Status__c.isUpdateable()){
                        OldMyIntelOutboundList[0].Core_IPS_Status__c = messageWrapperObj.status;
                    }
                    /*US1038991 - 09/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Retry_Count__c.isCreateable() || Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Retry_Count__c.isUpdateable()){
                        OldMyIntelOutboundList[0].Core_IPS_Retry_Count__c= retryCounter;
                    }
                    
                    myIntelOutboundList.addAll(OldMyIntelOutboundList);
                }
                
                else{
                    /*US1038991 - 09/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Case_ID__c.isUpdateable() || Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Case_ID__c.isCreateable()){
                        myIntelOutbound.Core_IPS_Case_ID__c = (strListIds.length()>255) ? strListIds.substring(0,255) : strListIds;
                    }
                    /*US1038991 - 09/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Operation_Type__c.isUpdateable() || Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Operation_Type__c.isCreateable()){
                        myIntelOutbound.Core_IPS_Operation_Type__c = operationType;
                    }
                    /*US1038991 - 09/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Status__c.isUpdateable() || Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Status__c.isCreateable()){
                        myIntelOutbound.Core_IPS_Status__c = messageWrapperObj.status;
                    }
                    /*US1038991 - 09/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Retry_Count__c.isUpdateable() || Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Retry_Count__c.isCreateable()){
                        myIntelOutbound.Core_IPS_Retry_Count__c= retryCounter;
                    }
                    
                    myIntelOutboundList.add(myIntelOutbound);
                    
                }
                try{
                    if( myIntelOutboundList != null && myIntelOutboundList.size()>0){
                        upsert myIntelOutboundList;
                    }
                }
                catch(Exception ex){ String strDetails= 'Exception occured. while upserting records';
                                    Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'warn','IPS MyIntel Integration issue',strDetails,null,'Case',null);
                                   }
            }
            // if success
            if( messageWrapperObj != null && messageWrapperObj.status != 'Failed'){
                
                
                if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Case_ID__c.isUpdateable()){
                    myIntelOutbound.Core_IPS_Case_ID__c =  strListIds;
                }
                if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Operation_Type__c.isUpdateable()){
                    myIntelOutbound.Core_IPS_Operation_Type__c = operationType;
                }
                if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Status__c.isUpdateable()){
                    myIntelOutbound.Core_IPS_Status__c = messageWrapperObj.status;
                }
                if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Retry_Count__c.isUpdateable()){
                    myIntelOutbound.Core_IPS_Retry_Count__c= retryCounter;
                }
                myIntelOutboundList.add(myIntelOutbound);
                
                try{
                    if(myIntelOutboundList.size()>0){
                        insert myIntelOutboundList;
                    }
                }catch(exception e){ 
                    String strDetails= 'Exception occured. while inserting records';
                    Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'warn','IPS MyIntel Integration issue',strDetails,null,'Case',null);
                    
                }
                /* US-0021721- 02/08/2021 - Start - Sai Krishna - For Myintel outbound repromote --*/
                if(OldMyIntelOutboundList != null && OldMyIntelOutboundList.size()>0){
                    name = OldMyIntelOutboundList[0].Name;
                    if(name == OldMyIntelOutboundList[0].Name) {
                    /*US1038991 - 09/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Case_ID__c.isCreateable() || Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Case_ID__c.isUpdateable()){
                        OldMyIntelOutboundList[0].Core_IPS_Case_ID__c =  strListIds;
                    }
                    /*US1038991 - 09/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Operation_Type__c.isCreateable() || Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Operation_Type__c.isUpdateable()){
                        OldMyIntelOutboundList[0].Core_IPS_Operation_Type__c = operationType;
                    }
                    
                    /*US1038991 - 09/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Status__c.isCreateable() || Schema.sObjectType.Core_IPS_MyIntel_Outbound_Message__c.fields.Core_IPS_Status__c.isUpdateable()){
                        OldMyIntelOutboundList[0].Core_IPS_Status__c = promoted;
                    }
                    myIntelOutboundList.addAll(OldMyIntelOutboundList);
                    }}
                
                
                try{
                    if( myIntelOutboundList != null && myIntelOutboundList.size()>0){
                        upsert myIntelOutboundList;
                    }
                }
                catch(Exception ex){ String strDetails= 'Exception occured. while upserting records';
                                    Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'warn','IPS MyIntel Integration issue',strDetails,null,'Case',null);
                                   } 
                /* US-0021721- 02/08/2021 - end - Sai Krishna - For Myintel outbound repromote --*/

                
            }
            //End-------US1005799----23-06-2021
            if(myIntelOutboundList != null && myIntelOutboundList.size()>0){
                List<Attachment> attachmentList = new List<Attachment>();
                    //APEX GURU - SOQL FIX
                    Map<Id, Core_IPS_MyIntel_Outbound_Message__c> myIntelOutboundListMap = new Map<Id, Core_IPS_MyIntel_Outbound_Message__c>(myIntelOutboundList); //ApexGuru Analysis "SOQL using IN-bind variable fix" -Begin
                    //for(Core_IPS_MyIntel_Outbound_Message__c OutboundMsg:[Select id,Name from Core_IPS_MyIntel_Outbound_Message__c where Id IN : myIntelOutboundList]){
                      for(Core_IPS_MyIntel_Outbound_Message__c OutboundMsg:[Select id,Name from Core_IPS_MyIntel_Outbound_Message__c where Id IN : myIntelOutboundListMap.keySet()]){ //ApexGuru Analysis "SOQL using IN-bind variable fix" - End
                    myintelOutboundName = OutboundMsg.Name;
                    Attachment att = new Attachment();
                    if(Schema.sObjectType.Attachment.fields.Name.isCreateable()){
                        att.Name = 'Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
                    }
                    if(Schema.sObjectType.Attachment.fields.parentId.isCreateable()){
                        att.parentId = OutboundMsg.Id;
                    }
                    if(Schema.sObjectType.Attachment.fields.Body.isCreateable()){
                        //System.debug('Blob value'+Blob.valueOf(jsonString));
                        //System.debug('JSON String >>'+jsonString);
                        att.Body = Blob.valueOf(jsonString);
                    }
                    
                    attachmentList.add(att);
                }
                try{
                    if(attachmentList != null && attachmentList.size()>0){
                        if(Schema.sObjectType.Attachment.fields.Body.isCreateable()){ //TWC745-6310 FLS-Create Fix
                            insert attachmentList;  
                        }
                    }
                }catch(exception e){ String strDetails= 'Exception occured. while inserting records';
                                    Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'warn','IPS MyIntel Integration issue',strDetails,null,'Case',null);
                                   }
                //when we get any server error from Apigee
                List<String> splitErrorCodes = (Label.Core_IPS_MyIntel_Error_Codes).split(',');
                if(splitErrorCodes.contains(String.valueOf(messageWrapperObj.errorCode))){
                    
                    // start----US1005799----23-06-2021----Niyazuddin-----retry mechanisam on error 
                    String caseURL = '';
                    String caseNumber = '';
                    
                    if(retryCounter<3){
                        if(doChainJob){ System.enqueueJob(new Core_IPS_MyIntel_3_0(casesIds,operationType,this.projectMemberList,retryCounter));
                                       //End-------US1005799----23-06-2021
                                      }
                        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
                        for ( Object obj : ( List< Object > )responseMap .get( 'data' ) ) {
                            Map < String, Object > caseDetailsMap = ( Map < String, Object > )obj;
                            caseURL += String.valueof(caseDetailsMap.get('caseURL'))+',';
                            caseNumber  += String.valueof(caseDetailsMap.get('caseNumber'))+',';
                        }
                        if(retryCounter == 0){// create log entry when it failed first time
                            String strDetails= 'Call out Service Name : '+'Core_IPS_MyIntel_3_0'+'\n Trace Information : '+'STATUS:'+ messageWrapperObj.errorCode + '\nSTATUS_CODE:' + messageWrapperObj.errorCode + '\n\n Message:' + messageWrapperObj.message + '\n\n caseNumber : '+caseNumber+ '\n\n caseURL: '+caseURL +'\n MyIntel Outbound Message Name: ' + myintelOutboundName;
                            Core_Log_Entry.logEntryWithDetails('IPS_MyIntel_Integration issue','IPS',null,'error','IPS MyIntel Integration issue',strDetails,null,'Case',null);   
                        }
                        String strDetails= 'Call out Service Name : '+'Core_IPS_MyIntel_3_0'+'\n Trace Information : '+'STATUS:'+ messageWrapperObj.errorCode + '\nSTATUS_CODE:' + messageWrapperObj.errorCode + '\n\n Message:' + messageWrapperObj.message + '\n\n caseNumber : '+caseNumber+ '\n\n caseURL: '+caseURL +'\n MyIntel Outbound Message Name: ' + myintelOutboundName;
                        Core_Log_Entry.logEntryWithDetails('IPS_MyIntel_Integration issue','IPS',null,'error','IPS MyIntel Integration issue',strDetails,null,'Case',null);
                    }
                    
                    
                }
                
            }
            //End-------US1005775----23-06-2021
        }
        // Start ----- Tushar
        if (remainingCaseIds.size() > 0) {
            system.debug('calling from last end   ');
            System.enqueueJob(new Core_IPS_MyIntel_3_0(remainingCaseIds, operationType, projectMemberList, intrestedPartiesList));
        }
        // End ---- Tushar
    }
    
    /*
* Description : Helper method to update at My Intel 3.0 when cases are created or updated with relevant changes.
*               We are Making a call to Apigee for token generation.
*               And after Token availability , making one request to APIGEE to post MyIntel with JSON we have. 
* Author : Chandrashekar Pallikonda
**/
    public static MessageWrapper sendCaseData(String jsonBody){
        MessageWrapper messageWrapperObj = new MessageWrapper();
      
        try {

                String ipsMyintelEndPoint = 'callout:Core_IPS_MyIntel_Integration'; //TWC745-6310-Implement Privileged Access Management (PAM)-custom setting to Named credential change
                Http callout = new Http();
                HttpRequest postRequest = new HttpRequest();
                postRequest.setMethod('POST');
                postRequest.setEndpoint(ipsMyintelEndPoint);
                postRequest.setHeader('content-type', 'application/json');               
                
                postRequest.setBody(jsonBody);
                postRequest.setTimeout(12000);
                HttpResponse response = callout.send(postRequest); 
                if(response.getStatusCode() == 200){
                    messageWrapperObj.body = response.getBody();
                    messageWrapperObj.errorCode = response.getStatusCode();
                    messageWrapperObj.status = 'Success';
                } else {
                    messageWrapperObj.body = response.getBody();
                    messageWrapperObj.errorCode = response.getStatusCode();
                    messageWrapperObj.status = 'Failed';
                    messageWrapperObj.message = response.toString();
                    
                }

        } catch(Exception e) { 
            String strDetails= 'Exception occured.';
            Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'warn','IPS MyIntel Integration issue',strDetails,null,'Case',null);
        }
        return messageWrapperObj;
    }
    
    /*************************************************
* Description : Helper Method to Generate JSON
* Author : Chandrashekar Pallikonda
**************************************************/
    public String generateJsonBody(List<Id> casesIds,String operationType){
        String jsonData = '';

        // Added By Mohan
        if(operationType <> null && casesIds <> null){
        List<Id> projectIds = new List<Id>();
        List<Case> caseList = new List<Case>();
        List<String> contactIds = new List<String>();
        List<Contact> contactList = new List<Contact>();
        Map<String, List<Map<String,String>>> contactAccountMap = new Map<String, List<Map<String,String>>>();
        if(Case.SObjectType.getDescribe().isQueryable()){
            caseList = [SELECT Subject, Status, Product.Name,CreatedDate,LastModifiedDate ,CaseNumber, AccountId, ContactId, Contact.Core_Enterprise_Id__c, Core_ConEmail__c, Core_CaseType__c, Core_IPS_Project_Case__c, Core_IPS_Customer_Visible__c FROM Case WHERE Id IN:casesIds];
        } 
        
        contactList = [SELECT Id,AccountId,Email,Core_Enterprise_Id__c FROM Contact where AccountId IN (select AccountId from case where Id IN:casesIds and Core_IPS_Project_Case__c = null) and Core_IPS_Active__c = true]; 
        
        for(Contact con: contactList){ 
            contactIds.add(con.Email);
            if(contactAccountMap.get(con.AccountId) == null){
                String enterpriseId = (con.Core_Enterprise_Id__c != null) ? con.Core_Enterprise_Id__c : '';
                contactAccountMap.put(con.AccountId, new List<Map<String,String>>{new Map<String,String>{'emailId' => con?.Email, 'enterpriseId' => enterpriseId}});
            }else{
                String enterpriseId = (con.Core_Enterprise_Id__c != null) ? con.Core_Enterprise_Id__c : '';
                contactAccountMap.get(con.AccountId).add(new Map<String,String>{'emailId' => con?.Email, 'enterpriseId' => enterpriseId});
            }
        }
        
        for(Core_IPS_Project_Member__c projectMember : projectMemberList){
            if(!contactIds.contains(projectMember.Core_IPS_Contact__r.Email)){
                if(projectMemberMap.get(projectMember.Core_IPS_Project__c) == null){
                    String enterpriseId = (projectMember.Core_IPS_Contact__r.Core_Enterprise_Id__c != null) ? projectMember.Core_IPS_Contact__r.Core_Enterprise_Id__c : '';
                    projectMemberMap.put(projectMember.Core_IPS_Project__c, new List<Map<String,String>>{new Map<String,String>{'emailId' => projectMember.Core_IPS_Contact__r.Email, 'enterpriseId' => enterpriseId}});
                } else{
                    String enterpriseId = (projectMember.Core_IPS_Contact__r.Core_Enterprise_Id__c != null) ? projectMember.Core_IPS_Contact__r.Core_Enterprise_Id__c : '';
                    projectMemberMap.get(projectMember.Core_IPS_Project__c).add(new Map<String,String>{'emailId' => projectMember.Core_IPS_Contact__r.Email, 'enterpriseId' => enterpriseId});
                }
            }
            contactIds.add(projectMember.Core_IPS_Contact__r.Email);
        }
        
        // start---- US1038333  ----25-06-2021----Farooq---- Interested party changes my Intel-- 
        for(Core_IPS_Case_Interested_Party__c intrestedParties : intrestedPartiesList){
            if(!contactIds.contains(intrestedParties.Contact__r.Email)){
                if(intrestedPartiesMap.get(intrestedParties.Case__c) == null){
                    
                    String enterpriseId = (intrestedParties.Contact__r.Core_Enterprise_Id__c != null) ? intrestedParties.Contact__r.Core_Enterprise_Id__c : '';
                    intrestedPartiesMap.put(intrestedParties.Case__c, new List<Map<String,String>>{new Map<String,String>{'emailId' => intrestedParties.Contact__r.Email, 'enterpriseId' => enterpriseId}});
                } else{
                    
                    String enterpriseId = (intrestedParties.Contact__r.Core_Enterprise_Id__c != null) ? intrestedParties.Contact__r.Core_Enterprise_Id__c : '';
                    intrestedPartiesMap.get(intrestedParties.Case__c).add(new Map<String,String>{'emailId' => intrestedParties.Contact__r.Email, 'enterpriseId' => ''});
                }
            }
        }
        
        
        
        // End---- US1038333  ----25-06-2021----Farooq------ 
        if(!caseList.isEmpty()){
            JSONGenerator jsonGen = JSON.createGenerator(true);
            jsonGen.writeStartObject();
            jsonGen.writeStringField('category','Case');
            jsonGen.writeStringField('sourceSystem','IPS');
            jsonGen.writeFieldName('data');
            jsonGen.writeStartArray();
            for(Case cs : caseList){
                
                jsonGen.writeStartObject();
                jsonGen.writeStringField('operation',operationType);
                jsonGen.writeStringField ('Subject',String.isNotBlank(cs?.Subject) ? cs.Subject :'');
                if(cs.Product.Name != null){
                    jsonGen.writeStringField('caseProductName',cs.Product.Name);
                } else {
                    jsonGen.writeNullField('caseProductName');
                }
                jsonGen.writeStringField('caseStatus',String.isNotBlank(cs?.Status) ? cs?.Status : '');
                jsonGen.writeDateTimeField('createdDate',cs.CreatedDate);
                jsonGen.writeDateTimeField('lastModifiedDate',cs.LastModifiedDate);
                jsonGen.writeStringField('caseURL',Label.Core_MyIntel_Case_URL+cs.Id);
                jsonGen.writeStringField('caseNumber',cs?.CaseNumber);
                if(cs.accountId != null){
                    jsonGen.writeStringField('accountId',cs.accountId);
                } else {
                    jsonGen.writeNullField('accountId');
                }
                if(cs.ContactId != null){
                    jsonGen.writeStringField('contactId',cs?.ContactId);
                } else {
                    jsonGen.writeNullField('contactId');
                }
                jsonGen.writeStringField('org','IPS');
                if(cs.Core_ConEmail__c != null){
                    jsonGen.writeStringField('contactEmail', cs.Core_ConEmail__c);
                } else {
                    jsonGen.writeNullField('contactEmail');
                }
                jsonGen.writeStringField('caseType',String.isNotBlank(cs?.Core_CaseType__c) ? cs?.Core_CaseType__c : '-');
                jsonGen.writeStringField('enterpriseId',String.isNotBlank(cs?.Contact?.Core_Enterprise_Id__c) ? cs?.Contact?.Core_Enterprise_Id__c : '');
                jsonGen.writeFieldName('allContacts');
                List<Map<String,String>> projectProjectMemberMap = new List<Map<String,String>>();
                List<Map<String,String>> casecontactMap = new List<Map<String,String>>();
                List<Map<String,String>> caseIntrestedPartiesMap = new List<Map<String,String>>();
                if(!contactAccountMap.isEmpty()){
                    casecontactMap = contactAccountMap.get(cs?.AccountId);
                }
                if(projectMemberMap.get(cs.Core_IPS_Project_Case__c) != null){
                    projectProjectMemberMap = projectMemberMap.get(cs.Core_IPS_Project_Case__c);
                    projectProjectMemberMap.addAll(casecontactMap);
                }
                if(intrestedPartiesMap.get(cs.Id) != null){
                    caseIntrestedPartiesMap = intrestedPartiesMap.get((String)cs.Id);
                    caseIntrestedPartiesMap.addAll(projectProjectMemberMap);
                }
                // Start---- US1038333  ----25-06-2021----Farooq---- Interested party changes my Intel-- 
                if(!caseIntrestedPartiesMap.isEmpty()){ jsonGen.writeObject(caseIntrestedPartiesMap);
                }else if(!projectProjectMemberMap.isEmpty()){
                    jsonGen.writeObject(projectProjectMemberMap);
                    //Added by tushar for null check (casecontactMap != null)
                }else if(casecontactMap != null && !casecontactMap.isEmpty()){
                    jsonGen.writeObject(casecontactMap);
                }else{
                    jsonGen.writeObject(new List<String>());
                }
                // end----  US1038333 ----25-06-2021----Farooq---- Interested party changes my Intel-- 
                
                jsonGen.writeBooleanField('isCustomerVisible',cs?.Core_IPS_Customer_Visible__c);
                jsonGen.writeEndObject();
            }
            jsonGen.writeEndArray();
            jsonGen.writeEndObject();
            jsonData = jsonGen.getAsString();
        }
        }
        return jsonData;
    }
   
    /*************************************************
* Description : When a contact becomes IPS Active, that contact gets the access to all of his account's cases which doesn't have project associated.
* Author : Chandrashekar Pallikonda
**************************************************/
    @InvocableMethod
    public static void allCasesMyIntel(List<Contact> newContactList){
        try{
            if(!Core_Trigger_Executions__c.getValues('myIntelIntegration').Core_Active__c){ return;	}
            Map<Id,Case> caseMap = new Map<Id,Case>();
            List<Id> accountIds = new List<Id>();
            for(Contact c : newContactList){
                if(c.Core_IPS_Active__c){ accountIds.add(c.AccountId); }
            }
            if(Case.SObjectType.getDescribe().isQueryable() && !accountIds.isEmpty()){
                caseMap = new Map<Id,Case>([SELECT Id FROM Case WHERE accountId IN: accountIds and Core_IPS_Project_Case__c = null]);
            }
            if(!caseMap.isEmpty() && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()){
                System.enqueueJob(new Core_IPS_MyIntel_3_0(new List<Id>(caseMap.keySet()), 'Update', new List<Core_IPS_Project_Member__c>()));
            }
        } catch(Exception e){
            Core_IPS_ExceptionHandling.logEntryWithException(e,'Core_IPS_CaseTriggerHandler','Contact');
        }
    }
    
    public class MessageWrapper{
        public String body;
        public Integer errorCode;
        public String status;
        public String message;
        
    }
}