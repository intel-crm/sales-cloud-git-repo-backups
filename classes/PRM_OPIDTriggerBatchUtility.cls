/***************************************************************************************************************************************
Apex Class Name     : PRM_OPIDTriggerBatchUtility
Version             : 1.01
Created Date        : March 2020
Function            : Utility class for PRM_OPIDTriggerBatch.
Maximum Batch Size  :
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                       4-March-2020                      US599996- Used for execute method PRM_OPIDTriggerBatch 
* Srishty                       24-March-2020                    US570458-Added Method for Upgrade Recommendation and also optimised

* Srishty                       3-April-2020                     US619504-Added aggregate logic for qunatitave criteria.
Also, updated logic for qualitative criteria for Upgrade recommendation.    
the code.
* Srishty                       9-April-2020                     US617760-Added Method that will calculate the total percentage
criteria pending for Next tier for VX Data
*Srishty                        24-April-2020                    US643150-Added Total Nbr Achieved Competency field and replaced Competency Achieved field from VX data and VX Recommendation
*Srishty                        4-May-2020                       US638610,US632701-Added logic for Select Benefit ,Specialty Present and Total Nbr Achieved Competency criterias for Upgrade Recommendation 
*Srishty                        4-May-2020                       US638612-Added logic for recommendation where different VX Data record have same account,partner role ,market type and Tier but with different Sales Type values(Sales Calculation Group)
*Srishty                        13-May-2020                      Scope result was optimised by using PRM_IsChanged_Ind__c formula field which will return 
only those records which needs to be processed and vxDataCompleteList will have all VXData with those One Partner ID which was part of Scope.
*Srishty                        8-June-2020                      US687613-Qualittaive boolean Fields which is getting updated through batch in Recommendation converted into picklist value. 
*Srishty                        8-June-2020                      DE80439-Specialty Present Field on VX Recommendation will be "Yes" when corresponding VX Data account ASA record have Specialty type record of same partner Role.
*Srishty                        11-June-2020                     DE81848-Added else condition when there is only one Rank available.
*Srishty                        12-June-2020                     PRM_FPGA_Project_Registration_Count_Nbr__c replaced by PRM_Design_Registration_Count_Nbr__c field.
*Srishty             31-August-2020            DE90355 : OPID Recommendation - multiple OPID recommendations should not be created for an account with same partner role but having
multiple sales groups
* Ruchi                         18 July 2025                 Removed reference for Partner role(PRM_Partner_Role_Nm__c) on VX Data Table(PRM_Value_Exchange_Data__c). Added comment "IPA Refresh 2.0 - Removed partner role as part of TWC729-8087"
*************************************************************************************************************************************/
public without sharing class PRM_OPIDTriggerBatchUtility
{
    private static Map<string, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
    @TestVisible
    private static final string ORIGIN = 'PRM_OPIDTriggerBatchUtility';
    private static final string SEVERITY = 'Critical';
    private static final string PROJECT = 'IPA';
    private static final string ERROR_MESSAGE = 'Too many DML rows';
    @TestVisible
    private static final string OPID_RECOMMENDATION_TYPE = 'OPID';
    @TestVisible
    private static final string UPGRADE_RECOMMENDATION_TYPE = 'Upgrade';
    @TestVisible
    private static final string RECOMMENDATION_STATUS_NEW = 'New';
    private static final string RECOMMENDATION_STATUS_PROCESSED='Processed';
    private static final string RECOMMENDATION_STATUS_INPROCESSED='In Process';
    private static final string RECOMMENDATION_STATUS_OPIDINPROCESS='OPID In Process';
    private static final string RECOMMENDATION_STATUS_OPIDCREATED='OPID Created';
    private static final string RECOMMENDATION_STATUS_REJECTED='Rejected';
    private static final string YES='Yes';
    private static final string NO='No';
    private static final string NA='NA';
    
    private static Map<string, PRM_Value_Exchange_Criteria_Association__c> vxCriteriaAssociationSalesMap = new  Map<string, PRM_Value_Exchange_Criteria_Association__c>();
    private static Map<string, List<PRM_Value_Exchange_Criteria_Association__c>> vxCriteriaAssociationAllRankSalesMap = new  Map<string, List<PRM_Value_Exchange_Criteria_Association__c>>();
    private static Map<string, PRM_Value_Exchange_Criteria_Association__c> vxCriteraiAssociationTrainingMap = new Map<string, PRM_Value_Exchange_Criteria_Association__c>();
    private static Map<string, PRM_Value_Exchange_Criteria_Association__c> vxCriteriaAssociationSolutionMap = new  Map<string, PRM_Value_Exchange_Criteria_Association__c>();
    private static Map<string, PRM_Value_Exchange_Criteria_Association__c> vxCriteraiAssociationEmployeeMap = new Map<string, PRM_Value_Exchange_Criteria_Association__c>();
    private static Map<string, PRM_Value_Exchange_Criteria_Association__c> vxCriteraiAssociationRegistrationMap = new Map<string, PRM_Value_Exchange_Criteria_Association__c>();
    private static Map<string, PRM_Value_Exchange_Criteria_Association__c> vxCriteraiAssociationTotalCompetencyMap = new Map<string, PRM_Value_Exchange_Criteria_Association__c>();
    private static Map<string, Decimal> vxCriteraiAssociationQuantativeTotalMap = new Map<string, Decimal>();
    private static Map<String, List<PRM_Value_Exchange_Criteria_Association__c>> vxCriteriaAssociationMap = new Map<String, List<PRM_Value_Exchange_Criteria_Association__c>>();
    private static Map<String,AggregateResult> groupByOPIDAggregateMapForOpid=new Map<String,AggregateResult>();
    private static Map<String,Map<String,Decimal>> groupByOPIDAggregateMapForUpgrade=new Map<String,Map<String,Decimal>>();
    private static Map<String,String> tierMap = new Map<String,String>();
    //public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh);  //IPA2.0-TWC727-2861
    public PRM_OPIDTriggerBatchUtility(List<PRM_Value_Exchange_Data__c> scope){
        List<PRM_Value_Exchange_Data__c> vxDataList=new List<PRM_Value_Exchange_Data__c> ();
        List<PRM_Value_Exchange_Data__c> vxDataUpgradeList=new List<PRM_Value_Exchange_Data__c> ();
        List<PRM_Value_Exchange_Data__c> vxDataCompleteList=new List<PRM_Value_Exchange_Data__c> ();
        List<PRM_Value_Exchange_Data__c> vxDataCompleteListForOpidReccom=new List<PRM_Value_Exchange_Data__c> ();
        Set<Id> opidSet= new Set<Id>();//OPID set of VX Data record picked by batch in this scope.
        Set<Id> accountIdSet= new Set<Id>();//Account Ids set of VX Data record picked by batch in this scope.
        Set<Id> accountIdForOPIDReccomSet = new Set<Id>();
        for(ChannelProgramLevel tier : [Select Id,Name,Program.Name from ChannelProgramLevel where Program.Name = :System.Label.PRM_Intel_Partner_Alliance]){
            tierMap.put(tier.Name,tier.Id);
        }
        
        for(PRM_Value_Exchange_Data__c vxData:scope){
            accountIdSet.add(vxData.PRM_Account_Id__c);//Set of all the Account Ids related to vx data picked by batch.
            if(vxData.PRM_One_Partner_Id__c == null){
                accountIdForOPIDReccomSet.add(vxData.PRM_Account_Id__c);
                vxDataList.add(vxData);  //List for OPID recommendation
            }
            else{
                vxDataUpgradeList.add(vxData); //List for Upgrade recommendation
                opidSet.add(vxData.PRM_One_Partner_Id__c);
            }
            
        }
        
        for(PRM_Value_Exchange_Data__c vx: [Select Id,PRM_Sales_Amount_Nbr__c,PRM_Total_Achieved_Competency_Nbr__c,PRM_Design_Registration_Count_Nbr__c,PRM_MP_Solutions_Count_Nbr__c,PRM_Number_Of_Employees_Nbr__c,PRM_Type_Of_Solutions_Txt__c,PRM_Country_Market_Type_Nm__c,PRM_One_Partner_Id__c,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.Core_CNDA_Number__c,PRM_Account_Id__r.Core_Covered_Account__c,/*PRM_Partner_Role_Nm__c,*/PRM_Tier_Id__r.Name,PRM_Change_Date_Dt__c,PRM_Processed_Date_Time_Dt__c,PRM_Training_Credit_Points_Count_Nbr__c,PRM_Sales_Calculation_Group_Txt__c,PRM_Revenue_Source_Txt__c 
                                            from PRM_Value_Exchange_Data__c 
                                            Where PRM_One_Partner_Id__c IN:opidSet
                                            OR PRM_Account_Id__c IN:accountIdForOPIDReccomSet
                                            Order by PRM_One_Partner_Id__c] ){ //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                                                if(opidSet.contains(vx.PRM_One_Partner_Id__c) && !vxDataCompleteList.contains(vx)){
                                                    vxDataCompleteList.add(vx);//List containing all VX data with those OPID which is part of Scope result for Qualitative criteria comparison
                                                }
                                                if(vx.PRM_One_Partner_Id__c==null && accountIdForOPIDReccomSet.contains(vx.PRM_Account_Id__c) && !vxDataCompleteListForOpidReccom.contains(vx)){
                                                    vxDataCompleteListForOpidReccom.add(vx);//DE90355-List Containing all VX data without OPID with those Account which is already picked batch including processed and non processed record
                                                }
                                            }
        
        initializeAssociationMap();//populate the criteria association maps for calculation
        populateAggregateMap(accountIdSet,opidSet);// populate the aggregates map for vx data values sum
        
        if(vxDataList.size()>0){
            upsertRecommendations(vxDataList,vxDataCompleteListForOpidReccom);//US599996-for OPID Recommendation Type
        }
        
        if(vxDataUpgradeList.size()>0){
            Map<String,List<PRM_Value_Exchange_Data__c>>  opidVxDataMap =new  Map<String,List<PRM_Value_Exchange_Data__c>>();//Map of OPID with all the VX Data record for same Partne Role,Market Type and Tier
            Set<Id> vxDataForUpgradeIdSet = new Set<Id>();
            for(PRM_Value_Exchange_Data__c vxData:vxDataUpgradeList ){
                vxDataForUpgradeIdSet.add(vxData.Id);
                String key=vxData.PRM_One_Partner_Id__c/*+vxData.PRM_Partner_Role_Nm__c*/ + vxData.PRM_Country_Market_Type_Nm__c +vxData.PRM_Tier_Id__r.Name; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                if(opidVxDataMap.containsKey(key)){
                    List<PRM_Value_Exchange_Data__c> vxDataWithSameOPIDList =opidVxDataMap.get(key);
                    vxDataWithSameOPIDList.add(vxData);
                    opidVxDataMap.put(key,vxDataWithSameOPIDList); //Map for VXData  with list of account with same opid                  
                }
                
                else{
                    List<PRM_Value_Exchange_Data__c> vxDataWithSameOPIDList = new List<PRM_Value_Exchange_Data__c>();
                    vxDataWithSameOPIDList.add(vxData);
                    opidVxDataMap.put(key,vxDataWithSameOPIDList);   
                } 
            }
            upsertRecommendationsForUpgrade(vxDataUpgradeList,opidVxDataMap,vxDataCompleteList,vxDataForUpgradeIdSet);//for Upgrade recommendation
        }
    }
    
    
    
    //US599996-Method will check the list of Value Exchange Data record with Value Exchange Criteria Associations and will upsert record in recommendation for OPID.
    private static void upsertRecommendations(List<PRM_Value_Exchange_Data__c> valueExchangeDataList,List<PRM_Value_Exchange_Data__c> vxDataCompleteListForOpidReccom)
    {  
        Map<Id,PRM_Value_Exchange_Data__c> notQualifiedVXDataMap= new Map<Id,PRM_Value_Exchange_Data__c>();//Map of VX Data not qualified for OPID Recommendation. 
        //Map<String,PRM_Value_Exchange_Recommendation__c> mapOfVXRecWithAggrKey = new Map<String,PRM_Value_Exchange_Recommendation__c>();//DE90355:Map of Aggregated VX data and VX recommendation.
        Decimal valuePercentageResult = 0;
        List<PRM_Value_Exchange_Data__c> valueExchangeDataToUpdateList = new List<PRM_Value_Exchange_Data__c>();
        Decimal rank;
        Set<Id> vxDataForOpidSet = new Set<Id>(); 
        for(PRM_Value_Exchange_Data__c valueExchangeData: valueExchangeDataList)
        {
            vxDataForOpidSet.add(valueExchangeData.Id);
            if(valueExchangeData.PRM_Tier_Id__r.Name == System.Label.PRM_Member && valueExchangeData.PRM_One_Partner_Id__c == null)
            {
                String key = /*valueExchangeData.PRM_Partner_Role_Nm__c +*/ valueExchangeData.PRM_Country_Market_Type_Nm__c + System.Label.PRM_Tier_Gold; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                String aggregateKey = valueExchangeData.PRM_Account_Id__c + /*valueExchangeData.PRM_Partner_Role_Nm__c +*/ valueExchangeData.PRM_Country_Market_Type_Nm__c + valueExchangeData.PRM_Tier_Id__r.Name; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                if(vxCriteriaAssociationAllRankSalesMap.containsKey(key))
                {
                    Boolean flag = true;
                    for(PRM_Value_Exchange_Criteria_Association__c valueExchangeAssociation:vxCriteriaAssociationAllRankSalesMap.get(key))
                    {   
                        valuePercentageResult = (decimal.valueOf(valueExchangeAssociation.PRM_Value_Txt__c.replaceAll(',','')) * decimal.valueOf(Label.PRM_OPID_Percentage)) / 100;
                        if((Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('SalesSum') >= valuePercentageResult)
                        {   
                            flag=true;
                            rank=valueExchangeAssociation.PRM_Rank_Nbr__c;
                            break;
                            
                        }
                        else 
                        {
                            flag=false;
                        }  
                    }
                    if(flag == false){ 
                        //to create records in VX Recommendation for OPID
                     /*   if(!mapOfVXRecWithAggrKey.containsKey(aggregateKey)){//DE90355:only one record will be created in VX recommendation for OPID record type for each Account.
                            PRM_Value_Exchange_Recommendation__c valueExchangeRecommendation = new  PRM_Value_Exchange_Recommendation__c();
                            valueExchangeRecommendation.RecordTypeId = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId();
                            valueExchangeRecommendation.PRM_Account_Id__c = valueExchangeData.PRM_Account_Id__c;
                            valueExchangeRecommendation.PRM_Tier_Id__c = valueExchangeData.PRM_Tier_Id__c;
                            valueExchangeRecommendation.PRM_Partner_Role_Nm__c = valueExchangeData.PRM_Partner_Role_Nm__c;
                            valueExchangeRecommendation.PRM_Market_Type_Nm__c = valueExchangeData.PRM_Country_Market_Type_Nm__c;
                            valueExchangeRecommendation.PRM_Sales_Amount_Nbr__c = (Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('SalesSum');
                            valueExchangeRecommendation.PRM_Recommendation_Type_Nm__c = OPID_RECOMMENDATION_TYPE;
                            valueExchangeRecommendation.PRM_Recommendation_Status_Nm__c = RECOMMENDATION_STATUS_NEW;
                            valueExchangeRecommendation.PRM_Rank_Nbr__c=rank;
                            mapOfVXRecWithAggrKey.put(aggregateKey,valueExchangeRecommendation);
                        }
                    }
                    else{ */
                        Map<String,Decimal> vxDataValueMap = new Map<String,Decimal>();
                        vxDataValueMap.put('Sales',(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('SalesSum')!=null?(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('SalesSum'):0);
                        vxDataValueMap.put('Training',(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinTraining')!=null? (Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinTraining'):0);
                        vxDataValueMap.put('Solutions',(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinSolution')!=null? (Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinSolution'):0);
                        vxDataValueMap.put('Registrations',(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinRegistration')!=null? (Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinRegistration'):0);
                        vxDataValueMap.put('Employee',(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinEmployee')!=null? (Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinEmployee'):0);
                        vxDataValueMap.put('TotalCompetency',(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinCompetancy')!=null?(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinCompetancy'):0);
                        Map<String,Decimal> calculatedValueMap = doCalculations(key,vxDataValueMap);
                        PRM_Value_Exchange_Data__c vxDataNotQualified = new PRM_Value_Exchange_Data__c();
                        vxDataNotQualified.PRM_Sales_To_Next_Tier_Nbr__c=calculatedValueMap.get('salesToNextTier');
                        vxDataNotQualified.PRM_Sales_to_next_tier_percent_nbr__c=calculatedValueMap.get('salesPercentageToNextTier');
                        vxDataNotQualified.PRM_Training_credit_to_next_tier_per_nbr__c=calculatedValueMap.get('trainingCreditsPercentageToNextTier');
                        vxDataNotQualified.PRM_Training_Credits_to_Next_Tier_Nbr__c=calculatedValueMap.get('trainingCreditsToNextTier');
                        vxDataNotQualified.PRM_Percent_to_next_tier_Nbr__c = calculatedValueMap.get('percentToNextTier');
                        notQualifiedVXDataMap.put(valueExchangeData.Id,vxDataNotQualified);  
                    }
                }
            }
        }
     /*   if(mapOfVXRecWithAggrKey.values().size()>0){
            upsertRecommendation(mapOfVXRecWithAggrKey.values());
        } */
        
        for(PRM_Value_Exchange_Data__c vxData : vxDataCompleteListForOpidReccom){//DE90355: Calculation will be updated for all the account part of VX data picked by batch and  and same account record previously processed. 
            //calculations for not qualified VX Data 
            if(notQualifiedVXDataMap.containsKey(vxData.Id)){
                vxData.PRM_Sales_To_Next_Tier_Nbr__c=notQualifiedVXDataMap.get(vxData.Id).PRM_Sales_To_Next_Tier_Nbr__c;
                vxData.PRM_Sales_to_next_tier_percent_nbr__c=notQualifiedVXDataMap.get(vxData.Id).PRM_Sales_to_next_tier_percent_nbr__c;
                vxData.PRM_Training_credit_to_next_tier_per_nbr__c=notQualifiedVXDataMap.get(vxData.Id).PRM_Training_credit_to_next_tier_per_nbr__c;
                vxData.PRM_Training_Credits_to_Next_Tier_Nbr__c=notQualifiedVXDataMap.get(vxData.Id).PRM_Training_Credits_to_Next_Tier_Nbr__c;
                vxData.PRM_Percent_to_next_tier_Nbr__c=notQualifiedVXDataMap.get(vxData.Id).PRM_Percent_to_next_tier_Nbr__c;
                valueExchangeDataToUpdateList.add(vxData);
            }
            else{//calculations for qualified record of VX Data
                if(vxData.PRM_Tier_Id__r.Name == System.Label.PRM_Member){
                    String key = /*vxData.PRM_Partner_Role_Nm__c +*/ vxData.PRM_Country_Market_Type_Nm__c + System.Label.PRM_Tier_Gold; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                    String aggregateKey = vxData.PRM_Account_Id__c /*+ vxData.PRM_Partner_Role_Nm__c*/ + vxData.PRM_Country_Market_Type_Nm__c + vxData.PRM_Tier_Id__r.Name; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                    Map<String,Decimal> vxDataValueMap = new Map<String,Decimal>();
                    vxDataValueMap.put('Sales',(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('SalesSum')!=null? (Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('SalesSum'):0);
                    vxDataValueMap.put('Training',(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinTraining')!=null? (Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinTraining'):0);
                    vxDataValueMap.put('Solutions',(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinSolution')!=null? (Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinSolution'):0);
                    vxDataValueMap.put('Registrations',(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinRegistration')!=null? (Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinRegistration'):0);
                    vxDataValueMap.put('Employee',(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinEmployee')!=null? (Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinEmployee'):0);
                    vxDataValueMap.put('TotalCompetency',(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinCompetancy')!=null?(Decimal) groupByOPIDAggregateMapForOpid.get(aggregateKey).get('MinCompetancy'):0);
                    Map<String,Decimal> calculatedValueMap = doCalculations(key,vxDataValueMap);
                    vxData.PRM_Sales_To_Next_Tier_Nbr__c=calculatedValueMap.get('salesToNextTier');
                    vxData.PRM_Sales_to_next_tier_percent_nbr__c=calculatedValueMap.get('salesPercentageToNextTier');
                    vxData.PRM_Training_credit_to_next_tier_per_nbr__c=calculatedValueMap.get('trainingCreditsPercentageToNextTier');
                    vxData.PRM_Training_Credits_to_Next_Tier_Nbr__c=calculatedValueMap.get('trainingCreditsToNextTier');
                    vxData.PRM_Percent_to_next_tier_Nbr__c = calculatedValueMap.get('percentToNextTier');
                    valueExchangeDataToUpdateList.add(vxData);
                }
                
                else{
                    valueExchangeDataToUpdateList.add(vxData);
                }
            }
        }
        updateVXData(valueExchangeDataToUpdateList,vxDataForOpidSet);//DE90355:to update all account for calculation and processed date for account picked by batch.
    }
    
    //Method will compare the VXData with VX critreia for Upgrade recommendation on the basis of qualitative and qunatitaive criteria logic 
    private static void upsertRecommendationsForUpgrade(List<PRM_Value_Exchange_Data__c> valueExchangeDataList,Map<String,List<PRM_Value_Exchange_Data__c>> opidVxDataMap, List<PRM_Value_Exchange_Data__c> opidVxDataCompleteList, Set<Id> vxDataForUpgradeIdSet)
    {
        List<PRM_Value_Exchange_Recommendation__c> valueExchangeRecommendationList = new  List<PRM_Value_Exchange_Recommendation__c>();
        Set<String> tempRemoveOpidVxDataIDSet = new Set<String>();
        Map<string, string> criteriaVxDataFieldMap = new  Map<string, string>();
        Map<String,CriteriaFulfilledwrapper> criteriaFulfilledMap = new Map<String,CriteriaFulfilledwrapper>();
        List<PRM_Value_Exchange_Data__c> vxFinalList = new List<PRM_Value_Exchange_Data__c>();
        Map<String,PRM_Value_Exchange_Data__c> notQualifiedVXDataMap= new Map<String,PRM_Value_Exchange_Data__c>();
        List<PRM_Value_Exchange_Data__c> valueExchangeDataToUpdateList = new List<PRM_Value_Exchange_Data__c>();
        Set<String> accPartnerRoleSpeciality =  new Set<String>();
        Map<String,List<PRM_Account_Specialty_Association__c>> mapOfAccAndASA = new Map<String,List<PRM_Account_Specialty_Association__c>>();
        Map<String,Map<Decimal,Boolean>> rankingSatisfiedQuantativeMap = new Map<String,Map<Decimal,Boolean>>();
        set<Id> upgradeAccIds = new set<Id>();
        list<PRM_Account_Specialty_Association__c> asaList = new list<PRM_Account_Specialty_Association__c>();
        if(!opidVxDataCompleteList.isEmpty()){
            for(PRM_Value_Exchange_Data__c upgradeList : opidVxDataCompleteList){
                upgradeAccIds.add(upgradeList.PRM_Account_Id__c);
            }
        }
        if(!upgradeAccIds.isEmpty()){  
            asaList  = [Select PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Specialty_Id__r.Name,PRM_Specialty_Type__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__c in:upgradeAccIds and  PRM_InActive_Ind__c = false] ;
        }
        /*if(!asaList.isEmpty() && (!ipaRefresh  || test.isrunningtest())){ //IPA2.0-TWC727-2861
            for(PRM_Account_Specialty_Association__c asa : asaList){
            if(asa.PRM_Specialty_Type__c.equalsIgnoreCase(System.Label.PRM_Source_Specialty)){//DE80439-Specialty ASA filter
                String asaKey =asa.PRM_Account_Id__c + asa.PRM_Partner_Role__c;
                if(mapOfAccAndASA.containsKey(asaKey)){//DE80439- for Specialty realted ASA
                    List<PRM_Account_Specialty_Association__c> tempList = mapOfAccAndASA.get(asaKey);
                    tempList.add(asa);
                    mapOfAccAndASA.put(asaKey,tempList);
                }
                else{
                    mapOfAccAndASA.put(asaKey,new List<PRM_Account_Specialty_Association__c>{asa});
                }
            }
            if(asa.PRM_Specialty_Type__c.equalsIgnoreCase(System.Label.PRM_RecordType_SelectBenefits)){//Select Benefits Filter at ASA
                String accPartnerRoleSpecialityValue = asa.PRM_Account_Id__c + asa.PRM_Partner_Role__c + asa.PRM_Specialty_Id__r.Name.toLowerCase();
                accPartnerRoleSpeciality.add(accPartnerRoleSpecialityValue);
            }
        }
        }*/ //Switch Removal
        criteriaVxDataFieldMap.put(System.Label.PRM_QuantativeCriteria_TrainingCredits, 'TrainingSum');
        criteriaVxDataFieldMap.put(System.Label.PRM_QuantativeCriteria_Sales, 'TotalSales');
        criteriaVxDataFieldMap.put(System.Label.PRM_QuantativeCriteria_NbrEmpTraining, 'EmployeeSum');
        criteriaVxDataFieldMap.put(System.Label.PRM_QuantativeCriteria_TotalAchievedCompetency, 'TotalAchievedCompetency');//US643150-Added new criteria as Quantative 
        criteriaVxDataFieldMap.put(System.Label.PRM_QuantativeCriteria_NbrSolutionsMplace, 'SolutionSum');
        criteriaVxDataFieldMap.put(System.Label.PRM_QuantativeCriteria_FPGA_Registrations, 'RegistrationSum');
        for(String vxDataKey: opidVxDataMap.keySet())
        {
            PRM_Value_Exchange_Data__c vxData=opidVxDataMap.get(vxDataKey)[0];
            
            string key;
            if(vxData.PRM_Tier_Id__r.Name == System.Label.PRM_Member)
            {
                key = /*vxData.PRM_Partner_Role_Nm__c +*/ vxData.PRM_Country_Market_Type_Nm__c + System.Label.PRM_Tier_Gold; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
            }
            if(vxData.PRM_Tier_Id__r.Name == System.Label.PRM_Tier_Gold)
            {
                key = /*vxData.PRM_Partner_Role_Nm__c +*/ vxData.PRM_Country_Market_Type_Nm__c + System.Label.PRM_Tier_Titanium; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
            }
            
            if(vxCriteriaAssociationMap.containsKey(key)){
                for(PRM_Value_Exchange_Criteria_Association__c vxCriteria: vxCriteriaAssociationMap.get(key))
                {
                    if(!rankingSatisfiedQuantativeMap.containsKey(vxDataKey)){
                        rankingSatisfiedQuantativeMap.put(vxDataKey, new Map<Decimal,Boolean>{vxCriteria.PRM_Rank_Nbr__c => true});
                    }
                    if(rankingSatisfiedQuantativeMap.containsKey(vxDataKey) && !rankingSatisfiedQuantativeMap.get(vxDataKey).containsKey(vxCriteria.PRM_Rank_Nbr__c)){
                        Map<Decimal,Boolean> tempRankMap = rankingSatisfiedQuantativeMap.get(vxDataKey);
                        tempRankMap.put(vxCriteria.PRM_Rank_Nbr__c,true);
                        rankingSatisfiedQuantativeMap.put(vxDataKey, tempRankMap);
                    }
                    string vxDataFieldName = criteriaVxDataFieldMap.get(vxCriteria.PRM_Specialty_Criteria_Id__r.Name);
                    
                    switch on vxCriteria.PRM_Specialty_Criteria_Id__r.Name {
                        when 'Training Credits','Sales','Minimum Number of employees doing the training','Number of Solutions in Mplace','FPGA Project Registrations','Total Nbr Achieved Competency' {
                            if(rankingSatisfiedQuantativeMap.containsKey(vxDataKey) && 
                               rankingSatisfiedQuantativeMap.get(vxDataKey).get(vxCriteria.PRM_Rank_Nbr__c)){
                                   if(groupByOPIDAggregateMapForUpgrade.get(vxDataKey).get(vxDataFieldName) < Decimal.valueOf(vxCriteria.PRM_Value_Txt__c.replaceAll(',',''))){
                                       Map<String, Map<Decimal,Boolean>> tempRankMap = new Map<String, Map<Decimal,Boolean>>();
                                       tempRankMap.putAll(rankingSatisfiedQuantativeMap);
                                       rankingSatisfiedQuantativeMap = populateRankingSatifiedMap(vxDataKey,vxCriteria.PRM_Rank_Nbr__c, tempRankMap,false);
                                       
                                   }
                               }
                            else{
                                continue;
                            }
                        }
                        
                    }
                }
                if(!rankingSatisfiedQuantativeMap.get(vxDataKey).values().contains(true)){
                    
                    Map<String,Decimal> vxDataValueMap = new Map<String,Decimal>();
                    vxDataValueMap.put('Sales',groupByOPIDAggregateMapForUpgrade.get(vxDataKey).get('TotalSales'));
                    vxDataValueMap.put('Training',groupByOPIDAggregateMapForUpgrade.get(vxDataKey).get('TrainingSum'));
                    vxDataValueMap.put('Solutions',groupByOPIDAggregateMapForUpgrade.get(vxDataKey).get('SolutionSum'));
                    vxDataValueMap.put('Registrations',groupByOPIDAggregateMapForUpgrade.get(vxDataKey).get('RegistrationSum'));
                    vxDataValueMap.put('Employee',groupByOPIDAggregateMapForUpgrade.get(vxDataKey).get('EmployeeSum'));
                    vxDataValueMap.put('TotalCompetency',groupByOPIDAggregateMapForUpgrade.get(vxDataKey).get('TotalAchievedCompetency'));//US643150-Added TotalAchievedCompetency as Qunatitative in total calculation
                    Map<String,Decimal> calculatedValueMap = doCalculations(key,vxDataValueMap);
                    
                    PRM_Value_Exchange_Data__c vxDataNotQualified = new PRM_Value_Exchange_Data__c();
                    vxDataNotQualified.PRM_Sales_To_Next_Tier_Nbr__c=calculatedValueMap.get('salesToNextTier');
                    vxDataNotQualified.PRM_Sales_to_next_tier_percent_nbr__c=calculatedValueMap.get('salesPercentageToNextTier');
                    vxDataNotQualified.PRM_Training_credit_to_next_tier_per_nbr__c=calculatedValueMap.get('trainingCreditsPercentageToNextTier');
                    vxDataNotQualified.PRM_Training_Credits_to_Next_Tier_Nbr__c=calculatedValueMap.get('trainingCreditsToNextTier');
                    vxDataNotQualified.PRM_Percent_to_next_tier_Nbr__c=calculatedValueMap.get('percentToNextTier');
                    notQualifiedVXDataMap.put(vxDataKey,vxDataNotQualified);
                    tempRemoveOpidVxDataIDSet.add(vxDataKey);
                } 
            }
            else{
                tempRemoveOpidVxDataIDSet.add(vxDataKey);
            }
        }//Loop for vxData ends here
        
        
        if(tempRemoveOpidVxDataIDSet.size()>0){
            for(String key:tempRemoveOpidVxDataIDSet){
                opidVxDataMap.remove(key);
            }
        }
        
        for(List<PRM_Value_Exchange_Data__c> vxDataListFinal : opidVxDataMap.values()){
            vxFinalList.addAll(vxDataListFinal);
        }
        
        
        for(PRM_Value_Exchange_Data__c vxData : opidVxDataCompleteList){
            
            
            String key = vxData.PRM_One_Partner_Id__c+/*vxData.PRM_Partner_Role_Nm__c +*/ vxData.PRM_Country_Market_Type_Nm__c +vxData.PRM_Tier_Id__r.Name; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
            if(rankingSatisfiedQuantativeMap.containsKey(key)){
                
                
                //Boolean flag = true;
                string tempKey;
                if(vxData.PRM_Tier_Id__r.Name == System.Label.PRM_Member)
                {
                    tempKey = /*vxData.PRM_Partner_Role_Nm__c +*/ vxData.PRM_Country_Market_Type_Nm__c + System.Label.PRM_Tier_Gold; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                }
                if(vxData.PRM_Tier_Id__r.Name == System.Label.PRM_Tier_Gold)
                {
                    tempKey = /*vxData.PRM_Partner_Role_Nm__c +*/ vxData.PRM_Country_Market_Type_Nm__c + System.Label.PRM_Tier_Titanium; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                }
                if(vxCriteriaAssociationMap.containsKey(tempKey)){
                    for(PRM_Value_Exchange_Criteria_Association__c vxCriteria: vxCriteriaAssociationMap.get(tempKey)){
                        if(rankingSatisfiedQuantativeMap.get(key).get(vxCriteria.PRM_Rank_Nbr__c)){
                            String rankKey = vxCriteria.PRM_Rank_Nbr__c+key;
                            CriteriaFulfilledwrapper wrapperObject = new CriteriaFulfilledwrapper();
                            if(!criteriaFulfilledMap.containsKey(rankKey)){
                                criteriaFulfilledMap.put(rankKey,wrapperObject);
                            }
                            
                            
                            switch on vxCriteria.PRM_Specialty_Criteria_Id__r.Name {
                                when 'Type of solutions' {
                                    Boolean containsSolution = false;
                                    if(criteriaFulfilledMap.containsKey(rankKey) && !criteriaFulfilledMap.get(rankKey).solutionFulfilled){
                                        criteriaFulfilledMap.get(rankKey).solutionFulfilledPresent = true;
                                        if(!String.isEmpty(String.valueOf(vxData.PRM_Type_Of_Solutions_Txt__c))){
                                            for(String sol:String.valueOf(vxData.PRM_Type_Of_Solutions_Txt__c).split(',')){
                                                if(sol!='' && vxCriteria.PRM_Value_Txt__c.contains(sol)){//Added not null to filter out string starting with ',' for comparing vx data with criteria
                                                    containsSolution = true;
                                                    break;
                                                }
                                            }
                                        }
                                        if(containsSolution){
                                            criteriaFulfilledMap.get(rankKey).solutionFulfilled = true;
                                            criteriaFulfilledMap.get(rankKey).solutionValue = String.valueOf(vxData.PRM_Type_Of_Solutions_Txt__c);
                                            
                                        }
                                    }
                                }
                                when 'CNDA' {
                                    if(criteriaFulfilledMap.containsKey(rankKey) && !criteriaFulfilledMap.get(rankKey).cndaFulfilled){
                                        criteriaFulfilledMap.get(rankKey).cndaPresent = true;
                                        if(String.valueOf(vxData.PRM_Account_Id__r.Core_CNDA_Number__c) !=Null){
                                            if(vxCriteria.PRM_Value_Txt__c=='Y'){
                                                criteriaFulfilledMap.get(rankKey).cndaFulfilled = true;
                                                criteriaFulfilledMap.get(rankKey).cndaValue = true;
                                                
                                            }
                                        }
                                    }
                                }
                                when 'Account Coverage' {
                                    if(criteriaFulfilledMap.containsKey(rankKey) && !criteriaFulfilledMap.get(rankKey).coverageFulfilled){
                                        criteriaFulfilledMap.get(rankKey).coveragePresent = true;
                                        if((Boolean)vxData.PRM_Account_Id__r.Core_Covered_Account__c){
                                            if(vxCriteria.PRM_Value_Txt__c=='Y'){
                                                criteriaFulfilledMap.get(rankKey).coverageFulfilled = true;
                                                criteriaFulfilledMap.get(rankKey).coverageValue = true;   
                                            }
                                        }
                                    }
                                }
                                when 'Select Benefit' {//US638610,US638612,US632701-Added  logic will compare Account's Select Benefit with same role of VX Data with VX Criteria.
                                    
                                    Boolean containsSelectBenefit = false;
                                    if(criteriaFulfilledMap.containsKey(rankKey)){
                                        
                                        criteriaFulfilledMap.get(rankKey).selectBenefitPresent = true;
                                        if(!String.isEmpty(vxCriteria.PRM_Value_Txt__c)){
                                            for(String selectBenefit : vxCriteria.PRM_Value_Txt__c.split(',')){//loop for select Benefit value start here...
                                                if(accPartnerRoleSpeciality.contains(vxData.PRM_Account_Id__c+/*vxData.PRM_Partner_Role_Nm__c+*/selectBenefit.toLowerCase())){ //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                                                    
                                                    containsSelectBenefit = true;
                                                    if(criteriaFulfilledMap.get(rankKey).selectBenfitValue.containsKey(vxData.PRM_Account_Id__c)){
                                                        List<String> selectBenefitValueList = criteriaFulfilledMap.get(rankKey).selectBenfitValue.get(vxData.PRM_Account_Id__c);
                                                        Set<String> uniqueBenifitValues = new Set<String>();
                                                        selectBenefitValueList.add(selectBenefit);
                                                        uniqueBenifitValues.addAll(selectBenefitValueList);
                                                        selectBenefitValueList.clear();
                                                        selectBenefitValueList.addAll(uniqueBenifitValues);
                                                        criteriaFulfilledMap.get(rankKey).selectBenfitValue.put(vxData.PRM_Account_Id__c,selectBenefitValueList);
                                                    }
                                                    else{
                                                        List<String> tempList = new List<String>();
                                                        tempList.add(selectBenefit);
                                                        criteriaFulfilledMap.get(rankKey).selectBenfitValue.put(vxData.PRM_Account_Id__c,tempList);
                                                    }
                                                }
                                            }//loop ends here.
                                        }
                                        if(!criteriaFulfilledMap.get(rankKey).selectBenefitFulfilled){
                                            if(containsSelectBenefit){
                                                criteriaFulfilledMap.get(rankKey).selectBenefitFulfilled = true;
                                                
                                            }
                                            else{
                                                criteriaFulfilledMap.get(rankKey).selectBenefitFulfilled = false;
                                            }
                                        }
                                    }
                                }
                                when 'Specialty present' {
                                    if(criteriaFulfilledMap.containsKey(rankKey) && !criteriaFulfilledMap.get(rankKey).specialtyPresentFulfilled){
                                        criteriaFulfilledMap.get(rankKey).specialtyPresent = true;
                                        String asaKey=vxData.PRM_Account_Id__c/*+vxData.PRM_Partner_Role_Nm__c*/; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                                        if(mapOfAccAndASA.containsKey(asaKey) && mapOfAccAndASA.get(asaKey).size()>0){
                                            criteriaFulfilledMap.get(rankKey).specialtyPresentFulfilled = true;                                            
                                        }
                                        
                                    }
                                }
                                when else {
                                    //System.debug('Ignored '+vxCriteria.PRM_Specialty_Criteria_Id__r.Name);
                                }
                            }
                        }
                    }
                    
                }
            }
            else{
                continue;
            }
        }
        
        
        for(PRM_Value_Exchange_Data__c vxData : opidVxDataCompleteList){//US687613-While creating and updating record in VX recommendation,Rank should be align with other location account.
            Boolean flag = true;
            String key=vxData.PRM_One_Partner_Id__c+/*vxData.PRM_Partner_Role_Nm__c +*/ vxData.PRM_Country_Market_Type_Nm__c +vxData.PRM_Tier_Id__r.Name; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
            CriteriaFulfilledwrapper wrapperObject = new CriteriaFulfilledwrapper();
            Map<String,List<String>> selectBenfitValue = new Map<String,List<String>>();
            Decimal satisfiedRank;
            if(rankingSatisfiedQuantativeMap.containsKey(key)){ 
                for(Decimal rank : rankingSatisfiedQuantativeMap.get(key).keyset()){//Loop on Rank satisfying Quantative Criteria
                    if(rankingSatisfiedQuantativeMap.get(key).get(rank)){
                        String rankKey = rank+key;
                        wrapperObject = criteriaFulfilledMap.get(rankKey);
                        if((wrapperObject.solutionFulfilledPresent && !wrapperObject.solutionFulfilled) ||
                           (wrapperObject.cndaPresent && !wrapperObject.cndaFulfilled) ||
                           (wrapperObject.coveragePresent && !wrapperObject.coverageFulfilled) || 
                           (wrapperObject.selectBenefitPresent&& !wrapperObject.selectBenefitFulfilled) ||
                           (wrapperObject.specialtyPresent&& !wrapperObject.specialtyPresentFulfilled)){
                               flag = false;
                               continue;
                           }
                        else{
                            flag=true;
                            satisfiedRank = rank;
                            if(wrapperObject.selectBenfitValue!=null){
                                selectBenfitValue.putAll(wrapperObject.selectBenfitValue);
                            }
                        }
                        
                        if(flag){
                            break;
                        }
                    }
                    else{
                        flag=false;
                    }
                }//Loop ends here.
            }
            else{
                flag=false;
            }
            if(flag)
            {
                PRM_Value_Exchange_Recommendation__c valueExchangeRecommendation = new  PRM_Value_Exchange_Recommendation__c();
                valueExchangeRecommendation.RecordTypeId = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();
                valueExchangeRecommendation.PRM_Account_Id__c = vxData.PRM_Account_Id__c;
                if(vxData.PRM_Tier_Id__r.Name == System.Label.PRM_Member){
                    valueExchangeRecommendation.PRM_Eligibility_Tier__c = tierMap.get(System.Label.PRM_Tier_Gold); 
                }
                else if(vxData.PRM_Tier_Id__r.Name == System.Label.PRM_Tier_Gold){
                    valueExchangeRecommendation.PRM_Eligibility_Tier__c = tierMap.get(System.Label.PRM_Tier_Titanium); 
                }
                else{
                    valueExchangeRecommendation.PRM_Eligibility_Tier__c = vxData.PRM_Tier_Id__c;
                }
                valueExchangeRecommendation.PRM_Tier_Id__c = vxData.PRM_Tier_Id__c;
                //valueExchangeRecommendation.PRM_Partner_Role_Nm__c = vxData.PRM_Partner_Role_Nm__c; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                valueExchangeRecommendation.PRM_Market_Type_Nm__c = vxData.PRM_Country_Market_Type_Nm__c;
                valueExchangeRecommendation.PRM_Recommendation_Type_Nm__c = UPGRADE_RECOMMENDATION_TYPE;
                valueExchangeRecommendation.PRM_Recommendation_Status_Nm__c = RECOMMENDATION_STATUS_NEW;
                valueExchangeRecommendation.PRM_Sales_Amount_Nbr__c = vxData.PRM_Sales_Amount_Nbr__c;
                valueExchangeRecommendation.PRM_Design_Registration_Count_Nbr__c = vxData.PRM_Design_Registration_Count_Nbr__c;//
                valueExchangeRecommendation.PRM_One_Partner_Id__c = vxData.PRM_One_Partner_Id__c;
                valueExchangeRecommendation.PRM_Training_Credit_Points_Count_Nbr__c = vxData.PRM_Training_Credit_Points_Count_Nbr__c;
                valueExchangeRecommendation.PRM_Total_Achieved_Competency_Nbr__c = vxData.PRM_Total_Achieved_Competency_Nbr__c;//US643150-Added Total Nbr Achieved_Competency Field as Qunatitative value. 
                valueExchangeRecommendation.PRM_No_Of_Employees_Done_Training_Nbr__c = vxData.PRM_Number_Of_Employees_Nbr__c;
                valueExchangeRecommendation.PRM_Number_Of_MP_Solutions_Nbr__c = vxData.PRM_MP_Solutions_Count_Nbr__c;
                valueExchangeRecommendation.PRM_Sales_Calculation_Group_Txt__c=vxData.PRM_Sales_Calculation_Group_Txt__c;
                valueExchangeRecommendation.PRM_Rank_Nbr__c=satisfiedRank;
                if(wrapperObject.solutionFulfilledPresent){
                    if(vxData.PRM_Type_Of_Solutions_Txt__c !=null){
                        valueExchangeRecommendation.PRM_Type_Of_Solutions_Txt__c = vxData.PRM_Type_Of_Solutions_Txt__c;//Qualitative field value will be updated with corresponding VX data record
                    }
                }
                else{
                    valueExchangeRecommendation.PRM_Type_Of_Solutions_Txt__c =NA; //US687613-If ceriteria is not present then NA value will populate.
                }
                
                if(wrapperObject.cndaPresent){
                    valueExchangeRecommendation.PRM_CNDA_Indicator_Nm__c = vxData.PRM_Account_Id__r.Core_CNDA_Number__c != Null ? YES : NO; //US687613- VX Upgrade changes for boolean fields                }
                }
                else{
                    valueExchangeRecommendation.PRM_CNDA_Indicator_Nm__c=NA;//US687613-If criteria is not present
                }
                if(wrapperObject.coveragePresent){
                    valueExchangeRecommendation.PRM_Account_Coverage_Nm__c = vxData.PRM_Account_Id__r.Core_Covered_Account__c ? YES : NO;//US687613-If criteria is present
                }
                else{
                    valueExchangeRecommendation.PRM_Account_Coverage_Nm__c =NA;
                    //US687613-If criteria is not present
                }
                if(wrapperObject.specialtyPresent){
                    String asaKey=vxData.PRM_Account_Id__c/*+vxData.PRM_Partner_Role_Nm__c*/; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                    if(mapOfAccAndASA.containsKey(asaKey)&&mapOfAccAndASA.get(asaKey).size()>0){
                        valueExchangeRecommendation.PRM_Specialty_Present_Nm__c =YES;//US687613-If criteria is present and value is also matching
                    }
                    else{
                        valueExchangeRecommendation.PRM_Specialty_Present_Nm__c =NO;//US687613-If criteria is present but value is not present.
                    } 
                }
                else {
                    valueExchangeRecommendation.PRM_Specialty_Present_Nm__c =NA;//US687613-If criteria is not present
                }
                if(wrapperObject.selectBenefitPresent){
                    if(selectBenfitValue!=null &&selectBenfitValue.containsKey(vxData.PRM_Account_Id__c)){
                        valueExchangeRecommendation.PRM_Select_Benefit_Txt__c = String.join(selectBenfitValue.get(vxData.PRM_Account_Id__c),',');//US687613-If criteria is present
                    }
                    else{
                        valueExchangeRecommendation.PRM_Select_Benefit_Txt__c = '';
                    }
                }
                else{
                    valueExchangeRecommendation.PRM_Select_Benefit_Txt__c = NA;//US687613-If criteria is not present
                }
                valueExchangeRecommendationList.add(valueExchangeRecommendation);
            }
            else{
                string calculationKey;
                if(vxData.PRM_Tier_Id__r.Name == System.Label.PRM_Member)
                {
                    calculationKey = /*vxData.PRM_Partner_Role_Nm__c +*/ vxData.PRM_Country_Market_Type_Nm__c + System.Label.PRM_Tier_Gold; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                }
                if(vxData.PRM_Tier_Id__r.Name == System.Label.PRM_Tier_Gold)
                {
                    calculationKey = /*vxData.PRM_Partner_Role_Nm__c +*/ vxData.PRM_Country_Market_Type_Nm__c + System.Label.PRM_Tier_Titanium; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                }
                Map<String,Decimal> vxDataValueMap = new Map<String,Decimal>();
                vxDataValueMap.put('Sales',groupByOPIDAggregateMapForUpgrade.get(key).get('TotalSales'));
                vxDataValueMap.put('Training',groupByOPIDAggregateMapForUpgrade.get(key).get('TrainingSum'));
                vxDataValueMap.put('Solutions',groupByOPIDAggregateMapForUpgrade.get(key).get('SolutionSum'));
                vxDataValueMap.put('Registrations',groupByOPIDAggregateMapForUpgrade.get(key).get('RegistrationSum'));
                vxDataValueMap.put('Employee',groupByOPIDAggregateMapForUpgrade.get(key).get('EmployeeSum'));
                vxDataValueMap.put('TotalCompetency',groupByOPIDAggregateMapForUpgrade.get(key).get('TotalAchievedCompetency'));//US643150-Added TotalAchievedCompetency as Qunatitative in total calculation
                Map<String,Decimal> calculatedValueMap = doCalculations(calculationKey,vxDataValueMap);
                
                PRM_Value_Exchange_Data__c vxDataNotQualified = new PRM_Value_Exchange_Data__c();
                vxDataNotQualified.PRM_Sales_To_Next_Tier_Nbr__c=calculatedValueMap.get('salesToNextTier');
                vxDataNotQualified.PRM_Sales_to_next_tier_percent_nbr__c=calculatedValueMap.get('salesPercentageToNextTier');
                vxDataNotQualified.PRM_Training_credit_to_next_tier_per_nbr__c=calculatedValueMap.get('trainingCreditsPercentageToNextTier');
                vxDataNotQualified.PRM_Training_Credits_to_Next_Tier_Nbr__c=calculatedValueMap.get('trainingCreditsToNextTier');
                vxDataNotQualified.PRM_Percent_to_next_tier_Nbr__c=calculatedValueMap.get('percentToNextTier');
                notQualifiedVXDataMap.put(key,vxDataNotQualified);
            }
        }
        
        if(valueExchangeRecommendationList.size()>0){
            upsertRecommendation(valueExchangeRecommendationList);
        }
        
        for(PRM_Value_Exchange_Data__c vxData : opidVxDataCompleteList){
            String key=vxData.PRM_One_Partner_Id__c/*+vxData.PRM_Partner_Role_Nm__c*/ + vxData.PRM_Country_Market_Type_Nm__c +vxData.PRM_Tier_Id__r.Name; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
            if(notQualifiedVXDataMap.containsKey(key)){
                vxData.PRM_Sales_To_Next_Tier_Nbr__c=notQualifiedVXDataMap.get(key).PRM_Sales_To_Next_Tier_Nbr__c;
                vxData.PRM_Sales_to_next_tier_percent_nbr__c=notQualifiedVXDataMap.get(key).PRM_Sales_to_next_tier_percent_nbr__c;
                vxData.PRM_Training_credit_to_next_tier_per_nbr__c=notQualifiedVXDataMap.get(key).PRM_Training_credit_to_next_tier_per_nbr__c;
                vxData.PRM_Training_Credits_to_Next_Tier_Nbr__c = notQualifiedVXDataMap.get(key).PRM_Training_Credits_to_Next_Tier_Nbr__c;
                vxData.PRM_Percent_to_next_tier_Nbr__c = notQualifiedVXDataMap.get(key).PRM_Percent_to_next_tier_Nbr__c;
                valueExchangeDataToUpdateList.add(vxData);
            }
            else{
                vxData.PRM_Sales_To_Next_Tier_Nbr__c=0;
                vxData.PRM_Sales_to_next_tier_percent_nbr__c=0;
                vxData.PRM_Training_credit_to_next_tier_per_nbr__c=0;
                vxData.PRM_Training_Credits_to_Next_Tier_Nbr__c=0;
                vxData.PRM_Percent_to_next_tier_Nbr__c = 0;
                valueExchangeDataToUpdateList.add(vxData);         
            }
        }
        updateVXData(valueExchangeDataToUpdateList,vxDataForUpgradeIdSet);
    }
    
    //US570458-Method will upsert the record in Recommendation and in case of failure error log will be generated.
    private static void upsertRecommendation(List<PRM_Value_Exchange_Recommendation__c> valueExchangeRecommendationList)
    {
        
        List<PRM_Value_Exchange_Recommendation__c> upsertValueExchangeRecommendationList = new  List<PRM_Value_Exchange_Recommendation__c>();
        List<Database.UpsertResult> upsertResultList = new  List<Database.UpsertResult>();
        Map<string, PRM_Value_Exchange_Recommendation__c> vxRecommendationMap = new  Map<string, PRM_Value_Exchange_Recommendation__c>();
        for(PRM_Value_Exchange_Recommendation__c vxRecommendation: [SELECT
                                                                    Id, 
                                                                    Name, 
                                                                    PRM_Account_Id__c, 
                                                                    PRM_Tier_Id__r.Name, 
                                                                    PRM_Partner_Role_Nm__c, 
                                                                    PRM_Market_Type_Nm__c,
                                                                    PRM_Sales_Calculation_Group_Txt__c,
                                                                    PRM_Recommendation_Status_Nm__c,
                                                                    PRM_One_Partner_Id__c
                                                                    FROM
                                                                    PRM_Value_Exchange_Recommendation__c 
                                                                    where PRM_Recommendation_Status_Nm__c =:RECOMMENDATION_STATUS_NEW 
                                                                    OR PRM_Recommendation_Status_Nm__c =:RECOMMENDATION_STATUS_PROCESSED 
                                                                    OR PRM_Recommendation_Status_Nm__c =:RECOMMENDATION_STATUS_INPROCESSED
                                                                    OR PRM_Recommendation_Status_Nm__c =:RECOMMENDATION_STATUS_OPIDINPROCESS
                                                                    OR PRM_Recommendation_Status_Nm__c =:RECOMMENDATION_STATUS_OPIDCREATED
                                                                    OR PRM_Recommendation_Status_Nm__c =:RECOMMENDATION_STATUS_REJECTED])//13-Aug -included New and Processed Status for Upsert
        {
            string key = vxRecommendation.PRM_Account_Id__c + vxRecommendation.PRM_Partner_Role_Nm__c + vxRecommendation.PRM_Market_Type_Nm__c +vxRecommendation.PRM_Tier_Id__c+vxRecommendation.PRM_Sales_Calculation_Group_Txt__c+vxRecommendation.PRM_One_Partner_Id__c;
            vxRecommendationMap.put(key, vxRecommendation);
        }
        Set<Id> upsertValExchRecommIds = new Set<Id>();
        for(PRM_Value_Exchange_Recommendation__c vxRecommendationToUpsert: valueExchangeRecommendationList)
        {
            string key = vxRecommendationToUpsert.PRM_Account_Id__c + vxRecommendationToUpsert.PRM_Partner_Role_Nm__c +vxRecommendationToUpsert.PRM_Market_Type_Nm__c+vxRecommendationToUpsert.PRM_Tier_Id__c+vxRecommendationToUpsert.PRM_Sales_Calculation_Group_Txt__c+vxRecommendationToUpsert.PRM_One_Partner_Id__c;
            if(vxRecommendationMap.containsKey(key) && !upsertValExchRecommIds.contains(vxRecommendationMap.get(key).Id))
            {
                upsertValExchRecommIds.add(vxRecommendationMap.get(key).Id);
                vxRecommendationToUpsert.Id = vxRecommendationMap.get(key).Id;
                vxRecommendationToUpsert.PRM_Recommendation_Status_Nm__c=vxRecommendationMap.get(key).PRM_Recommendation_Status_Nm__c;
                if (!upsertValueExchangeRecommendationList.contains(vxRecommendationToUpsert)) {
                    upsertValueExchangeRecommendationList.add(vxRecommendationToUpsert);
                }
            }
            else if(!vxRecommendationMap.containsKey(key))
            {
                upsertValueExchangeRecommendationList.add(vxRecommendationToUpsert);
            }
        }
        if(upsertValueExchangeRecommendationList.size() > 0 && upsertValueExchangeRecommendationList.size() < Limits.getLimitDMLRows())
        {
            upsertResultList = Database.upsert(upsertValueExchangeRecommendationList, PRM_Value_Exchange_Recommendation__c.Fields.Id, false);
            integer index = 0;
            for(Database.UpsertResult result: upsertResultList)
            {
                if(!result.isSuccess())
                {
                    Id sId;
                    string sObjectType = '';
                    string tags = '';
                    for(Database.Error err: result.getErrors())
                    {
                        sId = upsertValueExchangeRecommendationList[index].Id;
                        if(sId != null)
                        {
                            sObjectType = sId.getSObjectType().getDescribe().getName();
                        }
                        string accName = '';
                        accName = upsertValueExchangeRecommendationList[index].PRM_Account_Id__r.Name;
                        string partnerRoleName = '';
                        partnerRoleName = upsertValueExchangeRecommendationList[index].PRM_Partner_Role_Nm__c;
                        string marketType = '';
                        marketType = upsertValueExchangeRecommendationList[index].PRM_Market_Type_Nm__c;
                        tags = accName + ';' + partnerRoleName + ';' + marketType;
                        Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, err.getMessage(), '', sId, sObjectType, tags);
                    }
                }
            }
            index++;
        }
        else
        {
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, ERROR_MESSAGE, '', '', '', '');
        }
    }
    //US599996-Method will update the processed date in VX Data for every time batch pick the record.
    private static void updateVXData(List<PRM_Value_Exchange_Data__c> vXDataList,Set<Id> vxDataIdSet)
    {
        List<PRM_Value_Exchange_Data__c> updateValueExchangeDataList = new  List<PRM_Value_Exchange_Data__c>();
        for(PRM_Value_Exchange_Data__c vxData: vXDataList)
        {
            if(vxDataIdSet!=null && vxDataIdSet.size()>0 && vxDataIdSet.contains(vxData.Id)){
                vxData.PRM_Processed_Date_Time_Dt__c = System.now();
            }
            updateValueExchangeDataList.add(vxData);
        }
        if(updateValueExchangeDataList.size() > 0)
        {
            Update updateValueExchangeDataList;
        }
    }
    
    //US617760-Method will calculate the total percentage criteria pending for Next tier for VX Data
    private static Map<String,Decimal> doCalculations(String key,Map<String,Decimal> vxDataValueQuantMap){
        Map<String,Decimal> tempCriteraiAssociationQuantativeTotalMap = new Map<String,Decimal>();
        tempCriteraiAssociationQuantativeTotalMap.putAll(vxCriteraiAssociationQuantativeTotalMap);
        Decimal trainingCreditsToNextTier = 0;
        Decimal trainingCreditsPercentageToNextTier =100;//DE93114-Added default value as 100%,If there is no criteria of VX data then it will be updated with default vlaue.
        Decimal salesToNextTier = 0;
        Decimal salesPercentageToNextTier =100;//DE93114-Added default value as 100%
        Decimal vxDataQuantativeTotal = 0;
        Decimal solutionsToNextTier=0;
        Decimal employeeToNextTier=0;
        Decimal registrationToNextTier=0;
        Decimal percentToNextTier=100;//DE93114-Added default value as 100%
        Decimal totalCompetencyToNextTier=0;
        Map<String,Decimal> calculatedValueMap = new Map<String,Decimal>();
        if(tempCriteraiAssociationQuantativeTotalMap.containsKey(key)){
            if(vxCriteriaAssociationSalesMap.containsKey(key)){
                Decimal vxcriteriaSalesValue=(Decimal.valueOf(vxCriteriaAssociationSalesMap.get(key).PRM_Value_Txt__c.replaceAll(',','')));
                if(vxDataValueQuantMap.get('Sales')!= null ){
                    salesToNextTier=vxcriteriaSalesValue-vxDataValueQuantMap.get('Sales');
                    if(salesToNextTier<=0){
                        salesToNextTier = 0;
                        tempCriteraiAssociationQuantativeTotalMap.put(key,(tempCriteraiAssociationQuantativeTotalMap.get(key)-vxcriteriaSalesValue));
                    }
                    else{
                        vxDataQuantativeTotal = vxDataQuantativeTotal + vxDataValueQuantMap.get('Sales');
                    }
                }
                else{
                    salesToNextTier = vxcriteriaSalesValue;
                }
                if(vxcriteriaSalesValue > 0){
                    salesPercentageToNextTier=(salesToNextTier/vxcriteriaSalesValue)*100;
                }
                else {
                    salesPercentageToNextTier=0;
                }
                
            }
            if(vxCriteraiAssociationTrainingMap.containsKey(key)){
                Decimal vxcriteriatrainingValue=(decimal.valueOf(vxCriteraiAssociationTrainingMap.get(key).PRM_Value_Txt__c.replaceAll(',','')));
                if(vxDataValueQuantMap.get('Training')!= null ){
                    trainingCreditsToNextTier= vxcriteriatrainingValue-vxDataValueQuantMap.get('Training');
                    if(trainingCreditsToNextTier<=0){
                        trainingCreditsToNextTier=0;
                        tempCriteraiAssociationQuantativeTotalMap.put(key,(tempCriteraiAssociationQuantativeTotalMap.get(key)-vxcriteriatrainingValue));
                    }
                    else{
                        vxDataQuantativeTotal = vxDataQuantativeTotal + vxDataValueQuantMap.get('Training');
                    }
                }
                else{
                    trainingCreditsToNextTier = vxcriteriatrainingValue;
                }
                if(vxcriteriatrainingValue>0){
                    trainingCreditsPercentageToNextTier=(trainingCreditsToNextTier/vxcriteriatrainingValue)*100;
                }
                else{
                    trainingCreditsPercentageToNextTier=0; 
                }
            }
            if(vxCriteriaAssociationSolutionMap.containsKey(key)){
                Decimal vxcriteriaSolutionValue=(decimal.valueOf(vxCriteriaAssociationSolutionMap.get(key).PRM_Value_Txt__c.replaceAll(',','')));
                if(vxDataValueQuantMap.get('Solutions')!= null ){
                    solutionsToNextTier= vxcriteriaSolutionValue-vxDataValueQuantMap.get('Solutions');
                    if(solutionsToNextTier<=0){
                        tempCriteraiAssociationQuantativeTotalMap.put(key,(tempCriteraiAssociationQuantativeTotalMap.get(key)-vxcriteriaSolutionValue));  
                    }
                    else{
                        vxDataQuantativeTotal = vxDataQuantativeTotal + vxDataValueQuantMap.get('Solutions');
                    }
                }
            }
            
            if(vxCriteraiAssociationEmployeeMap.containsKey(key)){
                Decimal vxcriteriaEmployeeValue=(decimal.valueOf(vxCriteraiAssociationEmployeeMap.get(key).PRM_Value_Txt__c.replaceAll(',','')));
                if(vxDataValueQuantMap.get('Employee')!= null ){
                    employeeToNextTier= vxcriteriaEmployeeValue-vxDataValueQuantMap.get('Employee');
                    if(employeeToNextTier<=0){
                        tempCriteraiAssociationQuantativeTotalMap.put(key,(tempCriteraiAssociationQuantativeTotalMap.get(key)-vxcriteriaEmployeeValue));  
                    }
                    else{
                        vxDataQuantativeTotal = vxDataQuantativeTotal + vxDataValueQuantMap.get('Employee');
                    }
                }
            }
            
            if(vxCriteraiAssociationRegistrationMap.containsKey(key)){
                Decimal vxcriteriaRegistrationValue=(decimal.valueOf(vxCriteraiAssociationRegistrationMap.get(key).PRM_Value_Txt__c.replaceAll(',','')));
                if(vxDataValueQuantMap.get('Registrations')!= null ){
                    registrationToNextTier= vxcriteriaRegistrationValue-vxDataValueQuantMap.get('Registrations');
                    if(registrationToNextTier<=0){
                        tempCriteraiAssociationQuantativeTotalMap.put(key,(tempCriteraiAssociationQuantativeTotalMap.get(key)-vxcriteriaRegistrationValue));  
                    }
                    else{
                        vxDataQuantativeTotal = vxDataQuantativeTotal + vxDataValueQuantMap.get('Registrations');
                    }
                }
            }
            
            if(vxCriteraiAssociationTotalCompetencyMap.containsKey(key)){
                Decimal vxCriteriaTotalAchievedCompetency=(decimal.valueOf(vxCriteraiAssociationTotalCompetencyMap.get(key).PRM_Value_Txt__c.replaceAll(',','')));
                if(vxDataValueQuantMap.get('TotalCompetency')!= null ){
                    totalCompetencyToNextTier= vxCriteriaTotalAchievedCompetency-vxDataValueQuantMap.get('TotalCompetency');
                    if(totalCompetencyToNextTier<=0){
                        tempCriteraiAssociationQuantativeTotalMap.put(key,(tempCriteraiAssociationQuantativeTotalMap.get(key)-vxCriteriaTotalAchievedCompetency));  
                    }
                    else{
                        vxDataQuantativeTotal = vxDataQuantativeTotal + vxDataValueQuantMap.get('TotalCompetency');
                    }
                }
            }
            
            if(tempCriteraiAssociationQuantativeTotalMap.get(key)!=0){
                percentToNextTier = ((tempCriteraiAssociationQuantativeTotalMap.get(key) - vxDataQuantativeTotal)/tempCriteraiAssociationQuantativeTotalMap.get(key))*100;
            }
            else{
                percentToNextTier=0;   
            }
        }
        calculatedValueMap.put('salesToNextTier',salesToNextTier);
        calculatedValueMap.put('salesPercentageToNextTier',salesPercentageToNextTier);
        calculatedValueMap.put('trainingCreditsToNextTier',trainingCreditsToNextTier);
        calculatedValueMap.put('trainingCreditsPercentageToNextTier',trainingCreditsPercentageToNextTier);
        calculatedValueMap.put('percentToNextTier',percentToNextTier);
        return calculatedValueMap;
    }
    
    /*
    private static List<Decimal> sortKeys(Set<Decimal> keySet){
        List<decimal> ranksList = new List<decimal>();
        ranksList.addAll(keySet);
        ranksList.sort();
        return ranksList;
    }
    */

    private static Map<String,Map<Decimal,Boolean>> populateRankingSatifiedMap(String vxDataKey,Decimal rank, Map<String,Map<Decimal,Boolean>> rankingSatisfiedQuantativeMap, Boolean flag ){
        if(rankingSatisfiedQuantativeMap.containsKey(vxDataKey))
        {
            Map<Decimal,Boolean> tempRankingMap = rankingSatisfiedQuantativeMap.get(vxDataKey);
            tempRankingMap.put(rank,flag);
            rankingSatisfiedQuantativeMap.put(vxDataKey, tempRankingMap);
        }
        else{
            rankingSatisfiedQuantativeMap.put(vxDataKey, new Map<Decimal,Boolean>{rank => flag});
        }
        return rankingSatisfiedQuantativeMap;
    }
    //This method will instialize all map for criteria association to calculate Percentage To Next Tier.
    private static void initializeAssociationMap(){
        for(PRM_Value_Exchange_Criteria_Association__c valueExchangeAssociation: [SELECT
                                                                                  Id, 
                                                                                  PRM_Value_Txt__c, 
                                                                                  PRM_Value_Exchange_Id__r.PRM_Country_Market_Type_Nm__c, 
                                                                                  PRM_Value_Exchange_Id__r.PRM_Partner_Role_Nm__c, 
                                                                                  PRM_Value_Exchange_Id__r.PRM_Channel_Program_Level_Id__r.Name,
                                                                                  PRM_Specialty_Criteria_Id__r.Name,
                                                                                  PRM_Rank_Nbr__c
                                                                                  FROM
                                                                                  PRM_Value_Exchange_Criteria_Association__c
                                                                                  WHERE
                                                                                  PRM_InActive_Ind__c  = : false
                                                                                  ORDER BY PRM_Rank_Nbr__c Asc])
        {
            string key = /*valueExchangeAssociation.PRM_Value_Exchange_Id__r.PRM_Partner_Role_Nm__c + */
                valueExchangeAssociation.PRM_Value_Exchange_Id__r.PRM_Country_Market_Type_Nm__c + 
                valueExchangeAssociation.PRM_Value_Exchange_Id__r.PRM_Channel_Program_Level_Id__r.Name;
            if(vxCriteriaAssociationMap.containsKey(key)){
                List<PRM_Value_Exchange_Criteria_Association__c> tempList = vxCriteriaAssociationMap.get(key);
                tempList.add(valueExchangeAssociation);
                vxCriteriaAssociationMap.put(key,tempList);
            } 
            else{
                vxCriteriaAssociationMap.put(key,new List<PRM_Value_Exchange_Criteria_Association__c>{valueExchangeAssociation});
            }
            if(valueExchangeAssociation.PRM_Specialty_Criteria_Id__r.Name == System.Label.PRM_QuantativeCriteria_Sales){
                if(valueExchangeAssociation.PRM_Rank_Nbr__c == 1){
                    vxCriteriaAssociationSalesMap.put(key, valueExchangeAssociation);
                }
                if(vxCriteriaAssociationAllRankSalesMap.containsKey(key)){
                    List<PRM_Value_Exchange_Criteria_Association__c> tempList = vxCriteriaAssociationAllRankSalesMap.get(key);
                    tempList.add(valueExchangeAssociation);
                    vxCriteriaAssociationAllRankSalesMap.put(key,tempList);
                } 
                else{
                    vxCriteriaAssociationAllRankSalesMap.put(key,new List<PRM_Value_Exchange_Criteria_Association__c>{valueExchangeAssociation});
                }
            }
            if(valueExchangeAssociation.PRM_Specialty_Criteria_Id__r.Name == System.Label.PRM_QuantativeCriteria_TrainingCredits && valueExchangeAssociation.PRM_Rank_Nbr__c == 1){
                vxCriteraiAssociationTrainingMap.put(key,valueExchangeAssociation);
            }
            if(valueExchangeAssociation.PRM_Specialty_Criteria_Id__r.Name == System.Label.PRM_QuantativeCriteria_NbrSolutionsMplace && valueExchangeAssociation.PRM_Rank_Nbr__c == 1){
                vxCriteriaAssociationSolutionMap.put(key,valueExchangeAssociation);
                
            }
            if(valueExchangeAssociation.PRM_Specialty_Criteria_Id__r.Name == System.Label.PRM_QuantativeCriteria_NbrEmpTraining && valueExchangeAssociation.PRM_Rank_Nbr__c == 1){
                vxCriteraiAssociationEmployeeMap.put(key,valueExchangeAssociation);
            }
            if(valueExchangeAssociation.PRM_Specialty_Criteria_Id__r.Name ==  System.Label.PRM_QuantativeCriteria_FPGA_Registrations && valueExchangeAssociation.PRM_Rank_Nbr__c == 1){  
                vxCriteraiAssociationRegistrationMap.put(key, valueExchangeAssociation);
            }
            if(valueExchangeAssociation.PRM_Specialty_Criteria_Id__r.Name ==  System.Label.PRM_QuantativeCriteria_TotalAchievedCompetency && valueExchangeAssociation.PRM_Rank_Nbr__c == 1){  
                vxCriteraiAssociationTotalCompetencyMap.put(key, valueExchangeAssociation);
            }
            if((valueExchangeAssociation.PRM_Specialty_Criteria_Id__r.Name == System.Label.PRM_QuantativeCriteria_Sales || valueExchangeAssociation.PRM_Specialty_Criteria_Id__r.Name == System.Label.PRM_QuantativeCriteria_TrainingCredits || valueExchangeAssociation.PRM_Specialty_Criteria_Id__r.Name == System.Label.PRM_QuantativeCriteria_NbrSolutionsMplace || valueExchangeAssociation.PRM_Specialty_Criteria_Id__r.Name == System.Label.PRM_QuantativeCriteria_NbrEmpTraining || valueExchangeAssociation.PRM_Specialty_Criteria_Id__r.Name == System.Label.PRM_QuantativeCriteria_FPGA_Registrations || valueExchangeAssociation.PRM_Specialty_Criteria_Id__r.Name == System.Label.PRM_QuantativeCriteria_TotalAchievedCompetency)&& valueExchangeAssociation.PRM_Rank_Nbr__c == 1){
                if(vxCriteraiAssociationQuantativeTotalMap.containsKey(key)){
                    Decimal total=vxCriteraiAssociationQuantativeTotalMap.get(key) + Decimal.valueOf(valueExchangeAssociation.PRM_Value_Txt__c.replaceAll(',',''));
                    vxCriteraiAssociationQuantativeTotalMap.put(key,total);    
                }
                else{
                    vxCriteraiAssociationQuantativeTotalMap.put(key, Decimal.valueOf(valueExchangeAssociation.PRM_Value_Txt__c.replaceAll(',','')));
                } 
            }
        }
    }
    //This method will aggregate all the vx Data record on the basis of Account, Partner Role,Market Type,Tier and OPID but different Sales Calculation Group.
    private static void populateAggregateMap(Set<Id> accountIdSet, Set<Id> opidIdSet){
        for(AggregateResult result :[SELECT  PRM_Account_Id__c,PRM_One_Partner_Id__c,/*PRM_Partner_Role_Nm__c,*/PRM_Country_Market_Type_Nm__c,PRM_Tier_Id__r.Name,sum(PRM_Sales_Amount_Nbr__c)SalesSum,min(PRM_Training_Credit_Points_Count_Nbr__c) MinTraining ,min(PRM_Design_Registration_Count_Nbr__c)MinRegistration,min(PRM_MP_Solutions_Count_Nbr__c)MinSolution,min(PRM_Number_Of_Employees_Nbr__c)MinEmployee,min(PRM_Total_Achieved_Competency_Nbr__c)MinCompetancy,count(Id) from PRM_Value_Exchange_Data__c Group BY PRM_One_Partner_Id__c,PRM_Account_Id__c,/*PRM_Partner_Role_Nm__c,*/PRM_Country_Market_Type_Nm__c,PRM_Tier_Id__r.Name Having PRM_Account_Id__c IN :accountIdSet OR PRM_One_Partner_Id__c IN :opidIdSet ORDER BY PRM_One_Partner_Id__c ASC]){ //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
            if(result.get('PRM_One_Partner_Id__c')!=null){//This will further aggregate the vx Data record for all account under same OPID,Tier,Martket Type and Partner Role.
                String keyForUpgrade=(String)result.get('PRM_One_Partner_Id__c') /*+ (String)result.get('PRM_Partner_Role_Nm__c')*/ + (String)result.get('PRM_Country_Market_Type_Nm__c') + (String)result.get('Name'); //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                if(groupByOPIDAggregateMapForUpgrade.containsKey(keyForUpgrade)){
                    Map<String,Decimal> sumMap = groupByOPIDAggregateMapForUpgrade.get(keyForUpgrade);
                    Decimal totalSales = ((Decimal)result.get('SalesSum')!=null ? (Decimal)result.get('SalesSum'):0) + sumMap.get('TotalSales');
                    Decimal trainingSum = ((Decimal)result.get('MinTraining')!=null ? (Decimal)result.get('MinTraining'):0) + sumMap.get('TrainingSum');
                    Decimal registrationSum = ((Decimal)result.get('MinRegistration')!=null ? (Decimal)result.get('MinRegistration'):0) + sumMap.get('RegistrationSum');
                    Decimal solutionSum = ((Decimal)result.get('MinSolution')!=null ? (Decimal)result.get('MinSolution'):0) + sumMap.get('SolutionSum');
                    Decimal employeeSum = ((Decimal)result.get('MinEmployee')!=null ? (Decimal)result.get('MinEmployee'):0) + sumMap.get('EmployeeSum');
                    Decimal totalAchievedCompetency = ((Decimal)result.get('MinCompetancy')!=null ? (Decimal)result.get('MinCompetancy'):0) + sumMap.get('TotalAchievedCompetency');
                    sumMap.put('TotalSales',totalSales);
                    sumMap.put('TrainingSum',trainingSum);
                    sumMap.put('RegistrationSum',registrationSum);
                    sumMap.put('SolutionSum',solutionSum);
                    sumMap.put('EmployeeSum',employeeSum);
                    sumMap.put('TotalAchievedCompetency',totalAchievedCompetency);
                    groupByOPIDAggregateMapForUpgrade.put(keyForUpgrade,sumMap);
                }
                else{
                    groupByOPIDAggregateMapForUpgrade.put(keyForUpgrade,new Map<String,Decimal>{'TotalSales' => (Decimal)result.get('SalesSum')!=null ? (Decimal)result.get('SalesSum'):0,
                        'TrainingSum' => (Decimal)result.get('MinTraining')!=null ? (Decimal)result.get('MinTraining'):0,
                            'RegistrationSum' => (Decimal)result.get('MinRegistration')!=null ? (Decimal)result.get('MinRegistration'):0,
                                'SolutionSum' => (Decimal)result.get('MinSolution')!=null ? (Decimal)result.get('MinSolution'):0,
                                    'EmployeeSum' => (Decimal)result.get('MinEmployee')!=null ? (Decimal)result.get('MinEmployee'):0,
                                        'TotalAchievedCompetency' => (Decimal)result.get('MinCompetancy')!=null ? (Decimal)result.get('MinCompetancy'):0});
                }
            }
            else{
                String keyForOPID = (String)result.get('PRM_Account_Id__c') /*+ (String)result.get('PRM_Partner_Role_Nm__c')*/ + (String)result.get('PRM_Country_Market_Type_Nm__c') + (String)result.get('Name'); //Removed partner role as part of TWC729-8087
                groupByOPIDAggregateMapForOpid.put(keyForOPID,result);
            }
        }
    }
    
    
    //wrapper class for flag check for positive value of VX Data fullfiling the crietria  
    private class CriteriaFulfilledwrapper{
        private boolean solutionFulfilledPresent= false;
        private boolean solutionFulfilled= false;
        private String solutionValue { get; set;}
        private boolean cndaPresent= false;
        private boolean cndaFulfilled= false;
        private boolean cndaValue { get; set;}
        private boolean coveragePresent= false;
        private boolean coverageFulfilled= false;
        private boolean coverageValue { get; set;}
        private boolean selectBenefitPresent= false;
        private boolean selectBenefitFulfilled= false;
        private Map<String,List<String>> selectBenfitValue = new Map<String,List<String>>();
        private boolean specialtyPresent= false;
        private boolean specialtyPresentFulfilled= false;
    }
}