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
public class PCC_DRR_ApproveAllPendingProducts {
     public String retUrl{get;set;}  
   // public String designRegId;  
    public static boolean isTrue{get;set;}
    public List<Core_Design_Registration_Product__c> designprods;
    public static Core_Design_Registration__c DDRRecord;
      /* public PCC_DRR_ApproveAllPendingProducts(Id designRegId){
         allDesignRegProdslist=new List<Core_Design_Registration_Product__c>();
         allDesignRegProdsInactivelist=new List<Core_Design_Registration_Product__c>();
         allDesignRegProdsInEligiblelist=new List<Core_Design_Registration_Product__c>();
       //  designRegId=apexpages.currentpage().getParameters().get('Id');
        DDRRecord=[SELECT Id, OwnerId,Core_Vertical_Market_Nm__c,Core_Opportunity_Id__r.StageName,Core_Intel_Platform_Nm__c,Core_End_Customer_Account_Id__r.RecordType.Name,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,Core_Design_Registration_Status_Nm__c, RecordTypeId,Core_End_Customer_Account_Owner__c,Core_End_Customer_Account_Id__c from Core_Design_Registration__c where Id =: designRegId];               

        designprods =[SELECT id, Core_Design_Product_Status_Nm__c, Core_DR_Eligible_Status__c,Core_Active_Status__c,Core_Locked_Ind__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c =: designRegId];
         
        for (Core_Design_Registration_Product__c designRegProd : designprods) {
            if (designRegProd.Core_Locked_Ind__c == false && designRegProd.Core_Design_Product_Status_Nm__c.equals('Pending')) {
               allDesignRegProdslist.add(designRegProd);
            }
            if (designRegProd.Core_DR_Eligible_Status__c == false && designRegProd.Core_Locked_Ind__c == false && designRegProd.Core_Design_Product_Status_Nm__c.equals('Pending')) {
                allDesignRegProdsInEligiblelist.add(designRegProd);
            } 
            if (designRegProd.Core_Active_Status__c == false && designRegProd.Core_Locked_Ind__c == false && designRegProd.Core_Design_Product_Status_Nm__c.equals('Pending')) {
                allDesignRegProdsInactivelist.add(designRegProd);
            }
        }
             
         system.debug('allDesignRegProdslist'+allDesignRegProdslist);
        system.debug('allDesignRegProdsInactivelist'+allDesignRegProdsInactivelist.size());
    }  */
   //To check the dr status before Approve All/Reject All DR products -->Shivini 
    public  static boolean Core_DR_Status(Core_Design_Registration__c recordddr)
    {
       
        if(recordddr.Core_Design_Registration_Status_Nm__c=='Cancelled'||recordddr.Core_Design_Registration_Status_Nm__c=='Rejected'||recordddr.Core_Design_Registration_Status_Nm__c=='Abandoned'|| recordddr.Core_Opportunity_Id__r.StageName=='Production Win'){
            isTrue= true;
            }
            else{
                isTrue= false;
            }
        return isTrue;
    }

    //The below method is being called when user is clicked on ApproveAllPendingProducts List button //
  @AuraEnabled 
  public static void approvalAllpendingProd(Id designRegId){  
        String alertMessage;    
        List<Core_Design_Registration_Product__c> allDesignRegProdslist = new List<Core_Design_Registration_Product__c>();
        List<Core_Design_Registration_Product__c> allDesignRegProdsInactivelist = new List<Core_Design_Registration_Product__c>();
        List<Core_Design_Registration_Product__c> allDesignRegProdsInEligiblelist = new List<Core_Design_Registration_Product__c>();
        Core_Design_Registration__c DDRRecord;
        List<Core_Design_Registration_Product__c> designprods = new List<Core_Design_Registration_Product__c>();
       //  designRegId=apexpages.currentpage().getParameters().get('Id');
       DDRRecord=[SELECT Id, OwnerId,Core_Vertical_Market_Nm__c,Core_Opportunity_Id__r.StageName,Core_Intel_Platform_Nm__c,Core_End_Customer_Account_Id__r.RecordType.Name,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,Core_Design_Registration_Status_Nm__c, RecordTypeId,Core_End_Customer_Account_Owner__c,Core_End_Customer_Account_Id__c from Core_Design_Registration__c where Id =: designRegId limit 1];               

        designprods =[SELECT id, Core_Design_Product_Status_Nm__c, Core_DR_Eligible_Status__c,Core_Active_Status__c,Core_Locked_Ind__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c =: designRegId];
         
        for (Core_Design_Registration_Product__c designRegProd : designprods) {
            if (designRegProd.Core_Locked_Ind__c == false && designRegProd.Core_Design_Product_Status_Nm__c.equals('Pending')) {
               allDesignRegProdslist.add(designRegProd);
            }
            if (designRegProd.Core_DR_Eligible_Status__c == false && designRegProd.Core_Locked_Ind__c == false && designRegProd.Core_Design_Product_Status_Nm__c.equals('Pending')) {
                allDesignRegProdsInEligiblelist.add(designRegProd);
            } 
            if (designRegProd.Core_Active_Status__c == false && designRegProd.Core_Locked_Ind__c == false && designRegProd.Core_Design_Product_Status_Nm__c.equals('Pending')) {
                allDesignRegProdsInactivelist.add(designRegProd);
            }
        }
             
         system.debug('allDesignRegProdslist'+allDesignRegProdslist);
        system.debug('allDesignRegProdsInactivelist'+allDesignRegProdsInactivelist.size()); 
        List<Core_Design_Registration_Product__c> updateDesignprodList=new List<Core_Design_Registration_Product__c>();
       // retUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/'  designRegId;   
		//  Core_Design_Registration__c designReg=getDDRsoqlquery designRegId);
        String InactiveLovFields=Core_DDR_Accept_Approve_Reject_Design.ValidateInactiveLOVS(DDRRecord);
        system.debug('InactiveLovList*******'+InactiveLovFields);
        Boolean drstatus=Core_DR_Status(DDRRecord);
        if(drstatus== true){
            alertMessage='Products cannot be added or edited.';

        }
      else if (allDesignRegProdslist.size() == 0){   
               alertMessage ='There are no pending products on this Design Registration to Approve.';
          }
      else if(allDesignRegProdsInactivelist.size() > 0){ 
               alertMessage ='There are  Inactive Products added on this Design Registration, please remove the inactive products to proceed with Approval.';
      }else if(allDesignRegProdsInEligiblelist.size() > 0){
               alertMessage ='There are  Ineligible Products added on this Design Registration, please remove the Ineligible products to proceed with Approval.';
      }
      else if(InactiveLovFields !=''){ 
              alertMessage='Current selected values of the following fields'+'"'+InactiveLovFields+'"'+'on this record are inactive. Please select a valid value and retry submission ';
          } 
      else if((DDRRecord.Core_End_Customer_Account_Id__r.RecordType.Name=='Inactive Account' 
                  || DDRRecord.Core_End_Customer_Account_Id__r.RecordType.Name=='CoMarketing')){
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
    }
}