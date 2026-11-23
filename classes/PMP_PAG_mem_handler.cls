public class PMP_PAG_mem_handler {

    final static String[] PROGRAMS = new String[]{'ISA', 'CSPx2'};
    final static String NO_TIER = 'ODM-LOEM';    
    final static String INVALID_TIER = 'UNDETERMND';
  static Id PARTNER_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
  static Id INTEL_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();    

    // Uday 6/27/2019 US377991 - Populate all the MP fields from Account to its Company Information object.
    /***************************************************************************************************** 
    *Method Name:                                              onGroupMemAfterInsert
    *@return  :                                                Void
    *Modified By:                       Date:                  Changes: 
    *Udaya Katta                      6/27/2019                Original Version
    ******************************************************************************************************/
    public static void onGroupMemAfterInsert(List<Core_Account_Group_Member__c> newList, Map<Id,Core_Account_Group_Member__c> newMap) {
        List<PMP_Company__c> newcompanies = new List<PMP_Company__c>();
        Map<Id, Id> partnerIntelAcc_Map = new Map<Id, Id>();
        Map<Id, List<Core_Account_Group_Member__c>> IntelPartnerMem_Map = new Map<Id, List<Core_Account_Group_Member__c>>();        
        Map<Id, List<PMP_Company__c>> IntelCompInfo_Map = new Map<Id, List<PMP_Company__c>>();
        Map<Id, List<Core_Account_ERPM_Engagement__c>> erpm_accounts_Map = new Map<Id, List<Core_Account_ERPM_Engagement__c>>();
        Map<Id, Account> AccDetails_Map = new Map<Id,Account>([Select Id, Name,Core_IPA_Partner_Speciality__c, Core_User_Defined_Website__c,recordTypeId,Website,Core_IPA_Partner_Role__c from Account where RecordTypeId =: INTEL_RECTYPEID AND Id IN (Select Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Id IN: newMap.KeySet() AND Core_MDA_Ind__c = true)]); //Added Parnter role for US US589301       
        List<Account> changed_partnerAccs_lst = [Select Id, Name, Core_IPA_Partner_Speciality__c, Core_User_Defined_Website__c,Core_IPA_Partner_Role__c, 
                                                 (Select Id, Core_MDA_Ind__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__c,Core_Intel_Account_Id__r.Name, Core_Intel_Account_Id__r.Website, Core_Intel_Account_Id__r.recordTypeId from Partner_Account_Group_Members1__r
                                                  Where Core_MDA_Ind__c = true ORDER BY LastModifiedDate), 
                                                 (Select Id, Name, PMP_Account_Id__c, PMP_Company_Lifecycle_Status_Nm__c, PMP_Is_Published_Ind__c  from Company_Informations__r Where PMP_Is_Published_Ind__c = true AND PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published ORDER BY LastModifiedDate DESC),
                                                 (SELECT Core_Account_Id__c, Core_ERPM_Business_Attributes__c, Core_ERPM_Engagement_Id__r.Name from Account_ERPM_Engagements__r Where Core_ERPM_Engagement_Id__r.Name =: PROGRAMS) 
                                                 from Account where RecordTypeId =: INTEL_RECTYPEID
                                                 AND Id IN (Select Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Id IN: newMap.KeySet() AND Core_MDA_Ind__c = true) ORDER BY LastModifiedDate DESC]; //Added Core_IPA_Partner_Role__c for US589301
     system.debug('PROGRAMS 44 =>'+PROGRAMS);
        system.debug('changed_partnerAccs_lst 30 =>'+changed_partnerAccs_lst);
        for(Account acc : changed_partnerAccs_lst){ 
            for(Core_Account_Group_Member__c partner_grp_mem : acc.Partner_Account_Group_Members1__r){
                if(partner_grp_mem.Core_Partner_Account_Id__c != null && partner_grp_mem.Core_Intel_Account_Id__c != null){
                    partnerIntelAcc_Map.put(partner_grp_mem.Core_Partner_Account_Id__c, partner_grp_mem.Core_Intel_Account_Id__c);
                }                
            }
            for(PMP_Company__c comp_info : acc.Company_Informations__r){
                if(IntelCompInfo_Map.containsKey(comp_info.PMP_Account_Id__c)){
                    IntelCompInfo_Map.get(comp_info.PMP_Account_Id__c).add(comp_info);
                } else {
                    IntelCompInfo_Map.put(comp_info.PMP_Account_Id__c, new List<PMP_Company__c>{comp_info});
                }  
            }
            system.debug('Account_ERPM_Engagements__r 43 =>'+acc.Account_ERPM_Engagements__r);
            system.debug('PROGRAMS 44 =>'+PROGRAMS);
            for(Core_Account_ERPM_Engagement__c erpm_acc : acc.Account_ERPM_Engagements__r){
                if(erpm_accounts_Map.containsKey(erpm_acc.Core_Account_Id__c)){
                    erpm_accounts_Map.get(erpm_acc.Core_Account_Id__c).add(erpm_acc);
                }else{
                    erpm_accounts_Map.put(erpm_acc.Core_Account_Id__c, new List<Core_Account_ERPM_Engagement__c>{erpm_acc});
                }
            }
        } 
        
        for(Core_Account_Group_Member__c grp_mem : newList){
            Account acc = AccDetails_Map.get(grp_mem.Core_Intel_Account_Id__c);
            PMP_Company__c company_existing;
            String partner_program = '';
            String program_membership = ''; 
            system.debug('acc 56 =>'+acc);
            Core_Account_Group_Member__c new_gm = newMap.get(grp_mem.Id);
            system.debug('new_gm 58 =>'+new_gm);
            system.debug('erpm_accounts_Map =>'+erpm_accounts_Map);
            if(erpm_accounts_Map.containsKey(new_gm.Core_Intel_Account_Id__c)){
                system.debug('containsKey 61 =>');
                for( Core_Account_ERPM_Engagement__c eng : erpm_accounts_Map.get(new_gm.Core_Intel_Account_Id__c) ){
                    system.debug('eng 61 =>'+eng);
                    if( eng.Core_ERPM_Business_Attributes__c != INVALID_TIER ){ 
                        String progMembership = eng.Core_ERPM_Engagement_Id__r.Name + ' - ' + eng.Core_ERPM_Business_Attributes__c;
                        if(!program_membership.contains(progMembership))
                          program_membership += ';'  + progMembership;
                        if(!partner_program.contains(eng.Core_ERPM_Engagement_Id__r.Name))
                          partner_program += ';'  + eng.Core_ERPM_Engagement_Id__r.Name; 
                        system.debug('eng 66 =>'+program_membership);
                        system.debug('eng 67 =>'+partner_program);
                    }
                    else{
                        if(!partner_program.contains(eng.Core_ERPM_Engagement_Id__r.Name))
                          partner_program += ';'  + eng.Core_ERPM_Engagement_Id__r.Name;
                        system.debug('eng 71 =>'+eng);
                        system.debug('eng 72 =>'+partner_program);
                    } 
                }                                
            }
            if(IntelCompInfo_Map.containsKey(grp_mem.Core_Intel_Account_Id__c)){
                company_existing = IntelCompInfo_Map.get(grp_mem.Core_Intel_Account_Id__c)[0];
            }
            /*//PSG Partner Program Changes
            if(acc!=null && acc.Core_IPA_Partner_Role__c!=null && !string.isblank(acc.Core_IPA_Partner_Role__c) && acc.Core_IPA_Partner_Role__c.contains(System.Label.PMP_FPGA_Designer)){
            partner_program += ';'  + System.Label.PMP_PSG_Partner_Program;  //Added Core_IPA_Partner_Role__c for US589301
            program_membership += ';'  + System.Label.PMP_PSG_Partner_Program;   //Added Core_IPA_Partner_Role__c for US589301
            }
            //PSG Parnter Program Changes*/
            //Sponsor Partner Program Changes - Added By Manjula
            if(acc!=null && acc.Core_IPA_Partner_Role__c!=null && !string.isblank(acc.Core_IPA_Partner_Role__c) && acc.Core_IPA_Partner_Role__c.contains(System.Label.PMP_Sponsor_Partner_Program)){
            partner_program += ';'  + System.Label.PMP_Other_Partner_Program;  //Added Core_IPA_Partner_Role__c for US617305
            program_membership += ';'  + System.Label.PMP_Other_Partner_Program;   //Added Core_IPA_Partner_Role__c for US617305
            }
            //Sponser Parnter Program Changes
            if(grp_mem.Core_MDA_Ind__c != null && grp_mem.Core_MDA_Ind__c == True && AccDetails_Map.containsKey(grp_mem.Core_Intel_Account_Id__c)){

                PMP_Company__c company                          = new PMP_Company__c();
                //company.Id                                      = company_existing == null ? null : company_existing.Id;
                company.Name                                    = acc.Name;
                company.PMP_Account_Id__c                       = grp_mem.Core_Intel_Account_Id__c;
                company.PMP_Company_Lifecycle_Status_Nm__c      = PMP_StaticConstants_Partner.Draft;           
                company.PMP_Account_Website__c                  = acc.Core_User_Defined_Website__c;
                company.PMP_Account_Program_Membership__c       = program_membership;
                company.PMP_Partner_Program_nm__c           = partner_program;
                company.PMP_Account_Specialty__c           = acc.Core_IPA_Partner_Speciality__c;    
                company.PMP_Is_Published_Ind__c                 = true;                        
                company.PMP_Is_Working_Copy_Ind__c              = false;            
                company.PMP_Company_Status_Update_Dt__c         = Date.today();
                company.PMP_Initial_Storefront_Submit_Date_Dt__c     = Date.today();
                //Added to populate one partner Id at company level 31-Oct-2019
                company.PMP_One_Partner_ID__c             = grp_mem.Core_Partner_Account_Id__c;
                newcompanies.add(company);
            } else if (grp_mem.Core_MDA_Ind__c != null && grp_mem.Core_MDA_Ind__c == False && AccDetails_Map.containsKey(grp_mem.Core_Intel_Account_Id__c)){
                //if(!partnerAccountMDA_Map.ContainsKey(partnerAccountIds_Map.get(grp_mem.Id))) grp_mem.addError('Atleast one MDA should be flagged for a partner Account Group');
            }        
        } 
        if (newcompanies.size() > 0){
            insert(newcompanies);
            system.debug('newcompanies => '+newcompanies);
      System.enqueueJob(new PMP_SearchCreatePartnerWorkCopy(newcompanies));              
        }                 
    }    
    
    // Uday 6/27/2019 US377991 - Populate all the MP fields from Account to its Company Information object.
    /***************************************************************************************************** 
    *Method Name:                                              onGroupMemAfterUpdate
    *@return  :                                                Void
    *Modified By:                       Date:                  Changes: 
    *Udaya Katta                      6/27/2019                Original Version
    ******************************************************************************************************/
    
    public static void onGroupMemAfterUpdate(List<Core_Account_Group_Member__c> newList, Map<Id,Core_Account_Group_Member__c> oldMap,  Map<Id,Core_Account_Group_Member__c> newMap) {
        List<PMP_Company__c> newcompanies = new List<PMP_Company__c>(); 
        Map<Id, Boolean> partnerAccountMDA_Map = new Map<Id, Boolean>(); 
        Map<Id, Id> partnerIntelAcc_Map = new Map<Id, Id>();
        Map<Id, Account> AccDetails_Map = new Map<Id,Account>([Select Id, Name,Core_IPA_Partner_Speciality__c, Core_User_Defined_Website__c,recordTypeId,Website,Core_IPA_Partner_Role__c  from Account where RecordTypeId =: INTEL_RECTYPEID AND Id IN (Select Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Id IN: newMap.KeySet() AND Core_MDA_Ind__c = true)]);        
        Map<Id, List<PMP_Company__c>> IntelCompInfo_Map = new Map<Id, List<PMP_Company__c>>();        
        Map<Id, Id> partnerAccountIds_Map = new Map<Id, Id>(); 
        Map<Id, List<Core_Account_ERPM_Engagement__c>> erpm_accounts_Map = new Map<Id, List<Core_Account_ERPM_Engagement__c>>();        
        List<Account> changed_partnerAccs_lst = [Select Id, Name,Core_IPA_Partner_Speciality__c, Core_User_Defined_Website__c,recordTypeId,Website,Core_IPA_Partner_Role__c,  
                                                 (Select Id, Core_MDA_Ind__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__c,Core_Intel_Account_Id__r.Name, Core_Intel_Account_Id__r.Website, Core_Intel_Account_Id__r.recordTypeId from Partner_Account_Group_Members1__r Where Core_MDA_Ind__c = true ORDER BY LastModifiedDate DESC), 
                                                 (Select Id, Name, PMP_Account_Id__c, PMP_Company_Lifecycle_Status_Nm__c, PMP_Is_Published_Ind__c  from Company_Informations__r Where PMP_Is_Published_Ind__c = true AND PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published ORDER BY LastModifiedDate DESC),
                                                 (SELECT Core_Account_Id__c, Core_ERPM_Business_Attributes__c, Core_ERPM_Engagement_Id__r.Name from Account_ERPM_Engagements__r Where Core_ERPM_Engagement_Id__r.Name =: PROGRAMS) 
                                                 from Account where RecordTypeId =: INTEL_RECTYPEID
                                                 AND Id IN (Select Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Id IN: newMap.KeySet() AND Core_MDA_Ind__c = true) ORDER BY LastModifiedDate DESC];
        for(Account acc : changed_partnerAccs_lst){
            for(Core_Account_Group_Member__c partner_grp_mem : acc.Partner_Account_Group_Members1__r){
                if(partner_grp_mem.Core_Partner_Account_Id__c != null && partner_grp_mem.Core_Partner_Account_Id__c != null){
                    partnerIntelAcc_Map.put(partner_grp_mem.Core_Partner_Account_Id__c, partner_grp_mem.Core_Intel_Account_Id__c);
                }                
            }
            for(PMP_Company__c comp_info : acc.Company_Informations__r){
                if(IntelCompInfo_Map.containsKey(comp_info.PMP_Account_Id__c)){
                    IntelCompInfo_Map.get(comp_info.PMP_Account_Id__c).add(comp_info);
                } else {
                    IntelCompInfo_Map.put(comp_info.PMP_Account_Id__c, new List<PMP_Company__c>{comp_info});
                }  
            }
            for(Core_Account_ERPM_Engagement__c erpm_acc : acc.Account_ERPM_Engagements__r){
                if(erpm_accounts_Map.containsKey(erpm_acc.Core_Account_Id__c)){
                    erpm_accounts_Map.get(erpm_acc.Core_Account_Id__c).add(erpm_acc);
                }else{
                    erpm_accounts_Map.put(erpm_acc.Core_Account_Id__c, new List<Core_Account_ERPM_Engagement__c>{erpm_acc});
                }
            }
        } 
        
        for(Core_Account_Group_Member__c grp_mem : newList){
            Account acc = AccDetails_Map.get(grp_mem.Core_Intel_Account_Id__c);
            PMP_Company__c company_existing;
            String partner_program = '';
            String program_membership = '';            
            Core_Account_Group_Member__c old_gm = oldMap.get(grp_mem.Id);
            Core_Account_Group_Member__c new_gm = newMap.get(grp_mem.Id);
            if(erpm_accounts_Map.containsKey(new_gm.Core_Intel_Account_Id__c)){
                
                for( Core_Account_ERPM_Engagement__c eng : erpm_accounts_Map.get(new_gm.Core_Intel_Account_Id__c) ){
                    if( eng.Core_ERPM_Business_Attributes__c != INVALID_TIER && eng.Core_ERPM_Engagement_Id__r.Name!= NO_TIER ){
                        String progMembership = eng.Core_ERPM_Engagement_Id__r.Name + ' - ' + eng.Core_ERPM_Business_Attributes__c;
                        if(!program_membership.contains(progMembership))
                          program_membership += ';'  + progMembership;
                        if(!partner_program.contains(eng.Core_ERPM_Engagement_Id__r.Name))
                          partner_program += ';'  + eng.Core_ERPM_Engagement_Id__r.Name; 
                      
                    }
                    else{
                        if(!partner_program.contains(eng.Core_ERPM_Engagement_Id__r.Name))
                          partner_program += ';'  + eng.Core_ERPM_Engagement_Id__r.Name;
                       
                    }
                }                                
            }
            if(IntelCompInfo_Map.containsKey(grp_mem.Core_Intel_Account_Id__c)){
                company_existing = IntelCompInfo_Map.get(grp_mem.Core_Intel_Account_Id__c)[0];
            } 
           /* //PSG Partner Program Changes
            if(acc!=null && acc.Core_IPA_Partner_Role__c!=null && !string.isblank(acc.Core_IPA_Partner_Role__c) && acc.Core_IPA_Partner_Role__c.contains(System.Label.PMP_FPGA_Designer)){
            partner_program += ';'  + System.Label.PMP_PSG_Partner_Program;  //Added Core_IPA_Partner_Role__c for US589301
            program_membership += ';'  + System.Label.PMP_PSG_Partner_Program;   //Added Core_IPA_Partner_Role__c for US589301
            }
            //PSG Parnter Program Changes -commented as part of QA deployment*/
            //Sponsor Partner Program Changes - Added By Manjula
            if(acc!=null && acc.Core_IPA_Partner_Role__c!=null && !string.isblank(acc.Core_IPA_Partner_Role__c) && acc.Core_IPA_Partner_Role__c.contains(System.Label.PMP_Sponsor_Partner_Program)){
            partner_program += ';'  + System.Label.PMP_Sponsor_Partner_Program;  //Added Core_IPA_Partner_Role__c for US617305
            program_membership += ';'  + System.Label.PMP_Sponsor_Partner_Program;   //Added Core_IPA_Partner_Role__c for US617305
            }
            //Sponsor Parnter Program Changes
           // if(grp_mem.Core_MDA_Ind__c != null && grp_mem.Core_MDA_Ind__c == True && new_gm.Core_MDA_Ind__c != old_gm.Core_MDA_Ind__c && AccDetails_Map.containsKey(grp_mem.Core_Intel_Account_Id__c)){
            if(grp_mem.Core_MDA_Ind__c != null && grp_mem.Core_MDA_Ind__c == True && new_gm.Core_MDA_Ind__c != old_gm.Core_MDA_Ind__c && AccDetails_Map.containsKey(grp_mem.Core_Intel_Account_Id__c)){

                PMP_Company__c company                          = new PMP_Company__c();
                company.Id                                      = company_existing == null ? null : company_existing.Id;
                company.Name                                    = acc.Name;
                company.PMP_Account_Id__c                       = grp_mem.Core_Intel_Account_Id__c;
                company.PMP_Company_Lifecycle_Status_Nm__c      = PMP_StaticConstants_Partner.Draft;          
                company.PMP_Account_Website__c                  = acc.Core_User_Defined_Website__c;
                company.PMP_Account_Program_Membership__c       = program_membership;
                company.PMP_Partner_Program_nm__c           = partner_program;                 
                company.PMP_Account_Specialty__c           = acc.Core_IPA_Partner_Speciality__c;    
                company.PMP_Is_Published_Ind__c                 = true;                        
                company.PMP_Is_Working_Copy_Ind__c              = false;            
                company.PMP_Company_Status_Update_Dt__c         = Date.today();
                company.PMP_Initial_Storefront_Submit_Date_Dt__c     = Date.today();
                //Added to populate one partner Id at company level 31-Oct-2019
                company.PMP_One_Partner_ID__c             = grp_mem.Core_Partner_Account_Id__c;
                newcompanies.add(company);
                System.debug('comapany info'+ company);

            } else if (grp_mem.Core_MDA_Ind__c != null && grp_mem.Core_MDA_Ind__c == False && old_gm.Core_MDA_Ind__c == True && AccDetails_Map.containsKey(grp_mem.Core_Intel_Account_Id__c)){
                //if(!partnerAccountMDA_Map.ContainsKey(partnerAccountIds_Map.get(grp_mem.Id))) grp_mem.addError('Atleast one MDA should be flagged for a partner Account Group');
            }        
           //Commented as a part of US622434[FOR SONAR CUBE]              
           /* if (newcompanies.size() > 0){
                upsert(newcompanies);
                
                System.enqueueJob(new PMP_SearchCreatePartnerWorkCopy(newcompanies));              
            }*/
        }
         //as a part of US622434[FOR SONAR CUBE]     
        if (newcompanies.size() > 0){
            upsert(newcompanies);
            System.debug('comapany info'+ newcompanies);
            System.enqueueJob(new PMP_SearchCreatePartnerWorkCopy(newcompanies));              
        }

    }
    
    // Uday 6/27/2019 US377991 - Populate all the MP fields from Account to its Company Information object.
    /***************************************************************************************************** 
    *Method Name:                                              onGroupMemBeforeDelete
    *@return  :                                                Void
    *Modified By:                       Date:                  Changes: 
    *Udaya Katta                      6/27/2019                Original Version
    ******************************************************************************************************/
/*    
    public static void onGroupMemBeforeDelete(List<Core_Account_Group_Member__c> oldList, Map<Id,Core_Account_Group_Member__c> oldMap) {
        Map<Id, Integer> partnerAccountMDACount_Map = new Map<Id, Integer>();
        Map<Id, Id> partnerAccount_Map = new Map<Id, Id>();

        List<Account> changed_partnerAccs_lst = [Select Id, Name,   
                                                 (Select Id, Core_MDA_Ind__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__c,Core_Intel_Account_Id__r.Name, Core_Intel_Account_Id__r.Website, Core_Intel_Account_Id__r.recordTypeId from Partner_Account_Group_Members1__r Where Core_MDA_Ind__c = true ORDER BY LastModifiedDate), 
                                                 (Select Id, Name, PMP_Account_Id__c, PMP_Company_Lifecycle_Status_Nm__c, PMP_Is_Published_Ind__c  from Company_Informations__r Where PMP_Is_Published_Ind__c = true AND PMP_Company_Lifecycle_Status_Nm__c = 'Published' ORDER BY LastModifiedDate DESC)
                                                 from Account where RecordType.DeveloperName = 'Mastered_Account'
                                                 AND Id IN (Select Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Core_MDA_Ind__c = true AND Id IN: oldMap.KeySet()) ORDER BY LastModifiedDate];        

        for(Account acc : changed_partnerAccs_lst){
            for(Core_Account_Group_Member__c partner_grp_mem : acc.Partner_Account_Group_Members1__r){
                if(partnerAccountMDACount_Map.containsKey(partner_grp_mem.Core_Partner_Account_Id__c)){
                    partnerAccountMDACount_Map.put(partner_grp_mem.Core_Partner_Account_Id__c, partnerAccountMDACount_Map.get(partner_grp_mem.Core_Partner_Account_Id__c) + 1);
                } else {
                    partnerAccountMDACount_Map.put(partner_grp_mem.Core_Partner_Account_Id__c, 1);
                } 
            }
        } 
        
        for(Core_Account_Group_Member__c grp_mem : oldList){
            if(partnerAccountMDACount_Map.get(grp_mem.Core_Partner_Account_Id__c) <= 1){
                grp_mem.addError('Please ensure to have atleast one MDA for Partner Account');
            }
        }
    }    
*/
}