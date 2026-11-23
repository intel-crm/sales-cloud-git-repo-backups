public class PMP_Acc_ERPM_Eng_TriggerActions {
    
    final static String[] PROGRAMS = new String[]{'ISA', 'CSPx2'};
   	final static String NO_TIER = 'ODM-LOEM';    
    final static String INVALID_TIER = 'UNDETERMND';
    static Id PARTNER_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
    static Id INTEL_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    
    public static void onAfterInsert(List<Core_Account_ERPM_Engagement__c> newList, Map<Id,Core_Account_ERPM_Engagement__c> newMap){
        updatePartnerMembership(newList, null, newMap, null);    
    }
    
    public static void onAfterUpdate(List<Core_Account_ERPM_Engagement__c> newList, Map<Id,Core_Account_ERPM_Engagement__c> newMap){
        updatePartnerMembership(newList, null, newMap, null);
    }
    
    public static void onAfterDelete(List<Core_Account_ERPM_Engagement__c> oldList, Map<Id,Core_Account_ERPM_Engagement__c> oldMap){
        updatePartnerMembership(null, oldList, null, oldMap);
    }    
    
    public static void updatePartnerMembership(List<Core_Account_ERPM_Engagement__c> newList, List<Core_Account_ERPM_Engagement__c> oldList, Map<Id,Core_Account_ERPM_Engagement__c> newMap, Map<Id,Core_Account_ERPM_Engagement__c> oldMap){
        Map<Id, List<PMP_Company__c>> IntelCompInfo_Map = new Map<Id, List<PMP_Company__c>>();
        Map<Id, List<Core_Account_ERPM_Engagement__c>> erpm_accounts_Map = new Map<Id, List<Core_Account_ERPM_Engagement__c>>();
        List<PMP_Company__c> update_partners_lst = new List<PMP_Company__c>();
        Set<Id> erpm_acc_Ids = new Set<Id>();
        try{
            for(Core_Account_ERPM_Engagement__c erpm : newList != null ? newList : oldList){
                if(erpm.Core_Account_Id__c != null){
                    erpm_acc_Ids.add(erpm.Core_Account_Id__c);                
                }
            }
            
            List<Account> changed_partnerAccs_lst = [Select Id, Name,Core_IPA_Partner_Speciality__c, Core_User_Defined_Website__c,recordTypeId,Website, ParentId,	
                                                     (Select Id, Core_MDA_Ind__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__c,Core_Intel_Account_Id__r.Name, Core_Intel_Account_Id__r.Website, Core_Intel_Account_Id__r.recordTypeId, Core_Intel_Account_Id__r.ParentId from Partner_Account_Group_Members1__r Where Core_MDA_Ind__c = true ORDER BY LastModifiedDate), 
                                                     (Select Id, Name, PMP_Account_Id__c from Company_Informations__r ORDER BY LastModifiedDate),
                                                     (SELECT Core_Account_Id__c, Core_ERPM_Business_Attributes__c, Core_ERPM_Engagement_Id__r.Name from Account_ERPM_Engagements__r Where Core_ERPM_Engagement_Id__r.Name =: PROGRAMS) 
                                                     from Account WHERE  RecordTypeId =: INTEL_RECTYPEID 
                                                     AND (Id IN: erpm_acc_Ids) 
                                                     AND (Id IN (Select Core_Intel_Account_Id__c from Core_Account_Group_Member__c Where Core_MDA_Ind__c = true))			
                                                     ORDER BY LastModifiedDate];
            
            for(Account a : changed_partnerAccs_lst){
                for(PMP_Company__c comp_info : a.Company_Informations__r){
                    if(IntelCompInfo_Map.containsKey(comp_info.PMP_Account_Id__c)){
                        IntelCompInfo_Map.get(comp_info.PMP_Account_Id__c).add(comp_info);
                    } else {
                        IntelCompInfo_Map.put(comp_info.PMP_Account_Id__c, new List<PMP_Company__c>{comp_info});
                    }  
                }            
                for(Core_Account_ERPM_Engagement__c erpm_acc : a.Account_ERPM_Engagements__r){
                    if(erpm_accounts_Map.containsKey(erpm_acc.Core_Account_Id__c)){
                        erpm_accounts_Map.get(erpm_acc.Core_Account_Id__c).add(erpm_acc);
                    }else{
                        erpm_accounts_Map.put(erpm_acc.Core_Account_Id__c, new List<Core_Account_ERPM_Engagement__c>{erpm_acc});
                    }
                }                
            }
            
            for(Account a : changed_partnerAccs_lst){
                for(PMP_Company__c partner : IntelCompInfo_Map.get(a.Id)){
                    partner.PMP_Account_Program_Membership__c = '';
                    partner.PMP_Partner_Program_nm__c = '';   
                    if(erpm_accounts_Map.containsKey(a.Id)){
                        for(Core_Account_ERPM_Engagement__c eng : erpm_accounts_Map.get(a.Id)){
                            if( eng.Core_ERPM_Business_Attributes__c != INVALID_TIER ){ 
                                String progMembership = eng.Core_ERPM_Engagement_Id__r.Name + ' - ' + eng.Core_ERPM_Business_Attributes__c;
                                if(!partner.PMP_Account_Program_Membership__c.contains(progMembership))
                                	partner.PMP_Account_Program_Membership__c += ';'  + progMembership;
                                if(!partner.PMP_Partner_Program_nm__c.contains(eng.Core_ERPM_Engagement_Id__r.Name))
                                	partner.PMP_Partner_Program_nm__c += ';'  + eng.Core_ERPM_Engagement_Id__r.Name; 
                            }
                            else{
                                if(!partner.PMP_Partner_Program_nm__c.contains(eng.Core_ERPM_Engagement_Id__r.Name))
                                	partner.PMP_Partner_Program_nm__c += ';'  + eng.Core_ERPM_Engagement_Id__r.Name;
                            }                    
                        }                    
                    }
                    update_partners_lst.add(partner);
                }
            }
            
            if(!update_partners_lst.isEmpty()){
                Database.update(update_partners_lst);
            }
            
        } catch (exception ex){
            system.debug('Error : '+ ex.getMessage()+ ' Cause : ' + ex.getCause()+' Line : '+ ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage()+ ' ' + ex.getCause()+' '+ ex.getLineNumber());
        } 
        
    }   
}