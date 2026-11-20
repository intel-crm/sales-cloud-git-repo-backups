/****************************************************************************************************************************************
* Class Name        : Core_MDF_BankServiceHandler
* Created Date      : 11-11-2018
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - SB       11/11/2018         Service Class for handling trigger related functions on Bank object.
*****************************************************************************************************************************************/
public without sharing class Core_MDF_BankServiceHandler {

    //static String userIdPrefix = User.SObjectType.getDescribe().getKeyPrefix();
    //ATHR fixes - RP
    static string userIdPrefix = '005';

    static Boolean errorFlag = false;
    private Static String semicolon = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Semicolon');
    private Static String dash = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Dash');
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    //public static Boolean recursiveCheckStop = false;
    /*****************************************************************************************************
Method Name:        afterUpdateBankRecords
@return  :          void
@parameters:        newBankMap - Trigger.newMap for Core_MDF_Bank__c
oldBankMap - Trigger.oldMap for Core_MDF_Bank__c
Description:        Whenever the Owner of a Bank record is updated, share the record with the External Account Budget Admin User related to its program(s) and its Account.
Added By:           Accenture - SB - 11/11/2018
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void afterUpdateBankRecords(Map<Id, Core_MDF_Bank__c> oldBankMap, Map<Id, Core_MDF_Bank__c> newBankMap) {
        Map<Id, Core_MDF_Bank__c> bankAccLocUpdatedMap = new Map<Id, Core_MDF_Bank__c>();
        Map<Id, Core_MDF_Bank__c> bankOwnerUpdatedMap = new Map<Id, Core_MDF_Bank__c>();
        Map<Id, Core_MDF_Bank__c> bankProgramUpdatedMap = new Map<Id, Core_MDF_Bank__c>();
        Set<Id> bankProgramRemovedIdSet = new Set<Id>();
        List<Id> bankIdList = new List<Id>();
        
        for(Id bankId : oldBankMap.keySet()){
            if(oldBankMap.get(bankId).Core_MDF_Program__c != newBankMap.get(bankId).Core_MDF_Program__c){//Program Update
                for(String bankProgram : oldBankMap.get(bankId).Core_MDF_Program__c.split(semicolon)){//iterating over program of old Bank
                    String newBankProgram = newBankMap.get(bankId).Core_MDF_Program__c + semicolon;//appending semicolon to program of new Bank
                    if(!newBankProgram.contains(bankProgram + semicolon)){//checking if program has been removed
                        bankProgramRemovedIdSet.add(bankId);
                    }
                }
                bankProgramUpdatedMap.put(bankId,newBankMap.get(bankId));
                bankIdList.add(bankId);
            }
            if(oldBankMap.get(bankId).OwnerId != newBankMap.get(bankId).OwnerId){//Owner Update
                //bankOwnerUpdatedMap.put(bankId,newBankMap.get(bankId));
                bankIdList.add(bankId);
            }
            if((oldBankMap.get(bankId).Core_MDF_Account__c != newBankMap.get(bankId).Core_MDF_Account__c) ||//Account Update
               (oldBankMap.get(bankId).Core_MDF_Bank_Location__c != newBankMap.get(bankId).Core_MDF_Bank_Location__c)){//Location Update
                   bankAccLocUpdatedMap.put(bankId, newBankMap.get(bankId));
                   bankIdList.add(bankId);
               }
        }
        /*if(bankOwnerUpdatedMap != NULL && bankOwnerUpdatedMap.size() > 0){
            shareBankRecordsWithExternalUsers(bankOwnerUpdatedMap);
        }*/        
        if((bankProgramRemovedIdSet != NULL && bankProgramRemovedIdSet.size() > 0) || (bankAccLocUpdatedMap != NULL && bankAccLocUpdatedMap.size() > 0)){
            List<Core_MDF_Bank__Share> bankShareList = new List<Core_MDF_Bank__Share>();
            for(Core_MDF_Bank__Share bankShare : ([SELECT Id, ParentId, RowCause
                                                   FROM Core_MDF_Bank__Share
                                                   WHERE ParentId IN :bankIdList AND
                                                   RowCause IN (:Schema.Core_MDF_Bank__Share.RowCause.AccountBudgetAdmin__c, :Label.Core_MDF_RowCause_Manual)
                                                  ])){
                                                      if(bankProgramRemovedIdSet.contains(bankShare.ParentId) || 
                                                         oldBankMap.get(bankShare.ParentId).Core_MDF_Account__c != newBankMap.get(bankShare.ParentId).Core_MDF_Account__c ||
                                                         oldBankMap.get(bankShare.ParentId).Core_MDF_Bank_Location__c != newBankMap.get(bankShare.ParentId).Core_MDF_Bank_Location__c){
                                                             bankShareList.add(bankShare);
                                                         }
                                                  }
            if(bankShareList != NULL && bankShareList.size() > 0){
                delete bankShareList;
            }
            //shareBankRecordsWithUsers(bankAccLocUpdatedMap);
            //shareBankRecordsWithExternalUsers(bankAccLocUpdatedMap);
            shareABMRecords(bankIdList);
        }
        /*if(bankProgramUpdatedMap != NULL && bankProgramUpdatedMap.size() > 0){
            shareBankRecordsWithUsers(bankProgramUpdatedMap);
            shareBankRecordsWithExternalUsers(bankProgramUpdatedMap);
        }*/
        if(bankIdList != NULL && bankIdList.size() > 0){
            //Core_MDF_GeoBasedGenericSharing.checkObjectAndPgm('Core_MDF_Bank__c', bankIdList);
            createShareForBank(bankIdList,'IntExtSharing');
        }
        updateClaimOnBankHoldOrRelease(newBankMap.values(), oldBankMap);
    }
    
    /*****************************************************************************************************
Method Name:        beforeInsertBankRecords
@return  :          void
@parameters:        newBankList - Trigger.new for Core_MDF_Bank__c
Description:        Method called to perform before Insert Actions
Added By:           Accenture - SB - 10/07/2020
Modified By:        Date:    Changes:
******************************************************************************************************/
    public static void beforeInsertBankRecords(List<Core_MDF_Bank__c> newBankList){
        try{
            if(newBankList != Null && newBankList.size()>0){
                updateStatusToDraft(newBankList);
                if(!Core_MDF_Utility.byPassFeature('Bypass_Duplicate_Bank_Check'))
                    validateDuplicate(newBankList, false);
                calculateBankVatPercentage(NULL, newBankList, false);
            }
        }
        catch(Exception e){
            String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_OriginName);
        }
    }
    /*****************************************************************************************************
Method Name:        validateDuplicate
@return  :          void
@parameters:        newBankList - Trigger.new for Core_MDF_Bank__c
Description:        Method called to perform before Insert Actions
Added By:           Accenture - SB - 10/07/2020
Modified By:        Date:    Changes:
******************************************************************************************************/
    public static Set<Core_MDF_Bank__c> validateDuplicate(List<Core_MDF_Bank__c> newBankList, Boolean isUpdate){
        Set<String> bankSuppNoCurrPrgmSet = new Set<String>();
        Set<String> program = new Set<String>();
        Set<String> bankCurrency = new Set<String>();
        Set<String> supplierNo = new Set<String>();
        Set<Id> bankIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<String> legalEntityCodeSet = new Set<String>();
        Set<String> bankAccountNumber = new Set<String>();//added by JK - WW11 - to create a bank with different account numbers
        for(Core_MDF_Bank__c bankRecord : newBankList){
            bankCurrency.add(bankRecord.Core_MDF_Currency_cd__c);
            supplierNo.add(bankRecord.Core_MDF_Supplier_Number__c);
            accountIdSet.add(bankRecord.Core_MDF_Account__c);
            legalEntityCodeSet.add(bankRecord.Core_MDF_Intel_Company_Code__c);
            bankAccountNumber.add(bankRecord.Core_MDF_Bank_Account_Number__c);
            if(isUpdate){
                bankIdSet.add(bankRecord.Id);
            }
        }
        //Fetch the Banks from the Salesforce Database
        bankSuppNoCurrPrgmSet = fetchprgmSupnoCurrencySet(bankCurrency, supplierNo, bankIdSet, legalEntityCodeSet,accountIdSet,bankAccountNumber);
        return checkForBankDuplicate(newBankList, bankSuppNoCurrPrgmSet);
    }
    
    /*****************************************************************************************************
Method Name:        checkForBankDuplicate
@return  :          void
@parameters:        newBankList - Trigger.new for Core_MDF_Bank__c
Description:        Method called to perform before Insert Actions
Added By:           Accenture - SB - 10/07/2020
Modified By:        Date:    Changes:
******************************************************************************************************/
    public static Set<Core_MDF_Bank__c> checkForBankDuplicate(List<Core_MDF_Bank__c> newBankList, Set<String> bankSuppNoCurrPrgmSet){
        Set<String> incomingBankRecordSet = new Set<String>();
        Set<Core_MDF_Bank__c> validBankSet = new Set<Core_MDF_Bank__c>();
        for(Core_MDF_Bank__c bankRecord : newBankList){
            Set<String> bnkpgrmCurSupNoStringSet = new Set<String>();
            for(String prgm : bankRecord.Core_MDF_Program__c.split(';')){
                String bankSuppNoCurrPrgm = bankRecord.Core_MDF_Supplier_Number__c + '-' + bankRecord.Core_MDF_Currency_cd__c + '-' + prgm + '-'+ bankRecord.Core_MDF_Intel_Company_Code__c + '-' + bankRecord.Core_MDF_Account__c + '-' + bankRecord.Core_MDF_Bank_Account_Number__c + ';';
                if(incomingBankRecordSet.contains(bankSuppNoCurrPrgm)){//Incoming records have duplicates
                    bankRecord.addError(Label.Core_MDF_Bank_Duplicate_in_Incoming);
                }else if(bankSuppNoCurrPrgmSet != NULL && bankSuppNoCurrPrgmSet.contains(bankSuppNoCurrPrgm)){//Checking with the existing Salesforce Bank records
                    bankRecord.addError(Label.Core_MDF_Bank_Duplicate_SuppId_Prog_Curr);
                }
                else{
                    incomingBankRecordSet.add(bankRecord.Core_MDF_Supplier_Number__c + '-' + bankRecord.Core_MDF_Currency_cd__c + '-' + prgm + '-' + bankRecord.Core_MDF_Intel_Company_Code__c + '-' + bankRecord.Core_MDF_Account__c + '-' + bankRecord.Core_MDF_Bank_Account_Number__c + ';');
                    validBankSet.add(bankRecord);
                }
            }
        }
        return validBankSet;
    }
    
    /*****************************************************************************************************
Method Name:        fetchprgmSupnoCurrencySet
@return  :          void
@parameters:        newBankList - Trigger.new for Core_MDF_Bank__c
Description:        Method called to perform before Insert Actions
Added By:           Accenture - SB - 10/07/2020
Modified By:        Date:    Changes:
******************************************************************************************************/
    public static Set<String> fetchprgmSupnoCurrencySet(Set<String> bankCurrency, Set<String> supplierNo, Set<Id> bankIdSet, Set<String> legalEntityCodeSet, Set<Id> accountIdSet, Set<String> bankAccountNumber){
        Set<String> bankSuppNoCurrPrgmSet = new Set<String>();
        String bankIdQueryStr = '';
        
        if(bankIdSet != NULL && !bankIdSet.isEmpty()){
            bankIdQueryStr = ' AND Id NOT IN :bankIdSet';
        }
        String bankQuery = 'SELECT Core_MDF_Program__c,Core_MDF_Currency_cd__c,Core_MDF_Supplier_Number__c,Core_MDF_Account__c,Core_MDF_Intel_Company_Code__c,Core_MDF_Bank_Account_Number__c ' +
            'FROM Core_MDF_Bank__c ' +
            'WHERE  Core_MDF_Currency_cd__c IN :bankCurrency AND ' +
            'Core_MDF_Account__c IN :accountIdSet AND ' +
            'Core_MDF_Intel_Company_Code__c IN :legalEntityCodeSet AND '+
            'Core_MDF_Supplier_Number__c IN :supplierNo AND ' + 
            'Core_MDF_Bank_Account_Number__c IN :bankAccountNumber' + String.escapeSingleQuotes(bankIdQueryStr);
        for(Core_MDF_Bank__c bankRecord : Database.query(bankQuery)){
            for(String bankprgm : bankRecord.Core_MDF_Program__c.split(';')){
                bankSuppNoCurrPrgmSet.add(bankRecord.Core_MDF_Supplier_Number__c + '-' + bankRecord.Core_MDF_Currency_cd__c + '-' + bankprgm + '-' + bankRecord.Core_MDF_Intel_Company_Code__c + '-' + bankRecord.Core_MDF_Account__c + '-' + bankRecord.Core_MDF_Bank_Account_Number__c + ';');
            }
        }
        return bankSuppNoCurrPrgmSet;
    }
    /*****************************************************************************************************
Method Name:        beforeUpdateBankRecords
@return  :          void
@parameters:        newBankMap - Trigger.newMap for Core_MDF_Bank__c
oldBankMap - Trigger.oldMap for Core_MDF_Bank__c
Description:        Method called to perform before Update Actions
Added By:           Accenture - NZ - 20/01/2020
Modified By:        Date:        Changes:
Accenture - SB      10/07/2020   Added the calculation of Bank VAT percentage on the basis of Tax Code
Accenture - RG      02/06/2021   Bank recordtype Changes based on bank Status
******************************************************************************************************/
    public static void beforeUpdateBankRecords(Map<Id, Core_MDF_Bank__c> oldBankMap, Map<Id, Core_MDF_Bank__c> newBankMap){
        try{
            validateBankDataUpdate(oldBankMap, newBankMap);
            updateBankStatusAndRecordType(newBankMap.values(), oldBankMap);
        }
        catch(Exception e){String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_OriginName);}
    }
    
    /*****************************************************************************************************
Method Name:        calculateBankVatPercentage
@return  :          void
@parameters:        oldBankMap - Trigger.oldMap for Core_MDF_Bank__c
newBankList - Trigger.new for Core_MDF_Bank__c
Boolean - Check if it is an Update operation. True for update and false for insert.
Description:        Method called to calculate the Bank Vat percentage
Added By:           Accenture - SB - 10/07/2020
Modified By:        Date:    Changes:
******************************************************************************************************/
    public static void calculateBankVatPercentage(Map<Id, Core_MDF_Bank__c> oldBankMap, List<Core_MDF_Bank__c> newBankList, Boolean isUpdate){
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_BankVatPctCalculation') &&
           mapFunctionalityNameTriggerExecution.get('Core_MDF_BankVatPctCalculation').Core_Active__c){//if Bank Vat Percentage Switch is on
               if(isUpdate){//Update operation
                   List<Core_MDF_Bank__c> updatedBankTaxCodeList = checkIfBankTaxCodeHasBeenChanged(oldBankMap, newBankList); //Prepare the map for Bank records where Tax Code has been updated
                  /* if(updatedBankTaxCodeList != NULL && !updatedBankTaxCodeList.isEmpty()){ //if there are Bank records where Tax Code has been updated
                       populateVATPct(updatedBankTaxCodeList);//Populate the Bank's Vat Percentage
                   }*/ //ATHR Comment
                   //ATHR Fix- Deeply nested if
                   populateVATPct(updatedBankTaxCodeList != null && !updatedBankTaxCodeList.isEmpty() ? updatedBankTaxCodeList : new List<Core_MDF_Bank__c>());
               }
               else{//insert operation
                   populateVATPct(newBankList);//Populate the Bank's Vat Percentage
               }
           }
    }
    
    /*****************************************************************************************************
Method Name:        checkIfBankTaxCodeHasBeenChanged
@return  :          List<Core_MDF_Bank__c>
@parameters:        oldBankMap - Trigger.oldMap for Core_MDF_Bank__c
newBankList - Trigger.new for Core_MDF_Bank__c
Description:        Method called to check for Bank records where Tax Code has been updated
Added By:           Accenture - SB - 10/07/2020
Modified By:        Date:    Changes:
******************************************************************************************************/
    public static List<Core_MDF_Bank__c> checkIfBankTaxCodeHasBeenChanged(Map<Id, Core_MDF_Bank__c> oldBankMap, List<Core_MDF_Bank__c> newBankList){
        List<Core_MDF_Bank__c> updatedBankList = new List<Core_MDF_Bank__c>();
        for(Core_MDF_Bank__c bankRecord : newBankList){
            if(oldBankMap.get(bankRecord.Id).Core_MDF_Tax_codes_cd__c != bankRecord.Core_MDF_Tax_codes_cd__c){//Tax Code has been Updated
                updatedBankList.add(bankRecord);
            }
        }
        return updatedBankList;
    }
    
    /*****************************************************************************************************
Method Name:        validateBankDataUpdate
@return  :          void
@parameters:        newBankMap - Trigger.newMap for Core_MDF_Bank__c
oldBankMap - Trigger.oldMap for Core_MDF_Bank__c
Description:        Validate Change in Program or Ineffective Selection Field
Added By:           Accenture - SB - 10/07/2020
Modified By:        Date:    Changes:
******************************************************************************************************/
    public static void validateBankDataUpdate(Map<Id, Core_MDF_Bank__c> oldBankMap, Map<Id, Core_MDF_Bank__c> newBankMap){
        Map<Id, Core_MDF_Bank__c> updatedBankInactiveOrProgramInactiveMap = new Map<Id, Core_MDF_Bank__c>();
        List<Core_MDF_Bank__c> updatedBankList = new List<Core_MDF_Bank__c>();
        Set<Core_MDF_Bank__c> noProgSuppCurrUpdateBankSet = new Set<Core_MDF_Bank__c>();
        Boolean checkForBankInactivationOrProgramInactivation = false;
        
        //Loop over New Bank Data and validate if there is any change in Program or Ineffective Selection
        for(Core_MDF_Bank__c bankRecord : newBankMap.values()){
            if(bankRecord.Core_MDF_Program__c != oldBankMap.get(bankRecord.id).Core_MDF_Program__c ||
               bankRecord.Core_MDF_Ineffective_Selection_ind__c != oldBankMap.get(bankRecord.id).Core_MDF_Ineffective_Selection_ind__c){
                   //Add the bank id as key and bank details as value to updatedBankInactiveOrProgramInactiveMap
                   updatedBankInactiveOrProgramInactiveMap.put(bankRecord.Id, bankRecord);
               }
            //Duplicate Error check
            if(bankRecord.Core_MDF_Program__c != oldBankMap.get(bankRecord.id).Core_MDF_Program__c ||
               bankRecord.Core_MDF_Supplier_Number__c != oldBankMap.get(bankRecord.id).Core_MDF_Supplier_Number__c ||
               bankRecord.Core_MDF_Currency_cd__c != oldBankMap.get(bankRecord.id).Core_MDF_Currency_cd__c ||
               bankRecord.Core_MDF_Intel_Company_Code__c != oldBankMap.get(bankRecord.id).Core_MDF_Intel_Company_Code__c ||
               bankRecord.Core_MDF_Account__c != oldBankMap.get(bankRecord.id).Core_MDF_Account__c ||
               bankRecord.Core_MDF_Bank_Account_Number__c != oldBankMap.get(bankRecord.id).Core_MDF_Bank_Account_Number__c){
                  
                   updatedBankList.add(bankRecord);
               }
            else{
                noProgSuppCurrUpdateBankSet.add(bankRecord);
            }
        }
        
        if((updatedBankList != NULL && updatedBankList.size() > 0) || 
           (updatedBankInactiveOrProgramInactiveMap != NULL && updatedBankInactiveOrProgramInactiveMap.size() > 0)){
               if(updatedBankList != NULL && updatedBankList.size() > 0){//if Program, Supplier Number or Currency or Account or LE or Account Number has changed
                   Set<Core_MDF_Bank__c> validBankData = validateDuplicate(updatedBankList, true);
                   if(validBankData != NULL && !validBankData.isEmpty()){
                       if(validBankData.size() < updatedBankList.size()){//Some Duplicate errors are present in the validBankData
                           for(Core_MDF_Bank__c bankRecord : validBankData){
                               bankRecord.addError(Label.Core_MDF_Bank_No_Duplicate_Error);
                           }
                       }
                       else if(validBankData.size() == updatedBankList.size()){//Data correct
                           checkForBankInactivationOrProgramInactivation = true;
                       }
                   }
                   else{
                      /* if(noProgSuppCurrUpdateBankSet != NULL && !noProgSuppCurrUpdateBankSet.isEmpty()){
                        system.debug('inside 326');
                           for(Core_MDF_Bank__c bankRecord : noProgSuppCurrUpdateBankSet){
                               bankRecord.addError(Label.Core_MDF_Bank_No_Duplicate_Error);
                           }
                       }*/ //ATHR Comment
                       //ATHR Fix-Deeply nested if
                       for(Core_MDF_Bank__c bankRecord : ((noProgSuppCurrUpdateBankSet != null && !noProgSuppCurrUpdateBankSet.isEmpty()) ? noProgSuppCurrUpdateBankSet : new Set<Core_MDF_Bank__c>())) {
                               bankRecord.addError(Label.Core_MDF_Bank_No_Duplicate_Error);
                           }//ATHR End                       
                   }
               }
               else{//if Ineffective selection is updated or Program(s) has been inactivated
                   checkForBankInactivationOrProgramInactivation = true;
               }
               if(checkForBankInactivationOrProgramInactivation){
                   if(updatedBankInactiveOrProgramInactiveMap != NULL && updatedBankInactiveOrProgramInactiveMap.size() > 0){
                       if(!Core_MDF_Utility.byPassFeature('Bypass_Bank_Program_InActivation_Check'))
                           if(validateBankInactivationOrProgramInactivation(updatedBankInactiveOrProgramInactiveMap)){
                               beforeUpdateBankLogic(oldBankMap, newBankMap);
                           }
                   }
               }
           }
        else{
            beforeUpdateBankLogic(oldBankMap, newBankMap);
        }
    }
    
    /*****************************************************************************************************
Method Name:        populateVATPct
@return  :          void
@parameters:        newBankMap - Trigger.newMap for Core_MDF_Bank__c
Description:        Populate the Vat percentage on the basis of Tax code
Added By:           Accenture - SB - 10/07/2020
Modified By:        Date:    Changes:
******************************************************************************************************/
    public static void populateVATPct(List<Core_MDF_Bank__c> newBankList){
        Map<String, String> taxCodeVatPctMap = fetchTaxCodeVatPctMap();//Fetch the Tax Code and Vat Percentage mapping
        if(taxCodeVatPctMap != NULL && !taxCodeVatPctMap.isEmpty() && newBankList != NULL && !newBankList.isEmpty()){
            for(Core_MDF_Bank__c bankRecord : newBankList){
                if(taxCodeVatPctMap.containsKey(bankRecord.Core_MDF_Tax_codes_cd__c)){
                    bankRecord.Core_MDF_VAT_pct__c = taxCodeVatPctMap.get(bankRecord.Core_MDF_Tax_codes_cd__c);
                }
                else{
                    bankRecord.Core_MDF_VAT_pct__c = NULL;
                }
            }
        }
    }
    
    /*****************************************************************************************************
Method Name:        beforeUpdateBankLogic
@return  :          void
@parameters:        newBankMap - Trigger.newMap for Core_MDF_Bank__c
Description:        Populate the Vat percentage on the basis of Tax code
Added By:           Accenture - SB - 10/07/2020
Modified By:        Date:    Changes:
******************************************************************************************************/
    public static void beforeUpdateBankLogic(Map<Id, Core_MDF_Bank__c> oldBankMap, Map<Id, Core_MDF_Bank__c> newBankMap){
        calculateBankVatPercentage(oldBankMap, newBankMap.values(), true);//Calculate the Bank VAT percentage on the basis of Tax Code
    }
    
    /*****************************************************************************************************
Method Name:        fetchTaxCodeVatPctMap
@return  :          Map<String, String>
@parameters:
Description:        Fetch the Tax Code and Vat Percentage mapping
Added By:           Accenture - SB - 10/07/2020
Modified By:        Date:    Changes:
******************************************************************************************************/
    public static Map<String, String> fetchTaxCodeVatPctMap(){
        Map<String, String> taxCodeVatPctMap = new Map<String, String>();
        /*for(Core_MDF_Bank_Tax_Cd_Vat_Pct_Mapping__mdt taxCodeVatPct : [SELECT Id, Core_MDF_Tax_codes_cd__c, Core_MDF_VAT_pct__c
                                                                       FROM Core_MDF_Bank_Tax_Cd_Vat_Pct_Mapping__mdt]){
                                                                           taxCodeVatPctMap.put(taxCodeVatPct.Core_MDF_Tax_codes_cd__c, taxCodeVatPct.Core_MDF_VAT_pct__c);
                                                                       }*/
        for(Core_MDF_CCP_Custom_Metadata_Utility__c taxCodeVatPct :[select id,Core_MDF_Name_Criteria__c, Core_MDF_Value__c from Core_MDF_CCP_Custom_Metadata_Utility__c where Core_MDF_Category__c='Bank' and Core_MDF_Sub_Category__c='TAX_MAP']){
            taxCodeVatPctMap.put(taxCodeVatPct.Core_MDF_Name_Criteria__c,taxCodeVatPct.Core_MDF_Value__c);
                                                                       }
        return taxCodeVatPctMap;
    }
    
    /*****************************************************************************************************
Method Name:        validateBankInactivationOrProgramInactivation
@return  :          void
@parameters:        updatedBankMap - Map with updated Bank Data
Description:        Validate the updated Bank data to check if Program removed is valid for Inactivation
Added By:           Accenture - NZ - 24/01/2019
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static Boolean validateBankInactivationOrProgramInactivation(Map<Id, Core_MDF_Bank__c> updatedBankMap) {
        //Id - Store Inactive Bank id
        Set<Id> eligibleBankSet = new Set<Id>();
        
        Boolean transactionSuccessFlag = true;
        
        //List Storing program's which are de-selected
        Set<String> eligibleBankProgramWithoutDashSet = new Set<String>();
        
        //Map key-- API name Value --> Label name of Program
        Map<String,String> channelProgramBankProgramMap = new Map<String,String>();
        
        //Map key - bank Id's Value --> Set of Program without the -
        Map<Id,Set<String>> bankIdProgramWithoutDashStringSetMap = new Map<Id,Set<String>>();
        
        //Create a Map of Program with key as Program API and value as Program Value
        /*for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem : ([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c
                                                                   FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt LIMIT 1000])){
                                                                       channelProgramBankProgramMap.put(bpem.Core_MDF_Bank_Program_Name__c, bpem.Core_MDF_Channel_Program__c);
                                                                   }*/
        for(Core_MDF_ChannelProgram__mdt bpem : ([SELECT Label, Core_MDF_Bank_Program_Value__c
                                                                   FROM Core_MDF_ChannelProgram__mdt LIMIT 1000])){
                                                                       channelProgramBankProgramMap.put(bpem.Core_MDF_Bank_Program_Value__c, bpem.Label);
                                                                   }//Core_MDF_BankProgram_Entitlement_Mapping__mdt optimization
        for(Core_MDF_Bank__c bankRecord : updatedBankMap.values()){
            //Check if Ineffective Selection is true
            if(bankRecord.Core_MDF_Ineffective_Selection_ind__c){
                //Add the Bank Record to eligibleBankSet, eligibleBankProgramSet, eligibleBankProgramWithoutDashSet,bankIdProgramWithoutDashStringSetMap and bankIdIneffectiveFlagMap
                // WW51.2 OOC - added by JK instead of Core_MDF_Program__c , used Core_MDF_Program_Value__c
                for(String program : bankRecord.Core_MDF_Program_Value__c.split(';')){
                    String technicalProgramName = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(program);
                    eligibleBankProgramWithoutDashSet.add(technicalProgramName);
                   /* if(bankIdProgramWithoutDashStringSetMap.containsKey(bankRecord.Id)) {
		    	bankIdProgramWithoutDashStringSetMap.get(bankRecord.Id).add(technicalProgramName);
                //system.debug('bankIdProgramWithoutDashStringSetMap1'+bankIdProgramWithoutDashStringSetMap);
                } else {
                    bankIdProgramWithoutDashStringSetMap.put(bankRecord.Id,new Set<String>{technicalProgramName});
                }*/ // ATHR comment
                //ATHR Fix
                Set<String> techPrograms = bankIdProgramWithoutDashStringSetMap.get(bankRecord.Id);
                techPrograms = (techPrograms == null ? new Set<String>() : techPrograms);
                techPrograms.add(technicalProgramName);
                bankIdProgramWithoutDashStringSetMap.put(bankRecord.Id, techPrograms);//ATHR end
                 //system.debug('bankIdProgramWithoutDashStringSetMap2'+bankIdProgramWithoutDashStringSetMap);
                }
	    }
            //Check if Program is changed
            if(bankRecord.Core_MDF_Program_Value__c != NULL && //Program Value -> CCFB
               bankRecord.Core_MDF_Program__c != NULL &&
               ((Core_MDF_Bank__c)(Trigger.oldMap.get(bankRecord.Id))).Core_MDF_Program__c != ((Core_MDF_Bank__c)(Trigger.newMap.get(bankRecord.Id))).Core_MDF_Program__c){//Program -> CCFB, CCF
                   
                   //Loop over Program and set data in bankIdProgramStringSetMap, bankIdProgramWithoutDashStringSetMap, eligibleBankProgramSet, eligibleBankProgramWithoutDashSet
                   for(String programFromBackEndField :((Core_MDF_Bank__c)(Trigger.oldMap.get(bankRecord.Id))).Core_MDF_Program__c.split(';')){
                       
                       if(!(((Core_MDF_Bank__c)(Trigger.newMap.get(bankRecord.Id))).Core_MDF_Program__c + ';').contains(programFromBackEndField + ';')){
	                        String technicalProgramName = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(channelProgramBankProgramMap.get(programFromBackEndField));
	                        eligibleBankProgramWithoutDashSet.add(technicalProgramName);
				if(bankIdProgramWithoutDashStringSetMap.containsKey(bankRecord.Id)) {
					bankIdProgramWithoutDashStringSetMap.get(bankRecord.Id).add(technicalProgramName);
				} else { 
	                            bankIdProgramWithoutDashStringSetMap.put(bankRecord.Id,new Set<String>{technicalProgramName});
	                        }
                       }
                   }
               }
        }
        if(bankIdProgramWithoutDashStringSetMap != NULL && bankIdProgramWithoutDashStringSetMap.size() > 0){
            transactionSuccessFlag = updateActiveFlagForABMsToTrue(bankIdProgramWithoutDashStringSetMap, eligibleBankProgramWithoutDashSet);
        }
        return transactionSuccessFlag;
    }
    
    /*****************************************************************************************************
Method Name:        updateActiveFlagForABMsToTrue
@return  :          void
@parameters:        Map<Id,Set<String>> bankIdProgramStringSetMap //Map key --> bank Id, Value --> Set of Program
Description:        Update the Active Checkbox to true for the ABMs related to the Program which are getting inactivated
Added By:           Accenture - SB - 28/01/2020
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static Boolean updateActiveFlagForABMsToTrue(Map<Id,Set<String>> bankIdProgramStringSetMap, Set<String> eligibleBankProgramSet){
        //Map key --> bank Id, Value --> List of Program
        List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
        Boolean transactionSuccessFlag = true;
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
        if(bankIdErrorStringMap != NULL && !bankIdErrorStringMap.isEmpty()) {
            transactionSuccessFlag = false;
            for(Id bankId : bankIdErrorStringMap.keySet()) {
                Trigger.newMap.get(bankId).addError(bankIdErrorStringMap.get(bankId));
                }
        }
        return transactionSuccessFlag;
    }
    /*****************************************************************************************************
Method Name:        updateABMList
@return  :          void
@parameters:        Map<Id,Set<String>> bankIdProgramStringSetMap //Map key --> bank Id, Value --> Set of Program
Description:        Update the Active Checkbox to true for the ABMs related to the Program which are getting inactivated
Added By:           Accenture - SB - 26/02/2020
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static Map<Id,String> updateABMList(List<Core_MDF_Account_Bank_Mapping__c> abmList) {
        //Conditional
        String strClaimsRelatedErrorMessage = (Label.Core_MDF_Inactive_Bank_Error).substringBefore(': ');//Cannot Inactivate Bank as there are claims associated to the bank for the following program(s) :
        Map<Id,String> bankIdEscalationErrorStringMap = new Map<Id,String>();
        Map<Id,String> bankIdOtherErrorStringMap = new Map<Id,String>();
        Map<Id,Set<String>> bankIdClaimProgramSetErrorStringMap = new Map<Id,Set<String>>();
        Integer index = 0;
        //Update the ABM's data, and save the result in Database.saveResult
        String strEscalationsRelatedErrorMessage = Label.Core_MDF_BankErrorForActiveEscalations;
        for(Database.saveResult resultRecord: Database.update(abmList, false)){
            //Check if insertion is NOT successfull
            if(!resultRecord.isSuccess()){
                //Escalation Related Error Message
                if((resultRecord.getErrors().get(0).getMessage()).containsIgnoreCase(strEscalationsRelatedErrorMessage)){bankIdEscalationErrorStringMap.put(abmList.get(index).Core_MDF_Bank__c, strEscalationsRelatedErrorMessage);
                                                                                                                        }
                if((resultRecord.getErrors().get(0).getMessage()).containsIgnoreCase(strClaimsRelatedErrorMessage)){//Claim Related Error Message
                    String program = ((resultRecord.getErrors().get(0).getMessage()).substringAfter(': ')).substringBefore('.'); //DCF.
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
                List<String> listStrings = new List<String>(bankIdClaimProgramSetErrorStringMap.get(bankId));programs = String.join(listStrings, ', ');programs = programs.removeEnd(', ');//Remove the last comma and space
                bankIdFinalErrorMessageStringMap.put(bankId, strClaimsRelatedErrorMessage + ' : ' +programs + '.');//add a dot with the Program error message
            }
        }
        //Escalations
        if(bankIdEscalationErrorStringMap != NULL && bankIdEscalationErrorStringMap.size() > 0){
            for(Id bankId : bankIdEscalationErrorStringMap.keySet()){
                //no data in the bankIdFinalErrorMessageStringMap
                if(bankIdFinalErrorMessageStringMap == NULL || bankIdFinalErrorMessageStringMap.size() == 0){bankIdFinalErrorMessageStringMap.put(bankId, bankIdEscalationErrorStringMap.get(bankId));
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
    /*public static void shareBankRecordsWithUsers(Map<Id, Core_MDF_Bank__c> newBankMap){
        //Bypass bank record sharing with accountbudgetadminusers
        if(!Core_MDF_Utility.byPassFeature('Bypass_Bank_Internal_Sharing')){
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
                                                                           FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt
                                                                           WHERE Core_MDF_Entitlement_Name__c != NULL])){
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
                    List<String> bankProgramList = newBankMap.get(bankId).Core_MDF_Program__c.split(semicolon);
                    accountIdSet.add(newBankMap.get(bankId).Core_MDF_Account__c);
                    for(String bankProgram : bankProgramList){
                        if((channelProgramBankProgramMap.values()).contains(bankProgram)){
                            //Populate the accountIdChannelProgramIdBankIdsMap
                            //newBankMap.get(bankId).Core_MDF_Account__c + '-' + bankProgramChannelProgramIdMap.get(bankProgram)
                            if(accountIdChannelProgramIdBankIdsMap.containsKey(newBankMap.get(bankId).Core_MDF_Account__c + dash + bankProgramChannelProgramIdMap.get(bankProgram))){
                                accountIdChannelProgramIdBankIdsMap.get(newBankMap.get(bankId).Core_MDF_Account__c + dash + bankProgramChannelProgramIdMap.get(bankProgram)).add(bankId);
                            }
                            else{
                                accountIdChannelProgramIdBankIdsMap.put(newBankMap.get(bankId).Core_MDF_Account__c + dash + bankProgramChannelProgramIdMap.get(bankProgram), new List<String>{bankId});
                            }
                        }
                    }
                }
                for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Id, Core_MDF_Account__c, Core_MDF_Group_Name__c, Core_MDF_Type_of_Access__c,
                                                             Core_MDF_Group_Id__c, Core_MDF_Channel_Program__c
                                                             FROM Core_MDF_Partner_Group_Mapping__c
                                                             WHERE Core_MDF_Account__c IN :accountIdSet AND
                                                             Core_MDF_Channel_Program__c IN :channelProgramIdSet AND
                                                             //Core_MDF_Type_of_Access__c = :Label.Core_MDF_External AND
                                                             Core_MDF_Group_Id__c != NULL AND
                                                             Core_MDF_Account__c != NULL AND
                                                             Core_MDF_Inactive_Ind__c = false AND
                                                             Core_MDF_Channel_Program__c != NULL
                                                            ]){
                                                                //External
                                                                if((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External')).equalsIgnoreCase(pgm.Core_MDF_Type_of_Access__c)){
                                                                    if(extAccountIdChannelProgramIdGroupIdsMap.containsKey(pgm.Core_MDF_Account__c + dash + pgm.Core_MDF_Channel_Program__c)){
                                                                        extAccountIdChannelProgramIdGroupIdsMap.get(pgm.Core_MDF_Account__c + dash + pgm.Core_MDF_Channel_Program__c).add(pgm.Core_MDF_Group_Id__c);
                                                                    }
                                                                    else{
                                                                        extAccountIdChannelProgramIdGroupIdsMap.put(pgm.Core_MDF_Account__c + dash + pgm.Core_MDF_Channel_Program__c, new List<Id>{pgm.Core_MDF_Group_Id__c});
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
                                    WHERE Name = :Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Partner')
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
                                                                                   Core_Status__c = :Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Complete')
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
                            if(bankIdUserIdListMap != NULL && bankIdUserIdListMap.size() > 0){                               
                                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Bank__c',bankIdUserIdListMap, 'Read', Schema.Core_MDF_Bank__Share.RowCause.AccountBudgetAdmin__c);
                                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
                            }
                        }
                    }
                }
            }catch(Exception e){String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_OriginName);}
        }  
    }*/
 /*****************************************************************************************************
Method Name:        createShareForBank
@return  :          void
@parameters:        newBankMap - Trigger.newMap for Core_MDF_Bank__c
Description:        Whenever a Bank record is created or updated, share the bank records with Internal and External Users
Added By:           Accenture - HP - 12/03/2025
Modified By:        Date:       Changes:
******************************************************************************************************/    
    public static void createShareForBank(List<Id> bankIdList, String context){
        //if(!Core_MDF_Utility.byPassFeature('Bypass_Bank_Internal_Sharing') || !Core_MDF_Utility.byPassFeature('Bypass_Bank_External_Sharing')){ // ATHR Comment
        if(Core_MDF_Utility.byPassFeature('Bypass_Bank_Internal_Sharing') && Core_MDF_Utility.byPassFeature('Bypass_Bank_External_Sharing')){return;}// ATHR Fix - we can do early exist for this
   
            try{
                String accessType;
                Boolean intSharing = false;
                Boolean intPGMSharing = false;
                Boolean extSharing = false; 
                context  = !String.isBlank(context) ? context : 'IntExtSharing';
                if(!Core_MDF_Utility.byPassFeature('Bypass_Bank_Internal_Sharing') && !Core_MDF_Utility.byPassFeature('Bypass_Bank_External_Sharing') && context == 'IntExtSharing'){
                    accessType = null;
                    intSharing = true;
                    extSharing = true;
                }else if(!Core_MDF_Utility.byPassFeature('Bypass_Bank_Internal_Sharing') && (context == 'IntSharing' || context == 'IntExtSharing')){
                    accessType = Core_MDF_CCP_ConstantClass.INTERNAL;
                    intSharing = true;
                }else if(!Core_MDF_Utility.byPassFeature('Bypass_Bank_Internal_Sharing') && (context == 'IntPGMSharing' || context == 'IntExtSharing')){
                    accessType = Core_MDF_CCP_ConstantClass.INTERNAL;
                    intPGMSharing = true;
                }else if(!Core_MDF_Utility.byPassFeature('Bypass_Bank_External_Sharing') && (context == 'ExtSharing' || context == 'IntExtSharing')){
                    accessType = Core_MDF_CCP_ConstantClass.EXTERNAL;
                    extSharing = true;
                }
                Map<String,String> channelProgramBankProgramMap = new Map<String,String>();
                Map<String,String> bankProgramChannelProgramNameMap = new Map<String,String>();
                //Fetch and Map all the Channel Program Id and Bank Program from the Channel Program object
                Map<String,Id> bankProgToCPIdMap = new Map<String,Id>();            
                //Set of all the Account Id from the incoming Bank records
                Set<Id> accountIdSet = new Set<Id>();            
                //Set of all the Account Id from the incoming Bank records
                Set<Id> channelProgramIdSet = new Set<Id>();            
                List<Id> ultimateAccIdList = new List<Id>();
                List<Id> programIdList = new List<Id>();
                Map<Id,Set<String>> bankIdToUniqueSet = new Map<Id,Set<String>>();
                //key=2 digit country code, value=Geo
                Map<String,String> countryCodeGeoMap = new Map<String,String>();
                //key=2 digit country code, value=SubGeo
                Map<String,String> countryCodeSubGeoMap = new Map<String,String>();
                List<Core_MDF_RecordGeoShare> recordGeoShareForBudgetTypeList = new List<Core_MDF_RecordGeoShare>();
                List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();
                Map<Id,List<Id>> bankIdGroupIdListMap = new Map<Id,List<Id>>();
                
                //Fetch the Custom Metadata (Core_MDF_BankProgram_Entitlement_Mapping__mdt) which will contain the Mapping between the Bank Program values, Channel Program.
              /*  for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem : ([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt LIMIT 1000])){
                    channelProgramBankProgramMap.put(bpem.Core_MDF_Channel_Program__c, bpem.Core_MDF_Bank_Program_Name__c);
                    bankProgramChannelProgramNameMap.put(bpem.Core_MDF_Bank_Program_Name__c, bpem.Core_MDF_Channel_Program__c);
                }*/
                
                for(Core_MDF_ChannelProgram__mdt bpem : ([SELECT Label, Core_MDF_Bank_Program_Value__c FROM Core_MDF_ChannelProgram__mdt LIMIT 1000])){
                    channelProgramBankProgramMap.put(bpem.Label, bpem.Core_MDF_Bank_Program_Value__c);
                    bankProgramChannelProgramNameMap.put(bpem.Core_MDF_Bank_Program_Value__c, bpem.Label);
                }//Core_MDF_BankProgram_Entitlement_Mapping__mdt optimization
                
                //Fetch the Channel Program Ids with the help of the ChannelProgram name
                for(ChannelProgram cp : [SELECT Id, Name FROM ChannelProgram WHERE Name IN :channelProgramBankProgramMap.keySet()]){
                    if(channelProgramBankProgramMap.get(cp.Name) != NULL){
                        bankProgToCPIdMap.put(channelProgramBankProgramMap.get(cp.Name),cp.Id);
                    }
                }
                
                //Get Country Geo Mapping Records
                List<Core_MDF_CCP_Country_Geo_Mapping__mdt>  CountryMappingRecords = Core_MDF_GenericMetadata.getCountryGeoMappingMdt('');
                for(Core_MDF_CCP_Country_Geo_Mapping__mdt cgm : CountryMappingRecords) {
                    countryCodeGeoMap.put(cgm.Core_MDF_Code_2_Digits__c,cgm.Core_MDF_Geo__c);
                    countryCodeSubGeoMap.put(cgm.Core_MDF_Code_2_Digits__c,cgm.Core_MDF_Sub_Geo__c);
                }                
                
                //this is to populate the accountIdSet and channelProgramIdSet
                for(Core_MDF_Bank__c bank : [SELECT Id,Core_MDF_Account__c, Core_MDF_Program__c, Core_MDF_Bank_Location__c
                                             FROM Core_MDF_Bank__c WHERE Id IN : bankIdList])
                {
                    Set<String> uniqueKeySet = new Set<String>();
                    accountIdSet.add(bank.Core_MDF_Account__c);
                    for(String bankProgram : bank.Core_MDF_Program__c.split(semicolon)){
                        if(bankProgToCPIdMap.containsKey(bankProgram) && bankProgToCPIdMap.get(bankProgram) != NULL){
                            channelProgramIdSet.add(bankProgToCPIdMap.get(bankProgram));
                            uniqueKeySet.add((String)bank.Core_MDF_Account__c + (String)bankProgToCPIdMap.get(bankProgram));
                            if(countryCodeGeoMap.containsKey(bank.Core_MDF_Bank_Location__c)){
                                uniqueKeySet.add((String)bank.Core_MDF_Account__c + (String)bankProgToCPIdMap.get(bankProgram) + (String)countryCodeGeoMap.get(bank.Core_MDF_Bank_Location__c));
                                if(countryCodeSubGeoMap.containsKey(bank.Core_MDF_Bank_Location__c)){
                                    uniqueKeySet.add((String)bank.Core_MDF_Account__c + (String)bankProgToCPIdMap.get(bankProgram) + (String)countryCodeGeoMap.get(bank.Core_MDF_Bank_Location__c) + (String)countryCodeSubGeoMap.get(bank.Core_MDF_Bank_Location__c));
				    //Added NRE Program Check - Akash
                                    if(bankProgramChannelProgramNameMap.get(bankProgram) == Label.Core_MDF_IPA_Program_Name || bankProgramChannelProgramNameMap.get(bankProgram) == Label.Core_MDF_Co_GTM_program_name){                                    
                                        recordGeoShareForBudgetTypeList.add(new Core_MDF_RecordGeoShare(bank.Id,countryCodeGeoMap.get(bank.Core_MDF_Bank_Location__c),countryCodeSubGeoMap.get(bank.Core_MDF_Bank_Location__c), bankProgramChannelProgramNameMap.get(bankProgram)));
                                    }else{
                                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(bank.Id,countryCodeGeoMap.get(bank.Core_MDF_Bank_Location__c),countryCodeSubGeoMap.get(bank.Core_MDF_Bank_Location__c), bankProgramChannelProgramNameMap.get(bankProgram)));
                                    }
                                }
                            }
                        }
                    }
                    if(uniqueKeySet != NULL && uniqueKeySet.size() > 0){
                        bankIdToUniqueSet.put(bank.Id,new Set<String>(uniqueKeySet));                    
                    }
                    uniqueKeySet.clear();
                }
                ultimateAccIdList.addAll(accountIdSet);
                programIdList.addAll(channelProgramIdSet);
                //Mdt sharing
                if(intSharing){
                    if(recordGeoShareForBudgetTypeList != NULL && recordGeoShareForBudgetTypeList.size() >0){
                        Core_MDF_GeoBasedGenericSharing.shareRecordToGeoGroup('Core_MDF_Bank__c',recordGeoShareForBudgetTypeList);
                    }
                    if(recordGeoShareList != NULL && recordGeoShareList.size() >0){
                        Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroup('Core_MDF_Bank__c',recordGeoShareList);
                    }
                }
                //PGM sharing
                Core_MDF_PGM_Utility.pgmKeyGroupIdWrapper pgmKeyGrpIdWrapper = new Core_MDF_PGM_Utility.pgmKeyGroupIdWrapper();
                pgmKeyGrpIdWrapper = Core_MDF_PGM_Utility.getAccPGMKeyGrpIdMap(ultimateAccIdList,programIdList,accessType);
                Map<String,Id> intPGMAccKeyGroupIdMap = pgmKeyGrpIdWrapper.intPGMKeyGroupIdMap;
                Map<String,Id> extPGMAccKeyGroupIdMap = pgmKeyGrpIdWrapper.extPGMKeyGroupIdMap;
                if(bankIdToUniqueSet != NULL && bankIdToUniqueSet.size() > 0){
                    for(Id bankId : bankIdToUniqueSet.keySet()){
                        Set<Id> intGrpSet = new Set<Id>();
                        Set<Id> extGrpSet = new Set<Id>();
                        List<Id> grpIdList = new List<Id>();                       
                       // if(bankIdToUniqueSet.get(bankId) != NULL){ ATHR comment
                           // for(String uniqueKeySet : bankIdToUniqueSet.get(bankId)){
                        
                            for(String uniqueKeySet : (bankIdToUniqueSet.get(bankId) != null ? bankIdToUniqueSet.get(bankId) : new Set<String>())){ //ATHR fix
                                if((intSharing || intPGMSharing) && intPGMAccKeyGroupIdMap != NULL && intPGMAccKeyGroupIdMap.size() > 0 && intPGMAccKeyGroupIdMap.containsKey(uniqueKeySet)){
                                    intGrpSet.add(intPGMAccKeyGroupIdMap.get(uniqueKeySet));
                                }
                                if(extSharing && extPGMAccKeyGroupIdMap != NULL && extPGMAccKeyGroupIdMap.size() > 0 && extPGMAccKeyGroupIdMap.containsKey(uniqueKeySet)){
                                    extGrpSet.add(extPGMAccKeyGroupIdMap.get(uniqueKeySet));
                                }
                            }
                        //} ATHR comment
                        if(intGrpSet != NULL && intGrpSet.size() > 0){
                            grpIdList.addAll(intGrpSet);
                            bankIdGroupIdListMap.put(bankId,grpIdList);
                        }
                        if(extGrpSet != NULL && extGrpSet.size() > 0){
                            grpIdList.addAll(extGrpSet);
                            bankIdGroupIdListMap.put(bankId,grpIdList);
                        }
                    }
                }
                if(bankIdGroupIdListMap !=NuLL && bankIdGroupIdListMap.size() >0){
                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Bank__c', bankIdGroupIdListMap,'Edit');
                    Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
                }            
            }catch(Exception e){String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_OriginName);}  
        //}ATHR Comment
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
        String severity = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Normal_Severity');
        String subject = Label.Core_MDF_CCP_Support_Email_Subject + ' ' +  strReason + ' ' + Label.CCP_Support_Email_Subject_Part2;
        Map<String, String> coreLogMap = new Map<String, String>();
        coreLogMap.put(Label.Core_MDF_LogErrorField1, errorMessage);
        coreLogMap.put(Label.Core_MDF_LogErrorField2, subject);
        coreLogMap.put(Label.Core_MDF_LogErrorField3, strReason);
        coreLogMap.put(Label.Core_MDF_LogErrorField4,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Program_Name'));
        coreLogMap.put(Label.Core_MDF_LogErrorField5,strReason);
        coreLogMap.put(Label.Core_MDF_LogErrorField6, severity);
        coreLogMap.put(Label.Core_MDF_LogErrorField7, Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Support_Email'));
        coreLogMap.put(Label.Core_MDF_LogErrorField8, Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Support_Link'));
        coreLogMap.put(Label.Core_MDF_LogErrorField9, strReason + tab + Label.Core_MDF_LogErrorField10) ;
        String errorText = Core_MDF_CCP_UtilityClass.createLogEntry(coreLogMap);
    }
    
    
    
    /*****************************************************************************************************
Method Name:        shareBankRecordsWithExternalUsers
@return  :          void
@parameters:        newBankMap - Trigger.newMap for Core_MDF_Bank__c
Description:        Whenever a Bank record is created, share the record with the External Users other than Account Budget Admin records related to its program(s) and its Account.
Added By:           Accenture - SB - 09/24/2019
Modified By:        Date:       Changes:
******************************************************************************************************/
    /*public static void shareBankRecordsWithExternalUsers(Map<Id, Core_MDF_Bank__c> newBankMap){
        if(!Core_MDF_Utility.byPassFeature('Bypass_Bank_External_Sharing')){

            Map<Id,List<Id>> bankIdGroupIdListMap = new Map<Id,List<Id>>();
                                                              
            for(Core_MDF_Account_Bank_Mapping__c abm : [SELECT Id, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_External_Group_Id__c, Core_MDF_Bank__c
                                                        FROM Core_MDF_Account_Bank_Mapping__c
                                                        WHERE Core_MDF_Bank__c IN :newBankMap.keySet()
                                                        LIMIT 10000]){
                
                if(abm.Core_MDF_Account__r.Core_MDF_External_Group_Id__c != null){
                    //Creation of Bank and Group mapping
                    if(bankIdGroupIdListMap.containsKey(abm.Core_MDF_Bank__c) && bankIdGroupIdListMap.get(abm.Core_MDF_Bank__c) != NULL){
                        List<Id> groupIds = bankIdGroupIdListMap.get(abm.Core_MDF_Bank__c);
                        if(!groupIds.contains(abm.Core_MDF_Account__r.Core_MDF_External_Group_Id__c)){
                            groupIds.add(abm.Core_MDF_Account__r.Core_MDF_External_Group_Id__c);
                            bankIdGroupIdListMap.put(abm.Core_MDF_Bank__c, groupIds);
                        }                    
                    }
                    else{
                        bankIdGroupIdListMap.put(abm.Core_MDF_Bank__c, new List<Id>{abm.Core_MDF_Account__r.Core_MDF_External_Group_Id__c});
                    }
                }
            }

            //Bank Sharing
            Core_MDF_BankAccountServiceHandler.createShareRecords(bankIdGroupIdListMap, 'Core_MDF_Bank__c', 'Edit', 'Manual');
        }
    }*/
    /*****************************************************************************************************
Method Name:        shareABMRecords
@return  :          void
@parameters:        bankIdList - List of Bank Ids
Description:        Whenever a Bank record is updated, reshare the related ABM records with the External and Internal Users
Added By:           Accenture - SB - 09/24/2019
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void shareABMRecords(List<Id> bankIdList) {
       // if(!Core_MDF_Utility.byPassFeature('Bypass_Bank_ABM_Sharing')){//ATHR Comment
        if(Core_MDF_Utility.byPassFeature('Bypass_Bank_ABM_Sharing')){return;}//ATHR Fix - Deeply nested if

            Map<Id,Core_MDF_Account_Bank_Mapping__c> abmMap = new Map<Id,Core_MDF_Account_Bank_Mapping__c>();
            List<Core_MDF_Account_Bank_Mapping__Share> abmShareList = new List<Core_MDF_Account_Bank_Mapping__Share>();
            List<Core_MDF_Account_Bank_Mapping__c> abmList = [SELECT Id, Core_MDF_Bank__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_External_Group_Id__c FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Bank__c IN :bankIdList];
            
            for(Core_MDF_Account_Bank_Mapping__c abmRecord : abmList){
                abmMap.put(abmRecord.Id, abmRecord);
            }

            if(abmMap != NULL && abmMap.size() > 0){
                for(Core_MDF_Account_Bank_Mapping__Share abmShareRecord : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Core_MDF_Account_Bank_Mapping__Share WHERE ParentId IN :abmMap.keySet() AND RowCause = 'Manual']){abmShareList.add(abmShareRecord);
                                                                                                                                                                                                                                           }
                if(abmShareList != NULL && abmShareList.size() > 0){delete abmShareList;
                                                                   }
                Core_MDF_BankAccountServiceHandler.createABMShareForInternalUsers(abmMap);
            }

            //For External Sharing
            Map<Id,List<Id>> abmIdGroupIdListMap = new Map<Id,List<Id>>();
                                                                    
            for(Core_MDF_Account_Bank_Mapping__c abm : abmList){
                
                if(abm.Core_MDF_Account__r.Core_MDF_External_Group_Id__c != null){
                    //Creation of ABM and Group mapping
                    abmIdGroupIdListMap.put(abm.Id, new List<Id>{abm.Core_MDF_Account__r.Core_MDF_External_Group_Id__c});
                }
            }

            //ABM Sharing
            Core_MDF_BankAccountServiceHandler.createShareRecords(abmIdGroupIdListMap, 'Core_MDF_Account_Bank_Mapping__c', 'Edit', 'Manual');
        //}ATHR Comment
    }
    
    /*****************************************************************************************************
Method Name:        updateBankStatusAndRecordType
@return  :          void
@parameters:        newBankList - Trigger.new for Core_MDF_Bank__c
oldBankMap - Trigger.oldMap for Core_MDF_Bank__c
Description:        Method for updating Bank Status and record Types 
Added By:           Accenture - NK - 03/06/2021
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void updateBankStatusAndRecordType(List<Core_MDF_Bank__c> newBankList, Map<Id, Core_MDF_Bank__c> oldBankMap) { 
        
        Map<String,Schema.RecordTypeInfo> claimRecordTypeMap = Schema.SObjectType.Core_MDF_bank__c.getRecordTypeInfosByDeveloperName();
        for(Core_MDF_Bank__c bankRecord : newBankList){
           // if(bankRecord.Core_MDF_ESD_Update__c == true){ ATHR Comment
           if(bankRecord.Core_MDF_ESD_Update__c == false){continue;}//ATHR Fix
                if(bankRecord.Core_MDF_Ineffective_Selection_ind__c == false){
                    //Setting status to hold when bank is put on hold
                    //to check old bank status != hold
                    if(oldBankMap.get(bankRecord.Id).Core_MDF_Bank_Status__c != 'Hold' 
                       //to check if bank is put on esd hold
                       && ((bankRecord.Core_MDF_ESD_Hold_Indicator__c == true && oldBankMap.get(bankRecord.Id).Core_MDF_ESD_Hold_Indicator__c != bankRecord.Core_MDF_ESD_Hold_Indicator__c)
                           //to check if bank is put on ap hold
                           ||(bankRecord.Core_MDF_Hold_Payments_from_AP_file_ind__c == 'yes' && oldBankMap.get(bankRecord.Id).Core_MDF_Hold_Payments_from_AP_file_ind__c != bankRecord.Core_MDF_Hold_Payments_from_AP_file_ind__c)
                           // to check if ineffective indicator is changed and bank is on hold
                           ||((bankRecord.Core_MDF_ESD_Hold_Indicator__c == true || bankRecord.Core_MDF_Hold_Payments_from_AP_file_ind__c == 'yes') && oldBankMap.get(bankRecord.Id).Core_MDF_Bank_Status__c == 'Inactive'
                              && bankRecord.Core_MDF_Ineffective_Selection_ind__c != oldBankMap.get(bankRecord.Id).Core_MDF_Ineffective_Selection_ind__c))){
                                if(bankRecord.Core_MDF_Effective_Date__c <= system.today()){
                                  bankRecord.Core_MDF_Bank_Status__c = 'Hold';
                                  // non-draft record type
                                  bankRecord.RecordTypeId = claimRecordTypeMap.get('Core_MDF_Bank_Status_Non_Draft').getRecordTypeId();
                                }
                                //to check if effective date is in future
                                else if(bankRecord.Core_MDF_Effective_Date__c > system.today()){
                                    
                                    bankRecord.Core_MDF_Bank_Status__c = 'Draft';
                                    // non draft record type
                                    bankRecord.RecordTypeId = claimRecordTypeMap.get('Core_MDF_Bank_Status_Non_Draft').getRecordTypeId();
                                }
                              }
                    // Setting status as active when both holds are released and when effective date is reached
                    // Setting status as draft when both holds are released and when effective date is not reached
                    // to check esd hold indicator is false
                    else if(bankRecord.Core_MDF_ESD_Hold_Indicator__c == false
                            // to check ap hold indicator is not yes
                            && (bankRecord.Core_MDF_Hold_Payments_from_AP_file_ind__c != 'Yes')
                            // to check esd hold indicator is changed
                            && (oldBankMap.get(bankRecord.Id).Core_MDF_ESD_Hold_Indicator__c != bankRecord.Core_MDF_ESD_Hold_Indicator__c
                                // to check ap hold indicator is changed
                                || oldBankMap.get(bankRecord.Id).Core_MDF_Hold_Payments_from_AP_file_ind__c != bankRecord.Core_MDF_Hold_Payments_from_AP_file_ind__c
                                // to check if ineffective indicator is changed
                                || (bankRecord.Core_MDF_Ineffective_Selection_ind__c != oldBankMap.get(bankRecord.Id).Core_MDF_Ineffective_Selection_ind__c &&  oldBankMap.get(bankRecord.Id).Core_MDF_Bank_Status__c == 'Inactive')
                                // to check if old status is draft
                                || oldBankMap.get(bankRecord.Id).Core_MDF_Bank_Status__c == 'Draft')){
                                    //to check if effective date is in past
                                    if(bankRecord.Core_MDF_Effective_Date__c <= system.today()){
                                        bankRecord.Core_MDF_Bank_Status__c = 'Active';
                                        // active record type
                                        bankRecord.RecordTypeId = claimRecordTypeMap.get('Core_MDF_Bank_Status_Active').getRecordTypeId();
                                    }
                                    //to check if effective date is in future
                                    else if(bankRecord.Core_MDF_Effective_Date__c > system.today()){
                                        
                                        bankRecord.Core_MDF_Bank_Status__c = 'Draft';
                                        // non draft record type
                                        bankRecord.RecordTypeId = claimRecordTypeMap.get('Core_MDF_Bank_Status_Non_Draft').getRecordTypeId();
                                    }
                                }
                }
                // Setting status as inactive when ineffective indicator is true
                else if(bankRecord.Core_MDF_Ineffective_Selection_ind__c == true){
                    bankRecord.Core_MDF_Bank_Status__c = 'Inactive';
                    // non-draft record type
                    bankRecord.RecordTypeId = claimRecordTypeMap.get('Core_MDF_Bank_Status_Non_Draft').getRecordTypeId();
                }
          //  }ATHR Comment
        }
    }
    /*****************************************************************************************************
Method Name:        updateClaimOnBankHoldOrRelease
@return  :          void
@parameters:        newBankList - Trigger.new for Core_MDF_Bank__c
oldBankMap - Trigger.oldMap for Core_MDF_Bank__c
Description:        Method for updating Claims on Bank hold & release
Added By:           Accenture - NK - 04/06/2021
Modified By:        Date:       Changes:
******************************************************************************************************/   
    public static void updateClaimOnBankHoldOrRelease(List<Core_MDF_Bank__c> newBankList, Map<Id, Core_MDF_Bank__c> oldBankMap) { 
        
        //Map of Bank id to Reason List
        Map<Id,List<String>> idToReasonMap = new Map<Id,List<String>>();
        //Map of Bank id to Hold reason List
        Map<Id,List<String>> idToHoldMap = new Map<Id,List<String>>();
        //list to store the channel programs
        List<String> listOfPrograms = new List<String>();
        //map to store the list of countries from custom metadata
        Map<String, List<String>> channelProgramToCountriesMap = new Map<String, List<String>>();
        //list of release reasons
        List<String> releaseReasonList = new List<String>();
        //list of hold reasons
        List<String> holdReasonList = new List<String>();
        
        // Querying Channel Program Metadata and Creating map of Channel Program and the countries for which Claims need to go to bank doc hold
        for(Core_MDF_ChannelProgram__mdt cp : [Select Core_MDF_Technical_Program_Name__c,Core_MDF_BankDocHold_Countries_Required__c FROM Core_MDF_ChannelProgram__mdt WHERE Core_MDF_BankDocHold_Countries_Required__c != null]){
            
            List<String> listOfCountries = new List<String>();
            listOfCountries = cp.Core_MDF_BankDocHold_Countries_Required__c.split(';');
            channelProgramToCountriesMap.put(cp.Core_MDF_Technical_Program_Name__c, listOfCountries);
        }
        
        for(Core_MDF_Bank__c bankRecord : newBankList){
            if(bankRecord.Core_MDF_ESD_Update__c == true && bankRecord.Core_MDF_Ineffective_Selection_ind__c == false){
                // checking if bank is put on any hold (either esd or ap)
                if(bankRecord.Core_MDF_ESD_Hold_Indicator__c == true && oldBankMap.get(bankRecord.Id).Core_MDF_ESD_Hold_Indicator__c != bankRecord.Core_MDF_ESD_Hold_Indicator__c){
                       idToHoldMap.put(bankRecord.Id, new List<string>{Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ESD_Hold')});
                }
                if(bankRecord.Core_MDF_Hold_Payments_from_AP_file_ind__c == 'Yes' && oldBankMap.get(bankRecord.Id).Core_MDF_Hold_Payments_from_AP_file_ind__c != bankRecord.Core_MDF_Hold_Payments_from_AP_file_ind__c){
                    if(idToHoldMap.containsKey(bankRecord.Id)){
                        idToHoldMap.get(bankRecord.Id).add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Payment_Hold')); 
                    }else{ 
                        idToHoldMap.put(bankRecord.Id, new List<string>{Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Payment_Hold')});
                    } 
                }
                // checking if bank is released from esd hold
                if(bankRecord.Core_MDF_ESD_Hold_Indicator__c == false && oldBankMap.get(bankRecord.Id).Core_MDF_ESD_Hold_Indicator__c != bankRecord.Core_MDF_ESD_Hold_Indicator__c){
                    idToReasonMap.put(bankRecord.Id, new List<string>{Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ESD_Hold')});
                }
                // checking if bank is released from payment hold
                if((bankRecord.Core_MDF_Hold_Payments_from_AP_file_ind__c != 'Yes') && oldBankMap.get(bankRecord.Id).Core_MDF_Hold_Payments_from_AP_file_ind__c == 'Yes' 
                   && oldBankMap.get(bankRecord.Id).Core_MDF_Hold_Payments_from_AP_file_ind__c != bankRecord.Core_MDF_Hold_Payments_from_AP_file_ind__c){
                       if(idToReasonMap.containsKey(bankRecord.Id)){
                           idToReasonMap.get(bankRecord.Id).add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Payment_Hold'));
                       }
                       else{
                           idToReasonMap.put(bankRecord.Id,new List<string>{Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Payment_Hold')});
                       }
                   }
                
            }
            if((bankRecord.Core_MDF_Bank_Location__c !=NULL && oldBankMap.get(bankRecord.Id).Core_MDF_Bank_Location__c != bankRecord.Core_MDF_Bank_Location__c)){
                listOfPrograms = bankRecord.Core_MDF_Program_Value__c.split(';');
                
                for(string channelProgram : listOfPrograms){
                    if(channelProgramToCountriesMap.containsKey(channelProgram)){
                        if(channelProgramToCountriesMap.get(channelProgram).contains(bankRecord.Core_MDF_Bank_Location__c) && !channelProgramToCountriesMap.get(channelProgram).contains(oldBankMap.get(bankRecord.Id).Core_MDF_Bank_Location__c)){ 
                            if(idToHoldMap.containsKey(bankRecord.Id)){
                                idToHoldMap.get(bankRecord.Id).add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bank_Document_Hold')); 
                            }else{
                                idToHoldMap.put(bankRecord.Id,new List<string>{Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bank_Document_Hold')});    
                            }
                        }else if(!channelProgramToCountriesMap.get(channelProgram).contains(bankRecord.Core_MDF_Bank_Location__c) && channelProgramToCountriesMap.get(channelProgram).contains(oldBankMap.get(bankRecord.Id).Core_MDF_Bank_Location__c)){
                            if(idToReasonMap.containsKey(bankRecord.Id)){
                                idToReasonMap.get(bankRecord.Id).add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bank_Document_Hold'));
                            }
                            else{
                                idToReasonMap.put(bankRecord.Id,new List<string>{Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bank_Document_Hold')});
                            } 
                        }
                    }
                    
                }
            }
        } 
        // calling batch to update claims on bank release
        if(idToReasonMap != Null && idToReasonMap.size()>0){
            try{
                Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('BATCH_UPDATE_CLAIM_ON_BANK_RELEASE');
                Database.executeBatch(new Core_MDF_Batch_UpdateClaimOnBankRelease(idToReasonMap),Integer.valueOf(config.Core_MDF_Value__c));  
            }catch (Exception exc) {
                Core_MDF_CCP_UtilityClass.logError(exc);
            }
        }
        // calling batch to update claims on bank hold
        if(idToHoldMap != Null && idToHoldMap.size()>0){
            try{
                Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('BATCH_UPDATE_CLAIM_ON_BANK_HOLD_LIMIT');
                Database.executeBatch(new Core_MDF_Batch_UpdateClaimOnBankHold(idToHoldMap),Integer.valueOf(config.Core_MDF_Value__c));  
            }catch (Exception exc) {
                Core_MDF_CCP_UtilityClass.logError(exc);
            }
        }
        
    }
    /*****************************************************************************************************
Method Name:        updateStatusToDraft
@return  :          void
@parameters:        newBankList - Trigger.new for Core_MDF_Bank__c
Description:        Method for updating bank status to draft
Added By:           Accenture - NK - 07/06/2021
Modified By:        Date:       Changes:
******************************************************************************************************/   
    public static void updateStatusToDraft(List<Core_MDF_Bank__c> newBankList){
        
        if(newBankList != NULL && newBankList.size() > 0){
            //Code to update bank status to draft initially 
            for(Core_MDF_Bank__c bankRecord : newBankList){
                bankRecord.Core_MDF_Bank_Status__c = 'Draft';
            } 
        }
    }
}