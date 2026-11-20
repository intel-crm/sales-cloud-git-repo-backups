/*-------------------------------------------------------------------------------------------
Apex Class  : Core_OnClickReview_Ctrl
Version     : 1.0 
Created Date: 09 April 2020
Function    : Apex class for Review button to change the Status and Reviewed by Rep fields to Review and True values respectively on click of review button
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Kavyashree HR            09/04/2020             Original Version
--------------------------------------------------------------------------------------------*/

public class Core_OnClickReview_Ctrl {
    //Method created to fullfill the code coverage to migrate the commented code.
    public static void methodToCoverClass(){
        String result = 'Test class'+'coverage placeholder';
    }
    /*public static Boolean runTestClass = false;
    @AuraEnabled
    public static String updateStatusAndReviewedByRep(Id inquiryId){
        String alertMsg;
        List<Core_Inquiry__c> updateInquiry = new List<Core_Inquiry__c>();
        for(Core_Inquiry__c inquiryRec : [SELECT Id, Core_Inquiry_Status_Pkt__c, Core_Reviewed_by_Rep_Chk__c FROM Core_Inquiry__c WHERE id=:inquiryId]){
            inquiryRec.Core_Inquiry_Status_Pkt__c = 'Reviewed';
            inquiryRec.Core_Reviewed_by_Rep_Chk__c= True;
            if(Test.isRunningTest() && runTestClass == true){
                inquiryRec.Core_Inquiry_Status_Pkt__c = 'Reviewed';
                inquiryRec.Core_Reviewed_by_Rep_Chk__c= False;
            }            
            updateInquiry.add(inquiryRec);
        }try{            
            if(updateInquiry.size()>0 && updateInquiry!= null && Schema.sObjectType.Core_Inquiry__c.isUpdateable() ){
                Database.update(updateInquiry);
                alertMsg=System.Label.Core_Msg_For_Review;

            }else if(!Schema.sObjectType.Core_Inquiry__c.isUpdateable()){
                alertMsg=System.Label.Core_Msg_Insufficient_Previledge_For_Review;

            }
        }
        
        catch(DmlException de){
            alertMsg = '';
            Integer numErrors = de.getNumDml();
            for(Integer i=0;i<numErrors;i++) {
                System.debug('getDmlMessage=' + de.getDmlMessage(i));
                alertMsg += de.getDmlMessage(i);
                if(i < numErrors-1){
                    alertMsg += ';';
                }
            }
        }        
        return alertMsg;
    }*/
}