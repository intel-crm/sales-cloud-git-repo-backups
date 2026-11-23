public class Pricing_Update_TPT_ResponseTime_Batch implements Database.Batchable<SObject>{
    
    public database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator([SELECT id,Pricing_First_SubmissionToResponse_Time__c,Pricing_Last_Submission_to_Response_Time__c,Pricing_TPT_Quote_Line_Number__r.Pricing_Last_Approved_Date_dt__c,Pricing_TPT_Quote_Line_Number__r.Pricing_Original_Submitted_Date_dt__c,Pricing_TPT_Quote_Line_Number__r.Pricing_Last_Submitted_Date_dt__c,Pricing_TPT_Change_Time__c, Pricing_TPT_Set_Time__c, Pricing_TPT_Age__c,Pricing_TPT_Status_Time__c
                                         FROM Pricing_Quote_Line_Status_Age__c ORDER BY CreatedDate DESC]);
    }
    
    public void execute(database.BatchableContext bc, List<Pricing_Quote_Line_Status_Age__c> scope){
       
        for(Pricing_Quote_Line_Status_Age__c tpt : scope){
            if(tpt.Pricing_TPT_Change_Time__c==null){
                if(tpt.Pricing_TPT_Quote_Line_Number__r.Pricing_Last_Approved_Date_dt__c!=null && tpt.Pricing_TPT_Quote_Line_Number__r.Pricing_Original_Submitted_Date_dt__c!=null){
                    tpt.Pricing_First_SubmissionToResponse_Time__c = QuoteLineBusinessLogic.calculateStatusAge(tpt.Pricing_TPT_Quote_Line_Number__r.Pricing_Original_Submitted_Date_dt__c, tpt.Pricing_TPT_Quote_Line_Number__r.Pricing_Last_Approved_Date_dt__c)/(60*60*1000);               
                }
                if(tpt.Pricing_TPT_Quote_Line_Number__r.Pricing_Last_Approved_Date_dt__c!=null && tpt.Pricing_TPT_Quote_Line_Number__r.Pricing_Last_Submitted_Date_dt__c!=null){
                    Decimal lastResponseInMillSecs = QuoteLineBusinessLogic.calculateStatusAge(tpt.Pricing_TPT_Quote_Line_Number__r.Pricing_Last_Submitted_Date_dt__c, tpt.Pricing_TPT_Quote_Line_Number__r.Pricing_Last_Approved_Date_dt__c);
                    tpt.Pricing_Last_Submission_to_Response_Time__c = (lastResponseInMillSecs/(60*60*1000));                
                } 
                
            }else{
                Decimal milliseconds = QuoteLineBusinessLogic.calculateStatusAge(tpt.Pricing_TPT_Set_Time__c, tpt.Pricing_TPT_Change_Time__c);            
            	tpt.Pricing_TPT_Status_Time__c = (milliseconds).Divide((60*60*1000), 2);
                tpt.Pricing_TPT_Age__c = getAge(milliseconds);
            }
        }
        update scope;
    }
    private static String getAge(Decimal milliseconds) {
        Double duration = milliseconds;
        Double d = Math.floor(duration/86400000); //Get whole days
        duration -= d*86400000;
        Double h = Math.floor(duration/3600000); //Get whole hours
        duration -= h*3600000;
        Double m = Math.floor(duration/60000);
        duration -= m*60000;
        Double s = Math.floor(duration/1000);
        return d.format()+' days '+h.format()+' hours '+ m.format() + ' minutes ' + s.format() +' seconds';
    }
    public void finish(database.BatchableContext bc){
        
    }
}