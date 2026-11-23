/***************************************************************************************************************************************
Apex Class Name     : PRM_BatchToAssignAWRBenefits 
Version             : 1.0
Created Date        : May 2026
Function            : Batch class to AWR Benefits.
Maximum Batch Size  : 100
Modification Log    : 
* Developer                         Date                           Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------
* Utkarsh                        May-2026                     Start Method returns all the PAG accounts which has total sales value greater then 50000 **********************************************/
global class PRM_BatchToAssignAWRBenefits implements Database.Batchable<SObject>, Database.Stateful {

    public String logEntryMsgString='';
    public List<PRM_IPA_DQ_Logs__c> dqLogList = new List<PRM_IPA_DQ_Logs__c>();
    global boolean assignEntitlement = false;
    global Set<String> onePartnerIds = new Set<String>();
    global String currentTimePeriod = System.Label.PRM_Current_measurement_period;
    global Set<Id> successfulBenefitAssignments = new Set<Id>();
    global Decimal totalSales = Decimal.valueOf(System.Label.PRM_Total_Sales_Out_Threshold);
    
    global Iterable<AggregateResult> start(Database.BatchableContext bc) {
        return [SELECT PRM_One_Partner_Id__c accountId,SUM(PRM_Sales_Amount_Nbr__c) totalSales FROM PRM_Value_Exchange_Data__c WHERE PRM_TimePeriod_Nm__c =:currentTimePeriod GROUP BY PRM_One_Partner_Id__c HAVING SUM(PRM_Sales_Amount_Nbr__c) >:totalSales
        ];
    }

    global void execute(Database.BatchableContext bc,List<AggregateResult> scope)  {
        logEntryMsgString+='Inside execute method, scope: '+scope;
        PRM_BatchCustomSetting__c batchCustomSetting;
        List<Id> opidList = new List<Id>();
        List<String> benefits = new List<String>();
        Set<String> partnerIdsWithActiveBenefit = new Set<String>();
        List<PRM_AccountBenefitAssociation__c> abaRecordsToUpsert = new List<PRM_AccountBenefitAssociation__c>();
        List<String> benefitIds = new List<String>();
        List<PRM_Value_Exchange_Data__c> VxDataList = new List<PRM_Value_Exchange_Data__c>();
        Map<Id, PRM_AccountBenefitAssociation__c> existingABAByAccount = new Map<Id, PRM_AccountBenefitAssociation__c>();
        
        //Query on BatchCustomSetting to fetch batch size, Partner type, scheduling hour, channel program level
        batchCustomSetting = [Select Id, Name, PRM_NoOfRecords__c, PRM_Manual_Benefits__c,PRM_SchedulingHour__c,PRM_PartnerType__c,PRM_ChannelProgramLevel__c,PRM_Total_sales_value__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues];
        benefits = batchCustomSetting.PRM_Manual_Benefits__c.split(';');
        
        //System.debug('benefits :'+benefits);
        try{
            //Get One partner id list.
            for (AggregateResult ar : scope) {
                opidList.add((Id) ar.get('accountId'));
            }
            if(opidList != null && !opidList.isEmpty()){
                VxDataList = [SELECT Id,PRM_Account_Id__c,PRM_Change_Date_Dt__c,PRM_Country_Market_Type_Nm__c,PRM_From_Dt__c,PRM_IsChanged_Ind__c,PRM_One_Partner_Id__c,PRM_Processed_Date_Time_Dt__c,PRM_Sales_Amount_Nbr__c,PRM_Sales_Amount_Report_Nbr__c,PRM_Total_Sales_Out_Units_Nbr__c,PRM_Total_Sales_Out_Units_Report_Nbr__c,PRM_Value_Exchange_ext_id__c,PRM_TimePeriod_Nm__c,PRM_One_Partner_Id__r.Core_IPA_Badge_Tier__c,PRM_Sum_of_Training_Credits__c
                FROM PRM_Value_Exchange_Data__c WHERE PRM_One_Partner_Id__c IN :opidList];
            }
            if(VxDataList != null && !VxDataList.isEmpty()){
                for (PRM_Value_Exchange_Data__c rec : VxDataList) {
                    if (String.isNotBlank(rec.PRM_One_Partner_Id__c) && String.isNotBlank(rec.PRM_One_Partner_Id__r.Core_IPA_Badge_Tier__c)) {
                        onePartnerIds.add(rec.PRM_One_Partner_Id__c);
                    }
                }
            }
            //System.debug('onePartnerIds :'+onePartnerIds);
            //Get partner benefit id list.
            if(benefits != null && !benefits.isEmpty()){
                for (PRM_PartnerBenefit__c bnft : [select Id/*,Name,PRM_Benefit_Dsc__c,PRM_Benefit_Type_Nm__c,PRM_Benefit_Cd__c*/ from PRM_PartnerBenefit__c where Name IN :benefits]) {//ATHR Fix - TWC729-9556
                    benefitIds.add(bnft.Id);
                }
                //System.debug('benefitIds :'+benefitIds);
            }
            if((onePartnerIds != null && !onePartnerIds.isEmpty()) &&(benefitIds != null && !benefitIds.isEmpty())){
                for (PRM_AccountBenefitAssociation__c aba : [SELECT Id,PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Badge_Tier__c,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c,PRM_Source__c,PRM_Partner_Benefit_Id__c FROM PRM_AccountBenefitAssociation__c WHERE PRM_Account_Id__c IN :onePartnerIds AND PRM_Partner_Benefit_Id__c IN :benefitIds AND PRM_Account_Id__r.Core_IPA_Badge_Tier__c != '']) {
                    partnerIdsWithActiveBenefit.add(aba.PRM_Account_Id__c);
                    existingABAByAccount.put(aba.PRM_Account_Id__c,aba);
                }
                //System.debug('partnerIdsWithActiveBenefit :'+partnerIdsWithActiveBenefit);
                //System.debug('existingABAByAccount :'+existingABAByAccount);
            }
            /*Utkarsh - TWC729-9308 - Start - Populate source field while creating and updating AWR benefit record and enhance logic to update status of existing ABA to true*/
            for (String partnerId : onePartnerIds) {
                PRM_AccountBenefitAssociation__c newABA = new PRM_AccountBenefitAssociation__c();
                if (existingABAByAccount.containsKey(partnerId)) {// Existing ABA found
                    PRM_AccountBenefitAssociation__c existingABA = existingABAByAccount.get(partnerId);
                    if (existingABA.PRM_Status_Nm__c == 'Inactive') {
                        existingABA.PRM_Status_Nm__c = 'Active';
                        existingABA.PRM_Source__c = 'Tier';
                        existingABA.PRM_Status_Reason_Txt__c = System.Label.PRM_AWR_Assignment_Reason;
                        abaRecordsToUpsert.add(existingABA);
                    }

                } else {
                    newABA.PRM_Account_Id__c = partnerId;
                    newABA.PRM_Partner_Benefit_Id__c = benefitIds[0];
                    newABA.PRM_Source__c = 'Tier';
                    newABA.PRM_Status_Nm__c = 'Active';
                    newABA.PRM_Status_Reason_Txt__c = System.Label.PRM_AWR_Assignment_Reason;
                    abaRecordsToUpsert.add(newABA);
                }
            }
            /*Utkarsh - TWC729-9308 - END*/
            //System.debug('abaRecordsToUpsert :'+abaRecordsToUpsert);
            Database.UpsertResult[] results = Database.upsert(abaRecordsToUpsert, false);
            for(Integer i = 0; i < results.size(); i++) {
                if(results[i].isSuccess()) {
                    successfulBenefitAssignments.add(
                        abaRecordsToUpsert[i].PRM_Account_Id__c
                    );
                }
            }
            if(abaRecordsToUpsert != null && !abaRecordsToUpsert.isEmpty()){
                assignEntitlement = true;
                PRM_accBenefitAssociationUtility.onManualBenefitInsert(abaRecordsToUpsert,null,assignEntitlement);
            }
            if(successfulBenefitAssignments != null && !successfulBenefitAssignments.isEmpty()){
                for(Id partner :successfulBenefitAssignments){
                    PRM_IPA_DQ_Logs__c dqLog = new PRM_IPA_DQ_Logs__c();
                    dqLog.PRM_Object_Name__c='PRM_AccountBenefitAssociation__c'+partner;
                    dqLog.PRM_Message__c = 'Records will be inserted/updated as part of PRM_BatchToAssignAWRBenefits processing.';
                    dqLog.PRM_Apex_Class_Name__c = 'PRM_BatchToAssignAWRBenefits';
                    dqLogList.add(dqLog);
                }
            }
            
            logEntryMsgString += '\n[AWR benefit assigned] Using PRM_BatchToAssignAWRBenefits for ' + 'PRM_AccountBenefitAssociation__c' + ' with ' + abaRecordsToUpsert.size() + ' records';
        }
        catch (Exception ex) {
            logEntryMsgString += '\n[AWR benefit assignment failed] ' + ex.getMessage();
            //System.debug('Benefits created: ' + abaRecordsToUpsert.size());
        } 
    }

    global void finish(Database.BatchableContext bc) {
        try{
            List<Database.SaveResult> dqResultList = Database.insert(dqLogList,false);
            for(Database.SaveResult dqResult: dqResultList){
                if(!dqResult.isSuccess()){
                    for (Database.Error err : dqResult.getErrors()) {
                        logEntryMsgString+= 'Message: ' + err.getMessage() + '\n'  + 'Fields: ' + err.Fields.toString() + '\n' + 'StatusCode: ' + err.getStatusCode() + '\n';
                    }
                }
            }
        }
        catch(Exception ex){
            logEntryMsgString='\n errors:'+ex;
        }
        string jobInitiatedDateTime = System.Now().format('MM/dd/YYYY HH:MM:SS','PST');
        if(logEntryMsgString!=''){// this block will create Log Entry records on the basis of length of logEntryMsg and Field limit.
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
            for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
                Core_Log_Entry.logEntryWithDetails('PRM_BatchToAssignAWRBenefits', 'IPA', 'PRM_BatchToAssignAWRBenefits', 'Medium','Job started at: '+ jobInitiatedDateTime +' PST' ,logEntryUtility.logEntryList[i] , '', '', '');
            }//loop ends here..
        }

    }
}