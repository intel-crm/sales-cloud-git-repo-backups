/***************************************************
* Class Name       : PMP_Company_Info_TriggerHelper
* Created by       : Krishna Ch on 26/03/2021
* Description      : This class is used upto update the region on sub-region on company record based on country value.
* Orginal version  : Krishna Ch on 26/03/2021 - Onyx team
* User story Number: US936187 : MP : Geo region should be updated in MPI record.
* update           : 06/07/2022 - commented line no 92 and 103 as part of TWC4497-173 | DINESH MENGADE
* ****************************************************/
public without sharing class PMP_Company_Info_TriggerHelper{
    /*******
* Method Name : updateCompanyRegionOnCountryChange
* return type : void
* created by  : Krishna Ch on 26/03/2021 - Onyx team
* Description : Below method is to update the Region and sub-region on company if there is a change in the country value at company level.
****************/
    public static void updateCompanyRegionOnCountryChange(List<PMP_Company__c> partners, map<Id,PMP_Company__c> oldMap){
        
        //List<PMP_Company__c> partneListToUpdate = new List<PMP_Company__c>();
        //List<PMP_Company__c> partnerInitialList = new List<PMP_Company__c>();
        map<String, string> mCountryNameGeoRef = new map<String, string>();
        map<String, string> mCountryNameSubGeoRef = new map<String, string>();
        
        //Returns a maps of the data sets defined for the "Core_Country_Reference__c" custom setting with Name as keyset.
        for(Core_Country_Reference__c sobjStateRef : Core_Country_Reference__c.getall().values()){
            mCountryNameGeoRef.put(sobjStateRef.Name,sobjStateRef.Core_Geo__c);
            mCountryNameSubGeoRef.put(sobjStateRef.Name,sobjStateRef.Core_Sub_Geo__c);
        } 
        
        
        /** Below code is to check either country got changed at company level and fecthing the Region and sub-region 
from CountryNameGeoRef,mCountryNameSubGeoRef maps based on the country Name.*/
        if(!partners.isEmpty()){
            for(PMP_Company__c panr : partners){
                //Checking the country field and based on the country value fetching geo and sub geo values from Core_Country_Reference__c custom setting.
                if((oldMap == NULL && panr.PMP_Partner_Country_Txt__c != NULL ) || (oldMap != NUll && (panr.PMP_Partner_Country_Txt__c != NULL && 
                                                                                                       (panr.PMP_Partner_Country_Txt__c != oldMap.get(panr.id).PMP_Partner_Country_Txt__c)))){
                                                                                                           panr.PMP_Account_Region__c = '';
                                                                                                           panr.PMP_Account_Sub_Region__c = '';
                                                                                                           if(mCountryNameGeoRef.containsKey(panr.PMP_Partner_Country_Txt__c )){
                                                                                                               panr.PMP_Account_Region__c = mCountryNameGeoRef.get(panr.PMP_Partner_Country_Txt__c);
                                                                                                               panr.PMP_Account_Sub_Region__c = mCountryNameSubGeoRef.get(panr.PMP_Partner_Country_Txt__c);
                                                                                                           }
                                                                                                       }
            }
            
        }
        
    }
    /*******
* Method Name : updatecompanyAttributeMappingRecords
* return type : void
* created by  : Krishna Ch on 20/04/2021 - Onyx team
* Description : Below method is to update the AttributeMappingRecords if there is a change in the segment/speciality/role/tier value at company level.
****************/
    public static void updatecompanyAttributeMappingRecords(List<PMP_Company__c> partners, map<Id,PMP_Company__c> oldMap){
        
        Set<Id> partnersId = new Set<Id>();
        //Checking is there any change in segment/specialty/tier/partner program.
        if(!partners.isEmpty()){
            for(PMP_Company__c panr : partners){
                if(panr.PMP_Account_Specialty__c != oldMap.get(panr.id).PMP_Account_Specialty__c   ||
                   panr.PMP_Partner_Segment_Nm__c != oldMap.get(panr.id).PMP_Partner_Segment_Nm__c ||
                   panr.PMP_Partner_Program_nm__c != oldMap.get(panr.Id).PMP_Partner_Program_nm__c || 
                   panr.PMP_IPA_Badge_Tier_Txt__c != oldMap.get(panr.id).PMP_IPA_Badge_Tier_Txt__c){
                       partnersId.add(panr.id);
                   }
            }
        }
        if(!partnersId.isEmpty()){
            /*if this method is invoked from batch/future method then Calling synchronus method from below code, 
else invoke the future method.*/
            if(system.isBatch() || system.isFuture()){
                updateCompanyAttributeMappingRecordsSynchronously(partnersId);
            }
            else{
                updateCompanyAttributeMappingRecordsAsynchronously(partnersId); 
            }
        }
    }
    //below method is used to update CompanyAttributeMapping Records Asynchrousnully.
    @future
    public static void updateCompanyAttributeMappingRecordsAsynchronously(set<id> ptnrIds){
        updateCompanyAttributeMappingRecordsSynchronously(ptnrIds);
    }
    //below method is used to update CompanyAttributeMapping Records synchrousnully.
    public static void updateCompanyAttributeMappingRecordsSynchronously(set<id> ptnrIds){
        
        List<PMP_Marketing_Profile_Attributes_Mapping__c> attrMapToDelete = new List<PMP_Marketing_Profile_Attributes_Mapping__c>();
        
        //Below query will return all the existing CompanyAttributeMapping records related to the companies.
        
        attrMapToDelete =[select id,PMP_Marketing_Profile_Id__c from PMP_Marketing_Profile_Attributes_Mapping__c 
                          where PMP_Marketing_Profile_Id__c in :ptnrIds];
        
      
        if(!attrMapToDelete.isEmpty()){
            Database.DeleteResult[] results = Database.delete(attrMapToDelete, false);
            PMP_Utility.logDmlErrors((Object[]) results, 'PMP_Company_Info_TriggerHelper-updateCompanyAttributeMappingRecordsSynchronously');
            //Database.delete(attrMapToDelete);
        }
        // Below query returns the list of the companies got changed.
        
        List<PMP_Company__c> compList = [Select id,PMP_Account_Specialty__c,PMP_Partner_Segment_Nm__c,
                                         PMP_Partner_Program_nm__c,PMP_IPA_Badge_Tier_Txt__c from PMP_Company__c 
                                         where Id in :ptnrIds];
        // Creating the new attribute records to the company with latest segment/specialty/tier/partner program 
        if(!compList.isEmpty()){
            PMP_AccountBenefitPartnerUtility.InsertCompanyAttributeMappingRecords(compList);
        }
        
    }
    
    public static void updateIntelAdmin(List<PMP_Company__c> partners, map<Id,PMP_Company__c> oldMap){
        
        if(!partners.isEmpty()){    
            Id currentUserId = UserInfo.getUserId();
            for(PMP_Company__c Company : partners){
                if(Company.PMP_Intel_Admin_Id__c != currentUserId){
                if(Company.PMP_Company_Lifecycle_Status_Nm__c=='Update Required' && oldMap.get(Company.Id).PMP_Company_Lifecycle_Status_Nm__c!='Update Required'){
                    Company.PMP_Intel_Admin_Id__c = currentUserId;
                }
                }
            }           
        }       
    }

    
public class RemoveStorefrontSharingQueueable implements Queueable {
    private Set<Id> setConIdToRemove;

    public RemoveStorefrontSharingQueueable(Set<Id> setConIdToRemove) {
        this.setConIdToRemove = setConIdToRemove;
    }

    public void execute(QueueableContext context) {
        // your logic here
        removeStorefrontSharing(setConIdToRemove);
    }
}
public static void removeStorefrontSharing(set<id> setConIdToRemove){
	set<string> opidGroups=new set<string>();
    set<id> activeOPIDs=new set<id>();
    string pmpStr='PMP_';
    String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
    string entitlementLabel=system.label.PMP_Egligble_Entitlement;
    list<string> entitlementLabelValues=entitlementLabel.split(';');
    List<GroupMember> listToRemoveFromGroupMember = new List<GroupMember>();
    Map<String, Id> mapGroupNameToId = new Map<String, Id>();
    Map<Id, Set<Id>> mapGroupIdWithUserIDs = new Map<Id, Set<Id>>();
    map<id,set<GroupMember>> mapGroupIdWithGrpMmberId=new map<id,set<GroupMember>>();
    system.debug('entitlementLabel'+entitlementLabel);
    system.debug('entitlementLabelValues'+entitlementLabelValues);

        // STEP 1: Build mapOpidUserids
        Map<String, Set<Id>> mapOpidUserids = new Map<String, Set<Id>>();
    if(setConIdToRemove!=null && !setConIdToRemove.isEmpty()){
        for(contact con:[select Core_IPA_One_Partner_Id__c  from contact where id in :setConIdToRemove]){
		 opidGroups.add(pmpStr+con.Core_IPA_One_Partner_Id__c);
         activeOPIDs.add(con.Core_IPA_One_Partner_Id__c);
	}
    }
    if(activeOPIDs!=null && !activeOPIDs.isEmpty()){
        for (User u : [
			SELECT Id,contact.Core_IPA_One_Partner_Id__c
            FROM User
            WHERE isActive=true and contact.Core_IPA_One_Partner_Id__c in :activeOPIDs
            and ContactId in (SELECT Core_Contact_Id__c
               FROM Core_Contact_Entitlement__c 
               WHERE  Core_Entitlement_Id__r.name in :entitlementLabelValues)
        ]) {
            if (!mapOpidUserids.containsKey(u.contact.Core_IPA_One_Partner_Id__c)) {
                mapOpidUserids.put(u.contact.Core_IPA_One_Partner_Id__c, new Set<Id>());
            }
            mapOpidUserids.get(u.contact.Core_IPA_One_Partner_Id__c).add(u.Id);//id opidid1234,user1,user2
        }
    }
    

        // STEP 2: Get Groups by DeveloperName
        
if(opidGroups!=null && !opidGroups.isEmpty()){
        for (Group g : [
            SELECT Id, DeveloperName
            FROM Group
            WHERE DeveloperName IN :opidGroups
        ]) {
            mapGroupNameToId.put(g.DeveloperName, g.Id);
        }
	}

        // STEP 3: Get existing Group Members
       
    if(mapGroupNameToId!=null){
        for (GroupMember gm : [
            SELECT id, GroupId, UserOrGroupId
            FROM GroupMember
            WHERE GroupId IN :mapGroupNameToId.values()
        ]) {
            if (!mapGroupIdWithUserIDs.containsKey(gm.GroupId)) {
                mapGroupIdWithUserIDs.put(gm.GroupId, new Set<Id>());//user1
            }
            mapGroupIdWithUserIDs.get(gm.GroupId).add(gm.UserOrGroupId);
			if (!mapGroupIdWithGrpMmberId.containsKey(gm.GroupId)) {
                mapGroupIdWithGrpMmberId.put(gm.GroupId, new Set<GroupMember>());
            }
            mapGroupIdWithGrpMmberId.get(gm.GroupId).add(gm);
        }
    }

        // STEP 4: Prepare records to insert
      
    if(opidGroups!=null && !opidGroups.isEmpty()){
         for (String groupName : opidGroups) {
			Id groupId = mapGroupNameToId.containsKey(groupName) ? mapGroupNameToId.get(groupName) : null;
           // Id groupId = mapGroupNameToId.containskey(groupName)?mapGroupNameToId.get(groupName):'';
			//String opidId = groupName.split('_')[1];
			String opidId;
            if (groupName != null && groupName.contains('_')) {
                List<String> parts = groupName.split('_');
                opidId = (parts.size() > 1) ? parts[1] : null;
            }
            Set<Id> opidUsers = opidId!=null && mapOpidUserids.containskey(opidId)? mapOpidUserids.get(opidId): new Set<Id>();//opid id--userset
        
            Set<Id> existingUsers = groupId!=null && mapGroupIdWithUserIDs.containskey(groupId)?mapGroupIdWithUserIDs.get(groupId):new Set<Id>();
            if(opidUsers!=null){
                for (Id userId : opidUsers) {
                if (existingUsers.contains(userId) && mapGroupIdWithGrpMmberId.containsKey(groupId) &&
    			mapGroupIdWithGrpMmberId.get(groupId) != null) {
                    listToRemoveFromGroupMember.addAll(mapGroupIdWithGrpMmberId.get(groupId));
                }
            }
            }
            
        }
    }
       
	
	if(!listToRemoveFromGroupMember.isEmpty()){
		delete listToRemoveFromGroupMember;
	}
	}
    
  public static void createStagingFromCompany(List<PMP_Company__c> newCompanies) {
        if (newCompanies == null || newCompanies.isEmpty()) return;

        List<PMP_CompanyAutoFill__c> toInsert =
            new List<PMP_CompanyAutoFill__c>();

        for (PMP_Company__c c : newCompanies) {

            if (String.isBlank(c.PMP_Account_Website__c) || c.PMP_Company_Lifecycle_Status_Nm__c != 'Draft' || !c.PMP_Is_Working_Copy_Ind__c) continue;

            toInsert.add(new PMP_CompanyAutoFill__c(
                PMP_Partner_Id__c = c.Id,
                PMP_Website__c    = c.PMP_Account_Website__c,
                PMP_Autofill_Status__c = 'Staged'
            ));
        }

        if (!toInsert.isEmpty()) {
            Database.SaveResult[] sr = Database.insert(toInsert, false);
            PMP_Utility.logDmlErrors((Object[]) sr,'PMP_Company_Info_TriggerHelper-createStagingFromCompany'
            );
        }
    }
    
}