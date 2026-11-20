public class PMP_CompanyAutoFill_Helper {
    
    private static final String LOGO_KEY = 'logo_document_id';
 
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
        Map<Id, Id> partnerLogoDocMap = new Map<Id, Id>();

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
        
        //SYNC RESOURCES
        syncCompanyResourcesFromStage(draftPartnerIds,partnerToStageMap);
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
    /*public static void saveRegionsBulk(Map<Id, List<String>> partnerRegionsMap) {
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
    }*/
    public static void saveRegionsBulk(Map<Id, List<String>> partnerRegionsMap) {
    
        if (partnerRegionsMap == null || partnerRegionsMap.isEmpty()) return;
    
        // -------------------------------
        // STEP 1: Collect Names
        // -------------------------------
        Set<String> allNames = new Set<String>();
        for (List<String> names : partnerRegionsMap.values()) {
            allNames.addAll(names);
        }
        if (allNames.isEmpty()) return;
    
        // -------------------------------
        // STEP 2: Query Spec VALUES
        // -------------------------------
        Map<String, PMP_Specification_Value__c> valByName = new Map<String, PMP_Specification_Value__c>();
    
        for (PMP_Specification_Value__c v : [
            SELECT Id, Name, PMP_Specification_Product_Cd__c
            FROM PMP_Specification_Value__c
            WHERE PMP_Active_Ind__c = TRUE
            AND Name IN :allNames
        ]) {
            valByName.put(v.Name, v);
        }
    
        // -------------------------------
        // STEP 3: Query Specifications (only relevant tree)
        // -------------------------------
        Map<String, PMP_Specification__c> specByName = new Map<String, PMP_Specification__c>();
        Map<String, PMP_Specification__c> specByCode = new Map<String, PMP_Specification__c>();
    
        for (PMP_Specification__c s : [
            SELECT Id, Name,
                   PMP_Partner_Product_Specification_Id__c,
                   PMP_Product_Parent_Specification_Id__c
            FROM PMP_Specification__c
            WHERE PMP_Active_Ind__c = TRUE
            AND PMP_Ancestor_Specification_Cd__c LIKE '%NPP_GeographicCoverage%'
        ]) {
            if (s.Name != null) {
                specByName.put(s.Name, s);
            }
    
            if (s.PMP_Partner_Product_Specification_Id__c != null) {
                specByCode.put(s.PMP_Partner_Product_Specification_Id__c, s);
            }
        }
    
        // -------------------------------
        // STEP 4: Existing Records 
        // -------------------------------
        Set<Id> companyIds = partnerRegionsMap.keySet();
        Set<String> existingKeys = new Set<String>();
    
        for (PMP_Company_Region__c rec : [
            SELECT PMP_Company_Id__c,
                   PMP_Specification_Id__c,
                   PMP_Specification_Value__c
            FROM PMP_Company_Region__c
            WHERE PMP_Company_Id__c IN :companyIds
        ]) {
            if (rec.PMP_Specification_Id__c != null) {
                existingKeys.add(rec.PMP_Company_Id__c + '-S-' + rec.PMP_Specification_Id__c);
            }
            if (rec.PMP_Specification_Value__c != null) {
                existingKeys.add(rec.PMP_Company_Id__c + '-V-' + rec.PMP_Specification_Value__c);
            }
        }
    
        // -------------------------------
        // STEP 5: Prepare Inserts
        // -------------------------------
        List<PMP_Company_Region__c> toInsert = new List<PMP_Company_Region__c>();
        Set<String> uniqueKeys = new Set<String>();
    
        // -------------------------------
        // STEP 6: PROCESS
        // -------------------------------
        for (Id pid : partnerRegionsMap.keySet()) {
    
            for (String name : partnerRegionsMap.get(pid)) {
    
                // =========================
                // 1. VALUE LOGIC
                // =========================
                if (valByName.containsKey(name)) {
    
                    PMP_Specification_Value__c val = valByName.get(name);
    
                    // Insert VALUE
                    if (val.Id != null) {
                        String key = pid + '-V-' + val.Id;
    
                        if (!uniqueKeys.contains(key) && !existingKeys.contains(key)) {
                            uniqueKeys.add(key);
    
                            toInsert.add(new PMP_Company_Region__c(
                                PMP_Company_Id__c = pid,
                                PMP_Specification_Value__c = val.Id
                            ));
                        }
                    }
    
                    // VALUE → SPEC → PARENT CHAIN
                    if (val.PMP_Specification_Product_Cd__c != null &&
                        specByCode.containsKey(val.PMP_Specification_Product_Cd__c)) {
    
                        PMP_Specification__c spec =
                            specByCode.get(val.PMP_Specification_Product_Cd__c);
    
                        Set<String> visited = new Set<String>();
    
                        while (spec != null &&
                               spec.PMP_Partner_Product_Specification_Id__c != null &&
                               !visited.contains(spec.PMP_Partner_Product_Specification_Id__c)) {
    
                            visited.add(spec.PMP_Partner_Product_Specification_Id__c);
    
                            // Insert SPEC
                            if (spec.Id != null) {
                                String key = pid + '-S-' + spec.Id;
    
                                if (!uniqueKeys.contains(key) && !existingKeys.contains(key)) {
                                    uniqueKeys.add(key);
    
                                    toInsert.add(new PMP_Company_Region__c(
                                        PMP_Company_Id__c = pid,
                                        PMP_Specification_Id__c = spec.Id
                                    ));
                                }
                            }
    
                            // STOP at TOP
                            if (spec.PMP_Product_Parent_Specification_Id__c == 'NPP_GeographicCoverage') {
    
                                if (specByCode.containsKey('NPP_GeographicCoverage')) {
    
                                    PMP_Specification__c top =
                                        specByCode.get('NPP_GeographicCoverage');
    
                                    if (top != null && top.Id != null) {
    
                                        String key = pid + '-S-' + top.Id;
    
                                        if (!uniqueKeys.contains(key) && !existingKeys.contains(key)) {
                                            uniqueKeys.add(key);
    
                                            toInsert.add(new PMP_Company_Region__c(
                                                PMP_Company_Id__c = pid,
                                                PMP_Specification_Id__c = top.Id
                                            ));
                                        }
                                    }
                                }
                                break;
                            }
    
                            // Move to parent
                            if (spec.PMP_Product_Parent_Specification_Id__c != null &&
                                specByCode.containsKey(spec.PMP_Product_Parent_Specification_Id__c)) {
    
                                spec = specByCode.get(spec.PMP_Product_Parent_Specification_Id__c);
                            } else {
                                break;
                            }
                        }
                    }
                }
    
                // =========================
                // 2. DIRECT SPEC
                // =========================
                if (specByName.containsKey(name)) {
    
                    PMP_Specification__c spec = specByName.get(name);
    
                    if (spec != null && spec.Id != null) {
    
                        String key = pid + '-S-' + spec.Id;
    
                        if (!uniqueKeys.contains(key) && !existingKeys.contains(key)) {
                            uniqueKeys.add(key);
    
                            toInsert.add(new PMP_Company_Region__c(
                                PMP_Company_Id__c = pid,
                                PMP_Specification_Id__c = spec.Id
                            ));
                        }
                    }
                }
            }
        }
    
        // -------------------------------
        // STEP 7: INSERT
        // -------------------------------
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

	// LOGO PROCESSOR (ENTRY)    
    public static void processLogos(List<PMP_CompanyAutoFill__c> newList,Map<Id, PMP_CompanyAutoFill__c> oldMap) {
        if (newList == null || newList.isEmpty()) return;
    
        Map<Id, Id> stageToDocMap = new Map<Id, Id>();
        Map<Id, PMP_CompanyAutoFill__c> stageMap = new Map<Id, PMP_CompanyAutoFill__c>();
    
        for (PMP_CompanyAutoFill__c s : newList) {
    
            if (s.PMP_Partner_Id__c == null) continue;
            if (String.isBlank(s.Company_Key_Values__c)) continue;
    
            PMP_CompanyAutoFill__c oldRec = oldMap.get(s.Id);
    
            if (oldRec != null &&
                oldRec.Company_Key_Values__c == s.Company_Key_Values__c) {
                continue;
            }
    
            // SAFE parsing 
            Id docId = null;
    
            for (String pair : s.Company_Key_Values__c.split(';')) {
    
                List<String> parts = pair.split(':');
    
                if (parts.size() == 2 &&
                    parts[0] != null &&
                    parts[0].trim().toLowerCase() == LOGO_KEY) {
    
                    try {
                        docId = (Id) parts[1].trim();
                    } catch (Exception e) {}
                }
            }
    
            if (docId != null) {
                stageToDocMap.put(s.Id, docId);
                stageMap.put(s.Id, s);
            }
        }
    
        if (!stageToDocMap.isEmpty()) {
            linkLogosToRecords(stageToDocMap, stageMap);
        }
    }
    
    // CORE LOGO LINK
    private static void linkLogosToRecords(Map<Id, Id> stageToDocMap,Map<Id, PMP_CompanyAutoFill__c> stageMap) {
    
        if (stageToDocMap.isEmpty()) return;
    
        List<ContentDocumentLink> toInsert = new List<ContentDocumentLink>();
    
        for (Id stageId : stageToDocMap.keySet()) {
    
            Id docId = stageToDocMap.get(stageId);
            PMP_CompanyAutoFill__c rec = stageMap.get(stageId);
    
            if (docId == null || rec == null) continue;
    
            if (rec.PMP_Partner_Id__c != null) {
                toInsert.add(new ContentDocumentLink(
                    ContentDocumentId = docId,
                    LinkedEntityId    = rec.PMP_Partner_Id__c,
                    ShareType         = 'V',
                    Visibility        = 'AllUsers'
                ));
            }
    
            toInsert.add(new ContentDocumentLink(
                ContentDocumentId = docId,
                LinkedEntityId    = stageId,
                ShareType         = 'V',
                Visibility        = 'AllUsers'
            ));
        }
    
        if (!toInsert.isEmpty()) {
            Database.SaveResult[] res = Database.insert(toInsert, false);
    
            PMP_Utility.logDmlErrors(
                (Object[]) res,
                'PMP_CompanyAutoFill_Helper-linkLogosToRecords'
            );
        }
    }  
    
    private static void syncCompanyResourcesFromStage(Set<Id> partnerIds, Map<Id, PMP_CompanyAutoFill__c> partnerToStageMap) {
        List<PMP_Company_Resource__c> resourcesToInsert = new List<PMP_Company_Resource__c>();
        for (Id partnerId : partnerIds) {
            PMP_CompanyAutoFill__c stageRec = partnerToStageMap.get(partnerId);
            if (stageRec == null || String.isBlank(stageRec.PMP_Resources_JSON__c)) {
                continue;
            }
            try {
                List<Object> resources = (List<Object>)JSON.deserializeUntyped(stageRec.PMP_Resources_JSON__c);
                for (Object obj : resources) {
                    Map<String,Object> resource = (Map<String,Object>)obj;
                    String resourceName = (String)resource.get('name');
                    String resourceType = (String)resource.get('type');
                    String resourceUrl = (String)resource.get('url');
                    if (String.isBlank(resourceName) || String.isBlank(resourceUrl)) {
                        continue;
                    }
                    resourcesToInsert.add(new PMP_Company_Resource__c(PMP_Company_Id__c = partnerId, Name = resourceName, PMP_Company_Resource_Type_Nm__c = resourceType, PMP_Company_Resource_URL_txt__c = resourceUrl));
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Invalid Resource JSON : ' + e.getMessage());
            }
        }
        if (!resourcesToInsert.isEmpty()) {
            Database.SaveResult[] results = Database.insert(resourcesToInsert, false);
            PMP_Utility.logDmlErrors((Object[])results, 'PMP_CompanyAutoFill_Helper-syncCompanyResourcesFromStage');
        }
    }
}