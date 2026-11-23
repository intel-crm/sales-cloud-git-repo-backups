/**************************************************************************************
Class  Name:  Pricing_BatchQuoteShare_ATM
Version     : 1.0 
Created Date: 28 FEB 2020
Function    : Class to Share Quote and Commments with AccountTeamMember
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Anusha Mattaparthi            02/28/2020              Original version 
*************************************************************************************/


public without sharing class Pricing_BatchQuoteShare_ATM  implements Database.Batchable<sObject>{
    //This class helps in sharing Quote and Comments to new account team members
    public List<AccountTeamMember> accTeamMembersList = new List<AccountTeamMember>();
    public Map<Id,Set<Id>> accIdToMemberIdMap = new Map<Id,Set<Id>>();
    public Boolean isDeleteATM;
    
    public Pricing_BatchQuoteShare_ATM(List<AccountTeamMember> accountTeamMembersList, Boolean isDelete,Map<Id,Set<Id>> accIdToMemberIdMap){
        if(!accountTeamMembersList.isEmpty()){
            this.accTeamMembersList = accountTeamMembersList;
            this.accIdToMemberIdMap = accIdToMemberIdMap;
            this.isDeleteATM = isDelete;
        }
    }    
    
    
    /**
    * @description 
    * @author Mahesh Biradar | 08-10-2022 
    * @param Database.BatchableContext bc 
    * @return List<AccountTeamMember> 
    **/
    public List<AccountTeamMember> start(Database.BatchableContext bc){
        system.debug('Enetered batch share ATM Class: '+accTeamMembersList);
        return accTeamMembersList;
    }
    

    /**
    * @description 
    * @author Mahesh Biradar | 08-10-2022 
    * @param bc 
    * @param scope 
    **/
    public void execute(Database.BatchableContext bc, List<AccountTeamMember> scope){
        System.debug('Pricing_BatchQuoteShare_ATM.execute entered. scopeSize=' + scope.size());
        try{        
            Set<Id> userIds = new Set<Id>();
            for(AccountTeamMember atm : scope){
                userIds.add(atm.UserId);
            }
            
            List<GroupMember> groupMember =new List<GroupMember>();
            List<Core_MDF_Partner_Group_Mapping__c> listPartnerGroup = [select Core_MDF_Group_Name__c,Core_MDF_Group_Id__c,Core_MDF_Account__c from Core_MDF_Partner_Group_Mapping__c 
                                                                        where Core_MDF_Channel_Program_Name_Txt__c =: Label.Pricing_Tender_PGM_Channel and Core_MDF_Account__c in : accIdToMemberIdMap.keySet() and Core_MDF_Group_Id__c!=null and Core_MDF_Type_of_Access__c=: Label.Pricing_Tender_PGM_Type];
            if(!isDeleteATM){
                for(Core_MDF_Partner_Group_Mapping__c partnerGroup : listPartnerGroup){
                    for(Id userId : accIdToMemberIdMap.get(partnerGroup.Core_MDF_Account__c) ){
                        GroupMember gm= new GroupMember(); 
                        gm.GroupId = partnerGroup.Core_MDF_Group_Id__c;
                        gm.UserOrGroupId = userId;
                        groupMember.add(gm);
                    }
                } 
                if(groupMember.size() > 0){  
                    insert groupMember;
                }
            }
            else{
                Set<Id> grpIds = new Set<Id>();
                for(Core_MDF_Partner_Group_Mapping__c partnerGroup : listPartnerGroup){
                    grpIds.add(partnerGroup.Core_MDF_Group_Id__c);
                }
                groupMember=[ Select Id from GroupMember where UserOrGroupID in :userIds and GroupId in :grpIds];
                
                if(groupMember.size() > 0){  
                    delete groupMember;
                }                
            }
        }catch(exception e){ 
            Pricing_Tender_Utility.logError(e);
        } finally {
            System.debug('Pricing_BatchQuoteShare_ATM.execute completed. scopeSize=' + scope.size());
        }
    }
    
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 08-10-2022 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc){
        
    }
}