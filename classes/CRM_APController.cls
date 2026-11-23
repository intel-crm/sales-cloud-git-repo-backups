public class CRM_APController {
    @AuraEnabled(cacheable=true)
    public static List<CRM_Hot_Button__c> getHotButtons(Id accountPlanId) {
        system.debug('line 4'+accountPlanId);
        return [SELECT Id, Name, CRM_Description__c, CRM_Priority__c FROM CRM_Hot_Button__c WHERE CRM_Account_Plan__c = :accountPlanId];
    }

    @AuraEnabled
    public static void saveHotButtons(List<CRM_Hot_Button__c> hotButtons) {
            try {
            System.debug('Received Hot Buttons for Save: ' + JSON.serialize(hotButtons));

            for (CRM_Hot_Button__c hb : hotButtons) {
                if (hb.CRM_Account_Plan__c == null) {
                    System.debug('Missing Account Plan ID for Hot Button: ' + hb.Name);
                    throw new AuraHandledException('Account Plan ID is required.');
                }
            }

            upsert hotButtons;
            System.debug('Hot Buttons Saved Successfully');
        } catch (Exception e) {
            System.debug('Error in saving Hot Buttons: ' + e.getMessage());
            throw new AuraHandledException('Failed to save Hot Buttons: ' + e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
public static List<String> getPriorityPicklistValues() {
    Schema.DescribeFieldResult fieldResult = CRM_Hot_Button__c.CRM_Priority__c.getDescribe();
    List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
    List<String> values = new List<String>();
    
    for (Schema.PicklistEntry entry : picklistValues) {
        values.add(entry.getValue());
    }
    return values;
}
}