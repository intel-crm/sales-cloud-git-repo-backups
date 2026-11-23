/***************************************************************************************************************************************
Apex Class Name     : PRM_OnboardingStepWrapper
Version             : 1.0
Created Date        : July 2020
Function            : This is the wrapper class to return the steps for Post Onboarding.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                        4th-July-2020                     US640819-IPA - POST-LAUNCH [ONBOARDING]: Create an On-boarding experience for new and existing user to accept the T&Cs
*************************************************************************************************************************************/


public class PRM_OnboardingStepWrapper {

	public String type;	//linear
	public String eyebrow;	//Intel Partner Alliance
	public String title;	//More Benefits are coming your way
	public String description;	//Get a jump on accessing the expanded business building benefits
	public cls_steps[] steps;
	class cls_steps {
		public String stepId;	//helpers.id()
		public String component;	//c-ipa-partner-modal-terms-and-conditions
		public String componentData;	//terms-and-conditions
		public String title;	//Accept terms and conditions
		public String description;	//Please review and accept the terms and conditions and confirm your communication preferences
		public String completedTitle;	//Completed
		public String completedDescription;	//You've accepted the terms and conditoins and confirmed your communication preferences
		public boolean completed;
		public String modalTitle;	//Accept Terms and conditions
	}
}