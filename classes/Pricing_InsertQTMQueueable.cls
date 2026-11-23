public class Pricing_InsertQTMQueueable implements Queueable {
    
    public List<Pricing_Quote_Team__c> qtmList {set;get;}
    public Pricing_InsertQTMQueueable(List<Pricing_Quote_Team__c> qtmList){
        this.qtmList = qtmList;
    }
    public void execute(QueueableContext qc){
        try{
            if(qtmList.size() > 0){
                insert qtmList;
            } 
        }catch(Exception exp){Pricing_Tender_Utility.logError(exp);}
        
    }
}