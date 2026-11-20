public without sharing class CST_UtilityClass {
    
    @InvocableMethod( label='Map AD and AF Records')    
    public static void mapADandAF(List<String> customerFeedbackIds) {
        
        //  System.debug('customerFeedbackIds -->'+customerFeedbackIds);
        List<SPM_Account_Detail__c> accDetails = null;
        List<SPM_Account_Feedback__c> accFeedback = null;
        List<SPM_Account_Detail__c> accDetailsToUpdate = null;
        Map<Id,SPM_Account_Detail__c > adMap = null;
        
        if(customerFeedbackIds != null){
        adMap = new Map<Id,SPM_Account_Detail__c>([Select id,Feedback_Id__c,SPM_Customer_ID__c from SPM_Account_Detail__c where SPM_Customer_ID__c in: customerFeedbackIds and  Feedback_Id__c= null ]);
        }
        
        if(customerFeedbackIds != null){
           // accDetails = [Select id,Feedback_Id__c,SPM_Customer_ID__c from SPM_Account_Detail__c where SPM_Customer_ID__c in: customerFeedbackIds and  Feedback_Id__c= null ];
            accFeedback = [Select id,Account_ID__c,Account_ID__r.SPM_Customer_ID__c , Account_ID__r.Feedback_Id__c from SPM_Account_Feedback__c where Account_ID__r.SPM_Customer_ID__c  in:customerFeedbackIds and Account_ID__r.Feedback_Id__c = null  ];
            accDetailsToUpdate = new List<SPM_Account_Detail__c>();
            
            for(SPM_Account_Feedback__c accF : accFeedback){
                
                for(SPM_Account_Detail__c accD : adMap.values()){
                    
                    if(accD.Id == accF.Account_ID__c ){
                       
                        
                        adMap.get(accD.id).Feedback_Id__c = accF.Id ;
                        //accD.Feedback_Id__c = accF.Id ;
                        //System.debug('Line 31'+adMap.get(accD.id));
                        accDetailsToUpdate.add(adMap.get(accD.id));
                        
                    }
                }
            }
        }
        
        
        if(accDetailsToUpdate != null){
            
            List<Database.SaveResult> saveResults =  Database.update(accDetailsToUpdate, false);
            
            
            List<Core_Log_Entry__c> logErrors = new List<Core_Log_Entry__c>();                        
            
            for(Database.SaveResult sr : saveResults){
                
                If ( !sr.isSuccess()) {                 
                    for(Database.Error err : sr.getErrors()) {                            
                        logErrors.add(new Core_Log_Entry__c(Core_Details__c = ' Error while mapping AD and AF with error : ' + err.message, Core_Message__c = 'AD and AF Map failure', Core_Severity__c = 'Error', Core_Origin__c = 'CST_UtilityClass', Core_When__c = System.now()));
                    }                            
                }
            }
            
        }
        
    }
    
}