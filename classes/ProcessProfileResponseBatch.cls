global class ProcessProfileResponseBatch implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT id,PRM_Matching_Contact__c,PRM_Email_ID__c,PRM_Salesforce_ID__c,'+
        'PRM_New_Account__c, PRM_Profile_Response__c From PRM_Registration_Request__c where Sync_Profile_Response__c = true';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<PRM_Registration_Request__c> listRegReq) {
        //regReqRecord.PRM_Salesforce_ID__c for querying account record
        //PRM_Matching_Contact__c,PRM_Email_ID__c to query contact
        Set<Id> setExistingContactId = new Set<Id>();
        Set<String> setExistingContactWithmail = new Set<String>();
        Set<Id> regReqDuplicateAccIdSet = new Set<Id>();
        Map<Id, Contact> existingContactMap = new Map<Id, Contact>();
        Map<Id,Account> mapAccount = new Map<Id,Account>();
        List<Core_Log_Entry__c> listCoreLogEntry = new List<Core_Log_Entry__c>();

        for(PRM_Registration_Request__c regReq: listRegReq){
            if(regReq.PRM_Matching_Contact__c != null){
                setExistingContactId.add(regReq.PRM_Matching_Contact__c);
            }
            if(String.isNotBlank(regReq.PRM_Email_ID__c)){
                setExistingContactWithmail.add(regReq.PRM_Email_ID__c);
            }
            if(regReq.PRM_Salesforce_ID__c != null){              
                regReqDuplicateAccIdSet.add(regReq.PRM_Salesforce_ID__c);
            }
            if(regReq.PRM_New_Account__c != null){              
                regReqDuplicateAccIdSet.add(regReq.PRM_New_Account__c);
            }
        }
        if(!setExistingContactId.isEmpty() || !setExistingContactWithmail.isEmpty()){
            existingContactMap = new Map<Id, Contact>([
                SELECT 
                    Id,
                    AccountId,
                    Email,
                    Core_IPA_Contact_Segment__c,
                    Core_eRPM_Language_Code__c,
                    Core_IPA_PartnerRole__c,
                    Core_Do_Not_Contact__c,
                    Core_Preferred_Language__c,
                    PRM_Wechat_Union_Id__c,
                    Core_Login_Status__c,
                    Core_Enterprise_Id__c
                    /*Core_Login_Id__c*/  //IPA 2.0 - Removed login id reference- TWC-729-8150   
                FROM Contact 
                WHERE Id IN : setExistingContactId
                    OR Email IN: setExistingContactWithmail]);
        }
        
        mapAccount = new Map<Id, Account>([
            SELECT
            Id,
            Core_IPA_Partner_Segment__c,
            Name,
            AccountNumber,
            Core_Intel_Partner_Alliance_PartnerGroup__c,
            Core_Account_Type__c,
            Core_IPS_Active__c,
            Core_IPA_Partner_Role__c,
            Core_User_Defined_Phone_Number__c,
            Core_User_Defined_Website__c,
            RecordTypeId
            FROM Account
            WHERE Id IN: regReqDuplicateAccIdSet]);

        for(PRM_Registration_Request__c regReq: listRegReq){
            try {
                if(regReq.PRM_Profile_Response__c != null){
                    //if(PRM_IPAR_ProfileResponse_Utility.profRespSwitch){
                        PRM_ProfileResponse.createResponse_IPAR(listRegReq,mapAccount.values());
                    /*}else{
                        PRM_ProfileResponse.createResponse(listRegReq,mapAccount.values(),existingContactMap.values(),false);
                    }*/ // IPA Switch removal
                }
                List<Core_Account_Group_Member__c> cagList = PRM_ProfileResponseOptIn.getCAGList(mapAccount.keyset());
                //Calculate the Opt In and Points Not Eligible for Profile Response
                //if(PRM_IPAR_ProfileResponse_Utility.profRespSwitch){// TWC727-2858 : IPA 2.0 : Profile Responses- Points Status Calculations
                    PRM_ProfileResponseOptIn.checkExtProfRespOnOPIDAndCreateResp_IPAR(mapAccount.values(),existingContactMap.values(), cagList, listRegReq);
                /*}else{
                    PRM_ProfileResponseOptIn.checkExtProfRespOnOPIDAndCreateResp(mapAccount.values(),existingContactMap.values(), cagList, listRegReq);
                }*/ // IPA Switch removal
                regReq.Sync_Profile_Response__c = false;
                regReq.Profile_Response_Sync_Result__c = 'Success';
            } catch (Exception exc) {
                listCoreLogEntry.add(createLogEntry('Profile Sync Failure',regReq.Id,exc,'Medium'));
                regReq.Profile_Response_Sync_Result__c = 'Failure : Reason - '+ exc.getMessage();
            }
        }

        Database.SaveResult[] srList = Database.update(listRegReq, false);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()){
                for(Database.Error err : sr.getErrors()) {
                    listCoreLogEntry.add(createLogEntry('ProcessProfileResponseBatch : '+err.getMessage(),sr.getId(),null,'Medium'));
                }
            }
        }

        if(!listCoreLogEntry.isEmpty()){
            database.insert(listCoreLogEntry,false);
        }

    }

    global void finish(Database.BatchableContext BC) {

    }

    //Schedulable Implementation
    global void execute(SchedulableContext sc){

        List<AsyncApexJob> listName = [
            SELECT 
                ApexClass.Name, 
                Id, 
                JobItemsProcessed, 
                JobType, 
                Status, 
                NumberOfErrors, 
                MethodName 
            FROM AsyncApexJob 
            WHERE JobType  = 'BatchApex' 
            AND ApexClass.Name = 'ProcessProfileResponseBatch' 
            AND Status IN ('Preparing', 'Processing', 'Holding', 'Queued')
        ];

        if(listName.isEmpty()) {
            database.executebatch(new ProcessProfileResponseBatch(), 1);
        }
    }

    //pass the cronexpression to schedule the batch
    public static void processProfileResponseBatchSchedular(Integer everyNthMinute){
        if (everyNthMinute != null && everyNthMinute != 0) {
            Integer counter = 1;
            for(Integer minute =0; minute < 60; minute++){
                if(Math.mod(minute,everyNthMinute)==0){
                    String scheduleName = 'processProfileResponseBatchSchedular' + String.valueOf(counter);
                    String cronPattern  = '0 '+ String.valueOf(minute) +' * * * ?';
                    System.schedule(scheduleName ,cronPattern, new ProcessProfileResponseBatch());
                    counter++;
                }
            }
        }
    }
    
    public static Core_Log_Entry__c createLogEntry(String msg, Id reqId, Exception ex, String severity){
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c();
        String strTags = '';
        String strDetailsAndEx = '';
        

        if( ex != null ) {
            strDetailsAndEx += 'Message: ' + ex.getMessage() + '\n';
            strDetailsAndEx += 'Cause: ' + ex.getCause() + '\n';
            strDetailsAndEx += 'Line Number: ' + ex.getLineNumber() + '\n';
            strDetailsAndEx += 'Stack Trace: ' +ex.getStackTraceString() + '\n';
            strDetailsAndEx += 'Type Name: ' +ex.getTypeName() + '\n';
        }
        
        objCLE.Core_Origin__c = 'SFDC';
        objCLE.Core_Project__c = 'Profile Response Sync';
        objCLE.Core_Scope__c = 'Sync Profile Response';
        objCLE.Core_Severity__c = severity;
        objCLE.Core_Message__c = msg;
        objCLE.Core_When__c = system.now();
        objCLE.Core_Details__c = strDetailsAndEx;
        objCLE.Core_sObjectId__c = reqId;
        objCLE.Core_sObjectType__c = 'PRM_Registration_Request__c';
        objCLE.Core_Tags__c = strTags;

        return objCLE; 
    }
}