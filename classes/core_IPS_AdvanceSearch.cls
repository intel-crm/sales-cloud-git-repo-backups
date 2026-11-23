public with sharing  class core_IPS_AdvanceSearch{
  
    @AuraEnabled(cacheable=true)
    public static List<Case> getCases(
        String caseNumber,
        String status,
        String productName,
        String referenceId
    ) {
        String query;
        String condition = (String.isNotBlank(caseNumber)
            ? 'CaseNumber LIKE \'' + '%' + caseNumber + '%\''
            : '');

        

        condition += (String.isNotBlank(referenceId)
            ? (String.isNotBlank(condition) ? +' OR ' : '') +
              ' Core_Customer_Reference_ID__c LIKE \'' +
              '%' +
              referenceId +
              '%\''
            : '');

        condition += (String.isNotBlank(productName)
            ? (String.isNotBlank(condition) ? +' OR ' : '') +
              ' Asset.Name LIKE \'' +
              '%' +
              productName +
              '%\''
            : '');

        condition += (String.isNotBlank(status)
            ? (String.isNotBlank(condition) ? +' OR ' : '') +
              ' Status LIKE \'' +
              '%' +
              status +
              '%\''
            : '');

      

        System.debug('condition ' + condition);
        if (String.isNotBlank(condition)) {
            query =
                'SELECT CaseNumber,Status,Subject,Account.Name,Contact.Name,Priority,Asset.Name FROM Case WHERE ' +
                condition +
                ' ORDER BY CaseNumber';
        } else {
            query = 'SELECT CaseNumber,Status,Subject,Account.Name,Contact.Name,Priority,Asset.Name FROM Case ORDER BY CaseNumber LIMIT 200';
        }
        System.debug('Query ----> '+query);

        List<Case> records = Database.query(query);
        return records;
    }
}