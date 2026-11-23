/*********************************************************************************************************************
    Apex Class Name  : PRM_IPA_Utility
    Version       : 1.0
    Created Date  : DEC 2021
    Function      : Utility class containing common business logic for IPA
    Modification Log :
    * Developer                 Date                    Description
    * --------------------------------------------------------------------------------------------------------------------
    * 
    *********************************************************************************************************************/
    public without sharing class PRM_IPA_Utility {

        //public static boolean IPARefresh = Boolean.valueOf(label.PRM_IPARefresh);

        //Use this method to create a log entry record for Integrations.    
        public static PRM_Integration_Log__c createIntegrationLog(String recordId ,String callType, String module, String reqPayload, String respPayload, Integer respCode ,String systemName, String className)
        {
            System.debug('In 18::'+recordId +' length: ' +recordId.length());
            PRM_Integration_Log__c intLog = new PRM_Integration_Log__c();
            intLog.PRM_Record_ID__c = recordId;
            intLog.PRM_Callout_Type__c = callType;
            intLog.PRM_Module__c = module;
            intLog.PRM_Request_Payload__c = reqPayload;
            intLog.PRM_Response_Payload__c = respPayload;
            intLog.PRM_Response_Code__c = respCode;
            intLog.PRM_System_Name__c = systemName;
            intLog.PRM_Class__c = className;
            //System.debug('>>>'+PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger);
            if(!(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))){
                insert intLog;
            }
            
        
            if(className=='PRM_CIMCallout'){
                //system.enqueueJob(new PRM_RegistrationTrackerUtility.UpdateTrackerSteps (recordId,intLog!=null?string.valueof(intLog.Id):null,'PRM_CIMCallout',null));           
                set<string> recList=new set<String>();
                if(recordId !=null)
                    recList.add(string.valueof(recordId ));
                if(recList!=null && System.Label.PRM_Tracker_Enabled=='true')
                    PRM_RegistrationTrackerUtility.EnQueueTrackerUtility(recList,null,intLog!=null?string.valueof(intLog.Id):null,'PRM_CIMCallout','Self');
            }
        
            return intLog;
        }
        
        public static PRM_Integration_Log__c createPCCIntegrationLog(String recordId ,String callType, String module, String reqPayload, String respPayload, Integer respCode ,String systemName, String className,  DateTime reqTime, DateTime resTime, Boolean insertRecord, Id program, String reqUrl)
        {
            System.debug('In 18::'+recordId +' length: ' +recordId.length());
            PRM_Integration_Log__c intLog = new PRM_Integration_Log__c();
            intLog.PRM_Record_ID__c = recordId;
            intLog.PRM_Callout_Type__c = callType;
            intLog.PRM_Module__c = module;
            intLog.PRM_Request_Payload__c = reqPayload;
            intLog.PRM_Response_Payload__c = respPayload;
            intLog.PRM_Response_Code__c = respCode;
            intLog.PRM_System_Name__c = systemName;
            intLog.PRM_Class__c = className;
            intLog.PCC_Partner_Program__c = program;
            intLog.PCC_Requested_URL__c = reqUrl;
            if(!(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))){
                if(Schema.sObjectType.PRM_Integration_Log__c.isCreateable()){
                    insert intLog;
                }else{
                    Core_Log_Entry.logEntryWithDetails('PRM_IPA_Utility', 'PCC','createIntegrationLog', 'exception',System.label.PRM_Log_Entry_Error_Object_Level,System.label.PRM_Log_Entry_Error_Object_Level , ' ', '', ' ');
                }
            }          
            return intLog;
        }

        public static PRM_Integration_Log__c createIntegrationLog(String recordId ,String callType, String module, String reqPayload, String respPayload, Integer respCode ,String systemName, String className, DateTime reqTime, DateTime resTime)
        {
            PRM_Integration_Log__c intLog = new PRM_Integration_Log__c();
            intLog.PRM_Record_ID__c = recordId;
            intLog.PRM_Callout_Type__c = callType;
            intLog.PRM_Module__c = module;
            intLog.PRM_Request_Payload__c = reqPayload;
            intLog.PRM_Response_Payload__c = respPayload;
            intLog.PRM_Response_Code__c = respCode;
            intLog.PRM_System_Name__c = systemName;
            intLog.PRM_Class__c = className;
            intLog.PRM_Request_timestamp__c = reqTime;
            intLog.PRM_Response_timestamp__c = resTime;
            if(!(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))){
                insert intLog;
            }                 
            createIntegrationLogForClasses(className,reqPayload,intLog);
            return intLog;
        }

        //cognitive complexity
       public static void createIntegrationLogForClasses (string className,string reqPayload,PRM_Integration_Log__c intLog){
            if(className=='PRM_Account_Contact_Profiles' && reqPayload!=null){        
                Map<String, Object> reqMap =   (Map<String, Object>) JSON.deserializeUntyped(reqPayload);
                set<String> emailids =new set<String>();
                string emailid;
                boolean program=false;
                Map<String,Object> ind =( Map<String,Object> ) reqMap.get('KeyInput');
                if(ind.containskey('Name') && (String)ind.get('Name')!=null && (String)ind.get('Name')=='IPA')
                    program=true;
            
            if( (String)ind.get('InputValue') !=null)
                    emailid=string.valueof(ind.get('InputValue'));
            if(program && emailid!=null && System.Label.PRM_Tracker_Enabled=='true')
                {emailids.add(emailid);
                system.enqueueJob(new PRM_RegistrationTrackerUtility.UpdateTrackerSteps (null,emailids,intLog!=null?string.valueof(intLog.Id):null,'PRM_Account_Contact_Profiles',null));        
                }
                }        
        
            if(className=='PRM_CIMAccountSearch'){
                set<String> emailids=new set<string>(); 
                string emailid;
                if(reqPayload!=null)
                    emailid=reqPayload.substringBetween('EmailAddress:',',');
                if(emailid!=null && System.Label.PRM_Tracker_Enabled=='true'){
                    emailids.add(emailid);
                    system.enqueueJob(new PRM_RegistrationTrackerUtility.UpdateTrackerSteps(null,emailids,intLog!=null?string.valueof(intLog.Id):null,'PRM_CIMAccountSearch',null));        
                }
            }
        }
        
        //Use this method to check system accounts
        @AuraEnabled
        public static Map<String,Boolean> systemAccountDetails(List<String> regReqEmails){
            Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = Core_Intel_System_Accounts__mdt.getAll();
            Set<Id>sysAccIdSet=new Set<Id>();
            Map<String,Boolean> returnSysAccMap = new Map<String,Boolean>();
            if(regReqEmails.size() > 0 && !mapSysAcc.isEmpty()){
                for(String keySetString : mapSysAcc.keySet()){
                    sysAccIdSet.add(mapSysAcc.get(keySetString).AccountId__c);
                }        
                if(sysAccIdSet != null){
                    for(Contact cons : [SELECT Id,AccountId,/*Account.Name,*/Email FROM Contact WHERE Email IN: regReqEmails AND AccountId IN: sysAccIdSet]){//ATHR Fix - TWC729-9556 - SJ
                        if(cons.Email != null){
                            returnSysAccMap.put(cons.Email, True);
                            //System.debug('ReturnSysAccMap-->'+returnSysAccMap);
                        }
                    }
                }
            }
            return returnSysAccMap;
        }
        public static List<PRM_AccountBenefitAssociation__c> getAccountBenefitAssociationData(List<Id> accIdList)
        {
            List<PRM_AccountBenefitAssociation__c> aba = [Select Id, Name,PRM_Partner_Benefit_Id__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Status_Nm__c,PRM_Account_Id__r.Name,PRM_Status_Reason_Txt__c From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accIdList];
            return aba;
        }

    /*   public static List<PRM_Profile_Questions__c> getProfileQuestion(){
            List<PRM_Profile_Questions__c>profQues = new List<PRM_Profile_Questions__c>([Select Id,PRM_Question_Cd__c,PRM_Question_Type_Nm__c from PRM_Profile_Questions__c]);
            return profQues;
        }
        
        public static List<PRM_Profile_Answer__c> getProfileAnswer(){
            List<PRM_Profile_Answer__c>profAns = new List<PRM_Profile_Answer__c>([Select Id,PRM_Answer_Cd__c,PRM_Answer_Display_Txt__c from PRM_Profile_Answer__c]);
            return profAns;
        }  */

        public static boolean acmActiveCheck(List<PRM_AccountChannelMembership__c> acmListToCheckIPA,PRM_Registration_Request__c regReqRecord)
        {
            Boolean isACMActive;
            for(PRM_AccountChannelMembership__c acm: acmListToCheckIPA){
                if(acm.PRM_Partner_Role__c == regReqRecord.PRM_Partner_Role__c && acm.PRM_Status_Nm__c == System.label.PRM_Status){
                    isACMActive = true;    
                }          
            }
            
            if(isACMActive != true){
                isACMActive = false;
            }  
            
            return isACMActive;
            
        }

        public static Boolean acrActiveCheck(List<PRM_Account_Contact_Relationship__c> acrList, PRM_Registration_Request__c regReqRecord)
        {
            List<PRM_Account_Contact_Relationship__c> acrActiveCheck= new List<PRM_Account_Contact_Relationship__c>();
        Boolean isACRActive;
            if(acrList != null){
                for(PRM_Account_Contact_Relationship__c acr : acrList){
                    if(acr.PRM_Partner_Role__c == regReqRecord.PRM_Partner_Role__c && acr.PRM_Status_Nm__c == System.label.PRM_ACR_Status && acr.PRM_InActive_Ind__c == false && acr.PRM_Relationship_Id__r.Name == System.Label.PRM_Primary_Contact){
                        isACRActive = true;                      
                        }
                    }
                
                }
                
                if(isACRActive != true){
                    isACRActive = false;
                } 
            
            return isACRActive; 
        }
        

        //This method is used to get ACM object List matching partner role and channel program from registration reuqest
        public static List<PRM_AccountChannelMembership__c> getACMList(List<PRM_AccountChannelMemberShip__c> acmList, PRM_Registration_Request__c regReqRecord){
            List<PRM_AccountChannelMemberShip__c> acmListToCheckIPA = new List<PRM_AccountChannelMembership__c>();
            if(acmList != null){           
                for(PRM_AccountChannelMembership__c acm: acmList){
                    if(acm.PRM_Channel_Program_Id__c == regReqRecord.PRM_Channel_Program__c && acm.PRM_Partner_Role__c == regReqRecord.PRM_Partner_Role__c){
                        acmListToCheckIPA.add(acm);    
                    }    
                }
            }
            
            return acmListToCheckIPA;
            
        }
        
        public static Boolean isAccountIPAForPartnerRole(Account acc, List<PRM_AccountChannelMembership__c> acmList, String partnerRole) {
            boolean isIPAAccount = false;
            /*if(IPARefresh){*/
                isIPAAccount = acc.Core_Intel_Partner_Alliance_PartnerGroup__c && (acc.Core_IPA_Partner_Role__c != null && String.isNotBlank(String.valueOf(acc.Core_IPA_Partner_Role__c)) &&  acc.Core_IPA_Partner_Role__c.split(';').contains(partnerRole)) && (acmList != null && acmList.size() >0 ); //ACM getting back to partner issue fix-- RRT
            /*}
            else{
            isIPAAccount = acc.Core_Intel_Partner_Alliance_PartnerGroup__c && (acc.Core_Account_Type__c != null && String.isNotBlank(String.valueOf(acc.Core_Account_Type__c)) &&  acc.Core_Account_Type__c.split(';').contains(partnerRole)) && (acmList != null && acmList.size() >0 );
            }*/ // IPA refresh - switch removal
            return isIPAAccount;
        }
        
        public static void createLogEntry(String logEntryMsgString, String origin, String project, String scope, String severity, String tags){
            if(logEntryMsgString!=''){// this block will create Log Entry records on the basis of length of logEntryMsg and Field limit.
                PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
                Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
                logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
                for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
                    Core_Log_Entry.logEntryWithDetails(origin, project, scope, severity,logEntryUtility.logEntryList[0] ,logEntryUtility.logEntryList[i] , '', '', tags);
                }//loop ends here..
            }
        }
        
        public static PRM_Tracker__c createTrackerInstance(String type, String milestone, Id recomendationId, Id locationId, String groupbyId, String mergeField1, String mergeField2, Boolean isComplete, String logEntries, String integrationLogs, Id outboundId){
            PRM_Tracker__c tracker = new PRM_Tracker__c();
            tracker.PRM_Type__c = type;
            tracker.PRM_Milestone__c = milestone;
            tracker.PRM_OPID_Recommendation__c = recomendationId != null ? recomendationId : null;
            tracker.PRM_Location_Account__c = locationId != null ? locationId : null;
            tracker.PRM_Groupby_Id__c = groupbyId;
            tracker.PRM_Merge_field_1__c = mergeField1;
            tracker.PRM_Merge_field_2__c = mergeField2;
            tracker.PRM_Completed__c = isComplete;
            tracker.PRM_Log_Entries__c = logEntries;
            tracker.PRM_Integration_Logs__c = integrationLogs;
            tracker.PRM_Integration_Outbound_Message__c = outboundId != null ? outboundId : null;
            return tracker;
        }
        
        public static PRM_Tracker__c createTrackerInstance(String type, String milestone, Id recomendationId, Id locationId, String opid, String groupbyId, String mergeField1, String mergeField2, Boolean isComplete, String logEntries, String integrationLogs){
            PRM_Tracker__c tracker = new PRM_Tracker__c();
            tracker.PRM_Type__c = type;
            tracker.PRM_Milestone__c = milestone;
            tracker.PRM_OPID_Recommendation__c = recomendationId != null ? recomendationId : null;
            tracker.PRM_Location_Account__c = locationId != null ? locationId : null;
            tracker.PRM_OPID__c = opid != null ? Id.valueOf(opid) : null;
            tracker.PRM_Groupby_Id__c = groupbyId;
            tracker.PRM_Merge_field_1__c = mergeField1;
            tracker.PRM_Merge_field_2__c = mergeField2;
            tracker.PRM_Completed__c = isComplete;
            tracker.PRM_Log_Entries__c = logEntries;
            tracker.PRM_Integration_Logs__c = integrationLogs;
            return tracker;
        }
        
        public static PRM_Tracker__c createTrackerInstance(String type, String milestone, Id recomendationId, Id locationId, String opid, String groupbyId, String mergeField1, String mergeField2, Boolean isComplete, String logEntries, String integrationLogs, String displayName){
            PRM_Tracker__c tracker = new PRM_Tracker__c();
            tracker.PRM_Type__c = type;
            tracker.PRM_Milestone__c = milestone;
            tracker.PRM_OPID_Recommendation__c = recomendationId != null ? recomendationId : null;
            tracker.PRM_Location_Account__c = locationId != null ? locationId : null;
            tracker.PRM_OPID__c = opid != null ? Id.valueOf(opid) : null;
            tracker.PRM_Groupby_Id__c = groupbyId;
            tracker.PRM_Merge_field_1__c = mergeField1;
            tracker.PRM_Merge_field_2__c = mergeField2;
            tracker.PRM_Completed__c = isComplete;
            tracker.PRM_Log_Entries__c = logEntries;
            tracker.PRM_Integration_Logs__c = integrationLogs;
            tracker.PRM_Milestone_Display_Name__c = displayName;
            return tracker;
        }
        
    public static PRM_Tracker__c createTrackerInstance(id trackerId,string type, String milestone, Id recomendationId, Id locationId, Boolean isComplete,Id inboundId, Boolean isUpsert){
            PRM_Tracker__c tracker = new PRM_Tracker__c();
            if(isUpsert){
                tracker.id = trackerId;
            }
            tracker.PRM_Type__c = type;
            tracker.PRM_Milestone__c = milestone;
            tracker.PRM_OPID_Recommendation__c = recomendationId != null ? recomendationId : null;
            tracker.PRM_Location_Account__c = locationId != null ? locationId : null;
            tracker.PRM_Completed__c = isComplete;
            tracker.One_Partner_Inbound_Message__c = inboundId != null ? inboundId : null;
            
            return tracker;
        }
        public static String fourLetterLangCode(contact cont){
            //for 4 letter language code
                String languageCodeISO4 = '';
                List<Core_IAM_Microservice_Language_Code__mdt> lstLanguageCodes = new List<Core_IAM_Microservice_Language_Code__mdt>([SELECT Id, DeveloperName, Label, B2C_Code__c, Core_ISO_3_Language_Code__c FROM Core_IAM_Microservice_Language_Code__mdt]);
                for(Core_IAM_Microservice_Language_Code__mdt langCode : lstLanguageCodes){
                    if(langCode.Core_ISO_3_Language_Code__c == cont.Core_Preferred_Language__c){
                    languageCodeISO4 = langCode.B2C_Code__c;
                    }
                }
                if(languageCodeISO4 == ''){
                    languageCodeISO4 = 'en-US';
                }
                return languageCodeISO4;
            }
                    //for 2 letter country code
            public static String getTwoLwtterCountryCode(String country){
            String ContactMailingCountryCodeISO2 = '';
            String AccountBillingCountryCodeISO2 = '';
            String CountryValue = '';
            List<Core_Country_Code_Mapping__c> lcs = Core_Country_Code_Mapping__c.getall().values();
            if(lcs != null && lcs.size() > 0) {
                    for(Core_Country_Code_Mapping__c cs : lcs) {
                        if(cs.ISO_Code__c == country) {
                            CountryValue = cs.Country_Code__c;                            
                        }                        
                    }
                }
                return CountryValue;
            } 

         //Chaithaly - method to return highest rank value    
        public static Integer getHighestTierRank() {
          Map<String,Integer> ProgramTierRankingMap = new Map<String,Integer>();
         String tierRanking = LabelConfiguration__mdt.getInstance('IPA2TierRanking').Value__c;
            for(String prgmrank : tierRanking.split(';'))
            {
                List<String> progTier = prgmrank.split(':');
                ProgramTierRankingMap.put(progTier[0],Integer.valueOf(progTier[1]));     
            }

        Integer highestRank = 0;
        for (Integer rank : ProgramTierRankingMap.values()) {
            if (rank > highestRank) {
                highestRank = rank;
            }
        }
        return highestRank;
    } 
        public static List<String> getApplicablePartnerRoleTier(String parterRole, String tier){  
         Map<Integer,String> rankTierMap = new Map<Integer,String>();
        Map<String,Integer> ProgramTierRankingMap = new Map<String,Integer>();
        String tierRanking = LabelConfiguration__mdt.getInstance('IPA2TierRanking').Value__c;
         for(String prgmrank : tierRanking.split(';')) {
                List<String> progTier = prgmrank.split(':');
                ProgramTierRankingMap.put(progTier[0],Integer.valueOf(progTier[1]));
                rankTierMap.put(Integer.valueOf(progTier[1]),progTier[0]);
           }
        integer currentrank = ProgramTierRankingMap.get(tier);
        integer highestRank = PRM_IPA_Utility.getHighestTierRank();//5
        List<String> applicablePartnerRoleTier = new List<String>();
        if(currentrank < highestrank){
        while( currentrank < highestrank)  {
                applicablePartnerRoleTier.add(parterRole+'-'+rankTierMap.get(currentrank));
                // currentrank = currentrank-1;
                if(currentrank == 4){
                break;
                }
            }
        }
       else if (currentrank == highestrank){
        applicablePartnerRoleTier.add(parterRole+'-'+rankTierMap.get(currentrank)); //fpga- prestige
         while(currentrank >= highestrank  ){
            highestrank = highestrank - 1;
            applicablePartnerRoleTier.add( parterRole+'-'+rankTierMap.get(highestrank));
            if(highestrank == 4){
            break;}
            }
           }
          return applicablePartnerRoleTier;
       }       
    }