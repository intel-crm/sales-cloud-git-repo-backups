/****************************************************************************************************
Apex Trigger Name : Pricing_QuoteLineStatusAgeHandler
Version         : 1.0 
Created Date    : 18/10/2022
Function        : This class is used used as part of Quote Line Status Age trigger
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rahul                     18/10/2022               Created
*****************************************************************************************************/
public without sharing class Pricing_QuoteLineStatusAgeHandler extends TriggerHandler{
    
    /**
* @description afterInsert - Overriding method to share the Quote Line Status Age records with the public group
* @author Rahul Maindalkar | 18-10-2022 
**/      
    public override void afterInsert() {
        List<Pricing_Quote_Line_Status_Age__c> qlStatusAgeList = New List<Pricing_Quote_Line_Status_Age__c>();
        qlStatusAgeList = [Select Id, Pricing_TPT_Share_Required__c, Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__r.SBQQ__Account__c from Pricing_Quote_Line_Status_Age__c where Id in: Trigger.NewMap.keySet() and Pricing_TPT_Share_Required__c=True];
        shareTPTRecords(qlStatusAgeList);
    }
    
    /**
* @description afterInsert - Method is created to share the Quote Line Status Age records with the public group
* @author Rahul Maindalkar | 18-10-2022
* @param qlStatusAgeList 
**/    
    public static Set<Id> shareTPTRecords(List<Pricing_Quote_Line_Status_Age__c> qlStatusAgeList){
        Set<Id> accountIds = New Set<Id>();
        List<Pricing_Quote_Line_Status_Age__Share> TPTShare = new List<Pricing_Quote_Line_Status_Age__Share>();		
        Map<Id,Set<Id>> accountTPTToGroupIdMap = new  Map<Id,Set<Id>>(); 
        Set<Id> tptIds = New Set<Id>();        
        for(Pricing_Quote_Line_Status_Age__c qlStatusAge : qlStatusAgeList){
            if(qlStatusAge.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__r.SBQQ__Account__c!=Null){
                accountIds.add(qlStatusAge.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__r.SBQQ__Account__c);
            }
        }
        if(!accountIds.isEmpty()){
            for(Core_MDF_Partner_Group_Mapping__c partnerGroup : [select Id,Core_MDF_Account__c,Core_MDF_Channel_Program_Name_Txt__c,Core_MDF_Channel_Program__c,Core_MDF_AccountIdGroupName__c,Core_MDF_Group_Id__c,Core_MDF_Type_of_Access__c from Core_MDF_Partner_Group_Mapping__c where
                                                                  Core_MDF_Channel_Program_Name_Txt__c =: Label.Pricing_Tender_PGM_Channel and Core_MDF_Account__c in : accountIds and Core_MDF_Group_Id__c!=null]){
                                                                      
                                                                      if(!accountTPTToGroupIdMap.containsKey(partnerGroup.Core_MDF_Account__c) && partnerGroup.Core_MDF_Type_of_Access__c == Label.Pricing_Tender_PGM_Type){
                                                                          accountTPTToGroupIdMap.put(partnerGroup.Core_MDF_Account__c,new Set<Id>{partnerGroup.Core_MDF_Group_Id__c});
                                                                      }
                                                                      else if(partnerGroup.Core_MDF_Type_of_Access__c == Label.Pricing_Tender_PGM_Type) {
                                                                          accountTPTToGroupIdMap.get(partnerGroup.Core_MDF_Account__c).add(partnerGroup.Core_MDF_Group_Id__c);
                                                                      }
                                                                  }
        }
        
        for(Pricing_Quote_Line_Status_Age__c qlStatusAge : qlStatusAgeList){
            if(qlStatusAge.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__r.SBQQ__Account__c!=Null){
                if(accountTPTToGroupIdMap.containsKey(qlStatusAge.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__r.SBQQ__Account__c)){
                    for(Id groupId : accountTPTToGroupIdMap.get(qlStatusAge.Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__r.SBQQ__Account__c)){
                        TPTShare.add(new Pricing_Quote_Line_Status_Age__Share(
                            ParentId = qlStatusAge.Id,
                            UserOrGroupId = groupId,
                            AccessLevel = 'Read',
                            RowCause = Schema.Pricing_Quote_Line_Status_Age__Share.RowCause.Manual
                        )); 
                        tptIds.add(qlStatusAge.Id);
                    } 
                }
            }
        }           
        if(!TPTShare.isEmpty()){
            Database.insert(TPTShare ,false);
            if(!System.isBatch()){
                updateShareRequiredMethod(tptIds); 
            }
        }
        return tptIds;
    }
    
    /**
* @description updateShareRequiredMethod - Future method is created to update 'Share Required' field as false for the shared records
* @author Rahul Maindalkar | 18-10-2022 
* @param tptIds 
**/      
    @future
    public static void updateShareRequiredMethod(Set<Id> tptIds)
    {   
        List<Pricing_Quote_Line_Status_Age__c> qlStatusAgeUpdate = New List<Pricing_Quote_Line_Status_Age__c>();
        for(Id tptId : tptIds){
            Pricing_Quote_Line_Status_Age__c tptData = New Pricing_Quote_Line_Status_Age__c(Id=tptId);
            tptData.Pricing_TPT_Share_Required__c = False;
            qlStatusAgeUpdate.add(tptData);
        }
        if(qlStatusAgeUpdate.size()>0){
            update qlStatusAgeUpdate;
        }
    }    
}