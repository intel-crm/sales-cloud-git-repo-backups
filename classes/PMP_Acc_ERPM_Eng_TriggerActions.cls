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
    
    public static void updatePartnerMembership(List<Core_Account_ERPM_Engagement__c> newList, List<Core_Account_ERPM_Engagement__c> oldList, Map<Id, Core_Account_ERPM_Engagement__c> newMap, Map<Id, Core_Account_ERPM_Engagement__c> oldMap) {
        try {
            Map<Id, List<PMP_Company__c>> IntelCompInfo_Map = new Map<Id, List<PMP_Company__c>>();
            Map<Id, List<Core_Account_ERPM_Engagement__c>> erpm_accounts_Map = new Map<Id, List<Core_Account_ERPM_Engagement__c>>();
            List<PMP_Company__c> update_partners_lst = new List<PMP_Company__c>();

            Set<Id> erpm_acc_Ids = getCoreAccountIds(newList, oldList);

            populateMaps(erpm_acc_Ids, IntelCompInfo_Map, erpm_accounts_Map);

            updatePartners(IntelCompInfo_Map, erpm_accounts_Map, update_partners_lst);

            if (!update_partners_lst.isEmpty()) {
                Database.SaveResult[] results = Database.update(update_partners_lst, false);
            	PMP_Utility.logDmlErrors((Object[]) results, 'PMP_Acc_ERPM_Eng_TriggerActions-updatePartnerMembership');
                //Database.update(update_partners_lst);
            }
        } catch (Exception ex) {
            handleException(ex);
        }
    }

    private static Set<Id> getCoreAccountIds(List<Core_Account_ERPM_Engagement__c> newList, List<Core_Account_ERPM_Engagement__c> oldList) {
        Set<Id> erpm_acc_Ids = new Set<Id>();
        for (Core_Account_ERPM_Engagement__c erpm : (newList != null ? newList : oldList)) {
            if (erpm.Core_Account_Id__c != null) {
                erpm_acc_Ids.add(erpm.Core_Account_Id__c);
            }
        }
        return erpm_acc_Ids;
    }

    private static void populateMaps(Set<Id> erpm_acc_Ids, Map<Id, List<PMP_Company__c>> IntelCompInfo_Map, Map<Id, List<Core_Account_ERPM_Engagement__c>> erpm_accounts_Map) {
        for (Account a : [SELECT Id, 
                                (SELECT Id, Core_MDA_Ind__c, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c, Core_Intel_Account_Id__r.Name, Core_Intel_Account_Id__r.Website, Core_Intel_Account_Id__r.recordTypeId, Core_Intel_Account_Id__r.ParentId FROM Partner_Account_Group_Members1__r WHERE Core_MDA_Ind__c = true ORDER BY LastModifiedDate),
                                (SELECT Id, Name, PMP_Account_Id__c FROM Company_Informations__r ORDER BY LastModifiedDate),
                                (SELECT Core_Account_Id__c, Core_ERPM_Business_Attributes__c, Core_ERPM_Engagement_Id__r.Name FROM Account_ERPM_Engagements__r WHERE Core_ERPM_Engagement_Id__r.Name =: PROGRAMS) 
                                FROM Account WHERE RecordTypeId =: INTEL_RECTYPEID AND (Id IN: erpm_acc_Ids) AND (Id IN (SELECT Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c WHERE Core_MDA_Ind__c = true)) ORDER BY LastModifiedDate]) {
            for (PMP_Company__c comp_info : a.Company_Informations__r) {
                if (!IntelCompInfo_Map.containsKey(comp_info.PMP_Account_Id__c)) {
                    IntelCompInfo_Map.put(comp_info.PMP_Account_Id__c, new List<PMP_Company__c>());
                }
                IntelCompInfo_Map.get(comp_info.PMP_Account_Id__c).add(comp_info);
            }

            for (Core_Account_ERPM_Engagement__c erpm_acc : a.Account_ERPM_Engagements__r) {
                if (!erpm_accounts_Map.containsKey(erpm_acc.Core_Account_Id__c)) {
                    erpm_accounts_Map.put(erpm_acc.Core_Account_Id__c, new List<Core_Account_ERPM_Engagement__c>());
                }
                erpm_accounts_Map.get(erpm_acc.Core_Account_Id__c).add(erpm_acc);
            }
        }
    }

    private static void updatePartners(Map<Id, List<PMP_Company__c>> IntelCompInfo_Map, Map<Id, List<Core_Account_ERPM_Engagement__c>> erpm_accounts_Map, List<PMP_Company__c> update_partners_lst) {
        for (Id accountId : IntelCompInfo_Map.keySet()) {
            List<PMP_Company__c> compInfoList = IntelCompInfo_Map.get(accountId);
            List<Core_Account_ERPM_Engagement__c> erpmAccList = erpm_accounts_Map.get(accountId);

            for (PMP_Company__c partner : compInfoList) {
                partner.PMP_Account_Program_Membership__c = '';
                partner.PMP_Partner_Program_nm__c = '';

                if (erpmAccList != null) {
                    updatePartnerWithEngagements(partner, erpmAccList);
                }
                update_partners_lst.add(partner);
            }
        }
    }

    private static void updatePartnerWithEngagements(PMP_Company__c partner, List<Core_Account_ERPM_Engagement__c> erpmAccList) {
        for (Core_Account_ERPM_Engagement__c eng : erpmAccList) {
            if (eng.Core_ERPM_Business_Attributes__c != INVALID_TIER) {
                updatePartnerMembershipWithValidAttributes(partner, eng);
            } else {
                updatePartnerMembershipWithoutValidAttributes(partner, eng);
            }
        }
    }

    private static void updatePartnerMembershipWithValidAttributes(PMP_Company__c partner, Core_Account_ERPM_Engagement__c eng) {
        String progMembership = eng.Core_ERPM_Engagement_Id__r.Name + ' - ' + eng.Core_ERPM_Business_Attributes__c;
        if (!partner.PMP_Account_Program_Membership__c.contains(progMembership)) {
            partner.PMP_Account_Program_Membership__c += ';' + progMembership;
        }
        if (!partner.PMP_Partner_Program_nm__c.contains(eng.Core_ERPM_Engagement_Id__r.Name)) {
            partner.PMP_Partner_Program_nm__c += ';' + eng.Core_ERPM_Engagement_Id__r.Name;
        }
    }

    private static void updatePartnerMembershipWithoutValidAttributes(PMP_Company__c partner, Core_Account_ERPM_Engagement__c eng) {
        if (!partner.PMP_Partner_Program_nm__c.contains(eng.Core_ERPM_Engagement_Id__r.Name)) {
            partner.PMP_Partner_Program_nm__c += ';' + eng.Core_ERPM_Engagement_Id__r.Name;
        }
    }



    private static void updatePartnerProgramMembership(PMP_Company__c partner, Core_Account_ERPM_Engagement__c engagement) {
        if (engagement.Core_ERPM_Business_Attributes__c != INVALID_TIER) {
            String progMembership = engagement.Core_ERPM_Engagement_Id__r.Name + ' - ' + engagement.Core_ERPM_Business_Attributes__c;
            if (!partner.PMP_Account_Program_Membership__c.contains(progMembership)) {
                partner.PMP_Account_Program_Membership__c += ';' + progMembership;
            }
            if (!partner.PMP_Partner_Program_nm__c.contains(engagement.Core_ERPM_Engagement_Id__r.Name)) {
                partner.PMP_Partner_Program_nm__c += ';' + engagement.Core_ERPM_Engagement_Id__r.Name;
            }
        } else {
            if (!partner.PMP_Partner_Program_nm__c.contains(engagement.Core_ERPM_Engagement_Id__r.Name)) {
                partner.PMP_Partner_Program_nm__c += ';' + engagement.Core_ERPM_Engagement_Id__r.Name;
            }
        }
    }

    private static void handleException(Exception ex) {
        throw new AuraHandledException(ex.getMessage() + ' ' + ex.getCause() + ' ' + ex.getLineNumber());
    }   
}