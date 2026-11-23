public class Pricing_BillingStartDateUpdateThroughBRE {
        //@future(callout=true)
    @InvocableMethod(callout=true)
    public static void autoPopulateBillingStartDate(List<Id> qliIdLst){ 
       try{
        List<SBQQ__QuoteLine__c> qliLst = [select id,SBQQ__Quote__r.SBQQ__Account__r.Name,Pricing_Billing_Start_Date_Dt__c from SBQQ__QuoteLine__c where id in :qliIdLst];
        System.debug('qliLst :' + qliLst);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:IQR_Access_Test_Cred/services/data/v55.0/actions/custom/runDecisionMatrix/Pricing_BillingStartDateByAccount');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        InputLst reqInput = new InputLst();
        reqInput.inputs = new List<Inputs>();
        for(SBQQ__QuoteLine__c qli:qliLst){
            System.debug('Account name'+qli.SBQQ__Quote__r.SBQQ__Account__r.Name);
            Inputs input = new Inputs();
            input.Account = qli.SBQQ__Quote__r.SBQQ__Account__r.Name;
            reqInput.inputs.add(input);
        }
        System.debug(reqInput);
        request.setBody(JSON.serialize(reqInput));
        HttpResponse response = http.send(request);
        System.debug('code :' +response.getStatusCode());
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
            List<BreWrapper> json = (List<BreWrapper>) JSON.deserialize(response.getBody(), List<BREWrapper>.class);
            integer i = 0;
            for(SBQQ__QuoteLine__c qli:qliLst){
                system.debug('date :' +qli.Pricing_Billing_Start_Date_Dt__c);
                system.debug('days before if :' +json[i].outputValues.BillingStartDate);
                if(json[i].outputValues.BillingStartDate != null){
                    system.debug('days :' +json[i].outputValues.BillingStartDate);
                    DateTime billingDate = qli.Pricing_Billing_Start_Date_Dt__c;
                    Date myDate = date.newinstance(billingDate.year(), billingDate.month(), billingDate.day());
                    Date newDate = mydate.addDays(-(Integer.valueOf(json[i].outputValues.BillingStartDate)));
                    system.debug('newDate :'+newDate);
                    qli.Pricing_Billing_Start_Date_Dt__c = newDate;
                }
                i++;
            }
            if(!qliLst.isEmpty()){
                update qliLst;
            }
            
        }
    }
    catch(Exception e){
        Pricing_Tender_Utility.logError(e);
    }
    }
    public class InputLst{
        public List<Inputs> inputs{get;set;}
    }
    
    public class Inputs {
        public String Account{get;set;}
    }
    
    public class BREWrapper{
        public String actionName{get;set;}
        public Errors errors{get;set;}
        public String isSuccess{get;set;}
        public OutputValue outputValues{get;set;}
        public Integer version{get;set;}
    }
    public class OutputValue{
        public Decimal BillingStartDate{get;set;}
    }
    public class Errors{
        public String statusCode{get;set;}
        public String message{get;set;}
        public List<String> fields{get;set;}
    }

}