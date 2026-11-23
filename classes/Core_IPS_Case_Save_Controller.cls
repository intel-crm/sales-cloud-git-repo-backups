/*
* Class Name : Core_IPS_Case_Save_Controller
* Created By : Anil Gugulothu
* Description: This classes is referenced in Core_IPS_caseCreation_Form LWC which handles 
*              Case data sent from UI Component
* Modified By :
*/
public with sharing class Core_IPS_Case_Save_Controller {
    public Core_IPS_Case_Save_Controller() {

    /* Method name : handleSaveCase
	 * Parameter   : 
	 * Description : It will parse all the strings and assign values to appropriate Case fields 
	 *               and Save Report both Submit and Draft
	 * Return Type : String   
	 */
    }
    @AuraEnabled
    public static String handleSaveCase(String basicInfoData, String finalformData){
        try{
            system.debug('basicInfo'+basicInfoData);
            system.debug('finalformData'+finalformData);
            //Fetching Record Type ID
            Id IPSCaserecordypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IPS_Case_Create').getRecordTypeId();
            //New Case for insert or update
            Case newCase = new Case();
            newCase.RecordTypeId = IPSCaserecordypeId;
            if(basicInfoData != null){
                Core_IPS_CaseDetailsWrapper.BasicInfo result = Core_IPS_CaseDetailsWrapper.parseBasicInfo(basicInfoData);
                system.debug('parseBasic--'+result);
                newCase.RecordTypeId = IPSCaserecordypeId;
                newCase.Core_IPS_Project_Case__c = result.project;
                newCase.AssetId = result.Product;
                newCase.Core_Product_Variant__c = result.productvariantName;
                 newCase.Core_Case_Issue_Category__c = result.CategoryId;
                 newCase.Core_Case_Issue_Sub_Category__c = result.SubCategoryId;
                newCase.ContactId = '0033F000003GitwQAC'; //   
            }
            if(finalformData != null){
				Core_IPS_CaseDetailsWrapper.finalPageDetails resultpage = Core_IPS_CaseDetailsWrapper.parsefinalPageDetails(finalformData); 
            	system.debug('3rd pageData--'+resultpage);
                newCase.Core_IPS_Issue_source__c = 'Internal Portal	';
                newCase.Core_CaseType__c = resultpage.caseType;
                newCase.subject = resultpage.subject;
                newCase.Core_Issue_Description__c = resultpage.caseType;
                newCase.Description = resultpage.description;
                newCase.Core_Severity__c = resultpage.caseseverity;
                newCase.Core_Customer_Reference_ID__c = resultpage.custmerreference;
                newCase.Core_End_Customer__c  = resultpage.endcustomer;
            }
            insert newCase;
            String CsId = newCase.Id;
            return CsId;
        }
        catch (Exception e) {
            system.debug('error--'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}