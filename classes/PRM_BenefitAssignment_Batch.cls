public class PRM_BenefitAssignment_Batch implements Database.Batchable<SObject>, Database.Stateful {
    
    public String accountrecordId;
    public List<String> OnePartnerIDs = new List<String>();
    Set<PRM_AccountBenefitAssociation__c> allAbasToUpsert = new Set<PRM_AccountBenefitAssociation__c>();
    List<Core_Contact_Entitlement__c> allCEsToUpsert = new List<Core_Contact_Entitlement__c>();
    String csvData = 'Id,'+'PRM_Partner_Benefit_Id__c,'+'PRM_Partner_Benefit_Id__r.name,'+'PRM_Account_Id__c,'+'PRM_Status_Nm__c,'+'PRM_Source__c\n';
    String csvData2 = 'Id,'+'Core_Entitlement_Id__c,'+'Core_Entitlement_Id__r.name,'+'Core_Contact_Id__c,'+'Core_Selected__c,'+'Core_Status__c,'+'Core_Source__c,'+'Core_Entitlement_Type__c\n';
    public PRM_BenefitAssignment_Batch(String id,List<String> globalUnifiedIDs){
        this.accountrecordId = id;
        this.OnePartnerIDs = globalUnifiedIDs;
    }
    public List<Core_Log_Entry__c> errorLogs = new List<Core_Log_Entry__c>();
    public Database.QueryLocator start(Database.BatchableContext bc) {   
        String query;
        String opidRecType='Partner Account Group';
        query='SELECT Id, Core_IPA_One_Partner_Id__c,(SELECT Id, PRM_Partner_Role__c, PRM_Channel_Program_Level_Id__r.Name, PRM_Status_Nm__c FROM Channel_Memberships1__r WHERE PRM_Status_Nm__c=\'Approved\') FROM Account WHERE RecordType.Name = \'Partner Account Group\' AND Core_Deactivated__c = false and ID IN: OnePartnerIDs';
        return Database.getQueryLocator(query);
  }
  
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        List<PRM_VXBnftMatrix__c> benefitMatrixList = new List<PRM_VXBnftMatrix__c>();
        try {
        benefitMatrixList = [
                SELECT Id, PRM_BenfitMatrix_Combination__c, PRM_Channel_Program_Id__c, PRM_Covered_Account_Ind__c,
                    PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c, PRM_Partner_Benefit_Id__r.Name,
                    PRM_Approval_Type_Nm__c, PRM_Channel_Program_Level_Id__r.Name, PRM_Partner_Role_Nm__c,
                    PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c
                FROM PRM_VXBnftMatrix__c
                WHERE PRM_IsActive_Ind__c = true
                AND PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group'
                AND PRM_Partner_Benefit_Id__r.PRM_InActive_Ind__c = false  
                AND (PRM_Channel_Program_Level_Id__r.Name = 'Partner' OR PRM_Channel_Program_Level_Id__r.Name = 'Prestige')
            ]; // need to add filter for prestige and partner, Verify that Benefit matrix is loaded with new tier values-- Varun
        } catch (Exception ex) {
            System.debug('Exception 2- Failed to fetch Benefit Matrix: ' + ex.getMessage());
        }
        // Prepare Account -> ACM mapping
        Map<Id, List<PRM_AccountChannelMembership__c>> accountIdAcmMap = new Map<Id, List<PRM_AccountChannelMembership__c>>();
        Set<Id> accIds = new Set<Id>();
        Map<Id, String> accChMemMap = new Map<Id, String>();

        Map<Id, String> actIdRoleTierMap = new Map<Id, String>(); 
        Map<Id,Id> actToOPIDMap = new Map<Id,Id>();

        for (Account acc : scope) {
            if (acc.Channel_Memberships1__r != null && acc.Channel_Memberships1__r.size() > 0) {
                accIds.add(acc.Id);
                accountIdAcmMap.put(acc.Id, acc.Channel_Memberships1__r);
            }
        }

        Set<Id> IntelAccs = new Set<Id>();
        for(Core_Account_Group_Member__c cag : [SELECT id,Core_Intel_Account_Id__c,Core_Partner_Account_Id__c FROM Core_Account_Group_Member__c WHERE Core_Inactive_Ind__c = false AND Core_Partner_Account_Id__c IN: accIds]){
            IntelAccs.add(cag.Core_Intel_Account_Id__c);
        }

        for(Account intelacc : [SELECT Id, Core_IPA_One_Partner_Id__c,(SELECT Id, PRM_Partner_Role__c, PRM_Channel_Program_Level_Id__r.Name, PRM_Status_Nm__c FROM Channel_Memberships1__r WHERE PRM_Status_Nm__c='Approved') FROM Account WHERE RecordType.Name = 'Intel Account' AND Core_Deactivated__c = false and ID IN: IntelAccs]){
            //For ent wrapper
                PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
                acm = intelacc.Channel_Memberships1__r;

                accChMemMap.put(intelacc.id,acm.PRM_Partner_Role__c);
                actIdRoleTierMap.put(intelacc.Id, acm.PRM_Partner_Role__c+'-'+acm.PRM_Channel_Program_Level_Id__c);
                actToOPIDMap.put(intelacc.Id,intelacc.Core_IPA_One_Partner_Id__c);
        }

        // Fetch existing ABA records
        Map<String, Set<PRM_AccountBenefitAssociation__c>> accBenMap = new Map<String, Set<PRM_AccountBenefitAssociation__c>>();
        try {
            for (PRM_AccountBenefitAssociation__c aba : [
                SELECT Id, Name, PRM_Status_Nm__c, PRM_Account_Id__c, PRM_Partner_Benefit_Id__c,PRM_Source__c,
                    PRM_Partner_Benefit_Id__r.Name
                FROM PRM_AccountBenefitAssociation__c
                WHERE PRM_Account_Id__c IN :accIds
            ]) {
                if (!accBenMap.containsKey(aba.PRM_Account_Id__c))
                {
                    accBenMap.put(aba.PRM_Account_Id__c, new Set<PRM_AccountBenefitAssociation__c>());
                }
                accBenMap.get(aba.PRM_Account_Id__c).add(aba);
            }
        } catch (Exception ex) {
            System.debug('Exception3-- Failed to fetch ABA records: ' + ex.getMessage());
        }

        // Process Matrix
        Map<String, Set<String>> roleTierBenefitMap = new Map<String, Set<String>>();
        Map<String, Set<String>> manualBenefitMap = new Map<String, Set<String>>();

        for (PRM_VXBnftMatrix__c vx : benefitMatrixList) {
            String key = vx.PRM_Channel_Program_Level_Id__r.Name + ':' + vx.PRM_Partner_Role_Nm__c;
            if (vx.PRM_Approval_Type_Nm__c == 'Automatic') {
                if (!roleTierBenefitMap.containsKey(key)) {
                    roleTierBenefitMap.put(key, new Set<String>());
                }
                if (!roleTierBenefitMap.get(key).contains(vx.PRM_Partner_Benefit_Id__c)) {
                    roleTierBenefitMap.get(key).add(vx.PRM_Partner_Benefit_Id__c);
                }
            } else { 
                if (!manualBenefitMap.containsKey(key)) {
                    manualBenefitMap.put(key, new Set<String>());
                }
                manualBenefitMap.get(key).add(vx.PRM_Partner_Benefit_Id__c);
            }
        } 

        // Build account benefit map
        Map<Id, Set<String>> accountBenefitMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> accountManualBenefitMap = new Map<Id, Set<String>>();

        for (Id accId : accIds) {
            List<PRM_AccountChannelMembership__c> acmSet = accountIdAcmMap.get(accId);

            for (PRM_AccountChannelMembership__c acm : acmSet) {
                Set<String> keys = new Set<String>();
                String key1 = 'Partner:' + acm.PRM_Partner_Role__c;

                if (acm.PRM_Channel_Program_Level_Id__r.Name == 'Prestige') {
                    String Key = 'Prestige' + ':' + acm.PRM_Partner_Role__c;
                    keys.add(Key);
                    keys.add(key1);
                } else {
                    keys.add(key1);
                }
                System.debug('keys--' + keys);

                for (String applicableTier : keys) {
                    // Add automatic (tier) benefits
                    if (roleTierBenefitMap.containsKey(applicableTier)) {
                        if (!accountBenefitMap.containsKey(accId)) {
                            accountBenefitMap.put(accId, roleTierBenefitMap.get(applicableTier));
                        }
                        accountBenefitMap.get(accId).addAll(roleTierBenefitMap.get(applicableTier));
                    }

                    // Add manual benefits
                    if (manualBenefitMap.containsKey(applicableTier)) {
                        if (!accountManualBenefitMap.containsKey(accId)) {
                            accountManualBenefitMap.put(accId, manualBenefitMap.get(applicableTier));
                        }
                        accountManualBenefitMap.get(accId).addAll(manualBenefitMap.get(applicableTier));
                    }
                }
            }
        }

        // Prepare benefit records to upsert
        Set<PRM_AccountBenefitAssociation__c> abaToUpdate = new Set<PRM_AccountBenefitAssociation__c>();
        Map<Id, Set<PRM_AccountBenefitAssociation__c>> accountWiseABAs = new Map<Id, Set<PRM_AccountBenefitAssociation__c>>();

        for (Id accId : accountBenefitMap.keySet()) {
            Set<String> currentBenefits = accountBenefitMap.get(accId);
            Set<String> manualBenefits = accountManualBenefitMap.containsKey(accId)
                ? accountManualBenefitMap.get(accId)
                : new Set<String>();
            Set<PRM_AccountBenefitAssociation__c> existingAbas = accBenMap.containsKey(accId)
                ? accBenMap.get(accId)
                : new Set<PRM_AccountBenefitAssociation__c>();

            Set<String> existingBenefitIds = new Set<String>();
            Set<String> addedBenefitIds = new Set<String>();

            System.debug('Current benefits----->'+currentBenefits);
            System.debug('manualBenefits benefits----->'+manualBenefits);
            System.debug('existingAbas benefits----->'+existingAbas);

            for (PRM_AccountBenefitAssociation__c aba : existingAbas) {
                existingBenefitIds.add(aba.PRM_Partner_Benefit_Id__c);

                if (currentBenefits.contains(aba.PRM_Partner_Benefit_Id__c) && aba.PRM_Status_Nm__c == 'Inactive'  && !addedBenefitIds.contains(aba.PRM_Partner_Benefit_Id__c)) {
                    aba.PRM_Status_Nm__c = 'Active';
                    aba.PRM_Status_Reason_Txt__c = 'Activated as part of IPA Refresh';
                    abaToUpdate.add(aba);
                    addedBenefitIds.add(aba.PRM_Partner_Benefit_Id__c);
                } else if (!currentBenefits.contains(aba.PRM_Partner_Benefit_Id__c) &&
                        !manualBenefits.contains(aba.PRM_Partner_Benefit_Id__c) && aba.PRM_Status_Nm__c == 'Active') {
                    aba.PRM_Status_Nm__c = 'Inactive';
                    aba.PRM_Status_Reason_Txt__c = 'Inactivated as part of IPA Refresh';
                    abaToUpdate.add(aba);
                }
            }

            System.debug('abaToUpdate benefits----->'+abaToUpdate);
            System.debug('addedBenefitIds benefits----->'+addedBenefitIds);
            System.debug('existingBenefitIds ----->'+existingBenefitIds);


            //Set<String> addedBenefitIds = new Set<String>();
            for (String benefitId : currentBenefits) {
                if (!existingBenefitIds.contains(benefitId) && !addedBenefitIds.contains(benefitId)) {
                    PRM_AccountBenefitAssociation__c newAba = new PRM_AccountBenefitAssociation__c();
                    newAba.PRM_Account_Id__c = accId;
                    newAba.PRM_Partner_Benefit_Id__c = benefitId;
                    newAba.PRM_Status_Nm__c = 'Active';
                    newAba.PRM_Source__c = 'Tier';
                    newAba.PRM_Status_Reason_Txt__c = 'Inserted & activated as part of IPA Refresh';
                    abaToUpdate.add(newAba);
                    addedBenefitIds.add(benefitId);
                    System.debug('Inside adding block - benefitId: ' + benefitId);
                }
            }

            System.debug('abaToUpdate --> ' + abaToUpdate);
            System.debug('abaToUpdate size --> ' + abaToUpdate.size());

            accountWiseABAs.put(accId, new Set<PRM_AccountBenefitAssociation__c>(abaToUpdate));
            System.debug('accountWiseABAs final Set inside --- ' + accountWiseABAs);
        }
        System.debug('accountWiseABAs final Set outside --- ' + accountWiseABAs);

        Map<Id, Set<String>> accIdToMessages = new Map<Id, Set<String>>();

        // Flatten for upsert
        for (Set<PRM_AccountBenefitAssociation__c> abas : accountWiseABAs.values()) {
            allAbasToUpsert.addAll(abas);
        }

        System.debug('Just before insertion--Account Benefits-----abastoupsert>>'+allAbasToUpsert);


        //--------------------------------------------Entitlement records retrieval code-------------------------------------------------

        Map<Id, String> tierIdNames = new Map<Id, String>();
        for(ChannelProgramLevel record : [SELECT Id, Name FROM ChannelProgramLevel WHERE Program.PRM_programCode__c = 'IPA']) {
            tierIdNames.put(record.Id, record.Name);
        }

        Map<Id, Set<Id>> actIdCtIdMap = new Map<Id, Set<Id>>();
            Map<Id,List<String>> newPartnerRoleMap = new Map<Id, List<String>>();
            Map<Id, String> contactIdRelName = new Map<id, String>(); 
            for(PRM_Account_Contact_Relationship__c acrRec : [SELECT id,PRM_Relationship_Id__r.name,PRM_Account_Id__r.Core_IPA_Partner_Segment__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c, PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Contact_Id__c, PRM_Contact_Id__r.Core_IPA_PartnerRole__c , PRM_Partner_Role__c,PRM_Account_Id__c,PRM_Contact_Id__r.Core_IPA_Contact_Segment__c FROM PRM_Account_Contact_Relationship__c WHERE PRM_Account_Id__c in: accChMemMap.keySet() AND PRM_Account_Id__r.RecordType.DeveloperName =:  Label.PRM_Intel_Account AND PRM_InActive_Ind__c=false AND PRM_Status_Nm__c='Complete' AND  PRM_Partner_Role__c in: accChMemMap.values()]){
                    if(accChMemMap.get(acrRec.PRM_Account_Id__c) == acrRec.PRM_Partner_Role__c)
                    {
                        if(actIdCtIdMap!=null && !actIdCtIdMap.isEmpty() &&actIdCtIdMap.containsKey(acrRec.PRM_Account_Id__c)){
                          actIdCtIdMap.get(acrRec.PRM_Account_Id__c).add(acrRec.PRM_Contact_Id__c);
                        }else{
                            actIdCtIdMap.put(acrRec.PRM_Account_Id__c, new Set<id>{acrRec.PRM_Contact_Id__c});
                        }
                    
                      if(contactIdRelName!=null && !contactIdRelName.isEMpty() && contactIdRelName.containsKey(acrRec.PRM_Contact_Id__c)){
                            String str = contactIdRelName.get(acrRec.PRM_Contact_Id__c);
                            str+=acrRec.PRM_Relationship_Id__r.name;
                            contactIdRelName.put(acrRec.PRM_Contact_Id__c, str);
                        }else{
                            contactIdRelName.put(acrRec.PRM_Contact_Id__c, acrRec.PRM_Relationship_Id__r.name + '-');
                        }
                    }
                }


        PRM_EntitlementResponseWrapper entWrap = new PRM_EntitlementResponseWrapper();
        //entWrap.accountIdRecTypemap = accountIdRecTypemap;
        entWrap.actIdCtIdMap = actIdCtIdMap;
        entWrap.actIdRoleTierMap = actIdRoleTierMap;
        entWrap.contactIdRelName = contactIdRelName;
        entWrap.tierIdNames = tierIdNames;
        entWrap.actToOPIDMap = actToOPIDMap;
        entWrap.newPartnerRoleMap = newPartnerRoleMap;

        PRM_IPAR_ACMUpdateAssignEntitlment assignEnt = new PRM_IPAR_ACMUpdateAssignEntitlment();
        allCEsToUpsert = assignEnt.AssignEntitlements(entWrap);

        System.debug('Just before insertion--Contact entitlements-----allCEsToUpsert>>'+allCEsToUpsert);

    }
    public void finish(Database.BatchableContext bc){

        if(allAbasToUpsert!=null && !allAbasToUpsert.isEmpty()){
            for(PRM_AccountBenefitAssociation__c aba:allAbasToUpsert){
                //'Id,'+'PRM_Partner_Benefit_Id__c,'+'PRM_Partner_Benefit_Id__r.name,'+'PRM_Account_Id__c,'+'PRM_Status_Nm__c,'+'PRM_Source__c\n';
                csvData += aba.Id+','+aba.PRM_Partner_Benefit_Id__c+','+aba.PRM_Partner_Benefit_Id__r.name+','+aba.PRM_Account_Id__c+','+aba.PRM_Status_Nm__c+','+aba.PRM_Source__c+'\n';
            }
        }


        List<Attachment> listOfAttachment = new List<Attachment>();

        Blob csvBlob = Blob.valueOf(csvData);
        Attachment attachment = new Attachment();
        attachment.Name = 'BenefitAssc.csv';
        attachment.Body = csvBlob;
        attachment.ParentId = accountrecordId;
        listOfAttachment.add(attachment);

        //entitlement attachment
        if(allCEsToUpsert!=null && !allCEsToUpsert.isEmpty()){
            for(Core_Contact_Entitlement__c ce:allCEsToUpsert){
                //'Id,'+'Core_Entitlement_Id__c,'+'Core_Entitlement_Id__r.name,'+'Core_Contact_Id__c,'+'Core_Selected__c,'+'Core_Status__c,'+'Core_Source__c,'+'Core_Entitlement_Type__c,'+'\n';
                csvData2 += ce.Id+','+ce.Core_Entitlement_Id__c+','+ce.Core_Entitlement_Id__r.name+','+ce.Core_Contact_Id__c+','+ce.Core_Selected__c+','+ce.Core_Status__c+','+ce.Core_Source__c+','+ce.Core_Entitlement_Type__c+'\n';
            }
        }

        Blob csvBlob2 = Blob.valueOf(csvData2);
        Attachment attachment2 = new Attachment();
        attachment2.Name = 'ContactEntitlement.csv';
        attachment2.Body = csvBlob2;
        attachment2.ParentId = accountrecordId;
        listOfAttachment.add(attachment2);

        if(!Test.isRunningTest()){
            insert listOfAttachment;
        }

    }
}