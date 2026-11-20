/************
* Name : Core_AAQC_Inquiry_Details_CTRL 
* Author : Nikhil Godhani
* Date Created : 28-November-2018
* Description : This is being used for showing successful message every time when 'Draft' case is saved
* Version Updates : 
*   
* Date          By                      User-Story                                  Details 
* 28-11-18      Nikhil                  US:77763 and US:77764                       Created
********************/

public with sharing class Core_AAQC_Inquiry_Details_CTRL{
    
    public Core_AAQC_Inquiry_Details_CTRL(ApexPages.StandardController controller){

        String showMessage = '' + ApexPages.currentPage().getParameters().get('message');
        String pageHeaderReferer = ApexPages.currentPage().getParameters().get('referer'); 
        
        if(pageHeaderReferer != null && pageHeaderReferer.containsIgnoreCase('askCommissionpage') && showMessage != 'null')
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, showMessage)); 
        }
        
        string showActualMessage;
        
        if(showMessage != null && showMessage =='ClosedYes'){
            showActualMessage = LABEL.Core_AAQC_Case_Close_Yes_Notification;
        }
        else if(showMessage != null && showMessage =='ClosedNo'){
            showActualMessage = LABEL.Core_AAQC_Case_Close_No_Notification;
        }
        
        if(pageHeaderReferer != null && pageHeaderReferer.containsIgnoreCase('CaseCloseOnEmail') && showActualMessage != null)
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, showActualMessage)); 
        }
    }
}