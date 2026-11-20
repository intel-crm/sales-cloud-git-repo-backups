/*************************************************************************************************************************************************************************
* Class Name  : Intel_FormData 
* Version     : 1.0 
* Created Date: 05/03/2019
* Modification Log : Original Version
* Description : This wrapper class is used in Create Offering functionality. Used in MarketplaceCreateProductController.Apex 
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************************************************/

// The FormData class represents the JSON structure
// of the underlying offering data related to the form inputs
public class Intel_FormData {
    public static Boolean isWorking() {
        return true;
    }
//     public PMP_Partner_Offering__c offering { get; set; }
//     public Map<String, Intel_SpecificationDataWrapper> company { get; set; }
//     // TODO ADD ALL OTHER RELATED RECORD VALUES HERE
//     // AND ANY VALUE TO BE SAVED NOT ON OFFERING RECORD
//     public String selectedCategories { get; set; }
//     public List<String> selectedCategoriesSubCategory { get; set; }
//     public List<PMP_Partner_Offering_Resource__c> resources{ get; set; }
//     public String ProductWebPageName { get; set; }
//     public String ProductWebPageURL { get; set; }
//     public Intel_ProductWebPageDataWrapper productWebPageData{ get; set; }//Added by raj to get the productwebpage data
    
//     public Map<string, List<Intel_SpecificationDataWrapper>> specifications { get; set; }
//     public List<Intel_SpecificationDataWrapper> categoriesSubCategory { get; set; }
//     public Map<string, List<Intel_SpecificationDataWrapper>> specification_cmplxTab1{ get; set; }
//     public Map<string, List<string>> specification_smplTab1{get;set;}
//     public Map<string, string> specification_txtTab1{get;set;}
//     public Map<string, List<Intel_SpecificationDataWrapper>> specification_cmplxTab2{ get; set; }
//     public Map<string, List<string>> specification_smplTab2{get;set;}
//     public Map<string, string> specification_txtTab2{get;set;}
//     public Map<string, List<Intel_SpecificationDataWrapper>> specification_cmplxTab3{ get; set; }
//     public Map<string, List<string>> specification_smplTab3{get;set;}
//     public Map<string, string> specification_txtTab3{get;set;}
//     // ...
    
//     @auraEnabled public string solutionSubCategory{get;set;} 
//     public Map<String,List<Intel_SpecificationDataWrapper>> categoryAndSubCategory { get; set; } // Tab-1 Dropdown Radio combo
//     public map<string,List<Intel_SpecificationDataWrapper>> industryAndApplication{ get; set; } // Tab-1 industry and application

//     public List<MarketplaceImageUploader.ImageWrapper> imgWrapper {get;set;} //Added By Pranjal : TWC4497-41 
//     public List<PMP_SearchWrapperStore.OfferingResourceWrapper> galleryWrapperList {get;set;}//Added By Pranjal :
}