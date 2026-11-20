/*******************************************************************************************************************************************************************************************************
* Class Name  : PSS_SolutionToOfferingRetrigger
* Description : This Class holds the method to trigger the solution to offering conversion using Solution Id 
* Version     : 1.0 
* Created Date: 04-June-2021
* Modification Log :
* Created By  : ONYX Team (Infosys)
********************************************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public without sharing class PSS_SolutionToOfferingRetrigger {

/**
* Method called when the user retriggers the Solution To offering Conversion in Solution Detail Page
* @description- Re-Run the OPID Validation Checks and other mandatory checks for Conversion and invoke Conversion Logic
* @param solutionId Id of the Solution for which User Navigated to PSS_AdminReviewPage component
* @return SolutionRetriggerWrapper - Wrapper Class Variables returned back to JS from this Apex controller method
*/ 	
    /*@AuraEnabled
    public static SolutionRetriggerWrapper convertSolutionToOffering(String solutionId) {
		try {
			SolutionRetriggerWrapper response = new SolutionRetriggerWrapper();
			ArdiraSurvey__Survey_Result__c solutionDetail = fetchSolutionDetail(solutionId);
	
			if (solutionDetail != null) {
				String errorLogMessage = '';
				Integer isDuplicate = validateMPIRecord(solutionDetail);
	
				List<ArdiraSurvey__Survey_Result__c> solutionDetailList = new List<ArdiraSurvey__Survey_Result__c>();
				solutionDetailList.add(solutionDetail);
	
				if (isDuplicate == 2) {
					errorLogMessage = buildErrorMessage(errorLogMessage, System.Label.PSS_Conversion_MPI_Record_Validation_Error);
					response.partnerValidation = true;
				} else {
					try {
						PSS_SolutionToOfferingConverter.convertProposal(solutionDetailList);
						errorLogMessage = buildErrorMessage(errorLogMessage, System.Label.PSS_Offering_Creation_Success);
						response.offeringCreated = true;
						PSS_AdminDetailsController.createContactEntitlement(solutionId);
					} catch (Exception e) {
						errorLogMessage = buildErrorMessage(errorLogMessage, System.Label.PSS_Technical_Error_Message);
					}
				}
	
				updateSolutionDetail(solutionId, solutionDetail, errorLogMessage);
				refreshResultDetails(response, solutionDetail);
			}
	
			return response;
		} catch (Exception e) {
			PMP_Utility.logError(e, 'PSS_SolutionToOfferingRetrigger');
			throw e;
		}
	}
	
	private static ArdiraSurvey__Survey_Result__c fetchSolutionDetail(String solutionId) {
		if (!Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isAccessible()) {
			return null;
		}
	
		return [SELECT Id, PSS_Programs_Applicable_Nm__c, PSS_Company_Id__c,
					   PSS_Partner_Solution_Lifecycle_Status_Nm__c, PSS_Conversion_Admin_Log_Details_Txt__c,
					   PSS_Solution_Submitter_UserId_Id__c, ArdiraSurvey__Assigned_To_User__c,
					   PSS_Intel_Admin_Id__c  
				FROM ArdiraSurvey__Survey_Result__c 
				WHERE Id = :solutionId AND PSS_Partner_Solution_Lifecycle_Status_Nm__c = :PSS_StaticConstants.SOLUTION_APPROVED_STATUS];
	}
	
	private static Integer validateMPIRecord(ArdiraSurvey__Survey_Result__c solutionDetail) {
		return PSS_AdminDetailsController.isDuplicateOffering(solutionDetail.Id, solutionDetail.PSS_Partner_Solution_Lifecycle_Status_Nm__c);
	}
	
	private static String buildErrorMessage(String existingMessage, String newErrorMessage) {
		return String.isNotBlank(existingMessage) ? existingMessage + '\n' + newErrorMessage + PSS_StaticConstants.LOG_MESSAGE_SEPERATOR + System.Now() :
												   newErrorMessage + PSS_StaticConstants.LOG_MESSAGE_SEPERATOR + System.Now();
	}
	
	private static void updateSolutionDetail(String solutionId, ArdiraSurvey__Survey_Result__c solutionDetail, String errorLogMessage) {
		if (String.isNotBlank(errorLogMessage) && Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isUpdateable()) {
			ArdiraSurvey__Survey_Result__c solutionUpdate = new ArdiraSurvey__Survey_Result__c(Id = solutionId); 
			solutionUpdate.PSS_Conversion_Admin_Log_Details_Txt__c = String.isNotBlank(solutionDetail.PSS_Conversion_Admin_Log_Details_Txt__c) ? 
																	  solutionDetail.PSS_Conversion_Admin_Log_Details_Txt__c + '\n' + errorLogMessage :
																	  errorLogMessage;
			update solutionUpdate;
		}
	}
	
	private static void refreshResultDetails(SolutionRetriggerWrapper response, ArdiraSurvey__Survey_Result__c solutionDetail) {
		if (!System.isBatch()) {
			response.resultDetails = PSS_PartnerResponsePageCtrl.getPartnerResponses(solutionDetail.Id);
		}
	}
	
    
    //Wrapper to get the information about the results validation and offering creation
     public class SolutionRetriggerWrapper{
        @AuraEnabled
        Public Boolean partnerValidation=false;
        @AuraEnabled
        Public Boolean selectBenefit=false;
        @AuraEnabled
        Public Boolean offeringCreated =false;
        @AuraEnabled
        Public PSS_PartnerResponsePageCtrl.partnerResponseWrapper resultDetails; 
         
    }*/
}