/****************************************************************************************************************************************
* Class Name  : PMP_CreateOfferingTab4Service 
* Version     : 1.0 
* Created Date: 04-30-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Raj Yadav               04-30-2019                    Created for displaying tab4 - Resources elements in 'Create Offering' components
****************************************************************************************************************************************************************/
public with sharing class PMP_CreateOfferingTab4Service {
        
    public static Intel_Step getResourcesInputs(String stepName,PMP_Partner_Offering__c offering){
        
        boolean required=false;
        
        // STEP 4: Resources
        Intel_Step step4 = PMP_Offering_UI_Generator.createStep(stepName);
        //Section 5 for Resources
        Intel_Section section5 = PMP_Offering_UI_Generator.createSection(System.Label.PMP_Links_Attachments);
        step4.sections.add(section5);
        
        /*-------------------------------------------------------------------------------------------------------------------------------------*/
        //Sub-Section for upload images
        Intel_Subsection sub5a = PMP_Offering_UI_Generator.createSubsection(System.Label.PMP_Upload_Images);
        section5.subsections.add(sub5a);
        //If the category selected is Service upload image is not a required field
        required=offering.PMP_Category_nm__c!='Service'?true:false;
        //Inputs
        //Upload Images
        Intel_Uploader uploader=PMP_Offering_UI_Generator.createUploader(offering,required);
        sub5a.inputs.add(uploader);
        
        /*-------------------------------------------------------------------------------------------------------------------------------------*/
        //Sub-Section for Product Web URL
        Intel_Subsection sub5b = PMP_Offering_UI_Generator.createSubsection(System.Label.PMP_Product_Web_URL);
        section5.subsections.add(sub5b);
        //If the offering visibility id Public Content Product Web URL is not a required field
        if(offering.PMP_Partner_Offering_Visibility_Nm__c!=null){
          
            required=offering.PMP_Partner_Offering_Visibility_Nm__c=='Public Content'?true:false;}
        //Inputs
        //Title-Text Box
       Intel_Text T4S5C1 = PMP_Offering_UI_Generator.createText('Name',System.Label.PMP_Title,required,'productWebPageData');
       sub5b.inputs.add(T4S5C1);
    
        //URL-Text Box
        Intel_Text T4S5C2 = PMP_Offering_UI_Generator.createText('Url',System.Label.PMP_Url,required,'productWebPageData');
        sub5b.inputs.add(T4S5C2);
        
        /*-------------------------------------------------------------------------------------------------------------------------------------*/
        //Sub-section for resources
        Intel_Subsection sub5e = PMP_Offering_UI_Generator.createSubsection(System.Label.PMP_AdditionalResources);
        section5.subsections.add(sub5e); 
        //Resources
        system.debug('inside service');
        Intel_Resources resources=PMP_Offering_UI_Generator.createResources();
        system.debug('service resources'+resources);
        sub5e.inputs.add(resources);
        return step4;
    }
    
    public static List<PMP_Partner_Offering_Resource__c> getOfferingResources(Id offeringId){
        
        return [Select id,Name,PMP_Partner_Offering_Image__c,PMP_Resource_Type_Nm__c,
                PMP_Resource_Sequence_Nbr__c,PMP_Partner_Offering_Resource_URL_Txt__c,
                PMP_Offering_Id__c from PMP_Partner_Offering_Resource__c where 
                PMP_Offering_Id__c = :offeringId];
    }
     
 }