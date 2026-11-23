/******************************************************************************************************************************************
Class Name:  Core_CIMIntegrationHandler
Version     : 1.0 
Created Date: 04 SEP 2020
Function    : Handler for CIM integration
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar             04/09/2020              Original Version
*****************************************************************************************************************************************/

public without sharing class Core_CIMIntegrationHandler{
    
    /*************************************************************************************************************
    * Method name  : xmlAttachNParse
    * Description  : On insert of a Core_CIM_Staging__c record, this method will create contentDocumentLink and parse the xml header and update
    *                the basic data like cim id, message id, message type in Core_CIM_Staging__c record, and atlast call future method.
    * Return Type  : VOID
    * Parameter    : Core_CIM_Staging__c record
    **************************************************************************************************************/
    public static void xmlAttachNParse(Core_CIM_Staging__c cimStageRec){
        if(cimStageRec.Core_Source_System__c == 'CIM' && cimStageRec.Core_Status__c == 'Pending' && cimStageRec.Core_ContentVersion_ID__c <> null && cimStageRec.Core_ContentVersion_ID__c <> ''){
            List<ContentVersion> contVersion = [select Id, contentDocumentId, versionData from ContentVersion where Id =: cimStageRec.Core_ContentVersion_ID__c];
            if(!contVersion.isEmpty()){
                //Attach the xml with IIM record
                ContentDocumentLink cdLink = new ContentDocumentLink();
                cdLink.ContentDocumentId = contVersion[0].contentDocumentId;
                cdLink.LinkedEntityId = cimStageRec.Id;
                cdLink.Visibility = 'AllUsers';
                cdLink.shareType = 'V';
                insert cdLink;
                
                Boolean isValidRecord = false;
                String errMsg = '';
                //Need a separate object reference of Core_CIM_Staging__c because trigger.new is read only on after insert or update
                Core_CIM_Staging__c finalCIMStage = new Core_CIM_Staging__c();
                finalCIMStage.Id = cimStageRec.Id;
                finalCIMStage.Core_Retry_Counter__c = null;
                Core_XMLParserHandler.finalWrapper finalWrap = new Core_XMLParserHandler.finalWrapper();
                //Fetch header data
                finalWrap = xmlParsing(contVersion[0], Core_ConstantUtility.HDR, finalWrap, finalCIMStage);
                if(finalWrap <> null){
                    //Fetch CIM error message metadata
                    List<Core_CIM_Error_Message__mdt> cimErrorList = [select Id, DeveloperName, Core_Error_Message__c from Core_CIM_Error_Message__mdt];
                    Map<String,String> cimErrorMap = new Map<String,String>();
                    for(Core_CIM_Error_Message__mdt cimErr : cimErrorList){
                        cimErrorMap.put(cimErr.DeveloperName, cimErr.Core_Error_Message__c);
                    }
                    //Fetch CIM id
                    String cimId = Core_XMLParserHandler.getCIM(contVersion[0]);
                    
                    if(finalWrap.headwr.MsgType <> null && finalWrap.headwr.EventType <> null && finalWrap.headwr.MsgId <> null && cimId <> null){
                        finalCIMStage.Core_CIM_Message_Type__c = finalWrap.headwr.MsgType;
                        finalCIMStage.Core_CIM_Event_Type__c = finalWrap.headwr.EventType;
                        finalCIMStage.Core_Message_ID__c = finalWrap.headwr.MsgId;
                        finalCIMStage.Core_CIM_ID__c = cimId;
                        
                        //SLSCLD tag check
                        if(!contVersion[0].versionData.toString().contains(Core_ConstantUtility.SLSCLD_TAG) && !contVersion[0].versionData.toString().contains(Core_ConstantUtility.ERPM_TAG) && !finalWrap.headwr.MsgType.equalsIgnoreCase('delete')){
                            isValidRecord = false;
                            errMsg = cimErrorMap.get('No_SLSCLD_ERPM_Source_Type_Found');
                            cimStageRecordUpdate(false, true, new List<Core_CIM_Staging__c>{finalCIMStage}, 'Invalid Source Record', errMsg);
                        }else{
                            Map<String,String> validCombinationMap = getValidCIMActionType();
                            String actCombination = finalWrap.headwr.MsgType.toLowerCase() + ';' + finalWrap.headwr.EventType.toLowerCase();
                            if(validCombinationMap.containskey(actCombination)){
                                isValidRecord = true;
                            }else{
                                isValidRecord = false;
                                errMsg = cimErrorMap.get('Wrong_Message_Type_or_Event_Type_Found');
                                cimStageRecordUpdate(false, true, new List<Core_CIM_Staging__c>{finalCIMStage}, 'Data Issue', errMsg);
                            }
                        }
                    }else{
                        isValidRecord = false;
                        if(finalWrap.headwr.MsgType == null){
                            errMsg = errMsg + cimErrorMap.get('No_Message_Type_Found') + ';';
                        }else{
                            finalCIMStage.Core_CIM_Message_Type__c = finalWrap.headwr.MsgType;
                        }
                        if(finalWrap.headwr.EventType == null){
                            errMsg = errMsg + cimErrorMap.get('No_Event_Type_Found') + ';';
                        }else{
                            finalCIMStage.Core_CIM_Event_Type__c = finalWrap.headwr.EventType;
                        }
                        if(finalWrap.headwr.MsgId == null){
                            errMsg = errMsg + cimErrorMap.get('No_Message_ID_Found') + ';';
                        }else{
                            finalCIMStage.Core_Message_ID__c = finalWrap.headwr.MsgId;
                        }
                        if(cimId == null){
                            errMsg = errMsg + cimErrorMap.get('No_CIM_ID_Found') + ';';
                        }else{
                            finalCIMStage.Core_CIM_ID__c = cimId;
                        }
                        errMsg = errMsg.substring(0, errMsg.length()-1);
                        cimStageRecordUpdate(false, true, new List<Core_CIM_Staging__c>{finalCIMStage}, 'Data Issue', errMsg);
                    }
                    
                    if(isValidRecord){
                        finalCIMStage.Core_Status__c = 'Processing';
                        try{
                            update finalCIMStage;
                        }catch(Exception e){
                            isValidRecord = false;
                        }
                    }
                    
                    if(isValidRecord){
                        //Execute business logic
                        try{
                            processBusinessLogic(finalCIMStage.Id);
                        }catch(Exception e){
                            cimStageRecordUpdate(false, false, new List<Core_CIM_Staging__c>{finalCIMStage}, 'System Exception', e.getMessage() + '\n' + e.getStackTraceString());
                        }
                    }
                }
            }
        }
    }
    
    public static Core_XMLParserHandler.finalWrapper xmlParsing(ContentVersion contVersion, String nodeName, Core_XMLParserHandler.finalWrapper finalWrap, Core_CIM_Staging__c cimStageRec){
        try{
            finalWrap = Core_XMLParserHandler.parseXMLnReturn(contVersion, nodeName, finalWrap);
            return finalWrap;
        }catch(Exception e){
            cimStageRecordUpdate(false, true, new List<Core_CIM_Staging__c>{cimStageRec}, 'XML Parsing Issue', e.getMessage() + '\n' + e.getStackTraceString());
            return null;
        }
    }
    
    /*************************************************************************************************************
    * Method name  : getValidCIMActionType
    * Description  : This method is used to fetch all the valid CIM action type along with the combination of message type and event type.
    * Return Type  : Map<String, String>
    * Parameter    : NA
    **************************************************************************************************************/
    public static Map<String, String> getValidCIMActionType(){
        Map<String, String> validComb = new Map<String, String>();
        List<Core_CIM_Integration_Type__mdt> cimTypeList = [select Core_Message_Type__c, Core_Event_Type__c, Core_Action_Type__c from Core_CIM_Integration_Type__mdt where Core_Is_Active__c =: true];
        if(!cimTypeList.isEmpty()){
            for(Core_CIM_Integration_Type__mdt cimType : cimTypeList){
                validComb.put(cimType.Core_Message_Type__c.trim().toLowerCase() + ';' + cimType.Core_Event_Type__c.trim().toLowerCase(), cimType.Core_Action_Type__c);
            }
        }
        return validComb;
    }
    
    /*************************************************************************************************************
    * Method name  : processBusinessLogic
    * Description  : This method is used to parse the Snapshot, SourceRecords and MergeBusinessOrganization of xml and process the business 
    *                logic in future context
    * Return Type  : VOID
    * Parameter    : Core_CIM_Staging__c record id
    **************************************************************************************************************/
    @future
    public static void processBusinessLogic(String cimStageRecId){
        //Fetch CIM error message metadata
        List<Core_CIM_Error_Message__mdt> cimErrorList = [select Id, DeveloperName, Core_Error_Message__c from Core_CIM_Error_Message__mdt];
        Map<String,String> cimErrorMap = new Map<String,String>();
        for(Core_CIM_Error_Message__mdt cimErr : cimErrorList){
            cimErrorMap.put(cimErr.DeveloperName, cimErr.Core_Error_Message__c);
        }
        //fetch Core_CIM_Staging__c record 
        Core_CIM_Staging__c cimStageRec = [select Id, Core_ContentVersion_ID__c, Core_CIM_ID__c, Core_Message_ID__c, Core_CIM_Message_Type__c, Core_CIM_Event_Type__c, Core_Is_Invalid_Record__c, Core_Retry_Counter__c, Core_Status__c, Core_Error_Description__c, Core_CIM_Processing_Time__c from Core_CIM_Staging__c where Id =: cimStageRecId];
        ContentVersion contVersion = getContentVersion(cimStageRec.Core_ContentVersion_ID__c);
        Core_XMLParserHandler.finalWrapper finalWrap = parseXML(contVersion, cimStageRec);
        
        Map<String,String> validCombinationMap = getValidCIMActionType();
        String actComb = cimStageRec.Core_CIM_Message_Type__c.toLowerCase() + ';' + cimStageRec.Core_CIM_Event_Type__c.toLowerCase();
        
        if(validCombinationMap.containskey(actComb) && finalWrap <> null){
            if(validCombinationMap.get(actComb).equalsIgnoreCase('merge')){
                AggregateResult cimStageRecCount = [select count(Id)recCount from Core_CIM_Staging__c where Core_CIM_ID__c =: cimStageRec.Core_CIM_ID__c AND Core_CIM_Message_Type__c =: Core_ConstantUtility.HDR_MSGTYPE_UPSERT AND Core_CIM_Event_Type__c =: Core_ConstantUtility.HDR_EVTTYPE_MERGE AND Core_Message_ID__c >: cimStageRec.Core_Message_ID__c AND Core_Status__c =: 'Successful'];
                if(cimStageRecCount.get('recCount') == 0){
                    //Parse MergeBusinessOrganization
                    finalWrap = xmlParsing(contVersion, Core_ConstantUtility.MERGEBO, finalWrap, cimStageRec);
                    if(finalWrap <> null){
                        commonLogicOfAccountUpdate(cimStageRec, finalWrap, validCombinationMap.get(actComb), cimErrorMap);
                    }
                }else{
                    cimStageRecordUpdate(false, true, new List<Core_CIM_Staging__c>{cimStageRec}, 'Old Message', cimErrorMap.get('Higher_message_already_processed'));
                }
            }
            
            if(validCombinationMap.get(actComb).equalsIgnoreCase('update')){
                List<Core_CIM_Staging__c> prevCIMRecords = [select Id, Core_CIM_ID__c, Core_Message_ID__c, Core_CIM_Event_Type__c, Core_ContentVersion_ID__c, 
                                                            Core_Retry_Counter__c, Core_Status__c, Core_Error_Description__c, Core_Is_Invalid_Record__c, 
                                                            Core_CIM_Processing_Time__c from Core_CIM_Staging__c where Core_Is_Invalid_Record__c = false AND 
                                                            Core_CIM_ID__c =: cimStageRec.Core_CIM_ID__c AND Core_CIM_Message_Type__c =: Core_ConstantUtility.HDR_MSGTYPE_UPSERT AND 
                                                            Core_CIM_Event_Type__c =: Core_ConstantUtility.HDR_EVTTYPE_CORE AND Core_Message_ID__c <: cimStageRec.Core_Message_ID__c AND 
                                                            Core_Status__c =: 'Failed' AND Core_Retry_Counter__c <: 3
                                                           ];
                for(Core_CIM_Staging__c cimStg : prevCIMRecords){
                    cimStg.Core_Retry_Counter__c = cimStg.Core_Retry_Counter__c - 1;
                }
                cimStageRecordUpdate(false, true, prevCIMRecords, 'Old Message', cimErrorMap.get('Higher_message_already_processed'));
                commonLogicOfAccountUpdate(cimStageRec, finalWrap, validCombinationMap.get(actComb), cimErrorMap);
            }
            
            if(validCombinationMap.get(actComb).equalsIgnoreCase('delete')){
                deleteAccounts(cimStageRec, finalWrap);
            }
        }
    }
    
    public static void deleteAccounts(Core_CIM_Staging__c cimStageRec, Core_XMLParserHandler.finalWrapper finalWrap){
        try{
            Set<String> srcRecIdSet = getAllSourceRecordIds(finalWrap);
            List<Account> accList = [select Id, Core_Account_Not_In_CIM__c, Core_CIM_ID__c from Account where Core_Account_Not_In_CIM__c =: false AND (Core_CIM_ID__c =: cimStageRec.Core_CIM_ID__c OR Id IN: srcRecIdSet)];
            for(Account acc : accList){
                acc.Core_CIM_ID__c = cimStageRec.Core_CIM_ID__c;
                acc.Core_Last_MsgId__c = cimStageRec.Core_Message_ID__c;
                acc.Core_Account_Not_In_CIM__c = true;
            }
            update accList;
            cimStageRecordUpdate(new List<Core_CIM_Staging__c>{cimStageRec});
        }catch(Exception e){
            cimStageRecordUpdate(false, false, new List<Core_CIM_Staging__c>{cimStageRec}, 'System Exception', e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    public static ContentVersion getContentVersion(String contVersionId){
        //Get ContentVersion record
        ContentVersion contVersion = [select Id, versionData from ContentVersion where Id =: contVersionId];
        return contVersion;
    }
    
    public static Core_XMLParserHandler.finalWrapper parseXML(ContentVersion contVersion, Core_CIM_Staging__c cimStageRec){
        Core_XMLParserHandler.finalWrapper finalWrap = new Core_XMLParserHandler.finalWrapper();
        //Parse Snapshot
        finalWrap = xmlParsing(contVersion, Core_ConstantUtility.SNP, finalWrap, cimStageRec);
        //Parse SourceRecords
        if(finalWrap <> null){
            finalWrap = xmlParsing(contVersion, Core_ConstantUtility.SRS, finalWrap, cimStageRec);
        }
        return finalWrap;
    }
    
    public static void commonLogicOfAccountUpdate(Core_CIM_Staging__c cimStageRec, Core_XMLParserHandler.finalWrapper finalWrap, String actionType, Map<String,String> cimErrorMap){
        try{
            Boolean isProcessed = false;
            //Get all SLSCLD records
            Set<String> srcRecIdSet = getAllSourceRecordIds(finalWrap);
            List<String> cimIdList = new List<String>();
            cimIdList.add(cimStageRec.Core_CIM_ID__c);
            String survivorId = null;
            //Store both survivor and non survivor id in cimIdList
            if(actionType.equalsIgnoreCase('merge') && finalWrap.mbWr <> null){
                if(finalWrap.mbWr.SurvivorBusinessOrganizationPartyId <> null && finalWrap.mbWr.SurvivorBusinessOrganizationPartyId <> '' && finalWrap.mbWr.SurvivorBusinessOrganizationPartyId <> cimStageRec.Core_CIM_ID__c){
                    survivorId = finalWrap.mbWr.SurvivorBusinessOrganizationPartyId;
                    cimIdList.add(survivorId);
                }
                if(finalWrap.mbWr.NonSurvivorBusinessOrganizationPartyId <> null && finalWrap.mbWr.NonSurvivorBusinessOrganizationPartyId <> ''){
                    cimIdList.add(finalWrap.mbWr.NonSurvivorBusinessOrganizationPartyId);
                }
            }
            
            Set<String> erpmSet = new Set<String>();
            String businessIds = '';
            for(Core_XMLParserHandler.SourceRecord srcRecord : finalWrap.sourceRecordWr.SourceRecord){
                if(srcRecord.SourceSystemCd <> null && srcRecord.SourceSystemCd.equalsIgnoreCase(Core_ConstantUtility.SR_ERPM) && srcRecord.dedup.EngagementDeduplicationGroupCd <> null && (srcRecord.dedup.EngagementDeduplicationGroupCd.equalsIgnoreCase(Core_ConstantUtility.SR_DEDUP_ITP) || srcRecord.dedup.EngagementDeduplicationGroupCd.equalsIgnoreCase(Core_ConstantUtility.SR_DEDUP_B2B))){
                    erpmSet.add(srcRecord.dedup.EngagementDeduplicationGroupCd.toLowerCase());
                    businessIds = businessIds + srcRecord.sbo.id + ',';
                }
            }
            if(businessIds <> ''){
                businessIds = businessIds.substring(0, businessIds.length()-1);
            }
            
            //Query on account to get all the valid record
            List<Account> accList = [select Id, Name, Core_CIM_ID__c, Core_Account_Legal_Name__c, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode, Core_Account_Country__c, Phone, Fax, Website, Core_Last_MsgId__c, Core_Military_Aerospace_and_Government__c, Core_Export_Compliance_Block__c, Core_Export_Compliance_Block_Reason__c, Core_Alternate_Language_Name__c, Core_Alt_Address_1__c, Core_Alt_Language_City__c, Core_Alt_Language_country__c, Core_Alt_Language_State_Province__c, Core_Alt_Language_Postal_Code__c from Account where Core_CIM_ID__c IN: cimIdList OR Id IN: srcRecIdSet];
            List<Account> finalAccountList = new List<Account>();
            if(!accList.isEmpty()){
                //Update accounts
                if(actionType.equalsIgnoreCase('update')){
                    for(Account acc : accList){
                        if(acc.Core_Last_MsgId__c == null || Integer.valueOf(cimStageRec.Core_Message_ID__c) > Integer.valueOf(acc.Core_Last_MsgId__c)){
                            finalAccountList.add(populateAccountDetails(cimStageRec.Core_Message_ID__c, cimStageRec.Core_CIM_ID__c, businessIds, finalWrap, acc));
                        }
                    }
                }
                
                //Merge accounts
                if(actionType.equalsIgnoreCase('merge') && finalWrap.mbWr <> null){
                    if(survivorId == null){
                        survivorId = cimStageRec.Core_CIM_ID__c;
                    }
                    for(Account acc : accList){
                        finalAccountList.add(populateAccountDetails(cimStageRec.Core_Message_ID__c, survivorId, businessIds, finalWrap, acc));
                    }
                }
                if(!finalAccountList.isEmpty()){
                    update finalAccountList;
                    isProcessed = true;
                }
            }
            
            if(isProcessed){
                //Update CIM Stage record as successful
                cimStageRecordUpdate(new List<Core_CIM_Staging__c>{cimStageRec});
                //If merge processed successfully then process highest update message in same transaction 
                if(cimStageRec.Core_CIM_Event_Type__c.equalsIgnoreCase(Core_ConstantUtility.HDR_EVTTYPE_MERGE)){
                    List<Core_CIM_Staging__c> prevCIMRecords = [select Id, Core_CIM_ID__c, Core_Message_ID__c, Core_CIM_Event_Type__c, Core_ContentVersion_ID__c, 
                                                                Core_Retry_Counter__c, Core_Status__c, Core_Error_Description__c, Core_Is_Invalid_Record__c, 
                                                                Core_CIM_Processing_Time__c from Core_CIM_Staging__c where Core_Is_Invalid_Record__c = false AND 
                                                                Core_CIM_ID__c =: cimStageRec.Core_CIM_ID__c AND Core_CIM_Message_Type__c =: Core_ConstantUtility.HDR_MSGTYPE_UPSERT AND 
                                                                Core_CIM_Event_Type__c =: Core_ConstantUtility.HDR_EVTTYPE_CORE AND 
                                                                Core_Message_ID__c >: cimStageRec.Core_Message_ID__c order by Core_Message_ID__c desc Limit 1
                                                               ];
                    if(!prevCIMRecords.isEmpty()){
                        ContentVersion contVersion = getContentVersion(prevCIMRecords[0].Core_ContentVersion_ID__c);
                        Core_XMLParserHandler.finalWrapper parseWrap = parseXML(contVersion, prevCIMRecords[0]);
                        if(parseWrap <> null){
                            commonLogicOfAccountUpdate(prevCIMRecords[0], parseWrap, 'update', cimErrorMap);
                        }
                    }
                }
            }else{
                Boolean isDuplicateMsg = false;
                Boolean isLowerMsg = false;
                String errDesc = '';
                for(Account acc : accList){
                    if(acc.Core_Last_MsgId__c <> null && Integer.valueOf(cimStageRec.Core_Message_ID__c) == Integer.valueOf(acc.Core_Last_MsgId__c)){
                        isDuplicateMsg = true;
                    }
                    if(acc.Core_Last_MsgId__c <> null && Integer.valueOf(cimStageRec.Core_Message_ID__c) < Integer.valueOf(acc.Core_Last_MsgId__c)){
                        isLowerMsg = true;
                    }
                }
                if(isDuplicateMsg && isLowerMsg){
                    cimStageRecordUpdate(false, true, new List<Core_CIM_Staging__c>{cimStageRec}, 'Old Message', cimErrorMap.get('Duplicate_or_a_higher_mesage_processed'));
                }else if(isDuplicateMsg){
                    cimStageRecordUpdate(false, true, new List<Core_CIM_Staging__c>{cimStageRec}, 'Data Issue', cimErrorMap.get('Duplicate_message'));
                }else if(isLowerMsg){
                    cimStageRecordUpdate(false, true, new List<Core_CIM_Staging__c>{cimStageRec}, 'Old Message', cimErrorMap.get('Higher_message_already_processed'));
                }
            }
            
            //If SLSCLD record not found but ERPM record found then insert account
            /*****************************ERPM record process starts*****************************/
            Map<String,Core_Trigger_Executions__c> triggerExecMap = Core_Trigger_Executions__c.getAll();
            Boolean erpmItp = false;
            Boolean erpmB2b = false;
            Boolean isAccountInsert = false;
            if(triggerExecMap.containskey('ERPM_DEDUPGPITP_Create') && triggerExecMap.get('ERPM_DEDUPGPITP_Create').Core_Active__c){
                erpmItp = true;
            }
            if(triggerExecMap.containskey('ERPM_DEDUPGPB2B_Create') && triggerExecMap.get('ERPM_DEDUPGPB2B_Create').Core_Active__c){
                erpmB2b = true;
            }
            system.debug('erpmItp '+erpmItp);
            system.debug('erpmB2b '+erpmB2b);
            //Check ERPM record, if available, insert new account
            if(accList.isEmpty() && !erpmSet.isEmpty() && actionType.equalsIgnoreCase('update') && (erpmItp || erpmB2b)){
                Account finalAcc = new Account();
                finalAcc.Name = '';
                finalAcc.Core_CIM_ID__c = null;
                finalAcc.Core_Export_Compliance_Block__c = false;
                if(erpmItp && erpmSet.contains(Core_ConstantUtility.SR_DEDUP_ITP.toLowerCase())){
                    finalAcc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
                    isAccountInsert = true;
                }
                if(erpmB2b && erpmSet.contains(Core_ConstantUtility.SR_DEDUP_B2B.toLowerCase())){
                    finalAcc.Core_ERPM_IsB2B__c = true;
                    isAccountInsert = true;
                }
                finalAcc = populateAccountDetails(cimStageRec.Core_Message_ID__c, cimStageRec.Core_CIM_ID__c, businessIds, finalWrap, finalAcc);
                if(isAccountInsert){
                    insert finalAcc;
                }
                isProcessed = true;
                cimStageRecordUpdate(new List<Core_CIM_Staging__c>{cimStageRec});
            }
            /*****************************ERPM record process ends*****************************/

            if(accList.isEmpty()){
                if(erpmSet.isEmpty()){
                    cimStageRecordUpdate(false, true, new List<Core_CIM_Staging__c>{cimStageRec}, 'Data Issue', cimErrorMap.get('No_Account'));
                }else{
                    if(cimStageRec.Core_Status__c.equalsIgnoreCase('Processing')){
                        cimStageRecordUpdate(false, true, new List<Core_CIM_Staging__c>{cimStageRec}, 'Data Issue', cimErrorMap.get('Account_Creation_Off'));
                    }
                }
            }
        }catch(Exception e){
            cimStageRecordUpdate(false, false, new List<Core_CIM_Staging__c>{cimStageRec}, 'System Exception', e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    public static Account populateAccountDetails(String msgId, String cimId, String businessIds, Core_XMLParserHandler.finalWrapper finalWrap, Account acc){       
        if(acc.Name == ''){
            acc.Name = finalWrap.snpWr.bonm.BusinessOrganizationNm;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            acc.OwnerId = System.Label.Core_UncoveredAccount_UserId;
        }
        
        if(acc.Core_CIM_ID__c <> null){
            acc.Core_CIM_ID_Old__c = acc.Core_CIM_ID__c;
        }
        acc.Core_CIM_ID__c = cimId;
        acc.Core_Last_MsgId__c = msgId;
        
        //Update business ids
        acc.Core_Business_ID__c = businessIds.replaceAll(',', ', ').length() < 255 ? businessIds.replaceAll(',', ', ') : businessIds.replaceAll(',', ', ').substring(0, 252) ;
        //acc.Core_Business_ID__c = businessIds.replaceAll(',', ', ');
        
        acc.Core_Account_Legal_Name__c = finalWrap.snpWr.bonm.BusinessOrganizationNm;
        
        //Primary address update
        acc.BillingStreet = finalWrap.snpWr.pa.PhysicalStreetAddressTxt;
        acc.BillingCity = finalWrap.snpWr.pa.CityNm;
        if(finalWrap.snpWr.pa.CountryCd <> null){
            acc.BillingCountryCode = finalWrap.snpWr.pa.CountryCd;
            acc.Core_Account_Country__c = finalWrap.snpWr.pa.CountryNm;
        }else{
            acc.BillingCountry = null;
            acc.Core_Account_Country__c = null;
        }
        
        if(finalWrap.snpWr.pa.CountrySubdivisionCd <> null){
            acc.BillingStateCode = finalWrap.snpWr.pa.CountrySubdivisionCd;
        }else{
            acc.BillingState = null;
        }
        
        if(finalWrap.snpWr.pa.PostalCd <> null){
            acc.BillingPostalCode = finalWrap.snpWr.pa.PostalCd;
        }else{
            acc.BillingPostalCode = null;
        }
        
        //String BVDID = getBVDId(finalWrap);
        acc.Core_BVD9_ID__c = getBVDId(finalWrap);
        
        //Alternate language and address update
        /*Core_XMLParserHandler.SourceRecord cimhubRecord = getCIMHUBLatinRecord(finalWrap);
        if(cimhubRecord <> null){
            acc.Core_Alternate_Language_Name__c = cimhubRecord.sbonm.BusinessOrganizationNm;            
            acc.Core_Alt_Address_1__c = cimhubRecord.pa.PhysicalStreetAddressTxt;
            acc.Core_Alt_Language_City__c = cimhubRecord.pa.CityNm;
            acc.Core_Alt_Language_country__c = cimhubRecord.pa.CountryNm;
            acc.Core_Alt_Language_State_Province__c = cimhubRecord.pa.CountrySubdivisionNm;
            acc.Core_Alt_Language_Postal_Code__c = cimhubRecord.pa.PostalCd;
        }*/
        
        //Electronic address update
        for(Core_XMLParserHandler.ElectronicAddress elecAddress : finalWrap.snpWr.eleAdd){
            if(elecAddress.ElectronicAddressTypeCd.equalsIgnoreCase(Core_ConstantUtility.SNP_ELEC_ADR_PHONE) && elecAddress.ElectronicAddressTxt <> null){
                acc.Phone = elecAddress.ElectronicAddressTxt;
            }else if(elecAddress.ElectronicAddressTypeCd.equalsIgnoreCase(Core_ConstantUtility.SNP_ELEC_ADR_FAX) && elecAddress.ElectronicAddressTxt <> null){
                acc.Fax = elecAddress.ElectronicAddressTxt;
            }else if(elecAddress.ElectronicAddressTypeCd.equalsIgnoreCase(Core_ConstantUtility.SNP_ELEC_ADR_URL) && elecAddress.ElectronicAddressTxt <> null){
                acc.Website = elecAddress.ElectronicAddressTxt;
            }
        }
        
        //GEC update
        Core_XMLParserHandler.BusinessOrganizationThirdPartyWatchList botpwl = new Core_XMLParserHandler.BusinessOrganizationThirdPartyWatchList();
        for(Core_XMLParserHandler.BusinessOrganizationThirdPartyWatchList botp : finalWrap.snpWr.botpwlList){
            if(botp.WatchListTypeCd.equalsIgnoreCase(Core_ConstantUtility.SNP_EC) || botp.WatchListTypeCd.equalsIgnoreCase(Core_ConstantUtility.SNP_ECB)){
                botpwl = botp;
                break;
            }
        }
        if(botpwl.WatchListTypeCd == null){
            if(acc.Core_Export_Compliance_Block__c){
                acc.Core_Export_Compliance_Block__c = false;
                acc.Core_Export_Compliance_Block_Reason__c = '';
            }
        }else{
            acc.Core_Export_Compliance_Block__c = true;
            acc.Core_Export_Compliance_Block_Reason__c = botpwl.WatchListTypeNm;
        }
        
        return acc;
    }
    
    public static Set<String> getAllSourceRecordIds(Core_XMLParserHandler.finalWrapper finalWrap){
        Set<String> recIdset = new Set<String>();
        //Get all the SLSCLD record id
        for(Core_XMLParserHandler.SourceRecord srcRecord : finalWrap.sourceRecordWr.SourceRecord){
            if(srcRecord.SourceSystemCd <> null && srcRecord.SourceSystemCd.equalsIgnoreCase(Core_ConstantUtility.SR_SLSCLD)){
                recIdset.add(srcRecord.sbo.id);
            }
        }
        return recIdset;
    }
        public static String getBVDId(Core_XMLParserHandler.finalWrapper finalWrap){
        String BVDID = '';
        for(Core_XMLParserHandler.SourceRecord srcRecord : finalWrap.sourceRecordWr.SourceRecord){
            if(srcRecord.SourceSystemCd <> null && srcRecord.SourceSystemCd.equalsIgnoreCase(Core_ConstantUtility.SR_BVD)){
                BVDID =((srcRecord.sbo.id != Null && String.isNotBlank(srcRecord.sbo.id)) ? srcRecord.sbo.id : '');
            }
        }
        return BVDID ;
    }

    
    /*public static Core_XMLParserHandler.SourceRecord getCIMHUBLatinRecord(Core_XMLParserHandler.finalWrapper finalWrap){
        Core_XMLParserHandler.SourceRecord srRecord = null;
        //Get all type of SourceRecord
        List<Core_XMLParserHandler.SourceRecord> srcRecordList = finalWrap.sourceRecordWr.SourceRecord;
        //Get the CIMHUB record
        for(Core_XMLParserHandler.SourceRecord srcRecord : srcRecordList){
            if(srcRecord.SourceSystemCd <> null && srcRecord.SourceSystemCd.equalsIgnoreCase(Core_ConstantUtility.SR_CIMHUB)){
                srRecord = srcRecord;
                break;
            }
        }
        return srRecord;
    }*/
    
    public static void cimStageRecordUpdate(List<Core_CIM_Staging__c> cimStageRecList){
        cimStageRecordUpdate(true, false, cimStageRecList, '', '');
    }
    
    public static void cimStageRecordUpdate(Boolean isProcessed, Boolean isInvalidRec, List<Core_CIM_Staging__c> cimStageRecList, String failureReason, String errDescription){
        try{
            for(Core_CIM_Staging__c cimStageRec : cimStageRecList){
                if(cimStageRec.Core_Retry_Counter__c == null){
                    cimStageRec.Core_Retry_Counter__c = 1;
                }else{
                    cimStageRec.Core_Retry_Counter__c = cimStageRec.Core_Retry_Counter__c + 1;
                }
                cimStageRec.Core_Is_Invalid_Record__c = isInvalidRec;
                if(isProcessed){
                    cimStageRec.Core_Status__c = 'Successful';
                }else{
                    cimStageRec.Core_Status__c = 'Failed';
                    if(failureReason <> null){
                        cimStageRec.Core_Failure_Reason__c = failureReason;
                    }
                    cimStageRec.Core_Error_Description__c = errDescription;
                    cimStageRec.Core_CIM_Processing_Time__c = Datetime.now().addMinutes(-30);
                }
            }
            update cimStageRecList;
        }catch(Exception e){
            List<Core_Exceptions__c> excepList = new List<Core_Exceptions__c>();
            for(Core_CIM_Staging__c cimStage : cimStageRecList){
                Core_Exceptions__c excep = new Core_Exceptions__c();
                excep.Core_Class_Name__c ='Core_CIMIntegrationHandler';
                excep.Core_Method_Name__c ='cimStageRecordUpdate';
                excep.Core_Record_Id__c = cimStage.Id;
                excep.Core_Exception__c = e.getStackTraceString();
                excep.Core_IPS_Object_Name__c = 'Core_CIM_Staging__c';
                excepList.add(excep);
            }
            insert excepList;
        }
    }
    
    /*************
    * Method name  : retryCIMProcess
    * Description  : This method call the future method and runs the same bussiness logic.
    * Return Type  : VOID
    * Parameter    : List<String> recordId
    *************/
    
    @InvocableMethod
    public static void retryCIMProcess(List<String> recordId) {
        for(String rId : recordId){
        processBusinessLogic(rId);
        }
    }
    
    
}