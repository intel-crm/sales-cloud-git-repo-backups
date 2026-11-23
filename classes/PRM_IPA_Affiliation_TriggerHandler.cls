/***********************************************************************************************************************************************
Apex Class Name:  PRM_IPA_Affiliation_TriggerHandler
Created Date: 25 Aug 2022
Function    : Trigger Handler for the PRM_IPA_Affiliation_Trigger

Modification Log :
* Developer                     Date                Description                                             TestClass
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Shraddha More                 25/08/2022         Trigger Handler of PRM_IPA_Affiliation_Trigger       PRM_IPA_Affiliation_TriggerHandler_Test
after update
*************************************************************************************************************************************************/

public class PRM_IPA_Affiliation_TriggerHandler extends TriggerHandler {
    public static final String ORIGIN = 'PRM_IPA_Affiliation_TriggerHandler';
    public static final String SEVERITY = 'Critical';
    public static final String PROJECT = 'IPA';    
    public override void beforeinsert() {
        
        string Inactivestatus='InActive', program='Intel Partner Alliance', masterAccount = 'Mastered_Account';
        
        List<PRM_IPA_Affiliation__c> tagBuilderList = (List<PRM_IPA_Affiliation__c>) Trigger.new;
        
        Set<Id> setActiveAcmAcc = new Set<Id>();
        Set<Id> setNonIpaAcc = new Set<Id>();
        Set<Id> setofNonACMAcc = new Set<Id>();
        Set<Id> setofIPAAcc = new Set<Id>();        
        
        Set<ID> accIds = new Set<ID>();
        Set<String> uniqueIds = new Set<String>();
        Map<ID, ID> accIdToOpIds = new Map<ID, ID>();
        Set<ID> builderIdsFOrQuery = new Set<ID>();
        Map<Id, List<Id>> accIdsToAffiliations = new Map<Id, List<Id>>();
        Map<String, PRM_IPA_Affiliation__c> OPIDsToAffiliations = new Map<String, PRM_IPA_Affiliation__c>();
        List<PRM_IPA_Affiliation__c> listAffToUpsert = new List<PRM_IPA_Affiliation__c>();
        Map<Id, String> mapAccIdtoRecTypeName = new Map<Id, String>();
        List<String> existingaffUnique = new List<String>();
        Id recordTypeIdOPIDAccount = Schema.SObjectType.PRM_IPA_Affiliation__c.getRecordTypeInfosByName().get('Partner Account Group Affiliation').getRecordTypeId();
        Id recordTypeIdLocAccount = Schema.SObjectType.PRM_IPA_Affiliation__c.getRecordTypeInfosByName().get('Intel Account Affiliation').getRecordTypeId();
        Map<String, PRM_IPA_Affiliation__c> mapOpidToLocAff = new Map<String, PRM_IPA_Affiliation__c>();

        for (PRM_IPA_Affiliation__c aff : tagBuilderList) {
            aff.Unique_Key__c =
                (String) aff.PRM_Account__c +
                (String) aff.PRM_Builder_Strategy__c;
            uniqueIds.add(aff.Unique_Key__c);
            accIds.add(aff.PRM_Account__c);
            builderIdsFOrQuery.add(aff.PRM_Builder_Strategy__C);
            if (accIdsToAffiliations.containsKey(aff.PRM_Account__c)) {
                accIdsToAffiliations.get(aff.PRM_Account__c)
                    .add(aff.PRM_Builder_Strategy__c);
            } else {
                accIdsToAffiliations.put(
                    aff.PRM_Account__c,
                    new List<Id>{ aff.PRM_Builder_Strategy__c }
                );
            }
        }
        
        /*if (!accIds.isEmpty()){
            for(PRM_AccountChannelMembership__c acm : [ SELECT Id, PRM_Account_Id__r.RecordType.DeveloperName, PRM_Account_Id__c, PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c 
                                                       FROM PRM_AccountChannelMembership__c 
                                                       WHERE PRM_Status_Nm__c = 'Approved'
                                                       AND (PRM_Account_Id__r.RecordType.Name = 'Intel Account' OR PRM_Account_Id__r.RecordType.Name= 'Partner Account Group' )
                                                       AND PRM_Account_Id__c IN: accIds]
               ){
                   setofIPAAcc.add(acm.PRM_Account_Id__c);                  
               }  
        }*/
        
        if (!accIds.isEmpty()) {
            for (Account acc : [
                SELECT id, name, Core_IPA_One_Partner_Id__c, RecordType.Name,
                (SELECT Id, PRM_Account_Id__c 
                FROM Channel_Memberships1__r 
                WHERE PRM_Status_Nm__c = 'Approved'
                AND (PRM_Account_Id__r.RecordType.Name = 'Intel Account' OR PRM_Account_Id__r.RecordType.Name= 'Partner Account Group' )
                )
                FROM Account
                WHERE id IN :accIds
            ]) {
                for(PRM_AccountChannelMembership__c acm : acc.Channel_Memberships1__r){
                    setofIPAAcc.add(acm.PRM_Account_Id__c);     
                }
                if (
                    acc.Core_IPA_One_Partner_Id__c != null &&
                    acc.RecordType.Name == 'Intel Account' && acc.Core_IPA_One_Partner_Id__c != acc.id
                ) {
                    accIdToOpIds.put(acc.id, acc.Core_IPA_One_Partner_Id__c);
                }
                mapAccIdtoRecTypeName.put(acc.Id, acc.RecordType.Name);
            }
        }
        System.debug('>>>accIdToOpIds'+accIdToOpIds);
        if ((!accIdToOpIds.isEmpty() && !builderIdsFOrQuery.isEmpty()) || !uniqueIds.isEmpty()) {
            for (PRM_IPA_Affiliation__c aff : [
                SELECT
                id,
                Name,
                PRM_Account__c,
                PRM_Active__c,
                Unique_Key__c,
                PRM_Builder_Strategy__c,
                PRM_Builder_Strategy__r.Name
                FROM PRM_IPA_Affiliation__c
                WHERE
                (PRM_Builder_Strategy__c = :builderIdsFOrQuery
                 AND PRM_Account__c IN :accIdToOpIds.values())
                OR Unique_Key__c IN: uniqueIds
            ]) {
                if(uniqueIds.contains(aff.Unique_Key__c)){
                    existingaffUnique.add(aff.Unique_Key__c);
                }
                OPIDsToAffiliations.put(
                    (String)aff.PRM_Account__c + (String)aff.PRM_Builder_Strategy__c,
                    aff
                );
            }
            
        }
        for (PRM_IPA_Affiliation__c aff : tagBuilderList) {
            if(!setofIPAAcc.contains(aff.PRM_Account__c)
              ){
                  aff.addError('Selected Account('+aff.PRM_Account__c+ ') is Non IPA');
              }
            else if(existingaffUnique.contains(aff.Unique_Key__c)){
                aff.addError('This Account already has this Affiliation.');
            }
            else if(mapAccIdtoRecTypeName.get(aff.PRM_Account__c) == 'Intel Account'){
                aff.RecordTypeId = recordTypeIdLocAccount;
                if (accIdToOpIds.containsKey(aff.PRM_Account__c))
                {
                    if (
                        OPIDsToAffiliations.containsKey(
                            (String)accIdToOpIds.get(aff.PRM_Account__c) +
                            (String)aff.PRM_Builder_Strategy__c
                        )
                    ) {
                        PRM_IPA_Affiliation__c opidAff = OPIDsToAffiliations.get(
                            (String)accIdToOpIds.get(aff.PRM_Account__c) +
                            (String)aff.PRM_Builder_Strategy__c
                        );
                        if (!opidAff.PRM_Active__c) {
                            opidAff.PRM_Active__c = true;
                            listAffToUpsert.add(opidAff);
                        }
                    } else {
                        PRM_IPA_Affiliation__c tag = new PRM_IPA_Affiliation__c();
                        tag.PRM_Account__c = accIdToOpIds.get(aff.PRM_Account__c);
                        tag.PRM_Builder_Strategy__c = aff.PRM_Builder_Strategy__c;
                        tag.RecordTypeId = recordTypeIdOPIDAccount;
                        if(!listAffToUpsert.contains(tag)){
                            listAffToUpsert.add(tag);
                            mapOpidToLocAff.put(tag.PRM_Account__c, aff);
                        }                        
                    }
                }
            }
        }
        System.debug('>>>listAffToUpsert'+listAffToUpsert);
        if (!listAffToUpsert.isEmpty()) {
            Integer count = 0;
            List<Database.upsertResult> upsertResults = Database.upsert(listAffToUpsert, false);
            for(Database.upsertResult ur : upsertResults){
                if(!ur.isSuccess() && mapOpidToLocAff.containsKey(listAffToUpsert[count].PRM_Account__c)
                ){
                    mapOpidToLocAff.get(listAffToUpsert[count].PRM_Account__c).addError(ur.getErrors()[0].getMessage());
                }
                count++;
            }
        }  

    }
    
    public override void beforeupdate() {
        List<PRM_IPA_Affiliation__c> listTagBuilderToUpdate = new List<PRM_IPA_Affiliation__c>();
        Map<Id, String> mapAccIdtoRecTypeName = new Map<Id, String>();
        Set<Id> setAccIds = new Set<Id>();
        
        Map<id, PRM_IPA_Affiliation__c> mapOldsObject = (Map<id, PRM_IPA_Affiliation__c>) Trigger.oldMap;
        List<PRM_IPA_Affiliation__c> tagBuilderList = (List<PRM_IPA_Affiliation__c>) Trigger.new;
        // System.debug('Tag builder list-->' + tagBuilderList);
        // System.debug('Tag builder old map-->' + mapOldsObject);
        if (!tagBuilderList.isEmpty() && tagBuilderList.size() > 0) {
            for (PRM_IPA_Affiliation__c aff : tagBuilderList) {
                setAccIds.add(aff.PRM_Account__c);
            }
        }
        if (!setAccIds.isEmpty() && setAccIds.size() > 0) {
            for (Account ac : [
                SELECT Id, Name, RecordType.Name
                FROM Account
                WHERE Id IN :setAccIds
            ]) {
                mapAccIdtoRecTypeName.put(ac.Id, ac.RecordType.Name);
            }
        }
        Set<Id> setOfAccIds = new Set<Id>();
        Set<Id> setOfAff = new Set<Id>();
        
        Map<Id, PRM_IPA_Affiliation__c> tbmap = new Map<Id, PRM_IPA_Affiliation__c>();
        if (!tagBuilderList.isEmpty() && tagBuilderList.size() > 0) {
            for (PRM_IPA_Affiliation__c tb : tagBuilderList) {
                //System.debug('tb.PRM_Account__c--->' + tb.PRM_Account__c);
                
                if (
                    mapOldsObject != null &&
                    tb.PRM_Active__c !=
                    mapOldsObject.get(tb.Id).PRM_Active__c &&
                    mapAccIdtoRecTypeName.get(tb.PRM_Account__c) ==
                    'Intel Account'
                ) {
                    if (tb.PRM_Account__c != null) {
                        setOfAccIds.add(tb.PRM_Account__c);
                    }
                    if (tb.PRM_Builder_Strategy__c != null) {
                        setOfAff.add(tb.PRM_Builder_Strategy__c);
                    }
                }
            }
        }
        
        System.debug('setOfAff-->' + setOfAff);
        System.debug('setOfAccIds-->' + setOfAccIds);
        
        Map<Id, Core_Account_Group_Member__c> accOpidList = new Map<Id, Core_Account_Group_Member__c>();
        Set<Id> setOpIds = new Set<Id>();
        Map<Id, Id> mapLoactionToOpid = new Map<Id, Id>();
        if (!setOfAccIds.isEmpty()) {
            for (Core_Account_Group_Member__c cag : [
                SELECT
                id,
                name,
                Core_Inactive_Ind__c,
                Core_Partner_Account_Id__c,
                Core_Intel_Account_Id__c
                FROM Core_Account_Group_Member__c
                WHERE
                Core_Intel_Account_Id__c IN :setOfAccIds
                AND Core_Inactive_Ind__c = FALSE
            ]) {
                setOpIds.add(cag.Core_Partner_Account_Id__c);
            }
        }
        
        System.debug('setOpIds-->' + setOpIds);
        Set<Id> setSiblingsAccIds = new Set<Id>();
        Map<Id, List<Id>> mapOpidToListLocation = new Map<Id, List<Id>>();
        if (!setOpIds.isEmpty()) {
            for (Core_Account_Group_Member__c Cagm : [
                SELECT
                id,
                name,
                Core_Inactive_Ind__c,
                Core_Partner_Account_Id__c,
                Core_Intel_Account_Id__c
                FROM Core_Account_Group_Member__c
                WHERE
                Core_Partner_Account_Id__c IN :setOpIds
                AND Core_Inactive_Ind__c = FALSE
            ]) {
                setSiblingsAccIds.add(Cagm.Core_Intel_Account_Id__c);
                mapLoactionToOpid.put(
                    Cagm.Core_Intel_Account_Id__c,
                    Cagm.Core_Partner_Account_Id__c
                );
                if (
                    mapOpidToListLocation.containsKey(
                        Cagm.Core_Partner_Account_Id__c
                    )
                ) {
                    mapOpidToListLocation.get(Cagm.Core_Partner_Account_Id__c)
                        .add(Cagm.Core_Intel_Account_Id__c);
                } else {
                    mapOpidToListLocation.put(
                        Cagm.Core_Partner_Account_Id__c,
                        new List<Id>{ Cagm.Core_Intel_Account_Id__c }
                    );
                }
            }
        }
        
        System.debug('setSiblingsAccIds-->' + setSiblingsAccIds);
        Map<String, PRM_IPA_Affiliation__c> mapAccIdAndAFFToTagBuilder = new Map<String, PRM_IPA_Affiliation__c>();
        Map<Id, List<Id>> mapOPIDActiveAff = new Map<Id, List<Id>>();
        Map<Id, List<Id>> mapLoactionActiveAff = new Map<Id, List<Id>>();
        Map<Id, List<Id>> mapLoactionInactiveAff = new Map<Id, List<Id>>();
        Map<Id, List<Id>> mapOPIDInactiveAff = new Map<Id, List<Id>>();
        if (!setSiblingsAccIds.isEmpty() || !setOpIds.isEmpty()) {
            for (PRM_IPA_Affiliation__c tagBuilder : [
                SELECT
                id,
                Name,
                PRM_Account__c,
                PRM_Account__r.name,
                PRM_Account__r.Core_IPA_One_Partner_Id__c,
                PRM_Active__c,
                PRM_Builder_Strategy__c,
                PRM_Builder_Strategy__r.Name
                FROM PRM_IPA_Affiliation__c
                WHERE
                (PRM_Account__c IN :setSiblingsAccIds
                 OR PRM_Account__c IN :setOpIds)
                AND PRM_Builder_Strategy__c IN :setOfAff
                AND id NOT IN :tagBuilderList
            ]) {
                mapAccIdAndAFFToTagBuilder.put(
                    (String) tagBuilder.PRM_Account__c +
                    (String) tagBuilder.PRM_Builder_Strategy__c,
                    tagBuilder
                );
                if (tagBuilder.PRM_Active__c) {
                    if (setSiblingsAccIds.contains(tagBuilder.PRM_Account__c)) {
                        if (
                            mapLoactionActiveAff.containsKey(
                                tagBuilder.PRM_Account__c
                            )
                        ) {
                            mapLoactionActiveAff.get(tagBuilder.PRM_Account__c)
                                .add(tagBuilder.PRM_Builder_Strategy__c);
                        } else {
                            mapLoactionActiveAff.put(
                                tagBuilder.PRM_Account__c,
                                new List<Id>{
                                    tagBuilder.PRM_Builder_Strategy__c
                                        }
                            );
                        }
                    } else if (setOpIds.contains(tagBuilder.PRM_Account__c)) {
                        if (
                            mapOPIDActiveAff.containsKey(
                                tagBuilder.PRM_Account__c
                            )
                        ) {
                            mapOPIDActiveAff.get(tagBuilder.PRM_Account__c)
                                .add(tagBuilder.PRM_Builder_Strategy__c);
                        } else {
                            mapOPIDActiveAff.put(
                                tagBuilder.PRM_Account__c,
                                new List<Id>{
                                    tagBuilder.PRM_Builder_Strategy__c
                                        }
                            );
                        }
                    }
                } else {
                    /* if (setSiblingsAccIds.contains(tagBuilder.PRM_Account__c)) {
if (
mapLoactionInactiveAff.containsKey(
tagBuilder.PRM_Account__c
)
) {
mapLoactionInactiveAff.get(
tagBuilder.PRM_Account__c
)
.add(tagBuilder.PRM_Builder_Strategy__c);
} else {
mapLoactionInactiveAff.put(
tagBuilder.PRM_Account__c,
new List<Id>{
tagBuilder.PRM_Builder_Strategy__c
}
);
}
} else */
                    if (setOpIds.contains(tagBuilder.PRM_Account__c)) {
                        if (
                            mapOPIDInactiveAff.containsKey(
                                tagBuilder.PRM_Account__c
                            )
                        ) {
                            mapOPIDInactiveAff.get(tagBuilder.PRM_Account__c)
                                .add(tagBuilder.PRM_Builder_Strategy__c);
                        } else {
                            mapOPIDInactiveAff.put(
                                tagBuilder.PRM_Account__c,
                                new List<Id>{
                                    tagBuilder.PRM_Builder_Strategy__c
                                        }
                            );
                        }
                    }
                }
            }
        }
        
        System.debug('mapLoactionActiveAff--->' + mapLoactionActiveAff);
        System.debug('mapLoactionToOpid--->' + mapLoactionToOpid);
        System.debug('mapOpidToListLocation--->' + mapOpidToListLocation);
        for (PRM_IPA_Affiliation__c tb : tagBuilderList) {
            if (
                mapAccIdtoRecTypeName.get(tb.PRM_Account__c) == 'Intel Account'
            ) {
                if (
                    tb.PRM_Active__c &&
                    tb.PRM_Builder_Strategy__c != null &&
                    tb.PRM_Account__c != null
                ) {
                    if (
                        mapLoactionToOpid.containsKey(tb.PRM_Account__c) &&
                        mapOPIDInactiveAff.containsKey(
                            mapLoactionToOpid.get(tb.PRM_Account__c)
                        ) &&
                        mapOPIDInactiveAff.get(
                            mapLoactionToOpid.get(tb.PRM_Account__c)
                        )
                        .contains(tb.PRM_Builder_Strategy__c)
                    ) {
                        // update tag bulder of Opid as true
                        PRM_IPA_Affiliation__c tagBuilder = mapAccIdAndAFFToTagBuilder.get(
                            (String) mapLoactionToOpid.get(tb.PRM_Account__c) +
                            (String) tb.PRM_Builder_Strategy__c
                        );
                        tagBuilder.PRM_Active__c = true;
                        listTagBuilderToUpdate.add(tagBuilder);
                    }
                }
                if (
                    !tb.PRM_Active__c &&
                    tb.PRM_Builder_Strategy__c != null &&
                    tb.PRM_Account__c != null
                ) {
                    if (
                        mapLoactionToOpid.containsKey(tb.PRM_Account__c) &&
                        mapOPIDActiveAff.containsKey(
                            mapLoactionToOpid.get(tb.PRM_Account__c)
                        ) &&
                        mapOPIDActiveAff.get(
                            mapLoactionToOpid.get(tb.PRM_Account__c)
                        )
                        .contains(tb.PRM_Builder_Strategy__c) &&
                        mapOpidToListLocation.containsKey(
                            mapLoactionToOpid.get(tb.PRM_Account__c)
                        )
                    ) {
                        Boolean hasActive = false;
                        for (
                            Id loactionAc : mapOpidToListLocation.get(
                                mapLoactionToOpid.get(tb.PRM_Account__c)
                            )
                        ) {
                            if (mapLoactionActiveAff.containsKey(loactionAc)) {
                                mapLoactionActiveAff.get(loactionAc)
                                    .contains(tb.PRM_Builder_Strategy__c);
                                hasActive = true;
                                break;
                            }
                        }
                        //System.debug('hasActive---->' + hasActive);
                        if (!hasActive) {
                            // update tag bulder of Opid as false
                            PRM_IPA_Affiliation__c tagBuilder = mapAccIdAndAFFToTagBuilder.get(
                                (String) mapLoactionToOpid.get(
                                    tb.PRM_Account__c
                                ) + (String) tb.PRM_Builder_Strategy__c
                            );
                            tagBuilder.PRM_Active__c = false;
                            listTagBuilderToUpdate.add(tagBuilder);
                        }
                    }
                }
            }
        }
        
        //System.debug('listTagBuilderToUpdate--->' + listTagBuilderToUpdate);
        if (!listTagBuilderToUpdate.IsEmpty()) {
            System.debug(
                'listTagBuilderToUpdate inside upsert--->' +
                listTagBuilderToUpdate
            );
            Database.UpsertResult[] tagBList;
            tagBList = Database.upsert(listTagBuilderToUpdate, false);
            integer index = 0;
            for (Database.UpsertResult sr : tagBList) {
                if (!sr.isSuccess()) {
                    Id sId;
                    String sObjectType = 'PRM_IPA_Affiliation__c';
                    String tags = '';
                    for (Database.Error err : sr.getErrors()) {
                        sId = listTagBuilderToUpdate[index].Id;
                        System.debug('err.getMessage --->' + err.getMessage());
                        Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, err.getMessage(),'', sId, sObjectType, tags);
                    }
                } else {
                    System.debug('Upserted successfully');
                }
            }
            index++;
        }
    }
}