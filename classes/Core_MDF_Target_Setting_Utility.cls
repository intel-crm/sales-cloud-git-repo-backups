/********************************************************************************************************************************************** 
Class Name:         Core_MDF_Target_Setting_Utility
@parameters:        recordId, country
Description:        Utility class for Target Setting Line Items (Method called from LWC)
Test Class:	    Core_MDF_Target_Setting_Utility_Test	
Added By:           Leela   06-10-2024
Modified By:        Date:           Changes:

**********************************************************************************************************************************************/
public without sharing class Core_MDF_Target_Setting_Utility {
    Public static boolean getvalidateUserRegion(Id recordId,String country){
        Map<String, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>> iupgmMap = new Map<String, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>>();
        Boolean noIupgmAccess=false;
        String countryRegion;
        
        List<String> allGeosLst = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exception_AllGeo').Split(',');
        List<String> listOfCountry = new List<String>();
        List<String> countryRegionLst = new List<String>();
        try{
            if(!(FeatureManagement.checkPermission('Core_MDF_Budget_User_Target_Setting_Line_Item_Access'))){
                if(recordId!=null && country!=null){
                    if(country.contains(';')){
                        listOfCountry=country.split(';');
                    }else{
                        listOfCountry.add(country);
                    }
                    if(!listOfCountry.isEmpty()){
                        //hard validation rule to select only any one of the ALL other countries
                        if(listOfCountry.contains(Core_MDF_CCP_ConstantClass.Trgt_Setting_Line_Item_All_Other_EMEA)){
                            countryRegionLst.add('EMEA');
                        }else if(listOfCountry.contains(Core_MDF_CCP_ConstantClass.Trgt_Setting_Line_Item_All_Other_ASMO)){
                            countryRegionLst.add('ASMO');
                        }else if(listOfCountry.contains(Core_MDF_CCP_ConstantClass.Trgt_Setting_Line_Item_All_Other_APJ)){
                            countryRegionLst.add('APJ');
                        }else{
                            for(Core_MDF_CCP_Country_Geo_Mapping__mdt geoCountry : [SELECT MasterLabel, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c
                                                                            FROM Core_MDF_CCP_Country_Geo_Mapping__mdt where MasterLabel IN :listOfCountry]){
                                countryRegionLst.add(geoCountry.Core_MDF_Geo__c);
                            }
                        }
                    }
                    if(countryRegionLst !=null){
                        
                        // Query IUPGM records to get the regions for the creating users
                        List<String> accountManagerPermissionSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Acc_Mgr_Trgt_Line_Item_Modify').split(',');
                        for (Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Core_MDF_User_id__c,Core_MDF_Account_id__c,Core_MDF_Channel_Program_id__r.Name,Core_MDF_Region_Sub_Region_nm__c 
                                                                                FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c WHERE Core_MDF_User_id__c =: UserInfo.getUserId() AND Core_MDF_Active_Ind__c= TRUE  
                                                                                AND Core_MDF_Role_nm__c IN : accountManagerPermissionSet]){
                                                                                    //Verify if IUPGM user has WW access	    
                                                                                    List<String> regionList = iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';');                                                           
                                                                                    if(!regionList.isEmpty()){
                                                                                        for(String geo : regionList){
                                                                                            if(geo == 'WW'){
                                                                                                for(String strOnGeoLst : allGeosLst){
                                                                                                    String iupgmKey = (String) iupgm.Core_MDF_Account_id__c+ (String) iupgm.Core_MDF_Channel_Program_id__r.Name+strOnGeoLst;
                                                                                                    if(iupgmMap!=null && iupgmMap.containsKey(iupgmKey) && iupgmMap.get(iupgmKey) != null) {
                                                                                                        iupgmMap.get(iupgmKey).add(iupgm);    
                                                                                                    }
                                                                                                    else {
                                                                                                        iupgmMap.put(iupgmKey,new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>{iupgm});
                                                                                                    }
                                                                                                }    
                                                                                            }
                                                                                            else{
                                                                                                String iupgmKey = (String) iupgm.Core_MDF_Account_id__c+ (String) iupgm.Core_MDF_Channel_Program_id__r.Name+geo;
                                                                                                if(iupgmMap!=null && iupgmMap.containsKey(iupgmKey) && iupgmMap.get(iupgmKey) != null) {
                                                                                                    iupgmMap.get(iupgmKey).add(iupgm);    
                                                                                                }
                                                                                                else {
                                                                                                    iupgmMap.put(iupgmKey,new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>{iupgm});
                                                                                                }
                                                                                            }
                                                                                            
                                                                                        } 
                                                                                    }                                                           
                                                                                    
                                                                                    
                                                                                }
                        
                    }
                    
                    if(!iupgmMap.isEmpty()) { 
                        // Perform Region check for Target Setting Line Item record and throw validation error
                        Core_MDF_Target_Setting_Line_Item__c trgtSettingLineItemRec = [SELECT Id, Core_MDF_Ultimate_Account_Id__c,
                                                                                       Core_MDF_ProgramName_Txt__c,Core_MDF_Region_nm__c
                                                                                       FROM Core_MDF_Target_Setting_Line_Item__c
                                                                                       WHERE Id=: recordId ];
                        String trgetSettingLineItemkey;
                        for(String countryGeo : countryRegionLst){
                            trgetSettingLineItemkey = (String) trgtSettingLineItemRec.Core_MDF_Ultimate_Account_Id__c + (String) trgtSettingLineItemRec.Core_MDF_ProgramName_Txt__c+countryGeo;
                            if(!iupgmMap.containskey(trgetSettingLineItemkey)){
                                noIupgmAccess = true;
                                break;
                            }
                        }
                    }
                    
                    else{
                        
                        noIupgmAccess = true;
                    }
                }
            }
        }
        catch ( Exception e ){
            Core_MDF_CCP_UtilityClass.logError ( e );
        }
        
        return noIupgmAccess;
    }
}