/*************************************************************************************************
Class Name  : Core_WavePipelineAnalysis_Controller
Created Date: Oct 31, 2016
Function    : Controller for the simple Pipeline Analysis VF page, which redirects to the dashboard
              in the full-blown Wave UI
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Dave Hood         10/31/2016    Original version
* Vivek T S         01/09/2018    Added the condition to show the Pipeline Management URL - US91703 
**************************************************************************************************/
public class Core_WavePipelineAnalysis_Controller {
    
    private String pageName = '';
    
    public Core_WavePipelineAnalysis_Controller() {
        
        // Get the name of the page, between "apex/" and the first question mark (if any), then remove any trailing parameters
        pageName = ApexPages.currentPage().getUrl().split('apex/')[1];
        pageName = pageName.split('\\?')[0];
    }
    
    public PageReference init() {
        
        // Insert a "hit" into our tracking table
        Core_Wave_Dashboard_View__c hit = new Core_Wave_Dashboard_View__c(
            Core_User__c = UserInfo.getUserId(),
            Core_Dashboard_Page__c = pageName,
            Core_View_Date_Time__c = DateTime.now()
        );
        insert hit;
        
        // Redirect to the dashboard
        // Start - Added the condition to show the Pipeline Management URL *US91703* 
        PageReference pageRef = new PageReference(Label.Core_Wave_Pipeline_Analysis_URL);
      
        If (pageName == 'Core_WavePipelineManagement') {
            pageRef = new PageReference(Label.Core_Wave_Pipeline_Management_URL);
        }   
        // End - Added the condition to show the Pipeline Management URL *US91703* 
        return pageRef;
    }
}