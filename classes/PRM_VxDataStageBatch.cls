/**************************************************************************************************************************************************************************
Apex Class Name     : PRM_VxDataStageBatch 
Version             : 1.01
Created Date        : October 2020
Function            : Batch class to upsert list of VxData records with mapping of Partner Role value from ValueExchangeStage records and to update Processed Date of VxStage.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ----------------------------------------------------------------------------------------------------------------------------------------------
Tejasree                            1-OCT-2020                   Start method will return all VXStage records where isChangedIndicator=true.
Srishty                             5-OCT-2020                   Optimised Batch class method and query.
***************************************************************************************************************************************************************************/
public class PRM_VxDataStageBatch implements Database.Batchable<sObject>,Database.Stateful{
  public static String VXUCDTable=System.label.PRM_VXSwitch;
    //public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh);
    public static Database.QueryLocator start(Database.BatchableContext batchContext){  //Returns all VxStage reocrds where Changed Date > Processed Date 
        //IPA 2.0 -temporary fix for vx batch issue 
        List<Id> newTierIds = new List<Id>();
        for(ChannelProgramLevel tierid : [SELECT Id FROM ChannelProgramLevel where name in ('Prestige','Partner')]){
            newTierIds.add(tierid.Id);
        }
        String query = '';
        /*if(IPARefresh || test.isRunningTest()){*/
            if(VXUCDTable == 'TRUE' || test.isrunningtest()){
                query ='Select Id,Name,PRM_Time_Period__c,PRM_Account_Id__c,PRM_Batch_Status_Nm__c,PRM_Change_Date_Dt__c,PRM_Country_Market_Type_Nm__c,PRM_Design_Registration_Count_Nbr__c,PRM_From_Dt__c,PRM_IsChanged_Ind__c,PRM_MP_Solutions_Count_Nbr__c,PRM_Number_Of_Employees_Nbr__c,PRM_One_Partner_Id__c,PRM_Partner_Role_Nm__c,PRM_Processed_Date_Time_Dt__c,PRM_Revenue_Source_Txt__c,PRM_Sales_Amount_Nbr__c,PRM_Sales_Calculation_Group_Txt__c,PRM_Tier_Id__c,PRM_To_Dt__c,PRM_Total_Achieved_Competency_Nbr__c,PRM_Total_Sales_Out_Units_Nbr__c,PRM_Training_Credit_Points_Count_Nbr__c,PRM_Type_Of_Solutions_Txt__c,PRM_Value_Exchange_ext_id__c from PRM_Value_Exchange_UCD_Stage__c Where PRM_IsChanged_Ind__c=true and PRM_Tier_Id__c IN: newTierIds Order by PRM_One_Partner_Id__c';
            }
            else{
                query ='Select Id,Name,PRM_Time_Period__c,PRM_Account_Id__c,PRM_Batch_Status_Nm__c,PRM_Change_Date_Dt__c,PRM_Country_Market_Type_Nm__c,PRM_Design_Registration_Count_Nbr__c,PRM_From_Dt__c,PRM_IsChanged_Ind__c,PRM_MP_Solutions_Count_Nbr__c,PRM_Number_Of_Employees_Nbr__c,PRM_One_Partner_Id__c,PRM_Partner_Role_Nm__c,PRM_Processed_Date_Time_Dt__c,PRM_Revenue_Source_Txt__c,PRM_Sales_Amount_Nbr__c,PRM_Sales_Calculation_Group_Txt__c,PRM_Tier_Id__c,PRM_To_Dt__c,PRM_Total_Achieved_Competency_Nbr__c,PRM_Total_Sales_Out_Units_Nbr__c,PRM_Training_Credit_Points_Count_Nbr__c,PRM_Type_Of_Solutions_Txt__c,PRM_Value_Exchange_ext_id__c from PRM_Value_Exchange_Stage__c Where PRM_IsChanged_Ind__c=true and PRM_Tier_Id__c IN: newTierIds Order by PRM_One_Partner_Id__c';
            }
            
        //}
        /*if(!IPARefresh || test.isRunningTest()){
            if(VXUCDTable == 'TRUE' || test.isrunningtest()){
                query ='Select Id,Name,PRM_Time_Period__c,PRM_Account_Id__c,PRM_Batch_Status_Nm__c,PRM_Change_Date_Dt__c,PRM_Country_Market_Type_Nm__c,PRM_Design_Registration_Count_Nbr__c,PRM_From_Dt__c,PRM_IsChanged_Ind__c,PRM_MP_Solutions_Count_Nbr__c,PRM_Number_Of_Employees_Nbr__c,PRM_One_Partner_Id__c,PRM_Partner_Role_Nm__c,PRM_Processed_Date_Time_Dt__c,PRM_Revenue_Source_Txt__c,PRM_Sales_Amount_Nbr__c,PRM_Sales_Calculation_Group_Txt__c,PRM_Tier_Id__c,PRM_To_Dt__c,PRM_Total_Achieved_Competency_Nbr__c,PRM_Total_Sales_Out_Units_Nbr__c,PRM_Training_Credit_Points_Count_Nbr__c,PRM_Type_Of_Solutions_Txt__c,PRM_Value_Exchange_ext_id__c from PRM_Value_Exchange_UCD_Stage__c Where PRM_IsChanged_Ind__c=true and PRM_Tier_Id__c NOT IN: newTierIds Order by PRM_One_Partner_Id__c';
            }
            else{
                query ='Select Id,Name,PRM_Time_Period__c,PRM_Account_Id__c,PRM_Batch_Status_Nm__c,PRM_Change_Date_Dt__c,PRM_Country_Market_Type_Nm__c,PRM_Design_Registration_Count_Nbr__c,PRM_From_Dt__c,PRM_IsChanged_Ind__c,PRM_MP_Solutions_Count_Nbr__c,PRM_Number_Of_Employees_Nbr__c,PRM_One_Partner_Id__c,PRM_Partner_Role_Nm__c,PRM_Processed_Date_Time_Dt__c,PRM_Revenue_Source_Txt__c,PRM_Sales_Amount_Nbr__c,PRM_Sales_Calculation_Group_Txt__c,PRM_Tier_Id__c,PRM_To_Dt__c,PRM_Total_Achieved_Competency_Nbr__c,PRM_Total_Sales_Out_Units_Nbr__c,PRM_Training_Credit_Points_Count_Nbr__c,PRM_Type_Of_Solutions_Txt__c,PRM_Value_Exchange_ext_id__c from PRM_Value_Exchange_Stage__c Where PRM_IsChanged_Ind__c=true and PRM_Tier_Id__c NOT IN: newTierIds Order by PRM_One_Partner_Id__c';
            }
        }*/ // IPA Refresh - switch removal
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext batchContext, List<PRM_Value_Exchange_UCD_Stage__c> scope){ //Execute method to pass returned list of VxStage records to utility class
            PRM_VxDataStageBatchUtility vxStageBatch=new PRM_VxDataStageBatchUtility(scope);
    }
    
    public void finish(Database.BatchableContext batchContext){   //Calling OPIDTriggerBatch 
        PRM_OPIDTriggerBatch opidTriggerBatch = new PRM_OPIDTriggerBatch();
        ID batchprocessid = Database.executeBatch(opidTriggerBatch,Integer.valueOf(Label.PRM_OPID_VxBatch)); //Executing OPIDTriggerBatch with 500 as Batch Size
    }    
}