/****************************************************************************************************************************************
* Class Name  : PMP_CreateOfferingTab0Service 
* Version     : 1.0 
* Created Date: 09-12-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Raj Yadav               09-12-2019                    Created for displaying tab0 - create offeing categories modal
****************************************************************************************************************************************************************/
@isTest
public with sharing class PMP_CreateOfferingTab0Service {
    
    // //wrapper to store top level categories to be displayed on tab0
    // public class CategoryWrapper{
    //     public String localName{get; set;}
    //     public String englishName{get; set;}
    //     public String id{get; set;}
    //     public String imageURL{get; set;}
    //     public String description{get; set;}
    // }
    
    // /**
    // * Method added by raj to fetch top level categories to be displayed on tab0
    // * @description-fetch top level categories 
    // * @param null
    // * @return List<CategoryWrapper>
    // */
    // public static List<CategoryWrapper> fetchTopLevelCategories(){
        
    //     //List<PMP_Category__c> categories=new List<PMP_Category__c>();//to store category records from category object
    //     List<CategoryWrapper> categoriesData = new List<CategoryWrapper>();//to store the data to be returned
    //     CategoryWrapper categoryData;//Wrapper class variable
    //     String catNameInLocale;//to store category name in locale
    //     String catDescInLocale;//to store category description in locale
        
    //     Map<String, String> apiNameByLabel = PMP_Utility.getLocaleFields('Category',null);//calling getLocaleFields method of utility class to get api field names as per the user locale for Category object
        
    //         for(PMP_Category__c cat : [SELECT id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,PMP_Partner_Offering_Category_Dsc__c,PMP_Category_Chinese_Dsc__c,
    //                                   PMP_Category_Japanese_Dsc__c,PMP_Category_Image_URL_Txt__c,PMP_Partner_Product_Category_Cd__c,PMP_Ancestor_Category_Cd__c FROM PMP_Category__c 
    //                                   WHERE PMP_Partner_Product_Parent_Category_Cd__c=:PMP_StaticConstants_Offering.TYPE_ID 
    //                                   AND PMP_Active_Ind__c=true ORDER BY PMP_Category_Display_Sequence_Nbr__c ASC NULLS LAST]){//iterate over the category records and populate the wrapper
    //             if(String.valueOf(cat.get(apiNameByLabel.get('Name'))) != null && !apiNameByLabel.isEmpty()){//get the locale cat name based on the field from metadata records
    //                 catNameInLocale = String.valueOf(cat.get(apiNameByLabel.get('Name')));
    //             }
    //             else{//if translated value for the cat name is not available,store english value
    //                 catNameInLocale = cat.Name;
    //             }
    //             if(String.valueOf(cat.get(apiNameByLabel.get('Description'))) != null && !apiNameByLabel.isEmpty()){//get locale cat description based on the field from metadata records
    //                 catDescInLocale = String.valueOf(cat.get(apiNameByLabel.get('Description')));
    //             }
    //             else{//if translated value for the cat description is not available,store english value
    //                 catDescInLocale = cat.PMP_Partner_Offering_Category_Dsc__c;
    //             }
    //             //populate the wrapper to be sent to UI
    //             categoryData = new CategoryWrapper();
    //             categoryData.localName = catNameInLocale;
    //             categoryData.englishName = String.valueOf(cat.Name) + '|' + String.valueOf(cat.PMP_Partner_Product_Category_Cd__c);
    //             categoryData.id = cat.PMP_Partner_Product_Category_Cd__c;
    //             categoryData.imageURL = cat.PMP_Category_Image_URL_Txt__c;
    //             categoryData.description = catDescInLocale;
    //             categoriesData.add(categoryData);
    //         }
        
    //     return categoriesData;
    // }
    
    // /**
    //  * Method added by raj to create top level(i.e Ultimate parent and L1) offering category records
    //  * @description - method to create top 2 level offering category records
    //  * @param - offeringId to which the category is associated
    //  * @param - categoryPIMId , PIM Id of category selected on tab0
    //  * Method Parameter - Id
    //  * Method Parameter - String
    //  */
    // public static void createTopLevelOffCategoriesRecord(Id OfferingId, String categoryPIMId){
        
    //     String ultimateParentPIMId = 'NPP_01_TYPE';//PIM Id for the ultimate parent
    //     String L1Category;
        
    //     List<PMP_Partner_Offering_Category__c> offeringCategories=new List<PMP_Partner_Offering_Category__c>();///offering categories to be inserted
    //     PMP_Partner_Offering_Category__c offeringCategory;//wrapper instance
        
    //         for(PMP_Category__c category : [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,PMP_Partner_Product_Category_Cd__c,
    //                                        PMP_Ancestor_Category_Cd__c, PMP_Active_Ind__c FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c IN (:ultimateParentPIMId, :categoryPIMId) 
    //                                        AND PMP_Active_Ind__c = true ]){
    //             offeringCategory = new PMP_Partner_Offering_Category__c();
    //             offeringCategory.Name=category.Name;
    //             offeringCategory.PMP_Offering_Id__c=OfferingId;
    //             offeringCategory.PMP_Category_Id__c=category.Id;
    //             offeringCategory.PMP_Offering_Category_External_Key__c=category.PMP_Partner_Product_Category_Cd__c;
    //             offeringCategory.PMP_Ancestor_Category_Cd__c=category.PMP_Ancestor_Category_Cd__c;
    //             offeringCategories.add(offeringCategory);
                
    //             if(category.PMP_Partner_Product_Category_Cd__c == categoryPIMId){//get the name of L1 category,to be stored in offering record
    //                 L1Category = category.Name;
    //             }
                
    //         }
        
    //     if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isCreateable()){
    //         insert offeringCategories;//insert offering category records
    //     }
    // }
}