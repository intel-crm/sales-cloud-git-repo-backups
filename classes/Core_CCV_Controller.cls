public with sharing class Core_CCV_Controller {

    public Core_CCV__c ccvRec { get; set; }    
    public List<Core_Value_Chain__c> ccvDetail { get; set; }

    public Core_CCV_Controller() {
    
        String paramId = apexpages.currentpage().getparameters().get('id');
                   
        ccvRec = [SELECT Id, Name, Core_Account__c, Core_Opportunity__c 
                  FROM Core_CCV__c 
                  WHERE Id = :paramId];

        ccvDetail = [SELECT Id, Core_Function__c, Core_KPI__c, Core_Challenges__c, Core_Goals__c, Core_Proposals__c
                     FROM Core_Value_Chain__c 
                     WHERE Core_CCV__c = :paramId
                     ORDER BY Core_Function__c];

        while (ccvDetail.size() <= 4)
        {
            ccvDetail.add(ccvDetail[0]);
        }
    }    
}