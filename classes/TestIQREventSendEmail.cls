public class TestIQREventSendEmail {
    //a9U2D000000PpmnUAC
    //TestIQREventSendEmail.updateQuoteLine(Id.valueOf('a9U2D000000PpmnUAC'));
    @Future
    public static void updateQuoteLine(Id recId){
        
       List<SBQQ__QuoteLine__c> qli = [SELECT id,Name,Pricing_Status_Nm__c FROM SBQQ__QuoteLine__c WHERE id= :recId];
        if(qli.size() > 0){
            qli[0].Pricing_Status_Nm__c = 'Rejected';
            update qli;
        }
    }
}