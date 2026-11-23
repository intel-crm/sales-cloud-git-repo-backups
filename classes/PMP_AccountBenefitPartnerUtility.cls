public without sharing class PMP_AccountBenefitPartnerUtility {
    final static String INVALID_TIER = 'UNDETERMND';
    
    public static void insertUtility(List<PRM_AccountBenefitAssociation__c > newList){
        
        //System.debug('Benefit inser utility'+newList);
        Set<Id> basicAccessAccountIds = new Set<Id>();
        Set<Id> profileAccountIds = new Set<Id>();
        //Set<Id> enhancedAccountIds = new Set<Id>();
        // Supress Email Functionality
        Map<Id,boolean> profileAccountIdsMap = new Map<Id,boolean>();
        //Map<Id,boolean> enhancedAccountMap = new Map<Id,boolean>();

        // Added as part of OPID Restructure - to throw the error if enhanced benefit is inserted - as part of OPID Restructure - Sathish
        Map<Id,PRM_AccountBenefitAssociation__c> newMapBenefitList = new Map<Id,PRM_AccountBenefitAssociation__c>();
        for(PRM_AccountBenefitAssociation__c accBen : newList){
            newMapBenefitList.put(accBen.Id,accBen);
        }

        for(PRM_AccountBenefitAssociation__c accBen : newList){ //iterating on the BenefitList
            
            //System.debug('Benefit insert utility in for'+newList);
        
            if(accBen.PRM_Status_Nm__c == 'Active'){
                //IPA 2.0: TWC729-7822
               /* if(accBen.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c == PMP_StaticConstants_Partner.BENEFIT_BASIC_ACCESS_CODE && !PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits){
                    //if(!PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits){ 
                    basicAccessAccountIds.add(accBen.PRM_Account_Id__c);
                    //}
                    //System.debug('Basic Access Ids'+basicAccessAccountIds);
                }else*/ if(accBen.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c == PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE && !PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits){
                    //if(!PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits){ 
                        profileAccountIds.add(accBen.PRM_Account_Id__c);
                        profileAccountIdsMap.put(accBen.PRM_Account_Id__c,accBen.PRM_Suppress_Email__c);
                    //}
                }  
        }
        
    }
//IPA 2.0: TWC729-7822
 /*   if(!basicAccessAccountIds.isEmpty()){
        //System.debug('in if---');   
            createBasicAccessPartner(basicAccessAccountIds);
    }*/
    
    if(!profileAccountIds.isEmpty()){
        createBasicProfilePartner(profileAccountIdsMap);
    }
}   


/*******
* Method Name : insertOpidMpiJunctionRecords
* return type : void
* created by  : Onyx Team, Sathish , on 10/05/2021, for OPID Restructure Design & Implementation.
* Description :This method is to insert junction object records to relate One Partner Id(OPID) and Company Records(MPI) - Part of OPID restructure
********/
    public static void insertOpidMpiJunctionRecords(Map<Id,PMP_Company__c> mapCompanies)
    {       Set<Id> accountIds = new Set<Id>();
            List<PMP_OPID_MPI_Rel__c> listOpidMpiJunctionRecords = new List<PMP_OPID_MPI_Rel__c>();
            for(Id accountId  : mapCompanies.keyset()){
                PMP_Company__c companyMPI = mapCompanies.get(accountId);
                if(companyMPI.PMP_Is_Published_Ind__c){ //  Junction record on Published Copy Insert 
                    PMP_OPID_MPI_Rel__c opidMpiJunctionRecord;
                    accountIds.add(accountId);
                    opidMpiJunctionRecord = new PMP_OPID_MPI_Rel__c();
                    opidMpiJunctionRecord.PMP_One_Partner_ID__c = accountId;
                    opidMpiJunctionRecord.PMP_Marketing_Profile_Id__c = companyMPI.Id;
                    opidMpiJunctionRecord.Is_Active__c = true;
                    listOpidMpiJunctionRecords.add(opidMpiJunctionRecord);
                }
            }
                if (Schema.sObjectType.PMP_OPID_MPI_Rel__c.isCreateable() && !listOpidMpiJunctionRecords.isEmpty()) {
                    SObject[] records;
                    while(records == null) {
                            try {
                                records = getLockRecords(accountIds);
                            } catch(QueryException e) {
                               // System.debug('Parent Records Locked while inserting junction Objects:'+e.getMessage());
                            }
                        }
                    insert listOpidMpiJunctionRecords;
                }

    }

    public static SObject[] getLockRecords(Set<Id> accountIds){
        return [SELECT id from Account where Id in:accountIds FOR UPDATE];
    }

    /*******
    * Method Name : validateMultipleOPIDRelations
    * return type : void
    * created by  : Onyx Team, Sathish , on 10/27/2021, for OPID Restructure Design & Implementation.
    * Description :This method is to prevent OPID from linking to multiple MPI's - Part of OPID restructure
    ********/
    public static void validateMultipleOPIDRelations(List<PMP_OPID_MPI_Rel__c> listNew){
        Set<Id> listActiveAccountIds = new Set<Id>();
        Set<Id> listActiveMpiIds =new Set<Id>();
        for(PMP_OPID_MPI_Rel__c relation: listNew){
            if(relation.Is_Active__c == true){
                if(listActiveAccountIds.contains(relation.PMP_One_Partner_ID__c)){
                    relation.addError(System.Label.PMP_MultipleAccountMPI_Error);
                }
                listActiveAccountIds.add(relation.PMP_One_Partner_ID__c);
                listActiveMpiIds.add(relation.PMP_Marketing_Profile_Id__c);
            }
        }

        if(listActiveAccountIds.isEmpty()){
            return;
        }

        List<PMP_OPID_MPI_Rel__c> juncRecRelatedToAccounts = PMP_Utility.getJunctionAccountToMpiByAccountId(listActiveAccountIds);
        for(PMP_OPID_MPI_Rel__c relation : juncRecRelatedToAccounts){
            for(PMP_OPID_MPI_Rel__c junction:listNew)
            if(junction.PMP_One_Partner_ID__c == relation.PMP_One_Partner_ID__c){
                //system.debug('here new at partnerutility:'+junction.PMP_One_Partner_ID__c+'-'+junction.PMP_Marketing_Profile_Id__c);
                //system.debug('here exising at partnerutility:'+relation.PMP_One_Partner_ID__c+'-'+relation.PMP_Marketing_Profile_Id__c);
                junction.addError(System.Label.PMP_MultipleAccountMPI_Error);
                
            }
        }
        
        Map<Id,String> mapAccountToRecordType = new Map<Id,String>();
        List<Account> listAccounts = [Select Id,Core_Account_Record_Type__c from Account where Id in:listActiveAccountIds];

        for(Account acc: listAccounts){
            mapAccountToRecordType.put(acc.Id,acc.Core_Account_Record_Type__c);
        }
       

        

        List<PMP_Company__c> companies = [select Id,PMP_Is_Working_Copy_Ind__c,PMP_Partner_Benefit_Type__c from PMP_Company__c where id in:listActiveMpiIds];
        set<Id> basicAccessCompanyIds = new Set<Id>();
        set<Id> basicProfileOrEnhancedCompanyIds = new Set<Id>();
        set<Id> workingCopyIds = new Set<Id>();
        for(PMP_Company__c company :companies){
            /* if(company.PMP_Partner_Benefit_Type__c ==PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access){
                basicAccessCompanyIds.add(company.Id);
             }else */ if(company.PMP_Partner_Benefit_Type__c ==PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile){
                basicProfileOrEnhancedCompanyIds.add(company.Id);
            }/*else if(company.PMP_Partner_Benefit_Type__c ==PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced){
                basicProfileOrEnhancedCompanyIds.add(company.Id);
            }*/
            if(company.PMP_Is_Working_Copy_Ind__c == true){
                workingCopyIds.add(company.Id);
            }
        }

        for(Id workingCopyId:workingCopyIds){
            for(PMP_OPID_MPI_Rel__c junction:listNew){
                if(junction.PMP_Marketing_Profile_Id__c== workingCopyId){
                        junction.addError(System.Label.PMP_WorkingCopyLink_Error);
                }
            }
        }

        for(PMP_OPID_MPI_Rel__c junction : listNew){
            if(basicAccessCompanyIds.contains(junction.PMP_Marketing_Profile_Id__c)&&mapAccountToRecordType!=null && mapAccountToRecordType.containsKey(junction.PMP_One_Partner_ID__c) && mapAccountToRecordType.get(junction.PMP_One_Partner_ID__c)!='Intel Account'){
                junction.addError(System.Label.PMP_PartnerAccMPILink_Error);
            }else if(basicProfileOrEnhancedCompanyIds.contains(junction.PMP_Marketing_Profile_Id__c)&&mapAccountToRecordType!=null && mapAccountToRecordType.containsKey(junction.PMP_One_Partner_ID__c) && mapAccountToRecordType.get(junction.PMP_One_Partner_ID__c)!='Partner Account Group'){
                junction.addError(System.Label.PMP_IntelAccMPILink_Error);
            }
        }

    }
    ////IPA 2.0: TWC729-7822
   /* public static void createBasicAccessPartner(Set<Id> accountIds){
        String partner_program = '';
        String program_membership = '';
        Map<String,String> accountPartnerProgramMap = new map<String,String>();
        Map<String,String> accountProgramMembershipMap = new Map<String,String>();
        
        // If there is no exiting benefits then creating new company info for Basic Access
        
        List<Account> accountList = [Select id,Name, Core_IPA_Partner_Role__c,Core_Account_Type__c,Core_User_Defined_Website__c,Core_IPA_Badge_Tier__c,toLabel(Core_IPA_Partner_Segment__c),
                                     (SELECT PRM_Account_Id__c,PRM_Channel_Program_Level_Id__r.Name,toLabel(PRM_Partner_Role__c),PRM_Account_Id__r.Core_Account_Type__c
                                      FROM Channel_Memberships1__r where PRM_Status_Nm__c='Approved')                                     
                                     FROM Account where id IN: accountIds]; 
        
        for(Account acc : accountList){
            for( PRM_AccountChannelMembership__c eng : acc.Channel_Memberships1__r){
                if( eng.PRM_Channel_Program_Level_Id__r.Name != INVALID_TIER ){            
                    // String progMembership = eng.PRM_Partner_Role__c + ' - ' + eng.PRM_Channel_Program_Level_Id__r.Name;
                    String bizorgtype = '';
                    if(eng.PRM_Account_Id__r.Core_Account_Type__c!=null){
                        
                        if(!eng.PRM_Account_Id__r.Core_Account_Type__c.containsOnly('Distributor') && eng.PRM_Account_Id__r.Core_Account_Type__c.contains(';Distributor')){
                            bizorgtype  = 'Distributor-'+ eng.PRM_Account_Id__r.Core_Account_Type__c.remove(';Distributor');
                        }
                        else if(!eng.PRM_Account_Id__r.Core_Account_Type__c.containsOnly('Distributor') && eng.PRM_Account_Id__r.Core_Account_Type__c.contains('Distributor;')){
                            
                            bizorgtype  = 'Distributor-'+eng.PRM_Account_Id__r.Core_Account_Type__c.remove('Distributor;');
                        }else if(eng.PRM_Account_Id__r.Core_Account_Type__c.containsOnly('Distributor'))
                        {
                            bizorgtype = eng.PRM_Account_Id__r.Core_Account_Type__c;
                            
                        }
                        
                    }
                    
                    //System.debug('Distributor----'+bizorgtype );
                    String progMembership = eng.PRM_Partner_Role__c == 'Distributor'? bizorgtype.replace(';','-'):eng.PRM_Partner_Role__c + ' - ' + eng.PRM_Channel_Program_Level_Id__r.Name;
                    //system.debug('---progMembership---'+progMembership);
                    
                    if(!program_membership.contains(progMembership))
                        program_membership += ';'  + progMembership;
                    if(!partner_program.contains(';'+eng.PRM_Partner_Role__c))
                        partner_program += ';'  + eng.PRM_Partner_Role__c; 
                    
                }
                else{
                    //system.debug('---entering else---');
                    if(!partner_program.contains(eng.PRM_Partner_Role__c))
                        partner_program += ';'  + eng.PRM_Partner_Role__c;                        
                } 
                
            }
            
            
            accountPartnerProgramMap.put(acc.Id, partner_program);
            accountProgramMembershipMap.put(acc.Id,program_membership); 
        }

        // Added this map as part of OPID Restructure to get the inserted MPI Id's which are used to insert Junction records further - Sathish
        Map<Id,PMP_Company__c> mapAccountIdMpiCreation = new Map<Id,PMP_Company__c>();
        for(Account acc : accountList){
            PMP_Company__c company                          = new PMP_Company__c();
            company.Name                                    = acc.Name;
   //       company.PMP_Account_Id__c                        = acc.Id;   Commented as part of OPID Restructure - Sathish   
    // Added as part of OPID Restructure to populate OPID SFID using Related Account field - Sathish
            company.PMP_Opid_Sfid_Txt__c                        =  acc.Id;
            company.PMP_Company_Lifecycle_Status_Nm__c      = PMP_StaticConstants_Partner.Published;        
            company.PMP_Account_Website__c                  = acc.Core_User_Defined_Website__c;
            company.PMP_Is_Published_Ind__c                 = true;
            company.PMP_Partner_Benefit_Type__c             = PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access;
            company.PMP_Account_Program_Membership__c        = accountProgramMembershipMap.get(acc.Id);
            company.PMP_Partner_Program_nm__c                = accountPartnerProgramMap.get(acc.Id);
            if(acc.Core_IPA_Badge_Tier__c !=null){company.PMP_IPA_Badge_Tier_Txt__c= acc.Core_IPA_Badge_Tier__c;
            }else{
                company.PMP_IPA_Badge_Tier_Txt__c            = calculateIpaBadgeTier(acc.Channel_Memberships1__r);
            }
            // Added as part of OPID Restructure to populate biz-org-type using text field - Sathish
            company.PMP_Biz_Org_Type_Value_Txt__c                 = getBizOrgType( new Set<Id>{acc.id}, new Map<Id,String>{acc.id => acc.Core_Account_Type__c});
            mapAccountIdMpiCreation.put(acc.Id,company);

            
        }

        if(!mapAccountIdMpiCreation.isEmpty()){
            if(Schema.sObjectType.PMP_Company__c.isCreateable()){
                insert mapAccountIdMpiCreation.values() ;
            }
            insertOpidMpiJunctionRecords(mapAccountIdMpiCreation);
        }

        
    }*/
    
    public static void createBasicProfilePartner(Map<Id, Boolean> profileAccountIdsMap){
        //List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        String partner_program = '';
        String program_membership = '';
        Map<String,String> accountPartnerProgramMap = new map<String,String>();
        Map<String,String> accountProgramMembershipMap = new Map<String,String>();
        
        Set<Id> accountIdsForCreation = checkIfExistingPartner(profileAccountIdsMap.keySet());
        
        if(!accountIdsForCreation.isEmpty()){
            
            List<Account> accountList = [Select id,Name, Core_IPA_Partner_Role__c,Core_Account_Type__c,Core_User_Defined_Website__c,Core_IPA_Badge_Tier__c,toLabel(Core_IPA_Partner_Segment__c),
                                         (SELECT PRM_Account_Id__c,PRM_Channel_Program_Level_Id__r.Name,toLabel(PRM_Partner_Role__c),PRM_Account_Id__r.Core_Account_Type__c
                                          FROM Channel_Memberships1__r where PRM_Status_Nm__c='Approved')                                     
                                         FROM Account where id IN: accountIdsForCreation];
            // Logic to populate random related location account name on to the Company record
            Map<Id,String> mapPagAccountToIntelAccountName = new Map<Id,String>();
            List<Core_Account_Group_Member__c> locationAccountGrpMembrs = [Select Id,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Name From Core_Account_Group_Member__c Where Core_Partner_Account_Id__c IN :accountIdsForCreation AND Core_Inactive_Ind__c = false];
            for(Core_Account_Group_Member__c grpMem : locationAccountGrpMembrs){
                if(!mapPagAccountToIntelAccountName.containsKey(grpMem.Core_Partner_Account_Id__c)){
                    mapPagAccountToIntelAccountName.put(grpMem.Core_Partner_Account_Id__c, grpMem.Core_Intel_Account_Id__r.Name);
                }
            }
            
            for(Account acc : accountList){
                for( PRM_AccountChannelMembership__c eng : acc.Channel_Memberships1__r){
                    if( eng.PRM_Channel_Program_Level_Id__r.Name != INVALID_TIER ){            
                        // String progMembership = eng.PRM_Partner_Role__c + ' - ' + eng.PRM_Channel_Program_Level_Id__r.Name;
                        // String progMembership = eng.PRM_Partner_Role__c == 'Distributor'? eng.PRM_Partner_Role__c + ' - ' + eng.PRM_Account_Id__r.Core_Account_Type__c:eng.PRM_Partner_Role__c + ' - ' + eng.PRM_Channel_Program_Level_Id__r.Name;
                        String bizorgtype = '';
                        String progMembership = ''; 
                        if(eng.PRM_Account_Id__r.Core_Account_Type__c!=null){
                            bizorgtype = filterDistiBizOrgs(eng.PRM_Account_Id__r.Core_Account_Type__c);                                
                        }
                        if(eng.PRM_Partner_Role__c == 'Distributor'){
                            if(bizorgtype.split('\\;').size() > 1){
                                for(String biz : bizorgtype.split('\\;')){
                                    progMembership += 'Distributor' + ' - ' + biz + ';';
                                }
                                if(progMembership.endsWith(';')) {
                                    progMembership = progMembership.substring(0, progMembership.length() - 1);
                                }
                            }
                            else if(String.isEmpty(bizorgtype) && eng.PRM_Account_Id__r.Core_Account_Type__c!=null){
                                progMembership = eng.PRM_Account_Id__r.Core_Account_Type__c.contains('Distributor') ? 'Distributor':'';
                            }
                            else{ 
                                progMembership = 'Distributor' + ' - ' + bizorgtype;
                            }
                        }     
                     /*  else if(eng.PRM_Partner_Role__c == 'Service Provider'){
                            if(bizorgtype.split('\\;').size() > 1){
                                for(String biz : bizorgtype.split('\\;')){
                                    progMembership += 'Cloud & Comms Service Provider' + ' - ' + biz + ';';
                                }
                                if(progMembership.endsWith(';')) {
                                    progMembership = progMembership.substring(0, progMembership.length() - 1);
                                }
                            }
                            else if(String.isEmpty(bizorgtype) && eng.PRM_Account_Id__r.Core_Account_Type__c!=null){
                                progMembership = eng.PRM_Account_Id__r.Core_Account_Type__c.contains('Service Provider') ? 'Cloud & Comms Service Provider':'';
                            }
                            else{ 
                                progMembership = 'Cloud & Comms Service Provider' + ' - ' + bizorgtype;
                            }
                        }   */     
                        else{
                            progMembership =  eng.PRM_Partner_Role__c + ' - ' + eng.PRM_Channel_Program_Level_Id__r.Name;
                            if(eng.PRM_Account_Id__r.Core_Account_Type__c !=null && eng.PRM_Partner_Role__c == 'Solution Provider' && eng.PRM_Account_Id__r.Core_Account_Type__c.contains('IoT Solution Aggregator')){
                                //if(eng.PRM_Partner_Role__c == 'Solution Provider' && eng.PRM_Account_Id__r.Core_Account_Type__c.contains('IoT Solution Aggregator')){
                                    progMembership =  eng.PRM_Partner_Role__c + ' - ' + 'IoT Solution Aggregator';
                                //}
                            }
                        }
                        
                        if(!program_membership.contains(progMembership))
                            program_membership += ';'  + progMembership;
                        if(!partner_program.contains(';'+eng.PRM_Partner_Role__c))
                            partner_program += ';'  + eng.PRM_Partner_Role__c; 
                        
                    }
                    else{
                        if(!partner_program.contains(eng.PRM_Partner_Role__c))
                            partner_program += ';'  + eng.PRM_Partner_Role__c;                        
                    } 
                    
                }
                accountPartnerProgramMap.put(acc.Id, partner_program);
                accountProgramMembershipMap.put(acc.Id,program_membership); 
            }
            
            Map<Id,PMP_Company__c> mapAccountIdMpiCreation = new Map<Id,PMP_Company__c>();
            //creating new company info for Basic Access        
            for(Account acc : accountList){
                
                PMP_Company__c company                           = new PMP_Company__c();
                // company.Id                                       = company_existing == null ? null : company_existing.Id;

                if(!mapPagAccountToIntelAccountName.containsKey(acc.Id))
                    company.Name                                     = acc.Name;
                else {
                    company.Name                                    = mapPagAccountToIntelAccountName.get(acc.Id);
                }
                // company.PMP_Account_Id__c                        = acc.Id;   Commented as part of OPID Restructure - Sathish
                company.PMP_Company_Lifecycle_Status_Nm__c       = PMP_StaticConstants_Partner.Draft;          
                company.PMP_Account_Website__c                   = acc.Core_User_Defined_Website__c;
                company.PMP_Account_Program_Membership__c        = accountProgramMembershipMap.get(acc.Id);
                company.PMP_Partner_Program_nm__c                = accountPartnerProgramMap.get(acc.Id);                 
                //company.PMP_Account_Specialty__c                 = acc.Core_IPA_Partner_Speciality__c;  Commented as part of Specialty Deactivation - Divya  
                company.PMP_Is_Published_Ind__c                  = true;                        
                company.PMP_Is_Working_Copy_Ind__c               = false;            
                company.PMP_Company_Status_Update_Dt__c          = Date.today();
                company.PMP_Initial_Storefront_Submit_Date_Dt__c = Date.today();
                 // Added as part of OPID Restructure to populate OPID SFID using Related Account field - Sathish
                company.PMP_Opid_Sfid_Txt__c                        =  acc.Id;
               // company.PMP_One_Partner_ID__c                    = acc.Id; //grp_mem.Core_Partner_Account_Id__c;
                company.PMP_Partner_Benefit_Type__c              = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
                if(acc.Core_IPA_Badge_Tier__c !=null){company.PMP_IPA_Badge_Tier_Txt__c            = acc.Core_IPA_Badge_Tier__c;
                }else{
                    company.PMP_IPA_Badge_Tier_Txt__c            = calculateIpaBadgeTier(acc.Channel_Memberships1__r);
                }
                company.PMP_Partner_Segment_Nm__c                = acc.Core_IPA_Partner_Segment__c;
                company.PMP_Biz_Org_Type_Value_Txt__c                 = getBizOrgType( new Set<Id>{acc.id}, new Map<Id,String>{acc.id => acc.Core_Account_Type__c});
                company.PMP_Suppress_Email_Ind__c=profileAccountIdsMap.get(acc.Id);
   
                mapAccountIdMpiCreation.put(acc.Id,company);
            }
            
            if(!mapAccountIdMpiCreation.isEmpty()){
            
                insert mapAccountIdMpiCreation.values() ;
                
                //System.enqueueJob(new PMP_SearchCreatePartnerWorkCopy(partnerList));//Create Working Copy
                createPartnerWorkingCopyRecord(mapAccountIdMpiCreation.values());
                
                insertOpidMpiJunctionRecords(mapAccountIdMpiCreation);
                //InsertCompanyAttributeMappingRecords(partnerList);            
            } 
        }
        
    }


public static String getBizOrgType(Set<Id> relatedAccounts,Map<Id,String> mapAccountToBizOrgType){
    List<String> bizOrgType = new List<String>();
    for(Id accountId : relatedAccounts){
        String accountBizOrgType  = mapAccountToBizOrgType.get(accountId);   
        if(accountBizOrgType!=null){
            List<String> bizOrgs = accountBizOrgType.split(';');
            for(String biz: bizOrgs){
                if(PMP_StaticConstants_Partner.accountBizOrgTypeValues.contains(biz) && !bizOrgType.contains(biz)){
                    bizOrgType.add(biz);
                }    
            }
        }
    }
    return String.join(bizOrgType, ';');
}    

    
public static void updateUtility(List<PRM_AccountBenefitAssociation__c> updatedList, Map<Id,PRM_AccountBenefitAssociation__c> oldMap){
        
        Set<Id> accountIds = new Set<Id>();
        List<String> benefitIds = new List<String>();
        Map<Id,List<PRM_AccountChannelMembership__c>> mapAccountToAcmList = new Map<Id,List<PRM_AccountChannelMembership__c>>();


        Map<Id,PRM_AccountBenefitAssociation__c> mapBenefitsUpdated = new Map<Id,PRM_AccountBenefitAssociation__c>();
        for(PRM_AccountBenefitAssociation__c benAcc : updatedList){
            mapBenefitsUpdated.put(benAcc.id,benAcc);
            accountIds.add(benAcc.PRM_Account_Id__c);
            
        }

        for(PRM_AccountBenefitAssociation__c benAcc : oldMap.values()){
            benefitIds.add(benAcc.PRM_Partner_Benefit_Id__c);
        }

       
        //Map<String,String> benIdToCodeMap = getBenefitCode(benefitIds);
        Set<Id> inactivateAccountMpiRelation = new Set<Id>();
        Set<Id> inactivatedAccountIds = new Set<Id>();
	//IPA 2.0 simplification TWC729-8060  
        set<Id> activAccIds=new set<Id>();
        list<PMP_OPID_MPI_Rel__c> lstOfactiveMPIsToUpdate=new  list<PMP_OPID_MPI_Rel__c>();
      
        for(PRM_AccountBenefitAssociation__c accBen : updatedList){
            
            if(accBen.PRM_Status_Nm__c == 'Inactive' && oldMap.get(accBen.Id).PRM_Status_Nm__c != 'Inactive'){
	    //IPA 2.0 simplification TWC729-8060  
                if(accBen.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c ==PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE){
                    inactivatedAccountIds.add(accBen.PRM_Account_Id__c);
                    mapAccountToAcmList.put(accBen.PRM_Account_Id__c,new List<PRM_AccountChannelMembership__c>());
                }
                if(accBen.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c ==PMP_StaticConstants_Partner.BENEFIT_BASIC_ACCESS_CODE){
                    inactivateAccountMpiRelation.add(accBen.PRM_Account_Id__c);
                }
            }
	    //IPA 2.0 simplification TWC729-8060  
             if(accBen.PRM_Status_Nm__c == 'Active' && oldMap.get(accBen.Id).PRM_Status_Nm__c != 'Active'){
                    activAccIds.add(accBen.PRM_Account_Id__c);
              //  getAllAccountRelatedToMPINotActive
             }
        }
        //IPA 2.0 simplification TWC729-8060
        if(!activAccIds.isEmpty()) {
        for(PMP_OPID_MPI_Rel__c opidmpi:[select Id,PMP_One_Partner_ID__c, PMP_Marketing_Profile_Id__c,
                                        PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c,Is_Active__c
                                        from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c in :activAccIds 
                                        and Is_Active__c = false]){
            opidmpi.Is_Active__c=true;
            lstOfactiveMPIsToUpdate.add(opidmpi);
         }
    }
    if(!lstOfactiveMPIsToUpdate.isEmpty()) {
         Map<String, String> exceptionMap = new Map<String, String>();
        List<Database.SaveResult> saveResults =  Database.update(lstOfactiveMPIsToUpdate, false);
         //   List<Core_Log_Entry__c> logErrors = new List<Core_Log_Entry__c>();                        
            for(Database.SaveResult sr : saveResults){
                If ( !sr.isSuccess()) {                 
                    for(Database.Error err : sr.getErrors()) { 
                        
                        exceptionMap.put('Core_Details__c', ' Error while updating mpi records : ');
                        exceptionMap.put('Core_Message__c', 'Benefit change');
                        exceptionMap.put('Core_Origin__c', 'pmp_accountBenefitParterUtility');
                        exceptionMap.put('Core_Project__c','Marketplace');
                        exceptionMap.put('Core_Scope__c','update failure');
                        exceptionMap.put('Core_Severity__c', 'Critical');
                        PMP_Utility.createLogEntry(exceptionMap);                           
                    }                            
                }
            }
    }   //IPA 2.0 simplification TWC729-8060    
        
    if(inactivatedAccountIds.isEmpty()){
        return;
    }
    // logic to inactivate the junction relation if ACM list is empty
    List<PRM_AccountChannelMembership__c> acmList = [SELECT Id, PRM_Account_Id__c,PRM_Account_Id__r.name, PRM_Channel_Program_Id__c,PRM_Channel_Program_Id__r.name,PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.name,PRM_Status_Nm__c,PRM_Partner_Role__c FROM PRM_AccountChannelMembership__c where PRM_Account_Id__c IN: inactivatedAccountIds AND PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_Status_Nm__c ='Approved'];
    for(PRM_AccountChannelMembership__c acm : acmList){
        if(mapAccountToAcmList.containsKey(acm.PRM_Account_Id__c)){
            mapAccountToAcmList.get(acm.PRM_Account_Id__c).add(acm);
        }
    }

    for(Id accId : mapAccountToAcmList.keySet()){
        if(mapAccountToAcmList.get(accId).isEmpty()){inactivateAccountMpiRelation.add(accId);
        }
    }

    if(!inactivateAccountMpiRelation.isEmpty())  {
        markRelationshipInactive(inactivateAccountMpiRelation);
    }
    
        
    }


  /*  public static void onInactivateBenefitsOnACMTrigger(List<PRM_AccountBenefitAssociation__c> updatedBenefitList){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> benefitIds = new Set<Id>();

        for(PRM_AccountBenefitAssociation__c accBen : updatedBenefitList){
            benefitIds.add(accBen.Id);
        }

        Map<String,String> benIdToCodeMap = getBenefitCode(benefitIds);

        List<String> listBenefitCodes =new List<string>{PMP_StaticConstants_Partner.BENEFIT_BASIC_ACCESS_CODE,PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE,PMP_StaticConstants_Partner.BENEFIT_ENHANCED_CODE};
        for(PRM_AccountBenefitAssociation__c accBen: updatedBenefitList){
            if(!benIdToCodeMap.isEmpty() && benIdToCodeMap.containsKey(accBen.Id) && listBenefitCodes.contains(accBen.Id)){
                accountIds.add(accBen.PRM_Account_Id__c);
            }  
        }

        if(accountIds.isEmpty()){
            return;
        }

        markRelationshipInactive(accountIds);

    }*/

    public static Set<Id> checkIfExistingPartner(Set<Id> accountIds){
        Set<Id> remainingAccountIds = new Set<Id>();
        Set<Id> existingAccountIds = new Set<Id>();
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        Map<Id,Set<Id>> mapMpiToAccountListActive;
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){
            // Modified as part of OPID Restructure
            List<PMP_OPID_MPI_Rel__c> junctionObjects = PMP_Utility.getJunctionAccountToMpiByAccountId(accountIds);
            Set<Id> existingPartnerIds = PMP_Utility.getAllMpiIds(junctionObjects);
            mapMpiToAccountListActive = PMP_Utility.getMapMpiToListAccountActive(junctionObjects);

            partnerList = [SELECT id,PMP_Benefit_Update_Ind__c,PMP_Is_Working_Copy_Ind__c,PMP_Published_Copy_Id__c,toLabel(PMP_Account_Id__r.Core_IPA_Partner_Segment__c) from PMP_Company__c
                           where Id IN: existingPartnerIds
                           AND ((PMP_Is_Published_Ind__c = true and PMP_Benefit_Update_Ind__c = true) or (PMP_Is_Working_Copy_Ind__c=true))];
            }


        for(PMP_Company__c partner : partnerList){
           
            // add all the accounts which are related to MPI and have a MPI which is related         
            for(Id accountId : mapMpiToAccountListActive.get(partner.id)){
                existingAccountIds.add(accountId);
            }
        }
        
        for(String accId : accountIds){
            if(!existingAccountIds.contains(accId)){
                remainingAccountIds.add(accId);
            }
        }

        // return Accounts which have no MPI to create basic profile
        
        return remainingAccountIds;
        
    }
    

    /*******
    * Method Name : markRelationshipInactive
    * return type : void
    * created by  : Onyx Team, Sathish , on 10/18/2021, for OPID Restructure Design & Implementation.
    * Description :This method is to mark relationship's inactive for the given account Id's - Part of OPID restructure
    ********/

    public static void markRelationshipInactive(set<Id> accountIds){
        List<PMP_OPID_MPI_Rel__c> updatedJunctionRecords = new List<PMP_OPID_MPI_Rel__c>();
        List<PMP_OPID_MPI_Rel__c> junctionObjects = PMP_Utility.getJunctionAccountToMpiByAccountId(accountIds);
        for(PMP_OPID_MPI_Rel__c relationRecord:junctionObjects){
            if(relationRecord.Is_Active__c == true){
                relationRecord.Is_Active__c = false;
                updatedJunctionRecords.add(relationRecord);
            }
        }
        if(Schema.sObjectType.PMP_OPID_MPI_Rel__c.isUpdateable()){      
        update updatedJunctionRecords;
        }
    }

    public static void markPartnerAsDeleted(Set<Id> accountIds){
        List<PMP_Company__c> partnerList=new List<PMP_Company__c>();
        
        if(!accountIds.isEmpty())  //Checking the size
        {
            

            // Modified as part of OPID Restructure - to Inactivate the MPI - Sathish
            List<PMP_OPID_MPI_Rel__c> junctionObjects = PMP_Utility.getJunctionAccountToMpiByAccountId(accountIds);
            Set<Id> existingPartnerIds = PMP_Utility.getAllMpiIds(junctionObjects);
            Map<Id,Set<Id>> mapMpiToAccountListActive = PMP_Utility.getMapMpiToListAccountActive(junctionObjects);
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){                
                partnerList =   [select id, PMP_Benefit_Update_Ind__c,
                                            PMP_Partner_Benefit_Type__c 
                                from PMP_Company__c 
                                where Id in:existingPartnerIds
                                ];
            }
            if(!partnerList.isEmpty())
            {
                for(PMP_Company__c company:partnerList)
                {
                    // Inactivate the MPI - If only Active relationship is deactivated
                    if(!mapMpiToAccountListActive.isEmpty()&&mapMpiToAccountListActive.containsKey(company.Id) && mapMpiToAccountListActive.get(company.Id).size()==0){company.PMP_Benefit_Update_Ind__c=True;//Updating field
                    }    
                    //company.PMP_Partner_Benefit_Type__c='';
                }
                if(Schema.sObjectType.PMP_Company__c.isUpdateable()){
                    //The below static constant added by Krishna Ch for 101 SOQL issue.
                    Map<String,Core_Trigger_Executions__c> companyTriggerFlagMap = Core_Trigger_Executions__c.getAll();
                    if(companyTriggerFlagMap!=null && companyTriggerFlagMap.isEMpty() && companyTriggerFlagMap.containsKey('Sync_Published_Copy') 
                    && !companyTriggerFlagMap.get('Sync_Published_Copy').Core_Active__c){ // check added by dinesh to avoid de-ref error
                        PMP_StaticConstants_Partner.isCompanyAfterUpdateTriggerActive = False;
                    }

                    update partnerList;
                } 
                
                
            }
        }
    }
    
    public static void deleteUtility(List<PRM_AccountBenefitAssociation__c > listToBeDeleted){
        
        Set<Id> accountIds = new Set<Id>();       
        for(PRM_AccountBenefitAssociation__c accBen : [ select Id,Name,PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Account_Id__c,PRM_Status_Nm__c from PRM_AccountBenefitAssociation__c where Id IN : listToBeDeleted ]){
            accountIds.add(accBen.PRM_Account_Id__c);
        }
        if(!accountIds.isEmpty()){
            markPartnerAsDeleted(accountIds);
        }
    }
    
    public static Map<String,String> getBenefitCode(List<String> benefitIds){
        List<PRM_PartnerBenefit__c> benefits = new List<PRM_PartnerBenefit__c>();
        if(Schema.sObjectType.PRM_PartnerBenefit__c.isAccessible()){
            benefits = [SELECT id, PRM_Benefit_Cd__c from PRM_PartnerBenefit__c where Id IN :benefitIds];
        }
        Map<String,String> returnMap = new Map<String,String>();
        
        for(PRM_PartnerBenefit__c ben : benefits){
            returnMap.put(ben.Id,ben.PRM_Benefit_Cd__c);
        }
        return returnMap;
    }


    /*******
    * Method Name : getMapBenefitCodesToId
    * return type : void
    * created by  : Onyx Team, Sathish , on 10/18/2021, for OPID Restructure Design & Implementation.
    * Description :This method is to get the Map of Benefit code's and respective benefit Id's for given benefit codes - Part of OPID restructure
    ********/
    public static Map<String,String> getMapBenefitCodesToId(List<String> benefitCodes){
        List<PRM_PartnerBenefit__c> benefits = new List<PRM_PartnerBenefit__c>();
        if(Schema.sObjectType.PRM_PartnerBenefit__c.isAccessible()){
            benefits = [SELECT id, PRM_Benefit_Cd__c from PRM_PartnerBenefit__c where  PRM_Benefit_Cd__c IN :benefitCodes];
        }
        Map<String,String> returnMap = new Map<String,String>();
        
        for(PRM_PartnerBenefit__c ben : benefits){
            returnMap.put(ben.PRM_Benefit_Cd__c,ben.Id);
        }
        return returnMap;
    }
    
  // Modified as part of OPID Restructure to get the tier Info from all the related Accounts - Sathish
  // for updating the MP info record when new tier is created/Updated in account
  public Static  void updatePartnerWhenTierIsUpdated(List<PRM_AccountChannelMembership__c> accIdList){
    Set<Id> accountIds = new Set<Id>();

    for(PRM_AccountChannelMembership__c acm :accIdList){
        accountIds.add(acm.PRM_Account_Id__c);          
    }  

  
    updateTierOnMPI(accountIds);
}


/*******
* Method Name : updateTierOnMPI
* return type : void
* created by  : Onyx Team, Sathish , on 10/13/2021, for OPID Restructure Design & Implementation.
* Description :This method is to update tier info for the MPI's related to the Account Id's - Part of OPID restructure
********/
public static void updateTierOnMPI(set<Id> accountIds){
    
    //system.debug('AccountIds in ACM Trigger ==>'+accountIds);
    //Start: OPID to MPI tier defect fix added by Krishna Ch : OPID to MPI tier defect fix DE109646 : QA/PROD: MPI record is not getting updated when updated ACM tier/ Benefit/ New partner
    if( Schema.sObjectType.Core_Account_Group_Member__c.isAccessible() && (accountIds!=null && !accountIds.IsEmpty())){ // Fetching parent account id.
      
        for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where (Core_Intel_Account_Id__c IN :accountIds OR Core_Partner_Account_Id__c IN :accountIds)AND Core_Inactive_Ind__c = false]){ 
                accountIds.add(agm.Core_Partner_Account_Id__c);
                accountIds.add(agm.Core_Intel_Account_Id__c);
                //System.debug('the IntelOpidAccIds==>'+accountIds);
            } 
        
    }
    
    Id intelacc_rectypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    // add related accounts to the set of accounts whose tier info is updated
      // get the Published MPI related to the Account Id's
      List<PMP_OPID_MPI_Rel__c> junctionObjectsRelatedToAccounts = PMP_Utility.getJunctionAccountToMpiByAccountId(accountIds);
      Set<Id> allMpiIdRelatedToAccounts = PMP_Utility.getAllMpiIds(junctionObjectsRelatedToAccounts);
  
       // If No MPI related to accounts, return
       if(allMpiIdRelatedToAccounts.isEmpty()){
          return;
      }
  
      // get all the sibling accounts of the Account related to MPI
      List<PMP_OPID_MPI_Rel__c> junctionObjectsRelatedToMpi = PMP_Utility.getJunctionAccountToMpiByCompanyId(allMpiIdRelatedToAccounts);
      Map<Id,Set<Id>> mapMpiToListAccountActive = PMP_Utility.getMapMpiToListAccountActive(junctionObjectsRelatedToMpi);
      
  
      // mapMpiToListAccountActive.keyset() contains both published and working Copy Mpi Id's related to the accounts    
      List<PMP_Company__c> partners ;
      if(Schema.sObjectType.PMP_Company__c.isAccessible()){
          partners=[SELECT id,Name,PMP_Published_Copy_Id__r.PMP_Account_Program_Membership__c,PMP_IPA_Badge_Tier_Txt__c, PMP_Account_Program_Membership__c,PMP_Partner_Program_nm__c,PMP_Account_Website__c from PMP_Company__c where Id IN :mapMpiToListAccountActive.keyset()];
      }

    for(Id mpi : mapMpiToListAccountActive.keySet()){
        accountIds.addAll(mapMpiToListAccountActive.get(mpi));
    }

    
    //ENd : OPID to MPI tier defect fix DE109646 : QA/PROD: MPI record is not getting updated when updated ACM tier/ Benefit/ New partner role addition.
    
    Map<Id,String> mapAccountToCoreAccountType = new Map<Id,String>();
    List<Account> accountList = [Select id,Name,Core_IPA_Badge_Tier__c,Core_Account_Type__c,Core_IPA_Partner_Segment__c,RecordTypeId,Core_User_Defined_Website__c,
                                 (SELECT PRM_Account_Id__c,PRM_Channel_Program_Level_Id__r.Name,tolabel(PRM_Partner_Role__c),PRM_Account_Id__r.Core_Account_Type__c FROM Channel_Memberships1__r where PRM_Status_Nm__c='Approved')                                    
                                 FROM Account where id IN: accountIds];
    
    
    Map<Id,String> mapAccountToPartnerSegment = new Map<Id,String>();
    Map<Id,String> mapAccountToSpeciality = new Map<Id,String>();
    Map<Id,Account> mapAccount = new Map<Id,Account>();                  
    
    Map<Id,List<PRM_AccountChannelMembership__c>> mapAccountToListChannelMemberships = new Map<Id,List<PRM_AccountChannelMembership__c>>();
    for(Account acc: accountList){
        mapAccount.put(acc.Id,acc);
        mapAccountToCoreAccountType.put(acc.Id,acc.Core_Account_Type__c);
        mapAccountToPartnerSegment.put(acc.Id,acc.Core_IPA_Partner_Segment__c);
        //mapAccountToSpeciality.put(acc.Id,acc.Core_IPA_Partner_Speciality__c); Commented as part of Specialty Deactivation - Divya
        List<PRM_AccountChannelMembership__c> listChannelMemberships = new List<PRM_AccountChannelMembership__c>();
        for( PRM_AccountChannelMembership__c eng : acc.Channel_Memberships1__r){
            listChannelMemberships.add(eng);
        }
        mapAccountToListChannelMemberships.put(acc.Id,listChannelMemberships);
    }

    

    
    Schema.DescribeFieldResult fieldResultSpeciality = PMP_Company__c.PMP_Account_Specialty__c.getDescribe();
   List<Schema.PicklistEntry> pleSpeciality = fieldResultSpeciality.getPicklistValues();
   Set<String> picklistValuesSpeciality = new Set<String>();
   for( Schema.PicklistEntry f : pleSpeciality)
   {
       picklistValuesSpeciality.add(f.getValue());
   }
   Schema.DescribeFieldResult fieldResultSegment = PMP_Company__c.PMP_Partner_Segment_Nm__c.getDescribe();
   List<Schema.PicklistEntry> pleSegment = fieldResultSegment.getPicklistValues();
   Set<String> picklistValuesSegment = new Set<String>();
   for( Schema.PicklistEntry f : pleSegment)
   {
       picklistValuesSegment.add(f.getValue());
   }

    

    for(PMP_Company__c company : partners){
        company.PMP_Account_Program_Membership__c = null;
        company.PMP_Partner_Program_nm__c = null;
        company.PMP_IPA_Badge_Tier_Txt__c = null;

        // If Intel account update website info and company name to account name also
        if(mapMpiToListAccountActive.get(company.id).size()==1){
            List<Id> intelAccountIds = new List<Id>();
            intelAccountIds.addAll(mapMpiToListAccountActive.get(company.id));
            Account intelAcc = mapAccount.get(intelAccountIds[0]);
            if(intelAcc.RecordTypeId == intelacc_rectypeid){
                if(company.Name!=intelAcc.Name){
                    Integer maxSize = 80;
                    if(intelAcc.Name.length() > maxSize ){
                        company.Name = intelAcc.Name.substring(0, maxSize);
                    }else{
                        company.Name = intelAcc.Name;
                    }
                }

                if(company.PMP_Account_Website__c!=intelAcc.Core_User_Defined_Website__c){
                    company.PMP_Account_Website__c = intelAcc.Core_User_Defined_Website__c;
                }

            }
        }
        company.PMP_Biz_Org_Type_Value_Txt__c = getBizOrgType(mapMpiToListAccountActive.get(company.id),mapAccountToCoreAccountType);
        
        company.PMP_Partner_Segment_Nm__c = rollUpMultiPicklist(mapMpiToListAccountActive.get(company.id),mapAccountToPartnerSegment,picklistValuesSegment);
        company.PMP_Account_Specialty__c =  rollUpMultiPicklist(mapMpiToListAccountActive.get(company.id),mapAccountToSpeciality,picklistValuesSpeciality);

        List<PRM_AccountChannelMembership__c> listAllAccountChannelMembershipsRelatedToMpi = new List<PRM_AccountChannelMembership__c>();
        for(Id accountId:mapMpiToListAccountActive.get(company.id)){
            listAllAccountChannelMembershipsRelatedToMpi.addAll(mapAccountToListChannelMemberships.get(accountId));
        }
        
        String programMembership='';
        String partnerProgram='';
        String ipaBadgeTier= calculateIpaBadgeTier(listAllAccountChannelMembershipsRelatedToMpi);
            for(PRM_AccountChannelMembership__c eng : listAllAccountChannelMembershipsRelatedToMpi){
                if( eng.PRM_Channel_Program_Level_Id__r.Name != INVALID_TIER ){
                    // String progMembership = eng.PRM_Partner_Role__c + ' - ' + eng.PRM_Channel_Program_Level_Id__r.Name; 
                    // String progMembership = eng.PRM_Partner_Role__c == 'Distributor'? eng.PRM_Partner_Role__c + ' - ' + eng.PRM_Account_Id__r.Core_Account_Type__c:eng.PRM_Partner_Role__c + ' - ' + eng.PRM_Channel_Program_Level_Id__r.Name;
                                       
                String progMembership = getProgramMembership(eng);    
                programMembership= formatAndPopulateMultiPicklistForProgramMembership(programMembership,progMembership);
                partnerProgram = formatAndPopulateMultiPicklist(partnerProgram,eng.PRM_Partner_Role__c);
                
                }
                else{
                    partnerProgram = formatAndPopulateMultiPicklist(partnerProgram,eng.PRM_Partner_Role__c);
                }     
            }
            company.PMP_Account_Program_Membership__c=programMembership;
            company.PMP_Partner_Program_nm__c= partnerProgram;
            company.PMP_IPA_Badge_Tier_Txt__c = ipaBadgeTier;
         
    }

     
    if(Schema.sObjectType.PMP_Company__c.isUpdateable() && !partners.isempty()){
        
        //The below static constant added by Krishna Ch for 101 SOQL issue.
        Map<String,Core_Trigger_Executions__c> companyTriggerFlagMap = Core_Trigger_Executions__c.getAll();
        if(companyTriggerFlagMap.containsKey('Sync_Published_Copy') && 
           !companyTriggerFlagMap.get('Sync_Published_Copy').Core_Active__c){ 
               PMP_StaticConstants_Partner.isCompanyAfterUpdateTriggerActive = False;
           }
        
        update partners;
                   
    }
    
}

/*******
* Method Name : rollUpMultiPicklist
* return type : void
* created by  : Onyx Team, Sathish , on 10/13/2021, for OPID Restructure Design & Implementation.
* Description :This method is to roll the Multi-Picklist values from related Accounts and respective partner details - Part of OPID restructure
********/
public static String rollUpMultiPicklist(Set<Id> activeAccounts,Map<Id,String> mapAccountToPartnerDetails,Set<String> allowedValues){
    List<String> rolledUpPicklistValues = new List<String>();
    for(Id accountId : activeAccounts){
        if(mapAccountToPartnerDetails.get(accountId)!=null){
                List<String> picklistValues = mapAccountToPartnerDetails.get(accountId).split(';');
                for(String value : picklistValues){
                    if(allowedValues.contains(value)&&!rolledUpPicklistValues.contains(value)){
                        rolledUpPicklistValues.add(value);
                    }
                }
        }
    }
    rolledUpPicklistValues.sort();
    return String.join( rolledUpPicklistValues, ';' );
}

/*******
* Method Name : formatAndPopulateMultiPicklist
* return type : void
* created by  : Onyx Team, Sathish , on 10/13/2021, for OPID Restructure Design & Implementation.
* Description :This method is to roll the Multi-Picklist values - Part of OPID restructure
********/
public static String formatAndPopulateMultiPicklist(String mainString,String addedValue){
    if(addedValue=='Service Provider'){
           addedValue='Cloud & Comms Service Provider';
        }
    if(addedValue==null){
        return mainString;
    }
    if(mainString == ''){
        return mainString+addedValue;
    }
    List<String> stringValues = mainString.split(';');
    if(!stringValues.contains(addedValue)) { 
        stringValues.add(addedValue);                
        return String.join(stringValues,';');
    } else{ 
        return mainString;
    }
   
}

/*******
* Method Name : formatAndPopulateMultiPicklistForProgramMembership
* return type : void
* created by  : Onyx Team, Sathish , on 10/13/2021, for OPID Restructure Design & Implementation.
* Description :This method is to roll the Multi-Picklist values for ProgramMembership - Part of OPID restructure
********/
public static String formatAndPopulateMultiPicklistForProgramMembership(String mainProgramMembership,String addedProgram){
    Map<String,Integer> tierAndRankMap = new Map<String,Integer>{'Member' => 1, 'Gold' => 2, 'Titanium' => 3,'Partner' => 4, 'Prestige' => 5};
    if(!addedProgram.contains('-')){
        return mainProgramMembership;
    }
    if(mainProgramMembership == ''){
        return mainProgramMembership+addedProgram;
    }
    
    if(!mainProgramMembership.contains(addedProgram)) { 
        Map<String,String> mapPartnerRoleToTier = new Map<String,String>();
        Map<String,String> mapPartnerRoleToPartnerRoleTier = new Map<String,String>();
        for(String prgMembership : mainProgramMembership.split(';')){
            List<String> programDetails = prgMembership.split(' - ');
            if(programDetails!=null && programDetails.size()==2){
                mapPartnerRoleToTier.put(programDetails[0],programDetails[1]);
                mapPartnerRoleToPartnerRoleTier.put(programDetails[0],prgMembership);
                //System.debug('mapPartnerRoleToTier:'+mapPartnerRoleToTier);
            }
        }
        List<String> addedProgramDetails = addedProgram.split(' - ');
        if(addedProgramDetails!=null && addedProgramDetails.size()==2&&mapPartnerRoleToTier.containsKey(addedProgramDetails[0])&&!addedProgramDetails[0].contains('Distributor')&& !addedProgramDetails[0].contains('Solution Provider')) {
            if(tierAndRankMap.get(mapPartnerRoleToTier.get(addedProgramDetails[0]))<tierAndRankMap.get(addedProgramDetails[1])){
                mainProgramMembership =mainProgramMembership.replace(mapPartnerRoleToPartnerRoleTier.get(addedProgramDetails[0]),addedProgram);
            }
            return mainProgramMembership;

        }else{        
            return mainProgramMembership += ';'  + addedProgram;
        }
    } else{
        return mainProgramMembership;
    }
    }

/*******
* Method Name : getProgramMembership
* return type : void
* created by  : Onyx Team, Sathish , on 10/13/2021, for OPID Restructure Design & Implementation.
* Description :This method is to get the program membership String for the given ACM - Part of OPID restructure
********/
public static String getProgramMembership(PRM_AccountChannelMembership__c eng){
    String bizorgtype = '';
    String progMembership = ''; 
   /* if(eng.PRM_Account_Id__r.Core_Account_Type__c!=null){
        bizorgtype = filterDistiBizOrgs(eng.PRM_Account_Id__r.Core_Account_Type__c);                                
    }*/
   /* if(eng.PRM_Partner_Role__c == 'Distributor'){
        if(bizorgtype.split('\\;').size() > 1){
            for(String biz : bizorgtype.split('\\;')){
                progMembership += 'Distributor' + ' - ' + biz + ';';
            }
            if(progMembership.endsWith(';')) {
                progMembership = progMembership.substring(0, progMembership.length() - 1);
            }
        }
        else if(String.isEmpty(bizorgtype) && eng.PRM_Account_Id__r.Core_Account_Type__c!=null){
            progMembership = eng.PRM_Account_Id__r.Core_Account_Type__c.contains('Distributor') ? 'Distributor':'';
        }
        else{ 
            progMembership = 'Distributor' + ' - ' + bizorgtype;
        }
    }    */                      
   // else{
    if(string.isNotBlank(eng.PRM_Partner_Role__c)){
        //progMembership =  eng.PRM_Partner_Role__c + ' - ' + eng.PRM_Channel_Program_Level_Id__r.Name;
         progMembership = eng.PRM_Partner_Role__c == 'Service Provider'? 'Cloud & Comms Service Provider' + ' - ' + eng.PRM_Channel_Program_Level_Id__r.Name:eng.PRM_Partner_Role__c + ' - ' + eng.PRM_Channel_Program_Level_Id__r.Name;

  
        if(eng.PRM_Account_Id__r.Core_Account_Type__c !=null){
            if(eng.PRM_Partner_Role__c == 'Solution Provider' && eng.PRM_Account_Id__r.Core_Account_Type__c.contains('IoT Solution Aggregator')){
                progMembership =  eng.PRM_Partner_Role__c + ' - ' + 'IoT Solution Aggregator';
            }
        }
    
    }
     return progMembership;
}
    

/*******
* Method Name : onAccountMpiRelationStatusChange
* return type : void
* created by  : Onyx Team, Sathish , on 10/13/2021, for OPID Restructure Design & Implementation.
* Description :This method is to act based on relationship status (Active/Inactive) change b/w MPI and account - Part of OPID restructure
********/

public static void onAccountMpiRelationStatusChange(Map<Id,PMP_OPID_MPI_Rel__c> newMap,Map<Id,PMP_OPID_MPI_Rel__c> oldMap,Boolean handleBenefits){
    List<PMP_OPID_MPI_Rel__c> listActiveRecords = new List<PMP_OPID_MPI_Rel__c>();
    List<PMP_OPID_MPI_Rel__c> listInactiveRecords = new List<PMP_OPID_MPI_Rel__c>();
    Set<Id> tierUpdateMpiIds = new Set<Id>();
    List<PMP_OPID_MPI_Rel__c> statusChangedRecords = new List<PMP_OPID_MPI_Rel__c>();
    //Set<Id> statusChangedMpis = new Set<Id>();

    for(PMP_OPID_MPI_Rel__c relationRecord:newMap.values()){
            if(oldMap == null || oldMap.get(relationRecord.Id) == null || relationRecord.Is_Active__c !=oldMap.get(relationRecord.Id).Is_Active__c){
                statusChangedRecords.add(relationRecord);
                if(relationRecord.Is_Active__c == true){
                    listActiveRecords.add(relationRecord);   
                }else{
                    listInactiveRecords.add(relationRecord);
                }
                tierUpdateMpiIds.add(relationRecord.PMP_Marketing_Profile_Id__c);
            }
    }
    

    
    List<PMP_OPID_MPI_Rel__c> junctionObjects = PMP_Utility.getJunctionAccountToMpiByCompanyId(tierUpdateMpiIds);
    Map<Id,Set<Id>> mapMpiToAccountListActive = PMP_Utility.getMapMpiToListAccountActive(junctionObjects);
    Map<Id,PMP_Company__c> mapMpi = new Map<Id,PMP_Company__c>();
    Map<Id,Id> mapAccountToJunctionRecordIds = new Map<Id,Id>();
    List<PMP_Company__c> listMpi = [select Id,PMP_Benefit_Update_Ind__c,PMP_Partner_Benefit_Type__c,PMP_Working_Copy_Id__c from PMP_Company__c where id in:tierUpdateMpiIds];
    
    
     // populate PMP_Opid_Sfid_Txt__c on PMP_Company__c Object
    for(PMP_Company__c company : listMpi){
        List<Id> listAccounts = new List<Id>();
        if(mapMpiToAccountListActive.containsKey(company.id)){
        Set<Id> accounts = mapMpiToAccountListActive.get(company.id);   
        listAccounts.addAll(accounts);
        }
        company.PMP_Opid_Sfid_Txt__c = String.join(listAccounts,';');
        if(company.PMP_Working_Copy_Id__c!=null){
            PMP_Company__c workingCopyCompany = new PMP_Company__c();
            workingCopyCompany.Id = company.PMP_Working_Copy_Id__c;
            workingCopyCompany.PMP_Opid_Sfid_Txt__c = company.PMP_Opid_Sfid_Txt__c;
            mapMpi.put(workingCopyCompany.Id,workingCopyCompany);
        }
        mapMpi.put(company.id,company);
    }

   


     // variable to hold all the accounts to get all the related benefits 
    Set<Id> accountIds = new Set<Id>();
    //Set<Id> autoBenefitAccountIds = new Set<Id>();
    for(PMP_OPID_MPI_Rel__c record:newMap.values()){
        accountIds.add(record.PMP_One_Partner_ID__c);
    }
//IPA 2.0 simplification TWC729-8060  
    List<String> listBenefitCodes =new List<string>{PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE};

    Map<Id,PRM_AccountBenefitAssociation__c> mapAccountToBenefit = new Map<Id,PRM_AccountBenefitAssociation__c>();
    
    List<PRM_AccountBenefitAssociation__c> listActiveBenefits = [Select Id,PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Account_Id__c,PRM_Status_Nm__c from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in:accountIds and PRM_Status_Nm__c='Active' and PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c in:listBenefitCodes];

    for(PRM_AccountBenefitAssociation__c accountBenefit : listActiveBenefits){
        mapAccountToBenefit.put(accountBenefit.PRM_Account_Id__c,accountBenefit);
    }

   
    
    if(!listActiveRecords.isEmpty()){
        
       // variable to store map of account to updated benefit type values
       Map<Id,String> mapAccountToUpdatedBenefitType = new Map<Id,String>();

       for(PMP_OPID_MPI_Rel__c activeRelationRecord : listActiveRecords){
           PMP_Company__c company = mapMpi.get(activeRelationRecord.PMP_Marketing_Profile_Id__c);
           if(company.PMP_Benefit_Update_Ind__c == true){
               
               //system.debug('mapAccountToBenefit:'+ mapAccountToBenefit);

                    company.PMP_Benefit_Update_Ind__c = false;
                 //   company.PMP_Partner_Benefit_Type__c = mapAccountToBenefit.get(activeRelationRecord.PMP_One_Partner_ID__c).PRM_Partner_Benefit_Id__r.Name;
                    mapAccountToUpdatedBenefitType.put(activeRelationRecord.PMP_One_Partner_ID__c,company.PMP_Partner_Benefit_Type__c);
                    mapAccountToJunctionRecordIds.put(activeRelationRecord.PMP_One_Partner_ID__c,company.Id);
                    mapMpi.put(company.Id,company);
                    
                    if(company.PMP_Working_Copy_Id__c!=null){
                        PMP_Company__c workingCopy =  mapMpi.get(company.PMP_Working_Copy_Id__c);
                        workingCopy.Id = company.PMP_Working_Copy_Id__c;
                        workingCopy.PMP_Benefit_Update_Ind__c = false;
                        // workingCopy.PMP_Partner_Benefit_Type__c = mapAccountToBenefit.get(activeRelationRecord.PMP_One_Partner_ID__c).PRM_Partner_Benefit_Id__r.Name;
                        mapMpi.put(workingCopy.Id,workingCopy);
                    }
            }else{
                mapAccountToUpdatedBenefitType.put(activeRelationRecord.PMP_One_Partner_ID__c,mapMpi.get(activeRelationRecord.PMP_Marketing_Profile_Id__c).PMP_Partner_Benefit_Type__c);
                mapAccountToJunctionRecordIds.put(activeRelationRecord.PMP_One_Partner_ID__c,activeRelationRecord.PMP_Marketing_Profile_Id__c);

            }
       }

       if(!mapAccountToUpdatedBenefitType.isEmpty()&&handleBenefits){
           assignAutoBenefits(mapAccountToUpdatedBenefitType,mapAccountToJunctionRecordIds,newMap);
       }

    }

    Set<Id> tierAccountIds = new Set<Id>();

    Set<Id> inactivatedBenefitaccountIds = new Set<Id>();

    if(!listInactiveRecords.isEmpty()){
        for(PMP_OPID_MPI_Rel__c relationRecord:listInactiveRecords){
            PMP_Company__c company = mapMpi.get(relationRecord.PMP_Marketing_Profile_Id__c);
            //System.debug('mapAccountlist:'+mapMpiToAccountListActive);
            inactivatedBenefitaccountIds.add(relationRecord.PMP_One_Partner_ID__c);
            if( mapMpiToAccountListActive.isEmpty()|| !mapMpiToAccountListActive.containsKey(relationRecord.PMP_Marketing_Profile_Id__c) || mapMpiToAccountListActive.get(relationRecord.PMP_Marketing_Profile_Id__c).size()==0){
                
                if(company.PMP_Benefit_Update_Ind__c == false){
                    company.PMP_Benefit_Update_Ind__c=True;
                    if(company.PMP_Working_Copy_Id__c!=null){
                        PMP_Company__c workingCopy = new PMP_company__c();
                        workingCopy.Id = company.PMP_Working_Copy_Id__c;
                        workingCopy.PMP_Benefit_Update_Ind__c = True;
                        mapMpi.put(workingCopy.Id,workingCopy);
                    } 
                    mapMpi.put(company.Id,company);
                }
            }
        }
    }  

    //Set<Id> inactivatedBenefitIds = new Set<Id>();
    List<PRM_AccountBenefitAssociation__c> listInactivateBenefits = new List<PRM_AccountBenefitAssociation__c>();
    for(Id accountId: inactivatedBenefitaccountIds){
        //system.debug('accountMap:'+mapAccountToBenefit);
        //system.debug('accountToBenefit:'+mapAccountToBenefit.get(accountId));
        if(mapAccountToBenefit.get(accountId)!=null){
            PRM_AccountBenefitAssociation__c accBen = mapAccountToBenefit.get(accountId);
            if(accBen.PRM_Status_Nm__c=='Active'){
                accBen.PRM_Status_Nm__c = 'Inactive';
                accBen.PRM_Status_Reason_Txt__c = System.Label.PMP_DeactivateBenefit_StatusReason;
                listInactivateBenefits.add(accBen);    
            }
        }
    }

    PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits = true;
    if(Schema.sObjectType.PRM_AccountBenefitAssociation__c.isUpdateable() && !listInactivateBenefits.isEmpty()&&handleBenefits){
        update listInactivateBenefits;
    }
    PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits = false;    
    if(Schema.sObjectType.PMP_Company__c.isUpdateable() && !mapMpi.values().isempty()){
        
        //The below static constant added by Krishna Ch for 101 SOQL issue.
        Map<String,Core_Trigger_Executions__c> companyTriggerFlagMap = Core_Trigger_Executions__c.getAll();
        if(companyTriggerFlagMap.containsKey('Sync_Published_Copy') && 
           !companyTriggerFlagMap.get('Sync_Published_Copy').Core_Active__c){ 
               PMP_StaticConstants_Partner.isCompanyAfterUpdateTriggerActive = False;
           }

        update mapMpi.values();
        
    }

    for(Id mpiId: mapMpiToAccountListActive.keySet()){
        tierAccountIds.addAll(mapMpiToAccountListActive.get(mpiId));
    }
    
    updateTierOnMPI(tierAccountIds);
    
}

    public static String filterDistiBizOrgs(String accountBizType){
        String bizorgtype = '';
        for(String biz : accountBizType.split('\\;')){
            if(PMP_StaticConstants_Partner.bizOrgTypes.contains(biz)){
                bizorgtype += biz + ';';
            }
        }
        if(bizorgtype.endsWith(';')) {
            bizorgtype = bizorgtype.substring(0, bizorgtype.length() - 1);
        }
        return bizorgtype;
    }
    
    public static void InsertCompanyAttributeMappingRecords(List<PMP_Company__c> newPartners){

        List<PMP_Partner_Specialty__c> specList = [select id, Name from PMP_Partner_Specialty__c where PMP_Is_Active_Ind__c = true];
        List<PMP_Partner_Segment__c> segList = [select id, Name from PMP_Partner_Segment__c where PMP_Is_Active_Ind__c = true];
        List<PMP_Partner_Tier__c> tierList = [select id,Name from PMP_Partner_Tier__c where name != null ];
        List<PMP_Partner_Program__c> roleList = [select id, Name from PMP_Partner_Program__c where PMP_Is_Active_Ind__c = true ];
        
        Map<String, String> specIdMap = new Map<String,String>();
        Map<String, String> segIdMap = new Map<String,String>();
        Map<String, String> tierIdMap = new Map<String,String>();
        Map<String, String> roleIdMap = new Map<String,String>();
        
        for(PMP_Partner_Specialty__c spec: specList){
            specIdMap.put(spec.Name,spec.Id);
        }
        for(PMP_Partner_Segment__c seg : segList){
            segIdMap.put(seg.Name, seg.Id);
        }
        for(PMP_Partner_Tier__c tier : tierList){
            tierIdMap.put(tier.Name, tier.Id);
        }
        for(PMP_Partner_Program__c role : roleList){
            roleIdMap.put(role.Name, role.Id);
        }
        
        List<PMP_Marketing_Profile_Attributes_Mapping__c> mappingsToInsert = new List<PMP_Marketing_Profile_Attributes_Mapping__c >();
        //createMappingRecord(String partnerId, String specId, String segId, String tierId, String roleId
        
        for(PMP_Company__c partner : newPartners){
            if(partner.PMP_Account_Specialty__c != null){
                for(String spec : partner.PMP_Account_Specialty__c.split(';')){
                    if(specIdMap.containsKey(spec)){
                        mappingsToInsert.add(createMappingRecord(partner.Id, specIdMap.get(spec), null,null,null));    
                    }
                    
                }
            }
            if(partner.PMP_Partner_Segment_Nm__c !=null){
                for(String seg : partner.PMP_Partner_Segment_Nm__c.split(';')){
                    if(segIdMap.containsKey(seg)){
                    mappingsToInsert.add(createMappingRecord(partner.Id,null,segIdMap.get(seg),null,null));
                }
                }
            }
            if(partner.PMP_Partner_Program_nm__c !=null){
                for(String role : partner.PMP_Partner_Program_nm__c.split(';')){
                    if(roleIdMap.containsKey(role)){
                        mappingsToInsert.add(createMappingRecord(partner.Id, null,null,null,roleIdMap.get(role)));
                    }
                }
            }
            if(partner.PMP_IPA_Badge_Tier_Txt__c !=null){
                mappingsToInsert.add(createMappingRecord(partner.Id, null,null,tierIdMap.get(partner.PMP_IPA_Badge_Tier_Txt__c),null));
            }
            
        }
        
        if(mappingsToInsert.size() > 0){
            insert mappingsToInsert; 
        }
    }



    
    public static PMP_Marketing_Profile_Attributes_Mapping__c createMappingRecord(String partnerId, String specId, String segId, String tierId, String roleId){
        PMP_Marketing_Profile_Attributes_Mapping__c newAttribute = new PMP_Marketing_Profile_Attributes_Mapping__c();
        newAttribute.PMP_Marketing_Profile_Id__c = partnerId;
        newAttribute.PMP_Partner_Specialty__c = (specId!=null)?specId:null;
        newAttribute.PMP_Partner_Segment__c = (segId!=null)?segId:null;
        newAttribute.PMP_Partner_Tier__c = (tierId!=null)?tierId:null;
        newAttribute.PMP_Partner_Role__c = (roleId!=null)?roleId:null;
        return newAttribute;
    }
    
    public static String calculateIpaBadgeTier(List<PRM_AccountChannelMembership__c> acmList){
        //Map<String,Integer> tierAndRankMap = new Map<String,Integer>{'Member' => 1, 'Gold' => 2, 'Titanium' => 3};
        //Map<Integer,String> rankAndTierMap = new Map<Integer,String>{1 => 'Member', 2 => 'Gold', 3 => 'Titanium'}; 
		Map<String,Integer> tierAndRankMap = new Map<String,Integer>{'Member' => 1, 'Gold' => 2, 'Titanium' => 3, 'Partner' => 4, 'Prestige' => 5};
            Map<Integer,String> rankAndTierMap = new Map<Integer,String>{1 => 'Member', 2 => 'Gold', 3 => 'Titanium', 4 => 'Partner', 5 => 'Prestige'};       
                
                Integer highestTierRank = 0;
        
        for(PRM_AccountChannelMembership__c acm : acmList){
            if(tierAndRankMap.get(acm.PRM_Channel_Program_Level_Id__r.Name) > highestTierRank){
                highestTierRank = tierAndRankMap.get(acm.PRM_Channel_Program_Level_Id__r.Name); 
            }
        }
        
        return rankAndTierMap.get(highestTierRank);
    }
    
    //Create Partner working copy-to remove the async exception as old method to create working copy was a queuable method
    public static void createPartnerWorkingCopyRecord(List<PMP_Company__c> newcompanies){
        
        List<PMP_Company__c> createworkcopies = new List<PMP_Company__c>();
        List<PMP_Company__c> updatepublished = new List<PMP_Company__c>();   
        for(PMP_Company__c partner : newcompanies){
            PMP_Company__c partner_wc                           = new PMP_Company__c();
            partner_wc.Name                                     = partner.Name;
           // partner_wc.PMP_Account_Id__c                          = partner.PMP_Account_Id__c;
            partner_wc.PMP_Company_Lifecycle_Status_Nm__c       = PMP_StaticConstants_Partner.Draft;            
            partner_wc.PMP_Account_Website__c                   = partner.PMP_Account_Website__c;
            partner_wc.PMP_Account_Program_Membership__c        = partner.PMP_Account_Program_Membership__c;
            partner_wc.PMP_Partner_Program_nm__c                = partner.PMP_Partner_Program_nm__c;                
            partner_wc.PMP_Account_Specialty__c                 = partner.PMP_Account_Specialty__c;     
            partner_wc.PMP_Is_Published_Ind__c                  = false;                        
            partner_wc.PMP_Is_Working_Copy_Ind__c               = true;            
            partner_wc.PMP_Company_Status_Update_Dt__c          = Date.today();
            partner_wc.PMP_Published_Copy_Id__c                 = partner.Id;
            partner_wc.PMP_Opid_Sfid_Txt__c                         = partner.PMP_Opid_Sfid_Txt__c;
          //  partner_wc.PMP_One_Partner_ID__c                  = partner.PMP_One_Partner_ID__c;
            partner_wc.PMP_Partner_Benefit_Type__c              = partner.PMP_Partner_Benefit_Type__c;
            partner_wc.PMP_IPA_Badge_Tier_Txt__c                = partner.PMP_IPA_Badge_Tier_Txt__c;
            partner_wc.PMP_Partner_Segment_Nm__c                = partner.PMP_Partner_Segment_Nm__c;
            partner_wc.PMP_Suppress_Email_Ind__c                    = partner.PMP_Suppress_Email_Ind__c;
            createworkcopies.add(partner_wc);    
        }

        if(!createworkcopies.isEmpty()){
            Insert(createworkcopies);
            
            //Set<Id> partnerIdsCreated = new Set<Id>();
            for(PMP_Company__c wc : createworkcopies) {
                PMP_Company__c pc = new PMP_Company__c();
                pc.Id = wc.PMP_Published_Copy_Id__c;
                pc.PMP_Working_Copy_Id__c = wc.Id;
                updatepublished.add(pc);
            }
            if(!updatepublished.isEmpty()){
                update(updatepublished);
            }                    
        }
    }
	//IPA: Benefit chnages
    //Added by Krishna Ch DE111313 : to check the existing basic access partner is available or not, if available need to update existing partner.
    /*public static Set<Id> checkIfExistingBasicAccessPartner(Set<Id> accountIds){
        Set<Id> accountIdsWithNoMPI = new Set<Id>();
        Set<Id> existingAccountIds = new Set<Id>();
        List<PMP_Company__c>  partnerListWithBasicAccess = new List<PMP_Company__c>();
        Map<Id,Set<Id>> mapMpiToAccountListActive;
        String benefitType =PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access;
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){
            // Added as part of OPID Restructure
            List<PMP_OPID_MPI_Rel__c> junctionObjects = PMP_Utility.getJunctionAccountToMpiByAccountId(accountIds);
            Set<Id> existingPartnerIds = PMP_Utility.getAllMpiIds(junctionObjects);
            mapMpiToAccountListActive = PMP_Utility.getMapMpiToListAccountActive(junctionObjects);
            partnerListWithBasicAccess = [SELECT id,PMP_Benefit_Update_Ind__c,PMP_Is_Working_Copy_Ind__c,PMP_Published_Copy_Id__c from PMP_Company__c
                           where Id IN:existingPartnerIds  and
                           (PMP_Partner_Benefit_Type__c =: benefitType)
                           AND ((PMP_Is_Published_Ind__c =true and PMP_Benefit_Update_Ind__c=true) )];
        }

        Map<Id,Account> mapAccount = new Map<Id,Account>();
        if(!partnerListWithBasicAccess.isEmpty()){
            List<Account> accountList = [Select id,Core_IPA_Badge_Tier__c,Core_Account_Type__c,Core_IPA_Partner_Segment__c                                                 
            FROM Account where id IN: accountIds];
            for(Account acc:accountList){
                mapAccount.put(acc.Id,acc);
            }
        }
        
        for(PMP_Company__c partner : partnerListWithBasicAccess){
            if(!mapMpiToAccountListActive.get(partner.id).isEmpty()){
                // add all the accounts who already have basic Access MPI
                for(Id accountId: mapMpiToAccountListActive.get(partner.id)){
                    existingAccountIds.add(accountId);
                }
            }
           
             partner.PMP_Benefit_Update_Ind__c = false;

          
            for(Id accountId : mapMpiToAccountListActive.get(partner.id)){
                if(mapAccount.get(accountId)!=null){
                        partner.PMP_Partner_Segment_Nm__c = mapAccount.get(accountId).Core_IPA_Partner_Segment__c;
                        //partner.PMP_Account_Specialty__c = mapAccount.get(accountId).Core_IPA_Partner_Speciality__c;  Commented as part of Specialty Deactivation - Divya
                }
            }   
        }
        
        for(String accId : accountIds){
            if(!existingAccountIds.contains(accId)){
                accountIdsWithNoMPI.add(accId);
            }
        }
        
        if(!partnerListWithBasicAccess.isEmpty()){
            if(Schema.sObjectType.PMP_Company__c.isUpdateable()){

           //The below static constant added by Krishna Ch for 101 SOQL issue.
            Map<String,Core_Trigger_Executions__c> companyTriggerFlagMap = Core_Trigger_Executions__c.getAll();
            if(companyTriggerFlagMap.containsKey('Sync_Published_Copy') && 
               !companyTriggerFlagMap.get('Sync_Published_Copy').Core_Active__c){ 
                   PMP_StaticConstants_Partner.isCompanyAfterUpdateTriggerActive = False;
               }

                update partnerListWithBasicAccess;
            }
        }
        
        return accountIdsWithNoMPI;
        
    }*/
//IPA 2.0 TWC729-8060
/********
* Method Name : validateForAutoAssignBenefits
* return type : void
* created by  : Onyx Team, Sathish , on 10/11/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to auto assign benefits when benefit is changed at MPI level - Part of OPID restructure
********/ 
/*public static void validateForAutoAssignBenefits(Map<id,PMP_Company__c> newMapMpi,Map<id,PMP_Company__c> oldMapMpi){
    
    Set<Id> setNonExistingWorkingCopyIds = new Set<Id>();
    for(PMP_Company__c company : newMapMpi.values()){
        if(company.PMP_Partner_Benefit_Type__c!=null &&!company.PMP_Partner_Benefit_Type__c.equals(oldMapMpi.get(company.id).PMP_Partner_Benefit_Type__c)){
            if(company.PMP_Partner_Benefit_Type__c.equals(PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access)){
                company.addError(System.Label.PMP_BasicAccess_Error);
            }else if(oldMapMpi.get(company.id).PMP_Partner_Benefit_Type__c!=null &&oldMapMpi.get(company.id).PMP_Partner_Benefit_Type__c.equals(PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access)){
                company.addError(System.Label.PMP_BasicToOtherBenefit_Error);
            }

            if(company.PMP_Is_Published_Ind__c){
                if(newMapMpi.containsKey(company.PMP_Working_Copy_Id__c)){
                    PMP_Company__c workingCopy = newMapMpi.get(company.PMP_Working_Copy_Id__c);
                    if(workingCopy.PMP_Partner_Benefit_Type__c != company.PMP_Partner_Benefit_Type__c){
                        company.addError(System.Label.PMP_WorkingCopyBenefit_Error);
                    }
                }else{
                    setNonExistingWorkingCopyIds.add(company.PMP_Working_Copy_Id__c);
                }
            }
        }
   }

   if(setNonExistingWorkingCopyIds.isEmpty()){
        return;
   }

   List<PMP_Company__c> listNonExistingWorkingCopy = [select id,PMP_Partner_Benefit_Type__c,PMP_Published_Copy_Id__c from PMP_Company__c where id in:setNonExistingWorkingCopyIds];
   for(PMP_Company__c workingCopy : listNonExistingWorkingCopy){
       PMP_Company__c publishedCopy = newMapMpi.get(workingCopy.PMP_Published_Copy_Id__c);
       if(publishedCopy.PMP_Partner_Benefit_Type__c!=workingCopy.PMP_Partner_Benefit_Type__c){
            publishedCopy.addError(System.Label.PMP_WorkingCopyBenefit_Error);
       }
   }
        
}   */
/********
* Method Name : autoAssignBenefitsOnMpiBenefitChange
* return type : void
* created by  : Onyx Team, Sathish , on 10/11/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to auto assign benefits when benefit is changed at MPI level - Part of OPID restructure
********/
//IPA 2.0 simplification TWC729-8060  
 /*   public static void autoAssignBenefitsOnMpiBenefitChange(Map<id,PMP_Company__c> newMapMpi,Map<id,PMP_Company__c> oldMapMpi){
        
        // variable to store list of Mpi Id's whose benefit type has changed
        Set<Id> listMpiChangeBenefitType = new Set<Id>();
        
        Map<Id,Id> mapErrorAccountToMpiRecordIds = new Map<Id,Id>();

        List<PMP_Company__c> listUpdateCompany = new List<PMP_Company__c>();

        // logic to list MPI for which benefit type is changed
        for(PMP_Company__c company : newMapMpi.values()){
                    if(company.PMP_Partner_Benefit_Type__c!=null && !company.PMP_Partner_Benefit_Type__c.equals(oldMapMpi.get(company.id).PMP_Partner_Benefit_Type__c)){
                        // assign benefits to Accounts only when MPI is Published
                        if(company.PMP_Is_Published_Ind__c){
                            listMpiChangeBenefitType.add(company.id); 

                        }else{ 
                            // update the published Copy
                            if(newMapMpi.containsKey(company.PMP_Published_Copy_Id__c)){
                                PMP_Company__c publishedCopy = newMapMpi.get(company.PMP_Published_Copy_Id__c);
                                if(publishedCopy.PMP_Partner_Benefit_Type__c != company.PMP_Partner_Benefit_Type__c){
                                    publishedCopy.PMP_Partner_Benefit_Type__c = company.PMP_Partner_Benefit_Type__c;
                                    publishedCopy.PMP_Suppress_Email_Ind__c=company.PMP_Suppress_Email_Ind__c;
                                    listUpdateCompany.add(publishedCopy);
                                }
                            }else{
                                PMP_Company__c publishedCopycompany = new PMP_Company__c();
                                publishedCopycompany.Id = company.PMP_Published_Copy_Id__c;
                                publishedCopycompany.PMP_Partner_Benefit_Type__c = company.PMP_Partner_Benefit_Type__c;
                                publishedCopycompany.PMP_Suppress_Email_Ind__c=company.PMP_Suppress_Email_Ind__c;
                                listUpdateCompany.add(publishedCopycompany);
                            }
                            
                        }
                }
            
        }

       

        // Update the company records
        if(Schema.sObjectType.PMP_Company__c.isUpdateable() && !listUpdateCompany.isempty()){
        
            //The below static constant added by Krishna Ch for 101 SOQL issue.
            Map<String,Core_Trigger_Executions__c> companyTriggerFlagMap = Core_Trigger_Executions__c.getAll();
            if(companyTriggerFlagMap.containsKey('Sync_Published_Copy') && 
               !companyTriggerFlagMap.get('Sync_Published_Copy').Core_Active__c){ 
                   PMP_StaticConstants_Partner.isCompanyAfterUpdateTriggerActive = False;
               }
            
            try{
                update listUpdateCompany;
            }catch(DmlException e){
                //System.debug(e);
               if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                    PMP_Utility.logError(e, 'PMP_AccountBenefitPartnerUtility');
                    for(Id companyId : newMapMpi.keyset()){
                        newMapMpi.get(companyId).addError(e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').substringBefore(':'));
                    }
                }else{
                    throw e;
                }
            }
            
        }

         // Execute the auto assignment logic only when there are any changes in the benefit type of MPI
         if(listMpiChangeBenefitType.size()<1){
            return;
        }
        

        // variable to store map of account to updated benefit type values
            Map<Id,String> mapAccountToUpdatedBenefitType = new Map<Id,String>();

            // get the map of all mpi related accounts whose benefit is changed
            List<PMP_OPID_MPI_Rel__c> junctionObjects = PMP_Utility.getJunctionAccountToMpiByCompanyId(listMpiChangeBenefitType);
            Map<Id,Set<Id>> mapMpiToListAccountActive = PMP_Utility.getMapMpiToListAccountActive(junctionObjects);

            if(mapMpiToListAccountActive == null ||mapMpiToListAccountActive.keySet().isEmpty()){
                return;
            }

            // get the map of accounts and related benefits which are to be automatically assigned
            for(Id companyId : listMpiChangeBenefitType){
                for(Id accountId : mapMpiToListAccountActive.get(companyId)){
                  
                    mapAccountToUpdatedBenefitType.put(accountId,newMapMpi.get(companyId).PMP_Partner_Benefit_Type__c );
                    mapErrorAccountToMpiRecordIds.put(accountId,companyId);
                }
            }

            // if No accounts related to the updated benefit type - return as we cannot assign benefits without accounts
            if(mapAccountToUpdatedBenefitType.isEmpty()){
                return;
            }


            
           assignAutoBenefits(mapAccountToUpdatedBenefitType,mapErrorAccountToMpiRecordIds,newMapMpi);
           

        
    }*/

/********
* Method Name : assignAutoBenefits
* return type : void
* created by  : Onyx Team, Sathish , on 10/11/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to auto assign benefits when benefit is changed at MPI level - Part of OPID restructure
********/

public static void assignAutoBenefits( Map<Id,String> mapAccountToUpdatedBenefitType,Map<Id,Id> mapErrorRecordIds, Map<Id,SObject> errorRecords){
    /*
                BNFTSMBA - Basic Access Benefit
                BFTMKTPLBC - Basic Profile Benefit
                BFTMKTPLED - Enhanced Benefit
    */
    //IPA 2.0 simplification TWC729-8060  
     // get the Benefit record Id map using the benefit code for assigning to the lookup field
     List<String> listBenefitCodes =new List<string>{PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE};
     Map<String,String> mapBenefitCodeToBenefitId = getMapBenefitCodesToId(listBenefitCodes);
     Map<Id,List<PRM_AccountBenefitAssociation__c>> mapAccountToBenefitObjects ;



     Map<Id,PRM_AccountBenefitAssociation__c> mapActivateAlreadyExistingAccBen = new Map<Id,PRM_AccountBenefitAssociation__c>();
     Map<Id,PRM_AccountBenefitAssociation__c> mapDeactivateAlreadyExistingAccBen = new Map<Id,PRM_AccountBenefitAssociation__c>();
     Map<Id,PRM_AccountBenefitAssociation__c> mapInsertNonExistingAccBen = new Map<Id,PRM_AccountBenefitAssociation__c>();
     Map<Id,PRM_AccountBenefitAssociation__c> mapInsertNonExistingAccBenNoBenefitsScenario = new Map<Id,PRM_AccountBenefitAssociation__c>();
     Map<Id,PRM_AccountBenefitAssociation__c> mapInsertNonExistingBasicProflieBenefitInEnhancedBenefitScenario = new Map<Id,PRM_AccountBenefitAssociation__c>();

    // get Account Association Benefit Objects related to the accounts which are to be changed
    mapAccountToBenefitObjects = getMapAccountToBenefitObjects(mapAccountToUpdatedBenefitType.keySet());
    

    for(Id accountId : mapAccountToUpdatedBenefitType.keyset()){
        boolean doesAlreadyBenefitExists = false;
        boolean doesAlreadyBasicProfileExists = true;
            if(mapAccountToBenefitObjects.containsKey(accountId)){
                for(PRM_AccountBenefitAssociation__c accBen: mapAccountToBenefitObjects.get(accountId)){
                    //System.debug('accBen:'+accBen.PRM_Partner_Benefit_Id__r.Name +'==? updated Benefit:'+mapAccountToUpdatedBenefitType.get(accountId));
                    
                    
                    String benefit ;
                    // This is to handle the picklist value benefit name difference b/w mpi picklist and actual benefit name
                    /*if(mapAccountToUpdatedBenefitType.get(accountId) == PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access){
                        benefit = 'Solutions Marketplace Basic Access';
                    }else{
                        benefit =  mapAccountToUpdatedBenefitType.get(accountId);
                    }*/
					if(mapAccountToUpdatedBenefitType.get(accountId) == PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile){
                        benefit = mapAccountToUpdatedBenefitType.get(accountId);
                    }
					
                    if(accBen.PRM_Partner_Benefit_Id__r.Name == benefit){
                        doesAlreadyBenefitExists = true;
                        // Check if the assigned benefit is Inactive, If So activate the benefit
                            if(accBen.PRM_Status_Nm__c=='Inactive'){
                                accBen.PRM_Status_Nm__c = 'Active';
                                accBen.PRM_Status_Reason_Txt__c = System.Label.PMP_AssignBenefit_StatusReason;
                                mapActivateAlreadyExistingAccBen.put(accountId,accBen);
                                // Logic if enhanced benefit exists but basic profile does not exists/ we need to insert
				//IPA 2.0 simplification TWC729-8060  
                               // if(accBen.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c == PMP_StaticConstants_Partner.BENEFIT_ENHANCED_CODE){
                                    boolean basicProfileExists = false;
                                    for(PRM_AccountBenefitAssociation__c accBenBasicProfile: mapAccountToBenefitObjects.get(accountId)){
                                        if(accBenBasicProfile.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c == PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE){
                                            basicProfileExists = true;
                                        }
                                    }
                                    if(!basicProfileExists){
                                        PRM_AccountBenefitAssociation__c accBenBasicProfile = new PRM_AccountBenefitAssociation__c();
                                        accBenBasicProfile.PRM_Partner_Benefit_Id__c = mapBenefitCodeToBenefitId.get(PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE);
                                        accBenBasicProfile.PRM_Account_Id__c = accountId;
                                        accBenBasicProfile.PRM_Status_Nm__c = 'Inactive';
                                        accBenBasicProfile.PRM_Status_Reason_Txt__c = System.Label.PMP_DeactivateBenefit_StatusReason;
                                        mapInsertNonExistingBasicProflieBenefitInEnhancedBenefitScenario.put(accountId,accBenBasicProfile);
                                    }
                              //  }
                            }

                            
                    
                    }else{
                        if(accBen.PRM_Status_Nm__c=='Active'){
                            accBen.PRM_Status_Nm__c = 'Inactive';
                            accBen.PRM_Status_Reason_Txt__c = System.Label.PMP_DeactivateBenefit_StatusReason;
                            mapDeactivateAlreadyExistingAccBen.put(accountId,accBen);
                        }
                    }
                }  
            } 

                // if such benefit doesn't exist on the OPID, Insert the benefit
                if(!doesAlreadyBenefitExists){

                        Id partnerBenefitId;
                        // check if Account Benefit type is Solution Marketplace Basic Access
                        String benefitType =  mapAccountToUpdatedBenefitType.get(accountId);
                        switch on (benefitType){
			//IPA 2.0 simplification TWC729-8060  
                            // when 'Solution Marketplace Basic Access'{ partnerBenefitId = mapBenefitCodeToBenefitId.get(PMP_StaticConstants_Partner.BENEFIT_BASIC_ACCESS_CODE);
                                                                    
                            //                                         }
                            when 'Solutions Marketplace Basic Profile'{ partnerBenefitId = mapBenefitCodeToBenefitId.get(PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE);
                                                                        
                                                                    }
			//IPA 2.0 simplification TWC729-8060  					    
                            // when 'Solutions Marketplace Enhanced'{ partnerBenefitId = mapBenefitCodeToBenefitId.get(PMP_StaticConstants_Partner.BENEFIT_ENHANCED_CODE);
                            //                                         // If Enhanced Benefit then check if basic profile exists else need to insert basic profile with Inactive status
                            //                                             if(!mapAccountToBenefitObjects.containsKey(accountId)){
                            //                                                 doesAlreadyBasicProfileExists = false;
                            //                                             }
                            //                                         }

                        }
                    // create benefit object if the benefit does not exist
                        PRM_AccountBenefitAssociation__c accBen = new PRM_AccountBenefitAssociation__c();
                        accBen.PRM_Partner_Benefit_Id__c = partnerBenefitId;
                        accBen.PRM_Account_Id__c = accountId;
                        accBen.PRM_Status_Nm__c = 'Active';
                        accBen.PRM_Status_Reason_Txt__c = System.Label.PMP_AssignBenefit_StatusReason;
                        mapInsertNonExistingAccBen.put(accountId,accBen);
                        if(!doesAlreadyBasicProfileExists){
                            PRM_AccountBenefitAssociation__c accBenBasicProfile = new PRM_AccountBenefitAssociation__c();
                            accBenBasicProfile.PRM_Partner_Benefit_Id__c = mapBenefitCodeToBenefitId.get(PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE);
                            accBenBasicProfile.PRM_Account_Id__c = accountId;
                            accBenBasicProfile.PRM_Status_Nm__c = 'Inactive';
                            accBenBasicProfile.PRM_Status_Reason_Txt__c = System.Label.PMP_DeactivateBenefit_StatusReason;
                                mapInsertNonExistingAccBenNoBenefitsScenario.put(accountId,accBenBasicProfile);
                        }
                }
    }
    
    

    PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits = true;
    try{
    if(!mapInsertNonExistingBasicProflieBenefitInEnhancedBenefitScenario.isEmpty()&&!Test.isRunningTest()){
        PRM_aba_TriggerHandler.mpFirstInsertRun = true; //mp logic after insert
        PRM_accBenefitAssociationUtility.firstRunBeforeInsert = true; // valdiation before insert;
        insert mapInsertNonExistingBasicProflieBenefitInEnhancedBenefitScenario.values();
    }
    
    // Insert Basic profile benefit with Inactive status if No Benefits exists on OPID
    if(!mapInsertNonExistingAccBenNoBenefitsScenario.isEmpty()&&!Test.isRunningTest()){
        PRM_aba_TriggerHandler.mpFirstInsertRun = true; // For Validations to work
        PRM_accBenefitAssociationUtility.firstRunBeforeInsert = true; // valdiation before insert;
        insert mapInsertNonExistingAccBenNoBenefitsScenario.values();
    }
     if(!mapDeactivateAlreadyExistingAccBen.isEmpty()&&!Test.isRunningTest()){
        PRM_aba_TriggerHandler.mpFirstUpdateRun = true; // after operations marketplace logic
        PRM_accBenefitAssociationUtility.firstRun = true; // after operation of benefit insert
        PRM_accBenefitAssociationUtility.firstRunBeforeUpdate = true;// For Validations to work
         update mapDeactivateAlreadyExistingAccBen.values();
     }

     // Next Activate the already Existing benefits if Inactive
     if(!mapActivateAlreadyExistingAccBen.isEmpty()&&!Test.isRunningTest()){
        PRM_aba_TriggerHandler.mpFirstUpdateRun = true;// For Validations to work
        PRM_accBenefitAssociationUtility.firstRunBeforeUpdate = true;// For Validations to work
        PRM_accBenefitAssociationUtility.firstRun = true; // after operation of benefit insert
         update mapActivateAlreadyExistingAccBen.values();
     }

     // Insert If No such benefit exists on the OPID
     if(!mapInsertNonExistingAccBen.isEmpty()&&!Test.isRunningTest()){
        PRM_aba_TriggerHandler.mpFirstInsertRun = true; // For marketplace logic to work
        PRM_accBenefitAssociationUtility.firstRunBeforeInsert = true; // valdiation before insert;
        insert mapInsertNonExistingAccBen.values();
     } 
     PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits = false;  
    }catch(DmlException e){
        //System.debug(e);
       if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            PMP_Utility.logError(e, 'PMP_AccountBenefitPartnerUtility');
            for(Id objectId : errorRecords.keySet()){
                errorRecords.get(objectId).addError(e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').substringBefore(':'));
            }
        }else{
            throw e;
        }
    }

}

/********
* Method Name : getMapAccountToBenefitObjects
* return type : Map<Id,List<PRM_AccountBenefitAssociation__c>>
* created by  : Onyx Team, Sathish , on 10/11/2021, for OPID Restructure Design & Implementation.
* Description : Below method is to get map of account to list beneftis assigned - Part of OPID restructure
********/
    public static Map<Id,List<PRM_AccountBenefitAssociation__c>> getMapAccountToBenefitObjects(Set<Id> accountIds){
       //IPA 2.0 simplification TWC729-8060  
	 List<String> listBenefitCodes =new List<string>{PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE};
        Map<Id,List<PRM_AccountBenefitAssociation__c>> mapAccountToBenefitObjects = new Map<Id,List<PRM_AccountBenefitAssociation__c>>();
        for(PRM_AccountBenefitAssociation__c accBen :           [select id,
                                                                    PRM_Account_Id__c,
                                                                    PRM_Partner_Benefit_Id__r.Name,
                                                                    PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,
                                                                    PRM_Status_Reason_Txt__c,
                                                                    PRM_Status_Nm__c,
                                                                    PRM_Partner_Benefit_Id__c
                                                                from PRM_AccountBenefitAssociation__c 
                                                                where PRM_Account_Id__c in : accountIds
                                                                and PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c in :listBenefitCodes])
                {   
                    if(!mapAccountToBenefitObjects.isEmpty() && mapAccountToBenefitObjects.containsKey(accBen.PRM_Account_Id__c)){
                        mapAccountToBenefitObjects.get(accBen.PRM_Account_Id__c).add(accBen);
                    }else{
                        List<PRM_AccountBenefitAssociation__c> benefitList = new List<PRM_AccountBenefitAssociation__c>();
                        benefitList.add(accBen);
                        mapAccountToBenefitObjects.put(accBen.PRM_Account_Id__c,benefitList);
                    }
                }
                return mapAccountToBenefitObjects;
    }


    // Not used anywhere - this method does not do anything
    public static void checkBeforeDeactivateIntelAccountBenefit(List<PRM_AccountBenefitAssociation__c> accBenefitAssociations, Map<Id,PRM_AccountBenefitAssociation__c> oldABAMap) {
        // Commented by sathish - As part of OPID Restructure - As this is unused code
       /* Id intelAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        List<PRM_AccountBenefitAssociation__c> updateABAs = new List<PRM_AccountBenefitAssociation__c>();
        Map<Id, Set<Id>> accIdAndABAIds = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> opIdAndIntelAcctIds = new Map<Id, Set<Id>>();
        Set<Id> intelAccIds = new Set<Id>();
        Set<Id> notPublishedIntelIds = new Set<Id>();
        Set<String> benefitNames = new Set<String> { PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile, PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced };
            
            if(accBenefitAssociations.size() > 0 && Schema.sObjectType.PRM_AccountBenefitAssociation__c.isAccessible()) {
                for(PRM_AccountBenefitAssociation__c aba : [SELECT Id,PRM_Account_Id__c,PRM_Status_Nm__c,PRM_Partner_Benefit_Id__r.Name 
                                                            FROM PRM_AccountBenefitAssociation__c WHERE ID IN :accBenefitAssociations]) {
                                                                PRM_AccountBenefitAssociation__c oldABA = oldABAMap.get(aba.Id);
                                                                if(aba.PRM_Account_Id__c != null
                                                                
                                                                 && aba.PRM_Status_Nm__c != oldABA.PRM_Status_Nm__c && aba.PRM_Status_Nm__c == PMP_StaticConstants_Partner.INACTIVE
                                                                   && benefitNames.contains(aba.PRM_Partner_Benefit_Id__r.Name)) {
                                                                       if(accIdAndABAIds.get(aba.PRM_Account_Id__c) == null) {
                                                                           accIdAndABAIds.put(aba.PRM_Account_Id__c, new Set<Id>());
                                                                       }
                                                                       accIdAndABAIds.get(aba.PRM_Account_Id__c).add(aba.Id);
                                                                   }
                                                            }
                if(accIdAndABAIds.size() > 0) {
                    for(Account acc : [SELECT Id,RecordTypeId FROM Account WHERE Id IN :accIdAndABAIds.keySet()]) {
                        if(acc.RecordTypeId == intelAccRecId) {
                            intelAccIds.add(acc.Id);
                        }
                    }
                    if(Schema.sObjectType.Core_Account_Group_Member__c.isAccessible()) {
                        for(Core_Account_Group_Member__c agm : [SELECT Id,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c 
                                                                FROM Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c IN :intelAccIds]) {
                                                                    if(opIdAndIntelAcctIds.get(agm.Core_Partner_Account_Id__c) == null) {
                                                                        opIdAndIntelAcctIds.put(agm.Core_Partner_Account_Id__c, new Set<Id>());
                                                                    }
                                                                    opIdAndIntelAcctIds.get(agm.Core_Partner_Account_Id__c).add(agm.Core_Intel_Account_Id__c);
                                                                }
                    }
                    
                    if(opIdAndIntelAcctIds.size() > 0 && Schema.sObjectType.PMP_Company__c.isAccessible()) {
                        for(PMP_Company__c comp : [SELECT Id, PMP_Account_Id__c, PMP_Company_Lifecycle_Status_Nm__c 
                                                   FROM PMP_Company__c WHERE PMP_Account_Id__c IN :opIdAndIntelAcctIds.keySet() AND 
                                                   PMP_Is_Published_Ind__c=TRUE]) {
                                                       if(comp.PMP_Company_Lifecycle_Status_Nm__c != PMP_StaticConstants_Partner.Published) {
                                                           notPublishedIntelIds.addAll(opIdAndIntelAcctIds.get(comp.PMP_Account_Id__c));
                                                       } 
                                                   }
                    }
                    
                    for(PRM_AccountBenefitAssociation__c aba : accBenefitAssociations) {
                        if(notPublishedIntelIds.contains(aba.PRM_Account_Id__c)) {
                            aba.PRM_Status_Nm__c = oldABAMap.get(aba.Id).PRM_Status_Nm__c;
                        }
                    }
                }
            }
            */
    }

   
}