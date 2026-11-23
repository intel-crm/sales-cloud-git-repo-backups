public class PCC_ApproveRejectChangeLineItems {
 public static String alertMessage{get;set;}
 public static String retUrl{get;set;}
 public String commentText { get; set; }   
 public String changeRegId; 
 public List<PCC_Deal_Change_Request_Line_Item__c> lineItemsList = new List<PCC_Deal_Change_Request_Line_Item__c>();   
     public PCC_ApproveRejectChangeLineItems(){
        // Constructor
    }
     
    public PCC_ApproveRejectChangeLineItems(ApexPages.StandardSetController stdSetCtrl) {
        commentText = '';  
        changeRegId = apexpages.currentpage().getParameters().get('Id');
        List<PCC_Deal_Change_Request_Line_Item__c> selectedProducts = stdSetCtrl.getSelected();
        if(selectedProducts!=null && selectedProducts.size()>0) {
         lineItemsList=[select id,PCC_PSAM_Comment__c,PCC_Approval_Status__c from  PCC_Deal_Change_Request_Line_Item__c where id in :selectedProducts and PCC_Approval_Status__c ='Pending'];
                   
        }else{
        lineItemsList=[select id,PCC_PSAM_Comment__c,PCC_Approval_Status__c from  PCC_Deal_Change_Request_Line_Item__c where PCC_Approval_Status__c ='Pending'];
        
        }
    }
    public PageReference setRetUrl() {
        retUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/' + changeRegId;
        PageReference pageRef = new PageReference(retUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }
    public PageReference approveLineItems(){
     if (isCommentTextBlank()) {
                alertMessage = LabelConfiguration__mdt.getInstance('PCC_EnterComments').value__c;
            }
            else if(lineItemsList.size() == 0){
                alertMessage = LabelConfiguration__mdt.getInstance('PCC_SelectProductsApprove').value__c;
            }
   else { 
   alertMessage =  LabelConfiguration__mdt.getInstance('PCC_LineItemsSuccess').value__c;
   }
        List<PCC_Deal_Change_Request_Line_Item__c> updateLineItems = new List<PCC_Deal_Change_Request_Line_Item__c>();
        for(PCC_Deal_Change_Request_Line_Item__c lineItem :lineItemsList){
           lineItem.PCC_PSAM_Comment__c = lineItem.PCC_PSAM_Comment__c + commentText;
            lineItem.PCC_Approval_Status__c = 'Approved';
            updateLineItems.add(lineItem);
            
        } 
        if(updateLineItems.size() >0){
            update updateLineItems;
        }
       return null;    
    }
    
    public PageReference RejectLineItems(){
       if (isCommentTextBlank()) {
       
                alertMessage = LabelConfiguration__mdt.getInstance('PCC_EnterComments').value__c;
            }
            else if(lineItemsList.size() == 0){
                alertMessage = LabelConfiguration__mdt.getInstance('PCC_SelectPendingProducts').value__c;
            }
   else { 
   alertMessage =  LabelConfiguration__mdt.getInstance('PCC_LineItemsRejectSuccess').value__c;
   }List<PCC_Deal_Change_Request_Line_Item__c> updateLineItems = new List<PCC_Deal_Change_Request_Line_Item__c>();
        for(PCC_Deal_Change_Request_Line_Item__c lineItem :lineItemsList){
           lineItem.PCC_PSAM_Comment__c = lineItem.PCC_PSAM_Comment__c + commentText;
            lineItem.PCC_Approval_Status__c = 'Rejected';
            updateLineItems.add(lineItem);
            
        } 
        if(updateLineItems.size() >0){
            update updateLineItems;
        }
       return null;    
    }
    
    private boolean isCommentTextBlank() {
        return String.isBlank(commentText);
    }
}