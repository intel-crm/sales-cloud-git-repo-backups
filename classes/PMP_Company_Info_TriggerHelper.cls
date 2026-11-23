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
            Database.delete(attrMapToDelete);
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
            
            for(PMP_Company__c Company : partners){
                if(Company.PMP_Intel_Admin_Id__c != UserInfo.getUserId()){
                if(Company.PMP_Company_Lifecycle_Status_Nm__c=='Update Required' && oldMap.get(Company.Id).PMP_Company_Lifecycle_Status_Nm__c!='Update Required'){
              			Company.PMP_Intel_Admin_Id__c = Company.LastModifiedById;
          			}
                }
            }           
        }
        
    }
}