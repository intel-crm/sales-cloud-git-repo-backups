/***************************************************************************************************************************************
Apex Class Name     : PRM_BenefitsUpdateBatch
    Version             : 1.0
    Created Date        : Feb 2019
    Function            : Batch class to assign Benefits.
    Maximum Batch Size  : 100
    Modification Log    :
     * Developer                         Date                           Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 * Utkarsh                        8-Feb-2019                     Start Method returns all the accounts which are modified in Last specified number of hours.
 * Bharath                        8-Sep-2020                     US773368 - To accomodate the logic to delete VX Data Records on ACM Inactivation.
 *************************************************************************************************************************************************************/
global class PRM_BenefitsUpdateBatch implements Database.Batchable<sObject>,Database.Stateful{
    public static String ORIGIN  = 'PRM_BenefitUtility';
    public static String SEVERITY  = 'Info';
    public static String PROJECT  = 'IPA';
    public static String ERRORMESSAGE  = 'Too many DML rows';
    public static boolean sourceCheck = true;
    public static boolean assignOnlyEntitlement = true;
    public static boolean isAdminProcess = true;
    // public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh);  //IPA2.0-TWC727-2861 // IPA Switch Removal
    public static boolean ipadataMigrationBypass = Boolean.valueOf(label.PRM_IPA_Data_migration_bypass);  //IPA2.0-TWC727-2861
    global static Database.QueryLocator start(Database.BatchableContext context){
        String logEntryMsgString='';
        logEntryMsgString+='\nPRM_BenefitsUpdateBatch start method invoked at:'+System.Now().format('MM/dd/YYYY HH:MM:SS','PST')+' PST dt@@@';
        DateTime lastSuccessfulRun;
        Set<String> accountRecordType = new Set<String>{System.Label.PRM_Intel_Account,System.Label.PRM_Partner_Account_Group_Record_Type};
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        List<PRM_Account_Specialty_Association__c> asaList = new List<PRM_Account_Specialty_Association__c>();
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        Set<Id> accIdSet = new Set<Id>();
        PRM_BatchCustomSetting__c batchCustomSetting;
        List<String> cpl = new List<String>();
        //Query on BatchCustomSetting to fetch batch size, Partner type, scheduling hour, channel program level
        batchCustomSetting = [Select Id, Name, PRM_NoOfRecords__c, PRM_SchedulingHour__c,PRM_PartnerType__c,PRM_ChannelProgramLevel__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues];
        cpl = batchCustomSetting.PRM_ChannelProgramLevel__c.split(';');
        Integer batchExecutionInterval = batchCustomSetting.PRM_SchedulingHour__c.intValue();
        DateTime batchExecutionHours = System.Now().addHours(- batchExecutionInterval);
        //Query on AsyncApexJob to get the identical records which got modified in last 6 hrs.
        List<AsyncApexJob> lastBatchRun = [SELECT CompletedDate FROM AsyncApexJob WHERE ApexClass.Name = :System.Label.PRM_Benefit_Update_Batch AND Status =:System.Label.PRM_AsyncStatus Order By CompletedDate DESC LIMIT 1];
        if(lastBatchRun != NULL && !lastBatchRun.IsEmpty()){lastSuccessfulRun = (DateTime)lastBatchRun[0].CompletedDate;
            //Query on Account channel membership which got modified in last 6 hrs, channel program as IPA , Channel program level as gold or platinum, status as approved.
            //Bharath - US773368 - Removed Status and Channel Program Level filters on the below query and handled the filters in the utility class.
            if(ipadataMigrationBypass ){
                acmList = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c,PRM_Account_Id__r.Core_Covered_Account__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c From PRM_AccountChannelMembership__c Where PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance  AND (LastModifiedDate > :batchExecutionHours OR LastModifiedDate > :lastSuccessfulRun) and lastmodifiedby.name !='IPA Data Migration User'];
            }else{
                acmList = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c,PRM_Account_Id__r.Core_Covered_Account__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c From PRM_AccountChannelMembership__c Where PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance  AND (LastModifiedDate > :batchExecutionHours OR LastModifiedDate > :lastSuccessfulRun) ];
            }
            /* UTKARSH - DE69552 and US596757 - 27-02-2020 - As discussed with Lakshman,removed 'Core_Account_Type__c - Biz Org Type' from ACM query as we don’t need to consider ‘Biz Org Type’field value on Account*/
            
            /*US687673 - Start - Need to consider ASA record which got recently modified*/
            asaList = [Select Id, PRM_Account_Id__c, PRM_Account_Id__r.Name,PRM_Specialty_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c From PRM_Account_Specialty_Association__c Where PRM_InActive_Ind__c = false AND (LastModifiedDate > :batchExecutionHours OR LastModifiedDate > :lastSuccessfulRun)];
            /*US687673 - END*/
            acrList = [Select Id, PRM_Account_Id__c, PRM_Account_Id__r.Name,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_InActive_Ind__c = false  AND (LastModifiedDate > :batchExecutionHours OR LastModifiedDate > :lastSuccessfulRun)];
        }else{
            //Query on Account channel membership which got modified in last 6 hrs, channel program as IPA , Channel program level as gold or platinum, status as approved.
            //Bharath - US773368 - Removed Status and Channel Program Level filters on the below query and handled the filters in the utility class.
            if(ipadataMigrationBypass){
                acmList = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c,PRM_Account_Id__r.Core_Covered_Account__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c From PRM_AccountChannelMembership__c Where PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND LastModifiedDate > :batchExecutionHours and lastmodifiedby.name !='IPA Data Migration User'];
            }else{
                acmList = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c,PRM_Account_Id__r.Core_Covered_Account__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c From PRM_AccountChannelMembership__c Where PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND LastModifiedDate > :batchExecutionHours ];
            }
            /* UTKARSH - DE69552 and US596757 - 27-02-2020 - As discussed with Lakshman,removed 'Core_Account_Type__c - Biz Org Type' from ACM query as we don’t need to consider ‘Biz Org Type’field value on Account*/
            /*US687673 - Start - Need to consider ASA record which got recently modified*/
            asaList = [Select Id, PRM_Account_Id__c, PRM_Account_Id__r.Name,PRM_Specialty_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c From PRM_Account_Specialty_Association__c Where PRM_InActive_Ind__c = false AND LastModifiedDate > :batchExecutionHours];
            /*US687673 - END*/
            acrList = [Select Id, PRM_Account_Id__c, PRM_Account_Id__r.Name,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_InActive_Ind__c = false  AND LastModifiedDate > :batchExecutionHours];
        }
        if(acmList != NULL && !acmList.IsEmpty()){
            for(PRM_AccountChannelMembership__c acm :acmList){
                accIdSet.add(acm.PRM_Account_Id__c);
            }
        }
        if(acrList != NULL && !acrList.IsEmpty()){
            for(PRM_Account_Contact_Relationship__c acr :acrList){
                accIdSet.add(acr.PRM_Account_Id__c);
            }
        }
        /*US687673 - Start - Need to consider ASA record which got recently modified*/
        /*if(asaList != NULL && !asaList.IsEmpty() && (!ipaRefresh  || test.isrunningtest())){ //IPA2.0-TWC727-2861
            for(PRM_Account_Specialty_Association__c asa :asaList){
                accIdSet.add(asa.PRM_Account_Id__c);
            }
        } */// IPA Switch Removal
        /*US687673 - END*/
        logEntryMsgString+='\n\naccIdSet identified:'+JSON.serialize(accIdSet);
        logEntryMsgString+='\n\nlastSuccessfulRun identified:'+lastSuccessfulRun;
        PRM_IPA_Utility.createLogEntry(logEntryMsgString, 'PRM_BenefitsUpdateBatch', 'IPA', null, 'info', '');
        // if(lastBatchRun != NULL && !lastBatchRun.IsEmpty()){
            //Query on Account which got modified in last 6 hrs, record type as Intel Account ,partner type as CSP.
            return database.getQueryLocator('Select Id, Name,Core_Covered_Account__c,Core_IPA_Partner_Role__c,LastModifiedDate,RecordTypeId,RecordType.Name,RecordType.DeveloperName From Account Where Id IN :accIdSet');
            /* UTKARSH - DE69552 and US596757 - 27-02-2020 - As discussed with Lakshman,removed 'Core_Account_Type__c - Biz Org Type' from Account query as we don’t need to consider ‘Biz Org Type’field value on Account*/
        // }else{
            //         //Query on Account which got modified in last 6 hrs, record type as Intel Account ,partner type as CSP.
            //     return database.getQueryLocator('Select Id, Name,Core_Covered_Account__c,Core_IPA_Partner_Role__c,LastModifiedDate,RecordTypeId,RecordType.Name,RecordType.DeveloperName From Account Where Id IN :accIdSet OR (RecordType.DeveloperName IN :accountRecordType AND LastModifiedDate > :batchExecutionHours )');
            //     /* UTKARSH - DE69552 and US596757 - 27-02-2020 - As discussed with Lakshman,removed 'Core_Account_Type__c - Biz Org Type' from Account query as we don’t need to consider ‘Biz Org Type’field value on Account*/
        // }
    }
    global void execute(Database.BatchableContext context, List<Account> scope){
        String logEntryMsgString='';
        logEntryMsgString+='\nPRM_BenefitsUpdateBatch execute method invoked at:'+System.Now().format('MM/dd/YYYY HH:MM:SS','PST')+' PST dt@@@';
        logEntryMsgString+='\n\nScope for execute method:'+scope;
        try{
            logEntryMsgString+='\n\ncalling assignBenefitsAndEntitlements method';
            PRM_benefitUtility.logEntryMsgString = logEntryMsgString;
            PRM_benefitUtility.assignBenefitsAndEntitlements((List<Account>)scope,sourceCheck,assignOnlyEntitlement,isAdminProcess); //Calling utility class with list of account as parameter.
        }catch(Exception exp){
            logEntryMsgString+='\n\nException occurred:'+exp.getMessage() + '-' + exp.getStackTraceString();
            PRM_IPA_Utility.createLogEntry(logEntryMsgString, 'PRM_BenefitsUpdateBatch', 'IPA', null, 'error', '');
        }
    }
    global void finish(Database.BatchableContext context){
        /*
        PRM_BatchCustomSetting__c bm = [Select Id, Name, PRM_NoOfRecords__c,PRM_SchedulingHour__c,PRM_NoOfBatchEntRecords__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues LIMIT 1];
        Integer a=bm.PRM_NoOfBatchEntRecords__c.intValue();
        Database.executeBatch(new PRM_Contact_Entitlements_Insert_batch(), a); // Calling another batch class to assign entitlements.
         */
    }
}