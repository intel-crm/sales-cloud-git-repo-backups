public class ucdExcelExport {
	public class ContactWrapper{  
     @AuraEnabled  
     public string Name;  
     @AuraEnabled  
     public string Owner; 
     @AuraEnabled  
     public Boolean IPA;
     @AuraEnabled  
     public string salesGroup;
     @AuraEnabled  
     public string CIMID;
        @AuraEnabled  
     public string Id;
     @AuraEnabled  
     public string contactCount;
     public ContactWrapper(Account contactObj){  
       this.Name = contactObj.Name;  
       this.Owner = contactObj.Owner.Name;
       this.IPA = contactObj.Core_Intel_Partner_Alliance_PartnerGroup__c;
       this.salesGroup = contactObj.Core_Sales_Groups__c;
       this.CIMID = contactObj.Core_CIM_ID__c;
       this.Id = contactObj.id;
	   //this.contactCount = contactObj.contactCount;
     }  
   }  
   @AuraEnabled(cacheable=true)
   public static List<ContactWrapper> getContacts(String region){  
       String regionvalue = region;
       system.debug('A15 '+regionvalue);
     List<ContactWrapper> contactWrapperList = new List<ContactWrapper>();
       set<string> cimID = new set<string>();
       List<AggregateResult> regionID = [SELECT Core_Geo__c,Core_CIM_ID__c,COUNT(Id) AccountCount FROM Account 
                                        WHERE Core_CIM_ID__c != null AND Core_Geo__c =: regionvalue
                                        GROUP BY Core_Geo__c, Core_CIM_ID__c 
                                        HAVING COUNT(Id)>1 
                                        ORDER BY COUNT(Id) DESC
                                        LIMIT 2000]; 
       system.debug('A24 '+regionID);
       for(AggregateResult reg: regionID)
       {
           cimID.add(string.valueOf((reg.get('core_cim_id__c'))));
       }
       
     for(Account cwObj : [select id, Name,(SELECT Id FROM contacts),Type,Owner.Name,Core_CIM_ID__c, Core_Account_Legal_Name__c, 
                            Core_Prime_Account_Name__c,  Core_Geo__c, Core_Intel_Partner_Alliance_PartnerGroup__c, 
                            Core_Sales_Groups__c, Core_Account_Type__c from Account where Core_Geo__c =:regionvalue AND Core_CIM_Id__c =:cimID]){
         
       contactWrapperList.add(new ContactWrapper(cwObj)); 
         system.debug('A33 '+contactWrapperList);
     }  
     return contactWrapperList;  
   }  
}