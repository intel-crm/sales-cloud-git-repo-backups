public class Temp {
    public static void createAccountOnProjectCreationForExternalCustomer(Map<Id,Core_IPS_Project__c> projectMap){
        
        if(projectMap.values()!=null && projectMap.values().size()>0){ 
            Id profileId = userinfo.getProfileId();
            if(profileId==label.Core_IPS_External_Customer_Profile_Id && profileId <> null)
            {      
                try{
                    
                    Set <id> userCreatedByIds = new Set<id>();
                    List<Core_IPS_Account__c> lstCoreIpsAccount = new List<Core_IPS_Account__c>();
                    List<Core_IPS_Project_Member__c> lstCoreIpsProjectMembers = new List<Core_IPS_Project_Member__c>();
                    
                    for(Core_IPS_Project__c pj:projectMap.values())
                    {
                        userCreatedByIds.add(pj.createdbyid);
                    }
                    
                    Map<Id,User> mapUser = new Map<Id,User>([Select id,accountId,contactid from User where Id IN : userCreatedByIds and accountId!=null]);
                    if ( mapUser <> null && mapUser.size()>0 )
                    {
                        for(Id coreips :projectMap.keyset())
                        { 
                            if (projectMap.get(coreips) != null)
                            {
                                Core_IPS_Account__c ipsAcc = new Core_IPS_Account__c();
                                ipsAcc.Core_IPS_Project__c = coreips;
                                ipsAcc.Core_Members__c ='Selective';
                                ipsAcc.Core_Account__c = mapUser.get(projectMap.get(coreips).createdbyid).accountId;
                                lstCoreIpsAccount.add(ipsAcc);
                                
                                Core_IPS_Project_Member__c coreMember = new Core_IPS_Project_Member__c();
                                coreMember.Core_IPS_Project__c = coreips;
                                coreMember.Core_Selective_Member__c = true;
                                coreMember.Core_IPS_Contact__c = mapUser.get(projectMap.get(coreips).createdbyid).contactid;
                                coreMember.Core_User__c = mapUser.get(projectMap.get(coreips).createdbyid).Id;
                                lstCoreIpsProjectMembers.add(coreMember);
                            }
                            
                        }
                        Database.insert( lstCoreIpsAccount,false);
                        
                        Database.insert( lstCoreIpsProjectMembers,false);
                        
                    }
                }catch(exception ex){
                    String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                    System.debug('##### Exception: ' + exceptionMessage);
                    // inserting the Error into LogEntry object        
                    Core_IPS_ExceptionHandling.logEntryWithException(ex,'Core_IPS_Project_Handler','GroupMember');        
                }
            }
        }
    }
    
}