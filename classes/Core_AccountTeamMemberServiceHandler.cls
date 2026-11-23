public without sharing class Core_AccountTeamMemberServiceHandler{

    public static Id profileId = userinfo.getProfileId();
    public static String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

    public static void sharingAccountTeamList(list<AccountTeamMember> accTeamList, Boolean isDelete){

            String permissionSetName = System.Label.Pricing_Tender_PermissionSets_TenderUser;
            Set<ID> assignedIds=new Set<ID>();
            List<AccountTeamMember> accountTeamMembersList=new List<AccountTeamMember>();
            List<AccountTeamMember> accountTeamMembersDeletedList=new List<AccountTeamMember>();
            List<PermissionSetAssignment>     accmtPermisionId = [Select AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name =:permissionSetName];
            
            Map<Id,Set<Id>> accIdToUserIdMap = new Map<Id,Set<Id>>();
            if( accmtPermisionId <> Null && accmtPermisionId.size() > 0){
                for(PermissionSetAssignment psam : accmtPermisionId){
                    assignedIds.add(psam.AssigneeId);
                }
            }
        
        //Checking teamMember has tender permissionSet or not.
            if(!accTeamList.isEmpty()){
            for(AccountTeamMember atm: accTeamList){
                    if(assignedIds.contains(atm.UserId)){
                        accountTeamMembersList.add(atm);
                        if(accIdToUserIdMap.containsKey(atm.accountId)){
                            accIdToUserIdMap.get(atm.AccountId).add(atm.UserId);
                        }
                        else{
                            accIdToUserIdMap.put(atm.AccountId,new Set<Id>{atm.UserId});
                        }
                    }
                }  
            }
    
            //Sending accountTeamMembersList to  tender quote and quoteline sharing batch job.
            if(!accountTeamMembersList.isEmpty() && accountTeamMembersList <> Null){
            //System.debug('call batch '+'accountTeamMembersList '+accountTeamMembersList+' isDelete '+' accIdToUserIdMap '+accIdToUserIdMap);
            database.executebatch(new Pricing_BatchQuoteShare_ATM(accountTeamMembersList,isDelete,accIdToUserIdMap),200);
            }
    }

    public static void validationAccountTeam(list<AccountTeamMember> accTeamList, Map<Id,AccountTeamMember> oldAccTeamMember){
        Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        
        String profileNames  = System.Label.UCD_AccTeam_Bypass_Profile	;
        List<String> listProfileNames = new List<String>();

        if(String.isNotBlank(profileNames)){
            listProfileNames.addAll(ProfileNames.split(','));
        }

        Boolean bypassValidation = false;

        if(listProfileNames.size() > 0){
            bypassValidation =  listProfileNames.contains(profileName);
        }

        List<String> accountIds = new List<String>();
        Map<Id, Account> mapAccounts ;

        for(AccountTeamMember accountTeamMember : accTeamList){
            if(accountTeamMember.AccountId != null){
                accountIds.add(accountTeamMember.AccountId);
            }
        }

        if(accountIds.size() > 0){
                mapAccounts = new  Map<Id, Account>( [Select id, OwnerId, Core_Account_Category__c from Account where Id IN :accountIds AND recordtypeID =:intelRecordTypeId ] );
        }


        for(AccountTeamMember accountTeamMember : accTeamList){
            
            List<String> lstAccountCategory = new List<String>();
            List<String> lstAccountTeamCategory = new List<String>();

            if( !bypassValidation && accountTeamMember.AccountId != null && mapAccounts !=  null && mapAccounts.get(accountTeamMember.AccountId) != null ){
                if(!Core_AccountTeamMemberHandler.bypassValidationonAccountTeam && UserInfo.getUserId() != mapAccounts.get(accountTeamMember.AccountId).OwnerId){
                    //
                    accountTeamMember.addError(System.Label.UCD_ACM_AccountTeam_Can_Not_Edit);
                }
            }

            if( accountTeamMember.AccountId != null && mapAccounts !=  null && mapAccounts.get(accountTeamMember.AccountId) != null ){

                String accountCategory =  mapAccounts.get(accountTeamMember.AccountId).Core_Account_Category__c != null ? mapAccounts.get(accountTeamMember.AccountId).Core_Account_Category__c : '';
                String accountTeamCategory = accountTeamMember.Core_Account_Category__c != null ? accountTeamMember.Core_Account_Category__c : '' ;

                if(accountCategory.contains(';')){
                    lstAccountCategory = accountCategory.split(';');
                }else{
                    if(String.isNotBlank(accountCategory)){
                        lstAccountCategory.add(accountCategory);
                    }
                }

                if(accountTeamCategory.contains(';')){
                    lstAccountTeamCategory = accountTeamCategory.split(';');
                }else{
                    if(String.isNotBlank(accountTeamCategory)){
                        lstAccountTeamCategory.add(accountTeamCategory);
                    }
                }

                for(String  accTeamCatRec : lstAccountTeamCategory){
                    if( ! accountCategory.contains(accTeamCatRec)){
                        accountTeamMember.addError(System.Label.UCD_AccountTeams_validationMessage + accountCategory);
                    }
                }

            }            
        }
    }

    public static void restrictDuplicateCategory(Map<Id, AccountTeamMember> acctTeamMap, Map<Id,AccountTeamMember> oldAccTeamMember){

        Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();

        Set<String> accountIds = new Set<String>();
        Map<Id, Account> mapAccounts ;
        for(AccountTeamMember accountTeamMember : acctTeamMap.values()){

            AccountTeamMember oldAccTeamMemberRec = oldAccTeamMember != null ? oldAccTeamMember.get(accountTeamMember.Id) : null;

            if( accountTeamMember.AccountId != null){
                if( oldAccTeamMemberRec != null &&  accountTeamMember.TeamMemberRole != oldAccTeamMemberRec.TeamMemberRole && oldAccTeamMemberRec.TeamMemberRole == 'Account Owner'){
                    //131
                    accountTeamMember.addError(System.Label.UCD_ACM_AccountTeam_RoleValidation);
                }

                accountIds.add(accountTeamMember.AccountId);
            }
        }

        if(accountIds.size() > 0){
                mapAccounts = new  Map<Id, Account>( [Select id, OwnerId, Core_Account_Category__c, (Select id,AccountId,Core_Account_Category__c from accountTeamMembers) from Account where Id IN :accountIds AND recordtypeID =:intelRecordTypeId ] );
        }

        for(AccountTeamMember accountTeamMember : acctTeamMap.values()){

            List<String> lstAccountTeamCategory = new List<String>();
            List<String> lstAccountTeamCategoryForOtherRecFinal = new List<String>();

            String accountTeamCategory = accountTeamMember.Core_Account_Category__c != null ? accountTeamMember.Core_Account_Category__c : '' ;

            if(String.isNotBlank(accountTeamCategory)){
                if(accountTeamCategory.contains(';')){
                    lstAccountTeamCategory = accountTeamCategory.split(';');
                }else{
                    if(String.isNotBlank(accountTeamCategory)){
                        lstAccountTeamCategory.add(accountTeamCategory);
                    }
                }
            }

            if(accountTeamMember.AccountId != null && mapAccounts != null && mapAccounts.get(accountTeamMember.AccountId) != null){
                for(AccountTeamMember accTeamMemData : mapAccounts.get(accountTeamMember.AccountId).accountTeamMembers){
                    if(accountTeamMember.Id != accTeamMemData.Id){

                        String accountTeamCategoryForOtherRec = accTeamMemData.Core_Account_Category__c != null ? accTeamMemData.Core_Account_Category__c : '' ;
                        List<String> lstAccountTeamCategoryForOtherRec = new List<String>();

                        if(String.isNotBlank(accountTeamCategoryForOtherRec)){
                            if(accountTeamCategoryForOtherRec.contains(';')){
                                lstAccountTeamCategoryForOtherRec = accountTeamCategoryForOtherRec.split(';');
                            }else{
                                if(String.isNotBlank(accountTeamCategoryForOtherRec)){
                                    lstAccountTeamCategoryForOtherRec.add(accountTeamCategoryForOtherRec);
                                }
                            }
                        }

                        if(!lstAccountTeamCategoryForOtherRec.isEmpty()){
                            lstAccountTeamCategoryForOtherRecFinal.addAll(lstAccountTeamCategoryForOtherRec);
                        }

                    }
                }

                for(String categoryValues : lstAccountTeamCategoryForOtherRecFinal){
                    if(lstAccountTeamCategory.contains(categoryValues)){
                        accountTeamMember.addError(System.Label.UCD_ACM_AccountTeam_Duplicate_Values);
                    }
                }
            }
        }
    }
}