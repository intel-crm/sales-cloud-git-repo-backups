/******************************************************************************************************************************************
Class Name  : Core_opportunityproduct_listprice_contrl
Version     : 1.0 
Created Date: July 07, 2022
Function    : Showing the List Price history
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Mula Yeshwanth        07/07/2022   Original version
*****************************************************************************************************************************************/

public class Core_opportunityproduct_listprice_contrl {

    @AuraEnabled(cacheable=true)
    //OpportunityLineItem
    public static List<InactiveWrapper> getOpportunityLineItem(){
        List<InactiveWrapper> wrapperObjList = new List<InactiveWrapper> ();
      //return [Select id, PricebookEntry.Product2.Name, OldValue, NewValue, Field, PricebookEntry.Pricebook2Id from PricebookEntryHistory where Field = 'UnitPrice' and PricebookEntryId = ''];
      List<PricebookEntryHistory> pbList = [Select id, PricebookEntry.Product2.Name,CreatedBy.Name,createddate, OldValue, NewValue, Field, PricebookEntryId,PricebookEntry.Pricebook2Id from PricebookEntryHistory where Field = 'UnitPrice'];
        for(PricebookEntryHistory pbhis : pbList){
            InactiveWrapper inactObj= new  InactiveWrapper();
            inactObj.createdBy=pbhis.CreatedBy.Name;
              inactObj.createddate=pbhis.createddate;
              inactObj.oldValue=pbhis.OldValue;
              inactObj.newValue=pbhis.NewValue;
             wrapperObjList.add(inactObj);
        }
        
        System.debug('plist-'+pbList[0].CreatedBy.Name);
        //return [Select id, PricebookEntry.Product2.Name,CreatedBy.Name,createddate, OldValue, NewValue, Field, PricebookEntryId,PricebookEntry.Pricebook2Id from PricebookEntryHistory where Field = 'UnitPrice' and pricebookEntryId='01u2D000003pQKmQAM'];
    return wrapperObjList;
    }
    
   public class InactiveWrapper{

        @auraEnabled

        public String createdBy{get;set;}

        @auraEnabled

        public Datetime createdDate{get;set;}

        @auraEnabled

        public Object oldValue{get;set;}

        @auraEnabled

        public Object newValue{get;set;}
       
   }
}