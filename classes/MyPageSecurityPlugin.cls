global class MyPageSecurityPlugin implements SBQQ.PageSecurityPlugin2 {
    public Boolean isFieldEditable(String pageName, Schema.SObjectField field) {
        return null;
    }
    
    public Boolean isFieldEditable(String pageName, Schema.SObjectField field, SObject record) {
        return null;
    }
    
    public Boolean isFieldVisible(String pageName, Schema.SObjectField field) {
        return null;
    }
    
    public Boolean isFieldVisible(String pageName, Schema.SObjectField field, SObject record) {
       if ((pageName == 'EditLines') && (record instanceof SBQQ__QuoteLine__c)) {
            SBQQ__QuoteLine__c line = (SBQQ__QuoteLine__c)record;
            if (field != SBQQ__QuoteLine__c.SBQQ__ProductName__c && ((SBQQ__QuoteLine__c)record).recordTypeId == '0122D000000XWs2QAG') {
                System.debug('POC test '+((SBQQ__QuoteLine__c)record).recordTypeId);
                return false;
            }
        }
        
        return null;
    }
    public Boolean isFieldVisibleForObject(String pageName, Schema.SObjectField field, SObject record){
       /* if ((pageName == 'EditLines') && (record instanceof SBQQ__QuoteLine__c)) {
            SBQQ__QuoteLine__c line = (SBQQ__QuoteLine__c)record;
            if (field != SBQQ__QuoteLine__c.SBQQ__ProductName__c) {
                return false;
            }
        }
        */
        return null;
    }
}