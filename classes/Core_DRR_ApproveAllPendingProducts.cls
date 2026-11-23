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
    public Core_Design_Registration__c DDRRecord;
     List<Core_Design_Registration_Product__c> allDesignRegProdslist;
    List<Core_Design_Registration_Product__c> allDesignRegProdsInactivelist;
    public Core_DRR_ApproveAllPendingProducts (ApexPages.StandardSetController stdSetCtrl){
         allDesignRegProdslist=new List<Core_Design_Registration_Product__c>();
         DesignRegpProdId=apexpages.currentpage().getParameters().get('Id');
         system.debug('DesignRegpProdId'+DesignRegpProdId);
        DDRRecord=[select Id, OwnerId,Core_Vertical_Market_Nm__c,Core_Intel_Platform_Nm__c,Core_End_Customer_Account_Id__r.RecordType.Name,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c, RecordTypeId,Core_End_Customer_Account_Owner__c,Core_End_Customer_Account_Id__c from Core_Design_Registration__c where Id =: DesignRegpProdId];               

         allDesignRegProdslist=[SELECT id,Core_Design_Product_Status_Nm__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c=:DesignRegpProdId AND Core_Design_Product_Status_Nm__c = 'Pending' AND Core_Locked_Ind__c = false];
         allDesignRegProdsInactivelist=[SELECT id,Core_Design_Product_Status_Nm__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c=:DesignRegpProdId AND Core_Active_Status__c = false];       
         system.debug('allDesignRegProdslist'+allDesignRegProdslist);
        system.debug('allDesignRegProdsInactivelist'+allDesignRegProdsInactivelist.size());
    }  
    //The below method is being called when user is clicked on ApproveAllPendingProducts List button //
  public PageReference approvalAllpendingProd(){      
        List<Core_Design_Registration_Product__c> updateDesignprodList=new List<Core_Design_Registration_Product__c>();
        retUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/' +DesignRegpProdId;   
		//  Core_Design_Registration__c designReg=getDDRsoqlquery(DesignRegpProdId);
        String InactiveLovFields=Core_DDR_Accept_Approve_Reject_Design.ValidateInactiveLOVS(DDRRecord);
        system.debug('InactiveLovList*******'+InactiveLovFields);
      if (allDesignRegProdslist.size() == 0){   
               alertMessage ='There are no pending products on this Design Registration to Approve.';
          }
      else if(allDesignRegProdsInactivelist.size() > 0){ 
               alertMessage ='There are  Inactive Products added on this Design Registration, please remove the inactive products to proceed with Approval.';
      }else if(InactiveLovFields !=''){ 
              alertMessage='Current selected values of the following fields'+'"'+InactiveLovFields+'"'+'on this record are inactive. Please select a valid value and retry submission ';
          } 
      else if(DDRRecord.Core_End_Customer_Account_Id__r.RecordType.Name=='Inactive Account' 
                  || DDRRecord.Core_End_Customer_Account_Id__r.RecordType.Name=='CoMarketing' ){
            alertMessage='Current selected value of the field'+'"'+ 'End Customer Account'+'"'+' on this record is not a valid value anymore. Please select a valid value and retry submission ';
          
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
         }
      
        return null;
    }
}