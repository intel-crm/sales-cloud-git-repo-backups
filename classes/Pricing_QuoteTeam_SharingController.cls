/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-03-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_QuoteTeam_SharingController {
  
    @AuraEnabled
    public static List<QuoteTeamMember> getQuoteTeam(String quoteId){
        //This method is called by LWC to get all quote team member list of perticular Quote
        List<Pricing_Quote_Team__c> quoteTeam = [SELECT id,Name,Pricing_Quote_Team_Member_Id__r.FirstName,Pricing_Quote_Team_Member_Id__r.Email,Pricing_Quote_Team_Member_Id__r.LastName,Pricing_Quote_Team_Member_Id__c,Pricing_Role_Nm__c,Pricing_Grant_Access_Ind__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Id__c=:quoteId order by CreatedDate asc];
        List<QuoteTeamMember> quoteTeamMembers = new List<QuoteTeamMember>();
        for(Pricing_Quote_Team__c quoteTeamMemberObj : quoteTeam){
            
            //Create wrapper class to show needed data on LWC
            QuoteTeamMember qtm = new QuoteTeamMember();
            qtm.teamMemberId = quoteTeamMemberObj.Pricing_Quote_Team_Member_Id__c;
            qtm.teamMemberName = quoteTeamMemberObj.Pricing_Quote_Team_Member_Id__r.FirstName+' '+quoteTeamMemberObj.Pricing_Quote_Team_Member_Id__r.LastName; //to show full name of the user
            qtm.role = quoteTeamMemberObj.Pricing_Role_Nm__c;
            qtm.isAcessGranted = quoteTeamMemberObj.Pricing_Grant_Access_Ind__c;
            qtm.userEmail = quoteTeamMemberObj.Pricing_Quote_Team_Member_Id__r.Email;
            quoteTeamMembers.add(qtm);
        }
        return quoteTeamMembers;
    }
    
    @AuraEnabled
    public static Pricing_Quote_Team__c createQuoteTeamMember(String teamMemberEmail, String quoteId, String role, Boolean reassignPrimaryFSE){
        //This method is called by LWC to create quote team member for a perticular Quote
        try{
            List<Pricing_Quote_Team__c> pricingQuote = new List<Pricing_Quote_Team__c>();
            List<User> userList=[Select id,Profile.Name from User where Email=:teamMemberEmail and IsActive = true and Profile.Name != :'Partner' and ContactId = null limit 1]; 
            if(userList.size()>0){
                pricingQuote = [Select Pricing_Quote_Team_Member_Id__c,Pricing_Quote_Id__c,Pricing_Grant_Access_Ind__c from Pricing_Quote_Team__c where Pricing_Quote_Team_Member_Id__c=:userList[0].Id and Pricing_Quote_Id__c =:quoteId ];
            }
            //check if that user already present in the quote team member record 
            if(pricingQuote.size() == 0){ 
                Pricing_Quote_Team__c qtm = new Pricing_Quote_Team__c();
                if(role == Label.Pricing_Quote_Team_Role_FSE){
                    Boolean isvalidFSE = validateFSE(teamMemberEmail, quoteId);
                    if(isvalidFSE == false){
                        return null;
                    }
                }
                if(String.isBlank(teamMemberEmail) && (role == Label.Pricing_Quote_Team_Role_ITS || role == Label.Pricing_Quote_Team_Role_Account_Executive)){
                    return null;
                }
                qtm.Pricing_Quote_Id__c= quoteId;
                qtm.Pricing_Role_Nm__c = role;
                qtm.Pricing_Quote_Team_Member_Id__c=userList[0].Id;
                qtm.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Quote_Team__c',Label.Pricing_Tender_Quote_Team_RecordType);
                insert qtm;
                
                //reassign of primary FSE
                if(reassignPrimaryFSE){
                    String quoteIdWithFse = quoteId + ';' + teamMemberEmail;
                    publishIQR(quoteIdWithFse);
                }
                return qtm;
            }else{
                return null;
            }
        }catch(Exception ex){
            Pricing_Tender_Utility.logError(ex);
            return null;
        }
    }
    
    public static void publishIQR(String quoteId){
        try{
            //List to hold event objects to be published.
            List<Pricing_IQR_Event__e> newsEventList = new List<Pricing_IQR_Event__e>();
            newsEventList.add(new Pricing_IQR_Event__e(Pricing_QuoteId_Txt__c = quoteId,
                Pricing_IQR_Action_Nm__c = 'ApprovalRequestChange'));
            
            if(newsEventList.size() > 0){               
                // Call method to publish events.
                List<Database.SaveResult> results = EventBus.publish(newsEventList);
            }                            
        }catch(exception ex) {Pricing_Tender_Utility.logError(ex);}
    }

    @AuraEnabled
    public static MessageOutput removeQuoteTeamMember(List<String> teamMemberIds, String quoteId){
        //This method is called by LWC to remove quote team member for a perticular Quote
         MessageOutput msgOutput;
        try{
            List<Pricing_Quote_Team__c> qtm = [Select Pricing_Quote_Id__c, Pricing_Quote_Team_Member_Id__c,Pricing_Role_Nm__c,Pricing_Quote_Id__r.SBQQ__Status__c from Pricing_Quote_Team__c where Pricing_Quote_Id__c=:quoteId and Pricing_Quote_Team_Member_Id__c in :teamMemberIds];
            String quoteStatus = qtm[0].Pricing_Quote_Id__r.SBQQ__Status__c;
            if(qtm.size()>0){	//to check weather that user having quote team member record or not
                msgOutput = isValidFSEPresent(teamMemberIds,quoteId,qtm,quoteStatus);
                if(msgOutput.isSuccess){
                    delete qtm;
                }	
            }else{
                //return 'false';
                msgOutput.isSuccess = false;
                msgOutput.message = Label.Pricing_Quote_Team_Member_Removal_Error;
            }
        }catch(Exception ex){
            //return 'false';
            msgOutput.isSuccess = false;
            msgOutput.message = Label.Pricing_Quote_Team_Member_Removal_Error;
            return msgOutput;
        }
        return msgOutput;
    }

    @AuraEnabled(cacheable=true)  
    public static List<User> findRecords(String searchKey) {  
        //This method is called by LWC to find the user from searchkey
        String searchText = String.escapeSingleQuotes(searchKey) + '%';
        String query = 'SELECT Id, Name, Email, Isactive, Profile.Name FROM USER WHERE Name LIKE :searchText AND Profile.Name != \'Partner\' AND ContactId = null AND Isactive = true LIMIT 5';
        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)  
    public static String getCurrentQuoteName(String quoteId) { 
        SBQQ__Quote__c quote = [Select Name from SBQQ__Quote__c where Id = :quoteId];
        return quote.Name;
    }
    
    @AuraEnabled(cacheable=true)  
    public static boolean isInternal() { 
        //This method is called by LWC to check weather the logged in user is Internal or External user
        List<PermissionSetAssignment> pset = [SELECT Id, PermissionSet.Name, PermissionSet.Label 
                                                     FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId()];
        for(PermissionSetAssignment psa: pset){
            if(psa.PermissionSet.Label.contains('Tender Partner')){ 	//if permission set is 'Tender Partner' than this user is external
                return false;
            }
        }
        return true;
    }
    
    @AuraEnabled(cacheable=true)  
    public static boolean isDPMLegalFinanceUser() { 
        //This method is called by LWC to check weather the logged in user is DPM/Legal/Finance User
        List<String> permissionSetNames = new List<String>{
            Label.Pricing_Tender_PermissionSets_PricingDivisionalTenderPricingManager,
            Label.Pricing_Tender_PermissionSets_TenderReadOnly,
            Label.Pricing_Tender_PermissionSets_TenderRebateAnalyst
        };
        List<PermissionSetAssignment> pset = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND 
                                              PermissionSet.Name IN : permissionSetNames];
        if(pset.size()>0){
            return true;
        }
        return false;   
    }
    
    //Method to validate FSE in Quote Team
    public static boolean validateFSE(String teamMemberEmail,String quoteId) {
        List<PermissionSetAssignment> fsePermissionList = new List<PermissionSetAssignment>([SELECT Assignee.Email,PermissionSet.Name,AssigneeId
                                                                                        	FROM PermissionSetAssignment WHERE Assignee.Email =: teamMemberEmail AND Assignee.IsActive = true
                                                                                        	AND PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderUser]);
        List<AccountTeamMember> accoutTeamList = new List<AccountTeamMember>();
        if(!fsePermissionList.IsEmpty()){
            SBQQ__Quote__c quote = [SELECT id,SBQQ__Account__c from SBQQ__Quote__c where Id =: quoteId];
        	accoutTeamList = [SELECT Id, AccountId, User.Email 
                              FROM AccountTeamMember WHERE AccountId =: quote.SBQQ__Account__c 
                              AND User.Email =: teamMemberEmail];
        }
        if(!fsePermissionList.IsEmpty() && !accoutTeamList.IsEmpty()){
            return true;
        }      
        else{
            return false;
        }                                                                    
    }
    
    //Method to check on deletion of FSE is a valid FSE is present
    public static MessageOutput isValidFSEPresent(List<String> teamMemberIds, String quoteId,List<Pricing_Quote_Team__c> qtmToDelete, String quoteStatus){
        Boolean fseDelete = false;
        Set<Id> fseQTMDeleteUserIdSet = new Set<Id>();
        for(Pricing_Quote_Team__c qtm : qtmToDelete ){
            if(qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_FSE){
                fseDelete = true;
                fseQTMDeleteUserIdSet.add(qtm.Pricing_Quote_Team_Member_Id__c);
            }
        }
        
        //Check if there is a pending approval request for FSE quote team member to be deleted
		Set<Id> quoteLineIds = (new Map<Id,SBQQ__QuoteLine__c>([SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId])).keySet();
        List<ProcessInstanceWorkitem> pwItemPendingList = [Select Id,ActorId,ProcessInstance.TargetObjectId,OriginalActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN : quoteLineIds
                                            	  		   AND ProcessInstance.Status = 'Pending' AND ActorId IN:fseQTMDeleteUserIdSet];
        
        if(fseDelete){  //If FSE is deleted
            if(isInternal() && !(pwItemPendingList.size()>0)){ //for Internal before submission and after submission (no Pending Approval request present)
                List<Pricing_Quote_Team__c> qtmList = [SELECT Pricing_Quote_Id__c, Pricing_Quote_Team_Member_Id__c,Pricing_Role_Nm__c,Pricing_Quote_Id__r.SBQQ__SalesRep__c,Pricing_Quote_Id__r.SBQQ__Account__c 
                                                       FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Id__c=:quoteId AND (NOT Id In :qtmToDelete) AND Pricing_Role_Nm__c =: Label.Pricing_Quote_Team_Role_FSE];
                Set<Id> fseQTMUserIdSet = new Set<Id>();
                Set<Id> validFSEUserSet = new Set<Id>();
                String accountId = null;
                if(!qtmList.isEmpty()){
                    for(Pricing_Quote_Team__c qtm : qtmList){
                        fseQTMUserIdSet.add(qtm.Pricing_Quote_Team_Member_Id__c);
                        if(accountId == null){
                            accountId = qtm.Pricing_Quote_Id__r.SBQQ__Account__c;
                        }
                    }
                    if(!fseQTMUserIdSet.isEmpty()){  //Set of valid FSE users from Quote Team
                        validFSEUserSet = getValidFSEUserIdSet(fseQTMUserIdSet,accountId);
                    }
                    if(validFSEUserSet.size()>0){  //For Internal there is a valid FSE present in the Quote Team
                        return new MessageOutput(true,'');
                    }
                    else{   // There is no valid FSE present in the Quote Team
                        return (new MessageOutput(false,Label.Pricing_Quote_Team_No_Valid_FSE_Present_Error));
                    }
                }else{    //There are no FSEs present in the Quote Team
                    return (new MessageOutput(false,Label.Pricing_Quote_Team_No_Valid_FSE_Present_Error));
                }
            }else if(isInternal() && pwItemPendingList.size()>0){ //After Quote Submission if there is a pending Approval request throw an error (Internal)
            	return (new MessageOutput(false,Label.Pricing_QuoteTeam_FSE_Removal_After_Submission_Error));
            	//return new MessageOutput(true,'');
            }else{   //For external
                if(quoteStatus != Label.Pricing_Tender_Quote_Status_Draft){  // For external user on after submission FSE cannot be deleted from Quote Team
                    return (new MessageOutput(false,Label.Pricing_QuoteTeam_FSE_Removal_After_Submission_External_Error));
                }else{                                            //For external user on before submission FSE can be deleted from Quote Team
                    return (new MessageOutput(true,''));
                }
            }
        }else{    //For deletion of other Quote Team members apart from FSE
            return (new MessageOutput(true,''));
        } 
    }
    
    //Method to return set of Valid FSE users 
    public static Set<Id> getValidFSEUserIdSet(Set<Id> fseQTMUserIdSet,String accountId){
        Set<Id> fseUserWithPSSet = new SeT<Id>();
        Set<Id> validFSEUserSet = new Set<Id>();
        List<PermissionSetAssignment> fsePermSetDtls = new List<PermissionSetAssignment>([SELECT Assignee.Email,PermissionSet.Name,AssigneeId FROM PermissionSetAssignment 
                                                                                          WHERE Assignee.Id IN :fseQTMUserIdSet AND Assignee.IsActive = true
                                                                                          AND PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderUser]);
        for(PermissionSetAssignment psa:fsePermSetDtls){
            fseUserWithPSSet.add(psa.Assignee.Id);
        }
        
        for(AccountTeamMember accTeam : [SELECT Id,User.Email,AccountId FROM AccountTeamMember 
                                         WHERE AccountId=:accountId
                                         AND UserId IN: fseUserWithPSSet]){
                                             validFSEUserSet.add(accTeam.UserId);
                                         }
         return validFSEUserSet;
    }
    
    public class QuoteTeamMember {
        @AuraEnabled public String teamMemberId {set;get;}
        @AuraEnabled public String teamMemberName {set;get;}
        @AuraEnabled public String role {set;get;}
        @AuraEnabled public boolean isAcessGranted {set;get;}
        @AuraEnabled public String userEmail {set;get;}        
    }
    
    public class MessageOutput {
        @AuraEnabled public Boolean isSuccess {set;get;}
        @AuraEnabled public String message {set;get;}  
        MessageOutput(Boolean flag,String msg){
            isSuccess = flag;
            message=msg;
        }
    }

    /**
    * @description method to get all Valid FSEs from Quote Team
    * @author Sandeep | 03-23-2023 
    * @param quoteId Id of Quote Record
    **/
    @AuraEnabled
    public static Map<String,String> getQuoteFSEUsers(List<Id> quoteIds){
        
        Set<Id> quoteIdsSet = new Set<Id>(quoteIds);
        Map<Id,Set<Id>> quotetoFSEMemberIdMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> accIdtoFSEMemberMap = new Map<Id,Set<Id>>();
        Set<Id> fseUserIdSet = new set<Id>();
        Map<String,String> errorTypetoMsgMap = new Map<String,String>();
        String invalidFSEMembers = '';

        quotetoFSEMemberIdMap = Pricing_Publish_Quote.validateQtmFse(quoteIdsSet);

        if(!quotetoFSEMemberIdMap.isEmpty()){
            for(SBQQ__Quote__c quote : [SELECT Id,Name,SBQQ__Account__c FROM SBQQ__Quote__c WHERE Id IN: quoteIdsSet]){
                if(quotetoFSEMemberIdMap.containsKey(quote.Id)){
                    if(accIdtoFSEMemberMap.containsKey(quote.SBQQ__Account__c)){
                        accIdtoFSEMemberMap.get(quote.SBQQ__Account__c).addAll(quotetoFSEMemberIdMap.get(quote.Id));
                    }
                    else{
                        accIdtoFSEMemberMap.put(quote.SBQQ__Account__c, quotetoFSEMemberIdMap.get(quote.Id));
                    }
                    fseUserIdSet.addAll(quotetoFSEMemberIdMap.get(quote.Id));
                }
            }
        }

        for(Pricing_Quote_Team__c fseMember : [SELECT Id,Pricing_Quote_Team_Member_Id__c,Pricing_Quote_Team_Member_Id__r.Name FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Id__c IN: quoteIdsSet AND Pricing_Role_Nm__c = 'FSE/SDM']){
            if(!fseUserIdSet.contains(fseMember.Pricing_Quote_Team_Member_Id__c)){
                invalidFSEMembers +=  fseMember.Pricing_Quote_Team_Member_Id__r.Name + ',';
            }
        }

        if(!accIdtoFSEMemberMap.isEmpty()){
            errorTypetoMsgMap = addFSEUsersToPublicGroup(accIdtoFSEMemberMap,fseUserIdSet);
        }

        if(invalidFSEMembers != '' || (accIdtoFSEMemberMap.isEmpty() && invalidFSEMembers == '')){
            errorTypetoMsgMap.clear();
            invalidFSEMembers = invalidFSEMembers.removeEnd(',');
            errorTypetoMsgMap.put('type','error');
            String errorMsg = invalidFSEMembers == '' ? Label.Pricing_FSE_SyncAcess_NoMember_ErrorMsg : Label.Pricing_FSE_SyncAccess_Error_Msg.replaceAll('<User>',invalidFSEMembers);
            errorTypetoMsgMap.put('msg',errorMsg);
        }
        return errorTypetoMsgMap;  
    }

    /**
    * @description method to add FSE Users to Public Group if not present
    * @author Sandeep | 03-23-2023 
    * @param accIdtoFSEMemberMap Map of Account Id to Users Set
    **/
    public static Map<String,String> addFSEUsersToPublicGroup(Map<Id,Set<Id>> accIdtoFSEMemberMap, Set<Id> fseUserIdSet){

        Map<Id,Set<Id>> grpIdtoMemberIdMap = new Map<Id,Set<Id>>();
        Set<GroupMember> fseMemberstoAdd = new Set<GroupMember>();
        List<Core_MDF_Partner_Group_Mapping__c> partnerGroupMappingList = new List<Core_MDF_Partner_Group_Mapping__c>();
        Map<String,String> errorTypetoMsgMap = new Map<String,String>();

        try{
            if(!accIdtoFSEMemberMap.isEmpty()){

                partnerGroupMappingList = [SELECT Id,Core_MDF_Account__c,Core_MDF_Channel_Program_Name_Txt__c,Core_MDF_Channel_Program__c,Core_MDF_AccountIdGroupName__c,Core_MDF_Group_Id__c,Core_MDF_Type_of_Access__c FROM Core_MDF_Partner_Group_Mapping__c WHERE
                                            Core_MDF_Channel_Program_Name_Txt__c =: Label.Pricing_Tender_PGM_Channel AND Core_MDF_Account__c IN : accIdtoFSEMemberMap.keySet() AND Core_MDF_Group_Id__c != null AND Core_MDF_Type_of_Access__c =: Label.Pricing_Tender_PGM_Type];


                for(GroupMember gepMember : [SELECT Id,GroupId,UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN: fseUserIdSet]){
                    if(grpIdtoMemberIdMap.containsKey(gepMember.GroupId)){
                        grpIdtoMemberIdMap.get(gepMember.GroupId).add(gepMember.UserOrGroupId);
                    }
                    else{
                        grpIdtoMemberIdMap.put(gepMember.GroupId , new Set<Id>{gepMember.UserOrGroupId});
                    }
                }

                for(Core_MDF_Partner_Group_Mapping__c partnerGroupMap : partnerGroupMappingList){
                    if(accIdtoFSEMemberMap.containsKey(partnerGroupMap.Core_MDF_Account__c)){
                        if(grpIdtoMemberIdMap.containsKey(partnerGroupMap.Core_MDF_Group_Id__c)){
                            Set<Id> groupMemberIds = new Set<Id>(grpIdtoMemberIdMap.get(partnerGroupMap.Core_MDF_Group_Id__c));
                            for(Id fseUserId : accIdtoFSEMemberMap.get(partnerGroupMap.Core_MDF_Account__c) ){
                                if(!groupMemberIds.contains(fseUserId)){
                                    GroupMember grpMember= new GroupMember(); 
                                    grpMember.GroupId = partnerGroupMap.Core_MDF_Group_Id__c;
                                    grpMember.UserOrGroupId = fseUserId;
                                    fseMemberstoAdd.add(grpMember);
                                }
                            }
                        }
                        else{
                            for(Id fseUserId : accIdtoFSEMemberMap.get(partnerGroupMap.Core_MDF_Account__c) ){
                                GroupMember grpMember= new GroupMember(); 
                                grpMember.GroupId = partnerGroupMap.Core_MDF_Group_Id__c;
                                grpMember.UserOrGroupId = fseUserId;
                                fseMemberstoAdd.add(grpMember);
                            }
                        }
                    }
                }
                List<GroupMember> fseMemberstoAddList = new List<GroupMember>(fseMemberstoAdd);
                if(fseMemberstoAdd.size() > 0){
                    insert fseMemberstoAddList;
                    errorTypetoMsgMap.put('type','success');
                    errorTypetoMsgMap.put('msg',Label.Pricing_FSE_SyncAccess_Success_Msg);
                }
                else{
                    errorTypetoMsgMap.put('type','info');
                    errorTypetoMsgMap.put('msg',Label.Pricing_FSE_SyncAccess_Information_Msg);
                }
            }
        }
        catch(exception ex){
            Pricing_Tender_Utility.logError(ex);
            errorTypetoMsgMap.put('error',ex.getMessage());
        }
        return errorTypetoMsgMap;
    }   
}