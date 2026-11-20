/**************************************************************************************************************************************************************************
Apex Class Name     : PRM_VxDataStageBatchUtility 
Version             : 1.01
Created Date        : October 2020
Function            : Utility class to upsert list of VxData records with mapping of all field values from ValueExchangeStage records and to update Processed Date of VxStage.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ----------------------------------------------------------------------------------------------------------------------------------------------
Tejasree                            1-OCT-2020                    To upsert VxData records by populating all field values from VxStage records and to update Processed Date,Batch Status fields on VxDataStage
Srishty                             05-Oct-2020                   if Non IPA Account come in VX Stage record then market type will be populated 
in VX data from if one of the location account based on combination of OPID+Partner+Tier
optimised the mehtods and class variables.

* Ruchi                         18 July 2025                 Removed reference for Partner role(PRM_Partner_Role_Nm__c) on VX Data Table(PRM_Value_Exchange_Data__c). Added comment "IPA Refresh 2.0 - Removed partner role as part of TWC729-8087"
***************************************************************************************************************************************************************************/
public without sharing class PRM_VxDataStageBatchUtility {
    @TestVisible
    private static final string ORIGIN = 'PRM_VxDataStageBatchUtility';
    private static final string SEVERITY = 'Critical';
    private static final string PROJECT = 'IPA';
    private static final string ERROR_MESSAGE = 'Too many DML rows';
    private static final string SUCCESS = 'Success';
    private static final string FAILURE = 'Failure';
    private static final string NA = 'NA';
    private static Map<String,String> mapOfPicklistValues = new Map<String,String>();
    private static Map<String,String> groupMethodMap =  new Map<String,String>();
	public static Map<String,PRM_Value_Exchange_Data__c> UpdateExistingVXData = new Map<String,PRM_Value_Exchange_Data__c>();
    //Constructor where scope is passed from execute method of batch class 
    public PRM_VxDataStageBatchUtility(List<PRM_Value_Exchange_UCD_Stage__c> scope){
        //Using Schema methods to retrieve all picklist values of Partner Role field on Value Exchange Data.
        //Schema.DescribeFieldResult fieldResult = PRM_Value_Exchange_Data__c.PRM_Account_Id__r.Core_IPA_Partner_Role__c.getDescribe(); //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
        //List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues(); //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
        Map<String,String> opidPartnerCountryWithCountryTypeMap = new Map<String,String>();//map of OPID Partner Role+Tier with value country market type of VX stage records  
        Set<String> opidSet=new Set<String>();//Set of OPID from VX Stage record which is picked by batch.
        Set<String> intelaccountSet=new Set<String>();//Set of Account Id of location account of VX stage record
        /*for(Schema.PicklistEntry pickListVal : picklistEntry){
            if(pickListVal.isActive()){
                mapOfPicklistValues.put(pickListVal.getLabel(),pickListVal.getValue()); //Mapping picklist values with their respective Picklist label as Key 
            } 
        } //loop ends here*/ //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
        System.debug(LoggingLevel.INFO, 'Before building ID sets, heap=' + Limits.getHeapSize());
        

        for(PRM_Value_Exchange_UCD_Stage__c stageOPID:scope){
            if(stageOPID.PRM_One_Partner_Id__c!=null){
                opidSet.add(stageOPID.PRM_One_Partner_Id__c);//set of OPID which is picked by batch.
                if(stageOPID.PRM_Account_Id__c!=stageOPID.PRM_One_Partner_Id__c){
                    intelaccountSet.add(stageOPID.PRM_Account_Id__c); // set of intel accounts picked by batch
                }
            }
        } //loop ends here

        

        for(PRM_Value_Exchange_UCD_Stage__c vxStageWithOPID:[Select Id,PRM_Country_Market_Type_Nm__c,PRM_Account_Id__c,
                                                         /*PRM_Partner_Role_Nm__c,*/PRM_Tier_Id__c ,PRM_Time_Period__c,PRM_One_Partner_Id__c
                                                         from PRM_Value_Exchange_UCD_Stage__c where PRM_One_Partner_Id__c IN:opidSet OR PRM_Account_Id__c IN:intelaccountSet]){ //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                                                             //loop start here
                                                                 String key= vxStageWithOPID.PRM_Account_Id__c/*+vxStageWithOPID.PRM_Partner_Role_Nm__c+vxStageWithOPID.PRM_Tier_Id__c*/; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087 -- tier might cause a problem here if 1pid have more than 1 acm with diff tier, so removed tier as well
                                                                    if(!opidPartnerCountryWithCountryTypeMap.containsKey(key)){
                                                                            if(!String.isBlank(vxStageWithOPID.PRM_Country_Market_Type_Nm__c)){
                                                                                    opidPartnerCountryWithCountryTypeMap.put(key,vxStageWithOPID.PRM_Country_Market_Type_Nm__c);//if Country Market Type of location account is not null, then adding location account's CountryMarketType as value with key as OPID+PartnerRole+Tier 
                                                                            }
                                                                            else{
                                                                                    opidPartnerCountryWithCountryTypeMap.put(key,NA); //if Country Market Type of location account is null, then adding NA as value with key as OPID+PartnerRole+Tier 
                                                                            }
                                                                    }
                                                                    else if ((((opidPartnerCountryWithCountryTypeMap.get(key) == 'Emerging') || (opidPartnerCountryWithCountryTypeMap.get(key) == NA)) && (vxStageWithOPID.PRM_Country_Market_Type_Nm__c == 'Mature')) || ((opidPartnerCountryWithCountryTypeMap.get(key) == NA) && (vxStageWithOPID.PRM_Country_Market_Type_Nm__c == 'Emerging'))){
                                                                            opidPartnerCountryWithCountryTypeMap.put(key,vxStageWithOPID.PRM_Country_Market_Type_Nm__c);
                                                                    }
                                                         }//loop end here...

        addVxDataList(scope,opidPartnerCountryWithCountryTypeMap); //method to update VX data list with correct partner role and market type mapping 
    }
    
    //Method to populate VXStage fields Values to VxData field values with proper Partner Role and Market type field.
    private static void addVxDataList(List<PRM_Value_Exchange_UCD_Stage__c> vxStageList,Map<String,String> opidPartnerCountryWithCountryTypeMap){
        //IPA Refresh 2.0 - Added to check duplicate VX Data check as part of TWC729-8087
		Map<String,PRM_Value_Exchange_UCD_Stage__c> UniqueVXDataRecordtoInsert = new Map<String,PRM_Value_Exchange_UCD_Stage__c>();
        Map<String,PRM_Value_Exchange_Data__c> ExistingVXData = new Map<String,PRM_Value_Exchange_Data__c>();// Map of Existing VX Data in main table
        List<PRM_Value_Exchange_UCD_Stage__c> FinalVXDataToInsert = new List<PRM_Value_Exchange_UCD_Stage__c>();//List of VXData records which needs to be updated
        List<Id> Accountfortiermap = new List<Id>();//list of Account Ids from VXStage records
        // PB fix
        Set<id> accountIds = new Set<id>();
        Set<String> salesCalcTextList = new Set<String>();
        Set<String> timePeriodList = new Set<String>();
        for(PRM_Value_Exchange_UCD_Stage__c stageOPID:vxStageList){
            accountIds.add(stageOPID.PRM_Account_Id__c);
            salesCalcTextList.add(stageOPID.PRM_Sales_Calculation_Group_Txt__c);
            timePeriodList.add(stageOPID.PRM_Time_Period__c);
        }
        for( PRM_Value_Exchange_Data__c ExistingVXDataRecord : [Select Id,Name,PRM_Account_Id__c,PRM_One_Partner_Id__c,
                                            PRM_Training_Credit_Points_Count_Nbr__c,PRM_Training_Credit_Points_Report_Nbr__c, 
                                            PRM_Training_credits_tier_report_Nbr__c, PRM_Training_credit_to_next_tier_per_nbr__c,
                                            PRM_Training_Credits_to_Next_Tier_Nbr__c,PRM_MP_Solutions_Count_Report_Nbr__c,
                                            PRM_MP_Solutions_Count_Nbr__c,PRM_Total_Achieved_Competency_Nbr__c,PRM_Country_Market_Type_Nm__c,
                                            PRM_Total_Achieved_Competency_Report_Nbr__c,PRM_Sales_Amount_Report_Nbr__c,PRM_Sales_Amount_Nbr__c,
                                            PRM_Sales_To_Next_Tier_Report_Nbr__c,PRM_Sales_To_Next_Tier_Nbr__c,
                                            PRM_Total_Sales_Out_Units_Report_Nbr__c,PRM_Total_Sales_Out_Units_Nbr__c,
                                            PRM_Percent_to_next_tier_Nbr__c,PRM_Value_Exchange_ext_id__c,PRM_Sales_Calculation_Group_Txt__c,PRM_Processed_Date_Time_Dt__c,PRM_TimePeriod_Nm__c
                                            from PRM_Value_Exchange_Data__c where PRM_Account_Id__c IN :accountIds and PRM_Sales_Calculation_Group_Txt__c IN :salesCalcTextList and PRM_TimePeriod_Nm__c IN :timePeriodList]){
                                                String key = ExistingVXDataRecord.PRM_Account_Id__c + ExistingVXDataRecord.PRM_Sales_Calculation_Group_Txt__c + ExistingVXDataRecord.PRM_TimePeriod_Nm__c +ExistingVXDataRecord.PRM_Sales_Amount_Nbr__c + ExistingVXDataRecord.PRM_Total_Sales_Out_Units_Nbr__c + ExistingVXDataRecord.PRM_Training_Credit_Points_Count_Nbr__c; 
												String externalIdKey = ExistingVXDataRecord.PRM_Account_Id__c + ExistingVXDataRecord.PRM_Sales_Calculation_Group_Txt__c + ExistingVXDataRecord.PRM_TimePeriod_Nm__c;
												ExistingVXData.put(key,ExistingVXDataRecord);
												UpdateExistingVXData.put(externalIdKey,ExistingVXDataRecord);
											}                                
        for(PRM_Value_Exchange_UCD_Stage__c stageOPID:vxStageList){
            String key = stageOPID.PRM_Account_Id__c + stageOPID.PRM_Sales_Calculation_Group_Txt__c + stageOPID.PRM_Time_Period__c +stageOPID.PRM_Sales_Amount_Nbr__c + stageOPID.PRM_Total_Sales_Out_Units_Nbr__c + stageOPID.PRM_Training_Credit_Points_Count_Nbr__c; 
            if((!(UniqueVXDataRecordtoInsert.containsKey(key))) && (!(ExistingVXData.containsKey(key)))){ 
                UniqueVXDataRecordtoInsert.put(key,stageOPID); 
                FinalVXDataToInsert.add(stageOPID);
                Accountfortiermap.add(stageOPID.PRM_Account_Id__c);
            }
        }
        List<PRM_Value_Exchange_Data__c> listOfVxData = new List<PRM_Value_Exchange_Data__c>();
        List<PRM_Value_Exchange_UCD_Stage__c> listOfVxStageWithSameOpidAndAcc = new List<PRM_Value_Exchange_UCD_Stage__c>();//Non IPA Account list
        Map<String,PRM_Value_Exchange_UCD_Stage__c> vxExternalIdWithStageMap = new Map<String,PRM_Value_Exchange_UCD_Stage__c>();//Map if VVX stage with external Id

        Map<String,Id> TierStringIdMap = new Map<String,Id>();
        for(ChannelProgramLevel tier : [SELECT Id,Name FROM ChannelProgramLevel]){
            TierStringIdMap.put(tier.Name,tier.Id);
        }

        Map<String,String> AccountTierMap = new Map<String,String>();
        for(Account accId: [SELECT id,Core_IPA_Badge_Tier__c from account where id in:Accountfortiermap]){
            Id tierId= TierStringIdMap.get(accId.Core_IPA_Badge_Tier__c);
            AccountTierMap.put(accId.id,tierId);
        }
        
        
        for(PRM_Value_Exchange_UCD_Stage__c vxStage:FinalVXDataToInsert) {
            vxExternalIdWIthStageMap.put(vxStage.PRM_Value_Exchange_ext_id__c,vxStage); 
            if(vxStage.PRM_One_Partner_Id__c!=vxStage.PRM_Account_Id__c){
                    String key = vxStage.PRM_Account_Id__c;       
                    PRM_Value_Exchange_Data__c vxData = populateVxDataRecord(vxStage);//Calling method for vxData record creation                
                    vxData.PRM_Country_Market_Type_Nm__c=opidPartnerCountryWithCountryTypeMap.get(key);
                    vxData.PRM_Tier_Id__c=AccountTierMap.get(key);
                    listOfVxData.add(vxData);//list of VX data record with Account Id as location account.
            }
            else{
                listOfVxStageWithSameOpidAndAcc.add(vxStage);//list of non ipa account of VX stage record
            }
        }//loop ends here
        for(PRM_Value_Exchange_UCD_Stage__c vxStage:listOfVxStageWithSameOpidAndAcc){
            String key = vxStage.PRM_One_Partner_Id__c/*+vxStage.PRM_Partner_Role_Nm__c+vxStage.PRM_Tier_Id__c*/; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
            PRM_Value_Exchange_Data__c vxData = populateVxDataRecord(vxStage); //Calling method for creation of vxData
            vxData.PRM_Country_Market_Type_Nm__c = opidPartnerCountryWithCountryTypeMap.get(key);
            vxData.PRM_Tier_Id__c=AccountTierMap.get(key);
            listOfVxData.add(vxData);
        }//loop ends here
		upsertVxData(listOfVxData,vxExternalIdWithStageMap); //Calling upsertVxData method 
    }
    
    /*
    private static void DisplayDataOnTimePeriod(List<PRM_Value_Exchange_Stage__c> vxStageRecord){
        list<PRM_Value_Exchange_Stage__c> valueLst=new list<PRM_Value_Exchange_Stage__c>();
        for(PRM_Value_Exchange_Stage__c v:vxStageRecord){
            if(v.PRM_From_Dt__c.month()>=Integer.valueOf(Label.PRM_Vx_Frommonth_for_Report) && v.PRM_To_Dt__c.month()<=Integer.valueOf(Label.PRM_Vx_Tomonth_for_Report) && (v.PRM_From_Dt__c.year()==system.today().year()-2 && v.PRM_To_Dt__c.year()==(system.today().year()-1)) || (v.PRM_From_Dt__c.year()==system.today().year()-1 && v.PRM_To_Dt__c.year()==(system.today().year()))){
                 populateVxDataRecord(v);
            }
        }
     }
     */
    
    //Method to populate vx data record from vx stage
    private static PRM_Value_Exchange_Data__c populateVxDataRecord(PRM_Value_Exchange_UCD_Stage__c vxStageRecord){
        PRM_Value_Exchange_Data__c vxData = new PRM_Value_Exchange_Data__c();
		String externalIdKey = vxStageRecord.PRM_Account_Id__c + vxStageRecord.PRM_Sales_Calculation_Group_Txt__c + vxStageRecord.PRM_Time_Period__c;
        if((UpdateExistingVXData.containsKey(externalIdKey))){
			vxData.Id=UpdateExistingVXData.get(externalIdKey).Id;
		}
		vxData.Name=vxStageRecord.Name;
        vxData.PRM_Account_Id__c=vxStageRecord.PRM_Account_Id__c;
        vxData.PRM_Change_Date_Dt__c=vxStageRecord.PRM_Change_Date_Dt__c;
        vxData.PRM_Design_Registration_Count_Nbr__c=vxStageRecord.PRM_Design_Registration_Count_Nbr__c;
        vxData.PRM_From_Dt__c=vxStageRecord.PRM_From_Dt__c;
        vxData.PRM_MP_Solutions_Count_Nbr__c=vxStageRecord.PRM_MP_Solutions_Count_Nbr__c;
        vxData.PRM_Number_Of_Employees_Nbr__c=vxStageRecord.PRM_Number_Of_Employees_Nbr__c;
        vxData.PRM_One_Partner_Id__c=(vxStageRecord.PRM_One_Partner_Id__c != '-1')? vxStageRecord.PRM_One_Partner_Id__c:null;
        /*if(mapOfPicklistValues.containsKey(vxStageRecord.PRM_Partner_Role_Nm__c)){
            vxData.PRM_Partner_Role_Nm__c = mapOfPicklistValues.get(vxStageRecord.PRM_Partner_Role_Nm__c);
        }*/ //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
        vxData.PRM_Revenue_Source_Txt__c=vxStageRecord.PRM_Revenue_Source_Txt__c;
        vxData.PRM_Sales_Amount_Nbr__c=vxStageRecord.PRM_Sales_Amount_Nbr__c;
        vxData.PRM_Sales_Calculation_Group_Txt__c=vxStageRecord.PRM_Sales_Calculation_Group_Txt__c;
        //vxData.PRM_Tier_Id__c=vxStageRecord.PRM_Tier_Id__c; //IPA Refresh 2.0 - Stores account's tier as part of TWC729-8087
        vxData.PRM_To_Dt__c=vxStageRecord.PRM_To_Dt__c;
        vxData.PRM_Total_Achieved_Competency_Nbr__c=vxStageRecord.PRM_Total_Achieved_Competency_Nbr__c;
        vxData.PRM_Total_Sales_Out_Units_Nbr__c=vxStageRecord.PRM_Total_Sales_Out_Units_Nbr__c;
        vxData.PRM_Training_Credit_Points_Count_Nbr__c=vxStageRecord.PRM_Training_Credit_Points_Count_Nbr__c;
        vxData.PRM_Type_Of_Solutions_Txt__c=vxStageRecord.PRM_Type_Of_Solutions_Txt__c;
		vxData.PRM_Value_Exchange_ext_id__c=vxStageRecord.PRM_Value_Exchange_ext_id__c;
		vxData.PRM_TimePeriod_Nm__c=vxStageRecord.PRM_Time_Period__c;
        return vxData;
    }
    
    //Method to upsert Vx Data records and if any failure records are found, error logs will be generated for the same
    private static void upsertVxData(List<PRM_Value_Exchange_Data__c> vxDataList,Map<String,PRM_Value_Exchange_UCD_Stage__c> vxExternalIdWithStageMap){
        List<Database.UpsertResult> upsertResultList = new List<Database.UpsertResult>();
        List<PRM_Value_Exchange_UCD_Stage__c> updateVxStageList=new List<PRM_Value_Exchange_UCD_Stage__c>();
        if(vxDataList.size() < Limits.getLimitDMLRows() && !vxDataList.isEmpty() && vxDataList.size()>0){
			upsertResultList=Database.upsert(vxDataList,PRM_Value_Exchange_Data__c.Fields.Id,false);
			integer index = 0;
            for(Database.UpsertResult result: upsertResultList)
            {
                if(!result.isSuccess()){
                    Id sId;
                    string sObjectType = '';
                    string tags = '';
                    for(Database.Error err: result.getErrors()){
                        sId = vxDataList[index].Id;
                        if(sId != null){
                            sObjectType = sId.getSObjectType().getDescribe().getName();
                        }
                        string accName = '';
                        accName = vxDataList[index].PRM_Account_Id__r.Name;
                        /*string partnerRoleName = '';
                        partnerRoleName = vxDataList[index].PRM_Account_Id__r.Core_IPA_Partner_Role__c; ////IPA Refresh 2.0 - Removed partner role as part of TWC729-8087*/
                        string marketType = '';
                        marketType = vxDataList[index].PRM_Country_Market_Type_Nm__c;
                        tags = accName + ';' + marketType;
                        Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, err.getMessage(), '', sId, sObjectType, tags);//Calling existing method to track error logs
                    }
                    PRM_Value_Exchange_UCD_Stage__c vxStageToUpdateFailure= vxExternalIdWithStageMap.get(vxDataList[index].PRM_Value_Exchange_ext_id__c);
                    vxStageToUpdateFailure.PRM_Batch_Status_Nm__c=FAILURE;
                    //vxStageToUpdateFailure.PRM_Notes_Txt__c=
                    updateVxStageList.add(vxStageToUpdateFailure);//adding records in list of VXstage with failure status
                }
                else{
                    PRM_Value_Exchange_UCD_Stage__c vxStageToUpdateSuccess= vxExternalIdWithStageMap.get(vxDataList[index].PRM_Value_Exchange_ext_id__c);
                    vxStageToUpdateSuccess.PRM_Batch_Status_Nm__c=SUCCESS;
                    vxStageToUpdateSuccess.PRM_Processed_Date_Time_Dt__c = System.now();
                    updateVxStageList.add(vxStageToUpdateSuccess);//adding records in list of VXstage with success status
                }
                index++;
            } //loop ends here
            
        }
        else{
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, ERROR_MESSAGE, '', '', '', '');
        }
        if(!updateVxStageList.isEmpty() && updateVxStageList.size()>0 && updateVxStageList != null){
       updateVxData(updateVxStageList);
        }
    }
    public static void updateVxData(List<PRM_Value_Exchange_UCD_Stage__c> updateVxStageList){
        try{
            if(!updateVxStageList.isEmpty() && updateVxStageList.size()>0){
                update updateVxStageList;// Updating list of processed VX stage records
            }
        }
        catch(Exception e){
           // system.debug('Exception occured' +e.getMessage());
        } 
    }    
}