public with sharing class PMP_SearchPartnerDetailsController extends PMP_SearchWrapperStore{
    
    
    @AuraEnabled(cacheable=true)
    public static PartnerDetail getPartnerDetails(String partnerId, String langCode){
        //System.debug('PPP-->partnerId:'+partnerId);
        PartnerDetail partnerDetail=new PartnerDetail();
        PMP_Company__c company = new PMP_Company__c();
        PMP_Company__c companyWithPublished = new PMP_Company__c();
        //TranslationEOL
        string description='';
        string tagline = '';
        //String jsonValue;
        //Boolean cachePreview=False;
        
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){
            //Modified as a part of OPID Restructure : Removing PMP_Account_Id__c from the Query                                
            company=[SELECT Id, Name,PMP_Is_Working_Copy_Ind__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c, PMP_Account_Dsc__c, PMP_Account_Address_Txt__c,
                     PMP_Account_Industry__c, PMP_Account_Application__c,PMP_Account_Region__c, PMP_Account_Program_Membership__c,PMP_Company_Lifecycle_Status_Nm__c, 
                     PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c, PMP_Account_Specialty__c,PMP_Account_Website__c,
                     PMP_Account_Tag_Line__c,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,
                     PMP_Working_Copy_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Working_Copy_Id__r.PMP_Is_Updated_Ind__c,
                     PMP_Working_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Published_Copy_Id__c,
                     PMP_Published_Copy_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Published_Copy_Id__r.PMP_Is_Updated_Ind__c,
                     PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Published_Ind__c,
                     PMP_Published_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Enhanced_Login_Users_Txt__c,
                     toLabel(PMP_Disti_Components_Nm__c),toLabel(PMP_Disti_Sys_Solutions_Nm__c),PMP_Is_Distributor_Ind__c,PMP_Company_Status_Published_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c
                     ,PMP_Autofill_Txt__c
                     FROM PMP_Company__c where id=:partnerId LIMIT 1];
            //TranslationEOL
            if(company != null){
                description=company.PMP_Account_Dsc__c;
                tagline=company.PMP_Account_Tag_Line__c;
            }
        }
        if(company.PMP_Is_Working_Copy_Ind__c == true){
            try{
                //Modified as a part of OPID Restructure : Removing PMP_Account_Id__c from the Query                                      
                if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                    company=[SELECT Id, Name,PMP_Is_Working_Copy_Ind__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c, PMP_Account_Dsc__c, PMP_Account_Address_Txt__c,PMP_Company_Lifecycle_Status_Nm__c,
                             PMP_Account_Industry__c, PMP_Account_Application__c,PMP_Account_Region__c, PMP_Account_Program_Membership__c, 
                             PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c, PMP_Account_Specialty__c,PMP_Account_Website__c,
                             PMP_Account_Tag_Line__c,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,
                             PMP_Working_Copy_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Working_Copy_Id__r.PMP_Is_Updated_Ind__c,
                             PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Published_Ind__c,
                             PMP_Working_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Enhanced_Login_Users_Txt__c,
                             toLabel(PMP_Disti_Components_Nm__c),toLabel(PMP_Disti_Sys_Solutions_Nm__c),PMP_Is_Distributor_Ind__c,PMP_Published_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c,PMP_Company_Status_Published_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c,
                             PMP_Autofill_Txt__c
                             FROM PMP_Company__c where PMP_Working_Copy_Id__c =: partnerId LIMIT 1];
                }
                if(company != null){
                    partnerId = company.Id;
                    //TranslationEOL
                    description=company.PMP_Account_Dsc__c;
                    tagline=company.PMP_Account_Tag_Line__c;
                }
            }catch(Exception e){
                //system.debug('error while fetching company records' + e);
            }
            
        }
        if(company != null && company.PMP_Is_Published_Ind__c == true){
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                // companyWithPublished=[select PMP_Working_Copy_Id__c from PMP_Company__c where id=:partnerId limit 1];
                //Modified as a part of OPID Restructure : Removing PMP_Account_Id__c from the Query                                                                
                company=[SELECT Id, Name,PMP_Is_Working_Copy_Ind__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c, PMP_Account_Dsc__c, PMP_Account_Address_Txt__c,
                         PMP_Account_Industry__c, PMP_Account_Application__c,PMP_Account_Region__c, PMP_Account_Program_Membership__c,PMP_Company_Lifecycle_Status_Nm__c, 
                         PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c, PMP_Account_Specialty__c,PMP_Account_Website__c,PMP_Enhanced_Login_Users_Txt__c,
                         PMP_Account_Tag_Line__c,PMP_Published_Copy_Id__c,PMP_Is_Updated_Ind__c,PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Company_Status_Update_Dt__c,
                         PMP_Published_Copy_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Published_Copy_Id__r.PMP_Is_Updated_Ind__c,
                         PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Published_Ind__c, PMP_Published_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Enhanced_Login_Users_Txt__c,
                         toLabel(PMP_Disti_Components_Nm__c),toLabel(PMP_Disti_Sys_Solutions_Nm__c),PMP_Is_Distributor_Ind__c,PMP_Company_Status_Published_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c
                         ,PMP_Autofill_Txt__c
                         FROM PMP_Company__c where PMP_Published_Copy_Id__c=:partnerId LIMIT 1];
                //TranslationEOL
                if(company != null){
                    partnerId= company.id;//already we got working copy here
                    description=company.PMP_Account_Dsc__c;
                    tagline=company.PMP_Account_Tag_Line__c;
                    system.debug('company with published for fetching working copy'+company+'id'+company.id+'workingcopy'+company.PMP_Working_Copy_Id__c);
                    
                }
            }
        }   
        // SAFETY CHECK
        if(company == null){
            return partnerDetail;
        }
        
        partnerDetail.id = partnerId;
        partnerDetail.name = company.Name;
        partnerDetail.promotion = new List<Promotion>();
        partnerDetail.categories = new List<CategoryTab>();
        partnerDetail.companyResources = new List<PartnerResource>();
        partnerDetail.mobileList = new List<Mobile>();
        
        Partner partner = PMP_ProductPartnerDetailsController.getPartnerDetails(company.Id, company, false, langCode);
        
        if(partner != null){
            partner.contactByEmail = false;
            partner.contactByForm = true;
            //partner.imageUrl='https://via.placeholder.com/350x197/0071C5/FFFFFF?text=Product';
            partnerDetail.partnerDetails= partner;
        }
        //Logic to show notifications in storefront
        if (company.PMP_Is_Published_Ind__c ==true && company.PMP_Working_Copy_Id__r != null)
        {
            system.debug('entered into published cpy'+company.PMP_Is_Working_Copy_Ind__c );
            partnerDetail.currentStatus = company.PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c;
            partnerDetail.publishedStatus = company.PMP_Company_Lifecycle_Status_Nm__c;
            partnerDetail.isUpdateRequired = company.PMP_Working_Copy_Id__r.PMP_Is_Updated_Ind__c;
            //partnerDetail.partnerType=company.PMP_Working_Copy_Id__r.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c;
            if (company.PMP_Working_Copy_Id__r.PMP_Company_Status_Update_Dt__c!=null)
            {
                Date dt = company.PMP_Working_Copy_Id__r.PMP_Company_Status_Update_Dt__c;
                //system.debug('Date :'+ dt);
                
                DateTime dtm = DateTime.newInstance(dt.year(),dt.month(),dt.day());
                //system.debug('DateTime :'+ dtm);
                partnerDetail.statusUpdateDate = dtm.format('dd-MMM-yyyy');
                
            }  
            if (company.PMP_Working_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c !=null)
            {
                Date dt = company.PMP_Working_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c;
                DateTime dtm = DateTime.newInstance(dt.year(),dt.month(),dt.day());
                partnerDetail.initialUpdateDate = dtm.format('dd-MMM-yyyy');
                
            }
            if (company.PMP_Working_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c !=null)
            {
                Date dt = company.PMP_Working_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c;
                DateTime dtm = DateTime.newInstance(dt.year(),dt.month(),dt.day());
                partnerDetail.publishedDate = dtm.format('dd-MMM-yyyy');
                
            }
            //For adding banner to storefront if its AI generated
            if(company.PMP_Company_Lifecycle_Status_Nm__c == 'Draft' && (company.PMP_Autofill_Txt__c=='Scraped' || company.PMP_Autofill_Txt__c=='LLM_Knowledge' || company.PMP_Autofill_Txt__c=='Mixed' ) ){
                partnerDetail.scrapingValue = True; 
            }
            
        }
        //autofill logic
        if (company.PMP_Is_Working_Copy_Ind__c ==true)//this is working copy
        {
            system.debug('entered into workingcopy'+company.PMP_Is_Published_Ind__c );
            partnerDetail.currentStatus = company.PMP_Company_Lifecycle_Status_Nm__c;
            partnerDetail.publishedStatus = company.PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c;
            partnerDetail.isUpdateRequired = company.PMP_Is_Updated_Ind__c;
            //partnerDetail.partnerType=company.PMP_Working_Copy_Id__r.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c;
            if (company.PMP_Company_Status_Update_Dt__c!=null)
            {
                Date dt = company.PMP_Company_Status_Update_Dt__c;
                //system.debug('Date :'+ dt);
                
                DateTime dtm = DateTime.newInstance(dt.year(),dt.month(),dt.day());
                //system.debug('DateTime :'+ dtm);
                partnerDetail.statusUpdateDate = dtm.format('dd-MMM-yyyy');
                
            }  
            if (company.PMP_Initial_Storefront_Submit_Date_Dt__c !=null)
            {
                Date dt = company.PMP_Initial_Storefront_Submit_Date_Dt__c;
                DateTime dtm = DateTime.newInstance(dt.year(),dt.month(),dt.day());
                partnerDetail.initialUpdateDate = dtm.format('dd-MMM-yyyy');
                
            }
            if (company.PMP_Company_Status_Published_Date_Dt__c !=null)
            {
                Date dt = company.PMP_Company_Status_Published_Date_Dt__c;
                DateTime dtm = DateTime.newInstance(dt.year(),dt.month(),dt.day());
                partnerDetail.publishedDate = dtm.format('dd-MMM-yyyy');
                
            }
            //For adding banner to storefront if its AI generated
            if(company.PMP_Company_Lifecycle_Status_Nm__c == 'Draft' && (company.PMP_Autofill_Txt__c=='Scraped' || company.PMP_Autofill_Txt__c=='LLM_Knowledge' || company.PMP_Autofill_Txt__c=='Mixed' ) ){
                partnerDetail.scrapingValue = True; 
            }
            
        }
        //autofill logic ends here
        if(tagline != null){
            partnerDetail.tagline = tagline.unescapeHtml4(); 
        }
        
        
        //Logic to show more or show less is handled at the UI level
        if (description != null)
        {   
            partnerDetail.partnerDescription= description.unescapeHtml4();
            partnerDetail.partnerShortDescription = description.unescapeHtml4().stripHtmlTags(); //Sending striped string to display in intro section ()
        }
        //To get Partner Resource
        List<PMP_Company_Resource__c> resourceList = new List<PMP_Company_Resource__c>();
        if(Schema.sObjectType.PMP_Company_Resource__c.isAccessible()){
            if(partnerId==company.id || partnerId==company.PMP_Published_Copy_Id__c/*|| partnerId==company.PMP_Working_Copy_Id__c ||  partnerId==company.PMP_Published_Copy_Id__c*/)
                resourceList = [SELECT id,PMP_Company_Resource_Type_Nm__c, PMP_Company_Resource_URL_txt__c, Name  from PMP_Company_Resource__c where PMP_Company_Id__c=:partnerId and PMP_Company_Resource_Type_Nm__c!='Image' and PMP_Company_Resource_Type_Nm__c!='Thumbnail Image'];
        }
        for(PMP_Company_Resource__c resource : resourceList){
            PartnerResource res= new PartnerResource();
            res.title= resource.Name;
            res.linkUrl = resource.PMP_Company_Resource_URL_txt__c;
            res.type =resource.PMP_Company_Resource_Type_Nm__c;
            res.openInNewTab= true;
            partnerDetail.companyResources.add(res);
        }
        
        // To show offering related to partner 
        
        //List<PMP_Partner_Offering_Category__c> offCatList = new List<PMP_Partner_Offering_Category__c>();
        //Benefit
        List<String> benCode = new List<String>();
        
        // partnerDetail.partnerType=company.PMP_Account_Id__c.AccountBenefitAssociations__r.PRM_Benefit_Cd__c;
        //Modified as a part of OPID Restructure
        List<Id> accIds = new List<Id>();
        List<PMP_OPID_MPI_Rel__c> junctionObjects = PMP_Utility.getJunctionAccToMpiByCompanyId(company.PMP_Published_Copy_Id__c);
        for(PMP_OPID_MPI_Rel__c juncRec : junctionObjects){
            accIds.add(juncRec.PMP_One_Partner_ID__c);
        }
        List<PRM_AccountBenefitAssociation__c> allBenefits = [SELECT PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c FROM PRM_AccountBenefitAssociation__c WHERE PRM_Account_Id__c in: accIds AND PRM_Status_Nm__c = 'Active'];
        for (PRM_AccountBenefitAssociation__c accBen : allBenefits)
        {
            benCode.add(accBen.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c);
        }
        
        if (benCode.contains(PMP_StaticConstants_Partner.BENEFIT_ENHANCED_CODE))
        {
            
            //getPartnerCategories(partnerDetail, company.Id);
            //For Enhanced
            //partnerDetail.showMoreSection=true;
            partnerDetail.partnerType=PMP_StaticConstants_Partner.BENEFIT_ENHANCED_CODE;
            //getPartnerOfferings(partnerDetail, company.Id, company.Name, langCode);//IPA2.0:US-4497-1631_OfferingEOL
            partnerDetail.showCompanyResourceAndArticle=false;
            partnerDetail.showCompanyResourceAndArticleforEnhanced=true;
            
        }
        else  
            //if(benCode.contains(PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE))
        {
            //For Basic
            partnerDetail.showMoreSection=true;
            partnerDetail.partnerType=PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE;
            partnerDetail.showCompanyResourceAndArticleforEnhanced=false;
            partnerDetail.showCompanyResourceAndArticle=true;
        }
        
        
        
        
        //Logic related to Edit Storefront access
        partnerDetail.hasAccess = false;
        partnerDetail.isGuest = false;
        Map<String, Boolean> isSamePartnerUserMap = new Map<String, Boolean>();
        Boolean isSamePartnerUserIndicator = false;
        
        
        //To check system admin
        Boolean isSysAdmin = false;
        Id profId = userInfo.getProfileId();
        String profileName = [Select Name from Profile where Id =: profId].Name;
        
        if(PMP_StaticConstants_Partner.adminProfiles.contains(profileName)){
            isSysAdmin = true;
        }    
        List<String> partnerAccountIds = new List<String>();
        
        //Modified as a part of OPID Restructure
        List<PMP_OPID_MPI_Rel__c> alljunctionRecs = PMP_Utility.getJunctionAccToMpiByCompanyId(company.PMP_Published_Copy_Id__c);
        for(PMP_OPID_MPI_Rel__c juncRec : alljunctionRecs){
            partnerAccountIds.add(juncRec.PMP_One_Partner_ID__c);
        }
        //Existing Logic
        //partnerAccountIds.add(company.PMP_Account_Id__c);
        //Checking if same partner's user
        isSamePartnerUserMap = PMP_SearchUtilityController.isSamePartnerUser(partnerAccountIds);
        isSamePartnerUserIndicator=PMP_SearchUtilityController.isSamePartnerUserMethod(partnerAccountIds);
        //Modified as a part of OPID Restructure
        Boolean isSamePartner = false;
        for(String acc : partnerAccountIds){
            if(!isSamePartnerUserMap.containsKey(acc)){
                isSamePartnerUserMap.put(acc, false);
            }else{
                isSamePartner = isSamePartnerUserMap.get(acc);
            }
        }
        //Existing Logic
        /*if(!isSamePartnerUserMap.containsKey(company.PMP_Account_Id__c))
isSamePartnerUserMap.put(company.PMP_Account_Id__c, false);
*/
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> isOtherPartnerPSet = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> isPartnerAdminPSet = new List<PermissionSetAssignment>();
        
        //if(Schema.sObjectType.PermissionSetAssignment.isAccessible() && Schema.sObjectType.User.isAccessible()){
        permissionSetList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name in :PMP_StaticConstants_Partner.permissionSets];
        
        isPartnerAdminPSet = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: Userinfo.getUserId() AND PermissionSet.Name =:PMP_StaticConstants_Partner.permissionSets[0]];
        
        isOtherPartnerPSet = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: Userinfo.getUserId() AND PermissionSet.Name =:PMP_StaticConstants_Partner.otherPartnerPSets];
        //} 
        //system.debug('!PMP_SearchUtilityController.isGuest() => '+!PMP_SearchUtilityController.isGuest());
        //system.debug('isSamePartnerUserMap => '+isSamePartnerUserMap);
        //system.debug('isSamePartnerUserMap.get(company.PMP_Account_Id__c) => '+isSamePartnerUserMap.get(company.PMP_Account_Id__c));
        //system.debug('permissionSetList => '+permissionSetList);
        if(!PMP_SearchUtilityController.isGuest()){
            if(PMP_StaticConstants_Partner.adminProfiles.contains(profileName)  || isSamePartnerUserIndicator && permissionSetList.size()>0)                                                           
                // if(PMP_StaticConstants_Partner.adminProfiles.contains(profileName)  || (isSamePartnerUserMap.get(company.PMP_Account_Id__c) && permissionSetList.size()>0))
                partnerDetail.hasAccess = true;
            if(PMP_SearchUtilityController.isIntelAdmin()){
                partnerDetail.hasAccess = true;
            }
        }
        // system.debug('hasAccess => '+partnerDetail.hasAccess);
        partnerDetail.isGuest = PMP_SearchUtilityController.isGuest();
        partnerDetail.leadSettings = PMP_SearchCompanyLeadGenController.getExistingSettings(partnerId);
        //system.debug('LeadSettings : ' + partnerDetail.leadSettings);
        //system.debug('leadLangPreference => '+PMP_SearchUtilityController.getLanguageMessage(partnerDetail.leadSettings.languagePreference));
        partnerDetail.leadLangPreference = PMP_SearchUtilityController.getLanguageMessage(partnerDetail.leadSettings.languagePreference);
        /** MANAGE OFFERINGS FUNCTIONALITY START**/
        List<PermissionSetAssignment> isMangeOfferingsPSet = [SELECT Id,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =: Userinfo.getUserId() AND PermissionSet.Name in:PMP_StaticConstants_Partner.manageOfferingPermissionSets];
        
        if( !partnerDetail.isGuest){
            //Modified as a part of OPID Restructure
            for(Id acc : accIds){
                if(!isPartnerAdminPSet.isEmpty() && isPartnerAdminPSet.size() > 0 && isSamePartnerUserIndicator){
                    //if(isSamePartnerUserIndicator){
                    partnerDetail.hasLeadGenAccess = true;
                    //}
                }else if(!isOtherPartnerPSet.isEmpty() && isOtherPartnerPSet.size()>0 && isSamePartnerUserIndicator){
                    //if(isSamePartnerUserIndicator){
                    partnerDetail.hasLeadGenAccess = false;
                    //}
                }
                if(!isMangeOfferingsPSet.isEmpty() && isMangeOfferingsPSet.size()>0 && isSamePartnerUserIndicator){
                    //if(isSamePartnerUserIndicator){     
                    partnerDetail.manageOfferingAccess = true;                            
                    //}
                }
            }
            
            
            
            // Admin If Ends 
            //Modified as a part of OPID Restructure
            partnerDetail.isSamePartnerUser = isSamePartnerUserIndicator;
            //Existing Logic
            //partnerDetail.isSamePartnerUser = isSamePartnerUserMap.get(company.PMP_Account_Id__c);
        }//Guest if Ends
        else{
            partnerDetail.isSamePartnerUser = false;
            partnerDetail.manageOfferingAccess = false;
        }
        if(isSysAdmin || PMP_SearchUtilityController.isIntelAdmin()){
            partnerDetail.hasLeadGenAccess = true;
            partnerDetail.isSamePartnerUser = true;
            partnerDetail.manageOfferingAccess = true;            
        }
        partnerDetail.isIntelAdmin = PMP_SearchUtilityController.isIntelAdmin();
        /*** Lead Gen Logic Ends ***/ 
        
        partnerDetail.isContactPartnerVisible = PMP_SearchUtilityController.isContactButtonVisible(company);
        
        partnerDetail.showEnhancedPopup = !(company.PMP_Working_Copy_Id__r.PMP_Enhanced_Login_Users_Txt__c != NULL && company.PMP_Working_Copy_Id__r.PMP_Enhanced_Login_Users_Txt__c.contains(UserInfo.getUserId()));
        
        //New Logic for entitlements - Prabuddh (09/13/2020)
        final List<String> entitlements = getEntitlementsForCurrentUser(); 
        partnerDetail.isMarkettingSpecialist = entitlements.contains(PMP_StaticConstants_Partner.MARKETING_SPECIALIST);  
        partnerDetail.isPartnerAdmin = entitlements.contains(PMP_StaticConstants_Partner.PARTNER_ADMIN);    
        partnerDetail.isOfferingEditor = entitlements.contains(PMP_StaticConstants_Partner.OFFERING_EDITOR);  
        // Modified below condition to fix the production Issue -> Added by Onyx (18/02/2022) // Prod Fix - INC11025773
        if (entitlements.contains(PMP_StaticConstants_Partner.EMPLOYEE) && entitlements.size()==1) {
            partnerDetail.isLdrOeEmployee = true;
        } 
        else if (entitlements.contains(PMP_StaticConstants_Partner.LDR) || entitlements.contains(PMP_StaticConstants_Partner.OFFERING_EDITOR)) {
            partnerDetail.isLdrOeEmployee = true;
        }
        else {
            partnerDetail.isLdrOeEmployee = false;
        }     
        
        // System.debug('partnerDetail'+partnerDetail);
        return partnerDetail;
    } 
    
    public static String updatePartnerInfo(String partnerId) {
        
        String retStr = 'Failed';
        
        if (String.isBlank(partnerId) || !Schema.sObjectType.PMP_Company__c.isAccessible()) {
            return retStr;
        }
        
        Id userId = UserInfo.getUserId();
        
        // SINGLE QUERY (fetch working copy in same query)
        PMP_Company__c company = [
            SELECT Id,
            PMP_Is_Working_Copy_Ind__c,
            PMP_Working_Copy_Id__c,
            PMP_Enhanced_Login_Users_Txt__c,
            PMP_Working_Copy_Id__r.Id,
            PMP_Working_Copy_Id__r.PMP_Enhanced_Login_Users_Txt__c
            FROM PMP_Company__c
            WHERE Id = :partnerId
        ];
        
        // RESOLVE WORKING COPY (NO EXTRA QUERY)
        if (!company.PMP_Is_Working_Copy_Ind__c && company.PMP_Working_Copy_Id__r != null) {
            company = company.PMP_Working_Copy_Id__r;
        }
        
        // ================= SAFE STRING UPDATE =================
        String existingUsers = company.PMP_Enhanced_Login_Users_Txt__c;
        
        if (String.isNotBlank(existingUsers)) {
            
            // OPTIONAL: prevent duplicates
            Set<String> usersSet = new Set<String>(existingUsers.split(';'));
            usersSet.add(String.valueOf(userId));
            
            company.PMP_Enhanced_Login_Users_Txt__c =
                String.join(new List<String>(usersSet), ';');
            
        } else {
            company.PMP_Enhanced_Login_Users_Txt__c = String.valueOf(userId);
        }
        
        // ================= DML =================
        update company;
        
        return 'Success';
    }
    
    public static List<String> getEntitlementsForCurrentUser(){
        List<String> entitlements = new List<String>();
        
        List<PermissionSetAssignment> pSetList = [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId() and PermissionSet.IsOwnedByProfile = false];
        
        for(PermissionSetAssignment ps : pSetList){
            entitlements.add(ps.PermissionSet.Name);
        }
        return entitlements;
    }
}