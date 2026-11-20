/*
Author: Sai Thotakura
Onyx Team
Functionality: Trigger Handler calls the helper class
*/
public class PMP_RichMediaAssetTriggerHandler extends TriggerHandler{
    
    //Check if the trigger is active or not
    boolean triggerFlag = isActive('PMP_RichMediaAsset_Trigger'); 
    boolean fetchfilefromUrlFlag = isActive('PMP_FetchFilefromUrl_RichMedia');
    
    public override void beforeUpdate() {
        
        if(triggerFlag) {
            if(fetchfilefromUrlFlag) {
                PMP_RichMediaAssetTriggerHelper.oldPdfUpdateDateCapture(trigger.oldMap,trigger.new);
            }
        } 
    }
    
    public override void afterUpdate() { 
        if(triggerFlag) {
            if(fetchfilefromUrlFlag) {
                PMP_RichMediaAssetTriggerHelper.callrichmediadownload(trigger.oldMap,trigger.new);
            }
        }
    }
}