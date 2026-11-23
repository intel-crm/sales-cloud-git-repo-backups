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

public with sharing class PRM_IPA_Affiliation_TriggerHandler extends TriggerHandler {
    public static final String ORIGIN = 'PRM_IPA_Affiliation_TriggerHandler';
    public static final String SEVERITY = 'Critical';
    public static final String PROJECT = 'IPA';    
    public static final Id recordTypeIdLocAccount = Schema.SObjectType.PRM_IPA_Affiliation__c.getRecordTypeInfosByName().get('Intel Account Affiliation').getRecordTypeId();    
    public override void beforeinsert() {
        
        //string Inactivestatus='InActive', program='Intel Partner Alliance', masterAccount = 'Mastered_Account';
        
        List<PRM_IPA_Affiliation__c> tagBuilderList = (List<PRM_IPA_Affiliation__c>) Trigger.new;
        
        /*Set<Id> setActiveAcmAcc = new Set<Id>();
        Set<Id> setNonIpaAcc = new Set<Id>();
        Set<Id> setofNonACMAcc = new Set<Id>();*/
        Set<Id> setofIPAAcc = new Set<Id>();        
        
        Set<ID> accIds = new Set<ID>();
        Set<String> uniqueIds = new Set<String>();
        Map<ID, ID> accIdToOpIds = new Map<ID, ID>();
        Set<ID> builderIdsFOrQuery = new Set<ID>();
        //Map<Id, List<Id>> accIdsToAffiliations = new Map<Id, List<Id>>();
        //Map<String, PRM_IPA_Affiliation__c> OPIDsToAffiliations = new Map<String, PRM_IPA_Affiliation__c>();
        List<PRM_IPA_Affiliation__c> listAffToUpsert = new List<PRM_IPA_Affiliation__c>();
        //Map<Id, String> mapAccIdtoRecTypeName = new Map<Id, String>();
        List<String> existingaffUnique = new List<String>();
        Id recordTypeIdOPIDAccount = Schema.SObjectType.PRM_IPA_Affiliation__c.getRecordTypeInfosByName().get('Partner Account Group Affiliation').getRecordTypeId();
        Map<String, PRM_IPA_Affiliation__c> mapOpidToLocAff = new Map<String, PRM_IPA_Affiliation__c>();

        for (PRM_IPA_Affiliation__c aff : tagBuilderList) {
            aff.Unique_Key__c =
                (String) aff.PRM_Account__c +
                (String) aff.PRM_Builder_Strategy__c;
            uniqueIds.add(aff.Unique_Key__c);
            accIds.add(aff.PRM_Account__c);
            builderIdsFOrQuery.add(aff.PRM_Builder_Strategy__C);
            /*if (accIdsToAffiliations.containsKey(aff.PRM_Account__c)) {
                accIdsToAffiliations.get(aff.PRM_Account__c)
                    .add(aff.PRM_Builder_Strategy__c);
            } else {
                accIdsToAffiliations.put(
                    aff.PRM_Account__c,
                    new List<Id>{ aff.PRM_Builder_Strategy__c }
                );
            }*/
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
                //mapAccIdtoRecTypeName.put(acc.Id, acc.RecordType.Name);
            }
        }
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
                //OPIDsToAffiliations.put((String)aff.PRM_Account__c + (String)aff.PRM_Builder_Strategy__c,aff);
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
           /* else if(mapAccIdtoRecTypeName.get(aff.PRM_Account__c) == 'Intel Account'){
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
                            opidAff.PRM_Notes__c ='Roll up to 1PID from Intel account';//TWC729-8089 : Adding reason text : NJ
                            listAffToUpsert.add(opidAff);
                        }
                    } else {
                        PRM_IPA_Affiliation__c tag = new PRM_IPA_Affiliation__c();
                        tag.PRM_Account__c = accIdToOpIds.get(aff.PRM_Account__c);
                        tag.PRM_Builder_Strategy__c = aff.PRM_Builder_Strategy__c;
                        tag.RecordTypeId = recordTypeIdOPIDAccount;
                        tag.PRM_Notes__c = 'Roll up to 1PID from Intel account';
                        if(!listAffToUpsert.contains(tag)){
                            listAffToUpsert.add(tag);
                            mapOpidToLocAff.put(tag.PRM_Account__c, aff);
                        }                        
                    }
                }
            }
        }
        if (!listAffToUpsert.isEmpty()) {
            Integer count = 0;
            List<Database.upsertResult> upsertResults = Database.upsert(listAffToUpsert, false);
            for(Database.upsertResult ur : upsertResults){
                if(!ur.isSuccess() && mapOpidToLocAff.containsKey(listAffToUpsert[count].PRM_Account__c)
                ){
                    mapOpidToLocAff.get(listAffToUpsert[count].PRM_Account__c).addError(ur.getErrors()[0].getMessage());
                }
                count++;
            } */
        } 

    }
    
    /*public override void beforeupdate() {
        List<PRM_IPA_Affiliation__c> listTagBuilderToUpdate = new List<PRM_IPA_Affiliation__c>();
        Map<Id, String> mapAccIdtoRecTypeName = new Map<Id, String>();
        Set<Id> setAccIds = new Set<Id>();
        
        Map<id, PRM_IPA_Affiliation__c> mapOldsObject = (Map<id, PRM_IPA_Affiliation__c>) Trigger.oldMap;
        List<PRM_IPA_Affiliation__c> tagBuilderList = (List<PRM_IPA_Affiliation__c>) Trigger.new;
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
        
        //Map<Id, Core_Account_Group_Member__c> accOpidList = new Map<Id, Core_Account_Group_Member__c>();
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
        Map<String, PRM_IPA_Affiliation__c> mapAccIdAndAFFToTagBuilder = new Map<String, PRM_IPA_Affiliation__c>();
        Map<Id, List<Id>> mapOPIDActiveAff = new Map<Id, List<Id>>();
        Map<Id, List<Id>> mapLoactionActiveAff = new Map<Id, List<Id>>();
        //Map<Id, List<Id>> mapLoactionInactiveAff = new Map<Id, List<Id>>();
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
} else 
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
                        tagBuilder.PRM_Notes__c='Roll up to 1PID from Intel account';//TWC729-8089 : Adding reason text : NJ
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
                        if (!hasActive) {
                            // update tag bulder of Opid as false
                            PRM_IPA_Affiliation__c tagBuilder = mapAccIdAndAFFToTagBuilder.get(
                                (String) mapLoactionToOpid.get(
                                    tb.PRM_Account__c
                                ) + (String) tb.PRM_Builder_Strategy__c
                            );
                            tagBuilder.PRM_Active__c = false;
                            tagBuilder.PRM_Notes__c='Roll down from 1PID';//TWC729-8089 : Adding reason text : NJ
                            listTagBuilderToUpdate.add(tagBuilder);
                        }
                    }
                }
            }
        }
        if (!listTagBuilderToUpdate.IsEmpty()) {
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
                        Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, err.getMessage(),'', sId, sObjectType, tags);
                    }
                }
            }
            index++;
        }
    }*/
    public override void afterinsert() {
        opidToIntelAffiliationRolldown(Trigger.new,null);
		updateDealIncFlgOnAccs(Trigger.new,null);
    }
    public override void afterUpdate() {
        opidToIntelAffiliationRolldown(Trigger.new,(Map<Id,PRM_IPA_Affiliation__c>)Trigger.oldMap); 
		
		updateDealIncFlgOnAccs(Trigger.new,(Map<Id,PRM_IPA_Affiliation__c>)Trigger.oldMap);
    }
public static void updateDealIncFlgOnAccs(List<PRM_IPA_Affiliation__c> newList,Map<Id,PRM_IPA_Affiliation__c> oldMap){
		set<id> opidIds=new set<id>();
		Map<Id, Account> accountMap = new Map<Id, Account>();
        Map<Id, boolean> mapOpidWithAffActive = new Map<Id, boolean>();
    	Map<Id,PRM_IPA_Affiliation__c> mapAfftoStrategy =new Map<Id,PRM_IPA_Affiliation__c>([Select id,PRM_Account__c,PRM_Active__c,PRM_Builder_Strategy__c,
                                                                                             PRM_Builder_Strategy__r.Name from PRM_IPA_Affiliation__c where id IN:newList]);
    
		for(PRM_IPA_Affiliation__c aff:mapAfftoStrategy.values()){
		if(aff.PRM_Builder_Strategy__r !=null && aff.PRM_Builder_Strategy__r.Name=='Deal Incentive' &&
           	((oldmap==null && aff.PRM_Active__c==true)
            || (aff.PRM_Active__c!=oldmap.get(aff.id).PRM_Active__c && aff.PRM_Active__c==true) || 
               (aff.PRM_Active__c!=oldmap.get(aff.id).PRM_Active__c && aff.PRM_Active__c==false))
          )
        {
			opidIds.add(aff.PRM_Account__c);
            mapOpidWithAffActive.put(aff.PRM_Account__c,aff.PRM_Active__c);
		}
		} 
		if(!opidIds.isEmpty()){
			//getAccountswith opids
			for (Core_Account_Group_Member__c cag:[select id,name,Intel_Account_Name__c,Core_Intel_Account_Id__c, Core_Partner_Account_Id__c,
            Core_Partner_Account_Id__r.name,Core_Partner_Account_Id__r.PRM_Impartner_Deal_Sync__c , Core_Intel_Account_Id__r.PRM_Impartner_Deal_Sync__c,
             Core_Intel_Account_Id__r.name, Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Intel_Account_Id__r.RecordType.name,
			Primary_Account__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c in :opidIds 
			and (Primary_Account__c =true or Core_Intel_Partner_Alliance_PartnerGroup__c =true)]){
					if (cag.Core_Partner_Account_Id__c != null && !accountMap.containsKey(cag.Core_Partner_Account_Id__c) 
                    && mapOpidWithAffActive.containsKey(cag.Core_Partner_Account_Id__c ) && mapOpidWithAffActive.get(cag.Core_Partner_Account_Id__c)==true) {
					accountMap.put(
						cag.Core_Partner_Account_Id__c,
						new Account(
							Id = cag.Core_Partner_Account_Id__c,
							PRM_Impartner_Deal_Sync__c=true
						)
					);
				}else if(cag.Core_Partner_Account_Id__c != null && !accountMap.containsKey(cag.Core_Partner_Account_Id__c) 
                    && mapOpidWithAffActive.containsKey(cag.Core_Partner_Account_Id__c ) 
                    && mapOpidWithAffActive.get(cag.Core_Partner_Account_Id__c)==false){
                        accountMap.put(
						cag.Core_Partner_Account_Id__c,
						new Account(
							Id = cag.Core_Partner_Account_Id__c,
							PRM_Impartner_Deal_Sync__c=false
						)
					);
                    }

				if (cag.Core_Intel_Account_Id__c != null && !accountMap.containsKey(cag.Core_Intel_Account_Id__c) 
                && mapOpidWithAffActive.containsKey(cag.Core_Partner_Account_Id__c ) && mapOpidWithAffActive.get(cag.Core_Partner_Account_Id__c)==true) {
					accountMap.put(
						cag.Core_Intel_Account_Id__c,
						new Account(
							Id = cag.Core_Intel_Account_Id__c,
							PRM_Impartner_Deal_Sync__c=true
						)
					);
				}
                else if(cag.Core_Intel_Account_Id__c != null && !accountMap.containsKey(cag.Core_Intel_Account_Id__c) 
                && mapOpidWithAffActive.containsKey(cag.Core_Partner_Account_Id__c ) && mapOpidWithAffActive.get(cag.Core_Partner_Account_Id__c)==false) {
					accountMap.put(
						cag.Core_Intel_Account_Id__c,
						new Account(
							Id = cag.Core_Intel_Account_Id__c,
							PRM_Impartner_Deal_Sync__c=false
						)
					);
				}
				}
			}
			if (!accountMap.isEmpty()) {
				update accountMap.values();
			}
			
		}
	
    public static void opidToIntelAffiliationRolldown(List<PRM_IPA_Affiliation__c> newList,Map<Id,PRM_IPA_Affiliation__c> oldMap){
        Map<String,Set<String>> opidIntelMap = new Map<String,Set<String>>();
        Map<String,Set<String>> opidBuildStratMap = new Map<String,Set<String>>();
        Map<String,Set<String>> intelBuildStratMap = new Map<String,Set<String>>();
	    Map<String,Set<String>> opidInactiveBuildStratMap = new Map<String,Set<String>>();//TWC729-9422-If Affiliation is inactivated at 1PID, then it should roll down to location accounts
        Map<String,PRM_IPA_Affiliation__c> intelAffMap = new Map<String,PRM_IPA_Affiliation__c>();
        Set<String> builderStratSet = new Set<String>();
        Set<String> intelAccSet = new Set<String>();
        list<PRM_IPA_Affiliation__c> tagList=new list<PRM_IPA_Affiliation__c>();
        String errorMsg = '';

        for(PRM_IPA_Affiliation__c aff : newList){
            if((oldMap==null || (oldMap!=null && oldMap.containsKey(aff.id) && oldMap.get(aff.id).PRM_Active__c!=aff.PRM_Active__c) ) && aff.PRM_Active__c==true){
                if(opidBuildStratMap.containskey(aff.PRM_Account__c)){
                    opidBuildStratMap.get(aff.PRM_Account__c).add(aff.PRM_Builder_Strategy__c);
                }else{
                    Set<String> buildStratSet = new Set<String>();
                    buildStratSet.add(aff.PRM_Builder_Strategy__c);
                    opidBuildStratMap.put(aff.PRM_Account__c,buildStratSet);
                }
                builderStratSet.add(aff.PRM_Builder_Strategy__c);
            }
            if(oldMap != null && oldMap.containsKey(aff.Id) && oldMap.get(aff.Id).PRM_Active__c == true && aff.PRM_Active__c == false){//TWC729-9422-If Affiliation is inactivated at 1PID, then it should roll down to location accounts-start
                if(opidInactiveBuildStratMap.containsKey(aff.PRM_Account__c))
                {
                    opidInactiveBuildStratMap.get(aff.PRM_Account__c).add(aff.PRM_Builder_Strategy__c);
                }
                else
                {
                    opidInactiveBuildStratMap.put(aff.PRM_Account__c,new Set<String>{aff.PRM_Builder_Strategy__c});
                }
                
                builderStratSet.add(aff.PRM_Builder_Strategy__c);
            }
            
        }
		Set<String> opidSet = new Set<String>();
        opidSet.addAll(opidBuildStratMap.keySet());
		opidSet.addAll(opidInactiveBuildStratMap.keySet());
        if(!opidSet.isEmpty()){//TWC729-9422-If Affiliation is inactivated at 1PID, then it should roll down to location accounts-end
        //if(opidBuildStratMap!=null && !opidBuildStratMap.isEmpty()){
            List<PRM_AccountChannelMembership__c> intelAcmList = [SELECT Id,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Account_Id__c, PRM_Partner_Role__c, PRM_Account_Id__r.Core_IPA_One_Partner_Id__c 
                                                                    FROM PRM_AccountChannelMembership__c where PRM_Channel_Program_Id__r.Name='Intel Partner Alliance' AND PRM_Status_Nm__c ='Approved' 
                                                                    AND PRM_Account_Id__r.RecordType.DeveloperName ='Mastered_Account' AND PRM_Account_Id__r.Core_Deactivated__c = false and 
                                                                    PRM_Account_Id__r.Core_IPA_One_Partner_Id__c in: opidSet /*opidBuildStratMap.keySet()*/];
            if(intelAcmList!=null && !intelAcmList.isEmpty()){
                for(PRM_AccountChannelMembership__c acm: intelAcmList){
                    if(opidIntelMap.containskey(acm.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)){
                        opidIntelMap.get(acm.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c).add(acm.PRM_Account_Id__c);
                    }else{
                        Set<String> intelAcc = new Set<String>();
                        intelAcc.add(acm.PRM_Account_Id__c);
                        opidIntelMap.put(acm.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,intelAcc);
                    }
                    intelAccSet.add(acm.PRM_Account_Id__c);
                }
            }
        }
        if(builderStratSet!=null && !builderStratSet.isEmpty() && intelAccSet!=null && !intelAccSet.isEmpty() ){
            for(PRM_IPA_Affiliation__c tgb : [select id, Name, PRM_Account__c, PRM_Account__r.id, PRM_Active__c, PRM_Builder_Strategy__c, PRM_Builder_Strategy__r.Name 
                                            from PRM_IPA_Affiliation__c where PRM_Account__c IN :intelAccSet  AND PRM_Builder_Strategy__c In : builderStratSet]){
                String key = tgb.PRM_Account__c +':'+tgb.PRM_Builder_Strategy__c;
                if(intelBuildStratMap.containskey(tgb.PRM_Account__c)){
                        intelBuildStratMap.get(tgb.PRM_Account__c).add(tgb.PRM_Builder_Strategy__c);
                }else{
                        Set<String> buldStratSet = new Set<String>();
                        buldStratSet.add(tgb.PRM_Builder_Strategy__c);
                        intelBuildStratMap.put(tgb.PRM_Account__c,buldStratSet);
                }
                intelAffMap.put(key,tgb);
            }
        }
        if(opidIntelMap!=null && !opidIntelMap.isEmpty() && opidBuildStratMap!=null && !opidBuildStratMap.isEmpty()){
            for(String opid:opidIntelMap.keySet() ){
                Set<String> opidBuildStratSet = opidBuildStratMap.get(opid);
                for(String intel: opidIntelMap.get(opid)){
                    Set<String> intelBuildStratSet = intelBuildStratMap.containsKey(intel)? intelBuildStratMap.get(intel):null;
                    for(String buildStrat: opidBuildStratSet){
                        String key=intel+':'+buildStrat;
                        if(intelBuildStratSet!=null && intelBuildStratSet.contains(buildStrat) && intelAffMap.containsKey(key) && intelAffMap.get(key).PRM_Builder_Strategy__c==buildStrat && !intelAffMap.get(key).PRM_Active__c ){
                            PRM_IPA_Affiliation__c tag = intelAffMap.get(key);
                            tag.PRM_Notes__c = 'Rolled down from 1PID';
                            tag.PRM_Active__c= true;
                            tagList.add(tag);
                        }else if(intelBuildStratSet==null || !intelBuildStratSet.contains(buildStrat)){
                            PRM_IPA_Affiliation__c tag=new PRM_IPA_Affiliation__c();
                            tag.PRM_Account__c = intel;
                            tag.PRM_Builder_Strategy__c = buildStrat;
                            tag.RecordTypeId = recordTypeIdLocAccount;
                            tag.PRM_Notes__c = 'Rolled down from 1PID';
                            tag.PRM_Active__c= true;
                            tagList.add(tag);
                        }
                    }
                }
            }
        }
        if(!opidInactiveBuildStratMap.isEmpty())//TWC729-9422-If Affiliation is inactivated at 1PID, then it should roll down to location accounts-start
        {
            for(String opid : opidInactiveBuildStratMap.keySet())
            {
                if(opidIntelMap.containsKey(opid))
                {
                    for(String intel : opidIntelMap.get(opid))
                    {
                        for(String buildStrat :opidInactiveBuildStratMap.get(opid))
                        {
                            String key = intel + ':' + buildStrat;
                            if(intelAffMap.containsKey(key) && intelAffMap.get(key).PRM_Active__c)
                            {
                                PRM_IPA_Affiliation__c intelAff = intelAffMap.get(key);
                                intelAff.PRM_Active__c = false;
                                intelAff.PRM_Notes__c ='Rolled down inactive from 1PID';
                                tagList.add(intelAff);
                            }
                        }
                    }
                }
            }
        }//TWC729-9422-If Affiliation is inactivated at 1PID, then it should roll down to location accounts-end
        
        try{
            if(tagList.size()>0){
                    for(Database.UpsertResult sr: Database.Upsert(tagList, false)){
                        if(!sr.isSuccess()){
                            errorMsg +=  sr.getErrors()[0].getMessage() + '<br/>';

                        }
                    }
                }
        }catch (Exception e) {
            errorMsg+='Error -->'+e.getMessage();
        }
        finally{
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, errorMsg,'', '', '', '');
        }
    }
}