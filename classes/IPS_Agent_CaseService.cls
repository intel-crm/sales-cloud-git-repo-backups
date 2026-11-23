public with sharing class IPS_Agent_CaseService {

    public static void updateCaseStatus(
        String caseNumber,
        String status
    ) {

        Case c = IPS_Agent_CaseSelector.getCaseByNumber(
            caseNumber
        );

        c.Status = status;

        update c;
    }

    public static void closeCase(
        String caseNumber,
        String resolution,
        String closureComment
    ) {

        Case c = IPS_Agent_CaseSelector.getCaseByNumber(
            caseNumber
        );

        c.Status = 'Closed';
        c.Core_IPS_Resolution__c = resolution;
        c.Core_Closure_Comment__c = closureComment;

        update c;
    }

    public static void addComment(
    String caseNumber,
    String comment
) {

    if(String.isBlank(comment)) {

        throw new IPS_Agent_Exception(
            'Comment is required'
        );
    }

    Case c = IPS_Agent_CaseSelector.getCaseByNumber(caseNumber);

    Core_IPS_Case_Comments__c record = new Core_IPS_Case_Comments__c();

    record.Core_IPS_Case__c = c.Id;

    record.Core_IPS_Comment__c =
        comment;

    insert record;
}
}