/************************************************************************************
* Developer                   Date                   Description
* -----------------------------------------------------------------------------------                 
* Brian Matthews            12/10/2014               After-Update added 
*************************************************************************************/
public class Core_CCVHandler{

    public static Boolean valueMapBypass = false;
       
    public static void ccvObjectAfterUpdateHandler(List<Core_CCV__c> newList, Map<Id, Core_CCV__c> newMap, List<Core_CCV__c> oldList, Map<Id, Core_CCV__c> oldMap)
    {           
        Set<Id> ccvIds      = new Set<Id>();
        Set<Id> ccvAccounts = new Set<Id>();
        for (Core_CCV__C ccv : newList)
        {
            ccvAccounts.add(ccv.Core_Account__c); 
            ccvIds.add(ccv.Id);
            System.debug('CCV Account Id: ' + ccv.Core_Account__c); 
        }


        // Handle Sharing
        List<AccountTeamMember> teamList = [SELECT AccountId, UserId 
                                            FROM AccountTeamMember 
                                            WHERE AccountId IN :ccvAccounts
                                              AND isDeleted = false];             
        if (teamList.size() > 0)
        {
             
            Set<String> dupeCheck = new Set<String>();     
            String dupeString;         
                     
            Core_CCV_Sharing ccvSharingObj;                                   
               
            List<Core_CCV_Sharing> ccvShares = new List<Core_CCV_Sharing>();     
            for (Core_CCV__c ccv : newList)
            {            
                for (AccountTeamMember member : teamList)
                {
                    if (ccv.Core_Account__c == member.AccountId)
                    {
                        dupeString = string.valueOf(ccv.Id) + string.valueOf(member.UserId);
                        if (!dupeCheck.contains(dupeString))
                        {
                            dupeCheck.add(dupeString);                    
                            ccvSharingObj = new Core_CCV_Sharing();
                            ccvSharingObj.ccvId       = ccv.Id;
                            ccvSharingObj.userId      = member.UserId;
                            ccvSharingObj.accessLevel = 'Edit';
        
                            ccvShares.add(ccvSharingObj);
                            System.debug('CCV SharingObj: ' + ccvSharingObj.ccvId + ' ' + ccvSharingObj.userId + ' ' + ccvSharingObj.accessLevel); 
                        }
                    }                
                }                                                  
            }
            
            if (ccvShares.size() > 0)        
                Core_CCV_Sharing.manualShareList(ccvShares);        
        }                    


        // Need to bypass Value Map auto-add for clone.
        //
        if (valueMapBypass)
            return;
        
        List<Core_Value_Map__c> mapUpdateList = new List<Core_Value_Map__c>();

        Boolean hasLow;
        Boolean hasMedium;
        Boolean hasHigh;

        List<Core_Value_Map__c> mapList = [SELECT Id, Core_CCV__c, Core_Customer_Value__c 
                                           FROM Core_Value_Map__c
                                           WHERE Core_CCV__c IN :ccvIds];
        for (Id ccvId : ccvIds)
        {                                   
            hasLow    = false;
            hasMedium = false;
            hasHigh   = false;
            
            // Determine which Customer Value records have been created for the CCV.
            for (Core_Value_Map__c ccvValueMap : mapList)
            {                                            
                if (ccvValueMap.Core_CCV__c == ccvId)
                {
                    if (ccvValueMap.Core_Customer_Value__c.contains('High'))
                        hasHigh = true;
                    else if (ccvValueMap.Core_Customer_Value__c.contains('Med'))
                        hasMedium = true;
                    else if (ccvValueMap.Core_Customer_Value__c.contains('Low'))
                        hasLow = true;
                }
            }

            if (!hasHigh)
                mapUpdateList.add(new Core_Value_Map__c(Core_CCV__c=ccvId, Core_Customer_Value__c=Label.Core_CCV_Customer_Value_High));                

            if (!hasMedium)
                mapUpdateList.add(new Core_Value_Map__c(Core_CCV__c=ccvId, Core_Customer_Value__c=Label.Core_CCV_Customer_Value_Medium));                
            
            if (!hasLow)
                mapUpdateList.add(new Core_Value_Map__c(Core_CCV__c=ccvId, Core_Customer_Value__c=Label.Core_CCV_Customer_Value_Low));                
                        
        }        
        
        insert mapUpdateList;

    }
}