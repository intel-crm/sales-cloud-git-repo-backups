/****************************************************************************************************************************************
 * Class Name  : Core_MDF_PMBServiceHandler
 * Version     : 1.0
 * Created Date: 09-03-2018
 * Modification Log :
 * Developer            Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture - JV       03/09/2018          Service Class for handling trigger related functions on Partner Marketing Budget object.
 *****************************************************************************************************************************************/
public without sharing class Core_MDF_PMBServiceHandler {


    /*****************************************************************************************************
     Method Name:        checkPMBDuplicateRecords
     @return  :          void
     @parameters:        newPMBList - This will contain all the pmb records to be inserted/updated.
     Description:        Whenever a record is inserted/updated of Partner Marketing object, this method checks whether the current record is duplicate or not
     @Added By:          Accenture - JV - 09/03/2018
     Modified By:        Date:       Changes:
     ******************************************************************************************************/
    public static void checkPMBDuplicateRecords(List<PartnerMarketingBudget> newPMBList) {
        //List of partner account
        List<Id> partnerAccountList = new List<Id>();
        //List of budgets
        List<Id> pmbIdList = new List<Id>();
        try{
            for(PartnerMarketingBudget pmbRecord :newPMBList) {
                PartnerAccountList.add(pmbRecord.Core_MDF_Budget_Partner__c);
                pmbIdList.add(pmbRecord.Id);
            }
            //List of existing budgets corresponding to partner account
            List<PartnerMarketingBudget> existingpmbList = [SELECT Id, Core_MDF_Budget_Partner__c, StartDate, EndDate, Core_MDF_Program__c, Core_MDF_Budget_Type__c
                                                            FROM PartnerMarketingBudget WHERE Core_MDF_Budget_Partner__c IN :partnerAccountList
                                                            limit 1000];


            for(PartnerMarketingBudget newpmbRecord :newPMBList) {
                for(PartnerMarketingBudget existingpmbRecord :existingpmbList) {
                    if(validatePmbWithOverlapAndDupCheck(newpmbRecord, existingpmbRecord) && (newpmbRecord.StartDate == existingpmbRecord.StartDate
                        && newpmbRecord.EndDate == existingpmbRecord.EndDate)) {
                        //Duplicate budget error
                        newpmbRecord.addError(Label.Core_MDF_PMBDuplicateError);
                    } else if(validatePmbWithOverlapAndDupCheck(newpmbRecord, existingpmbRecord) &&
                                    checkOverlapBudget(newpmbRecord, existingpmbRecord)) {
                        //Overlapping budget error
                        newpmbRecord.addError(Label.Core_MDF_PMBOverlapError);
                    }
                }
            }
        } 
        catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); } // JV- Accenture : Add the exception into Core_Log_Entry Object
    }

    /*****************************************************************************************************
     Method Name:        checkPMBDuplicateRecordsOnUpdate
     @return  :          void
     @parameters:        newPMBList - This will contain all the pmb records to be updated.
     oldPMBMap -  Map of the old Partner Marketing Budget.
     Description:        Whenever a record is updated of Partner Marketing object, this method checks whether the current record is duplicate or not
     @Added By:          Accenture - AD - 12/21/2018
     Modified By:        Date:       Changes:
     ******************************************************************************************************/
    public static void checkPMBDuplicateRecordsOnUpdate(List<PartnerMarketingBudget> newPMBList, Map<Id, PartnerMarketingBudget> oldPMBMap) {
        //To store PMB which to be processed for duplicate check
        List<PartnerMarketingBudget> pmbToBeProcessedForDupCheck = new List<PartnerMarketingBudget>();
        try{
            for(PartnerMarketingBudget newPmbRecord :newPMBList) {
                if(newPmbRecord.Core_MDF_Budget_Partner__c != oldPMBMap.get(newPmbRecord.ID).Core_MDF_Budget_Partner__c
                   || newPmbRecord.StartDate != oldPMBMap.get(newPmbRecord.ID).StartDate ||newpmbRecord.EndDate != oldPMBMap.get(newPmbRecord.ID).EndDate
                   || newPmbRecord.Core_MDF_Program__c != oldPMBMap.get(newPmbRecord.ID).Core_MDF_Program__c
                   || newpmbRecord.Core_MDF_Budget_Type__c != oldPMBMap.get(newPmbRecord.ID).Core_MDF_Budget_Type__c) {
                    pmbToBeProcessedForDupCheck.add(newPmbRecord);
                }
            }
            if(pmbToBeProcessedForDupCheck != null && pmbToBeProcessedForDupCheck.size() > 0) {
                //Invoke method to check duplicate and overlapping budgets
                checkPMBDuplicateRecords(pmbToBeProcessedForDupCheck);
            }

        } catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); }
    }

    /*****************************************************************************************************
     Method Name:        validateDecreasedBudgetAmount
     @return  :          void
     @parameters:        newPMBList - This will contain all the pmb records to be updated.
     Description:        This method is validating the decrease budget amount with corp allocated amount
     @Added By:          Accenture - AD - 3/20/2019
     Modified By:        Date:       Changes:
     ******************************************************************************************************/
    public static void validateDecreasedBudgetAmount(Map<Id, PartnerMarketingBudget> newPmbToBeProcessed, Map<Id, PartnerMarketingBudget> oldPMBMap) {
        try{
            system.debug('newPmbToBeProcessed- inside validation ' + newPmbToBeProcessed);
            system.debug('newPmbToBeProcessed size- inside validation ' + newPmbToBeProcessed.size());
            //Map of budget record Ids and related budget allocations
            List<PartnerMarketingBudget> pmbToBeProcessed = new List<PartnerMarketingBudget>();
            for(PartnerMarketingBudget pmb :newPmbToBeProcessed.values()) {
                /*if(pmb.Core_MDF_Decrease_Budget_Amount_Amt__c != oldPMBMap.get(pmb.ID).Core_MDF_Decrease_Budget_Amount_Amt__c) {*/
                if(pmb.Core_MDF_Decrease_Budget_Amount_Amt__c != oldPMBMap.get(pmb.ID).Core_MDF_Decrease_Budget_Amount_Amt__c || pmb.Core_MDF_Budget_Status__c !=oldPMBMap.get(pmb.ID).Core_MDF_Budget_Status__c ) {
                    pmbToBeProcessed.add(pmb);
                }
            }
            if(pmbToBeProcessed != null && pmbToBeProcessed.size() > 0) {
                Map<Id, PartnerMarketingBudget> existingBudgetAllocations = new Map<Id, PartnerMarketingBudget>([select Id, (select id, Core_MDF_Available_Allocation_Amount__c, ChannelPartnerId from PartnerFundAllocations) from PartnerMarketingBudget where Id IN :pmbToBeProcessed]);
                for(PartnerMarketingBudget pmb :pmbToBeProcessed) {
                    //checking map values
                    if(existingBudgetAllocations.containsKey(pmb.Id) && (existingBudgetAllocations.get(pmb.Id).PartnerFundAllocations) != null) {
                        for(PartnerFundAllocation alloc :existingBudgetAllocations.get(pmb.Id).PartnerFundAllocations) {
                            if(pmb.Core_MDF_Budget_Partner__c == alloc.ChannelPartnerId && (pmb.Core_MDF_Decrease_Budget_Amount_Amt__c != null &&
                               pmb.Core_MDF_Decrease_Budget_Amount_Amt__c > alloc.Core_MDF_Available_Allocation_Amount__c)
                               && (pmb.Core_MDF_Budget_Status__c == Label.Core_MDF_Budget_Status_Approved ||
                                   pmb.Core_MDF_Budget_Status__c == Label.Core_MDF_Budget_Status_Released)) {
                                //set error
                                pmb.addError(Label.Core_MDF_Budget_Decrease_Amount);
                                break;
                            }
                        }
                    }
                }
            }

        } 
        catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); }
    }

    /*****************************************************************************************************
     Method Name:        validatePmbWithOverlapAndDupCheck
     @return  :          boolean
     @parameters:        newpmbRecord - This will contain all new pmb records
     existingpmbRecord - This will contain all existing pmb records corresponding to budget partner
     Description:        This method is used to validate common conditions to check duplicate and overlap budget
     @Added By:          Accenture - AD - 7/30/2019
     Modified By:        Date:       Changes:
     ******************************************************************************************************/

    public static boolean validatePmbWithOverlapAndDupCheck(PartnerMarketingBudget newpmbRecord, 
                                                            PartnerMarketingBudget existingpmbRecord) {
        //flag to hold result
        Boolean isValid = false;
        if(newpmbRecord != null && existingpmbRecord != null && existingpmbRecord.Id != newpmbRecord.Id &&
                                                                    newpmbRecord.Core_MDF_Budget_Partner__c == existingpmbRecord.Core_MDF_Budget_Partner__c &&
                                                                    newpmbRecord.Core_MDF_Program__c == existingpmbRecord.Core_MDF_Program__c &&
                                                                    newpmbRecord.Core_MDF_Budget_Type__c == existingpmbRecord.Core_MDF_Budget_Type__c) {
            isValid = true;
        }
        return isValid;
    }
    
    /*****************************************************************************************************
     Method Name:        checkOverlapBudget
     @return  :          boolean
     @parameters:        newpmbRecord - This will contain all new pmb records
     existingpmbRecord - This will contain all existing pmb records corresponding to budget partner
     Description:        This method is used to validate condition to check overlap budget
     @Added By:          Accenture - AD - 7/30/2019
     Modified By:        Date:       Changes:
     ******************************************************************************************************/
    public static boolean checkOverlapBudget(PartnerMarketingBudget newpmbRecord, 
                                             PartnerMarketingBudget existingpmbRecord) {
        //flag to hold result
        Boolean isValid = false;
        if((newpmbRecord != null && existingpmbRecord != null) && ((newpmbRecord.StartDate == existingpmbRecord.EndDate || newpmbRecord.EndDate == existingpmbRecord.StartDate) || (newpmbRecord.StartDate > existingpmbRecord.StartDate && newpmbRecord.EndDate < existingpmbRecord.EndDate) || (newpmbRecord.StartDate > existingpmbRecord.StartDate && newpmbRecord.StartDate < existingpmbRecord.EndDate && newpmbRecord.EndDate > existingpmbRecord.EndDate) || (newpmbRecord.StartDate == existingpmbRecord.StartDate && ((newpmbRecord.EndDate > existingpmbRecord.StartDate && newpmbRecord.EndDate < existingpmbRecord.EndDate)
                                                    || newpmbRecord.EndDate > existingpmbRecord.EndDate)) || (newpmbRecord.EndDate == existingpmbRecord.EndDate && ((newpmbRecord.StartDate > existingpmbRecord.StartDate && newpmbRecord.StartDate < existingpmbRecord.EndDate)
                                                    || newpmbRecord.StartDate < existingpmbRecord.StartDate)) || (newpmbRecord.StartDate < existingpmbRecord.StartDate && ((newpmbRecord.EndDate > existingpmbRecord.StartDate && newpmbRecord.EndDate < existingpmbRecord.EndDate) || newpmbRecord.EndDate > existingpmbRecord.EndDate)))) {
            isValid = true;
        }
        return isValid;
    }

    /*****************************************************************************************************
     Method Name:        invokeBudgetShareRecordToGeoGroup
     @return  :          void
     @parameters:        List of Budget record
     Description:        This is invocable method to perform Geo Based Sharing for a Budget record
     Added By:           Accenture-VD
     Date :                04-Nov-2019
     Modified By:        Date:       Changes:
     *****************************************************************************************************/
    @InvocableMethod
    public static void invokeBudgetShareRecordToGeoGroup(List<PartnerMarketingBudget> listOfPMB) {
        //To share record on the basis of Channel Program and geo
        List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();
        //To store account ids from Partner Marketing Budget
        List<Id> accountIds = new List<Id>();
        //Map of account id and account
        Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>();
        //To store program ids
        List<Id> programIds = new List<Id>();
        //Map of channel Program id and technical program name
        Map<Id, String> cpIdToTechProgNameMap = new Map<Id, String>();
        try{
            for(PartnerMarketingBudget pmb :listOfPMB) {
                //Getting all the accounts from Budget List
                accountIds.add(pmb.Core_MDF_Budget_Partner__c);
                //storing program ids of accounts
                programIds.add(pmb.Core_MDF_Program__c);
            }
            for (Account acc :[Select Id, Core_Geo__c, Core_Sub_Geo__c, Core_MDF_Channel_Program__c, Core_MDF_CoMarketing_Ultimate_Account__c from Account where id IN :accountIds]) {
                //To get account's geo and subgeo field
                accountIdToAccountMap.put(acc.Id, acc);
            }
            //Iterating to get channel program technical program name
            for (ChannelProgram cp :[Select Id, Name, Core_MDF_Technical_Program_Name__c from ChannelProgram where id IN :programIds]) {
                cpIdToTechProgNameMap.put(cp.Id, cp.Name);
            }
            for(PartnerMarketingBudget pmbObj :listOfPMB) {
                Account account = accountIdToAccountMap.get(pmbObj.Core_MDF_Budget_Partner__c);
                recordGeoShareList.add(new Core_MDF_RecordGeoShare(pmbObj.id, account.Core_Geo__c, account.Core_Sub_Geo__c, cpIdToTechProgNameMap.get(pmbObj.Core_MDF_Program__c)));
            }
            //To share record on the basis of Channel Program and geo
            if(recordGeoShareList != null && recordGeoShareList.size() > 0) {
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('PartnerMarketingBudget', recordGeoShareList);
            } 
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
}