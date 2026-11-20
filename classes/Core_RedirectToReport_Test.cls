/**************************************************************************************
*Apex Class Name:Core_RedirectToReport_Test
*Version        :1.0
*Created Date   :07/02/2018
*Modification Log :
*Developer                   Date                  Description
* ----------------------------------------------------------------------------                 
*Laxmana Lenka              07/02/2018             Initial Revision
*************************************************************************************/
@isTest
public class Core_RedirectToReport_Test {
    
    public static List < Opportunity > lstOpportunity = new List < Opportunity > ();
     
     /*
     * Method name  : testredirectreport
     * Description  : test method to cover Core_RedirectToReport class
     * Return Type  : VOID
     * Parameter    : NONE
     */
     
    static testMethod void testredirectreport() {
        Core_Sales_Report_URL__c reportSettings1  = new Core_Sales_Report_URL__c(Name='Goal_Credit', Core_Report_URL__c='00O2D000000JI2y' );
        insert reportSettings1  ;
         
        Core_Sales_Report_URL__c reportSettings2  = new Core_Sales_Report_URL__c(Name='Milestone_Credit', Core_Report_URL__c='00Oo0000004d1eDEAQ' );
        insert reportSettings2  ;
         
        Core_Sales_Report_URL__c reportSettings3  = new Core_Sales_Report_URL__c(Name='Product_Credit', Core_Report_URL__c='00Oo0000004d1eE' );
        insert reportSettings3  ;
        
        Core_Sales_Report_URL__c reportSettings4  = new Core_Sales_Report_URL__c(Name='Opportunity_Credit', Core_Report_URL__c='00Oo0000004d1eE' );
        insert reportSettings4  ;
 
        lstOpportunity = Core_Test_Utility.Core_Opportunity(1);        
        for (Opportunity opp: lstOpportunity) {
            //opp.AccountId = lstAccount[iRowNo].Id;
            opp.Core_Intel_Platform__c = 'Apollo Lake D';                      
        }         
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(lstOpportunity[0]);
         //DWG EOL Temporary fix - switch to be added | Permanent fix - code to be re-configured
        Core_RedirectToReport reportctrl = new Core_RedirectToReport (sc);
        reportctrl.isClassic=False;
        reportctrl.MCPageRef();
        reportctrl.DWGPageRef();
        reportctrl.PCPageRef();
        reportctrl.OppCPageRef();
                  
        Core_RedirectToReport reportctrl2 = new Core_RedirectToReport (sc);
        reportctrl2.isClassic=True;
        reportctrl2.MCPageRef();
        reportctrl2.DWGPageRef();
        reportctrl2.PCPageRef();
        reportctrl2.OppCPageRef();
     }
}