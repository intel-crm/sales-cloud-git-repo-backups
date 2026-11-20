/**************************************************************************************
Apex Class Name:Core_RedirectToReport 
Created Date:2nd JUL 2018
Function    :Redirecting to produccredit, milestone credit and goal credit report. Get all the custom setting report Ids.
Modification Log :
* Developer           Date               Description
* ----------------------------------------------------------------------------   
* Laxmana Lenka      Jul 2, 2018         Initial version
*************************************************************************************/

public class Core_RedirectToReport{
    
    //Variable to hold reportid
    Public String goalCreditId {get; set;}
    Public String milestoneCreditId {get; set;}
    Public String productCreditId {get; set;}
    public String recordId{get;set;}
    public boolean isClassic;
    Public String oppCreditId {get; set;}
    
    /*
     * Method name  : Core_RedirectToReport
     * Description  : The extension constructor get report IDs for ProductCredit, Milestone credit and Goal credit from the custon setting 
     * Return Type  : NA
     * Parameter    : ApexPages.StandardController
     */
    public Core_RedirectToReport(ApexPages.StandardController controller) {
        
        recordId = controller.getId();
        String uiTheme;
        //added to escape this code for the test methods to avoid error     
        if(!test.isRunningTest()){
            uiTheme = UserInfo.getUiThemeDisplayed();
        }
        //checks if the user is in classic or logged into lightning experience.
        if(uiTheme == 'Theme3'){
            isClassic = true;
        }else 
            isClassic = false;
        Map<String, Core_Sales_Report_URL__c> mapReport = Core_Sales_Report_URL__c.getAll();
        goalCreditId = mapReport.get('Goal_Credit').Core_Report_URL__c;
        milestoneCreditId = mapReport.get('Milestone_Credit').Core_Report_URL__c;
        productCreditId = mapReport.get('Product_Credit').Core_Report_URL__c;
        oppCreditId = mapReport.get('Opportunity_Credit').Core_Report_URL__c;
    }
    /*
     * Method name  : DWGPageRef
     * Description  : Redirect to deal win goal credit report
     * Return Type  : PageReference
     * Parameter    : none
     */
    //DWG EOL Temporary fix - switch to be added | Permanent fix - code to be re-configured
    public PageReference DWGPageRef(){
        PageReference pageRef;
        if(isClassic){
            pageRef = new PageReference('/'+goalCreditId+'?pv0='+recordId);
        }else{
            pageRef = new PageReference('/one/one.app#/sObject/'+goalCreditId+'/view?fv0='+recordId);
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /*
     * Method name  : MCPageRef
     * Description  : Redirect to milestone credit report
     * Return Type  : PageReference
     * Parameter    : none
     */
    public PageReference MCPageRef(){
        PageReference pageRef;
        if(isClassic){
            pageRef = new PageReference('/'+milestoneCreditId+'?pv0='+recordId);
        }else{
            pageRef = new PageReference('/one/one.app#/sObject/'+milestoneCreditId+'/view?fv0='+recordId);
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    /*
     * Method name  : PCPageRef
     * Description  : Redirect to Product credit report
     * Return Type  : PageReference
     * Parameter    : none
     */
    public PageReference PCPageRef(){
        PageReference pageRef;
        if(isClassic){
            pageRef = new PageReference('/'+productCreditId+'?pv0='+recordId);
        }else{
            pageRef = new PageReference('/one/one.app#/sObject/'+productCreditId+'/view?fv0='+recordId);
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    /*
     * Method name  : PCPageRef
     * Description  : Redirect to Product credit report
     * Return Type  : PageReference
     * Parameter    : none
     */
    public PageReference OppCPageRef(){
        PageReference pageRef;
        if(isClassic){
            pageRef = new PageReference('/'+oppCreditId+'?pv0='+recordId);
        }else{
            pageRef = new PageReference('/one/one.app#/sObject/'+oppCreditId+'/view?fv0='+recordId);
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
}