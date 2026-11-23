public with sharing class Core_MDF_BatchClaimHelper {
    
    public static List<Core_MDF_BulkClaimTemplateParticulars__mdt> metadataRecordList;
    public static Core_MDF_Claim_Batch__c batch;
    public static List<Core_MDF_Claim_Batch_Stage__c> stageClaimRecs;
    public static Map<String,PartnerFundRequest> activityNumberToPfrMap;
    
    /************************************************************************************************************ 
Method Name:         preventDeleteWhenClaimInSuccessStatus
Description:         Method to Prevent Delete on the Claim Batch Stage Records if the Claim status is not equal to 'Failed'
@Added By:           Intel      - Areefa - 28-03-2019
Modified By:         Date:      - Changes: 
*************************************************************************************************************/ 
    public static void preventDeleteWhenClaimInSuccessStatus(List<Core_MDF_Claim_Batch_Stage__c> oldClaimStageList) {
        for(Core_MDF_Claim_Batch_Stage__c claimBatchRec: oldClaimStageList){
            if(claimBatchRec.Core_MDF_Processing_Status_Nm__c <> System.Label.Core_MDF_Claim_Batch_Failed) 
            {
                claimBatchRec.addError(system.Label.Core_MDF_Claim_Cannot_BeDeleted);
            } 
        }
    }
    
    
    
    /************************************************************************************************************ 
Method Name:        getListofClaims
@return  :          List<PartnerFundClaim>
@parameters:        List<Core_MDF_Claim_Batch_Stage__c> List of stage claims
Description:        This method will return the list of claims to be created                      
Added By:           Intel  - Areefa - 29/03/2019
Modified By:        Date:       Changes: 
Accenture - JV      4/7/2019    Dynamically Mapping the Stage and Claim Records based on Cutom Metadata
*************************************************************************************************************/
    public static List<PartnerFundClaim> mapStageRecordsToClaim(List<Core_MDF_Claim_Batch_Stage__c> stageClaimRecs){
        batch = [SELECT Id,Name,Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c FROM Core_MDF_Claim_Batch__c WHERE Id = :stageClaimRecs[0].Core_MDF_Batch_ID__c LIMIT 1];
        metadataRecordList = [SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                              Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c
                              FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                              WHERE Core_MDF_Channel_program__c = :batch.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c
                              AND Core_MDF_Upload_Record_Type__c =: Label.Core_MDF_PFCText];
        List<PartnerFundClaim>  claimRecords = new List<PartnerFundClaim>();
        
        if(stageClaimRecs != NULL && stageClaimRecs.size() > 0)
        {
            for(Core_MDF_Claim_Batch_Stage__c stageClaim: stageClaimRecs)
            {   
                if(stageClaim.Core_MDF_Processing_Status_Nm__c != Label.Core_MDF_Claim_Batch_Failed)
                {
                    PartnerFundClaim pfc = new PartnerFundClaim();
                    List<String> stageFieldsNotToBeMappedWithClaim = Label.Core_MDF_StageFieldsNotToBeMapped.split(',');
                    for(Core_MDF_BulkClaimTemplateParticulars__mdt metadataRecord : metadataRecordList)
                    {
                        if(!stageFieldsNotToBeMappedWithClaim.contains(metadataRecord.Core_MDF_Stage_Field_API_Name__c)){
                            pfc.put(metadataRecord.Core_MDF_Target_Field_API_Name__c,stageClaim.get(metadataRecord.Core_MDF_Stage_Field_API_Name__c));
                        }
                    }
                    pfc.RequestId = stageClaim.Core_MDF_Request_Id__c;
                    pfc.Core_MDF_Bank__c =  stageClaim.Core_MDF_Bank_Id__c;
                    pfc.Core_MDF_Claim_Batch_Stage__c = stageClaim.Id;
                    pfc.Core_MDF_Batch_Nbr__c = batch.Name;
                    pfc.Core_MDF_Country_Location_nm__c =activityNumberToPfrMap.get(stageClaim.Core_MDF_Activity_Nbr__c).Core_MDF_Country_nm__c;
                    claimRecords.add(pfc);
                }
            }       
        }
        return claimRecords;        
    }
    
    /************************************************************************************************************ 
Method Name:        isClaimStageRecordEdited
@return  :          Boolean
@parameters:        newClaimStageRecord,oldClaimStageMap,lstBulkUploadMappings
Description:        To check whether the incoming claimstage record is edited or not
Added By:           Accenture  - JV - 07/04/2019
Modified By:        Date:       Changes: 
*************************************************************************************************************/
    public static Boolean isClaimStageRecordEdited(Core_MDF_Claim_Batch_Stage__c newClaimStageRecord, Map<Id,Core_MDF_Claim_Batch_Stage__c> oldClaimStageMap,List<Core_MDF_BulkClaimTemplateParticulars__mdt> lstBulkUploadMappings)
    {
        Boolean isEdited = FALSE;
        for(Core_MDF_BulkClaimTemplateParticulars__mdt mdtRecord : lstBulkUploadMappings){
            if(mdtRecord.Core_MDF_Stage_Required_Ind__c == TRUE && oldClaimStageMap!=null && oldClaimStageMap.get(newClaimStageRecord.Id)!=null
               && (newClaimStageRecord.get(mdtRecord.Core_MDF_Stage_Field_API_Name__c) != (oldClaimStageMap.get(newClaimStageRecord.Id).get(mdtRecord.Core_MDF_Stage_Field_API_Name__c)))
              ){
                  isEdited = TRUE;
                  break;
              }
        }
        // check if "Create Duplicate" check box was set by the User or not:
        if(newClaimStageRecord.Core_MDF_Create_Duplicate_ind__c == TRUE && oldClaimStageMap.get(newClaimStageRecord.Id).Core_MDF_Create_Duplicate_ind__c == FALSE){
            isEdited = TRUE;
        }
        if(isEdited){
            return TRUE;
        }else{return FALSE;}
    }
    
    /************************************************************************************************************ 
Method Name:        insertClaimsAndUpdateClaimStageRecords
@return  :          Boolean
@parameters:        Claims List to be inserted
Description:        This method is used to Insert the Claims And Updated the Corresponding claim stage records with the proper status
Added By:           Accenture  - JV - 07/04/2019
Modified By:        Date:       Changes: 
*************************************************************************************************************/
    public static void insertClaimsAndUpdateClaimStageRecords(List<PartnerFundClaim> claims)
    {
        Set<Id> succesRecordIdSet = new Set<Id>();
        //List<Database.SaveResult> result = new List<Database.SaveResult>();
        List<PartnerFundClaim> claimToBeInserted = new List<PartnerFundClaim>();
        for(PartnerFundClaim pfc : claims){
            if(pfc.Id == null){
                claimToBeInserted.add(pfc);
            }
        }
        Database.SaveResult[] result = Database.insert(claimToBeInserted, false);
        List<Core_MDF_Claim_Batch_Stage__c> successfulStageRecords = new List<Core_MDF_Claim_Batch_Stage__c>();
        List<Core_MDF_Claim_Batch_Stage__c> failedStageRecords = new List<Core_MDF_Claim_Batch_Stage__c>();
        for (Database.SaveResult sr : result) {
            if (sr.isSuccess()) {
                succesRecordIdSet.add(sr.getId());
            }
        }
        Map<Id,PartnerFundClaim> successClaimMap = new Map<Id,PartnerFundClaim>([Select Id,Core_MDF_Claim_Batch_Stage__c, Core_MDF_Claim_Ref_Number__c
                                                                                 FROM PartnerFundClaim where ID IN :succesRecordIdSet]);
        
        Map<PartnerFundClaim,Id> claimToClaimStageIdMap = new Map<PartnerFundClaim,Id>();
        Map<PartnerFundClaim,Id> successClaimToClaimStageIdMap = new Map<PartnerFundClaim,Id>();
        for(PartnerFundClaim claim : successClaimMap.values())
        {
            successClaimToClaimStageIdMap.put(claim,claim.Core_MDF_Claim_Batch_Stage__c);
        }
        for(PartnerFundClaim claim : claims)
        {
            claimToClaimStageIdMap.put(claim,claim.Core_MDF_Claim_Batch_Stage__c);
        }
        for(Integer i=0;i<result.size();i++){
            if (result[i].isSuccess()){
                ID stageid = successClaimToClaimStageIdMap.get(successClaimMap.get(result[i].getId()));//success record from the list
                Core_MDF_Claim_Batch_Stage__c stageRecord = new Core_MDF_Claim_Batch_Stage__c();
                stageRecord.ID = stageid;
                stageRecord.Core_MDF_Claim_Reference_Nbr__c = successClaimMap.get(result[i].getId()).Core_MDF_Claim_Ref_Number__c;
                successfulStageRecords.add(stageRecord);        
            }
            else {
                // DML operation failed
                Database.Error errorMsg = result[i].getErrors()[0];
                ID stageid = claimToClaimStageIdMap.get(claims.get(i));//failed record from the list
                Core_MDF_Claim_Batch_Stage__c stageRecord = new Core_MDF_Claim_Batch_Stage__c();
                stageRecord.ID = stageid;
                stageRecord.Core_MDF_Message_txt__c = stageRecord.Core_MDF_Message_txt__c == NUll ? errorMsg.getMessage() : stageRecord.Core_MDF_Message_txt__c + errorMsg.getMessage();
                stageRecord.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                failedStageRecords.add(stageRecord);
            } 
        }
        List<Core_MDF_Claim_Batch_Stage__c> stageRecordsToUpdate = new List<Core_MDF_Claim_Batch_Stage__c>();
        stageRecordsToUpdate.addAll(successfulStageRecords);
        stageRecordsToUpdate.addAll(failedStageRecords);
        Database.update(stageRecordsToUpdate);
    }
    
    /************************************************************************************************************ 
Method Name:        checkAccessiblityForUpdate
@return  :          void
@parameters:        List<Core_MDF_Claim_Batch_Stage__c> List of stage claims and its map
Description:        This method will check if user has access to given activities and banks when updating a stage record                      
Added By:           Accenture  - JV - 07/04/2019
Modified By:        Date:        Changes: 
Accenture - JV     07/04/2019    To check if user has access to given activities and banks when updating a stage record
*************************************************************************************************************/
    public static void checkAccessiblityForUpdate(List<Core_MDF_Claim_Batch_Stage__c> claimStageListToBeProcessed,Map<Id,Core_MDF_Claim_Batch_Stage__c> newclaimStageMap)
    {
        Set<String> activityNumbers = new Set<String>();
        Set<String> bankNumbers = new Set<String>();
        Map<String,Id> validBankNumbers = new Map<String,Id>();
        Set<Id> accounts = new Set<Id>();
        Map<String,List<String>> bankAccountMap = new Map<String,List<String>>();
        List<Core_MDF_Account_Bank_Mapping__c> accountBankMapping = new List<Core_MDF_Account_Bank_Mapping__c>();
        Set<String> bankStatusSet = createBankStatusSet();
        Set<Id> channelPartnerIdSet = new Set<Id>();
        activityNumberToPfrMap= new Map<String,PartnerFundRequest>();
        
        
        if(claimStageListToBeProcessed != NULL && claimStageListToBeProcessed.size() > 0)
        {
            //To get a mapping of the Channel Program in the Bank Object
            Id batch = claimStageListToBeProcessed[0].Core_MDF_Batch_ID__c;
            Core_MDF_Claim_Batch__c programAccRec = [Select Id, Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Account__c
                                                     From Core_MDF_Claim_Batch__c 
                                                     where Id = :batch LIMIT 1];
            //To store the channel program and ultimate account of the user
            String program = programAccRec.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c; 
            Id ultimateAccountId = programAccRec.Core_MDF_Account__c;
            
            Core_MDF_ChannelProgram__mdt bankProgram = [SELECT Core_MDF_Bank_Program_Value__c 
                                                        FROM Core_MDF_ChannelProgram__mdt
                                                        WHERE Core_MDF_Technical_Program_Name__c = :program LIMIT 1];
            
            //To have a set of the activities and bank input by user 
            for(Core_MDF_Claim_Batch_Stage__c claim : claimStageListToBeProcessed)
            {
                activityNumbers.add(claim.Core_MDF_Activity_Nbr__c);
                bankNumbers.add(claim.Core_MDF_Bank_Nbr__c);
            }
            
            //To retrieve all the activities that are valid and match the ones input by user
            List<PartnerFundRequest> userActivities = [SELECT Id, ChannelPartnerId, Core_MDF_Activity_Number__c, Core_MDF_Country_nm__c 
                                                       FROM PartnerFundRequest
                                                       WHERE Core_MDF_Activity_Number__c IN :activityNumbers
                                                       AND ChannelPartner.Core_MDF_Active_Ind__c = true
                                                       AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c = :ultimateAccountId
                                                       AND Core_MDF_Fund_Request_Status__c IN :Label.Core_MDF_PFR_Status_CreateClaim.split(';')
                                                       AND ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =:program];
            
            //To store all the accounts belonging to the given activities
            /*if(userActivities.size() > 0 || userActivities != null)*/
            if( userActivities != null && userActivities.size() > 0 )
            {  
                for(PartnerFundRequest activity : userActivities)
                {
                    activityNumberToPfrMap.put(activity.Core_MDF_Activity_Number__c,activity);
                    channelPartnerIdSet.add(activity.ChannelPartnerId);
                    
                }
            }
            
            //To retrieve all the banks that are valid and match the ones input by user and belong to the same account as the activities
            if(activityNumberToPfrMap.size() > 0)
            {
                
                accountBankMapping = [SELECT Id, Core_MDF_Account__c, Core_MDF_Bank__c, Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_Program__c, Core_MDF_AccountIdBankIdMapping__c 
                                      FROM Core_MDF_Account_Bank_Mapping__c
                                      WHERE Core_MDF_Account__c IN :channelPartnerIdSet
                                      AND Core_MDF_Bank__r.Core_MDF_Program__c includes (:bankProgram.Core_MDF_Bank_Program_Value__c)
                                      AND Core_MDF_Bank__r.Core_MDF_Supplier_Number__c IN :bankNumbers
                                      AND Core_MDF_Bank__r.Core_MDF_Bank_Status__c IN: bankStatusSet
                                      AND Core_MDF_Account__r.Core_MDF_Active_Ind__c  = true
                                      AND Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c = :ultimateAccountId
                                      AND Core_MDF_Active_ind__c=TRUE
                                     ];
                /*if(accountBankMapping.size() > 0 || accountBankMapping != null)*/
                if(accountBankMapping != null && accountBankMapping.size() > 0)
                {                
                    for(Core_MDF_Account_Bank_Mapping__c abm : accountBankMapping)
                    {
                       if(bankAccountMap.containsKey(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c)){
                            bankAccountMap.get(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c).add(abm.Core_MDF_Account__c);
                        }
                        else{
                            bankAccountMap.put(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, new List<String>{abm.Core_MDF_Account__c});
                        }
                        validBankNumbers.put(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, abm.Core_MDF_Bank__c);
                    }
                    
                }
            }

            //To populate approiate error messages in case of any errors or assign RequestId, Bank and Processing status
            for(Core_MDF_Claim_Batch_Stage__c claimStageRec : claimStageListToBeProcessed)
            {
                //To check if activity Contains No Countries
                if(activityNumberToPfrMap.keySet().contains(claimStageRec.Core_MDF_Activity_Nbr__c)
                   && (activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c==null){
                       claimStageRec.Core_MDF_Message_txt__c = claimStageRec.Core_MDF_Message_txt__c == Null ? Label.Core_MDF_No_Countries_Error :claimStageRec.Core_MDF_Message_txt__c + '\n' + Label.Core_MDF_No_Countries_Error;
                       claimStageRec.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;   
                }
                //To check if activity Contains Multiple Countries
                else if(activityNumberToPfrMap.keySet().contains(claimStageRec.Core_MDF_Activity_Nbr__c)
                   && (activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c!=null
                   && ((activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c).contains(';')){
                    claimStageRec.Core_MDF_Message_txt__c = claimStageRec.Core_MDF_Message_txt__c == Null ? Label.Core_MDF_Multiple_Countries_Error :claimStageRec.Core_MDF_Message_txt__c + '\n' + Label.Core_MDF_Multiple_Countries_Error;
                    claimStageRec.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                }
                //To check if its a valid activity
                else if(!activityNumberToPfrMap.keySet().contains(claimStageRec.Core_MDF_Activity_Nbr__c))
                {
                    newclaimStageMap.get(claimStageRec.Id).Core_MDF_Message_txt__c = claimStageRec.Core_MDF_Message_txt__c == Null ? Label.Core_MDF_Claim_Stage_Activity_Error :claimStageRec.Core_MDF_Message_txt__c + '\n' + Label.Core_MDF_Claim_Stage_Activity_Error;
                    newclaimStageMap.get(claimStageRec.Id).Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                }
                //To check if its a valid bank
                else if(!validBankNumbers.keySet().contains(claimStageRec.Core_MDF_Bank_Nbr__c))
                {
                    newclaimStageMap.get(claimStageRec.Id).Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                    newclaimStageMap.get(claimStageRec.Id).Core_MDF_Message_txt__c = claimStageRec.Core_MDF_Message_txt__c + '\n' + Label.Core_MDF_Claim_Stage_Bank_Error;
                }
                //To check if the given bank belongs to the account on the given activity
                else if(!(bankAccountMap.get(claimStageRec.Core_MDF_Bank_Nbr__c).contains((activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).ChannelPartnerId)))
                {
                    newclaimStageMap.get(claimStageRec.Id).Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                    newclaimStageMap.get(claimStageRec.Id).Core_MDF_Message_txt__c = claimStageRec.Core_MDF_Message_txt__c + '\n' + Label.Core_MDF_Bulk_Claim_Account_Bank_Error;
                }
                else
                {
                    newclaimStageMap.get(claimStageRec.Id).Core_MDF_Request_Id__c = (activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Id;
                    newclaimStageMap.get(claimStageRec.Id).Core_MDF_Bank_Id__c = validBankNumbers.get(claimStageRec.Core_MDF_Bank_Nbr__c);
                    newclaimStageMap.get(claimStageRec.Id).Core_MDF_Message_txt__c = '';
                    newclaimStageMap.get(claimStageRec.Id).Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Successful;
                }
                
            }
            
        }
        
        
    }
    
    
    /************************************************************************************************************ 
Method Name:        checkAccessiblityForInsert
@return  :          void
@parameters:        List<Core_MDF_Claim_Batch_Stage__c> List of stage claims and its map
Description:        This method will check if user has access to given activities and banks when uploading bulk claims for insert                      
Added By:           Intel  - Sarah Manuel - 07/04/2019
Modified By:        Date:       Changes: 
Intel - SM          07/04/2019    To check if user has access to given activities and banks when uploading bulk claims for insert
*************************************************************************************************************/    
    public static void checkAccessiblityForInsert(List<Core_MDF_Claim_Batch_Stage__c> claimStageList)
    {
        Set<String> activityNumbers = new Set<String>(); 
        Set<String> bankNumbers = new Set<String>();
        Map<String,Id> validBankNumbers = new Map<String,Id>();
        Set<Id> accounts = new Set<Id>();
        Map<String,List<String>> bankAccountMap = new Map<String,List<String>>();
        List<Core_MDF_Account_Bank_Mapping__c> accountBankMapping = new List<Core_MDF_Account_Bank_Mapping__c>();
        Set<String> bankStatusSet = createBankStatusSet();
        Set<Id> channelPartnerIdSet = new Set<Id>();
        activityNumberToPfrMap = new Map<String,PartnerFundRequest>();
           
            if(claimStageList != NULL && claimStageList.size() > 0)
        {
            Id batch = claimStageList[0].Core_MDF_Batch_ID__c; 
            //To get the banks program name
            Core_MDF_Claim_Batch__c programAccRec = [Select Id, Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Account__c
                                                     From Core_MDF_Claim_Batch__c 
                                                     where Id = :batch LIMIT 1];
            
            
            //To store the channel program and ultimate account of the user
            String program = programAccRec.Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c;

            
            Id ultimateAccountId = programAccRec.Core_MDF_Account__c;

            
            Core_MDF_ChannelProgram__mdt bankProgram = [SELECT Core_MDF_Bank_Program_Value__c 
                                                        FROM Core_MDF_ChannelProgram__mdt
                                                        WHERE Core_MDF_Technical_Program_Name__c = :program LIMIT 1];

            
            //To have a set of the activities and bank input by user 
            for(Core_MDF_Claim_Batch_Stage__c claim : claimStageList)
            {
                activityNumbers.add(claim.Core_MDF_Activity_Nbr__c);
                bankNumbers.add(claim.Core_MDF_Bank_Nbr__c);
            }
            
            //To get the Activities accessible to the user based on the input activity numbers
            List<PartnerFundRequest> userActivities = [SELECT Id, ChannelPartnerId, Core_MDF_Activity_Number__c,Core_MDF_Country_nm__c 
                                                       FROM PartnerFundRequest
                                                       WHERE Core_MDF_Activity_Number__c IN :activityNumbers
                                                       AND ChannelPartner.Core_MDF_Active_Ind__c  = true
                                                       AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c = :ultimateAccountId
                                                       AND Core_MDF_Fund_Request_Status__c IN :Label.Core_MDF_PFR_Status_CreateClaim.split(';')
                                                       AND ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =:program];
            System.debug('userActivities are:::'+userActivities);
            //To store all the accounts belonging to the given activities
            //if(userActivities.size() > 0 || userActivities != null)
            if(userActivities != null && userActivities.size() > 0 )            
            {
                for(PartnerFundRequest activity : userActivities)
                {
                    activityNumberToPfrMap.put(activity.Core_MDF_Activity_Number__c,activity);
                    channelPartnerIdSet.add(activity.ChannelPartnerId);
                    
                }
            }
            //To retrieve all the banks that are valid and match the ones input by user and belong to the same account as the activities
            if(activityNumberToPfrMap.size() > 0)
            {   
                System.debug('activityNumberToPfrMap is:::'+activityNumberToPfrMap);
                System.debug('channelPartnerIdSet is:::'+channelPartnerIdSet);
                accountBankMapping = [SELECT Id, Core_MDF_Account__c, Core_MDF_Bank__c, Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_Program__c, Core_MDF_AccountIdBankIdMapping__c 
                                      FROM Core_MDF_Account_Bank_Mapping__c
                                      WHERE Core_MDF_Account__c IN : channelPartnerIdSet
                                      AND Core_MDF_Bank__r.Core_MDF_Program__c includes (:bankProgram.Core_MDF_Bank_Program_Value__c)
                                      AND Core_MDF_Bank__r.Core_MDF_Supplier_Number__c IN :bankNumbers
                                      AND Core_MDF_Bank__r.Core_MDF_Bank_Status__c IN: bankStatusSet
                                      AND Core_MDF_Account__r.Core_MDF_Active_Ind__c = true
                                      AND Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c = :ultimateAccountId
                                      AND Core_MDF_Active_ind__c=TRUE
                                     ];
                if(accountBankMapping != null && accountBankMapping.size() > 0)
                {
                    System.debug('accountBankMappings are:::'+accountBankMapping);
                    for(Core_MDF_Account_Bank_Mapping__c abm : accountBankMapping)
                    {
                        if(bankAccountMap.containsKey(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c)){
                            bankAccountMap.get(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c).add(abm.Core_MDF_Account__c);
                        }
                        else{
                            bankAccountMap.put(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, new List<String>{abm.Core_MDF_Account__c});
                        }
                        validBankNumbers.put(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, abm.Core_MDF_Bank__c);
                    }
                }
                
            }
            
            System.debug('bankAccountMap:::'+bankAccountMap);
            System.debug('validBankNumbers:::'+validBankNumbers);
            for(Core_MDF_Claim_Batch_Stage__c claimStageRec : claimStageList)
            {
                //To check if activity Contains No Countries
                if(activityNumberToPfrMap.keySet().contains(claimStageRec.Core_MDF_Activity_Nbr__c)
                   && (activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c==null){
                       claimStageRec.Core_MDF_Message_txt__c = claimStageRec.Core_MDF_Message_txt__c == Null ? Label.Core_MDF_No_Countries_Error :claimStageRec.Core_MDF_Message_txt__c + '\n' + Label.Core_MDF_No_Countries_Error;
                       claimStageRec.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;   
                }
                //To check if activity Contains Multiple Countries
                else if(activityNumberToPfrMap.keySet().contains(claimStageRec.Core_MDF_Activity_Nbr__c)
                   && (activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c!=null
                   && ((activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Core_MDF_Country_nm__c).contains(';')){
                    claimStageRec.Core_MDF_Message_txt__c = claimStageRec.Core_MDF_Message_txt__c == Null ? Label.Core_MDF_Multiple_Countries_Error :claimStageRec.Core_MDF_Message_txt__c + '\n' + Label.Core_MDF_Multiple_Countries_Error;
                    claimStageRec.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                }
                //To check if its a valid activity
                else if(!activityNumberToPfrMap.keySet().contains(claimStageRec.Core_MDF_Activity_Nbr__c) )
                {
                    claimStageRec.Core_MDF_Message_txt__c = claimStageRec.Core_MDF_Message_txt__c == Null ? Label.Core_MDF_Claim_Stage_Activity_Error :claimStageRec.Core_MDF_Message_txt__c + '\n' + Label.Core_MDF_Claim_Stage_Activity_Error;
                    claimStageRec.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                }
                //To check if its a valid bank
                else if(!validBankNumbers.keySet().contains(claimStageRec.Core_MDF_Bank_Nbr__c))
                {
                    claimStageRec.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                    claimStageRec.Core_MDF_Message_txt__c = claimStageRec.Core_MDF_Message_txt__c + '\n' + Label.Core_MDF_Claim_Stage_Bank_Error;
                }
                //To check if the given bank belongs to the account on the given activity
                else if(!(bankAccountMap.get(claimStageRec.Core_MDF_Bank_Nbr__c).contains((activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).ChannelPartnerId)))
                {
                    claimStageRec.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Failed;
                    claimStageRec.Core_MDF_Message_txt__c = claimStageRec.Core_MDF_Message_txt__c + '\n' + Label.Core_MDF_Bulk_Claim_Account_Bank_Error;
                }
                else
                {
                    claimStageRec.Core_MDF_Request_Id__c = (activityNumberToPfrMap.get(claimStageRec.Core_MDF_Activity_Nbr__c)).Id;
                    claimStageRec.Core_MDF_Bank_Id__c = validBankNumbers.get(claimStageRec.Core_MDF_Bank_Nbr__c);
                    claimStageRec.Core_MDF_Message_txt__c = '';
                    claimStageRec.Core_MDF_Processing_Status_Nm__c = Label.Core_MDF_Claim_Batch_Successful;
                }
            }
        }
    }
    /************************************************************************************************************ 
Method Name:        createBankStatusSet
@return  :          Set<String>
@parameters:        -
Description:        This method returns valid bank status for creating claim                      
Added By:           Accenture  - Krishna Kulkarni - 19/06/2019
Modified By:        Date:       Changes: 
***************************************************************************************************/        
    public static Set<String> createBankStatusSet()
    {
        Set<String> bankStatusSet = new Set<String>();
        String bankStatusList = System.label.Core_MDF_Claim_Bank_StatusList;
        //To get valid bank status
        if(!String.IsBlank(bankStatusList)){
            for(String bankStatus : bankStatusList.split(';')){
                bankStatusSet.add(bankStatus);
            }
        }
        return bankStatusSet;         
    }
}