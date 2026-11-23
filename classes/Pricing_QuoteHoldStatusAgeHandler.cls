/****************************************************************************************************
Apex Trigger Name : Pricing_QuoteHoldStatusAgeHandler
Version         : 1.0 
Created Date    : 10/02/2024
Function        : This class is used used as part of Quote Line Status Age trigger
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Siddharth                 10/02/2024               Created
*****************************************************************************************************/
public without sharing class Pricing_QuoteHoldStatusAgeHandler extends TriggerHandler{
    /**
    * @description afterInsert - Overriding method to share the Quote Hold Status Age records with the public group
    * @author Siddharth Kant | 10/02/2024 
    **/      
    public override void afterInsert() {
        List<Pricing_Quote_Hold_Status_Age__c> quoteHoldStatusAgeList = New List<Pricing_Quote_Hold_Status_Age__c>();
        quoteHoldStatusAgeList = [Select id,Pricing_QuoteOnHold__r.SBQQ__Account__c from Pricing_Quote_Hold_Status_Age__c where Id in: Trigger.NewMap.keySet()];
        shareHoldStatusRecords(quoteHoldStatusAgeList);
    }
    
    /**
    * @description afterInsert - Method is created to share the Quote Hold Status Age records with the public group
    * @author Siddharth Kant | 10/02/2024
    * @param quoteHoldStatusAgeList 
    **/    
    public static void shareHoldStatusRecords(List<Pricing_Quote_Hold_Status_Age__c> quoteHoldStatusAgeList){
        try{
            Set<Id> accountIds = New Set<Id>();
            List<Pricing_Quote_Hold_Status_Age__Share> holdShare = new List<Pricing_Quote_Hold_Status_Age__Share>();		
            Map<Id,Set<Id>> accountHoldToGroupIdMap = new  Map<Id,Set<Id>>(); 
        
            for(Pricing_Quote_Hold_Status_Age__c quoteHoldeStatusAge : quoteHoldStatusAgeList){
                if(quoteHoldeStatusAge.Pricing_QuoteOnHold__r.SBQQ__Account__c!=Null){
                    accountIds.add(quoteHoldeStatusAge.Pricing_QuoteOnHold__r.SBQQ__Account__c);
                }
            }
            if(!accountIds.isEmpty()){
                for(Core_MDF_Partner_Group_Mapping__c partnerGroup : [select Id,Core_MDF_Account__c,Core_MDF_Channel_Program_Name_Txt__c,Core_MDF_Channel_Program__c,Core_MDF_AccountIdGroupName__c,Core_MDF_Group_Id__c,Core_MDF_Type_of_Access__c from Core_MDF_Partner_Group_Mapping__c where
                                                                      Core_MDF_Channel_Program_Name_Txt__c =: Label.Pricing_Tender_PGM_Channel and Core_MDF_Account__c in : accountIds and Core_MDF_Group_Id__c!=null]){
                                                                          if(partnerGroup.Core_MDF_Type_of_Access__c == Label.Pricing_Tender_PGM_Type) {
                                                                              if(accountHoldToGroupIdMap.keySet().contains(partnerGroup.Core_MDF_Account__c)){
                                                                                  accountHoldToGroupIdMap.get(partnerGroup.Core_MDF_Account__c).add(partnerGroup.Core_MDF_Group_Id__c);
                                                                              }else{
                                                                                  accountHoldToGroupIdMap.put(partnerGroup.Core_MDF_Account__c,new Set<Id>{partnerGroup.Core_MDF_Group_Id__c});
                                                                              }
                                                                          }
                                                                      }
            }
            
            for(Pricing_Quote_Hold_Status_Age__c onHoldStatusAge : quoteHoldStatusAgeList){
                if(onHoldStatusAge.Pricing_QuoteOnHold__r.SBQQ__Account__c!=Null){
                    if(accountHoldToGroupIdMap.containsKey(onHoldStatusAge.Pricing_QuoteOnHold__r.SBQQ__Account__c)){
                        for(Id groupId : accountHoldToGroupIdMap.get(onHoldStatusAge.Pricing_QuoteOnHold__r.SBQQ__Account__c)){
                            holdShare.add(new Pricing_Quote_Hold_Status_Age__Share(
                                ParentId = onHoldStatusAge.Id,
                                UserOrGroupId = groupId,
                                AccessLevel = 'Read',
                                RowCause = Schema.Pricing_Quote_Hold_Status_Age__Share.RowCause.Pricing_On_Hold_Account_Team_Group__c
                            )); 
                        } 
                    }
                }
            }           
            if(!holdShare.isEmpty()){
                insert holdShare;
            }
        }
        catch(exception ex){Pricing_Tender_Utility.logError(ex);}
        
    }    
}