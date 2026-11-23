/***************************************************
* Class Name       : PMP_companyInfoUpdateOnCoutryChange
* Created by       : Krishna Ch on 26/03/2021
* Description      : This class is used upto update the region on sub-region on company record based on country value.
* Orginal version  : Krishna Ch on 26/03/2021 - Onyx team
* User story Number: US936187 : MP : Geo region should be updated in MPI record.
*
* ****************************************************/
public class PMP_companyInfoUpdateOnCoutryChange{
 /*******
* Method Name : updateCompanyRegionOnCountryChange
* return type : void
* created by  : Krishna Ch on 26/03/2021 - Onyx team
* Description : Below method is to update the Region and sub-region on company if there is a change in the country value at company level.
****************/
    public static void updateCompanyRegionOnCountryChange(List<PMP_Company__c> partners, map<Id,PMP_Company__c> oldMap){
        
        List<PMP_Company__c> partneListToUpdate = new List<PMP_Company__c>();
        List<PMP_Company__c> partnerInitialList = new List<PMP_Company__c>();
        map<String, string> mCountryNameGeoRef = new map<String, string>();
        map<String, string> mCountryNameSubGeoRef = new map<String, string>();
        
        //No use
        //Returns a maps of the data sets defined for the "Core_Country_Reference__c" custom setting with Name as keyset.
        for(Core_Country_Reference__c sobjStateRef : Core_Country_Reference__c.getall().values()){
            mCountryNameGeoRef.put(sobjStateRef.Name,sobjStateRef.Core_Geo__c);
            mCountryNameSubGeoRef.put(sobjStateRef.Name,sobjStateRef.Core_Sub_Geo__c);
        } 
        
        
        /** Below code is to check either country got changed at company level and fecthing the Region and sub-region 
from CountryNameGeoRef,mCountryNameSubGeoRef maps based on the country Name. */
        if(!partners.isEmpty()){
            for(PMP_Company__c panr : partners){
                
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
    
}