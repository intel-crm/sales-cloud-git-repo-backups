/****************************************************************************************************************************************
* Class Name  : PMP_CreateOfferingTab1Service 
* Version     : 1.0 
* Created Date: 04-25-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Manasa                 04-25-2019                    Created for displaying tab1 - offering details elements in 'Create Offering' components
****************************************************************************************************************************************************************/
public with sharing class PMP_CreateOfferingTab1Service { 
   
    
    public static Intel_Step getOfferingDetailsInputs(string stepName,string categoryPIMId,
                                                      List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specList,
                                                      Map<String, PMP_Specifications_Tab_Mapping__mdt> stepConfigurationsMap,
                                                      PMP_Partner_Offering__c offering,set<string> offSpecSet,
                                                        map<string,string> specValDataMap,map<string,List<string>> specValListMap, string language ){
          system.debug('****categoryPIMId****'+categoryPIMId);//category name changed to category PIM Id by raj[09/13] 
          
          // STEP 1: Offering Details
          Intel_Step step1 = PMP_Offering_UI_Generator.createStep(stepName);
          //Section 1 for offering details
          //Intel_Section section1 = PMP_Offering_UI_Generator.createSection(System.Label.PMP_Create_New_Offering);
          Intel_Section section1 = PMP_Offering_UI_Generator.createSection(''); 
          step1.sections.add(section1); 
          //Sub-Section for offering details
          Intel_Subsection sub1a = PMP_Offering_UI_Generator.createSubsection(System.Label.PMP_Offering_Overview);
          section1.subsections.add(sub1a);
          // INPUTS
          // language - dropdown
          Intel_Dropdown T1S1C1 = PMP_Offering_UI_Generator.createDropdown('PMP_Offering_Language_Nm__c',System.Label.PMP_Input_Language,'PMP_Partner_Offering__c',true,'offering');
          T1S1C1.disabled = language !=null ?true : false;
          sub1a.inputs.add(T1S1C1);
          
          //Empty - field to shift Name field below Language US:356458 Manasa
          Intel_Text empty = PMP_Offering_UI_Generator.createText(null,null,null,null);
          sub1a.inputs.add(empty); 
          
          // Offering Name - Textbox
          Intel_Text T1S1C2 = PMP_Offering_UI_Generator.createText('PMP_Partner_Offering_Nm__c',System.Label.PMP_Offering_Name,true,'offering');
          sub1a.inputs.add(T1S1C2);
          
          
          // Description - Rich Textbox
          Intel_RichText T1S1C3 = PMP_Offering_UI_Generator.createRichText('PMP_Partner_Offering_Dsc__c',System.Label.PMP_Description,System.Label.PMP_CTA_Complete_The_Field,true,'offering');
          sub1a.inputs.add(T1S1C3);
          
                                                            // Offered By - Dropdown (Company Options)          
                                                            /*
                                                            * @Description:populate (Offered By:Company information) for Admin and Partner Users 
                                                            * @Author:Gireesh
                                                            * @UserStory:US322454
                                                            * */
                                                            
                                                            String userId=UserInfo.getUserId();
                                                            Profile profileName=[SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
                                                            User userDetails=[SELECT Id, ContactId,Name, UserType, ProfileId, IsActive,IsPortalEnabled,LastName FROM User where id=:userId];
                                                            //Group grp=[SELECT Id FROM Group where Name='PMP - All Intel Admin Users' LIMIT 1];
                                                            //Declaring textBox with a map
                                                            Map<String,String> additionalInfoMap=new Map<String,String>();
                                                            Intel_Text partnerOfferingByTextBox = PMP_Offering_UI_Generator.createText('PMP_Company_Id__c',System.Label.PMP_Offered_By,true,'company');
                                                            partnerOfferingByTextBox.valueType='complex';
                                                            partnerOfferingByTextBox.disabled=True;
                                                            partnerOfferingByTextBox.textValue='';
                                                            Boolean isAccountAvailabel=false;
                                                            Boolean adminUser=false;
                                                            Boolean mdaIndicator=false;
                                                            
                                                            
                                                            //If the user is part of Admin Group, then show the drop down with all the company info
                                                            {
                                                                Group grp=[SELECT Id FROM Group where Name='PMP - All Intel Admin Users' LIMIT 1];
                                                                if (grp!=Null){
                                                                    List<GroupMember> groupMembers=[SELECT UserOrGroupId FROM GroupMember where GroupId=:grp.Id]; 
                                                                    for (GroupMember groupMember: groupMembers){
                                                                        if(groupMember.UserOrGroupId==userId ){
                                                                            adminUser=true;
                                                                            isAccountAvailabel=true;
                                                                            break;
                                                                        }
                                                                    }
                                                                }
                                                                
                                                            }
                                                            
                                                            //If Partner User
                                                            if(!adminUser && userDetails.IsPortalEnabled){                                                             
                                                                List<Contact> userAccount=null;
                                                                PMP_Company__c companyInformation;
                                                                
                                                                if(userDetails.ContactId!=null){
                                                                    userAccount=[SELECT Id, Name, AccountId FROM Contact where Id=:userDetails.ContactId LIMIT 1];
                                                                    //system.debug('account:'+userAccount[0].AccountId);
                                                                    if(userAccount.size()>0){
                                                                        
                                                                        
                                                                       
                                                                        //Query on Partner Account Group  
                                                                        List<Core_Account_Group_Member__c> accountGroupMember=[select Core_Partner_Account_Id__c, Core_MDA_Ind__c,
                                                                                                                               Core_Intel_Account_Id__c from Core_Account_Group_Member__c 
                                                                                                                               where Core_Intel_Account_Id__c=:userAccount[0].AccountId  LIMIT 1];
                                                                        //Chek if MDA indicator is not active 
                                                                        if(accountGroupMember.size()>0 && !accountGroupMember[0].Core_MDA_Ind__c){
                                                                            /* For the Partner Account get Intel Accounts among which has MDA as active */
                                                                            List<Core_Account_Group_Member__c> partnerAccountGroupMember=[select Core_Partner_Account_Id__c, Core_MDA_Ind__c,
                                                                                                                                          Core_Intel_Account_Id__c from Core_Account_Group_Member__c 
                                                                                                                                          where Core_Partner_Account_Id__c=:accountGroupMember[0].Core_Partner_Account_Id__c 
                                                                                                                                          and Core_MDA_Ind__c=true  LIMIT 1];
                                                                            if(partnerAccountGroupMember.size()>0){
                                                                                mdaIndicator=true;
                                                                                isAccountAvailabel=true;
                                                                                companyInformation=getCompanyInfoForAccount(partnerAccountGroupMember[0].Core_Intel_Account_Id__c);
                                                                            }
                                                                        }
                                                                        //Check if MDA indicator is active
                                                                        else if(accountGroupMember.size()>0 && accountGroupMember[0].Core_MDA_Ind__c){
                                                                            //if(!mdaIndicator)
                                                                            isAccountAvailabel=true;
                                                                            companyInformation=getCompanyInfoForAccount(userAccount[0].AccountId);
                                                                        }
                                                                        //If MDA indicator is active then add the company information text box with value
                                                                        if(isAccountAvailabel){
                                                                            additionalInfoMap.put('relatedId',companyInformation.Id);
                                                                            partnerOfferingByTextBox.additionalValues=additionalInfoMap;
                                                                            partnerOfferingByTextBox.textValue=companyInformation.Name;
                                                                            sub1a.inputs.add(partnerOfferingByTextBox);
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            /*Show drop down for System Admin and IT Admin*/
                                                            else if(profileName.Name==Label.PMP_System_Administrator || profileName.Name==PMP_StaticConstants_Offering.ITADMIN ){
                                                                //Get All company information
                                                                adminUser=true;
                                                                isAccountAvailabel=true;
                                                                 
                                                            }
                                                            
                                                            if(adminUser){
                                                                Map<Id,String> companyNameMap = new Map<id,String>();
                                                                companyNameMap =getCompanyInfoOptions(); 
                                                                Intel_Dropdown T1S1C4 = PMP_Offering_UI_Generator.createDropdown(companyNameMap,'PMP_Company_Id__c',System.Label.PMP_Offered_By,true,'offering');
                                                                sub1a.inputs.add(T1S1C4); 
                                                            }
                                                            
                                                            /* Display blank text for any other users/if account or contact is not found*/
                                                            if(!isAccountAvailabel && !adminUser){
                                                                partnerOfferingByTextBox.additionalValues=additionalInfoMap;
                                                                sub1a.inputs.add(partnerOfferingByTextBox);
                                                            }


                                                           /* Map<Id,String> companyNameMap = new Map<id,String>();
                                                            companyNameMap = getCompanyInfoOptions();
          Intel_Dropdown T1S1C4 = PMP_Offering_UI_Generator.createDropdown(companyNameMap,'PMP_Company_Id__c',System.Label.PMP_Offered_By,true,'offering');
          sub1a.inputs.add(T1S1C4);*/
          
          //Offering View Options - Dropdown
          Intel_Dropdown T1S1C5 = PMP_Offering_UI_Generator.createDropdown('PMP_Partner_Offering_Visibility_Nm__c',System.Label.PMP_Offering_Visibility,'PMP_Partner_Offering__c',true,'offering');
          sub1a.inputs.add(T1S1C5);
          
          //Offering Validity Start Date - Date Field
          Intel_Text T1S1C6 = PMP_Offering_UI_Generator.createDate('date','PMP_Partner_Offering_Start_Dt__c',System.Label.PMP_Offering_Valid_From,true,'offering');
          sub1a.inputs.add(T1S1C6);
          
          //Offering Validity End Date - Date Field
          Intel_Text T1S1C7 = PMP_Offering_UI_Generator.createDate('date','PMP_Partner_Offering_End_Dt__c',System.Label.PMP_Offering_Valid_To,true,'offering');
          sub1a.inputs.add(T1S1C7);
          
          // Tagline - Textbox
          Intel_Text T1S1C8 = PMP_Offering_UI_Generator.createText('PMP_Partner_Offering_Tag_Line_Txt__c',System.Label.PMP_Tag_Line,false,'offering');
          sub1a.inputs.add(T1S1C8);
          
          // --------coments start-------------------------------------------------------------------------------------------------------------------------
          /*Intel_Subsection sub1b = PMP_Offering_UI_Generator.createSubsection(System.Label.PMP_Offering_Overview);
    section1.subsections.add(sub1b);
    //comments end*/
          Intel_Subsection sub1c = new Intel_Subsection();
          if(categoryPIMId!=null){
              List<PMP_CategoryController.Core_PMP_OfferingCategory> categoryWrapper = getOfferingCategorySubCategoryList(categoryPIMId,language,PMP_StaticConstants_Offering.categoryType);//categoryName replaced with categoryPIMId
              //Comments start
              
              /*Map<string,string> categoryPicklistMap = New Map<string,string>();
    for(PMP_CategoryController.Core_PMP_OfferingCategory iterWrapper : categoryWrapper){
    categoryPicklistMap.put(iterWrapper.PIMCategoryId,iterWrapper.categoryName);
    }
    Intel_Dropdown T1S2C1 = PMP_Offering_UI_Generator.createDropdown(categoryPicklistMap,'Sub Category','Sub Category',false);
    sub1b.inputs.add(T1S2C1); 
    //Comments end*/
              set<string> offCategorySet = new set<string>();
              if(offering.Id!=null){
                  List<PMP_Partner_Offering_Category__c> offeringCatList = new List<PMP_Partner_Offering_Category__c>();
                  system.debug('******offering.Id******'+offering.Id);
                  offeringCatList = [select id,PMP_Offering_Category_External_Key__c,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offering.Id AND PMP_Category_Id__r.PMP_Active_Ind__c=true]; 
                  system.debug('******offeringCatList******'+offeringCatList.size()); 
                  if(!offeringCatList.isEmpty()){
                      for(PMP_Partner_Offering_Category__c offCat : offeringCatList){
                          offCategorySet.add(offCat.PMP_Offering_Category_External_Key__c); 
                          system.debug('******offCat.PMP_Offering_Category_External_Key__c******'+offCat.PMP_Offering_Category_External_Key__c);
                      }
                  }
                  system.debug('******offCategorySet******'+offCategorySet); 
              }
              Intel_DropdownRadioCombo T1S1C9= PMP_Offering_UI_Generator.createCategoriesDropDownRadioCombo/*createDropdownCombo*/(categoryWrapper,offCategorySet);
              sub1a.inputs.add(T1S1C9);
              
              // Prakash - to Test new UI start
              sub1c = PMP_Offering_UI_Generator.createSubsection(System.Label.PMP_Marketing_Information);
              section1.subsections.add(sub1c);
              
              List<PMP_CategoryController.Core_PMP_OfferingCategory> industryWrapper = getOfferingCategorySubCategoryList(PMP_StaticConstants_Offering.INDUSTRY_ID,language,PMP_StaticConstants_Offering.industry);
              Intel_Checkbox T1S3C1= PMP_Offering_UI_Generator.createCategoryInfo(industryWrapper,System.Label.PMP_Industry,'industryValues',offCategorySet);
              sub1c.inputs.add(T1S3C1);
              
              List<PMP_CategoryController.Core_PMP_OfferingCategory> applicationWrapper = getOfferingCategorySubCategoryList(PMP_StaticConstants_Offering.APPLICAION_ID,language,PMP_StaticConstants_Offering.application);
              Intel_Checkbox T1S3C2= PMP_Offering_UI_Generator.createCategoryInfo(applicationWrapper,System.Label.PMP_application,'applicationValues',offCategorySet);
              sub1c.inputs.add(T1S3C2);
              //End
          }
          
          //-------------------Added by Manasa--------Start---------------Specs ---------
          //Variables Declaration
          
          Intel_Subsection geoSubSection = new Intel_Subsection();
          Intel_Subsection endCustomerSubSection = new Intel_Subsection();
          Intel_Subsection spikeUS = new Intel_Subsection(); //Added for Spike
          PMP_Specifications_Tab_Mapping__mdt  configMtd = new  PMP_Specifications_Tab_Mapping__mdt();                                               
          
          //Iterate on the sepecList which we get from MarketPlaceCreateProductController class                                                
          for(PMP_SpecificationController.Core_PMP_OfferingSpecs iterSpec : specList){
              //If specID is NPP_GeographicCoverage
              if(iterSpec.specId !=null && iterSpec.specId == PMP_StaticConstants_Offering.GEOREGION){
                  //Assign specID to Custom Metadata Variable
                  configMtd = stepConfigurationsMap.get(iterSpec.specId);
                  //Assign SubSection to geoSubSection 
                  geoSubSection = PMP_Offering_UI_Generator.getSpecificationSubsection(iterSpec,configMtd , offering,offSpecSet,specValDataMap,specValListMap);               
                  
              }
              //If specID is NPP_EndCustomerType
              else if (iterSpec.specId !=null && iterSpec.specId == PMP_StaticConstants_Offering.ENDCUSTOMERTYPE){
                  //Assign specID to Custom Metadata Variable
                  configMtd = stepConfigurationsMap.get(iterSpec.specId);
                  //Assign SubSection to endCstTypeSubSection
                  endCustomerSubSection = PMP_Offering_UI_Generator.getSpecificationSubsection(iterSpec,configMtd , offering,offSpecSet,specValDataMap,specValListMap);
              }
          
          }  
          //Add Geo Regions Sub section first to the Marketing Info section                                                   
          section1.subsections.add(geoSubSection);  
          //Then Add End Customer Type Sub section after Geo Regions Sub Section, to the Marketing Info section                                                      
          section1.subsections.add(endCustomerSubSection); 
          //---------------------Added by Manasa--------End---------------Specs------------  
        
          
          
          //returning the Step         
          return step1; 
      }   
    /** 
* @description : get company Info 
* @User's contact's account Name
* @return a Map<id,String> 
* Method Parameters - no parameters
*/
    public static Map<Id,String> getCompanyInfoOptions(){
        Map<Id,String> companyMap = new Map<Id,String>();
        User user;
        User user1;
        Contact con;
        String uId;   
        List<PMP_Company__c> companyInfoList = [Select id, Name, PMP_Account_Id__c, PMP_Account_Id__r.Core_CNDA_Number__c,
                                                PMP_Account_Address_Txt__c, PMP_Account_Dsc__c from PMP_Company__c 
                                                where PMP_Is_Published_Ind__c=true order by Name LIMIT 10000]; 
        
        uId = UserInfo.getUserId(); 
        
        user = [Select id,ContactId,Contact.AccountId,Contact.Account.Name from User where id=:uId];
        for(PMP_Company__c coInfo : companyInfoList){ 
            
            if(user !=null && user.Contact.AccountId !=null){
                if(user.Contact.Account.Name == coInfo.Name){   
                    companyMap.put(coInfo.Id,coInfo.Name);
                }   
            }                  
            else{                   
                companyMap.put(coInfo.Id,coInfo.Name);
            } 
        }
        return companyMap;
    }
    
    public static PMP_Company__c getCompanyInfoForAccount(Id accountId){
        return [SELECT id, Name, PMP_Account_Id__c from PMP_Company__c where 
          PMP_Is_Published_Ind__c=true and PMP_Account_Id__c=:accountId  LIMIT 1];
    }
    
    /*************************************************************************** 
* Method Name : isDuplicateOffering
* Description : Method to identify duplicate Offerings
*              -1 for duplicate offering within same partner company
*               0 for duplicate offering across the partner exchange
*               1 for non duplicte offering
******************************************************************************/
   /* public static integer isDuplicateOffering(string strOfferingName, string offeringId, string companyId)
    {
        system.debug('offeringId: ' + offeringId);
        system.debug('companyId: ' + companyId);
        system.debug('strOfferingName : '+ strOfferingName);
        
        Integer totalCount = [Select count() from PMP_Partner_Offering__c where PMP_Partner_Offering_Nm__c = :strOfferingName
                              and PMP_Working_Copy_Id__c = null and Id != :offeringId]; 
        system.debug('totalCount====>'+totalCount);
        if(totalCount > 0)
        {
            Integer companyCount = [Select count() from PMP_Partner_Offering__c where PMP_Partner_Offering_Nm__c = :strOfferingName
                                    and PMP_Working_Copy_Id__c = null and PMP_Company_Id__c = :companyId and Id != :offeringId];
            system.debug('companyCount====>'+companyCount);
            if(companyCount > 0){
                return -1;
            }
            else{
                return 0;
            }
            
        }
        else {
            return 1;
        }
    
        
    }*/
    
    public static List<PMP_CategoryController.Core_PMP_OfferingCategory> getOfferingCategorySubCategoryList(string mainCategory,string language, string categoryType){
        string selectedCategory = '%' + mainCategory + '%';
        List<PMP_Category__c> categoriesList;
        List <PMP_CategoryController.Core_PMP_OfferingCategory>  fileteredCategoryList = new List<PMP_CategoryController.Core_PMP_OfferingCategory>();
        Map<String,PMP_CategoryController.Core_PMP_OfferingCategory> categoryMap= new Map<String,PMP_CategoryController.Core_PMP_OfferingCategory>();
        
        categoriesList =[SELECT Id, Name, PMP_Parent_Category_Id__c,PMP_Partner_Product_Category_Cd__c, 
                         PMP_Partner_Product_Parent_Category_Cd__c,
                         PMP_Display_Type_Nm__c, PMP_Active_Ind__c, 
                         PMP_Parent_Category_Id__r.PMP_Partner_Product_Category_Cd__c,
                         PMP_Ancestor_Category_Cd__c, PMP_Ancestor_Category_Nm__c,
                         PMP_Business_Segment_Nm__c,
                         PMP_Category_Japanese_Nm__c, PMP_Category_Chinese_Nm__c, Type__c, PMP_ChildMandatory_Ind__c                                                        
                         FROM PMP_Category__c where PMP_Active_Ind__c=true and
                         PMP_Ancestor_Category_Cd__c LIKE: selectedCategory and
                         Type__c =: categoryType
                         order by PMP_Category_Display_Sequence_Nbr__c
                         
                        ];

        system.debug('*****categoriesList******'+categoriesList);
        
        String categoryNameInLocale;//to store category name as per the user locale
        Map<String, String> apiNameByLabel = PMP_Utility.getLocaleFields('Category',language);//calling getLocaleFields method of utility class to get api field names as per the user locale for Category object
        
        for(PMP_Category__c iterCategory : categoriesList){
            system.debug(iterCategory.name );
            /*fetch the locale category name from category object for the user locale using metadata field*/
            if(String.valueOf(iterCategory.get(apiNameByLabel.get('Name'))) != null && !apiNameByLabel.isEmpty()){
                categoryNameInLocale = String.valueOf(iterCategory.get(apiNameByLabel.get('Name')));
            }
            else{//if the translated value for the category is not available,store english value
                categoryNameInLocale = iterCategory.Name;
            }
            
            PMP_CategoryController.Core_PMP_OfferingCategory tempiterCategory=new PMP_CategoryController.Core_PMP_OfferingCategory(
                categoryNameInLocale, iterCategory.PMP_Partner_Product_Category_Cd__c, iterCategory.PMP_Partner_Product_Parent_Category_Cd__c, 
                iterCategory.PMP_Display_Type_Nm__c, iterCategory.PMP_Ancestor_Category_Cd__c, iterCategory.PMP_Ancestor_Category_Nm__c,
                iterCategory.PMP_Business_Segment_Nm__c,false,false,iterCategory.Id,null,iterCategory.PMP_ChildMandatory_Ind__c); 
            
          //  system.debug(tempiterCategory.categoryName);
            categoryMap.put(tempiterCategory.PIMCategoryId,tempiterCategory); 
            //selectedCategory ='%'+ iterCategory.PMP_Ancestor_Category_Cd__c + '%';
            
        }
        
        system.debug('*****categoryMap******'+categoryMap.keyset().size());
        
        
        
        
        
        
        if(!categoryMap.isEmpty()){
            for(String PIMCategoryId : categoryMap.keySet()){
                
                //get the parent of the current node and attach the current node to the parent node            
                PMP_CategoryController.Core_PMP_OfferingCategory tempChildOffering=categoryMap.get(PIMCategoryId);
                if(categoryMap.containsKey(tempChildOffering.PIMParentCategoryId)){
                    PMP_CategoryController.Core_PMP_OfferingCategory tempParentOffering=categoryMap.get(tempChildOffering.PIMParentCategoryId);
                    tempParentOffering.childOfferingCategory.add(tempChildOffering);
                    system.debug(tempChildOffering);                
                }
                
                //assign all parent nodes to list
                if(tempChildOffering.ancestorCategoryId.contains(mainCategory)){//ancestor category name changed to ancestor category Id
                    
                    fileteredCategoryList.add(tempChildOffering);
                    system.debug('*****fileteredCategoryList******'+fileteredCategoryList );
                    
                }
            }
        }   
        
      /*   for(PMP_CategoryController.Core_PMP_OfferingCategory iter : fileteredCategoryList){

            system.debug(iter.categoryName+ ' :' +iter.childOfferingCategory.size()  );
        
        } */
        
        return fileteredCategoryList; 
    }
    
    /*
     * Method added by raj to validate offering Data
     * @desription -> -1 for duplicate offering within same partner company
     *                 0 for duplicate offering across the partner exchange
     *                 1 for non duplicte offering
     *                -2 for Non ISA Offering
     * @param - formData containing the selected categories
     * @param - offering containing the input language
     * @Method Parameter - Intel_FormData
     * @Method Parameter - PMP_Partner_Offering__c
     * @return - Integer
     */
    public static Integer validateOfferingData(Intel_FormData formData){
    List<Intel_SpecificationDataWrapper> specList = new List<Intel_SpecificationDataWrapper>();
    set<id> categoryIdSet = new set<id>();
    List<PMP_Category__c> selectedCategories = new List<PMP_Category__c>();
    PMP_Partner_Offering__c offering = formData.offering;
    specList =  PMP_OfferingCategoryHelper.populateSpecificationDataWrapper(formData.categoryAndSubCategory,null,formData.industryAndApplication);//method call to get specList
    Integer status = 2;//setting status default as 2,which means partner can create Non ISA offering 
    
    if(offering.PMP_Offering_Language_Nm__c != 'English' && specList.size() > 0){//if the offering is Non-English,only then check whether it's ISA or Non-ISA && if selected caetgories are there add it to a set
            for(Intel_SpecificationDataWrapper spec : specList){
                categoryIdSet.add((id)spec.Id);//populating set with the selected category's Id
            }
        
        if(categoryIdSet.size() > 0){//if category Ids are there,fetch the corresponding category records
            selectedCategories = [Select id,PMP_Ancestor_Category_Cd__c, Name,Type__c, 
                                    PMP_Business_Segment_Nm__c from PMP_Category__c where id IN : categoryIdSet AND Type__c = 'Category'];
        }
        
        for(PMP_Category__c cat : selectedCategories){//iterate over the fetched records and check whether sub-category has IoT as Partner Segment
            if(cat.PMP_Ancestor_Category_Cd__c.countMatches('|') == 1 //it's a sub-category 
                && !cat.PMP_Business_Segment_Nm__c .contains('IoT')){ //it doesn't belong to IoT Partner Segment
                status = -2;
            }
        }
    }
    
    if(status == 2){//if Non-ISA creation for the partner is allowed then only check for the duplicate name check
            status = PMP_CheckIfDuplicateOffering.isDuplicateOffering(offering.PMP_Partner_Offering_Nm__c, offering.Id, offering.PMP_Company_Id__c);//method call to validate duplicate name     
    }
    
    return status;
        
    }
}