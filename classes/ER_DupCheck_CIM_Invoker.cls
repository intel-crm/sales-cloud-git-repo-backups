public class ER_DupCheck_CIM_Invoker {
    @InvocableMethod(label='Run Duplicate Check' description='Runs the CIM duplicate check via Flow')
    public static void run(List<Id> recordIds) {
        for (Id recordId : recordIds) {
            PRM_Registration_Request__c req = [
                SELECT Id,
                       PRM_Account_Name__c,
                       PRM_Email_ID__c,
                       PRM_Last_Name__c,
                       PRM_First_Name__c,
                       PRM_Country__c,
                       PRM_State_Province__c,
                       PRM_Account_URL__c,
                       PRM_Salesforce_ID__c
                FROM PRM_Registration_Request__c
                WHERE Id = :recordId
                LIMIT 1
            ];

            System.enqueueJob(new ER_DupCheck_CIMCallout(
                req,
                0,
                '5',
                '85',
                req.PRM_Account_URL__c,
                true
            ));
        }
    }
}