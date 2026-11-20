/**************************************************************************************
Apex Class Name:  Core_Reject_Prospect_Test
Version     : 1.0 
Created Date: 23 Sep 2020
Function    : test class for the class Core_Reject_Prospect
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kavyashree H R            09/23/2020              Original Version
*************************************************************************************/
@isTest
public class Core_Reject_Prospect_Test{
     private static Core_Prospect__c prospectrec {
        get;
        set;
     }
     /*
     * Method name  : setup
     * Description  : Method to setup test data prospect rejection
     * Return Type  : None
     * Parameter    : None
     */
     static void setup(){
         prospectrec= new Core_Prospect__c();
         prospectrec.Core_URLElectronicAddressTxt__c='www.google.com';
         prospectrec.Core_Notes_Txt__c='Test Prospect Notes';
         prospectrec.Core_Source_Pkt__c  ='Sales AI';
         insert prospectrec;
     }
     /*
     * Method name  : rejectProspect
     * Description  : test method to check reject button
     * Return Type  : Void
     * Parameter    : NA
     */ 
    static testmethod void rejectProspect(){        
        setup();
        Test.starttest();
            Core_Claim_Prospect.UpdateOwnertoQueue(prospectrec.id);
            Core_Reject_Prospect.updateStatusToDisqualified(prospectrec.id, 'Not Target Profile',''); 
            Core_Reject_Prospect.ReviveProspect(prospectrec.id);   
        Test.stoptest();       
    }
    
    /*
     * Method name  : rejectProspectCatchBlock
     * Description  : test method to check reject button
     * Return Type  : Void
     * Parameter    : NA
     */
    static testmethod void rejectProspectCatchBlock(){        
        setup();
        Core_Claim_Prospect.UpdateOwnertoQueue(prospectrec.id);
        prospectrec.Core_Status_Pkt__c = 'Converted';
        prospectrec.Core_Is_Converted_Chk__c = true;
        prospectrec.Core_Converted_Date__c = System.now();        
        update prospectrec;   
        Test.starttest();     
            Core_Reject_Prospect.updateStatusToDisqualified(prospectrec.id, 'Not Target Profile',''); 
        Test.stoptest();       
    }
    
    /*
     * Method name  : alreadyRejectProspect
     * Description  : test method to check reject button
     * Return Type  : Void
     * Parameter    : NA
     */
    static testmethod void alreadyRejectProspect(){        
        setup();
        Core_Claim_Prospect.UpdateOwnertoQueue(prospectrec.id);
        prospectrec.Core_Status_Pkt__c = 'Converted';
        prospectrec.Core_Is_Converted_Chk__c = true;
        prospectrec.Core_Converted_Date__c = System.now();
        update prospectrec;
        Test.starttest();
            Core_Reject_Prospect.updateStatusToDisqualified(prospectrec.id, 'Not Target Profile',''); 
            Core_Reject_Prospect.checkifDisqualifiedProspect(prospectrec.id);
            Core_Reject_Prospect.ReviveProspect(prospectrec.id);     
        Test.stoptest(); 
    }

}