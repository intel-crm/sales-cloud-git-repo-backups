/*-------------------------------------------------------------------------------------------
Apex Class  : Core_Claim_Prospect_test
Version     : 1.0  
Created Date: 22 Sep 2020
Function    : Apex test class for Claim button to change the ownership of record to loggrdin user on click of claim button
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh                 22/09/2020             Original Version
--------------------------------------------------------------------------------------------*/
@isTest
public class Core_Claim_Prospect_Test {
    
    static testmethod void prospectClaim(){        
        Core_Prospect__c prospectrec= new Core_Prospect__c();
        prospectrec.Core_URLElectronicAddressTxt__c='www.google.com';
        prospectrec.Core_Notes_Txt__c='Test Prospect Notes';
        prospectrec.Core_Source_Pkt__c  ='Test Prospect Source';
        insert prospectrec;
        
        Core_Claim_Prospect.UpdateOwnertoQueue(prospectrec.id);
        Core_Claim_Prospect.UpdateOwnertoQueue(prospectrec.id);       
    }   
    
     /*
     * Method name  : claimProspectCatchBlock
     * Description  : test method to check claim button
     * Return Type  : Void
     * Parameter    : NA
     */
    static testmethod void claimProspectCatchBlock(){        
        Core_Prospect__c prospectrec= new Core_Prospect__c();
        prospectrec.Core_URLElectronicAddressTxt__c='www.google.com';
        prospectrec.Core_Notes_Txt__c='Test Prospect Notes';
        prospectrec.Core_Source_Pkt__c  ='Test Prospect Source';
        insert prospectrec;
        Core_Claim_Prospect.UpdateOwnertoQueue(prospectrec.id);
        prospectrec.Core_Status_Pkt__c = 'Converted';
        prospectrec.Core_Is_Converted_Chk__c = true;
        prospectrec.Core_Converted_Date__c = System.now();        
        update prospectrec;   
        Test.starttest();     
            Core_Claim_Prospect.UpdateOwnertoQueue(prospectrec.id); 
        Test.stoptest();       
    } 
}