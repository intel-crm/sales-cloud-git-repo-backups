/***************************************************************************************************************************************
Apex Class Name     : PRM_IPAPartnerOnboarding_CTRL
Version             : 1.0
Created Date        : July 2020
Function            : This controller class will load different steps on Post Launch Onboarding Page on the baisis of type and User Entitlement on UI.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                        2nd-July-2020                     US640819-IPA - POST-LAUNCH [ONBOARDING]: Create an On-boarding experience for new and existing user to accept the T&Cs
* Srishty                        20th-Aug-2020                     US761138-Update text labels on onboarding based on PS changes
* Srishty                        20th-Aug-2020                     DE89081: Updating checkbox text through Partner Terms and Condition Object
* Srishty 						 14th-Sept-2020                    US776714- Updated Custom label for non primary external URL and System.now() for agreement signed date
*************************************************************************************************************************************/

public without sharing class PRM_IPAPartnerOnboarding_CTRL {
    @TestVisible
    private final static String DEFAULT_LANGUAGE='ENG';
    private final static String TERMS_VALUE='checkbox-terms-conditions';
    private final static String TERMS_FIELD_ID='XX1';
    private final static String TERMS_FIELD_TYPE='Checkbox';
    private final static String STATUS_ACTIVE='Active';
    private final static String STATUS_INACTIVE='inactive';
    private final static String STATUS_COMPLETE='Complete';
    @Testvisible
    private final static String STATUS_PENDING='Pending';
    private final static String STATUS_APPROVED='Approved';
    private final static String RICHTEXT='richtext';
    private final static String REQUIRED_FIELD='This field is required';
    
    //public static boolean IPARefresh = Boolean.valueOf(label.PRM_IPARefresh);
    
    /*This method will return true if step1 is completed
    *This will be called from getComponent method of partnerOnboarding component 
    */
    @AuraEnabled
    public static Boolean isStepOneCompleted(){
        Boolean isStepOneCompleted =false;
        try{
            Id loggedInContactId=getContactId();
            Boolean isTandCAccepted=isTandCAccepted(loggedInContactId);
            Boolean isFirstUser =showTandCCheckbox(loggedInContactId);
            List<String> subCodeList =System.Label.PRM_Post_Onboarding_Subscription_Code.split(',');
            List<PRM_ContactSubscriptionAssociation__c> contactSubs =[Select Id from PRM_ContactSubscriptionAssociation__c 
                                                                      where PRM_Contact_Id__c=:loggedInContactId 
                                                                      AND PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c IN:subCodeList AND PRM_Status_Nm__c=:STATUS_ACTIVE];
            if(!contactSubs.isEmpty() && contactSubs.size()==subCodeList.size()){
                if(isFirstUser && isTandCAccepted ){
                    isStepOneCompleted=true;
                }
                else if(isFirstUser && !isTandCAccepted){
                    isStepOneCompleted=false;
                }
                else{
                    isStepOneCompleted=true;
                }
            }
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
        return isStepOneCompleted;
    }
    
    /*This method will return true if step2 is completed
    *This will be called on the init method of ipaPartnerOnboarding component 
    */
    @AuraEnabled
    public static Boolean isStepTwoCompleted(){
        Boolean isStepTwoCompleted =false;
        try{
            Id loggedInContactId=getContactId();
            List<PRM_Partner_Community_Enrollment_Request__c> enrollmentRequests = [Select  PRM_Partner_Community_Nm__c 
                                                                                from PRM_Partner_Community_Enrollment_Request__c 
                                                                                where PRM_Contact_Id__c = :loggedInContactId 
                                                                                And (PRM_Status_Nm__c =:STATUS_PENDING 
                                                                                     OR PRM_Status_Nm__c=:STATUS_APPROVED)];
            if(!enrollmentRequests.isEmpty() && enrollmentRequests.size()>0){
                isStepTwoCompleted=true;
            }
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
        return isStepTwoCompleted;
    }
    
    @AuraEnabled
    public static String getStepCompletionStatus(){
        SuccessResponseWrapper stepStatus = new SuccessResponseWrapper();
        stepStatus.stepOneCompleted = isStepOneCompleted();
        stepStatus.stepTwoCompleted = isStepTwoCompleted();
        return JSON.serialize(stepStatus);
        
    }

    /*This method return differnt apex method to javascript service class function
     * It return on the basis of Type of Subcomponent defined at component level. 
    */
    @AuraEnabled(cacheable=true)
    public static String getSubComponentDataPostLaunch(String type){
        switch on type {
            when 'terms-and-conditions','terms-and-conditions-non-primary' {
                return loadTermAndConditions();
            }
            when 'community-picklist' {
                return loadCommunitySelection();
            }
            when 'community-picklist-non-primary'{
                return loadCommunitySelectionNonPrimary();
            }
            when else {
                return 'Type not specified';
            }
        }
    }
    
    /*This method will return content of the Term & Condition modal.
    */ 
    @AuraEnabled(cacheable=true)
    public static String loadTermAndConditions(){
        boolean isFirstUser;
        
        PRM_SubComponentDataWrapper tAndCWrapperObject = new PRM_SubComponentDataWrapper();
        try{
            Id loggedInContactId=getContactId();
            isFirstUser=showTandCCheckbox(loggedInContactId);//this boolean checks if Contact is eligible for T&C record creation.        
            //PRM_Partner_Terms_and_Conditions__c partnerTermsAndCondition=new PRM_Partner_Terms_and_Conditions__c();
            List<String> ipaTAndCCodeList =System.Label.PRM_IPATermsandConditions_ContentCode.split(',');
            String contextMessagePreferredLang='';
            String contextMessageEnglish='';
            String contextMessageFinal='';
            String gdprTextEng='';
            String gdprTextPrefferedLang='';
            String gdprTextFinal='';
            String checkboxTextENG='';
            String checkboxTextOtherLang='';
            String checkboxTextFinal='';
            String preferredLanguage= [Select Core_Preferred_Language__c 
                                       from Contact 
                                       where Id =:loggedInContactId 
                                       Limit 1].Core_Preferred_Language__c;
            if(String.isBlank(preferredLanguage)){
                preferredLanguage=DEFAULT_LANGUAGE;
            }
            contextMessageFinal = loadTermAndConditionsHelper( ipaTAndCCodeList, preferredLanguage);
            // for( PRM_Partner_Terms_and_Conditions__c termsAndCondition : [Select Id,Name,PRM_Content_Message_Txt__c,PRM_Content_Language_Nm__c 
            //                                                               from PRM_Partner_Terms_and_Conditions__c 
            //                                                               where PRM_Content_Code_Txt__c IN:ipaTAndCCodeList 
            //                                                               AND PRM_Terms_and_Conditions_Type_Nm__c=:System.Label.PRM_PartnerTermsandConditions_Type
            //                                                               AND (PRM_Content_Language_Nm__c =:DEFAULT_LANGUAGE OR PRM_Content_Language_Nm__c =:preferredLanguage)
            //                                                               AND PRM_InActive_Ind__c=false 
            //                                                               ORDER BY Name ASC
            //                                                              ]){
            //                                                                  if(termsAndCondition.PRM_Content_Language_Nm__c==preferredLanguage){
            //                                                                      contextMessagePreferredLang=contextMessagePreferredLang+termsAndCondition.PRM_Content_Message_Txt__c;
            //                                                                  }
            //                                                                  else{
            //                                                                      contextMessageEnglish=contextMessageEnglish+termsAndCondition.PRM_Content_Message_Txt__c;
            //                                                                  }
            //                                                               }
            // if(contextMessagePreferredLang==null || String.isBlank(contextMessagePreferredLang)){
            //     contextMessageFinal=contextMessageEnglish; 
            // }
            // else{
            //     contextMessageFinal=contextMessagePreferredLang;
            // }

           List<String> contentCodeList =System.Label.PRM_PartnerTermsandConditions_GDPR_Code.split(',');
           gdprTextFinal = loadTermAndConditionsHelper( contentCodeList, preferredLanguage);
        //    for(PRM_Partner_Terms_and_Conditions__c gdpr :[Select Id,Name,PRM_Content_Message_Txt__c,PRM_Content_Language_Nm__c 
        //                                                                   from PRM_Partner_Terms_and_Conditions__c 
        //                                                                   where PRM_Content_Code_Txt__c IN:contentCodeList 
        //                                                                   AND PRM_Terms_and_Conditions_Type_Nm__c=:System.Label.PRM_PartnerTermsandConditions_Type
        //                                                                   AND (PRM_Content_Language_Nm__c =:DEFAULT_LANGUAGE OR PRM_Content_Language_Nm__c =:preferredLanguage)
        //                                                                   AND PRM_InActive_Ind__c=false 
        //                                                                   ORDER BY Name ASC
        //                                                   ]){
        //                                                       if(gdpr.PRM_Content_Language_Nm__c==preferredLanguage){
        //                                                           gdprTextPrefferedLang=gdprTextPrefferedLang+gdpr.PRM_Content_Message_Txt__c;
        //                                                       }
        //                                                       else{
        //                                                          gdprTextEng=gdprTextEng+gdpr.PRM_Content_Message_Txt__c;
        //                                                       }
                                                                  
        //                                                   }
        //     // if(gdprTextPrefferedLang==null || String.isBlank(gdprTextPrefferedLang)){
        //     //     gdprTextFinal=gdprTextEng;  
        //     // }
        //     // else{
        //     //     gdprTextFinal=gdprTextPrefferedLang;
        //     // }

            List<String> checkboxTextCodeList =System.Label.PRM_PartnerTermsandConditions_CheckboxText_Code.split(',');
            checkboxTextFinal = loadTermAndConditionsHelper( checkboxTextCodeList, preferredLanguage);
            //  for(PRM_Partner_Terms_and_Conditions__c checkboxText :[Select Id,Name,PRM_Content_Message_Txt__c,PRM_Content_Language_Nm__c 
            //                                                               from PRM_Partner_Terms_and_Conditions__c 
            //                                                               where PRM_Content_Code_Txt__c IN:checkboxTextCodeList 
            //                                                               AND PRM_Terms_and_Conditions_Type_Nm__c=:System.Label.PRM_PartnerTermsandConditions_Type
            //                                                               AND (PRM_Content_Language_Nm__c =:DEFAULT_LANGUAGE OR PRM_Content_Language_Nm__c =:preferredLanguage)
            //                                                               AND PRM_InActive_Ind__c=false 
            //                                                         ORDER BY Name ASC]){
            //                                                         if(checkboxText.PRM_Content_Language_Nm__c==preferredLanguage){
            //                                                       checkboxTextOtherLang=checkboxTextOtherLang+checkboxText.PRM_Content_Message_Txt__c;
            //                                                        }
            //                                                        else{
            //                                                      checkboxTextENG=checkboxTextENG+checkboxText.PRM_Content_Message_Txt__c;
            //                                                         }
            //                                                         }
            // // if(checkboxTextOtherLang==null || String.isBlank(checkboxTextOtherLang)){
            // //     checkboxTextFinal=checkboxTextENG;  
            // // }
            // // else{
            // //     checkboxTextFinal=checkboxTextOtherLang;
            // // }
            
            tAndCWrapperObject.title = System.Label.PRM_Onboarding_AcceptTermsAndConditions;
            if( isFirstUser) {
            tAndCWrapperObject.content.add(new PRM_SubComponentDataWrapper.cls_content(RICHTEXT,contextMessageFinal));
            }

            PRM_SubComponentDataWrapper.cls_fields fields = new PRM_SubComponentDataWrapper.cls_fields();
            fields.name = System.Label.PRM_PartnerTermsandConditions_GDPR_Code;
            fields.required = true;
            if( isFirstUser) {
            fields.fieldId = TERMS_FIELD_ID;
            fields.type = TERMS_FIELD_TYPE;
            fields.name = System.Label.PRM_Onboarding_Type_TnC;
            fields.value = TERMS_VALUE;
            fields.checked = false;
            fields.label = checkboxTextFinal;
            fields.requireError = REQUIRED_FIELD;
            }

            tAndCWrapperObject.fields.add(fields);
            PRM_SubComponentDataWrapper.cls_gdpr gdpr = new PRM_SubComponentDataWrapper.cls_gdpr();
            gdpr.type = RICHTEXT;
            gdpr.body = gdprTextFinal;
            tAndCWrapperObject.gdpr.add(gdpr);
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
        return JSON.serialize(tAndCWrapperObject);
    }

    public static string loadTermAndConditionsHelper(List<String> codeList, String preferredLanguage){

        String preferredLang='';
        String messageEnglish='';
        String finalMsg = '';

        for(PRM_Partner_Terms_and_Conditions__c termsAndCondition :[Select Id,Name,PRM_Content_Message_Txt__c,PRM_Content_Language_Nm__c 
                                                                          from PRM_Partner_Terms_and_Conditions__c 
                                                                          where PRM_Content_Code_Txt__c IN:codeList 
                                                                          AND PRM_Terms_and_Conditions_Type_Nm__c=:System.Label.PRM_PartnerTermsandConditions_Type
                                                                          AND (PRM_Content_Language_Nm__c =:DEFAULT_LANGUAGE OR PRM_Content_Language_Nm__c =:preferredLanguage)
                                                                          AND PRM_InActive_Ind__c=false 
                                                                          ORDER BY Name ASC
                                                          ]){
                                                              if(termsAndCondition.PRM_Content_Language_Nm__c==preferredLanguage){
                                                                preferredLang=preferredLang+termsAndCondition.PRM_Content_Message_Txt__c;
                                                              }
                                                              else{
                                                                messageEnglish=messageEnglish+termsAndCondition.PRM_Content_Message_Txt__c;
                                                              }  
        }
        finalMsg = preferredLang==null || String.isBlank(preferredLang) ? messageEnglish : preferredLang;
    
        return finalMsg;
    }

    
    /*This method will create record for Terms and Condition accepted for Contact Account  \
    * This method will create record for Subcription of Contact for currently loggedin User
    *This will be called on the click of submit button on Step1
    */
    @AuraEnabled
    public static String submitTermsAndCondtion(String stepId,String data){
        Boolean submitTAndC = false;
        Boolean isFirstUser=false;
        Id contactId=getContactId();
        List<Sobject> listToInsert = new List<Sobject>();
        Id accId =[Select AccountId from Contact where Id=:contactId Limit 1].AccountId;
        String contactFirstName = [Select FirstName from Contact where Id=:contactId Limit 1].FirstName;
        String contactLastName = [Select LastName from Contact where Id=:contactId Limit 1].LastName;
        String contactName = contactFirstName+' '+contactLastName;
        String contactEmail = [Select Email from Contact where Id=:contactId Limit 1].email;
        List<String> subCodeList =System.Label.PRM_Post_Onboarding_Subscription_Code.split(',');
        List<PRM_ContactSubscriptionAssociation__c> contactSubsAssocList =new List<PRM_ContactSubscriptionAssociation__c>();
        List<PRM_ContactSubscriptionAssociation__c> contactSubsAssocListToUpdate =new List<PRM_ContactSubscriptionAssociation__c>();
        isFirstUser=showTandCCheckbox(contactId);//this boolean checks if Contact is eligible for T&C record creation.
        submitTAndC=isTAndCAccepted(contactId);//this boolean will return true/false depending on T&C created for Account of loggedin User.
        if(!submitTAndC && isFirstUser){
            Id partnerAgreementId =[Select Id from PRM_PartnerAgreement__c where Name=:System.Label.PRM_IPA_Terms_Condition Limit 1].Id;
            PRM_AccountLegalAgreemntAssociation__c accLegalAccoc = new PRM_AccountLegalAgreemntAssociation__c();
            accLegalAccoc.PRM_Account_Id__c=accId;
            accLegalAccoc.PRM_Partner_Agreement_Id__c=partnerAgreementId;
            // IPA 2.0 - TWC729-7874-start
            accLegalAccoc.PRM_Signed_By_Email__c = contactEmail;
            accLegalAccoc.PRM_Signed_By_Name__c = contactName;
            //IPA 2.0 - TWC729-7874-end
            accLegalAccoc.PRM_Agreement_Sign_Dt__c=System.now();
            listToInsert.add(accLegalAccoc);//insert Account Legal Agreement Association Record  
        }
        
        Set<Id> existingContactSub = new Set<Id>();
        for(PRM_ContactSubscriptionAssociation__c contactSub :[Select Id,PRM_Partner_Subscription_Id__c,PRM_Status_Nm__c 
                                                               from PRM_ContactSubscriptionAssociation__c
                                                               where PRM_Contact_Id__c=:contactId
                                                               AND PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c IN:subCodeList]){
                                                                     existingContactSub.add(contactSub.PRM_Partner_Subscription_Id__c);
                                                                    if(contactSub.PRM_Status_Nm__c == STATUS_INACTIVE) {
                                                                        contactSub.PRM_Status_Nm__c=STATUS_ACTIVE;
                                                                        contactSub.PRM_Status_Reason_Txt__c = 'Activated from portal';//TWC729-8089 : Adding reason text : NJ
                                                                        contactSubsAssocListToUpdate.add(contactSub);
                                                                    }
                                                                  }
        for(PRM_Partner_Subscription__c subs:[Select Id from PRM_Partner_Subscription__c where PRM_Subscription_Cd__c IN :subCodeList ]){
            if(!existingContactSub.contains(subs.Id)){
                PRM_ContactSubscriptionAssociation__c contactSubscription = new PRM_ContactSubscriptionAssociation__c();
                contactSubscription.PRM_Contact_Id__c=contactId;
                contactSubscription.PRM_Partner_Subscription_Id__c=subs.Id;
                contactSubscription.PRM_Status_Nm__c=STATUS_ACTIVE;
                contactSubscription.PRM_Status_Reason_Txt__c = 'Activated from portal';//TWC729-8089 : Adding reason text : NJ
                contactSubsAssocList.add(contactSubscription);
            }
        }
        
        listToInsert.addAll(contactSubsAssocList);
        Account accIPAUpdate =[Select Id,Core_Intel_Partner_Alliance_PartnerGroup__c from Account  where Id =:accId limit 1];
        if(!accIPAUpdate.Core_Intel_Partner_Alliance_PartnerGroup__c){
           accIPAUpdate.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        }
        
        SuccessResponseWrapper submitTerms = new SuccessResponseWrapper();
        if(listToInsert.size()>0){
            try{
                insert listToInsert;
                update accIPAUpdate;
            }
            catch(Exception e){
                submitTerms.success = false;
            }
        }
        if(contactSubsAssocListToUpdate.size() > 0 && !contactSubsAssocListToUpdate.isEmpty()) {
            try{
                update contactSubsAssocListToUpdate;
            }catch(Exception e) {
                submitTerms.success = false;
            }            
        }
        submitTerms.messageId = stepId;
        return JSON.serialize(submitTerms);
    }
   
     /*This method will return Srings of Available community and Enrolled Community for Loggedin User when Step 2 is loaded.
    * Right side of list will show community for which User is already enrolled.
    * Left side of List will show community available for User for which is is not enrolled.
    */
    @AuraEnabled(cacheable=false)
    public static String loadCommunitySelection(){
        PRM_SubComponentDataWrapper communitySelectionWrapperObject = new PRM_SubComponentDataWrapper();
        try{
            Id loggedInContactId=getContactId();
            //Id loggedInContactId = '0038A00000S27maQAB'; //for testing purpose
            Map<String,String> availableCommunityMap = new Map<String,String>();
            List<String> availbaleCommunityList=System.Label.PRM_Available_Communities_Onboarding.split(',');
            
            String enrolledCommunitiesByUser =[Select Core_IPA_Partner_Community__c from Contact where Id=:loggedInContactId limit 1].Core_IPA_Partner_Community__c;
            List<String> enrolledCommunities = new List<String>();
            if(String.isNotBlank(enrolledCommunitiesByUser)){
                enrolledCommunities =enrolledCommunitiesByUser.split(';');
            }
            enrolledCommunities = addEnrollmentRequests(enrolledCommunities,loggedInContactId);
            
            Schema.DescribeFieldResult fieldResult = Contact.Core_IPA_Partner_Community__c.getDescribe();
            for( Schema.PicklistEntry f : fieldResult.getPicklistValues()){
                if(availbaleCommunityList.contains(f.getLabel())){
                    availableCommunityMap.put(f.getValue(),f.getLabel());
                }
                if(enrolledCommunities.contains(f.getValue())){
                    availableCommunityMap.put(f.getValue(),f.getLabel());
                }
            }
            communitySelectionWrapperObject.title = System.Label.PRM_Onboarding_Communities;
            communitySelectionWrapperObject.content.add(new PRM_SubComponentDataWrapper.cls_content(RICHTEXT,System.Label.PRM_Onboarding_Step2_Message));
            PRM_SubComponentDataWrapper.cls_community community = new PRM_SubComponentDataWrapper.cls_community();
            community.sourceLabel = System.Label.PRM_Onboarding_AvailableCommunities;
            community.selectedLabel = System.Label.PRM_Oboarding_SelectedCommunities;
            List<PRM_SubComponentDataWrapper.cls_communityOptions> communityOptions = new List<PRM_SubComponentDataWrapper.cls_communityOptions>();
            for(String communityKey : availableCommunityMap.keySet()){
                communityOptions.add(new PRM_SubComponentDataWrapper.cls_communityOptions(communityKey,availableCommunityMap.get(communityKey)));
            }
            community.communityOptions = communityOptions;
            community.selectedOptions = new List<String>(enrolledCommunities);
            community.requiredOptions = new List<String>(enrolledCommunities);
            communitySelectionWrapperObject.community = community;
            PRM_SubComponentDataWrapper.cls_footerLinkData footerLinkData = new PRM_SubComponentDataWrapper.cls_footerLinkData();
            footerLinkData.label = System.Label.PRM_Onboarding_ManageResponsibilities;
            footerLinkData.externalUrl = System.Label.PRM_Onboarding_footer_ExtURL;
            footerLinkData.communityPage = '';
            footerLinkData.objectPage = '';
            footerLinkData.recordId = '';
            communitySelectionWrapperObject.footerLinkData = footerLinkData;
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
        return JSON.serialize(communitySelectionWrapperObject);
    }
    /*This method will return community selection for Non Primary link
     * US761138 : On closing/submit Community modal in non primary link will 
     * redirect to external link 
     */
    @AuraEnabled(cacheable=false)
    public static String loadCommunitySelectionNonPrimary(){
        PRM_SubComponentDataWrapper communitySelectionWrapperObject = new PRM_SubComponentDataWrapper();
        try{
            Id loggedInContactId=getContactId();
            //Id loggedInContactId = '0038A00000S27maQAB'; //for testing purpose
            Map<String,String> availableCommunityMap = new Map<String,String>();
            List<String> availbaleCommunityList=System.Label.PRM_Available_Communities_Onboarding.split(',');
            
            String enrolledCommunitiesByUser =[Select Core_IPA_Partner_Community__c from Contact where Id=:loggedInContactId limit 1].Core_IPA_Partner_Community__c;
            List<String> enrolledCommunities = new List<String>();
            if(String.isNotBlank(enrolledCommunitiesByUser)){
                enrolledCommunities =enrolledCommunitiesByUser.split(';');
            }
            enrolledCommunities = addEnrollmentRequests(enrolledCommunities,loggedInContactId);
            
            Schema.DescribeFieldResult fieldResult = Contact.Core_IPA_Partner_Community__c.getDescribe();
            for( Schema.PicklistEntry f : fieldResult.getPicklistValues()){
                if(availbaleCommunityList.contains(f.getLabel())){
                    availableCommunityMap.put(f.getValue(),f.getLabel());
                }
                if(enrolledCommunities.contains(f.getValue())){
                    availableCommunityMap.put(f.getValue(),f.getLabel());
                }
            }
            communitySelectionWrapperObject.title = System.Label.PRM_Onboarding_Communities;
            communitySelectionWrapperObject.content.add(new PRM_SubComponentDataWrapper.cls_content(RICHTEXT,System.Label.PRM_Onboarding_Step2_Message));
            PRM_SubComponentDataWrapper.cls_community community = new PRM_SubComponentDataWrapper.cls_community();
            community.sourceLabel = System.Label.PRM_Onboarding_AvailableCommunities;
            community.selectedLabel = System.Label.PRM_Oboarding_SelectedCommunities;
            List<PRM_SubComponentDataWrapper.cls_communityOptions> communityOptions = new List<PRM_SubComponentDataWrapper.cls_communityOptions>();
            for(String communityKey : availableCommunityMap.keySet()){
                communityOptions.add(new PRM_SubComponentDataWrapper.cls_communityOptions(communityKey,availableCommunityMap.get(communityKey)));
            }
            community.communityOptions = communityOptions;
            community.selectedOptions = new List<String>(enrolledCommunities);
            community.requiredOptions = new List<String>(enrolledCommunities);
            communitySelectionWrapperObject.community = community;
            PRM_SubComponentDataWrapper.cls_footerLinkData footerLinkData = new PRM_SubComponentDataWrapper.cls_footerLinkData();
            footerLinkData.label = System.Label.PRM_Onboarding_ManageResponsibilities;
            footerLinkData.externalUrl = System.Label.PRM_Onboarding_footer_ExtURL;
            footerLinkData.communityPage = '';
            footerLinkData.objectPage = '';
            footerLinkData.recordId = '';
            communitySelectionWrapperObject.footerLinkData = footerLinkData;
            PRM_SubComponentDataWrapper.cls_submitFormAndRedirectLinkData submitRedirectLinkData = new PRM_SubComponentDataWrapper.cls_submitFormAndRedirectLinkData();
            submitRedirectLinkData.externalUrl=System.Label.EPUM_Manage_Personnel;//US776714: custom label updated with diff URLs for redirecting to ext URL from non primary page based on language.
            submitRedirectLinkData.label=System.Label.IPA_Partner_Submit;
            communitySelectionWrapperObject.submitFormAndRedirectLinkData =submitRedirectLinkData;
            PRM_SubComponentDataWrapper.cls_closeModalAndRedrirectLinkData closeLinkData = new PRM_SubComponentDataWrapper.cls_closeModalAndRedrirectLinkData();
            closeLinkData.externalUrl=System.Label.EPUM_Manage_Personnel;
            closeLinkData.label=System.Label.IPA_Partner_Close;
            communitySelectionWrapperObject.closeModalAndRedrirectLinkData =closeLinkData;
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
        return JSON.serialize(communitySelectionWrapperObject);
    }
    
    
    /*This method will return Srings of new added communities to right side of list in step2.
    * Once the user click on submit, User will be enrolled for new community added to list 
    */
    @AuraEnabled
    public static String submitCommunityEnrollmentRequest(String stepId,String community){
        SuccessResponseWrapper submitCommunity = new SuccessResponseWrapper();
        if(String.isNotEmpty(community)){
            List<Object> newCommunities = (List<Object>)JSON.deserializeUntyped(community);
            submitCommunity.community = newCommunities;
            Id loggedInContactId = getContactId();
            String enrolledCommunitiesByUser =[Select Core_IPA_Partner_Community__c 
                                               from Contact 
                                               where Id=:loggedInContactId 
                                               limit 1].Core_IPA_Partner_Community__c;
            List<String> enrolledCommunities = new List<String>();
            if(String.isNotBlank(enrolledCommunitiesByUser)){
                enrolledCommunities =enrolledCommunitiesByUser.split(';');
            }
            enrolledCommunities = addEnrollmentRequests(enrolledCommunities,loggedInContactId);
            Map<String,String> communityAdminEmail= new Map<String,String>();
            Map<String,Id> communityAdminId= new Map<String,Id>();
            for(PRM_Partner_Community_Admins__mdt commName:[Select PRM_CommunityAdminEmail__c,Label 
                                                            from PRM_Partner_Community_Admins__mdt ] ){
                communityAdminEmail.put(commName.Label,commName.PRM_CommunityAdminEmail__c.toLowerCase());   
            }
            
            for(User admin :[Select Id,Email from User where Email IN:communityAdminEmail.values()]){
                communityAdminId.put(admin.Email.toLowerCase(),admin.Id);
            }
            List<PRM_Partner_Community_Enrollment_Request__c> newEnrollmentRequests = new List<PRM_Partner_Community_Enrollment_Request__c>();
            for(Object comm: newCommunities){
                String communityName = String.valueOf(comm);
                if(!enrolledCommunities.contains(communityName)){
                    PRM_Partner_Community_Enrollment_Request__c newEnrollmentRequest = new PRM_Partner_Community_Enrollment_Request__c();
                    newEnrollmentRequest.PRM_Contact_Id__c = loggedInContactId;
                    newEnrollmentRequest.PRM_Partner_Community_Nm__c = communityName;
                    newEnrollmentRequest.PRM_Status_Nm__c = STATUS_PENDING;
                    newEnrollmentRequest.PRM_Start_Date_Dt__c=System.now();
                    newEnrollmentRequest.PRM_Approver_Id__c = communityAdminId.get(communityAdminEmail.get(communityName));
                    newEnrollmentRequests.add(newEnrollmentRequest);
                }
            }
            
            if(newEnrollmentRequests.size()>0){
                try{
                    insert newEnrollmentRequests;
                }
                catch(Exception e){
                    submitCommunity.success = false;
                }
            }
            
        }
        submitCommunity.stepId = stepId;
        
        return JSON.serialize(submitCommunity);
        
    }
    
    /*This method checks if Contact is Partner Admin/Partner Admin Delgate or Employee.
     * This method return true only if Contact is Partner Admin /Delegate and T&C is not singed for Users Account.
     */
    private static Boolean showTandCCheckbox(Id loggedInContactId){
        Boolean showTAndC=false;
        try{
            Contact loggedInContact =[Select Id,Core_Primary_Contact__c,AccountId 
                                      from Contact 
                                      where Id =:loggedInContactId limit 1];
            Set<String> contactEntitlements = new Set<String>();
            for(Core_Contact_Entitlement__c contactEntitlement : [Select Core_Contact_Id__c,Core_Entitlement_Id__r.Name 
                                                                  from Core_Contact_Entitlement__c
                                                                  where Core_Contact_Id__c=:loggedInContactId AND Core_Selected__c=true AND Core_Status__c=:STATUS_COMPLETE]){
                                                                      contactEntitlements.add(contactEntitlement.Core_Entitlement_Id__r.Name); 
                                                                  }
            Boolean isTAndCAccepted=isTAndCAccepted(loggedInContactId);
            //Boolean isPrimaryContact=loggedInContact.Core_Primary_Contact__c;
            for(PRM_Account_Contact_Relationship__c acrRelationship :[Select Id,PRM_Relationship_Id__r.Name 
                                                                      from PRM_Account_Contact_Relationship__c 
                                                                      where PRM_Contact_Id__c=:loggedInContactId
                                                                      AND PRM_Account_Id__c=:loggedInContact.AccountId 
                                                                      AND PRM_InActive_Ind__c=false]){
                                                                          if(acrRelationship.PRM_Relationship_Id__r.Name==System.Label.PRM_Primary_Contact 
                                                                             && contactEntitlements.contains(System.Label.PRM_Primary_Contact) && !isTAndCAccepted){
                                                                                 showTAndC=true;
                                                                             }
                                                                          else if(acrRelationship.PRM_Relationship_Id__r.Name==System.Label.PRM_Partner_Admin_Delegate 
                                                                                  && contactEntitlements.contains(System.Label.PRM_Partner_Admin_Delegate)&& !isTAndCAccepted){
                                                                                      showTAndC=true;
                                                                                  }
                                                                          else if(acrRelationship.PRM_Relationship_Id__r.Name==System.Label.PRM_Employee 
                                                                                  && contactEntitlements.contains(System.Label.PRM_Employee)&& !isTAndCAccepted){
                                                                                      showTAndC=true;
                                                                                  }
                                                                          
                                                                      }
        }
        catch(Exception ex){
            System.debug('Exception '+ex.getMessage());
        }
        return showTAndC;
    }
     /*This method is reusable method to check if Legal Terms and Condition for LoggedIn User's Account is accepted.
      * Method will return boolean on the basis of record present for Account Legal Assoc for User's Account.
     */
    private static Boolean isTAndCAccepted(Id loggedInContactId){
        Boolean isTandCAccepted =false;
        Id accId =[Select AccountId from Contact where Id=:loggedInContactId limit 1 ].AccountId; 
        List<PRM_AccountLegalAgreemntAssociation__c> accLegalAssoc =[Select Id 
                                                                     from PRM_AccountLegalAgreemntAssociation__c 
                                                                     where PRM_Account_Id__c=:accId 
                                                                     AND PRM_Partner_Agreement_Id__r.Name=:System.Label.PRM_IPA_Terms_Condition]; 
        if(!accLegalAssoc.isEmpty()){
            isTandCAccepted=true;
        }                                                                                           
        return isTandCAccepted;
    } 
    
    /*This method is reusable method to generate Contact Id for LoggedIn User
     */
    private static Id getContactId(){
        return [Select ContactId from User where Id =:UserInfo.getUserId() limit 1].ContactId;
    }
    /*This method will return list of communties for User added in Step 2.
     * This method will check and return only those communties which is slected by user and request was not created before.
     */
    private static List<String> addEnrollmentRequests(List<String> enrolledCommunities, Id loggedInContactId){
        for(PRM_Partner_Community_Enrollment_Request__c enrollmentRequest: [Select  PRM_Partner_Community_Nm__c 
                                                                                from PRM_Partner_Community_Enrollment_Request__c 
                                                                                where PRM_Contact_Id__c = :loggedInContactId 
                                                                                And (PRM_Status_Nm__c =:STATUS_PENDING 
                                                                                     OR PRM_Status_Nm__c=:STATUS_APPROVED)]){
                                                                                    if(!enrolledCommunities.contains(enrollmentRequest.PRM_Partner_Community_Nm__c)){
                                                                                        enrolledCommunities.add(enrollmentRequest.PRM_Partner_Community_Nm__c);
                                                                                    }
                                                                                }
        return enrolledCommunities;
    }
    //Wrapper to return response after submitCommunityEnrollmentRequest and loadTermAndConditions
    @TestVisible
    private class SuccessResponseWrapper{
        private Boolean success = true;
        private String messageId;
        private String stepId;
        private List<Object> community;
        @TestVisible
        private Boolean stepOneCompleted;
        @TestVisible
        private Boolean stepTwoCompleted;
    }
    
    //wrapper to return response after 
    @TestVisible
    private class RedirectResponseWrapper{
        @TestVisible
        private Boolean stepOneCompleted;
        @TestVisible
        private String redirectUrl;
    }

    /* This methid is called from manage personal, dashboard, manage benefit and company profile to check 
    * if t&c is checked and correct subscriptions are there or else redirect to on-boarding page
    */
    @AuraEnabled(cacheable=true)
    public static String onBoardingRedirect(){
        RedirectResponseWrapper redirectResponse = new RedirectResponseWrapper();
        redirectResponse.stepOneCompleted = isTandCandSubscriptionCheck();
        redirectResponse.redirectUrl = getRedirectUrl();
        return JSON.serialize(redirectResponse);        
    }
    
    /*This method will return true T&C is checked and subscriptions are correct */
    @TestVisible
    private static Boolean isTandCandSubscriptionCheck(){
        Boolean isTandCSubscriptionCheck = false;
       
        try{
            Id loggedInContactId=getContactId();
            Boolean isTandCAccepted=isTAndCAccepted(loggedInContactId);
            List<String> subCodeList =System.Label.PRM_Post_Onboarding_Subscription_Code.split(',');
            List<PRM_ContactSubscriptionAssociation__c> contactSubs =[Select Id from PRM_ContactSubscriptionAssociation__c 
                                                                      where PRM_Contact_Id__c=:loggedInContactId
                                                                      AND PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c IN:subCodeList];
            if(!contactSubs.isEmpty() && contactSubs.size()==subCodeList.size() && isTandCAccepted){
                isTandCSubscriptionCheck=true;
            }
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
        return isTandCSubscriptionCheck;
    }   
    /** This method is called to get post-launch-primary or post-launc-non-primary link base on user type
     * 
     */
     @TestVisible
    private static string getRedirectUrl(){
        String redirectUrl = '';
        try {
            User loggedInUser = [SELECT ContactId,Email, AccountId,profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];            
            if(loggedInUser.ContactId!=null && loggedInUser.profile.Name == System.Label.Core_Partner_Profile_Name) {
                List<String> partnerEntlmnt = new List<String>();
                List<String> empEntlmnt = new List<String>();
                for(Core_Contact_Entitlement__c entlmnt : [select id,Core_Entitlement_Id__r.name, Core_Status__c, Core_Selected__c from Core_Contact_Entitlement__c where Core_Selected__c= true and Core_Status__c='complete' and Core_Contact_Id__c =:loggedInUser.ContactId]){
                    if(entlmnt.Core_Entitlement_Id__r.name == System.Label.PRM_Employee) {
                        empEntlmnt.add(entlmnt.Core_Entitlement_Id__r.name);
                    }
                    if( entlmnt.Core_Entitlement_Id__r.name == System.Label.PRM_Partner_Admin || entlmnt.Core_Entitlement_Id__r.name == System.Label.PRM_Partner_Admin_Delegate) {
                        partnerEntlmnt.add(entlmnt.Core_Entitlement_Id__r.name);
                    }
                }
                if(empEntlmnt.size()>partnerEntlmnt.size()) {
                    redirectUrl = System.Label.PRM_Post_Launch_Non_Primary_Link;
                }else{
                    redirectUrl = System.Label.PRM_Post_Launch_Primary_Link;
                }
            }
        }
        catch(Exception ex){
            System.debug('Exception '+ex.getMessage());
        }
        return redirectUrl;
    }
}