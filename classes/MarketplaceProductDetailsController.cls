/******************************************************************************************************************************************************************
* Class Name  : MarketplaceProductDetailsController 
* Version     : 1.0 
* Created Date: 06-10-2019
* Modification Log :
*
* Developer                           Date                          Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Raj                   06/10/2019                    Method 'getOfferingDetails' to display offering details on create offering wizard's product card
******************************************************************************************************************************************************************/
public with sharing class MarketplaceProductDetailsController {
    
    /**
    * method added by raj to get offering details for US374590
    * @description-fetch offering and it's related object details
    * @param offeringId the Id of the offering
    * @return Map<String,Object>
    * Method Parameters - Id
    */
    @AuraEnabled(cacheable = true)
    public static String getOfferingDetails(Id offeringId){
        Map<String,Object> detailsByType = new Map<String,Object>();//It will contain details of the offering and it's related object
        String language = userinfo.getLanguage();//getting the logged in user's language
        String localeCatNmField;
        String localeSpecNmField;
        String localeSpecValNmField;
        List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeFields = new List<PMP_Locale_To_FieldAPINm_Mapping__mdt>();
        List<OffCatWrapper> categoriesData = new List<OffCatWrapper>();
        List<OffSpecWrapper> specificationsData = new List<OffSpecWrapper>();
        
        system.debug('language---->'+language);
        
        if(language != null){//if user language is there fetch the name field of all the taxonomy object for the user language from metadata
            localeFields = PMP_Utility.getLocaleToFieldMdtRecordsByField(language, 'Name');
        }
        
        for(PMP_Locale_To_FieldAPINm_Mapping__mdt localField : localeFields){//iterating over metadata records and getting the api field names of cat, spec and specVal
            if(localField.PMP_Object_Nm__c == 'Category'){
                localeCatNmField = localField.PMP_Field_APINm__c;
            }
            else if(localField.PMP_Object_Nm__c == 'Specification'){
                localeSpecNmField = localField.PMP_Field_APINm__c;
            }
            else if(localField.PMP_Object_Nm__c == 'Specification Value'){
                localeSpecValNmField = localField.PMP_Field_APINm__c;
            }
            
        }

        //getting offering related information from offering object and putting it into the map
        PMP_Partner_Offering__c offering = [SELECT Id, Name, PMP_Partner_Offering_Nm__c, PMP_Company_Id__r.Name, PMP_Partner_Offering_Dsc__c, 
                                            PMP_Partner_Offering_Start_Dt__c, PMP_Partner_Offering_End_Dt__c,
                                            PMP_Partner_Offering_Tag_Line_Txt__c, toLabel(PMP_Partner_Offering_Visibility_Nm__c)
                                            FROM PMP_Partner_Offering__c WHERE Id =: offeringId];
        
        //getting categories related to the offering and putting it into offering category wrapper
        List<PMP_Partner_Offering_Category__c> offCategories = PMP_CategoryController.getOfferingCaregories(offeringId);
        for(PMP_Partner_Offering_Category__c offCat : offCategories){
            OffCatWrapper catDataWrapper = new OffCatWrapper();
            catDataWrapper.localName = String.valueOf(offCat.PMP_Category_Id__r.get(localeCatNmField));
            catDataWrapper.ancestorId = offCat.PMP_Ancestor_Category_Cd__c;
            categoriesData.add(catDataWrapper);
        }
        
        
        //getting specifications related to the offering and putting it into the map
        List<PMP_Partner_Offering_Specification__c> offSpecs = PMP_SpecificationController.getOfferingSpecifications(offeringId);
        for(PMP_Partner_Offering_Specification__c offSpec : offSpecs){
           	OffSpecWrapper specDataWrapper = new OffSpecWrapper();
            if(String.valueOf(offSpec.PMP_Specification_Id__r.get(localeSpecNmField)) != null){
            	specDataWrapper.localSpecName = String.valueOf(offSpec.PMP_Specification_Id__r.get(localeSpecNmField));
            }
            else{
                specDataWrapper.localSpecName = String.valueOf(offSpec.PMP_Specification_Id__r.get('Name'));
            }
            if(offSpec.PMP_Specification_Value_Id__r != null){
                if(String.valueOf(offSpec.PMP_Specification_Value_Id__r.get(localeSpecValNmField)) != null){
            		specDataWrapper.localSpecValueName = String.valueOf(offSpec.PMP_Specification_Value_Id__r.get(localeSpecValNmField));
                }
                else{
                    specDataWrapper.localSpecValueName = String.valueOf(offSpec.PMP_Specification_Value_Id__r.get('Name'));
                }
            }
            specDataWrapper.specificationId = offSpec.PMP_Product_Specification_Cd__c;
            specDataWrapper.ancestorId = offSpec.PMP_Ancestor_Specification_Cd__c;
            specificationsData.add(specDataWrapper);
        }
        
        detailsByType.put(PMP_StaticConstants_Offering.OfferingDetail, offering);
        detailsByType.put(PMP_StaticConstants_Offering.selectedCategories,categoriesData);
        detailsByType.put(PMP_StaticConstants_Offering.selectedSpecifications,specificationsData);
        
        return JSON.serialize(detailsByType);
        
    }
    
    public class OffCatWrapper{
        public String localName{get; set;}
        public String ancestorId{get; set;}
    }
    
    public class OffSpecWrapper{
        public String localSpecName{get; set;}
        public String localSpecValueName{get; set;}
        public String specificationId{get; set;}
        public String ancestorId{get; set;}
    }
}