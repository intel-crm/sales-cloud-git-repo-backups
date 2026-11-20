/***************************************************************************************************************************************
Apex Class Name     : PRM_ResponsibilitiesDataWrapper
Version             : 1.0
Created Date        : July 2020
Function            : This is the wrapper class to return the responsibilities confirmation data for post Onboarding.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Avanish                        18th`-July-2020                     
*************************************************************************************************************************************/

public with sharing class PRM_ResponsibilitiesDataWrapper {
    
    public String stepId;	//helpers.id()
    public String title;	//Verify Roles and responsibilities
    public String imageUrl;
    public List<cls_content> content = new List<cls_content>();
    public List<cls_tableData> tableData = new List<cls_tableData>();
    public cls_closeModalAndRedrirectLinkData closeModalAndRedrirectLinkData;
    public cls_footerLinkData footerLinkData;
    
    public class cls_content {
        public String type;	//richtext
        public String body;	//Test
        public cls_content(String type, String body){
            this.type = type;
            this.body = body;
        }
    }
    
    public class cls_tableData {
        public boolean highlight;
        public String responsibility;	//Partner Admin
        public String employee;	//Julia Go(You)
        public cls_tableData(Boolean highlight, String responsibility, String employee){
            this.highlight = highlight;
            this.responsibility = responsibility;
            this.employee = employee;
        }
    }
    
    public class cls_closeModalAndRedrirectLinkData {
		public String label; // "Close and Go to Partner Portal";
		public String externalUrl; //"#closeFormAndRedirectLinkData";
	}
    
    public class cls_footerLinkData {
		public String label;	//Manage Responsibilities
		public String externalUrl;	//#
		public String communityPage;	//
		public String objectPage;	//
		public String recordId;	//
	}
}