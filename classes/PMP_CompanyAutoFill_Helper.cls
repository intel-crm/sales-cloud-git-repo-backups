public class PMP_CompanyAutoFill_Helper {
 
    public static void publishStagedCompanies(List<PMP_CompanyAutoFill__c> stagedCompanies) {
        if (stagedCompanies == null || stagedCompanies.isEmpty()) {
            return;
        }
    
        /* ---------- Collect Partner Ids ---------- */
        Set<Id> partnerIds = new Set<Id>();
        for (PMP_CompanyAutoFill__c sc : stagedCompanies) {
            if (sc.PMP_Partner_Id__c != null && sc.PMP_Website__c != null) {
                partnerIds.add(sc.PMP_Partner_Id__c);
            }
        }
        if (partnerIds.isEmpty()) return;
    
        /* ---------- Query Company Names ---------- */
        Map<Id, String> companyNameById = new Map<Id, String>();
        for (PMP_Company__c c : [
            SELECT Id, Name
            FROM PMP_Company__c
            WHERE Id IN :partnerIds
        ]) {
            companyNameById.put(c.Id, c.Name);
        }
    
        /* ---------- Build Platform Events ---------- */
        List<sf_scraping_request__e> eventsToPublish =
            new List<sf_scraping_request__e>();
    
        for (PMP_CompanyAutoFill__c sc : stagedCompanies) {
            if (sc.PMP_Website__c == null || sc.PMP_Partner_Id__c == null) {
                continue;
            }
    
            String companyName = companyNameById.get(sc.PMP_Partner_Id__c);
            if (String.isBlank(companyName)) continue;
    
            eventsToPublish.add(new sf_scraping_request__e(
                Stage_Object_Id__c  = sc.Id,
                Company_Name__c     = companyName,
                Company_Website__c  = sc.PMP_Website__c
            ));
        }
    
        if (eventsToPublish.isEmpty()) {
            return;
        }
    
        System.debug(
            LoggingLevel.ERROR,
            'Publishing Event Payload: ' + JSON.serialize(eventsToPublish)
        );
    
        /* ---------- Publish Events with Error Logging ---------- */
        Database.SaveResult[] res = EventBus.publish(eventsToPublish);
        PMP_Utility.logDmlErrors(
            (Object[]) res,
            'PMP_CompanyAutoFill_Helper-publishStagedCompanies'
        );
    }
    
    public static void processStagingRecords(List<PMP_CompanyAutoFill__c> newList,Map<Id, PMP_CompanyAutoFill__c> oldMap) {
        if (newList == null || newList.isEmpty()) return;

        /* ---------- Allowed Autofill Status Transitions ---------- */
        Set<String> allowedOldStatuses = new Set<String>{ 'Staged', 'In Progress' };
        Set<String> allowedNewStatuses = new Set<String>{ 'Scraped', 'Mixed', 'LLM_Knowledge' };

        Map<Id, PMP_CompanyAutoFill__c> partnerToStageMap = new Map<Id, PMP_CompanyAutoFill__c>();
        Set<Id> partnerIds = new Set<Id>();

        for (PMP_CompanyAutoFill__c s : newList) {
            if (s.PMP_Partner_Id__c == null) continue;

            PMP_CompanyAutoFill__c oldRec = oldMap.get(s.Id);
            if (oldRec == null) continue;

            if (oldRec.PMP_Autofill_Status__c == s.PMP_Autofill_Status__c) continue;
            if (!allowedOldStatuses.contains(oldRec.PMP_Autofill_Status__c)) continue;
            if (!allowedNewStatuses.contains(s.PMP_Autofill_Status__c)) continue;

            partnerIds.add(s.PMP_Partner_Id__c);
            partnerToStageMap.put(s.PMP_Partner_Id__c, s);
        }

        if (partnerIds.isEmpty()) return;

        /* ---------- Draft Company Filter ---------- */
        Set<Id> draftPartnerIds = new Set<Id>();
        for (PMP_Company__c c : [
            SELECT Id
            FROM PMP_Company__c
            WHERE Id IN :partnerIds
              AND PMP_Company_Lifecycle_Status_Nm__c = 'Draft'
        ]) {
            draftPartnerIds.add(c.Id);
        }

        if (draftPartnerIds.isEmpty()) return;

        /* ---------- Build Region & Category Maps ---------- */
        Map<Id, List<String>> partnerRegionsMap      = new Map<Id, List<String>>();
        Map<Id, List<String>> partnerIndustriesMap   = new Map<Id, List<String>>();
        Map<Id, List<String>> partnerApplicationsMap = new Map<Id, List<String>>();

        for (Id pid : draftPartnerIds) {
            PMP_CompanyAutoFill__c s = partnerToStageMap.get(pid);
            if (s == null) continue;

            partnerRegionsMap.put(pid,
                s.PMP_Regions__c != null ? s.PMP_Regions__c.split(';') : new List<String>());

            partnerIndustriesMap.put(pid,
                s.PMP_Industries__c != null ? s.PMP_Industries__c.split(';') : new List<String>());

            partnerApplicationsMap.put(pid,
                s.PMP_Applications__c != null ? s.PMP_Applications__c.split(';') : new List<String>());
        }

        //SAVE REGIONS
        saveRegionsBulk(partnerRegionsMap);
        
        //SAVE PARTNER CATEGORIES
        savePartnerCategoriesBulk(partnerIndustriesMap, PMP_StaticConstants_Partner.PIM_INDUSTRY_ID);
        savePartnerCategoriesBulk(partnerApplicationsMap, PMP_StaticConstants_Partner.PIM_APPLICATION_ID);       
        
		//UPDATE COMPANY
        updateCompanyFromStage(draftPartnerIds, partnerToStageMap);
        
        //SYNC TRANSLATIONS
        syncCompanyTranslationsFromStage(draftPartnerIds, partnerToStageMap);
    }
   
    //UPDATE COMPANY
    private static void updateCompanyFromStage(Set<Id> partnerIds,Map<Id, PMP_CompanyAutoFill__c> partnerToStageMap) {
        List<PMP_Company__c> toUpdate = new List<PMP_Company__c>();

        for (Id pid : partnerIds) {
            PMP_CompanyAutoFill__c s = partnerToStageMap.get(pid);
            if (s == null) continue;

            PMP_Company__c c = new PMP_Company__c(Id = pid);
            Boolean hasUpdate = false;

            if (String.isNotBlank(s.PMP_Tagline__c)) {
                c.PMP_Account_Tag_Line__c = s.PMP_Tagline__c;
                hasUpdate = true;
            }
            if (String.isNotBlank(s.PMP_Description__c)) {
                c.PMP_Account_Dsc__c = s.PMP_Description__c;
                hasUpdate = true;
            }

            c.PMP_Autofill_Txt__c = s.PMP_Autofill_Status__c;
            hasUpdate = true;

            if (hasUpdate) toUpdate.add(c);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] res = Database.update(toUpdate, false);
            PMP_Utility.logDmlErrors((Object[]) res, 'PMP_CompanyAutoFill_Helper-updateCompany');
        }
    }
	 
    //SYNC TRANSLATIONS
    private static void syncCompanyTranslationsFromStage(Set<Id> partnerIds,Map<Id, PMP_CompanyAutoFill__c> partnerToStageMap) {
        Map<String, PMP_Company_Translation__c> existingMap = new Map<String, PMP_Company_Translation__c>();

        for (PMP_Company_Translation__c tr : [
            SELECT Id, PMP_Company_Information_Id__c, PMP_Field_Nm__c
            FROM PMP_Company_Translation__c
            WHERE PMP_Company_Information_Id__c IN :partnerIds
              AND PMP_Field_Nm__c IN ('PMP_Account_Tag_Line__c', 'PMP_Account_Dsc__c')
        ]) {
            existingMap.put(tr.PMP_Company_Information_Id__c + '|' + tr.PMP_Field_Nm__c, tr);
        }

        List<PMP_Company_Translation__c> toInsert = new List<PMP_Company_Translation__c>();
        List<PMP_Company_Translation__c> toUpdate = new List<PMP_Company_Translation__c>();

        for (Id pid : partnerIds) {
            PMP_CompanyAutoFill__c s = partnerToStageMap.get(pid);
            if (s == null) continue;

            if (String.isNotBlank(s.PMP_Tagline__c)) {
                String key = pid + '|PMP_Account_Tag_Line__c';
                if (existingMap.containsKey(key)) {
                    existingMap.get(key).PMP_English_Txt__c = s.PMP_Tagline__c;
                    toUpdate.add(existingMap.get(key));
                } else {
                    toInsert.add(new PMP_Company_Translation__c(
                        PMP_Company_Information_Id__c = pid,
                        PMP_Field_Nm__c = 'PMP_Account_Tag_Line__c',
                        PMP_English_Txt__c = s.PMP_Tagline__c
                    ));
                }
            }

            if (String.isNotBlank(s.PMP_Description__c)) {
                String key = pid + '|PMP_Account_Dsc__c';
                if (existingMap.containsKey(key)) {
                    existingMap.get(key).PMP_English_Txt__c = s.PMP_Description__c;
                    toUpdate.add(existingMap.get(key));
                } else {
                    toInsert.add(new PMP_Company_Translation__c(
                        PMP_Company_Information_Id__c = pid,
                        PMP_Field_Nm__c = 'PMP_Account_Dsc__c',
                        PMP_English_Txt__c = s.PMP_Description__c
                    ));
                }
            }
        }

        if (!toInsert.isEmpty()) {
            Database.SaveResult[] res = Database.insert(toInsert, false);
            PMP_Utility.logDmlErrors((Object[]) res, 'PMP_CompanyAutoFill_Helper-insertTranslations');
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] res = Database.update(toUpdate, false);
            PMP_Utility.logDmlErrors((Object[]) res, 'PMP_CompanyAutoFill_Helper-updateTranslations');
        }
    }

    //SAVE REGIONS
    public static void saveRegionsBulk(Map<Id, List<String>> partnerRegionsMap) {
        if (partnerRegionsMap == null || partnerRegionsMap.isEmpty()) return;

        Set<String> allNames = new Set<String>();
        for (List<String> names : partnerRegionsMap.values()) allNames.addAll(names);
        if (allNames.isEmpty()) return;

        Map<String, PMP_Specification__c> parentSpecMap = new Map<String, PMP_Specification__c>();
        for (PMP_Specification__c s : [
            SELECT Id, Name
            FROM PMP_Specification__c
            WHERE PMP_Ancestor_Specification_Cd__c LIKE '%NPP_GeographicCoverage%'
              AND PMP_Active_Ind__c = TRUE
              AND Name IN :allNames
        ]) parentSpecMap.put(s.Name, s);

        Map<String, PMP_Specification_Value__c> childSpecMap = new Map<String, PMP_Specification_Value__c>();
        for (PMP_Specification_Value__c v : [
            SELECT Id, Name
            FROM PMP_Specification_Value__c
            WHERE PMP_Active_Ind__c = TRUE
              AND Name IN :allNames
        ]) childSpecMap.put(v.Name, v);

        List<PMP_Company_Region__c> toInsert = new List<PMP_Company_Region__c>();

        for (Id pid : partnerRegionsMap.keySet()) {
            for (String name : partnerRegionsMap.get(pid)) {
        
                //  Insert Spec Value record (if exists)
                if (childSpecMap.containsKey(name)) {
                    Id specValueId = childSpecMap.get(name).Id;
                    if (specValueId != null) {
                        toInsert.add(new PMP_Company_Region__c(
                            PMP_Company_Id__c = pid,
                            PMP_Specification_Value__c = specValueId
                        ));
                    }
                }
        
                //  Insert Parent Spec record (if exists)
                if (parentSpecMap.containsKey(name)) {
                    Id specId = parentSpecMap.get(name).Id;
                    if (specId != null) {
                        toInsert.add(new PMP_Company_Region__c(
                            PMP_Company_Id__c = pid,
                            PMP_Specification_Id__c = specId
                        ));
                    }
                }
            }
        }

        if (!toInsert.isEmpty()) {
            Database.SaveResult[] res = Database.insert(toInsert, false);
            PMP_Utility.logDmlErrors((Object[]) res, 'PMP_CompanyAutoFill_Helper-saveRegionsBulk');
        }
    }

    //SAVE PARTNER CATEGORIES
    public static void savePartnerCategoriesBulk(Map<Id, List<String>> partnerCategoriesMap,String pimIdPrefix) {
        if (partnerCategoriesMap == null || partnerCategoriesMap.isEmpty()) return;

        Set<String> allNames = new Set<String>();
        for (List<String> names : partnerCategoriesMap.values()) allNames.addAll(names);
        if (allNames.isEmpty()) return;

        Map<String, Id> categoryIdByName = new Map<String, Id>();
        for (PMP_Category__c c : [
            SELECT Id, Name
            FROM PMP_Category__c
            WHERE PMP_Ancestor_Category_Cd__c LIKE :pimIdPrefix + '%'
              AND PMP_Active_Ind__c = TRUE
              AND Name IN :allNames
        ]) categoryIdByName.put(c.Name, c.Id);

        List<PMP_Partner_Category__c> toInsert = new List<PMP_Partner_Category__c>();

        for (Id pid : partnerCategoriesMap.keySet()) {
            for (String name : partnerCategoriesMap.get(pid)) {
                Id catId = categoryIdByName.get(name);
                if (catId == null) continue;

                toInsert.add(new PMP_Partner_Category__c(
                    PMP_Partner_Id__c = pid,
                    PMP_Category_Id__c = catId
                ));
            }
        }

        if (!toInsert.isEmpty()) {
            Database.SaveResult[] res = Database.insert(toInsert, false);
            PMP_Utility.logDmlErrors((Object[]) res, 'PMP_CompanyAutoFill_Helper-savePartnerCategoriesBulk');
        }
    }
}