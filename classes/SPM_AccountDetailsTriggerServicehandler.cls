/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-14-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class SPM_AccountDetailsTriggerServicehandler {
    public static void shareAccoutndetails(List<SPM_New_Accounts__c> triggerNew){
        
        List<Id> listOfIds = new List<Id>();
        for(SPM_New_Accounts__c accNew :triggerNew){
            listOfIds.add(accNew.CreatedById);
        }
        Map<String,List<SPM_Security_Mapping__c>> securityMapToShare = getSharingDetails(listOfIds);
        Set<string> trackShared = new Set<String>();
        List<SPM_New_Accounts__Share> newAccountSharing = new List<SPM_New_Accounts__Share>();
        
        try{
            
            if(!securityMapToShare.IsEmpty()){
                for(SPM_New_Accounts__c accNew :triggerNew)
                {                     
                    for(string checkEachrecord : securityMapToShare.keySet()){
                        integer checkRolesCount = 0;
                        
                        for(SPM_Security_Mapping__c securityMap : securityMapToShare.get(checkEachrecord)){
                            
                            
                            if(securityMap.Manager__c != accNew.CreatedById && !trackShared.contains(securityMap.Manager__c) ){
                                newAccountSharing.add(addSharingRecord(accNew,securityMap.Manager__c));  
                                trackShared.add(securityMap.Manager__c);
                                
                            }
                            //TWC3123-6460
                            if(securityMap.TA__c <> null && securityMap.TA__c != accNew.CreatedById && !trackShared.contains(securityMap.TA__c)) {
                                newAccountSharing.add(addSharingRecord(accNew,securityMap.TA__c));  
                                trackShared.add(securityMap.TA__c); 
                            }
                        } // end of security map loop
                        
                    } // end of account owner loop
                    
                }
            }
            if(newAccountSharing.size() > 0)
                insert newAccountSharing;
        } catch (Exception e) {
            Core_Exceptions__c excep = new Core_Exceptions__c(Core_Exception__c = 'Failure : ########### - '+e.getStackTraceString()+' Cause'+e.getMessage(),Core_Class_Name__c ='SPM_AccountDetailsTriggerServicehandler',Core_Method_Name__c ='shareAccoutndetails',Core_IPS_Object_Name__c = 'SPM_New_Accounts__c');
            insert excep;
        }
    }
    
    public static Map<String,List<SPM_Security_Mapping__c>> getSharingDetails(List<Id> listOfIds){
        Map<String,List<SPM_Security_Mapping__c>> securityMapTemp = new Map<String,List<SPM_Security_Mapping__c>>();
        Set<String> unique = new Set<String>();
        for(SPM_Security_Mapping__c  tempSec : [select Id,Account_Owner__c  from SPM_Security_Mapping__c where Account_Owner__r.IsActive  = true and Manager__r.IsActive = true and  Role__c in ('DR','VP','Regional Lead') and (Manager__c in: listOfIds or TA__c in:listOfIds )]) {//TWC3123-6460
            unique.add(tempSec.Account_Owner__c);
        }
        for(SPM_Security_Mapping__c  tempSecurity : [select Id,Account_Owner__c,Account_Owner__r.Core_WWID__c, Customer_Category__c,Region__c,Role__c,Manager__c,TA__c from SPM_Security_Mapping__c where Account_Owner__r.IsActive  = true and Manager__r.IsActive = true  ]){
            if(!securityMapTemp.containsKey(tempSecurity.Account_Owner__c) && unique.contains(tempSecurity.Account_Owner__c)){
                securityMapTemp.put(tempSecurity.Account_Owner__c, new List<SPM_Security_Mapping__c>());
                securityMapTemp.get(tempSecurity.Account_Owner__c).add(tempSecurity );
            }else if(securityMapTemp.containsKey(tempSecurity.Account_Owner__c)){
                securityMapTemp.get(tempSecurity.Account_Owner__c).add(tempSecurity );
            }          
        }
        return securityMapTemp;
    }
    
    public static SPM_New_Accounts__Share addSharingRecord(SPM_New_Accounts__c accNew,string UserID){
        SPM_New_Accounts__Share tempDr = new SPM_New_Accounts__Share();
        tempDr.ParentId = accNew.id;
        tempDr.UserOrGroupId = UserID;
        tempDr.AccessLevel = 'Edit';
        
        return tempDr;
    }
    
    public class UserSecurityWrapper {
        public String DR { get; set; }
        public String VP { get; set; }
        public String GM { get; set; }
        public String RL { get; set; }
        public String LATAM { get; set; }
    }
}