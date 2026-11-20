public class PCC_UpdateOppLineItem implements Queueable {
    private Id recordId;
    
    public PCC_UpdateOppLineItem(Id recId) {
        recordId = recId;
    }
    
    public void execute(QueueableContext context) {
        // Perform the time-consuming logic here
        Core_DDR_Cancel_Product_Controller.updateOppLineItem(recordId);
    }
}