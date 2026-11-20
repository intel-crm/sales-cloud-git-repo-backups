public with sharing class DynamicLWCFormBuilderController {
    public DynamicLWCFormBuilderController() {

    }

    @AuraEnabled
    public static List<Core_IPS_EnvironmentDetailQuestion> getDependentDynamicFields(String selectedValue, String  FieldId, String supProdId){
         
        Core_IPS_CaseCreateHelper helper = new Core_IPS_CaseCreateHelper();

        return  helper.basedonSelectedandQuestionValue(selectedValue,FieldId,supProdId);
      
    }
}