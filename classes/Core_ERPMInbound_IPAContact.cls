/******************************************************************************************************************************************
Class Name  : Core_ERPMInbound_IPAContact
This class contains the deprecated code from the Core_IntInboundMsgERPM_Contact Class.
As Core_IntInboundMsgERPM_Contact Class having a label STOP_ERPM_SLSCLD_IPA_INTEG has true value, it wont excute below logics
***********************************************************************************************************************/

public without sharing class Core_ERPMInbound_IPAContact {
    public static void IPA_AddPartnerRole(Contact newc, Set<String> erpmAcctEnggCodes, Set<Id> allAccountIds) {
        List<String> acctBenefits = new List<String>();
        Map<Id,Account> accountPartnerSpecsMap = new Map<Id,Account>();
        Map<String,String> eRPMSFMappingsByPartnerSpecs = new Map<String,String>();
        Set<String> allPartnerSpecs = new Set<String>();
        IPA_getAccountPartner(allAccountIds,accountPartnerSpecsMap,eRPMSFMappingsByPartnerSpecs,allPartnerSpecs);
        String partnerSpeciality = accountPartnerSpecsMap.containsKey(newc.AccountId) ? accountPartnerSpecsMap.get(newc.AccountId).Core_IPA_Partner_Speciality__c : null;
        List<String> partnerRoles = new List<String>();
        map<string, List<string> > customSettingmap = new map<string, List<string> >();
        
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
    public static void IPA_Subscription(Core_IntegrationUtility.ERPM_Person person, Map<String,Account> matchingAccountMap, Map<Id,List<Core_IntegrationUtility.ERPM_Person_Account_Relation>> acctIdRelationshipsMap,
                                        List<Core_IntegrationUtility.ERPM_Person_Account> erpmAccounts, List<String> PRMEngagements) {
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
                                                                if(!acctIdRelationshipsMap.ContainsKey(matchingAccountMap.get(acct.cimId).Id))
                                                                    acctIdRelationshipsMap.put(matchingAccountMap.get(acct.cimId).Id, relationships);
                                                                else
                                                                    acctIdRelationshipsMap.get(matchingAccountMap.get(acct.cimId).Id).addAll(relationships);
                                                            }
                                                        }
                                                        erpmAccounts.add(acct);
                                                    }
                                                }
                                            }
                                        }
    public static void IPA_AddPartnerRole(Contact newc, Set<String> erpmAcctEnggCodes, Id sfAccountId, Set<Id> allAccountIds) {
        List<String> acctBenefits = new List<String>();
        Map<Id,Account> accountPartnerSpecsMap = new Map<Id,Account>();
        Map<String,String> eRPMSFMappingsByPartnerSpecs = new Map<String,String>();
        Set<String> allPartnerSpecs = new Set<String>();
        IPA_getAccountPartner(allAccountIds,accountPartnerSpecsMap,eRPMSFMappingsByPartnerSpecs,allPartnerSpecs);
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
        map<string, List<string> > customSettingmap = new map<string, List<string> >();
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
            if(partnerRoles.size() >0)
                newc.Core_IPA_PartnerRole__c = Core_IntegrationUtility.formatMultiSelectPicklist(new List<String>(new Set<String>(partnerRoles)));
            
        }
        
    }
    public static void IPA_AddAcctRelationships(Core_IntegrationUtility.ERPM_Person_Account acct, List<String> PRMEngagements, Map<Id,List<Core_IntegrationUtility.ERPM_Person_Account_Relation>> acctIdRelationshipsMap, Map<String,Account> matchingAccountMap, List<Core_IntegrationUtility.ERPM_Person_Account> erpmAccounts, Set<String> erpmAcctEnggCodes){
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
    public static void IPA_SetRelationshipByChnlMembership(Id sfAcctId, Boolean enttlAssignFlag, Id contactId, String eRPMChangeAgentId, List<Core_IntegrationUtility.ERPM_Person_Account> erpmAccounts, Map<Id,List<Core_IntegrationUtility.ERPM_Person_Account_Relation>> acctIdRelationshipsMap, Set<String> erpmAcctEnggCodes) {
        Set<String> partnerRoles = new Set<String>();
        for(ERPM_SF_MAPPING_SETTING__mdt mpr : [SELECT eRPM_KeyValue__c FROM ERPM_SF_MAPPING_SETTING__mdt WHERE Mappting_Type__c =: Label.PRM_Partner_Role AND eRPM_EngagementCodes__c IN: erpmAcctEnggCodes]) {
            partnerRoles.add(mpr.eRPM_KeyValue__c);
        }
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
    public static void IPA_UpdateMailingCountry(List<String> IPAEnggsForAddress, Contact newc, Core_IntegrationUtility.ERPM_Person person){
        for(String engg : IPAEnggsForAddress)
        {
            if(Label.IPAEnggsForMailingAddress.split(',').Contains(engg))
            {
                newc.MailingCountry = person.mailingCountry;
            }
        }
    } 
    public static void IPA_getAccountPartner(Set<Id> allAccountIds, Map<Id,Account> accountPartnerSpecsMap, Map<String,String> eRPMSFMappingsByPartnerSpecs, Set<String> allPartnerSpecs){
        if(!allAccountIds.isEmpty()) {
            accountPartnerSpecsMap = new Map<Id,Account>([SELECT Core_IPA_Partner_Speciality__c FROM Account WHERE Id IN: allAccountIds]);
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