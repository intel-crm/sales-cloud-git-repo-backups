public class UCD_AccountChangeReviewTriggerHandler {
    
    public static void createAccountChangeReviewRecords(List<ACM_Account_Change_Review__e> newEvents){
        List<UCD_Account_Change_Review__c> accountchangeReviewList = new List<UCD_Account_Change_Review__c>();
        
        List<Id> accountIds = new List<Id>();
        
        for(ACM_Account_Change_Review__e acrEvent : newEvents) {
            accountIds.add(acrEvent.Account_Id__c); 
        }
        System.debug('newEvents+++'+newEvents);
        System.debug('accountIds++++'+accountIds);
        
        List<Account> accountList = [SELECT Id, Name, Core_Data_Simplified_Account_Nm__c, Core_Business_Party_Id__c, ParentId, Core_Customer_Aggregation_Type__c, BillingState, Phone, Website,Core_Unified_Intermediate_Customer_BP_Id__c,
        Core_Unified_Intermediate_Customer_Name__c,Core_Unified_Global_Customer_BP_Id__c,Core_Unified_Global_Customer_Name__c FROM Account WHERE Id In: accountIds];
        Map<Id, Account> accountMap = new Map<Id, Account>(accountList);
        
        
        for(ACM_Account_Change_Review__e acrEvent : newEvents) {
            System.debug('BPIDDDD++'+ accountMap.get(acrEvent.Account_Id__c).Core_Unified_Global_Customer_BP_Id__c);
            UCD_Account_Change_Review__c accountchangeReview = new UCD_Account_Change_Review__c();
            accountchangeReview.Current_Unified_ID__c = accountMap.get(acrEvent.Account_Id__c).Core_Business_Party_Id__c;
            accountchangeReview.Current_SF_account__c = accountMap.get(acrEvent.Account_Id__c).Id;
            accountchangeReview.Current_Account_Name__c = accountMap.get(acrEvent.Account_Id__c).Name;
            accountchangeReview.Current_Simplified_Account_Name__c = accountMap.get(acrEvent.Account_Id__c).Core_Data_Simplified_Account_Nm__c;
            accountchangeReview.Current_Customer_Aggregation_Type__c = accountMap.get(acrEvent.Account_Id__c).Core_Customer_Aggregation_Type__c;
            accountchangeReview.Current_Parent_ID__c = accountMap.get(acrEvent.Account_Id__c).ParentId;
            accountchangeReview.Current_UCD_Global_ID__c = accountMap.get(acrEvent.Account_Id__c).Core_Unified_Global_Customer_BP_Id__c;
            accountchangeReview.Current_UCD_Global_Name__c = accountMap.get(acrEvent.Account_Id__c).Core_Unified_Global_Customer_Name__c;
            accountchangeReview.Current_UCD_Intermediate_ID__c = accountMap.get(acrEvent.Account_Id__c).Core_Unified_Intermediate_Customer_BP_Id__c;
            accountchangeReview.Current_UCD_Intermediate_Name__c = accountMap.get(acrEvent.Account_Id__c).Core_Unified_Intermediate_Customer_Name__c;

            /*accountchangeReview.Current_Address__c__StateCode = accountMap.get(acrEvent.Account_Id__c).BillingState;
            accountchangeReview.Current_Address__c__CountryCode__s = accountMap.get(acrEvent.Account_Id__c).BillingAddress;
            accountchangeReview.Current_Address__c__Street__s = accountMap.get(acrEvent.Account_Id__c).BillingAddress;
            accountchangeReview.Current_Address__c__PostalCode__s = accountMap.get(acrEvent.Account_Id__c).BillingAddress;
            accountchangeReview.Current_Address__c__City__s = accountMap.get(acrEvent.Account_Id__c).BillingAddress;
            accountchangeReview.Current_Address__c__Latitude__s = accountMap.get(acrEvent.Account_Id__c).BillingAddress;
            accountchangeReview.Current_Address__c__Longitude__s = accountMap.get(acrEvent.Account_Id__c).BillingAddress;
            accountchangeReview.Current_Address__c__GeocodeAccuracy__s='Address';*/
            
            accountchangeReview.Current_Phone__c = accountMap.get(acrEvent.Account_Id__c).Phone;
            accountchangeReview.Current_Website__c = accountMap.get(acrEvent.Account_Id__c).Website;
            
            accountchangeReview.New_Account_Name__c = acrEvent.New_Account_Name__c;
            //accountchangeReview.New_Address__c = acrEvent.New_Address__c;
            accountchangeReview.New_Customer_Aggregation_Type__c = acrEvent.New_Customer_Aggregation_Type__c;
            //accountchangeReview.New_Customer_Process_Engagement__c =  acrEvent.New_Customer_Process_Engagement__c;
            accountchangeReview.New_Parent_ID__c = acrEvent.New_Parent_ID__c;
            accountchangeReview.New_Simplified_Account_Name__c = acrEvent.New_Simplified_Account_Name__c;
            accountchangeReview.New_Phone__c = acrEvent.New_Phone__c;
            accountchangeReview.New_Unified_ID__c = acrEvent.New_Unified_ID__c;
            accountchangeReview.New_Website__c = acrEvent.New_Website__c;
            accountchangeReview.New_UCD_Global_ID__c = acrEvent.New_UCD_Global_ID__c;
            accountchangeReview.New_UCD_Global_Name__c = acrEvent.New_UCD_Global_Name__c;
            accountchangeReview.New_UCD_Intermediate_ID__c = acrEvent.New_UCD_Intermediate_ID__c;
            accountchangeReview.New_UCD_Intermediate_Name__c = acrEvent.New_UCD_Intermediate_Name__c;
    
            
            accountchangeReview.Status__c = 'New' ;
            accountchangeReviewList.add(accountchangeReview);
        }
        
        insert accountchangeReviewList;
    }
                                       }