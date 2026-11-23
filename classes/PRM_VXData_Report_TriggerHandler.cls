/***************************************************************************************************************************************
Apex Class Name     : PRM_VXData_Report_TriggerHandler 
Version             : 1.0
Created Date        : Sept 2020
Function            :  PRM_VXData_Report_TriggerHandler.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Dinesh                        7-Sept-2020                   This handler class will be called from trigger whenever a record is created/updated/deleted.   
* Srishty						15-Sept-2020                  Updated afterUpdate method to invoke trigger only if specific field is updated.
* Ruchi                         18 July 2025                 Removed reference for Partner role(PRM_Partner_Role_Nm__c) on VX Data Table(PRM_Value_Exchange_Data__c). Added comment "IPA Refresh 2.0 - Removed partner role as part of TWC729-8087"
**************************************************************************************************************************************/
public Without Sharing class PRM_VXData_Report_TriggerHandler extends TriggerHandler{
    //This method will call utility method when record is inserted in VX Data.
    public override void beforeInsert(){
        if(isActive('PRM_VXData_Trigger_Switch')){
            PRM_VXData_Report_Utility.updateMarketType(Trigger.new,null);
        }
    }
    //This method will call utility method when record is inserted in VX Data.
    public override void beforeUpdate(){
        if(isActive('PRM_VXData_Trigger_Switch')){
            PRM_VXData_Report_Utility.updateMarketType(Trigger.new, (Map<Id, PRM_Value_Exchange_Data__c>)Trigger.oldMap);
        }
    }
    public override void afterInsert(){
        if(isActive('PRM_VXData_Trigger_Switch')){
            PRM_VXData_Report_Utility.trainingRecordsUpdate(Trigger.new);
        }
    }
    //This method will call utility method when record is updated for specific field .
    public override void afterUpdate(){
        Map<id, PRM_Value_Exchange_Data__c> mapOldVX = (Map<id, PRM_Value_Exchange_Data__c>) Trigger.oldMap;
        list<PRM_Value_Exchange_Data__c> listNewVX = (List<PRM_Value_Exchange_Data__c>) Trigger.new;
        if(isActive('PRM_VXData_Trigger_Switch')){
        List<PRM_Value_Exchange_Data__c> vxUpdateList = new List<PRM_Value_Exchange_Data__c>();
  List<PRM_Value_Exchange_Data__c> vxDataList = new List<PRM_Value_Exchange_Data__c>();
  for (PRM_Value_Exchange_Data__c newVX : listNewVX) {
  PRM_Value_Exchange_Data__c oldVX = mapOldVX.get(newVX.id);
  
                if(oldVX.PRM_Training_Credit_Points_Count_Nbr__c!= newVX.PRM_Training_Credit_Points_Count_Nbr__c
                   || oldVX.PRM_Sales_Amount_Nbr__c != newVX.PRM_Sales_Amount_Nbr__c 
                   || oldVX.PRM_Total_Achieved_Competency_Nbr__c != newVX.PRM_Total_Achieved_Competency_Nbr__c
                   || oldVX.PRM_MP_Solutions_Count_Nbr__c != newVX.PRM_MP_Solutions_Count_Nbr__c
                   || oldVX.PRM_Training_Credits_to_Next_Tier_Nbr__c != newVX.PRM_Training_Credits_to_Next_Tier_Nbr__c
                   || oldVX.PRM_Sales_To_Next_Tier_Nbr__c != newVX.PRM_Sales_To_Next_Tier_Nbr__c
                   || oldVX.PRM_Total_Sales_Out_Units_Nbr__c != newVX.PRM_Total_Sales_Out_Units_Nbr__c
                   || oldVX.PRM_Sales_Calculation_Group_Txt__c != newVX.PRM_Sales_Calculation_Group_Txt__c
                   || oldVX.PRM_Account_Id__c != newVX.PRM_Account_Id__c
                   /*|| oldVX.PRM_Partner_Role_Nm__c != newVX.PRM_Partner_Role_Nm__c*/ //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                   || oldVX.PRM_Processed_Date_Time_Dt__c != newVX.PRM_Processed_Date_Time_Dt__c
                   || oldVX.PRM_One_Partner_Id__c != newVX.PRM_One_Partner_Id__c
                  ){
                      vxUpdateList.add(newVX);
                  }
      if (
                    newVX.PRM_Percent_to_next_tier_Nbr__c !=
                    oldVX.PRM_Percent_to_next_tier_Nbr__c
                ) {
                    vxDataList.add(newVX);
                }
            }
      if (!vxUpdateList.isEmpty() || !vxDataList.isEmpty()){
      PRM_VXData_Report_Utility.trainingRecordsUpdate(vxUpdateList);
            }
            
        }
    }
    //This method will call utility method when VX Data record is deleted .
    public override void afterDelete(){
        if(isActive('PRM_VXData_Trigger_Switch')){
            PRM_VXData_Report_Utility.trainingRecordsUpdate(Trigger.old);
	    }
    }
    
    
}