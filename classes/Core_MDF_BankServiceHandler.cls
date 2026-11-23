/****************************************************************************************************************************************
* Class Name        : Core_MDF_BankServiceHandler
* Created Date      : 11-11-2018
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - SB       11/11/2018          Service Class for handling trigger related functions on Bank object.
*****************************************************************************************************************************************/
public without sharing class Core_MDF_BankServiceHandler{
    static String userIdPrefix = User.SObjectType.getDescribe().getKeyPrefix();
    /***************************************************************************************************** 
    Method Name:        afterUpdateBankRecords
    @return  :          void
    @parameters:        newBankMap - Trigger.newMap for Core_MDF_Bank__c
    oldBankMap - Trigger.oldMap for Core_MDF_Bank__c
    Description:        Whenever the Owner of a Bank record is updated, share the record with the External Account Budget Admin User related to its program(s) and its Account.
    Added By:           Accenture - SB - 11/11/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void afterUpdateBankRecords(Map<Id,Core_MDF_Bank__c> oldBankMap, Map<Id,Core_MDF_Bank__c> newBankMap){
        Map<Id,Core_MDF_Bank__c> updatedBankOwnerMap = new Map<Id,Core_MDF_Bank__c>();
        Map<Id,Core_MDF_Bank__c> bankProgramAddedMap = new Map<Id,Core_MDF_Bank__c>();
        Map<Id,Core_MDF_Bank__c> bankProgramRemovedMap = new Map<Id,Core_MDF_Bank__c>();
        Map<Id,Core_MDF_Bank__c> updatedAccountMap = new Map<Id,Core_MDF_Bank__c>();
        List<Id> updatedBankLocationBankIdList = new List<Id>();
        for(Id bankId : oldBankMap.keySet()){
            if(oldBankMap.get(bankId).OwnerId != newBankMap.get(bankId).OwnerId){
                updatedBankOwnerMap.put(bankId,newBankMap.get(bankId));
            }
            if(newBankMap.get(bankId).Core_MDF_Program__c != NULL && oldBankMap.get(bankId).Core_MDF_Program__c != NULL
                && oldBankMap.get(bankId).Core_MDF_Program__c != newBankMap.get(bankId).Core_MDF_Program__c){//if program has been changed
                    for(String bankProgram : oldBankMap.get(bankId).Core_MDF_Program__c.split(';')){//CCF, DCF || newBank -> CCF, DCF, SPCF
                        if(!newBankMap.get(bankId).Core_MDF_Program__c.contains(bankProgram)){//('CCF;DCF;SPCF').doesNotContain('CCF')
                            bankProgramRemovedMap.put(bankId,newBankMap.get(bankId));
                        }
                        else{ 
                            bankProgramAddedMap.put(bankId,newBankMap.get(bankId));
                        }
                    }
                }
            
            if(oldBankMap.get(bankId).Core_MDF_Account__c != newBankMap.get(bankId).Core_MDF_Account__c){//if account has been changed
                updatedAccountMap.put(bankId,newBankMap.get(bankId));
            }
            
            if(oldBankMap.get(bankId).Core_MDF_Bank_Location__c != newBankMap.get(bankId).Core_MDF_Bank_Location__c){//if Bank Location has been changed
                
                updatedAccountMap.put(bankId,newBankMap.get(bankId));
                updatedBankLocationBankIdList.add(bankId);
            }
        }
        if(updatedBankOwnerMap.size() > 0){
            shareBankRecordsWithUsers(updatedBankOwnerMap);
            Core_MDF_GeoBasedGenericSharing.checkObjectAndPgm('Core_MDF_Bank__c', updatedBankLocationBankIdList);
        }
        if(bankProgramRemovedMap.size() > 0 || updatedAccountMap.size() > 0 || updatedBankLocationBankIdList.size() > 0){            
            List<Core_MDF_Bank__Share> bankShareList = [SELECT Id, ParentId, RowCause
                                                        FROM Core_MDF_Bank__Share
                                                        WHERE (ParentId IN :bankProgramRemovedMap.keySet() OR
                                                               ParentId IN :updatedAccountMap.keySet() OR
                                                               ParentId IN :updatedBankLocationBankIdList) AND 
                                                        RowCause IN (:Schema.Core_MDF_Bank__Share.RowCause.AccountBudgetAdmin__c, :Label.Core_MDF_RowCause_Manual)
                                                       ];
            if(bankShareList != NULL && bankShareList.size() > 0){
                delete bankShareList;
            }
            if(bankProgramRemovedMap.size() > 0){
                shareBankRecordsWithUsers(bankProgramRemovedMap);
                shareBankRecordsWithExternalUsers(bankProgramRemovedMap);
                Core_MDF_GeoBasedGenericSharing.checkObjectAndPgm('Core_MDF_Bank__c', updatedBankLocationBankIdList);
            }
            if(updatedAccountMap.size() > 0){
                shareBankRecordsWithUsers(updatedAccountMap);
                Core_MDF_GeoBasedGenericSharing.checkObjectAndPgm('Core_MDF_Bank__c', updatedBankLocationBankIdList);
            }
            if(updatedBankLocationBankIdList.size() > 0){
                shareBankRecordsWithUsers(updatedAccountMap);
                Core_MDF_GeoBasedGenericSharing.checkObjectAndPgm('Core_MDF_Bank__c', updatedBankLocationBankIdList);
                shareABMRecords(updatedBankLocationBankIdList);
            }
        }
        if(bankProgramAddedMap.size() > 0){ shareBankRecordsWithUsers(bankProgramAddedMap);Core_MDF_GeoBasedGenericSharing.checkObjectAndPgm('Core_MDF_Bank__c', updatedBankLocationBankIdList);
        }
        
    }
    /***************************************************************************************************** 
    Method Name:        beforeUpdateBankRecords
    @return  :          void
    @parameters:        newBankMap - Trigger.newMap for Core_MDF_Bank__c
                        oldBankMap - Trigger.oldMap for Core_MDF_Bank__c
    Description:        Method called to perform before Update Actions
    Added By:           Accenture - NZ - 20/01/2020
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void beforeUpdateBankRecords(Map<Id,Core_MDF_Bank__c> oldBankMap, Map<Id,Core_MDF_Bank__c> newBankMap){
        try{
            //Validate the Bank Data
            validateBankDataUpdate(oldBankMap, newBankMap);
        }catch(Exception e){String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_OriginName);}         
    }
    /***************************************************************************************************** 
    Method Name:        validateBankDataUpdate
    @return  :          void
    @parameters:        newBankMap - Trigger.newMap for Core_MDF_Bank__c
                        oldBankMap - Trigger.oldMap for Core_MDF_Bank__c
    Description:        Validate Change in Program or Ineffective Selection Field
    Added By:           Accenture - NZ - 20/01/2020 
    Modified By:        Date:  	27-Jan-2020    Changes: 
   ******************************************************************************************************/
    public static void validateBankDataUpdate(Map<Id,Core_MDF_Bank__c> oldBankMap, Map<Id,Core_MDF_Bank__c> newBankMap)
    {
        Map<Id,Core_MDF_Bank__c> updatedBankInactiveOrProgramInactiveMap = new Map<Id,Core_MDF_Bank__c>();
        //Loop over Old Bank Data and validate if there is any change in Program or Ineffective Selection
        for(Core_MDF_Bank__c bankRecord : oldBankMap.values()){
            if(bankRecord.Core_MDF_Program__c != newBankMap.get(bankRecord.id).Core_MDF_Program__c ||
               bankRecord.Core_MDF_Ineffective_Selection_ind__c != newBankMap.get(bankRecord.id).Core_MDF_Ineffective_Selection_ind__c){
                //Add the bank id as key and bank details as value to updatedBankInactiveOrProgramInactiveMap
			    updatedBankInactiveOrProgramInactiveMap.put(bankRecord.id,newBankMap.get(bankRecord.id));
            }
        }
        //updatedBankInactiveOrProgramInactiveMap has data then call the method validateBankInactivationOrProgramInactivation to check if Bank can be deactivated
        if(updatedBankInactiveOrProgramInactiveMap != NULL && updatedBankInactiveOrProgramInactiveMap.size() > 0){
            validateBankInactivationOrProgramInactivation(updatedBankInactiveOrProgramInactiveMap);
        }
    }
    
    /***************************************************************************************************** 
    Method Name:        validateBankInactivationOrProgramInactivation
    @return  :          void
    @parameters:        updatedBankMap - Map with updated Bank Data 
    Description:        Validate the updated Bank data to check if Program removed is valid for Inactivation
    Added By:           Accenture - NZ - 24/01/2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void validateBankInactivationOrProgramInactivation(Map<Id,Core_MDF_Bank__c> updatedBankMap){
        //Id - Store Inactive Bank id 
        Set<Id> eligibleBankSet = new Set<Id>();
     
        //List Storing program's which are de-selected
        Set<String> eligibleBankProgramWithoutDashSet = new Set<String>();  
        
        //Map key-- API name Value --> Label name of Program
        Map<String,String> channelProgramBankProgramMap = new Map<String,String>();
       
        //Map key - bank Id's Value --> Set of Program without the -
        Map<Id,Set<String>> bankIdProgramWithoutDashStringSetMap = new Map<Id,Set<String>>();

        //Create a Map of Program with key as Program API and value as Program Value
        for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem : ([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c
                                                                   FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt])){
            channelProgramBankProgramMap.put(bpem.Core_MDF_Bank_Program_Name__c, bpem.Core_MDF_Channel_Program__c);
        }
        for(Core_MDF_Bank__c bankRecord : updatedBankMap.values()){
            //Check if Ineffective Selection is true
           	if(bankRecord.Core_MDF_Ineffective_Selection_ind__c){
                //Add the Bank Record to eligibleBankSet, eligibleBankProgramSet, eligibleBankProgramWithoutDashSet,bankIdProgramWithoutDashStringSetMap and bankIdIneffectiveFlagMap
                for(String program : bankRecord.Core_MDF_Program__c.split(';')){
                    if(bankIdProgramWithoutDashStringSetMap.containsKey(bankRecord.Id)){
                     	bankIdProgramWithoutDashStringSetMap.get(bankRecord.Id).add(channelProgramBankProgramMap.get(program).replaceAll('-', ''));
                    }else{
                     	bankIdProgramWithoutDashStringSetMap.put(bankRecord.Id,new Set<String> {channelProgramBankProgramMap.get(program).replaceAll('-', '')});
                    }
                    eligibleBankProgramWithoutDashSet.add(channelProgramBankProgramMap.get(program).replaceAll('-', ''));
         		}
            }
            //Check if Program is changed
            if(bankRecord.Core_MDF_Program_Value__c != NULL && //Program Value -> CCFB
               bankRecord.Core_MDF_Program__c != NULL &&
               ((Core_MDF_Bank__c)(Trigger.oldMap.get(bankRecord.Id))).Core_MDF_Program__c != ((Core_MDF_Bank__c)(Trigger.newMap.get(bankRecord.Id))).Core_MDF_Program__c){//Program -> CCFB, CCF
                System.debug('((Core_MDF_Bank__c)(Trigger.oldMap.get(bankRecord.Id))).Core_MDF_Program__c : '+((Core_MDF_Bank__c)(Trigger.oldMap.get(bankRecord.Id))).Core_MDF_Program__c );
                System.debug('((Core_MDF_Bank__c)(Trigger.newMap.get(bankRecord.Id))).Core_MDF_Program__c : '+((Core_MDF_Bank__c)(Trigger.newMap.get(bankRecord.Id))).Core_MDF_Program__c );

                //Loop over Program and set data in bankIdProgramStringSetMap, bankIdProgramWithoutDashStringSetMap, eligibleBankProgramSet, eligibleBankProgramWithoutDashSet
                for(String programFromBackEndField :((Core_MDF_Bank__c)(Trigger.oldMap.get(bankRecord.Id))).Core_MDF_Program__c.split(';')){
                    
                    if(!(((Core_MDF_Bank__c)(Trigger.newMap.get(bankRecord.Id))).Core_MDF_Program__c + ';').contains(programFromBackEndField + ';')){
                        if(bankIdProgramWithoutDashStringSetMap.containsKey(bankRecord.Id)){
                            bankIdProgramWithoutDashStringSetMap.get(bankRecord.Id).add(channelProgramBankProgramMap.get(programFromBackEndField).replaceAll('-', ''));
                        }else{
                            bankIdProgramWithoutDashStringSetMap.put(bankRecord.Id,new Set<String> {channelProgramBankProgramMap.get(programFromBackEndField).replaceAll('-', '')});
                        }
                        eligibleBankProgramWithoutDashSet.add(channelProgramBankProgramMap.get(programFromBackEndField).replaceAll('-', ''));
                    }
                }
        	}
        }
        System.debug('bankIdProgramWithoutDashStringSetMap: '+bankIdProgramWithoutDashStringSetMap);
        System.debug('eligibleBankProgramWithoutDashSet: '+eligibleBankProgramWithoutDashSet);
        if(bankIdProgramWithoutDashStringSetMap != NULL && bankIdProgramWithoutDashStringSetMap.size() > 0){
            updateActiveFlagForABMsToTrue(bankIdProgramWithoutDashStringSetMap, eligibleBankProgramWithoutDashSet);
        }       
    }
    
    /***************************************************************************************************** 
    Method Name:        updateActiveFlagForABMsToTrue
    @return  :          void
    @parameters:        Map<Id,Set<String>> bankIdProgramStringSetMap //Map key --> bank Id, Value --> Set of Program
    Description:        Update the Active Checkbox to true for the ABMs related to the Program which are getting inactivated
    Added By:           Accenture - SB - 28/01/2020
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void updateActiveFlagForABMsToTrue(Map<Id,Set<String>> bankIdProgramStringSetMap, Set<String> eligibleBankProgramSet){        
        //Map key --> bank Id, Value --> List of Program
        List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();    
        
        //Loop over ABM query and deactivate the ABM for Eligible Bank and ABM 
        for(Core_MDF_Account_Bank_Mapping__c abm : [SELECT Id, Core_MDF_Account__c, Core_MDF_Bank__c, 
                                                           Core_MDF_Program__c, Core_MDF_AccountIdBankIdMapping__c, 
                                                           Core_MDF_Active_ind__c 
                                                    FROM Core_MDF_Account_Bank_Mapping__c
                                                    WHERE Core_MDF_Bank__c IN :bankIdProgramStringSetMap.keySet() AND
                                                          Core_MDF_Active_ind__c = true  AND
                                                          Core_MDF_Program__c IN :eligibleBankProgramSet]){
            if(bankIdProgramStringSetMap.get(abm.Core_MDF_Bank__c).contains(abm.Core_MDF_Program__c)){
                abm.Core_MDF_Active_ind__c = false;
                abmList.add(abm);
            }            
        }

        Map<Id,String> bankIdErrorStringMap = updateABMList(abmList);

        for(Id bankId : bankIdErrorStringMap.keySet()){
            Trigger.newMap.get(bankId).addError(bankIdErrorStringMap.get(bankId));
        }
    }
    /***************************************************************************************************** 
    Method Name:        updateABMList
    @return  :          void
    @parameters:        Map<Id,Set<String>> bankIdProgramStringSetMap //Map key --> bank Id, Value --> Set of Program
    Description:        Update the Active Checkbox to true for the ABMs related to the Program which are getting inactivated
    Added By:           Accenture - SB - 26/02/2020
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static Map<Id,String> updateABMList(List<Core_MDF_Account_Bank_Mapping__c> abmList){
        //Conditional
        String strClaimsRelatedErrorMessage = (Label.Core_MDF_Inactive_Bank_Error).substringBefore(': ');//Cannot Inactivate Bank as there are claims associated to the bank for the following program(s) : 
        Map<Id,String> bankIdEscalationErrorStringMap = new Map<Id,String>();
        Map<Id,String> bankIdOtherErrorStringMap = new Map<Id,String>();
        Map<Id,Set<String>> bankIdClaimProgramSetErrorStringMap = new Map<Id,Set<String>>();       
        Integer index = 0;
        //Update the ABM's data, and save the result in Database.saveResult
        String strEscalationsRelatedErrorMessage = Label.Core_MDF_BankErrorForActiveEscalations;
        for(Database.saveResult resultRecord: Database.update(abmList, false)){
            System.debug('SB -> resultRecord: ' + resultRecord);
            //Check if insertion is NOT successfull 
            if(!resultRecord.isSuccess()){
                //Escalation Related Error Message
                if((resultRecord.getErrors().get(0).getMessage()).containsIgnoreCase(strEscalationsRelatedErrorMessage)){
                    bankIdEscalationErrorStringMap.put(abmList.get(index).Core_MDF_Bank__c, strEscalationsRelatedErrorMessage);
                }
                if((resultRecord.getErrors().get(0).getMessage()).containsIgnoreCase(strClaimsRelatedErrorMessage)){//Claim Related Error Message
                    String program = ((resultRecord.getErrors().get(0).getMessage()).substringAfter(': ')).substringBefore('.'); //DCF.
					System.debug('SB -> program: ' + program);
                    String programWithoutDot = program.replace('.', ''); //DCF
                    if((bankIdClaimProgramSetErrorStringMap == NULL || bankIdClaimProgramSetErrorStringMap.size() == 0) || //no data in bankIdClaimProgramSetErrorStringMap
                      !(bankIdClaimProgramSetErrorStringMap.containsKey(abmList.get(index).Core_MDF_Bank__c))){//data not present for the Bank in the bankIdClaimProgramSetErrorStringMap
                        bankIdClaimProgramSetErrorStringMap.put(abmList.get(index).Core_MDF_Bank__c, new Set<String>{programWithoutDot});
                    }
                    else if(bankIdClaimProgramSetErrorStringMap != NULL && bankIdClaimProgramSetErrorStringMap.size() > 0 && (bankIdClaimProgramSetErrorStringMap.containsKey(abmList.get(index).Core_MDF_Bank__c) && !((bankIdClaimProgramSetErrorStringMap.get(abmList.get(index).Core_MDF_Bank__c)).contains(programWithoutDot)))){//Multiple programs for the same Bank
                        Set<String> programSet = new Set<String>();programSet = bankIdClaimProgramSetErrorStringMap.get(abmList.get(index).Core_MDF_Bank__c);programSet.add(programWithoutDot);bankIdClaimProgramSetErrorStringMap.put(abmList.get(index).Core_MDF_Bank__c, programSet);                        
                    }
                }
                /* else{bankIdOtherErrorStringMap.put(abmList.get(index).Core_MDF_Bank__c,resultRecord.getErrors().get(0).getMessage());
                } */
            }
            index++;
        }
        Map<Id,String> bankIdFinalErrorMessageStringMap = new Map<Id,String>();
        //Claims
        if(bankIdClaimProgramSetErrorStringMap != NULL && bankIdClaimProgramSetErrorStringMap.size() > 0){
            for(Id bankId : bankIdClaimProgramSetErrorStringMap.keySet()){
                String programs = '';
                List<String> listStrings = new List<String>(bankIdClaimProgramSetErrorStringMap.get(bankId));
                programs = String.join(listStrings, ', ');
                programs = programs.removeEnd(', ');//Remove the last comma and space
                bankIdFinalErrorMessageStringMap.put(bankId, strClaimsRelatedErrorMessage + ' : ' +programs + '.');//add a dot with the Program error message
            }
        }
        //Escalations
        if(bankIdEscalationErrorStringMap != NULL && bankIdEscalationErrorStringMap.size() > 0){
            for(Id bankId : bankIdEscalationErrorStringMap.keySet()){
                System.debug('bankIdEscalationErrorStringMap: '+bankIdEscalationErrorStringMap);
                System.debug('bankIdFinalErrorMessageStringMap: '+bankIdFinalErrorMessageStringMap);
                //no data in the bankIdFinalErrorMessageStringMap
                if(bankIdFinalErrorMessageStringMap == NULL || bankIdFinalErrorMessageStringMap.size() == 0){
                    bankIdFinalErrorMessageStringMap.put(bankId, bankIdEscalationErrorStringMap.get(bankId));
                }
                //data present in the bankIdFinalErrorMessageStringMap but for Claims
                else if(bankIdFinalErrorMessageStringMap != NULL && bankIdFinalErrorMessageStringMap.size() > 0 && bankIdFinalErrorMessageStringMap.containsKey(bankId) && !(bankIdFinalErrorMessageStringMap.get(bankId)).contains(strEscalationsRelatedErrorMessage)){bankIdFinalErrorMessageStringMap.put(bankId, bankIdFinalErrorMessageStringMap.get(bankId) + '\n' + strEscalationsRelatedErrorMessage);
                }
            }            
        }
        if(bankIdOtherErrorStringMap != NULL && bankIdOtherErrorStringMap.size()>0){for(Id bankId :bankIdOtherErrorStringMap.keySet()){bankIdFinalErrorMessageStringMap.put(bankId,bankIdFinalErrorMessageStringMap.get(bankId) +'\n' + bankIdOtherErrorStringMap.get(bankId));
            }
        }
        return bankIdFinalErrorMessageStringMap;
    }

    /***************************************************************************************************** 
    Method Name:        shareRecordsWithAccountBudgetAdminUsers
    @return  :          void
    @parameters:        newBankMap - Trigger.newMap for Core_MDF_Bank__c
    Description:        Whenever a Bank record is created, share the record with the External Account Budget Admin User related to its program(s) and its Account.
    Added By:           Accenture - SB - 11/11/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void shareBankRecordsWithUsers(Map<Id,Core_MDF_Bank__c> newBankMap){
        try{
            //List of all the Entitlement Names from the "Bank Program Entitlement Mapping" metadata
            Set<String> entitlementNameSet = new Set<String>();
            
            //Map of all the Channel Program and Bank Program from the "Bank Program Entitlement Mapping" metadata
            Map<String,String> channelProgramBankProgramMap = new Map<String,String>();
            
            //Map of Entitlement Name and it's associated Id from the Entitlement (Core_Entitlement__c) object records 
            Map<String,Id> entitlementNameIdMap = new Map<String,Id>();
            
            //Fetch and Map all the Channel Program Id and Bank Program from the Channel Program object
            Map<String,String> bankProgramChannelProgramIdMap = new Map<String,String>();
            
            //Set of all the Account Id from the incoming Bank records
            Set<Id> accountIdSet = new Set<Id>();
            
            //Set of all the Account Id from the incoming Bank records
            Set<Id> channelProgramIdSet = new Set<Id>();
            
            //Map where key = Account Id + '-' + Channel Program Id and value = related Bank Id list from the incoming Bank records
            Map<String,List<Id>> accountIdChannelProgramIdBankIdsMap = new Map<String,List<Id>>();
            
            //Map where key = Account Id + '-' + Channel Program Id and value = related Group Id list from the PGM object records
            Map<String,List<Id>> extAccountIdChannelProgramIdGroupIdsMap = new Map<String,List<Id>>();
            
            //Map where key = Group Id and value = related Bank Id list
            Map<Id,List<Id>> extGroupIdBankIdsMap = new Map<Id,List<Id>>();
            
            //Map where key = User Id and value = related Group Id list from the GroupMember object records
            Map<Id,List<Id>> userIdGroupIdsMap = new Map<Id,List<Id>>();
            
            //Map where key = User Id and value = related Group Id list from the GroupMember object records with only Account budget Admin users
            Map<Id,List<Id>> finalUserIdGroupIdsMap = new Map<Id,List<Id>>();
            
            //Map of Contact Id and related User Id from the User records
            Map<Id,Id> contactIdUserIdMap = new Map<Id,Id>();
            
            //Map of Bank Id and related User Id list from the User records - this will be used to create the Bank Share records.
            Map<Id,List<Id>> bankIdUserIdListMap = new Map<Id,List<Id>>();
            
            //Fetch the channelProgramBankProgramMap bankProgramBackEndFieldString from the Core_MDF_BankProgram_Entitlement_Mapping__mdt
            //Fetch the Custom Metadata (Core_MDF_BankProgram_Entitlement_Mapping__mdt) which will contain the Mapping between the Bank Program values, Channel Program and the Entitlement Names.
            for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem : ([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c, 
                                                                       Core_MDF_Entitlement_Name__c
                                                                       FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt])){
                                                                           entitlementNameSet.add(bpem.Core_MDF_Entitlement_Name__c);
                                                                           channelProgramBankProgramMap.put(bpem.Core_MDF_Channel_Program__c, bpem.Core_MDF_Bank_Program_Name__c);
                                                                       }
            //Fetch the Channel Program Ids with the help of the ChannelProgram name
            for(ChannelProgram cp : [SELECT Id, Name
                                     FROM ChannelProgram
                                     WHERE Name IN :channelProgramBankProgramMap.keySet()]){
                                         if(channelProgramBankProgramMap.get(cp.Name) != NULL){
                                             bankProgramChannelProgramIdMap.put(channelProgramBankProgramMap.get(cp.Name),cp.Id);
                                             channelProgramIdSet.add(cp.Id);
                                         }
                                     }
            
            //this is to populate the accountIdSet and accountIdChannelProgramIdBankIdsMap
            for(Id bankId : newBankMap.keySet()){
                //This will contain all the bank programs for the current element.
                List<String> bankProgramList = newBankMap.get(bankId).Core_MDF_Program__c.split(Label.Core_MDF_Semicolon);                
                accountIdSet.add(newBankMap.get(bankId).Core_MDF_Account__c);
                for(String bankProgram : bankProgramList){
                    //Populate the accountIdChannelProgramIdBankIdsMap
                    //newBankMap.get(bankId).Core_MDF_Account__c + '-' + bankProgramChannelProgramIdMap.get(bankProgram)
                    if(accountIdChannelProgramIdBankIdsMap.containsKey(newBankMap.get(bankId).Core_MDF_Account__c + Label.Core_MDF_Dash + bankProgramChannelProgramIdMap.get(bankProgram))){
                        accountIdChannelProgramIdBankIdsMap.get(newBankMap.get(bankId).Core_MDF_Account__c + Label.Core_MDF_Dash + bankProgramChannelProgramIdMap.get(bankProgram)).add(bankId);
                    }
                    else{
                        accountIdChannelProgramIdBankIdsMap.put(newBankMap.get(bankId).Core_MDF_Account__c + Label.Core_MDF_Dash + bankProgramChannelProgramIdMap.get(bankProgram), new List<String>{bankId});
                    }
                }
            } for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Id, Core_MDF_Account__c, Core_MDF_Group_Name__c, Core_MDF_Type_of_Access__c, 
                                                           Core_MDF_Group_Id__c, Core_MDF_Channel_Program__c
                                                           FROM Core_MDF_Partner_Group_Mapping__c
                                                           WHERE Core_MDF_Account__c IN :accountIdSet AND
                                                           Core_MDF_Channel_Program__c IN :channelProgramIdSet AND
                                                           //Core_MDF_Type_of_Access__c = :Label.Core_MDF_External AND
                                                           Core_MDF_Group_Id__c != NULL AND
                                                           Core_MDF_Account__c != NULL AND 
                                                           Core_MDF_Channel_Program__c != NULL
                                                          ]){
                                                              //External
                                                              if((Label.Core_MDF_External).equalsIgnoreCase(pgm.Core_MDF_Type_of_Access__c)){
                                                                  if(extAccountIdChannelProgramIdGroupIdsMap.containsKey(pgm.Core_MDF_Account__c + Label.Core_MDF_Dash + pgm.Core_MDF_Channel_Program__c)){
                                                                      extAccountIdChannelProgramIdGroupIdsMap.get(pgm.Core_MDF_Account__c + Label.Core_MDF_Dash + pgm.Core_MDF_Channel_Program__c).add(pgm.Core_MDF_Group_Id__c);
                                                                  }
                                                                  else{
                                                                      extAccountIdChannelProgramIdGroupIdsMap.put(pgm.Core_MDF_Account__c + Label.Core_MDF_Dash + pgm.Core_MDF_Channel_Program__c, new List<Id>{pgm.Core_MDF_Group_Id__c});
                                                                  }
                                                              }
                                                          }
            //Populate the extGroupIdBankIdsMap
            if(accountIdChannelProgramIdBankIdsMap.size() > 0){
                for(String straccountIdChannelProgramId : accountIdChannelProgramIdBankIdsMap.keySet()){
                    //External
                    if(extAccountIdChannelProgramIdGroupIdsMap.get(straccountIdChannelProgramId) != NULL){
                        for(Id groupId : extAccountIdChannelProgramIdGroupIdsMap.get(straccountIdChannelProgramId)){
                            if(extGroupIdBankIdsMap.containsKey(groupId)){
                                extGroupIdBankIdsMap.get(groupId).addAll(accountIdChannelProgramIdBankIdsMap.get(straccountIdChannelProgramId));
                            }
                            else{
                                extGroupIdBankIdsMap.put(groupId, accountIdChannelProgramIdBankIdsMap.get(straccountIdChannelProgramId));
                            }
                        }
                    }
                }
            }
            
            //Populate the userIdGroupIdsMap and userIdSet
            if(extGroupIdBankIdsMap.size() > 0){
                for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId
                                      FROM GroupMember
                                      WHERE GroupId IN :extGroupIdBankIdsMap.keySet()]){
                                          String userOrGroupIdString = gm.UserOrGroupId;
                                          //Check if the Group Member is a User but not a Group
                                          //if(userIdPrefix.equalsIgnoreCase(gm.UserOrGroupId)){
                                          if(userOrGroupIdString.startsWithIgnoreCase(userIdPrefix)){
                                              //if(Core_MDF_GenericShareRecordActionClass.findObjectNameFromRecordIdPrefix(gm.UserOrGroupId).equalsIgnoreCase(Label.Core_MDF_User_Object_Label)){
                                              if(userIdGroupIdsMap.containsKey(gm.UserOrGroupId)){ userIdGroupIdsMap.get(gm.UserOrGroupId).add(gm.GroupId);
                                                                                                 }
                                              else{
                                                  userIdGroupIdsMap.put(gm.UserOrGroupId, new List<Id>{gm.GroupId});
                                              }
                                          }
                                      }
                Id profileId = [SELECT Id, Name
                                FROM Profile
                                WHERE Name = :Label.Core_MDF_Partner
                                LIMIT 1].Id;
                if(userIdGroupIdsMap.size() > 0 && profileId != NULL){
                    for(User userRecord : [SELECT ContactId
                                           FROM User
                                           WHERE Id IN :userIdGroupIdsMap.keySet() AND
                                           IsActive = true AND
                                           ProfileId = :profileId AND
                                           ContactId != NULL]){
                                               contactIdUserIdMap.put(userRecord.ContactId, userRecord.Id);
                                           }
                    if(contactIdUserIdMap.size() > 0){
                        //Fetch all the Entitlement Ids and put it in the entitlementNameIdMap
                        for(Core_Entitlement__c entRecord : ([SELECT Id, Name
                                                              FROM Core_Entitlement__c
                                                              WHERE Name IN :entitlementNameSet])){
                                                                  entitlementNameIdMap.put(entRecord.Name, entRecord.Id);
                                                              }
                        
                        //Populate the finalUserIdGroupIdsMap
                        for(Core_Contact_Entitlement__c contactEntitlement : ([SELECT Id, Name, Core_Contact_Id__c, Core_Contact_Id__r.Account.Id,
                                                                               Core_Selected__c, Core_Status__c, Core_Entitlement_Id__c,
                                                                               Core_Entitlement_Id__r.Name
                                                                               FROM Core_Contact_Entitlement__c
                                                                               WHERE Core_Contact_Id__c IN : contactIdUserIdMap.keySet() AND
                                                                               Core_Entitlement_Id__c IN : entitlementNameIdMap.values() AND
                                                                               Core_Selected__c = true AND
                                                                               Core_Status__c = :Label.Core_MDF_Complete
                                                                               ORDER BY CreatedDate DESC])){
                                                                                   if(finalUserIdGroupIdsMap.containsKey(contactIdUserIdMap.get(contactEntitlement.Core_Contact_Id__c))){
                                                                                       finalUserIdGroupIdsMap.get(contactIdUserIdMap.get(contactEntitlement.Core_Contact_Id__c)).addAll(userIdGroupIdsMap.get(contactIdUserIdMap.get(contactEntitlement.Core_Contact_Id__c)));
                                                                                   }
                                                                                   else{
                                                                                       finalUserIdGroupIdsMap.put(contactIdUserIdMap.get(contactEntitlement.Core_Contact_Id__c), userIdGroupIdsMap.get(contactIdUserIdMap.get(contactEntitlement.Core_Contact_Id__c)));                               
                                                                                   }
                                                                               }
                        if(finalUserIdGroupIdsMap.size() > 0){
                            for(Id userId : finalUserIdGroupIdsMap.keySet()){
                                for(Id groupId : finalUserIdGroupIdsMap.get(userId)){
                                    for(Id bankId : extGroupIdBankIdsMap.get(groupId)){
                                        if(bankIdUserIdListMap.containsKey(bankId)){
                                            bankIdUserIdListMap.get(bankId).add(userId);
                                        }
                                        else{
                                            bankIdUserIdListMap.put(bankId, new List<Id>{userId});
                                        }
                                    }
                                }
                            }
                        }
                        if(bankIdUserIdListMap.size() > 0){
                            //SELECT RowCause, AccessLevel, UserOrGroupId, ParentId, Id FROM Core_MDF_Bank__Share
                            List<Core_MDF_Bank__Share> extBankShareList = new List<Core_MDF_Bank__Share>();
                            for(Id bankId : bankIdUserIdListMap.keySet()){
                                for(Id userId : bankIdUserIdListMap.get(bankId)){
                                    Core_MDF_Bank__Share bankShare = new Core_MDF_Bank__Share();
                                    bankShare.ParentId = bankId;
                                    bankShare.UserOrGroupId = userId;
                                    bankShare.RowCause = Schema.Core_MDF_Bank__Share.RowCause.AccountBudgetAdmin__c;
                                    bankShare.AccessLevel = Label.Core_MDF_Read_Access;
                                    extBankShareList.add(bankShare);
                                }
                            }
                            if(extBankShareList.size() > 0){
                                insert extBankShareList;
                            }
                        }
                    }
                }
            }
        }catch(Exception e){String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_OriginName);}
        
    }
    
    /***************************************************************************************************** 
    Method Name:        logErrorinLogObjectWithReason
    @return  :          void
    @parameters:        errorMessage - This will contain the Exception that is caught in class.
    strReason - This will contain reasons for the exception.
    Description:        Whenever an exception is passed as an argument, it will call the getErrorDetails method and
    pass the string returned to create the Log Entry record through the logErrorinLogObject method.
    Added By:           Accenture - SB - 09/14/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void logErrorinLogObjectWithReason(string errorMessage,string strReason)
    {
        String tab = '\t';
        String severity = Label.Core_MDF_Normal_Severity;
        String subject = Label.Core_MDF_CCP_Support_Email_Subject + ' ' +  strReason + ' ' + Label.CCP_Support_Email_Subject_Part2;
        Map<String, String> coreLogMap = new Map<String, String>();
        coreLogMap.put(Label.Core_MDF_LogErrorField1, errorMessage);
        coreLogMap.put(Label.Core_MDF_LogErrorField2, subject);
        coreLogMap.put(Label.Core_MDF_LogErrorField3, strReason);
        coreLogMap.put(Label.Core_MDF_LogErrorField4,Label.Core_MDF_Program_Name);
        coreLogMap.put(Label.Core_MDF_LogErrorField5,strReason);
        coreLogMap.put(Label.Core_MDF_LogErrorField6, severity);
        coreLogMap.put(Label.Core_MDF_LogErrorField7, Label.Core_MDF_CCP_Support_Email);
        coreLogMap.put(Label.Core_MDF_LogErrorField8, Label.Core_MDF_CCP_Support_Link);
        coreLogMap.put(Label.Core_MDF_LogErrorField9, strReason + tab + Label.Core_MDF_LogErrorField10) ;
        String errorText = Core_MDF_CCP_UtilityClass.createLogEntry(coreLogMap);
    }
    
    
    
    /***************************************************************************************************** 
    Method Name:        shareBankRecordsWithExternalUsers
    @return  :          void
    @parameters:        newBankMap - Trigger.newMap for Core_MDF_Bank__c
    Description:        Whenever a Bank record is created, share the record with the External Account Budget Admin User related to its program(s) and its Account.
    Added By:           Accenture - SB - 09/24/2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void shareBankRecordsWithExternalUsers(Map<Id,Core_MDF_Bank__c> newBankMap){
        Map<Id,List<Id>> bankIdUserIdListMap = new Map<Id,List<Id>>();
        List<Core_MDF_Account_Bank_Mapping__c> abmList = [SELECT Id, Core_MDF_Account__c, Core_MDF_Account__r.Name, Core_MDF_Bank__c, Core_MDF_Bank__r.Name, 
                                                          Core_MDF_Bank__r.Core_MDF_Account__c, Core_MDF_Bank__r.Core_MDF_Program__c, Core_MDF_Account__r.Core_MDF_Channel_Program__c 
                                                          FROM Core_MDF_Account_Bank_Mapping__c 
                                                          WHERE Core_MDF_Bank__c IN :newBankMap.keySet()
                                                          LIMIT 10000];
        bankIdUserIdListMap = Core_MDF_BankAccountServiceHandler.buildBankUsersMap(abmList, 'bank');
        if(bankIdUserIdListMap.size() > 0){ //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Core_MDF_Bank__c',bankIdUserIdListMap);
                                          }
    }
    /***************************************************************************************************** 
    Method Name:        shareABMRecords
    @return  :          void
    @parameters:        bankIdList - List of Bank Ids
    Description:        Whenever a Bank record is updated, reshare the related ABM records with the External and Internal Users
    Added By:           Accenture - SB - 09/24/2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void shareABMRecords(List<Id> bankIdList){
        Map<Id,Core_MDF_Account_Bank_Mapping__c> abmMap = new Map<Id,Core_MDF_Account_Bank_Mapping__c>();
        List<Core_MDF_Account_Bank_Mapping__Share> abmShareList = new List<Core_MDF_Account_Bank_Mapping__Share>();
        for(Core_MDF_Account_Bank_Mapping__c abmRecord : [SELECT Id, Core_MDF_Bank__c FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Bank__c IN :bankIdList]){abmMap.put(abmRecord.Id, abmRecord);
                                                                                                                                                                   }
        if(abmMap != NULL && abmMap.size() > 0){
            for(Core_MDF_Account_Bank_Mapping__Share abmShareRecord : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Core_MDF_Account_Bank_Mapping__Share WHERE ParentId IN :abmMap.keySet() AND RowCause = 'Manual']){abmShareList.add(abmShareRecord);
                                                                                                                                                                                                                                       }
            if(abmShareList != NULL && abmShareList.size() > 0){delete abmShareList;
                                                               }
            
            Core_MDF_BankAccountServiceHandler.shareBankAndABMRecordsWithExternalUsers(abmMap);
            Core_MDF_BankAccountServiceHandler.createABMShareForInternalUsers(abmMap);
        }
    }
    
}