public with sharing class PRM_OPID_OnDemandsyncRequest { 
    
    /*public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_ORIGIN   = 'PRM_OPID_OnDemandsyncRequest';
    public static final String LOG_ENTRY_PROJECT  = 'On Demand Sync';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_OPID_OnDemandsyncRequest';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    
    @AuraEnabled
    public static void ondemandSyncReq(Id recordId){
        if(recordId!=null) {
            List<Account> accounts = new List<Account>();
            HttpRequest httpReq = new HttpRequest();
            HttpResponse response = new HttpResponse();
            try {
                accounts = [SELECT Id,Core_OnePartnerID__c,Core_Deactivated__c FROM Account WHERE id= :recordId];                            
                PRM_Integration__mdt apiDetails = [Select Id, API_Key__c, EndPointURL__c, Password__c, Username__c from PRM_Integration__mdt where MasterLabel='OnDemandSync'];
                if(apiDetails!=null){
                    if(accounts.size() > 0) {
                        string token = getToken(apiDetails) != null ? getToken(apiDetails).access_token : null; 
                        if(token != null || String.isNotBlank(token)) {       
                            httpReq = new  HttpRequest();                               
                            httpReq.setEndpoint(apiDetails.EndPointURL__c);
                            httpReq.setHeader(PRM_IPA_Constants.Authorization, PRM_IPA_Constants.Bearer +token);
                            //httpReq.setHeader('API_Key', apiDetails.API_Key__c);   
                            httpReq.setHeader('Content-Type', 'application/json');
                            //httpReq.setBody('{  "name": { "givenName": "Henry P", "familyName": "Denham"  },  "userName": "henry_91@mailinator.com",  "active": true,  "preferredLanguage": "EN",  "emails": [ {"value": "henry_91@mailinator.com","primary": true }  ],  "addresses": [ {"country": "US" }  ],  "schemas": ["urn:scim:schemas:core:1.0", "urn:scim:schemas:extension:inteluser:1.0"  ]}');
                            httpReq.setBody(constructOnDemandSyncJSON(accounts));
                            httpReq.setMethod('POST');
                            httpReq.setTimeout(Integer.valueOf(Label.APIGEETimeout));
                            response = new Http().send(httpReq);
                            if(response.getStatusCode() != 200 || response.getBody().indexOf('ErrorCode') > -1){
                                CustomException ex = new CustomException();                    
                                ex.Message = response.getBody();                          
                                ex.StackTraceString = 'CIM API Error';                    
                                createErrorOPIDSyncRecord('Unable to Initiate Sync Request', accounts[0], ex, LOG_ENTRY_ERROR); 
                            }else{
                                createOPIDSyncReqRecord(EncodingUtil.urlDecode(response.getBody(), 'UTF-8'), accounts[0]); 
                            }
                        }
                    }
                }else{
                    CustomException ex = new CustomException();                    
                    ex.Message = 'End Point Record is not available';                          
                    ex.StackTraceString = 'PRM_Integration__mdt';                    
                    createErrorOPIDSyncRecord(ex.Message, accounts[0], ex, LOG_ENTRY_ERROR);  
                }
            }catch(Exception ex){
                CustomException custEx = new CustomException();
                custEx.Message = ex.getMessage();
                custEx.Cause = ex.getCause();
                custEx.StackTraceString = ex.getStackTraceString();
                custEx.LineNumber = ex.getLineNumber();                
                custEx.TypeName = ex.getTypeName();
                
                createErrorOPIDSyncRecord('Issue in Record Id', accounts[0], custEx, LOG_ENTRY_ERROR);               
            }
            finally
            {
                // Calling the utility method to create Integration log record
                PRM_IPA_Utility.createIntegrationLog(recordId,PRM_IPA_Constants.CALLOUT_TYPE_OUTBOUND,PRM_IPA_Constants.MODULE_ONDEMAND_OPID,constructOnDemandSyncJSON(accounts),response.getBody(),response.getStatusCode(),PRM_IPA_Constants.SYSTEM_NAME_CIM,'PRM_OPID_OnDemandsyncRequest');         
                
            }
        }
    }
    
    public static PRM_Token_Model getToken(PRM_Integration__mdt agsAPIDetails) {
        PRM_Token_Model token = new PRM_Token_Model();
        try {
            HttpRequest httpReq = new  HttpRequest();
            httpReq.setEndpoint(agsAPIDetails.API_Key__c);
            httpReq.setMethod( 'POST' );
            httpReq.setHeader('content-type', 'application/x-www-form-urlencoded');
            
            //string gType = EncodingUtil.urlEncode('client_credentials','UTF-8');
            String payLoad = 'grant_type=client_credentials&client_id=' + EncodingUtil.urlEncode(agsAPIDetails.Username__c,'UTF-8') +'&client_secret=' + EncodingUtil.urlEncode(agsAPIDetails.Password__c, 'UTF-8');
            httpReq.setBody(payLoad);
            HttpResponse response = new Http().send(httpReq);
            if(response.getStatusCode() == 200 ) {
                token = PRM_Token_Model.parse(response.getBody());
                Cache.Org.put('local.PRMIPAPartition.APIGEEaccesstoken',token.access_token, Integer.valueOf(Label.APIGEETokenExpiryTime),Cache.Visibility.ALL, true);
            }
            else {
                CustomException ex = new CustomException();                    
                ex.Message = 'Error in token generation -'+response.getBody();  
                createErrorOPIDSyncRecord(ex.Message, null, ex, LOG_ENTRY_ERROR);
            }
        }
        catch(Exception ex){
            CustomException custEx = new CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();
            createErrorOPIDSyncRecord('API token issue', null, custEx, LOG_ENTRY_ERROR); 
        }
        return token;
    }
    
    public static String constructOnDemandSyncJSON(List<Account> accList) {
        List<String> parterIds = new List<String>();
        String jsonStr='';
        outputJsonWrapper jsonWrap = new outputJsonWrapper();
        for(Account accRec : accList){
            if(accRec.Core_OnePartnerID__c != null){           
                parterIds.add(accRec.Core_OnePartnerID__c);
            }
        }
        if(parterIds!=null && !parterIds.isEmpty()) {  
            jsonWrap.Core_OnePartnerID_Tempc =parterIds;            
            jsonStr =JSON.serialize(jsonWrap);
            jsonStr = jsonStr.replace('Core_OnePartnerID_Tempc', 'Core_OnePartnerID__c');   
        } 
        return jsonStr;
    }
    
    public static void createErrorOPIDSyncRecord(String msg, Account acc, CustomException ex, String severity){
        try{ 
            Id recId = acc.Id;
            String strDetailsAndEx = '';
            strDetailsAndEx += 'Message: ' + ex.Message + '\n';
            strDetailsAndEx += 'Cause: ' + ex.Cause + '\n';
            strDetailsAndEx += 'Line Number: ' + ex.LineNumber + '\n';
            strDetailsAndEx += 'Stack Trace: ' + ex.StackTraceString + '\n';
            strDetailsAndEx += 'Type Name: ' + ex.TypeName + '\n';
            if(recId != null){
                //Creating error records
                OPID_Sync_Request__c opSyncRec = new OPID_Sync_Request__c();
                opSyncRec.OP_CIMID__c = acc.Core_OnePartnerID__c;
                opSyncRec.OPID_Account__c = recId;
                //opSyncRec.Response__c = msg;
                opSyncRec.Status__c = 'Failed';
                opSyncRec.Status_Reason__c = strDetailsAndEx; 
                //Status Reason need to add here;
                insert opSyncRec;
            }
            
        }catch(Exception e){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);
        }
        
    }
    
    public static void createOPIDSyncReqRecord(String msg, Account acc){
        system.debug('msg-->'+msg+'Account-->'+acc);
        try{ 
            Id recId,syncObjRecId; 
            //String strDetailsAndEx = '';
            Boolean isEmptyResponse = (msg != null && msg.length() < 10 && msg.contains('[') && msg.contains(']'));

            if(acc != null && msg != null){
                recId = acc.Id;
                OPID_Sync_Request__c opSyncRec = new OPID_Sync_Request__c();
                opSyncRec.OP_CIMID__c = acc.Core_OnePartnerID__c;
                opSyncRec.OPID_Account__c = acc.Id;
                opSyncRec.Response__c = msg;
                opSyncRec.Status__c = 'Sync Response Received';
                insert opSyncRec;
                syncObjRecId = opSyncRec.Id;
       }
            if((msg != null && !msg.contains('No Data retrieved')) || isEmptyResponse){
                //Querying the SF Active CAG records based on AccountId
                //List<Core_Account_Group_Member__c> cagSFRecsList = [SELECT Id, Name, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Inactive_Ind__c from Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c =:recId AND Core_Inactive_Ind__c != true];
                //Map<Id, Core_Account_Group_Member__c> existingCAGMap = new Map<Id, Core_Account_Group_Member__c>([SELECT Id, Name, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Inactive_Ind__c,Core_Partner_Account_Id__r.Name, from Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c =:recId AND Core_Inactive_Ind__c != true]);
                Map<Id, Core_Account_Group_Member__c> existingCAGMap = new Map<Id, Core_Account_Group_Member__c>([SELECT Id, Name, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Inactive_Ind__c,Core_Partner_Account_Id__r.Name,Core_Partner_Account_Id__r.Core_Prime_Account_Name__c,
                                                                           Core_Partner_Account_Id__r.Core_PAG_Grouping_Method__c,Core_Intel_Account_Id__r.Core_Business_Party_Id__c from Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c =:recId AND Core_Inactive_Ind__c != true]);

                Set<Id> locationAccIds = new Set<Id>();
                Map<String, Set<Id>> locationSFAccMap = new Map<String,Set<Id>>();
                Set<Id> accountIdPAG = new set<Id>();           
                List<Core_OnePartner_Inbound_Message__c> InboundlistToInsert = new List<Core_OnePartner_Inbound_Message__c>();
                List<Core_OnePartner_Inbound_Message__c> inboundrecsInsertList = new List<Core_OnePartner_Inbound_Message__c>();
                Set<Id> CIMaccountIds = new Set<Id>();
                Map<String, Set<Id>> CIMRecordsMap = new Map<String,Set<Id>>();
                Set<Id> idsToInsertSet = new Set<Id>();
                Set<Id> detachmentrecsSet = new Set<Id>();
                //List<Core_OnePartner_Inbound_Message__c> detachmentRecsInsertList = new List<Core_OnePartner_Inbound_Message__c>();
                Map<String,List<Core_OnePartner_Inbound_Message__c>> cimRecordDetailsMap = new Map<String,List<Core_OnePartner_Inbound_Message__c>>();
                Map<Id, Account> accstoUpdateMap = new Map<Id,Account>();
                
                //Getting all location account ids, Core OP IDs from CAG active list
                for(Core_Account_Group_Member__c cagRecs: existingCAGMap.values()){
                    if(cagRecs.Core_Intel_Account_Id__c != null){
                        locationAccIds.add(cagRecs.Core_Intel_Account_Id__c);
                    }
                    if(cagRecs.Core_Partner_Account_Id__r.Core_OnePartnerID__c != null && locationAccIds !=null){
                        locationSFAccMap.put(cagRecs.Core_Partner_Account_Id__r.Core_OnePartnerID__c, locationAccIds);
                    }
                    if(isEmptyResponse){
                        detachmentrecsSet.add(cagRecs.Core_Intel_Account_Id__c);
                    }
                }
                //Deserialize the JSON response - 
                if(!isEmptyResponse){
                //List<Map<String, String>> wrapList = new List<Map<String, String>>();
                List<Object> CIMResponseRecsList = (List<Object>) JSON.deserializeUntyped(msg);
                Map<String,Object> deserializedRecordsMap = (Map<String,Object>) JSON.deserializeUntyped(json.serialize(CIMResponseRecsList[0]));
                String jsonStr = JSON.serialize(deserializedRecordsMap.values());
                String replacedjson = replaceJsonString(jsonStr);
                List<List<cimRecsMappingwrapper>> inboundwrapList= cimRecsMappingwrapper.parse(replacedjson);
                List<cimRecsMappingwrapper> inboundwrapRecsList = inboundwrapList[0];
                
                for(cimRecsMappingwrapper wrap :inboundwrapRecsList){
                    Core_OnePartner_Inbound_Message__c inboundRecord = new Core_OnePartner_Inbound_Message__c();
                    inboundRecord.Core_Effective_End_Date_Time__c=wrap.Core_Effective_End_Date_Time_Temp;
                    inboundRecord.Core_OnePartner_Account_Name__c = wrap.Core_OnePartner_Account_Name_Temp;
                    inboundRecord.Core_OnePartnerID__c = decimal.valueOf(wrap.Core_OnePartnerID_Temp);
                    inboundRecord.Core_PrimeID__c = wrap.Core_PrimeID_Temp != null? decimal.valueOf(wrap.Core_PrimeID_Temp.trim()): null; 
                    inboundRecord.Core_SalesCloud_AccountID__c = wrap.Core_SalesCloud_AccountID_Temp;   
                    inboundRecord.Core_Status__c= 'NEW'; 
                    inboundRecord.Core_Status_Reason__c = wrap.Core_Status_Reason_Temp;
                    inboundRecord.Core_Effective_Start_Date_Time__c = wrap.Core_Effective_Start_Date_Time_Temp;
                    inboundRecord.Core_PAG_Grouping_Method__c = wrap.Core_PAG_Grouping_Method_Temp;
                    inboundRecord.OPID_Sync_Request__c = syncObjRecId;
                    inboundRecord.Core_Status_Effective_End_Date_Time__c = wrap.Core_Status_Effective_End_Date_Time_Temp;
                    InboundlistToInsert.add(inboundRecord);
                }
                }
                //Getting all CIM account ids
                List<Core_OnePartner_Inbound_Message__c> listofInboundMessage = null;
                 if(!InboundlistToInsert.isEmpty()){
                    for(Core_OnePartner_Inbound_Message__c cimRec: InboundlistToInsert){
                        //cimRecordDetailsMap.put(String.valueof(cimRec.Core_OnePartnerID__c), cimRec);
                        if(!cimRecordDetailsMap.containskey(String.valueof(cimRec.Core_OnePartnerID__c))){
                            listofInboundMessage = new List<Core_OnePartner_Inbound_Message__c>();
                            listofInboundMessage.add(cimRec);
                            cimRecordDetailsMap.put(String.valueof(cimRec.Core_OnePartnerID__c),listofInboundMessage);
                        }else{
                            cimRecordDetailsMap.get(String.valueof(cimRec.Core_OnePartnerID__c)).add(cimRec);
                        }
                        if(cimRec.Core_SalesCloud_AccountID__c != null){
                            CIMaccountIds.add(cimRec.Core_SalesCloud_AccountID__c);
                        }
                        if(CIMaccountIds != null && cimRec.Core_OnePartnerID__c != null){
                            CIMRecordsMap.put(String.valueof(cimRec.Core_OnePartnerID__c), CIMaccountIds);
                        }
                        if(cimRec.Core_Status_Effective_End_Date_Time__c != null && acc.Core_Deactivated__c == false)
                        {
                            //for OPID deactivation
                            inboundrecsInsertList.add(cimRec);
                        }

                    }
                    //Extract Logic starts here - Creating inbound msg object records

                    if(!CIMRecordsMap.keyset().isEmpty()){
                       //Getting the Non Matched SF Records - Detachment records Insert
                       if(!locationSFAccMap.keyset().isEmpty()){
                           for(String str: locationSFAccMap.keyset()){
                                for(Id ids: locationSFAccMap.get(str)){
                                    if(CIMRecordsMap.get(str).contains(ids) == false){
                                        detachmentrecsSet.add(ids); //= locationSFAccMap.get(str);
                                    }   
                                }
                        	} 
                       } 	
                        //Getting the CIM records for Insert
                        for(String str: CIMRecordsMap.keyset()){
                            for(Id ids: CIMRecordsMap.get(str)){
                                if(!locationSFAccMap.keyset().isEmpty()){
                                    //Checking CIM records having a match of SF records
                                    if(locationSFAccMap.get(str).contains(ids) == false){
                                        idsToInsertSet.add(ids);// = CIMRecordsMap.get(str);
                                	}
                                	if(!locationSFAccMap.containsKey(str)){
                                        idsToInsertSet.add(ids);// = CIMRecordsMap.get(str);
	                                }
                                }//End of Location Map has values if
                                else{//If CIM have records but SF is not having assiciated records
                                	idsToInsertSet.add(ids);
                            	}
                            }
                        }
                        
                    }
                } //End of inboundCIMrecsList
                
                //Adding a logic to handle CIM Name Changes, Grouping Method Changes - as part of on demand sync
                if(!cimRecordDetailsMap.isEmpty() && !existingCAGMap.isEmpty()){
                    //Checking the data between CIM and SF
                   // for(Core_OnePartner_Inbound_Message__c cimRecs: cimRecordDetailsMap.values()){
                        
                         for(Core_Account_Group_Member__c cagSFRecs: existingCAGMap.values()){
                           	//Checking the Name Difference from CIM and SF
                             List<Core_OnePartner_Inbound_Message__c> cimRecsList  = cimRecordDetailsMap.get(cagSFRecs.Core_Partner_Account_Id__r.Core_OnePartnerID__c);
                             for(Core_OnePartner_Inbound_Message__c cimRecs :cimRecsList){  
                             if(cagSFRecs.Core_Partner_Account_Id__c != null && ((cimRecs.Core_PAG_Grouping_Method__c != null && cimRecs.Core_PAG_Grouping_Method__c != cagSFRecs.Core_Partner_Account_Id__r.Core_PAG_Grouping_Method__c)|| (cimRecs.Core_OnePartner_Account_Name__c != null && cimRecs.Core_OnePartner_Account_Name__c != cagSFRecs.Core_Partner_Account_Id__r.Name)) || (cimRecs.Core_Status_Effective_End_Date_Time__c != null && (acc.Core_Deactivated__c == false))){
                                      Account updateAcc = new Account();
                                      updateAcc.id = cagSFRecs.Core_Partner_Account_Id__c; 
                                  	  updateAcc.Name = cimRecs.Core_OnePartner_Account_Name__c;
                                      updateAcc.Core_PAG_Grouping_Method__c = cimRecs.Core_PAG_Grouping_Method__c;
                                      if(cimRecs.Core_Status_Effective_End_Date_Time__c != null && (acc.Core_Deactivated__c == false))
                                      {
                                      updateAcc.Core_Deactivated__c = true;
                                      accountIdPAG.add(updateAcc.id);
                                      }
                                      accstoUpdateMap.put(updateAcc.Id,updateAcc);
                                    }
                            
                                }
                            
                    }
                }

            List<PRM_AccountBenefitAssociation__c> updateBenefitList = new  List<PRM_AccountBenefitAssociation__c>();
            for(PRM_AccountBenefitAssociation__c aba : [Select Id,Name,PRM_Account_Id__c,PRM_Partner_Benefit_Id__c,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accountIdPAG]){
                aba.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;   
                aba.PRM_Status_Reason_Txt__c ='Inactivated as 1PID is deactivated';//TWC729-8089 : Adding reason text : NJ 
                updateBenefitList.add(aba);                   
            }
            if((updateBenefitList != null && !updateBenefitList.IsEmpty())){
                //To skip the MP benefit validation
                PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits = true;
                Database.update(updateBenefitList,false);
            }


                if(!accstoUpdateMap.isEmpty() && idsToInsertSet.isEmpty() && detachmentrecsSet.isEmpty()){
                    update accstoUpdateMap.values();
                    if(syncObjRecId != null){
                        OPID_Sync_Request__c opSyncRecUpdate= new OPID_Sync_Request__c();
                        opSyncRecUpdate.Id = syncObjRecId; 
                        opSyncRecUpdate.Status__c = 'Success';
                        update opSyncRecUpdate;
                	}
                }
                
                if(idsToInsertSet != null){
                    for(Core_OnePartner_Inbound_Message__c inbMsg: InboundlistToInsert){
                        //Constructing core inbound message insert list
                        if(idsToInsertSet.contains(inbMsg.Core_SalesCloud_AccountID__c) && inboundrecsInsertList.indexOf(inbMsg) == -1){
                            inboundrecsInsertList.add(inbMsg);
                        }
                        //Constructing core inbound message detachment list
                        /*if(detachmentrecsSet.contains(inbMsg.Core_SalesCloud_AccountID__c)){
                            //detachmentrecsSet.remove(inbMsg.Core_SalesCloud_AccountID__c);
                            inbMsg.Core_Effective_End_Date_Time__c = DateTime.now().addDays(-1);
                            detachmentRecsInsertList.add(inbMsg);
                        }*/
                    /*}
                }
                if(detachmentrecsSet != null){
                    for(Core_Account_Group_Member__c cagRecords: existingCAGMap.values()){
                        if(detachmentrecsSet.contains(cagRecords.Core_Intel_Account_Id__c)){
                            Core_OnePartner_Inbound_Message__c inboundRecord = new Core_OnePartner_Inbound_Message__c();
                            inboundRecord.Core_SalesCloud_AccountID__c = cagRecords.Core_Intel_Account_Id__c;
                            inboundRecord.Core_Status__c ='NEW';
                            inboundRecord.Core_Status_Reason__c ='Detach request created by SF - On Demand Sync Detachment Process';
                            inboundRecord.Core_OnePartner_Account_Name__c = cagRecords.Core_Partner_Account_Id__r.Name;
                            inboundRecord.Core_PAG_Grouping_Method__c = cagRecords.Core_Partner_Account_Id__r.Core_PAG_Grouping_Method__c;
                            inboundRecord.Core_Effective_End_Date_Time__c = DateTime.now().addDays(-1);
                            inboundRecord.Core_OnePartnerID__c = Integer.valueOf(cagRecords.Core_Partner_Account_Id__r.Core_OnePartnerID__c);
							inboundRecord.OPID_Sync_Request__c = syncObjRecId;
                            inboundrecsInsertList.add(inboundRecord);
                        }
                    }
                }
                if(!inboundrecsInsertList.isEmpty()){
                    insert inboundrecsInsertList;
                }
                //Updating the status as "In-Progress"
                if(syncObjRecId != null){
                    OPID_Sync_Request__c opSyncRecUpdate= new OPID_Sync_Request__c();
                    opSyncRecUpdate.Id = syncObjRecId; 
                    opSyncRecUpdate.Status__c = 'In Progress';
                    update opSyncRecUpdate;
                }
            }else{
				if(syncObjRecId != null){
                    OPID_Sync_Request__c opSyncRecUpdate= new OPID_Sync_Request__c();
                    opSyncRecUpdate.Id = syncObjRecId; 
                    opSyncRecUpdate.Status__c = 'Failed';
                    update opSyncRecUpdate;
				}
			}
        }catch(Exception e){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);
        }
        
    }
    
    public static String replaceJsonString(String jsonStr){   
        //TWC729-7726 : Cim Prime EOL start 
        jsonStr=jsonStr.replace('Core_Business_Party_ID__c','Core_Business_Party_ID_Temp');
        //TWC729-7726 : Cim Prime EOL end
       jsonStr=jsonStr.replace('Core_Effective_End_Date_Time__c','Core_Effective_End_Date_Time_Temp');
       jsonStr=jsonStr.replace('Core_OnePartner_Account_Name__c','Core_OnePartner_Account_Name_Temp');
       jsonStr=jsonStr.replace('Core_OnePartnerID__c','Core_OnePartnerID_Temp');
       jsonStr=jsonStr.replace('Core_PrimeID__c','Core_PrimeID_Temp');
       jsonStr=jsonStr.replace('Core_SalesCloud_AccountID__c','Core_SalesCloud_AccountID_Temp');
       jsonStr=jsonStr.replace('Core_Status_Reason__c','Core_Status_Reason_Temp');
       jsonStr=jsonStr.replace('Core_Status__c','Core_Status_Temp');
       jsonStr=jsonStr.replace('Core_Effective_Start_Date_Time__c','Core_Effective_Start_Date_Time_Temp');
       jsonStr=jsonStr.replace('Core_PAG_Grouping_Method__c','Core_PAG_Grouping_Method_Temp');
    return jsonStr;
   }
    
    //Wrapper Class for Output JSON Request    
    public class outputJsonWrapper{
        public List<string> Core_OnePartnerID_Tempc;
    } 
    
    public class CustomException extends Exception {
        public String message {set;get;}
        public Exception cause {set;get;}
        public Integer lineNumber {set;get;}
        public String stackTraceString {set;get;}
        public String typeName {set;get;}
    }
    
   //Wrapper for creating SF core inbound msg records
   public class cimRecsMappingwrapper {
    public String Core_CIM_ID_Temp;
    public String Core_Business_Party_ID_Temp;
    public DateTime Core_Effective_End_Date_Time_Temp;
    public String Core_OnePartner_Account_Name_Temp;
    public String Core_OnePartnerID_Temp;
    public String Core_Prime_Account_Name_Temp;
    public String Core_PrimeID_Temp;
    public String Core_SalesCloud_AccountID_Temp;
    public String Core_Status_Temp;
    public String Core_Status_Reason_Temp;
    public DateTime Core_Effective_Start_Date_Time_Temp;
    public String Core_PAG_Grouping_Method_Temp;
    public DateTime Core_Status_Effective_End_Date_Time_Temp;
    
    }
    public static List<List<cimRecsMappingwrapper>> parse(String json) {
            return (List<List<cimRecsMappingwrapper>>) System.JSON.deserialize(json, List<List<cimRecsMappingwrapper>>.class);
    }*/
}