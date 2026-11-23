public class Core_UserUtility {
    @InvocableMethod
    public static void InactivateAcrOnContact(List<User> InactiveUserRecord)
    {
        List<PRM_Account_Contact_Relationship__c> acrPartnerAdminFinalList= new List<PRM_Account_Contact_Relationship__c>();
        List<PRM_Account_Contact_Relationship__c> acrEmployeeFinalList= new List<PRM_Account_Contact_Relationship__c>();       
        Set<PRM_Account_Contact_Relationship__c> acrPartnerAdminSet= new Set<PRM_Account_Contact_Relationship__c>();
        Set<PRM_Account_Contact_Relationship__c> acrEmployeeSet= new Set<PRM_Account_Contact_Relationship__c>();
        Set<String> InactiveEmails= new Set<String>();  
        Set<Id> contactSet= new Set<Id>();   
        List<Contact> contLst = new List<Contact>();
        system.debug('Core_utility  method invoked');
        
        for(User UsrList:InactiveUserRecord) {                
            InactiveEmails.add(UsrList.Email);
            system.debug('List of Inactive Email Ids'+InactiveEmails);
        } 
        
        if(!InactiveEmails.isEmpty()){
            system.debug('InactiveUserRecord are '+InactiveEmails);
            for(Contact con :[ select Id,Email from Contact where Email IN:InactiveEmails]){
                contactSet.add(Con.Id);
            }
            
            system.debug('Contacts associated to inactive emails - the list of contacts are'+contactSet);            
        }  
        
        try{
            
            if(contactSet != null && !contactSet.IsEmpty()){
                system.debug('Core_utility  2nd loop');
                for(PRM_Account_Contact_Relationship__c acr:[SELECT Id,PRM_Soft_Contact__c,PRM_InActive_Ind__c,PRM_Contact_Id__c,
                                                             PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c,
                                                             PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c FROM PRM_Account_Contact_Relationship__c 
                                                             WHERE PRM_InActive_Ind__c=false  AND PRM_Contact_Id__c IN:contactSet]){ 
                                                                 system.debug('The result of query is '+acr);    
                                                                 acr.PRM_InActive_Ind__c=true;
                                                         //      acr.PRM_Soft_Contact__c=true;
                                                                 acr.PRM_End_Date_Dt__c = System.today();
                                                                 if(acr.PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c==false){         
                                                                     acrPartnerAdminSet.add(acr);                                                               
                                                                 }else{                                                            
                                                                     acrEmployeeSet.add(acr);
                                                                 }
                                                                 
                                                             }
            }
            
            
            if(acrPartnerAdminSet != null && acrPartnerAdminSet.size()>0){
                acrPartnerAdminFinalList.addall(acrPartnerAdminSet);
                update acrPartnerAdminFinalList;
                //PRM_AcctContRelUtility.inactivateContactEntitlement(acrPartnerAdminFinalList,acrPartnerAdminSetMap);
                //String obj = JSON.serialize(acrPartnerAdminFinalList);
                //dbOperations(obj);
                //system.debug('Partner Admin Set ::: ' + acrPartnerAdminFinalList);
            }
            if(acrEmployeeSet != null && acrEmployeeSet.size()>0){
                acrEmployeeFinalList.addall(acrEmployeeSet);
                update acrEmployeeFinalList;
                //PRM_AcctContRelUtility.inactivateContactEntitlement(acrEmployeeFinalList,acrEmployeeSetMap);  
                
                //String obj = JSON.serialize(acrEmployeeFinalList);
                //futureACROperation(obj);
                //system.debug('Employee Set ::: ' + acrEmployeeFinalList);
            }    
        }catch(Exception ex){
            PRM_ErrorUtilityClass.logError(ex);
        }
    }  
    
}