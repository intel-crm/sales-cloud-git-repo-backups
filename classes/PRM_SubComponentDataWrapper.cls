/***************************************************************************************************************************************
Apex Class Name     : PRM_SubComponentDataWrapper
Version             : 1.0
Created Date        : July 2020
Function            : This is the wrapper class to return the sub component data for post Onboarding.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                        4th`-July-2020                     US640819-IPA - POST-LAUNCH [ONBOARDING]: Create an On-boarding experience for new and existing user to accept the T&Cs
* Srishty                        20th-Aug-2020                     US761138-Update text labels on onboarding based on PS changes
* Srishty                        20th-Aug-2020                     DE89081: Updating checkbox text through Partner Terms and Condition Object
*************************************************************************************************************************************/

public class PRM_SubComponentDataWrapper{
    public String stepId;	//helpers.id()
    public String title;	//Accept Terms and conditions
    public List<cls_content> content = new List<cls_content>();
    public List<cls_fields> fields = new List<cls_fields>();
    public List<cls_gdpr> gdpr = new List<cls_gdpr>();
    public cls_community community;
    public cls_footerLinkData footerLinkData;
    public cls_submitFormAndRedirectLinkData submitFormAndRedirectLinkData;
    public cls_closeModalAndRedrirectLinkData closeModalAndRedrirectLinkData;
    
    public class cls_content {
        public String type;	//richtext
        public String body;	//Test
        public cls_content(String type, String body){
            this.type = type;
            this.body = body;
        }
    }
    
    public class cls_fields {
        public String fieldId;	//XX-1
        public String type;	//Checkbox
        public String name;	//terms-and-conditions
        public String value;	//checkbox-terms-conditions
        public boolean checked;
        public String label;	//I have read and agree to these terms and conditions
        public boolean required;
        public String requireError;	//This field is required
    }
    
    public class cls_gdpr {
		public String type;	//richtext
		public String body;	//test
	}
   
    
    public class cls_community {
        public String sourceLabel;	//Available Communities
        public String selectedLabel;	//Selected Communities
        public List<cls_communityOptions> communityOptions;
        public List<String> selectedOptions;
        public List<String> requiredOptions;
    }
    
    
    public class cls_communityOptions {
        public String value;	//fpga
        public String label;	//FPGA
        public cls_communityOptions(String value, String label){
            this.value = value;
            this.label = label;
        }
    }
    
    public class cls_footerLinkData {
		public String label;	//Manage Responsibilities
		public String externalUrl;	//#
		public String communityPage;	//
		public String objectPage;	//
		public String recordId;	//
	}
    public class cls_submitFormAndRedirectLinkData{
        public String label;
        public String externalUrl;
    }
    public class cls_closeModalAndRedrirectLinkData{
        public String label;
        public String externalUrl;
    }
}