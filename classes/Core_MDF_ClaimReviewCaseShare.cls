/****************************************************************************************************************************************
* Class Name  : Core_MDF_ClaimReviewCaseShare 
* Version     : 1.0 
* Created Date: 11-21-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Harika P         11/23/2018                   Created Core_MDF_ClaimReviewCaseShare for sharing case records
* Accenture – Shridhar K       01/08/2019                   Updated claimReviewCaseShare method 
* Accenture – Shridhar K       02/18/2019                   Case is shared with account manager based on PGM records
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ClaimReviewCaseShare {
/****************************************************************************************************************************************
Method Name:                                             claimReviewCaseShare
@return  :                                               Void
@parameters:                                             caseList - List of cases                                
Description:                                             This method will be invoked by a Process Builder in order to create the Share records for Cases 
Added By:                                                Accenture – Harika P  -  11/23/2018
Modified By:                  Date:                      Changes: 
Accenture – Harika P        11/21/2018                   Created. 
Accenture – Shridhar K      01/08/2019                   Updated claimReviewCaseShare method to share Case records only with claim submitter.
Accenture – Shridhar K      02/18/2019                   Case is shared with account manager based on PGM records
*****************************************************************************************************************************************/    
    @InvocableMethod
    public static void claimReviewCaseShare(List<Case> caseList){
        try{                    
            Map<Id,List<Id>> claimIdUserIdListMapToShare = new Map<Id,List<Id>>();        
            Map<Id,List<Id>> caseIdWithUserOrGroupId = new Map<Id,List<Id>>();  
            Map<Id,Id> caseWithVirtualAccount = new Map<Id,Id>();
            Map<Id,Id> caseWithIntelAccount = new Map<Id,Id>();
            Map<Id,Id> virtualAccWithIntelAcc = new Map<Id,Id>();
            Map<Id,List<Core_MDF_Partner_Group_Mapping__c>> intelAccIdWithGroup = new Map<Id,List<Core_MDF_Partner_Group_Mapping__c>>();
            Map<Id,Account> virtualAccMap = new Map<Id,Account>();
            
            //VK
            Set<Id> accIdSet = new Set<Id>();
            Set<Id> programIdSet = new Set<Id>();
            Set<String> geoSet = new Set<String>();            
            Map<String,Id> geoInternalMap = new Map<String,Id>();
            String accIdProgramIdGeoSubGeo,accIdProgramIdGeo,accIdProgramId;
            String geoMapKey, subGeoMapKey;
            
            // Identifying accounts from cases
            for (Case c : caseList){
                if(c.AccountId != null){
                    caseWithVirtualAccount.put(c.Id, c.AccountId);
                    String geo = c.Core_Account_Geo__c.trim();
                    geoSet.add(geo);
                }
                
            }
            
            //isUser active check in below query added by Shridhar 04/02/2019
            // Mapping with virtual corp accounts
            List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = [SELECT Id, Name, Core_MDF_Account__c, Core_MDF_User__c, Core_MDF_AccountIdUserId__c 
                                                                    FROM Core_MDF_Partner_Node_User_Mapping__c WHERE 
                                                                    Core_MDF_Account__c IN: caseWithVirtualAccount.values() AND Core_MDF_User__r.IsActive = true LIMIT 50000];
            System.debug('pnumList :'+ pnumList);
            
            //Claim Submitter check logic begins
            list<Id> allUsersId = new list<Id>();
            for(Core_MDF_Partner_Node_User_Mapping__c pnumRec : pnumList){
                allUsersId.add(pnumRec.Core_MDF_User__c);
            }       
            Set<Id> allClaimSubmitter = new Set<Id>();
            
            for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN :allUsersId AND PermissionSet.Name = 'Core_MDF_CCP_External_Claim_Submitter']){
                allClaimSubmitter.add(usrPer.AssigneeId);
            }
            //Claim Submitter check logic ends
            
            //Case sharing with Account Manager begins
            //Case is shared with Account Manager based on PGM records       
            for(Account acc: [SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__c FROM Account WHERE Id IN: caseWithVirtualAccount.values()]){
                if(acc.Core_MDF_CoMarketing_Ultimate_Account__c!= null){
                    virtualAccWithIntelAcc.put(acc.Id, acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                    virtualAccMap.put(acc.Id,acc);
                    accIdSet.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                    //System.debug('accIdSet---' + accIdSet);
                    programIdSet.add(acc.Core_MDF_Channel_Program__c);
                    System.debug('programIdSet---' + programIdSet);
                }
            }
            
            //Fetching PGM records and storing them in map with Account
            for(Core_MDF_Partner_Group_Mapping__c pgm:[SELECT Id, Core_MDF_Group_Id__c, Core_MDF_Account__c,Core_MDF_Sub_Region_cd__c, 
                                                       		  Core_MDF_Channel_Program__c,Core_MDF_Region_cd__c
                                                       FROM Core_MDF_Partner_Group_Mapping__c 
                                                       WHERE Core_MDF_Type_of_Access__c='Internal' 
                                                       AND Core_MDF_Account__c IN : accIdSet AND 
                                                       	   Core_MDF_Channel_Program__c IN : programIdSet AND
                                                       	   (Core_MDF_Region_cd__c IN : geoSet OR Core_MDF_Region_cd__c = 'WW')]){
				If(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                    accIdProgramIdGeoSubGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c+pgm.Core_MDF_Sub_Region_cd__c;                                              
                    geoInternalMap.put(accIdProgramIdGeoSubGeo, pgm.Core_MDF_Group_Id__c);
                }else{
                    accIdProgramIdGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                    geoInternalMap.put(accIdProgramIdGeo, pgm.Core_MDF_Group_Id__c);
                }                                               
				if(pgm.Core_MDF_Region_cd__c == 'WW'){
                    accIdProgramId = accIdProgramIdGeo.left(36);
                    geoInternalMap.put(accIdProgramId,pgm.Core_MDF_Group_Id__c);                                          
				}
            }      
            
            for (Case c : caseList){
                //Initilatizing set again
                Set<Id> userOrGroupIdSet = new Set<Id>();
                // Getting list of Id's to be shared 
                for(Core_MDF_Partner_Node_User_Mapping__c pnumShare : pnumList){
                    //Claim Submitter condtion is added by Shridhar 01/08/2018
                    // To share case record only with external claim submitter 
                    if(c.AccountId != NULL && c.AccountId == pnumShare.Core_MDF_Account__c && allClaimSubmitter.contains(pnumShare.Core_MDF_User__c)){                            
                        userOrGroupIdSet.add(pnumShare.Core_MDF_User__c);                    
                    }            
                }
                
                if(c.Core_IPS_Account_Sub_Geo__c != NULL){
                    subGeoMapKey = (String)virtualAccWithIntelAcc.get(c.AccountId) + virtualAccMap.get(c.AccountId).Core_MDF_Channel_Program__c + c.Core_Account_Geo__c.trim()+c.Core_IPS_Account_Sub_Geo__c.trim();
                    
                }
                
                geoMapKey = (String)virtualAccWithIntelAcc.get(c.AccountId) + virtualAccMap.get(c.AccountId).Core_MDF_Channel_Program__c + c.Core_Account_Geo__c.trim();
                 
                
                if(subGeoMapKey != NULL && geoInternalMap.containsKey(subGeoMapKey)){
                    userOrGroupIdSet.add(geoInternalMap.get(subGeoMapKey));
                }
                
                if(geoInternalMap.containsKey(geoMapKey)){
                    userOrGroupIdSet.add(geoInternalMap.get(geoMapKey));
                }
                
                geoMapKey = geoMapKey.left(36);
                
                if(geoInternalMap.containsKey(geoMapKey)){
                    userOrGroupIdSet.add(geoInternalMap.get(geoMapKey));
                }
                
                // Preparing map of case Id and List of user Id's to be shared 
                if (userOrGroupIdSet.Size()>0){                
                    caseIdWithUserOrGroupId.Put(c.Id, new List<Id>(userOrGroupIdSet));                    
                }
            }        
            // Call Generic share method class using MapcaseIdWithUserOrGroupId for sharing Case records with 
            // External Users from Partner Node User Mapping
            System.debug('caseIdWithUserOrGroupId: '+caseIdWithUserOrGroupId);
            if(!caseIdWithUserOrGroupId.isEmpty()){
                Core_MDF_GenericShareRecordActionClass.createShareRecordList('Case', caseIdWithUserOrGroupId); 
            }
        }
        catch(Exception e){
            String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,'Exception occured in CCP claimReviewCaseShare method');
        }
    }
}