/****************************************************************************************************
Apex Class Name : Core_DRR_ApproveAllPendingProducts
Version         : 1.0 
Created Date    : 06/06/2018
Function        :This class used to Approves all the Pending Products after data validation on Design Registration products.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Rajesh kumar                 09/08/2017            Created
*****************************************************************************************************/
public class Core_DRR_ApproveAllPendingProducts {
    public String alertMessage{get;set;}
    public String retUrl{get;set;}  
    public String DesignRegpProdId;  
     List<Core_Design_Registration_Product__c> allDesignRegProdslist;
    List<Core_Design_Registration_Product__c> allDesignRegProdsInactivelist;
    public Core_DRR_ApproveAllPendingProducts (ApexPages.StandardSetController stdSetCtrl){
         allDesignRegProdslist=new List<Core_Design_Registration_Product__c>();
         DesignRegpProdId=apexpages.currentpage().getParameters().get('Id');
         system.debug('DesignRegpProdId'+DesignRegpProdId);
         allDesignRegProdslist=[SELECT id,Core_Design_Product_Status_Nm__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c=:DesignRegpProdId AND Core_Design_Product_Status_Nm__c = 'Pending' AND Core_Locked_Ind__c = false];
         allDesignRegProdsInactivelist=[SELECT id,Core_Design_Product_Status_Nm__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c=:DesignRegpProdId AND Core_Active_Status__c = false AND Core_Locked_Ind__c = false];       
         system.debug('allDesignRegProdslist'+allDesignRegProdslist);
        system.debug('allDesignRegProdsInactivelist'+allDesignRegProdsInactivelist.size());
    }  
    //The below method is being called when user is clicked on ApproveAllPendingProducts List button //
  public PageReference approvalAllpendingProd(){      
        List<Core_Design_Registration_Product__c> updateDesignprodList=new List<Core_Design_Registration_Product__c>();
        retUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/' +DesignRegpProdId;   
      if(allDesignRegProdsInactivelist.size() > 0){
               alertMessage ='There are  Inactive Products added on this Design Registration, please remove the inactive products to proceed with Approval.';
      }
      else{
      if(allDesignRegProdslist.size() == 0){
               alertMessage ='There are no pending products on this Design Registration to Approve.';
      }
      
         else{
             for(Core_Design_Registration_Product__c desp:allDesignRegProdslist){
                desp.Core_Design_Product_Status_Nm__c='Approved';
                updateDesignprodList.add(desp);
               }
              
            try{
                update updateDesignprodList;
                alertMessage = updateDesignprodList.size() + ' Pending Design Registration Products Approved successfully.';
            }catch(Exception e){
               alertMessage='An error has occurred updating Desgin Registration Products'+e.getMessage();
            } 
         }}
        return null;
    }
}