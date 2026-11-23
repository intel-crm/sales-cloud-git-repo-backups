/******************************************************************************************************************************************
Class Name  : Core_ERPMInboundMessage_IPAContact
This class contains the deprecated code from the Core_IntInboundMsgERPM_Contact Class.
As Core_IntInboundMsgERPM_Contact Class having a label STOP_ERPM_SLSCLD_IPA_INTEG has true value, it wont excute below logics
***********************************************************************************************************************/

public without sharing class Core_ERPMInboundMessage_IPAContact {

    public static Set<String> erpmAcctEnggCodes = new Set<String>();
    private static Boolean enttlAssignFlag = false;
    private static List<Core_IntegrationUtility.ERPM_Person_Account> erpmAccounts = new List<Core_IntegrationUtility.ERPM_Person_Account>();
    public static Map<Id,Account> accountPartnerSpecsMap = new Map<Id,Account>();

    /*
    * description : Setting person Account record 
    * params : Core_IntegrationUtility.ERPM_Person person
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    public static void IPA_SetErpmAccount(Core_IntegrationUtility.ERPM_Person person){
        enttlAssignFlag= true;
        for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
            erpmAccounts.add(acct);
        }
    }

    /*
    * description : Setting the Person account record Id
    * params : Core_IntegrationUtility.ERPM_Person person,Contact matchingContact,Set<Id> allAccountIds,Map<String,Account> matchingAccountMap
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    public static void IPA_SetAllAccountId(Core_IntegrationUtility.ERPM_Person person,Contact matchingContact,Set<Id> allAccountIds,Map<String,Account> matchingAccountMap){
        if (!person.ignoreMessage) {
            if (matchingContact!=null &&(matchingContact.Core_eRPM_Person_Id__c==person.erpmPersonId || matchingContact.Email==person.email)) {
                allAccountIds.add(matchingContact.AccountId);
            }else if (!person.personAccounts.isEmpty()) {
                for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
                    if (matchingAccountMap.containsKey(acct.cimId)) {
                        allAccountIds.add(matchingAccountMap.get(acct.cimId).Id);
                    }
                }   
            }
        }
    }

    /*
    * description : Add partner role based on account engagements and patner speciality of account
    * params : Contact newc, Set<Id> allAccountIds
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    public static void IPA_AddPartnerRole(Contact newc, Set<Id> allAccountIds) {
        List<String> acctBenefits = new List<String>();
        Map<String,String> eRPMSFMappingsByPartnerSpecs = new Map<String,String>();
        Set<String> allPartnerSpecs = new Set<String>();
        IPA_getAccountPartner(allAccountIds,eRPMSFMappingsByPartnerSpecs,allPartnerSpecs);
        String partnerSpeciality = accountPartnerSpecsMap.containsKey(newc.AccountId) ? accountPartnerSpecsMap.get(newc.AccountId).Core_IPA_Partner_Speciality__c : null;
        List<String> partnerRoles = new List<String>();
        Map<string, List<string> > customSettingmap = new map<string, List<string> >();
        if(!String.isEmpty(partnerSpeciality)) {
            List<String> partnerSplList = partnerSpeciality.split(';');
            for(String partnerSpl : partnerSplList ) {
                if(eRPMSFMappingsByPartnerSpecs.containsKey(partnerSpl)) {
                    acctBenefits.add(eRPMSFMappingsByPartnerSpecs.get(partnerSpl));
                }
            }
        }
        List<ERPM_SF_MAPPING_SETTING__mdt> eRPMSFMappingsByEnggCodes = [SELECT SF_KeyValue__c, eRPM_KeyValue__c, eRPM_EngagementCodes__c FROM ERPM_SF_MAPPING_SETTING__mdt WHERE Mappting_Type__c =: Label.PRM_Partner_Role AND eRPM_EngagementCodes__c IN: erpmAcctEnggCodes];
        for( ERPM_SF_MAPPING_SETTING__mdt customSettings : eRPMSFMappingsByEnggCodes) {
            if ((!customSettingmap.containsKey(customSettings.eRPM_EngagementCodes__c)) ) {
                if(acctBenefits.Contains(customSettings.SF_KeyValue__c)) {
                    customSettingmap.put(customSettings.eRPM_EngagementCodes__c, new List<String> {customSettings.eRPM_KeyValue__c});
                }
                else if(customSettings.eRPM_EngagementCodes__c == Label.PRM_ISA_Engagement_Code
                        || customSettings.eRPM_EngagementCodes__c == Label.PRM_CSPx2EngagementCode) {
                            customSettingmap.put(customSettings.eRPM_EngagementCodes__c, new List<String> {customSettings.eRPM_KeyValue__c});
                        }
            }
            else {
                if(!customSettingmap.get(customSettings.eRPM_EngagementCodes__c).Contains(customSettings.eRPM_KeyValue__c)) {
                    if(acctBenefits.Contains(customSettings.SF_KeyValue__c)) {
                        customSettingmap.get(customSettings.eRPM_EngagementCodes__c).add(customSettings.eRPM_KeyValue__c);
                    }
                }
            }
        }
        if(customSettingmap.values().size() > 0) {
            for(List<String> roles : customSettingmap.values()) {
                partnerRoles.addAll(roles);
            }
            if(String.isNotBlank(newc.Core_IPA_PartnerRole__c))
                partnerRoles.addAll(newc.Core_IPA_PartnerRole__c.split(';'));
        }
    }

    /*
    * description : Add/Update the account person subscription for an existing user
    * params : Core_IntegrationUtility.ERPM_Person person, Map<String,Account> matchingAccountMap, Map<Id,List<Core_IntegrationUtility.ERPM_Person_Account_Relation>> acctIdRelationshipsMap,List<String> PRMEngagements
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    public static void IPA_Subscription(Core_IntegrationUtility.ERPM_Person person, Map<String,Account> matchingAccountMap, Map<Id,List<Core_IntegrationUtility.ERPM_Person_Account_Relation>> acctIdRelationshipsMap,List<String> PRMEngagements) {

        Set<String> emailCimIds = new Set<String>();
        Map<String,Set<String> > params = new Map<String,Set<String> >();
        if (person.personAccounts.size() > 0) {
            for (Core_IntegrationUtility.ERPM_Person_Account acct : person.personAccounts) {
                if (matchingAccountMap.containsKey(acct.cimId)) {
                    List<Core_IntegrationUtility.ERPM_Person_Account_Relation> relationships = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
                    if(acct.personAccountRelations != null && acct.personAccountRelations.size() > 0) {
                        for(Core_IntegrationUtility.ERPM_Person_Account_Relation ePAR: acct.personAccountRelations) {
                            if((PRMEngagements !=null && PRMEngagements.size() > 0) && PRMEngagements.contains(ePAR.engagementCode)) {
                                relationships.add(ePAR);
                            }
                        }
                        if(relationships.size() >0) {
                            if(!acctIdRelationshipsMap.ContainsKey(matchingAccountMap.get(acct.cimId).Id)){
                                acctIdRelationshipsMap.put(matchingAccountMap.get(acct.cimId).Id, relationships);
                            }
                            else{
                                acctIdRelationshipsMap.get(matchingAccountMap.get(acct.cimId).Id).addAll(relationships);
                            }
                        }
                    }
                    erpmAccounts.add(acct);
                }
            }
        }
    }

    /*
    * description : Add partner role based on account engagements and patner speciality of account
    * params : Contact newc, Id sfAccountId, Set<Id> allAccountIds
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    public static void IPA_AddPartnerRole(Contact newc, Id sfAccountId, Set<Id> allAccountIds) {
        List<String> acctBenefits = new List<String>();
        Map<String,String> eRPMSFMappingsByPartnerSpecs = new Map<String,String>();
        Set<String> allPartnerSpecs = new Set<String>();
        IPA_getAccountPartner(allAccountIds,eRPMSFMappingsByPartnerSpecs,allPartnerSpecs);
        String partnerSpeciality = accountPartnerSpecsMap.containsKey(sfAccountId) ? accountPartnerSpecsMap.get(sfAccountId).Core_IPA_Partner_Speciality__c : null;
        if(!String.isEmpty(partnerSpeciality)) {
            List<String> partnerSplList = partnerSpeciality.split(';');
            for(String partnerSpl : partnerSplList ) {
                if(eRPMSFMappingsByPartnerSpecs.containsKey(partnerSpl)) {
                    acctBenefits.add(eRPMSFMappingsByPartnerSpecs.get(partnerSpl));
                }
            } 
        }
        List<String> partnerRoles = new List<String>();
        Map<string, List<string> > customSettingmap = new map<string, List<string> >();
        List<ERPM_SF_MAPPING_SETTING__mdt> eRPMSFMappingsByEnggCodes = [SELECT SF_KeyValue__c, eRPM_KeyValue__c, eRPM_EngagementCodes__c FROM ERPM_SF_MAPPING_SETTING__mdt WHERE Mappting_Type__c =: Label.PRM_Partner_Role AND eRPM_EngagementCodes__c IN: erpmAcctEnggCodes];
        for( ERPM_SF_MAPPING_SETTING__mdt customSettings : eRPMSFMappingsByEnggCodes) {
            if ((!customSettingmap.containsKey(customSettings.eRPM_EngagementCodes__c)) ) {
                if(acctBenefits.Contains(customSettings.SF_KeyValue__c)) {
                    customSettingmap.put(customSettings.eRPM_EngagementCodes__c, new List<String> {customSettings.eRPM_KeyValue__c});
                }
                else if(customSettings.eRPM_EngagementCodes__c == Label.PRM_ISA_Engagement_Code
                        || customSettings.eRPM_EngagementCodes__c == Label.PRM_CSPx2EngagementCode) {
                            customSettingmap.put(customSettings.eRPM_EngagementCodes__c, new List<String> {customSettings.eRPM_KeyValue__c});
                        }
            }
            else {
                if(!customSettingmap.get(customSettings.eRPM_EngagementCodes__c).Contains(customSettings.eRPM_KeyValue__c)) {
                    if(acctBenefits.Contains(customSettings.SF_KeyValue__c)) {
                        customSettingmap.get(customSettings.eRPM_EngagementCodes__c).add(customSettings.eRPM_KeyValue__c);
                    }
                }
            }
        }
        if(customSettingmap.values().size() > 0) {
            for(List<String> roles : customSettingmap.values()) {
                partnerRoles.addAll(roles);
            }
            if(partnerRoles.size() >0){
                newc.Core_IPA_PartnerRole__c = Core_IntegrationUtility.formatMultiSelectPicklist(new List<String>(new Set<String>(partnerRoles)));
            }  
        } 
    }

    /*
    * description : Add Account Contact Relationship.
    * params : Core_IntegrationUtility.ERPM_Person_Account acct, List<String> PRMEngagements, Map<Id,List<Core_IntegrationUtility.ERPM_Person_Account_Relation>> acctIdRelationshipsMap, Map<String,Account> matchingAccountMap
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    public static void IPA_AddAcctRelationships(Core_IntegrationUtility.ERPM_Person_Account acct, List<String> PRMEngagements, Map<Id,List<Core_IntegrationUtility.ERPM_Person_Account_Relation>> acctIdRelationshipsMap, Map<String,Account> matchingAccountMap){
        List<Core_IntegrationUtility.ERPM_Person_Account_Relation> relationships = new List<Core_IntegrationUtility.ERPM_Person_Account_Relation>();
        
        if(acct.personAccountRelations != null && acct.personAccountRelations.size() > 0) {
            for(Core_IntegrationUtility.ERPM_Person_Account_Relation ePAR: acct.personAccountRelations) {
                if((PRMEngagements !=null && PRMEngagements.size() > 0) && PRMEngagements.contains(ePAR.engagementCode)) {
                    relationships.add(ePAR);
                }
            }
            
            if(relationships.size() >0)
                acctIdRelationshipsMap.put(matchingAccountMap.get(acct.cimId).Id, relationships);
        }
        erpmAccounts.add(acct);
    }

    /*
    * description : Based on account Channel Membership Assign Subs And relationship.
    * params : Id sfAcctId, Id contactId, String eRPMChangeAgentId, Map<Id,List<Core_IntegrationUtility.ERPM_Person_Account_Relation>> acctIdRelationshipsMap
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    public static void IPA_SetRelationshipByChnlMembership(Id sfAcctId, Id contactId, String eRPMChangeAgentId, Map<Id,List<Core_IntegrationUtility.ERPM_Person_Account_Relation>> acctIdRelationshipsMap) {
        Set<String> partnerRoles = new Set<String>();
        for(ERPM_SF_MAPPING_SETTING__mdt mpr : [SELECT eRPM_KeyValue__c FROM ERPM_SF_MAPPING_SETTING__mdt WHERE Mappting_Type__c =: Label.PRM_Partner_Role AND eRPM_EngagementCodes__c IN: erpmAcctEnggCodes]) {
            partnerRoles.add(mpr.eRPM_KeyValue__c);
        }
        System.debug('### Partner Role'+partnerRoles);
        System.debug('### Partner Role SfActId '+sfAcctId);
        List<PRM_AccountChannelMembership__c> accountChannelMemberships = [SELECT Id FROM PRM_AccountChannelMembership__c
                                                                           WHERE PRM_Account_Id__c =: sfAcctId
                                                                           AND PRM_Partner_Role__c IN: partnerRoles
                                                                           AND PRM_Status_Nm__c =: Label.PRM_Engagement_Status_Approved];

        if(accountChannelMemberships != null && accountChannelMemberships.size() > 0) {
            if(enttlAssignFlag == true) {
                System.enqueueJob(new Core_Integration_Additional_Attributes(null, contactId, Label.PRM_IPAEngagement, null, null,null, null, eRPMChangeAgentId,erpmAccounts));      // Team ruby changes - added extra parameter erpmAccounts.
            } else {
                if((acctIdRelationshipsMap.size()>0) && string.isNotBlank(contactId) && (erpmAccounts != null && !erpmAccounts.IsEmpty()))// Team ruby changes - added extra parameter erpmAccounts.
                {
                    for(Id acctId : acctIdRelationshipsMap.keyset()) {
                        Id jobId = System.enqueueJob(new Core_Integration_Additional_Attributes(acctId, contactId, Label.PRM_IPAEngagement, null, acctIdRelationshipsMap.get(acctId),null, null, eRPMChangeAgentId,erpmAccounts));
                        
                        System.enqueueJob(new Core_Integration_Additional_Attributes(acctId, contactId, Label.PRM_IPAEngagement, null, null,null, acctIdRelationshipsMap.get(acctId), eRPMChangeAgentId,erpmAccounts)); // Team ruby changes - added extra parameter erpmAccounts.
                    }
                }
            }
        }
    }

    /*
    * description : Getting accountPartner for adding partner role.
    * params : Set<Id> allAccountIds, Map<String,String> eRPMSFMappingsByPartnerSpecs, Set<String> allPartnerSpecs
    * author : abhishekx.kushwaha@intel.com, chethan.s.kunder@intel.com
    */
    public static void IPA_getAccountPartner(Set<Id> allAccountIds, Map<String,String> eRPMSFMappingsByPartnerSpecs, Set<String> allPartnerSpecs){
        if(!allAccountIds.isEmpty()) {
            accountPartnerSpecsMap = new Map<Id,Account>([SELECT Core_IPA_Partner_Speciality__c FROM Account WHERE Id IN: allAccountIds]);
            system.debug('@#* AccountPartnerSpecMap'+accountPartnerSpecsMap);
            for(Id AccountId : accountPartnerSpecsMap.keySet()) {
                if(!String.isEmpty(accountPartnerSpecsMap.get(AccountId).Core_IPA_Partner_Speciality__c)) {
                    allPartnerSpecs.addAll(accountPartnerSpecsMap.get(AccountId).Core_IPA_Partner_Speciality__c.split(';'));
                }
            }
            if(allPartnerSpecs.size() > 0) {
                for(ERPM_SF_MAPPING_SETTING__mdt mdt : [SELECT eRPM_KeyValue__c,SF_KeyValue__c FROM ERPM_SF_MAPPING_SETTING__mdt
                                                        WHERE Mappting_Type__c =: Label.PRM_IPA_Partner_Specialty AND
                                                        SF_KeyValue__c IN: allPartnerSpecs]) {
                                                            eRPMSFMappingsByPartnerSpecs.put(mdt.SF_KeyValue__c, mdt.eRPM_KeyValue__c);
                                                        }
            }
        }
    }
}