/***************************************************************************************************************************************
Apex Class Name     : PRM_OPIDTriggerBatch 
Version             : 1.01
Created Date        : March 2020
Function            : Batch class to provide OPID Recommendations.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                        4-March-2020                     US599996-Start method will return all the VX data with OPID null.
* Srishty              24-March-2020            US570458-Added the condition to return vx data with OPID 
for upgrade scenario
*Srishty             3-April-2020             US619504-Added the aggregate query for quantiative criteria for 
Upgrade Recommendation
*Srishty                        24-April-2020                     US643150-Added 'Total Nbr Achieved Competency' field and replaced 'Competency Achieved field' from VX data and VX Recommendation 
*Srishty                        4-May-2020                        US638610,US632701,US638612-Optimized Execute Method 
*Srishty                        13-May-2020                       Start Method query result was optimised by using PRM_IsChanged_Ind__c formula field which will return 
only those records which needs to be processed.
*Srishty            12-June-2020           PRM_FPGA_Project_Registration_Count_Nbr__c replaced by PRM_Design_Registration_Count_Nbr__c field.
*************************************************************************************************************************************/

public class PRM_OPIDTriggerBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    public static Database.QueryLocator start(Database.BatchableContext context){
        
        String query='Select Id,PRM_Sales_Amount_Nbr__c,PRM_Total_Achieved_Competency_Nbr__c,PRM_Design_Registration_Count_Nbr__c,PRM_MP_Solutions_Count_Nbr__c,PRM_Number_Of_Employees_Nbr__c,PRM_Type_Of_Solutions_Txt__c,PRM_Country_Market_Type_Nm__c,PRM_One_Partner_Id__c,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.Core_CNDA_Number__c,PRM_Account_Id__r.Core_Covered_Account__c,PRM_Partner_Role_Nm__c,PRM_Tier_Id__r.Name,PRM_Change_Date_Dt__c,PRM_Processed_Date_Time_Dt__c,PRM_Training_Credit_Points_Count_Nbr__c,PRM_Sales_Calculation_Group_Txt__c,PRM_Revenue_Source_Txt__c from PRM_Value_Exchange_Data__c  where PRM_IsChanged_Ind__c = true Order By PRM_One_Partner_Id__c';    
        return Database.getQueryLocator(query);//only those records with Processed Date less than Changed Date or Process Date Is null will be returned by Start Method 
    }
    
    public void execute(Database.BatchableContext context, List<PRM_Value_Exchange_Data__c> scope){
        PRM_OPIDTriggerBatchUtility opidTriggerBatch = new PRM_OPIDTriggerBatchUtility(scope); //calling constructor of utility class and passing the scope.
    }
    
    public void finish(Database.BatchableContext context){
        
    }
    
}