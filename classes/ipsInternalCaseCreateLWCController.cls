public with sharing class ipsInternalCaseCreateLWCController {
   
    public ipsInternalCaseCreateLWCController() {
       
    }

     @AuraEnabled(cacheable=true)
    public static List<CustomSelectOptions> getvariant(String selectedProductId){
      return  ipsInternalCaseCreateLWCHelper.displayProductVariant(selectedProductId);
    }

    @AuraEnabled(cacheable=true)
    public static List<CustomSelectOptions> getCategoryDetails(String supportedProductId){
      return  ipsInternalCaseCreateLWCHelper.getCategoryOptions(supportedProductId);
    }
    @AuraEnabled(cacheable=true)
    public static List<CustomSelectOptions> getSubCategoryDetail(String categorySelected){
      return  ipsInternalCaseCreateLWCHelper.getsubCategory_Options(categorySelected);
    }
     @AuraEnabled
    public static List<Core_IPS_EnvironmentDetailQuestion> getProductEDQ(String supportedProductId, String subCategoryid,Boolean isAgent){
        System.debug('anishcont>>>>>>'+ipsInternalCaseCreateLWCHelper.displayedqQuestions(supportedProductId,subCategoryid,isAgent));
      return  ipsInternalCaseCreateLWCHelper.displayedqQuestions(supportedProductId,subCategoryid,isAgent);
    }
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_EnvironmentDetailQuestion> getSubCatProductEDQ(String supportedProductId, String subCategoryid,Boolean isAgent){
        System.debug('anishcont2>>>>>>'+ipsInternalCaseCreateLWCHelper.displayedqQuestions(supportedProductId,subCategoryid,isAgent));
      return  ipsInternalCaseCreateLWCHelper.displayedqQuestions(supportedProductId,subCategoryid,isAgent);
    }
    @AuraEnabled(cacheable=true)
    public static boolean getAgentDetail(){
      System.debug('Agent >>'+ipsInternalCaseCreateLWCHelper.getAgent());
      return  ipsInternalCaseCreateLWCHelper.getAgent();
    }
    @AuraEnabled(cacheable=true)
    public static List<CustomSelectOptions> getPlatformDetails(Id productsId){
      System.debug('plaform >>'+ipsInternalCaseCreateLWCHelper.getPlaform(productsId));
     return    ipsInternalCaseCreateLWCHelper.getPlaform(productsId);
     
    }
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_EnvironmentDetailQuestion> DependentQuestionsLWC(String selectedProductId, List<Core_IPS_EnvironmentDetailQuestion> childquestionsrecords){
      System.debug('>>>chil'+childquestionsrecords);
        
      System.debug('childq >>'+ipsInternalCaseCreateLWCHelper.renderDependentQuestionsLWC(selectedProductId,childquestionsrecords));
     return  ipsInternalCaseCreateLWCHelper.renderDependentQuestionsLWC(selectedProductId,childquestionsrecords);
     //return null;
    }
    @AuraEnabled
    public static List<Core_IPS_EnvironmentDetailQuestion> basedonSelectedandQuestionValue(String selectedProductId, String  childquestionsrecords){
      System.debug('>>>chil2'+childquestionsrecords);
        
   //   System.debug('childq2 >>'+ipsInternalCaseCreateLWCHelper.basedonSelectedandQuestionValue(selectedProductId,childquestionsrecords));
     return  ipsInternalCaseCreateLWCHelper.basedonSelectedandQuestionValue(selectedProductId,childquestionsrecords);
     //return null;
    }
    @AuraEnabled
    public static String saveCaseRecord(Boolean customerVisible, String caseType, String contactId, String caseProject, String productId,String caseSource,String caseSeverity,String caseSubject,String caseDesc,String caseCategory,String caseSubCategory, String caseSupportProject,String caseEDQdata){
         return  ipsInternalCaseCreateLWCHelper.saveCaseDetails(customerVisible, caseType,contactId,caseProject,productId,caseSource,caseSeverity,caseSubject,caseDesc,caseCategory,caseSubCategory,caseSupportProject,caseEDQdata);
    }
 @AuraEnabled
    public static List<User>  getUserDetailsBasedOnSearch(String searchValueUser){
         return  ipsInternalCaseCreateLWCHelper.getUserDetailsBasedOnSearch(searchValueUser);
    }
    
    @AuraEnabled
    public static String saveInternalInterestedParty(String userID, String caseId, String contactID ){
       return  ipsInternalCaseCreateLWCHelper.saveInternalInterestedParty(userID,caseId,contactID);
    }
    
}