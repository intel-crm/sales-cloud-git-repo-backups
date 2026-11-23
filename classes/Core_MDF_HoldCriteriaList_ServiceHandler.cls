/******************************************************************************************************
* Class Name  : Core_MDF_HoldCriteriaList_ServiceHandler 
* Version     : 1.0 
* Created Date: 05-08-2019
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Intel - AD      05/08/2019         Service handler class for hold list criteria functionality
*******************************************************************************************************/
public without sharing class Core_MDF_HoldCriteriaList_ServiceHandler {
    /****************************************************************************************************** 
Method Name:        deleteHoldCriteriaList
@return  :          void
@parameters:        List of Hold List Criteria
Description:        This method is used to delete existing hold list criteria record
Added By:           Accenture - AD - 04/29/2019
Modified By:        Date:       Changes:  
*******************************************************************************************************/    
    public static void preventDeleteOfEffectiveHoldCriteria(List<Core_MDF_Hold_Criteria__c> holdCriteriaListToBeProcessed ){
        for(Core_MDF_Hold_Criteria__c holdListCriteria : holdCriteriaListToBeProcessed){
            //checking if effective date is on or before todays date
            if(holdListCriteria.Core_MDF_Effective_Dt__c !=null
               && holdListCriteria.Core_MDF_Effective_Dt__c <= Date.today()){
                   //add error
                   holdListCriteria.addError(Label.Core_MDF_PreventDeleteHoldListCriteria);
               }
        }
    } 
    
    /****************************************************************************************************** 
    Method Name:        validateAccountProgramAssociation
    @return  :          void
    @parameters:        List of Hold List Criteria
    Description:        This method is used to validate selected program and account 
    Added By:           Accenture - AD - 05/20/2019
    Modified By:        Date:       Changes:  
    *******************************************************************************************************/    
    public static void validateAccountProgramAssociation(List<Core_MDF_Hold_Criteria__c> holdCriteriaListToBeProcessed ){
        //Set of ultimate account from hold criteria records
        Set<Id> setUltimateAccountIds = new Set<Id>();
        //Map of ultimate account and list of channel programs of corresdponding virtual corp account
        Map<Id,List<String>> mapOfUltimateAccAndChannelPrograms = new Map<Id,List<String>>();
        //Hold all criteria records which has progam and account both are not null.
        List<Core_MDF_Hold_Criteria__c> finalHoldCriteriaListToBeProcessed = new List<Core_MDF_Hold_Criteria__c>();

        for(Core_MDF_Hold_Criteria__c holdListCriteria : holdCriteriaListToBeProcessed){
            //Not null check for both program and account
            if(holdListCriteria.Core_MDF_UltimateAccount_Id__c !=null && holdListCriteria.Core_MDF_Program_id__c !=null){
                setUltimateAccountIds.add(holdListCriteria.Core_MDF_UltimateAccount_Id__c);
                finalHoldCriteriaListToBeProcessed.add(holdListCriteria);
            }           
        }
        //Existing virtual corp accounts
        Map<Id,Account> existingVirtualCorpAccountsMap = new Map<Id,Account>([SELECT ID,Core_MDF_Channel_Program__c,Core_MDF_Parent_Fund_Account__c FROM account 
                                                 WHERE Core_MDF_Parent_Fund_Account__c IN : setUltimateAccountIds]);
        for(Account account : existingVirtualCorpAccountsMap.values()){
            if(mapOfUltimateAccAndChannelPrograms.containsKey(account.Core_MDF_Parent_Fund_Account__c)){
                mapOfUltimateAccAndChannelPrograms.get(account.Core_MDF_Parent_Fund_Account__c) 
                    .add(account.Core_MDF_Channel_Program__c);
            }else{
                mapOfUltimateAccAndChannelPrograms.put(account.Core_MDF_Parent_Fund_Account__c,
                                                       new List<Id>{account.Core_MDF_Channel_Program__c});
            }
        }
        //Loop on final hold criteria list
        for(Core_MDF_Hold_Criteria__c newholdCriteriaRecord : finalHoldCriteriaListToBeProcessed){
            //hold channel program list from map
            List<Id> listOfVirtualCorpChannelProgram = 
                mapOfUltimateAccAndChannelPrograms.containsKey(newholdCriteriaRecord.Core_MDF_UltimateAccount_Id__c) ?
                mapOfUltimateAccAndChannelPrograms.get(newholdCriteriaRecord.Core_MDF_UltimateAccount_Id__c) : null;
            //Checking null condition and selected progarm from hold criteria record
            if(listOfVirtualCorpChannelProgram != null && listOfVirtualCorpChannelProgram.size() > 0 &&
               (!listOfVirtualCorpChannelProgram.contains(newholdCriteriaRecord.Core_MDF_Program_id__c))){         
                   //Add error - in case, selected ultimate account is not member of selected program
                   newholdCriteriaRecord.addError(Label.Core_MDF_AccountProgramMatchError);
               }else{
                   //If channel program list is null, will through error, other wise it will create/edit record  
                   if(listOfVirtualCorpChannelProgram==null){
                    //Add error - in case, ultimate account has no virual corp account
                    newholdCriteriaRecord.addError(Label.Core_MDF_AccountProgramMatchError);
                   }
               }
        }
    }
    
    /****************************************************************************************************** 
    Method Name:        validateAccountProgramAssociationOnEdit
    @return  :          void
    @parameters:        List of Hold List Criteria
    Description:        This method is used to validate selected program and account 
    Added By:           Accenture - AD - 05/20/2019
    Modified By:        Date:       Changes:  
    *******************************************************************************************************/    
    public static void validateAccountProgramAssociationOnEdit(List<Core_MDF_Hold_Criteria__c> holdCriteriaListToBeProcessed,Map<Id,Core_MDF_Hold_Criteria__c> holdCriteriaListOldMap){
        // Final list of hold criteria records to be processed
        List<Core_MDF_Hold_Criteria__c> finalholdCriteriaListToBeProcessed = new List<Core_MDF_Hold_Criteria__c>();
        for(Core_MDF_Hold_Criteria__c newHoldCriteria : holdCriteriaListToBeProcessed){
            //checking if account or program is changed or not
            if((newHoldCriteria.Core_MDF_UltimateAccount_Id__c != holdCriteriaListOldMap.get(newHoldCriteria.Id).Core_MDF_UltimateAccount_Id__c)
               || (newHoldCriteria.Core_MDF_Program_id__c != holdCriteriaListOldMap.get(newHoldCriteria.Id).Core_MDF_Program_id__c)){
                   finalholdCriteriaListToBeProcessed.add(newHoldCriteria);
               }  
        }
        //null check for final hold criteria record list
        if(finalholdCriteriaListToBeProcessed != null && finalholdCriteriaListToBeProcessed.size()>0){
            //Validate  selected account and program combination
            validateAccountProgramAssociation(finalholdCriteriaListToBeProcessed);
        }
    }

    /****************************************************************************************************** 
    Method Name:        validateGeoCountryAssociation
    @return  :          void
    @parameters:        List of Hold List Criteria
    Description:        This method is used to validate selected Geo and Country 
    Added By:           Accenture - JV - 05/22/2019
    Modified By:        Date:       Changes:  
    *******************************************************************************************************/    
    public static void validateGeoCountryAssociation(List<Core_MDF_Hold_Criteria__c> holdCriteriaListToBeProcessed){
        //To hold selected geo-country values (Ex: PRC->CHINA)
        List<String> geoCountryList = new List<String>();
        //To hold geo from country (Ex: PRC)
        String geoOfCountry =  '';
        for(Core_MDF_Hold_Criteria__c newHoldCriteria : holdCriteriaListToBeProcessed){
            //checking if country is selected , the geo has to be selected
            //ATHR - Deeply Nested if 16209
            if(newHoldCriteria.Core_MDF_Region_Country_txt__c != null){
                continue;
            }
            if(newHoldCriteria.Core_MDF_Geo_Txt__c == null){
                newHoldCriteria.addError(Label.Core_MDF_GeoCountryMatchError);
                continue;
            }

            /*if(newHoldCriteria.Core_MDF_Region_Country_txt__c != null){
              if(newHoldCriteria.Core_MDF_Geo_Txt__c != null){*/
                  //Split values and store into list
                  geoCountryList = (newHoldCriteria.Core_MDF_Region_Country_txt__c).split(';');
                for(String geoCountry : geoCountryList){
                    //use substringBefore to extract geo from selected geo-country (Ex: PRC->CHINA)
                    //geoOfCountry = PRC (after substringBefore)
                    geoOfCountry = geoCountry.substringBefore('->');
                    //chekcing geo and corresponding contries selected or not
                    //If geo=PRC the countries should be CHINA, MACAU..
                    if(!(newHoldCriteria.Core_MDF_Geo_Txt__c).contains(geoOfCountry)){
                        //add error, if geo and corresponding contries not selected
                        newHoldCriteria.addError(Label.Core_MDF_GeoCountryMatchError);
                    }
                }
              /*}else{
                  //Add error - If country is selected , but geo is not seleted 
                  newHoldCriteria.addError(Label.Core_MDF_GeoCountryMatchError);
                }
            }*/
        }
    }
    /****************************************************************************************************** 
    Method Name:        validateGeoCountryAssociationOnEdit
    @return  :          void
    @parameters:        List of Hold List Criteria
    Description:        This method is used to validate selected Geo and Country 
    Added By:           Accenture - JV - 05/22/2019
    Modified By:        Date:       Changes:  
    *******************************************************************************************************/    
    public static void validateGeoCountryAssociationOnEdit(List<Core_MDF_Hold_Criteria__c> holdCriteriaListToBeProcessed ,Map<Id,Core_MDF_Hold_Criteria__c> holdCriteriaListOldMap){
        // Final list of hold criteria records to be processed
        List<Core_MDF_Hold_Criteria__c> finalholdCriteriaListToBeProcessed = new List<Core_MDF_Hold_Criteria__c>();
        for(Core_MDF_Hold_Criteria__c newHoldCriteria : holdCriteriaListToBeProcessed){
            //checking if geo or country is changed or not
            if((newHoldCriteria.Core_MDF_Geo_Txt__c != holdCriteriaListOldMap.get(newHoldCriteria.Id).Core_MDF_Geo_Txt__c)
                || (newHoldCriteria.Core_MDF_Region_Country_txt__c != holdCriteriaListOldMap.get(newHoldCriteria.Id).Core_MDF_Region_Country_txt__c)){
                finalholdCriteriaListToBeProcessed.add(newHoldCriteria);
            }
        }
        // check if the final hold criteria list is not empty
        if(finalholdCriteriaListToBeProcessed != null && finalholdCriteriaListToBeProcessed.size()>0){
            //Validate  selected geo and country combination
            validateGeoCountryAssociation(finalholdCriteriaListToBeProcessed);
        }
    }
    /****************************************************************************************************** 
    Method Name:        validateCategoryTypeAssociation
    @return  :          void
    @parameters:        List of Hold List Criteria
    Description:        This method is used to validate selected Geo and Country 
    Added By:           Accenture - JV - 05/22/2019
    Modified By:        Date:       Changes:  
    *******************************************************************************************************/    
    public static void validateCategoryTypeAssociation(List<Core_MDF_Hold_Criteria__c> holdCriteriaListToBeProcessed){
        //To hold selected geo-country values (Ex: Broadcst->Podcast)
        List<String> activityCategoryTypeList = new List<String>();
        //To hold geo from country (Ex: Broadcst)
        String activityCategoryOfType = '';
        for(Core_MDF_Hold_Criteria__c newHoldCriteria : holdCriteriaListToBeProcessed){
            //checking if category-type is selected , then category has to be selected
            //ATHR - Deeply Nested if 16209
            if(newHoldCriteria.Core_MDF_Activity_Category_Type_Txt__c == null){
                continue;
            }
            if(newHoldCriteria.Core_MDF_Activity_Category_Txt__c == null){
                newHoldCriteria.addError(Label.Core_MDF_CategoryTypeMatchError);
                continue;
            }
            /*if(newHoldCriteria.Core_MDF_Activity_Category_Type_Txt__c != null){
              if(newHoldCriteria.Core_MDF_Activity_Category_Txt__c != null){*/
                  //Split values and store into list
                  activityCategoryTypeList = (newHoldCriteria.Core_MDF_Activity_Category_Type_Txt__c).split(';');
                for(String activityCategoryType : activityCategoryTypeList){
                    //use substringBefore to extract category from selected category-type (Ex: Broadcst->Podcast)
                    //activityCategoryOfType = Broadcst (after substringBefore)
                    activityCategoryOfType = activityCategoryType.substringBefore('->');
                    //chekcing category and corresponding types selected or not
                    //If category=Broadcast then types should be Podcast, Radio..
                    if(!(newHoldCriteria.Core_MDF_Activity_Category_Txt__c).contains(activityCategoryOfType)){
                        //add error, if category and corresponding types not selected
                        newHoldCriteria.addError(Label.Core_MDF_CategoryTypeMatchError);
                    }
                }
              /*}else{
                  //Add error - If category-type is selected , but category is not seleted
                  newHoldCriteria.addError(Label.Core_MDF_CategoryTypeMatchError);
                  }
            }*/
        }
    }
    /****************************************************************************************************** 
    Method Name:        validateCategoryTypeAssociationOnEdit
    @return  :          void
    @parameters:        List of Hold List Criteria
    Description:        This method is used to validate selected Geo and Country 
    Added By:           Accenture - JV - 05/22/2019
    Modified By:        Date:       Changes:  
    *******************************************************************************************************/    
    public static void validateCategoryTypeAssociationOnEdit(List<Core_MDF_Hold_Criteria__c> holdCriteriaListToBeProcessed ,Map<Id,Core_MDF_Hold_Criteria__c> holdCriteriaListOldMap){
        // Final list of hold criteria records to be processed
        List<Core_MDF_Hold_Criteria__c> finalholdCriteriaListToBeProcessed = new List<Core_MDF_Hold_Criteria__c>();
        for(Core_MDF_Hold_Criteria__c newHoldCriteria : holdCriteriaListToBeProcessed){
            //checking if activity category or activity type is changed or not
            if((newHoldCriteria.Core_MDF_Activity_Category_Txt__c != holdCriteriaListOldMap.get(newHoldCriteria.Id).Core_MDF_Activity_Category_Txt__c)
                || (newHoldCriteria.Core_MDF_Activity_Category_Type_Txt__c != holdCriteriaListOldMap.get(newHoldCriteria.Id).Core_MDF_Activity_Category_Type_Txt__c)){
                finalholdCriteriaListToBeProcessed.add(newHoldCriteria);
            }
        }
        // check if the final hold criteria list is not empty
        if(finalholdCriteriaListToBeProcessed != null && finalholdCriteriaListToBeProcessed.size()>0){
            //Validate  selected activity category or activity type  combination
            validateCategoryTypeAssociation(finalholdCriteriaListToBeProcessed);
        }
    }
 
}