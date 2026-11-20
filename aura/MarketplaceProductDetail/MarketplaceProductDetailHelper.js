({   
    
    getOfferingDetails : function(component,helper) 
    {   
        var offeringId='';
        if(component.get('v.recordId')){
            offeringId = component.get('v.recordId');
        }
        else if (!component.get('v.recordId') && component.get('v.offeringId')){
            offeringId = component.get('v.offeringId');
        }
        
        var act = component.get("c.checkValidOffering");
        act.setParams({ "offeringId": offeringId, isPreview: component.get('v.previewMode') });
        act.setCallback(this, function(response) {
            
            if(response.getState() === "SUCCESS") {
                if(response.getReturnValue() === true) {                
        
        var language = helper.getJsonFromUrl().Lang; //US398772 fethcing langugae from Url
        //In preview mode, if language parameter is not present, then data should appear in base language
        
        if (!language && component.get('v.previewMode'))
        {
            language='NA';
        }
        
        // Ashish Changes for Enable Preview Page with read/write message (US583259)
        var showChat = helper.getJsonFromUrl().viewChat; 
        if(showChat) {
            component.set("v.displayChatSection",showChat);        
        }
        // Ashish Changes for for Enable Preview Page with read/write message (US583259)
              
        var userLangCode = $A.get("$Locale.langLocale"); // logged-In or Guest users language code (if changed via language selector) - Prabuddh(US452769)
        // Sandhya :US592842
        var isPreview = component.get('v.previewMode');
        
        
        var  urlString = window.location.href;
        var action = component.get("c.getOfferingDetail");
   
        console.log('Action Called' + offeringId);
        if(!isPreview){
            action.setStorable();
        }
        action.setParams({ "offeringId": offeringId,
                          "bEditOffering":false,
                          "bViewOffering":true,
                          "bCompareOffering":false,
                          "language":language,
                          langCode: userLangCode,
                          isPreview:isPreview
                         });
               
        //action.setStorable();
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var response = response.getReturnValue();
                
                response=JSON.parse(response);
                var product=new Object();                   
                
                //Gireesh:US758953:Set Event banner                 
                if(response!=undefined && response.objectData!=undefined && response.objectData.eventPartnerOffering!=undefined && response.objectData.eventPartnerOffering){
                    
                    component.set("v.showEventBanner", response.objectData.eventPartnerOffering);
                }
                //end
                if(response.objectData.mdaId){
                    component.set('v.mdaId',response.objectData.mdaId);
                }
                //Checking if the user is intel employee and offering is not public content
                if(response.objectData.isIntelEmployee && (response.objectData.OfferingDetail[0].PMP_Partner_Offering_Visibility_Nm__c!= 'Public Content')){
                    component.set('v.showDisclaimer',true); //If the above criteria satisfies, setting show disclaimer to true
                }
                
                if(response.objectData.showContactPartner){
                    component.set('v.showContactPartner', true);
                    
                }
                
                //if(response.objectData.partnerDetail!=undefined && response.objectData.partnerDetail && response.objectData.partnerDetail.length>0){
                if(response.objectData.partnerDetail && response.objectData.partnerDetail!=undefined){
                    product.partnerDetails=response.objectData.partnerDetail;
                    product.productCompanyResource = response.objectData.productCompanyResource.companyResources;
                    product.articleCompanyResource = response.objectData.articleCompanyResource.articleList;
                    product.viewAllLabel = response.objectData.articleCompanyResource.viewAllLabel;
                    var categoryLabel = response.objectData.OfferingDetail[0].PMP_Category_nm__c + '-' + response.objectData.OfferingDetail[0].PMP_Sub_Category_nm__c;
                    var  ContactproductData= {
                        contactByEmail: false,
                        contactByForm: true,
                        requestAQuote: false, 
                        id: product.partnerDetails.id,
                        autoPartnerId: product.partnerDetails.autoPartnerId,
                        oid: response.objectData.OfferingDetail[0].PMP_Offering_Id__c,
                        offRecId: response.objectData.OfferingDetail[0].Id,                       
                        name: product.partnerDetails.name,           
                        title: response.objectData.OfferingDetail[0].Name,
                        isGuest:response.objectData.OfferingDetail.isAnonymousUser,
                        categoryLabel : categoryLabel
                    };
                    
                }
                
                component.set("v.dataObj",ContactproductData);
                /*Added by raj to check whether user has access to edit and see notification messages for the offering*/
                if(response.objectData.showEditButton != undefined && response.objectData.isAnonymousUser != undefined){
                    var hasEditAccess = false;
                    var showNotification = false;
                    // var haspreviewText = true;
                    if(response.objectData.showEditButton && !response.objectData.isAnonymousUser){
                        hasEditAccess = true;
                        showNotification = true;
                        
                        if(response.objectData.OfferingDetail[0].PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Retired')
                        {
                            hasEditAccess = false;
                            component.set("v.ShowClone",true);
                        }
                        else
                        {
                            component.set("v.ShowClone",true);
                        }
                        
                        if(response.objectData.OfferingDetail[0].PMP_Is_Notified_Ind__c){
                            component.set('v.showDateChangeButton',true);
                        }
                        //  haspreviewText =false;
                        
                    }
                    
                    component.set("v.showEditOfferingButton",hasEditAccess);//setting the boolean for edit offering button
                    component.set("v.showViewNotification",showNotification);//setting the boolean for showNotification
                    // component.set("v.showChatSection",true);
                }
                
                
                //if langauge parameter is not present in url, we check for user locale in the apex controller and
                //send it as a parmeter. This is done as a part of change request.
                if(!language && response.objectData.userLocale && response.objectData.userLocale != 'NA'){
                    
                    language = response.objectData.userLocale;
                }
                //we set Language as NA on the offering name formula field so that we show base language 
                //values when user clicks on offering name from list view
                else if(language=='NA'){language=undefined}
                if(language){
                    component.set("v.offeringDisplayLang",language);
                    
                }
                
                //set params for new preview window 
                
                /*---------------------------------------End--------------------------------------------------------*/
                //get Offering detail
                //if(response.objectData.OfferingDetail!=undefined && response.objectData.OfferingDetail && response.objectData.OfferingDetail.length>0)
                if(response.objectData.OfferingDetail && response.objectData.OfferingDetail!=undefined && response.objectData.OfferingDetail.length!=undefined && response.objectData.OfferingDetail.length>0)
                {   
                    
                    product.offeringDetails=response.objectData.OfferingDetail[0];
                    //product.partnerDetails=response.objectData.partnerDetail;
                    var cnt;                                                   
                    
                    //Added by shahrukh : US396679 : Navigate to working copy if user opens published record
                    if(response.objectData.WorkingCopyId){
                        component.set("v.recordId",response.objectData.WorkingCopyId);
                    }
                    
                    component.set("v.editPageReference",{
                        //Moved by shahrukh from controller to helper as there is requirment to change record Id[4/07/2019]
                        type: "standard__namedPage",
                        
                        attributes: {
                            "pageName": "offering-edit"
                        },
                        state: {
                            "recordId": component.get('v.recordId'),
                            "Lang":language,
                            
                        }
                    });
                    window.localStorage.setItem('hideSave', false);
            		window.localStorage.setItem('hideSaveDesc', false);
            		window.localStorage.setItem('hideSaveCompany', false);
                    //End of code US396679
                    
                    //Added by Shahrukh US381631 : Disable buttons on admin review and approved
                    var isAdmin = response.objectData.isAdmin;
                    var today = new Date();  // Declaring todays date to check future date scenario
                    today = today.toISOString().slice(0,10);  //changing the date to required format
                    var startDate=null;
                    if(product.offeringDetails!=undefined && product.offeringDetails.PMP_Partner_Offering_Start_Dt__c!=undefined){
                        startDate = product.offeringDetails.PMP_Partner_Offering_Start_Dt__c; //storing from date in a variable
                    }
                    
                    
                    //checking the condition to disable edit offering button
                    //Gireesh:US762788
                    var isNotEnglish;
                    
                    if(product.offeringDetails.PMP_Translated_Languages__c && product.offeringDetails.PMP_Business_Segment_Nm__c){
                    	isNotEnglish=(!(product.offeringDetails.PMP_Translated_Languages__c).includes('English') && (product.offeringDetails.PMP_Business_Segment_Nm__c).includes('IoT') );
                    }
                    
                    if((isNotEnglish && isAdmin) ||( product.offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c==="Admin Review" || (product.offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c==="Approved" && startDate>today)) && !isAdmin){
                        component.set("v.disabled",true);
                    }
                    
                    
                    //Notification Banner Messages : US396638 - Added by Shahrukh 
                    if(!response.objectData.isAnonymousUser){ //Checking if logged in user is not anonymous
                        //Checking different status values and setting the messages respectively
                        var off = product.offeringDetails;
                        
                        if(product.offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c==="Draft"){
                            helper.notificationBannerMessages(component,helper,"redo",$A.get("$Label.c.PMP_DraftEditBannerMessage"));
                        }else if(product.offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c==="Rejected"){
                            helper.notificationBannerMessages(component,helper,"lock",$A.get("$Label.c.PMP_RejectedEditBannerMessage")) ;
                        }else if(product.offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c==="Published" ){
                            component.set("v.isPublished", true); //For Clone button visiblity                           
                            
                            helper.notificationBannerMessages(component,helper,"redo",$A.get("$Label.c.PMP_PublishedEditBannerMessage")) ;
                            
                            
                        }else if(off.PMP_Partner_Offering_Lifecycle_Status_Nm__c==="Approved"){
                            if(((startDate<=today) && off.PMP_Pre_Release_Item_Count_Num__c==0 && off.PMP_Pre_Release_Check_Nm__c==null) || (off.PMP_Pre_Release_Item_Count_Num__c==0 && off.PMP_Pre_Release_Check_Nm__c=='Yes' && (startDate<=today)) || (off.PMP_Pre_Release_Item_Count_Num__c==0 && off.PMP_Pre_Release_Check_Nm__c=='No' && !off.PMP_Is_Notified_Ind__c && (startDate<=today))){
                                component.set("v.isPublished", true); //For Clone button visiblity
                                helper.notificationBannerMessages(component,helper,"redo",$A.get("$Label.c.PMP_PublishedEditBannerMessage")) ;
                            }else if(off.PMP_Pre_Release_Item_Count_Num__c==0 && startDate>today && (off.PMP_Pre_Release_Check_Nm__c!='No' || (off.PMP_Pre_Release_Check_Nm__c=='No' && !off.PMP_Is_Notified_Ind__c))){
                                component.set("v.isPublished", true); //For Clone button visiblity 
                                var futureDateLabel = $A.get("$Label.c.PMP_ApprovedFutureDateEditBannerMessage").replace('{0}', startDate);
                                helper.notificationBannerMessages(component,helper,"lock",futureDateLabel) ;
                            }else{  //Scheduled to be published banner message when offering is approved but not published
                                component.set("v.isPublished", true);
                                helper.notificationBannerMessages(component,helper,"redo",$A.get("$Label.c.PMP_ScheduledToBePublishedEditBannerMessage")) ;
                            }
                        }else if(product.offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c==="Admin Review"){
                            helper.notificationBannerMessages(component,helper,"lock",$A.get("$Label.c.PMP_AdminReviewEditBannerMessage")) ;
                        }else if(product.offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c==="Update Required"){
                            helper.notificationBannerMessages(component,helper,"redo",$A.get("$Label.c.PMP_UpdateRequiredEditBannerMessage")) ;
                        }else if(product.offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c==="Retired"){
                            helper.notificationBannerMessages(component,helper,"lock",$A.get("$Label.c.PMP_RetiredOfferingBannerNotification")) ;
                        }
                    }
                    
                    //End of Code US396638
                    
                    product.productGallery=[];
                    if(response.objectData.contentWrapper)
                    {
                        /* var contentVersions = response.objectData.downloadURL;  // Getting Content version for gallery data
                        for (var idx=0; idx < contentVersions.length; idx++) 
                        {
                            //var ContentDownloadUrl = contentVersions[idx].ContentDownloadUrl.split("/servlet/");
                            //var newURL = "imp/servlet/" + ContentDownloadUrl[1];
                            product.productGallery.push({
                                thumbnailURL: contentVersions[idx].ContentDownloadUrl, 
                                imageURL: contentVersions[idx].ContentDownloadUrl,
                                //thumbnailURL: 'Test', //Added for POC content Asset
                                //imageURL: 'Test',
                                type:'Image',
                                imgAlt: $A.get("$Label.c.PMP_Gallery")  + idx
                            }); 
                            cnt = idx+1;
                        }    */
                        //Changes for Content Asset display on offering Detail 
                        var conAssets = response.objectData.contentWrapper;  // Getting Content Asset for gallery data
                        for (var idx=0; idx < conAssets.length; idx++) 
                        {
                            product.productGallery.push({
                                thumbnailURL: conAssets[idx].thumbnailUrl ?
                                conAssets[idx].thumbnailUrl+'?isOptimized=false': conAssets[idx].imageUrl+'?isOptimized=false', 
                                imageURL: conAssets[idx].imageUrl+'?isOptimized=false',
                                type:'Image',
                                imgAlt: $A.get("$Label.c.PMP_Gallery")  + idx
                            }); 
                            cnt = idx+1;
                        }   
                        component.set("v.count",cnt);
                    }  
                    
                }
                //get selected categories
                if(response.objectData.selectedCategories){
                    var category = response.objectData.selectedCategories; // Getting selected Categories - for Industries and Applications
                    
                    product.industriesApplications=[];
                    product.industriesApplications.industries=[];
                    product.industriesApplications.applications=[];
                    product.industriesApplications.availability_pricing=[];
                    product.technicalSpecifications = [];
                    var catValues ='';
                    var categoryTitle = '';
                    var categoryId = [];
                    var parentCategoryId = '';
                    var categoryById = new Map();
                    var categoryChildById = new Map();
                    var IndustryById = new Map();
                    var IndustryChildById = new Map();
                    var applicationById = new Map();
                    var applicationChildById = new Map();
                    for(var idx =0; idx<category.length;idx++){
                        if(category[idx].PMP_Ancestor_Category_Cd__c){
                            //Industries from selected categories,added by raj for US298826
                            if(category[idx].PMP_Ancestor_Category_Cd__c.includes($A.get("$Label.c.PMP_NPP_01_Industry"))){
                                var catList=[];//to store industry's child
                                //map<categoryId,categoryObject>,contains categoryId and it's object record
                                IndustryById.set(category[idx].PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,category[idx]);
                                //map<categoryId,List<categoryObject>>,contains the categoryId and list of child related to it(Default 0)
                                IndustryChildById.set(category[idx].PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,catList);
                            }
                            //Applications from selected categories,added by raj for US298826
                            else if (category[idx].PMP_Ancestor_Category_Cd__c.includes($A.get("$Label.c.PMP_NPP_01_APP"))){	
                                var catList=[];//to store application's child
                                //map<categoryId,categoryObject>,contains categoryId and it's object record 
                                applicationById.set(category[idx].PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,category[idx]);
                                //map<categoryId,List<categoryObject>>,contains categoryId and list of child related to it(Default 0)
                                applicationChildById.set(category[idx].PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,catList);                            
                            } 
                            //Category from selected categories - ON TECHINICAL SPECIFICATIONS SECTION
                                else if (category[idx].PMP_Ancestor_Category_Cd__c.includes($A.get("$Label.c.PMP_NPP_01_TYPE"))){
                                    var catList=[];//to store category's child
                                    //map<categoryId,categoryObject>,contains categoryId and it's object record
                                    categoryById.set(category[idx].PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,category[idx]);
                                    //map<categoryId,List<categoryObject>>,contains categoryId and list of child related to it(Default 0)
                                    categoryChildById.set(category[idx].PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,catList);
                                }
                            
                        }                                         
                    }
                    for(var cat of category){
                        if(cat.PMP_Ancestor_Category_Cd__c){
                            if(cat.PMP_Ancestor_Category_Cd__c.includes($A.get("$Label.c.PMP_NPP_01_Industry")) && IndustryChildById.has(cat.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c)){
                                IndustryChildById.get(cat.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c).push(cat);
                            }
                            else if(cat.PMP_Ancestor_Category_Cd__c.includes($A.get("$Label.c.PMP_NPP_01_APP")) && applicationChildById.has(cat.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c)){
                                applicationChildById.get(cat.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c).push(cat);
                            }
                                else if(cat.PMP_Ancestor_Category_Cd__c.includes($A.get("$Label.c.PMP_NPP_01_TYPE")) && categoryChildById.has(cat.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c)){
                                    categoryChildById.get(cat.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c).push(cat);
                                }
                        }
                    }
                    
                }
                
                //added by raj to get application from categories for US326443
                if(applicationChildById){
                    for(var app of applicationChildById.keys()){
                        var productCategories='';
                        if(applicationChildById.get(app).length==0){
                            //getting only the nodes which doesn't have any child 
                            var cat=applicationById.get(app);
                            var ancesCat=cat.PMP_Ancestor_Category_Cd__c.split('|');
                            if(ancesCat.length>1){
                                //appending all parent except for the ultimate parent
                                for(var ancesIdx=1;ancesIdx<ancesCat.length;ancesIdx++){
                                    var parent=applicationById.get(ancesCat[ancesIdx]);
                                    if(parent){
                                    	productCategories+=parent.Name+' : ';
                                    }
                                }
                            }
                            if(cat){
                            	productCategories = productCategories + cat.Name; 
                            }    
                        }
                        if(productCategories){
                            product.industriesApplications.applications.push({label: productCategories,
                                                                              link: '#'});
                        }
                    }
                }
                
                
                //added by raj to get industries from categories for US326443
                
                if(IndustryChildById){
                    for(var ind of IndustryChildById.keys()){
                        var productCategories='';
                        if(IndustryChildById.get(ind).length==0){
                            //getting only the child nodes which were selected 
                            var cat=IndustryById.get(ind);
                            var ancesCat=cat.PMP_Ancestor_Category_Cd__c.split('|');
                            if(ancesCat.length>1){
                                //appending all parent except for the ultimate parent
                                for(var ancesIdx=1;ancesIdx<ancesCat.length;ancesIdx++){
                                    var parent=IndustryById.get(ancesCat[ancesIdx]);
                                    if(parent){
                                        productCategories+=parent.Name+' : ';
                                    }
                                }
                            }
                            productCategories = productCategories + cat.Name;
                            
                        }
                        if(productCategories){
                            product.industriesApplications.industries.push({label: productCategories,
                                                                            link: '#'});
                        }
                    }
                }
                
                //Sandhya : Showing Categories in Seperate Links
                if(categoryChildById){
                    var categoryListItem = [];
                    for(var itr of categoryChildById.keys()){
                        
                        if(categoryChildById.get(itr).length == 0){
                            //getting only the child nodes which were selected 
                            var cat=categoryById.get(itr);  
                            
                            var ancesCat=cat.PMP_Ancestor_Category_Cd__c.split('|');
                            
                            if(ancesCat.length>1){
                                //appending all parent except for the ultimate parent
                                for(var ancesIdx=1;ancesIdx<ancesCat.length;ancesIdx++){
                                    
                                    var parent=categoryById.get(ancesCat[ancesIdx]);
                                    
                                    if(parent){
                                        if(parent.Name.includes(':')){
                                        	parent.Name = parent.Name;
                                        }else{
                                            parent.Name = parent.Name+' : ';
                                        }    
                                        categoryListItem.push(parent);
                                  
                                        catValues +=parent.Name+' : ';    
                                            
                                        
                                    }    
                                }  
                                
                                categoryListItem.push(cat);
                                
                                
                                	catValues = catValues + cat.Name;  
                                
                                
                            }
                            
                            categoryId = categoryListItem;//cat.PMP_Category_Id__r.Id;
                            
                            categoryTitle =$A.get("$Label.c.PMP_Category");
                            
                        } 
                    }
                    
                    
                }
                //get the all specifications from Server Response
                if(response.objectData.selectedSpecifications)
                {
                    var specifications = response.objectData.selectedSpecifications; //Getting Selected Specifications
                    /***********Initialising Variables************/
                    var spec = new Object();  
                    product.specification = [];
                    product.specification.data=[];
                    product.includedIntelTechnologies = [];
                    product.regions=[];              
                    var productCategories='';                   
                    product.SpecName = [];
                    var mandatorySpecSet = new Set();                  
                    var nonMandatorySpecSet = new Set();
                    var EndProducts=new Object();
                    var intelTech = new Set();
                    var dup = '';
                    var firstChipset = 'Y';
                    var processorTitle = '';
                    var processorDescription = '';
                    var fpgadescription = '';
                    var chipsetDescription = '';
                    var intelDescription = '';
                    var ances2 = '';
                    var processorDecMap = new Map();
                    var PimageURLNew = '';
                    var CimageURLNew = '';
                    var FimageURLNew = '';
                    var IimageURLNew = '';
                    var processorTechMap = new Map();
                    var chipsetTechMap = new Map();
                    var chipsetDecMap = {};
                    var fpgaTechMap = new Map();
                    var fpgaDecMap = {};
                    var intelTechMap = new Map();
                    var intelDecMap = {};
                    var processor  = new Object();
                    processor.description = '';
                    processor.imageurl = '';
                    var regionById = new Map();
                    var regionChildById = new Map();
                    var countriesBySubRegionId = new Map();//Added by raj as part of spike story
                    var countries = [];//Added by raj as part of spike story
                    var vpuDescription = '';
                    var vpuTechMap = new Map();
                    var vpuDecMap  = new Map();
                    var VimageURLNew = '';
                    
                    //Variables added by Deepanshu for optimized code
                    var nucDescription = '';
                    var nucObjectMapByName = new Map();
                    var nucDescMap = new Map();
                    var NimageURLNew = '';
                    
                    var chipsetDescription = '';
                    var chipsetObjectMapByName = new Map();
                    var chipsetDescMap = new Map();
                    var CimageURLNew = '';
                    
                    var fpgaDescription = '';
                    var fpgaObjectMapByName = new Map();
                    var fpgaDescMap = new Map();
                    var FimageURLNew = '';
                    
                    var processorDescription = '';
                    var processorObjectMapByName = new Map();
                    var processorDescMap = new Map();
                    var PimageURLNew = '';
                    
                    var intelTechDescription = '';
                    var intelTechObjectMapByName = new Map();
                    var intelTechDescMap = new Map();
                    var IimageURLNew = '';
                    
                    var pacDescription = '';
                    var pacObjectMapByName = new Map();
                    var pacDescMap = new Map();
                    var pacImageURLNew = '';
                    
                    
                    for(var idx =0; idx<specifications.length;idx++)
                    {
                        /*Added By Raj for displaying region and subregion on details page US439862*/
                        if(specifications[idx].PMP_Ancestor_Specification_Cd__c != undefined && specifications[idx].PMP_Ancestor_Specification_Cd__c.includes($A.get("$Label.c.PMP_NPP_GeographicCoverage"))){
                            var subRegions = [];//to store sub regions
                            //storing the region records by product specification Id
                            regionById.set(specifications[idx].PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,specifications[idx]);
                            //setting child list of the region to empty(default 0)
                            //commented as no longer required
                            regionChildById.set(specifications[idx].PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,subRegions);
                            //storing the selected countries in seperate map(added by raj as part of spike)
                            if(specifications[idx].PMP_Specification_Value_Cd__c != undefined){
                                countries.push(specifications[idx]);
                                countriesBySubRegionId.set(specifications[idx].PMP_Product_Specification_Cd__c, specifications[idx]);
                            }
                        }
                        /*--------------------------------End-------------------------------------*/
                        //Availability and Pricing from selected specification,added by raj for US298826
                        if(specifications[idx].PMP_Ancestor_Specification_Cd__c===$A.get("$Label.c.PMP_AvailabilityandPricingLevel1"))
                        {	
                            if(specifications[idx].PMP_Product_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_AvailabilityAndPricing_CPP")){
                                productCategories=specifications[idx].PMP_Specification_Nm__c+' : '+ $A.get("$Label.c.PMP_Yes");
                            }else{
                                productCategories=specifications[idx].PMP_Specification_Nm__c+' : '+specifications[idx].PMP_Specification_Value_Cd__c;
                            }
                            product.industriesApplications.availability_pricing.push({
                                label:productCategories,
                                link:'#'});
                        }
                        /* User Story: 	US611446
                         * Added by:    Deepanshu - ONYX 
                         * Description: The purpose for this code is to display Processors as a part of Included Intel Technologies through new optimized code.
                         */
                        //Checking the parent by using a method to fetch the custom labels 
                        if (specifications[idx].PMP_Ancestor_Specification_Cd__c != undefined && specifications[idx].PMP_Ancestor_Specification_Cd__c.includes($A.get("$Label.c.PMP_NPP_Processors")) && specifications[idx].PMP_Specification_Id__r.PMP_Specification_Type_Nm__c == 'Processor')
                        {
                            //Variables for internal use
                            var isSpecNotPresent = false;
                            var isSpecPresent = false;
                            var isOnlySpec = false;
                            var specsList = [];
                            
                            //Enter only if specification value is selected
                            if(specifications[idx].PMP_Specification_Value_Cd__c != undefined)
                            {
                                //If the Spec Tech Map doesn't have specification Name - from hereon referred to as "isSpecNotPresent"
                                if(!processorObjectMapByName.has(specifications[idx].Name)){
                                    //Setting isSpecNotPresent boolean as true for further processing in method
                                    isSpecNotPresent = true;
                                    //Calling Generic method and getting all details
                                    var recData = this.createSpecInstance(specifications[idx], processorDescription, PimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                    if(recData.specDescObject != undefined){
                                        processorObjectMapByName.set(specifications[idx].Name,recData.specTechObject);
                                        specsList.push(recData.specDescObject);
                                        processorDescMap.set(specifications[idx].Name,specsList);
                                    }
                                    processorDescription = recData.specDescription;
                                    PimageURLNew = recData.specImageUrlNew;
                                }
                                
                                //If Spec Tech map has specification name
                                else{
                                    //Setting Condition2 boolean as true for further processing in method
                                    isSpecPresent = true;
                                    //Calling Generic method and getting all details
                                    var recData = this.createSpecInstance(specifications[idx], processorDescription, PimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                    if(recData.specDescObject != undefined){
                                        processorObjectMapByName.set(recData.specTechName,recData.specTechObject); 
                                        var temp = [];
                                        if((processorDescMap.get(specifications[idx].Name) != undefined)){
                                            temp = processorDescMap.get(specifications[idx].Name);  
                                        }
                                        temp.push(recData.specDescObject);
                                        processorDescMap.set(specifications[idx].Name,temp);
                                    }
                                    processorDescription = recData.specDescription;
                                    PimageURLNew = recData.specImageUrlNew;
                                }		
                            }	
                            
                            //If Spec values are not present - Create only Spec Object and populate with spec data 
                            else{
                                //Setting isOnlySpec boolean as true for further processing in method
                                isOnlySpec = true;
                                //Calling Generic method and getting all details	
                                var recData = this.createSpecInstance(specifications[idx], processorDescription, PimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                processorObjectMapByName.set(specifications[idx].Name,recData.specTechObject);
                                processorDescription = recData.specDescription;
                                PimageURLNew = recData.specImageUrlNew;
                                if(specifications[idx].PMP_Specification_Id__r){
                                    processorObjectMapByName.delete(specifications[idx].PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name);
                                }
                            }
                        }
                        
                        /* User Story: 	US600114
                         * Added by:    Deepanshu - ONYX 
                         * Description: The purpose for this code is to display Chipset as a part of Included Intel Technologies through new optimized code.
                         */
                        //Checking the parent by using a method to fetch the custom labels 
                        else if (specifications[idx].PMP_Ancestor_Specification_Cd__c != undefined && specifications[idx].PMP_Ancestor_Specification_Cd__c.includes($A.get("$Label.c.PMP_NPP_Chipsets")))
                        {
                            //Variables for internal use
                            var isSpecNotPresent = false;
                            var isSpecPresent = false;
                            var isOnlySpec = false;
                            var specsList = [];
                            
                            //Enter only if specification value is selected
                            if(specifications[idx].PMP_Specification_Value_Cd__c != undefined)
                            {
                                //If the Spec Tech Map doesn't have specification Name - from hereon referred to as "isSpecNotPresent"
                                if(!chipsetObjectMapByName.has(specifications[idx].Name)){
                                    //Setting isSpecNotPresent boolean as true for further processing in method
                                    isSpecNotPresent = true;
                                    //Calling Generic method and getting all details
                                    var recData = this.createSpecInstance(specifications[idx], chipsetDescription, CimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                    if(recData.specDescObject != undefined){
                                        chipsetObjectMapByName.set(specifications[idx].Name,recData.specTechObject);
                                        specsList.push(recData.specDescObject);
                                        chipsetDescMap.set(specifications[idx].Name,specsList);
                                    }
                                    chipsetDescription = recData.specDescription;
                                    CimageURLNew = recData.specImageUrlNew;
                                }
                                
                                //If Spec Tech map has specification name
                                else{
                                    //Setting Condition2 boolean as true for further processing in method
                                    isSpecPresent = true;
                                    //Calling Generic method and getting all details
                                    var recData = this.createSpecInstance(specifications[idx], chipsetDescription, CimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                    if(recData.specDescObject != undefined){
                                        chipsetObjectMapByName.set(recData.specTechName,recData.specTechObject); 
                                        var temp = [];
                                        if((chipsetDescMap.get(specifications[idx].Name) != undefined)){
                                            temp = chipsetDescMap.get(specifications[idx].Name);  
                                        }
                                        temp.push(recData.specDescObject);
                                        chipsetDescMap.set(specifications[idx].Name,temp);
                                    }
                                    chipsetDescription = recData.specDescription;
                                    CimageURLNew = recData.specImageUrlNew;
                                }		
                            }	
                            
                            //If Spec values are not present - Create only Spec Object and populate with spec data 
                            else{
                                //Setting isOnlySpec boolean as true for further processing in method
                                isOnlySpec = true;
                                //Calling Generic method and getting all details	
                                var recData = this.createSpecInstance(specifications[idx], chipsetDescription, CimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                chipsetObjectMapByName.set(specifications[idx].Name,recData.specTechObject);
                                chipsetDescription = recData.specDescription;
                                CimageURLNew = recData.specImageUrlNew;
                                if(specifications[idx].PMP_Specification_Id__r){
                                    chipsetObjectMapByName.delete(specifications[idx].PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name);
                                }
                            }
                        }
                        
                        /* User Story: 	US600114
                             * Added by:    Deepanshu - ONYX 
                             * Description: The purpose for this code is to display FPGA as a part of Included Intel Technologies through new optimized code.
                             */
                        //Checking the parent by using a method to fetch the custom labels 
                            else if (specifications[idx].PMP_Ancestor_Specification_Cd__c != undefined && specifications[idx].PMP_Ancestor_Specification_Cd__c.includes($A.get("$Label.c.PMP_NPP_FPGA")))
                            {
                                //Variables for internal use
                                var isSpecNotPresent = false;
                                var isSpecPresent = false;
                                var isOnlySpec = false;
                                var specsList = [];
                                
                                //Enter only if specification value is selected
                                if(specifications[idx].PMP_Specification_Value_Cd__c != undefined)
                                {
                                    //If the Spec Tech Map doesn't have specification Name - from hereon referred to as "isSpecNotPresent"
                                    if(!fpgaObjectMapByName.has(specifications[idx].Name)){
                                        //Setting isSpecNotPresent boolean as true for further processing in method
                                        isSpecNotPresent = true;
                                        //Calling Generic method and getting all details
                                        var recData = this.createSpecInstance(specifications[idx], fpgaDescription, FimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                        if(recData.specDescObject != undefined){
                                            fpgaObjectMapByName.set(specifications[idx].Name,recData.specTechObject);
                                            specsList.push(recData.specDescObject);
                                            fpgaDescMap.set(specifications[idx].Name,specsList);
                                        }
                                        fpgaDescription = recData.specDescription;
                                        FimageURLNew = recData.specImageUrlNew;
                                    }
                                    
                                    //If Spec Tech map has specification name
                                    else{
                                        //Setting Condition2 boolean as true for further processing in method
                                        isSpecPresent = true;
                                        //Calling Generic method and getting all details
                                        var recData = this.createSpecInstance(specifications[idx], fpgaDescription, FimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                        if(recData.specDescObject != undefined){
                                            fpgaObjectMapByName.set(recData.specTechName,recData.specTechObject); 
                                            var temp = [];
                                            if((fpgaDescMap.get(specifications[idx].Name) != undefined)){
                                                temp = fpgaDescMap.get(specifications[idx].Name);  
                                            }
                                            temp.push(recData.specDescObject);
                                            fpgaDescMap.set(specifications[idx].Name,temp);
                                        }
                                        fpgaDescription = recData.specDescription;
                                        FimageURLNew = recData.specImageUrlNew;
                                    }		
                                }	
                                
                                //If Spec values are not present - Create only Spec Object and populate with spec data 
                                else{
                                    //Setting isOnlySpec boolean as true for further processing in method
                                    isOnlySpec = true;
                                    //Calling Generic method and getting all details	
                                    var recData = this.createSpecInstance(specifications[idx], fpgaDescription, FimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                    fpgaObjectMapByName.set(specifications[idx].Name,recData.specTechObject);
                                    fpgaDescription = recData.specDescription;
                                    FimageURLNew = recData.specImageUrlNew;
                                    if(specifications[idx].PMP_Specification_Id__r){
                                        fpgaObjectMapByName.delete(specifications[idx].PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name);
                                    }
                                }
                            }
                        
                        /* User Story: 	
         * Added by:    Deepanshu - ONYX 
         * Description: The purpose for this code is to display NUC as a part of Included Intel Technologies through new optimized code.
         */
                        //Checking the parent by using a method to fetch the custom labels 
                                else if (specifications[idx].PMP_Ancestor_Specification_Cd__c != undefined && specifications[idx].PMP_Ancestor_Specification_Cd__c.includes($A.get("$Label.c.PMP_NPP_NUC")))
                                {
                                    //Variables for internal use
                                    var isSpecNotPresent = false;
                                    var isSpecPresent = false;
                                    var isOnlySpec = false;
                                    var specsList = [];
                                    
                                    //Enter only if specification value is selected
                                    if(specifications[idx].PMP_Specification_Value_Cd__c != undefined)
                                    {
                                        //If the Spec Tech Map doesn't have specification Name - from hereon referred to as "Condition 1"
                                        if(!nucObjectMapByName.has(specifications[idx].Name)){
                                            //Setting Condition2 boolean as true for further processing in method
                                            isSpecNotPresent = true;
                                            //Calling Generic method and getting all details
                                            var recData = this.createSpecInstance(specifications[idx], nucDescription, NimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                            if(recData.specDescObject != undefined){
                                                nucObjectMapByName.set(specifications[idx].Name,recData.specTechObject);
                                                specsList.push(recData.specDescObject);
                                                nucDescMap.set(specifications[idx].Name,specsList);
                                            }
                                            nucDescription = recData.specDescription;
                                            NimageURLNew = recData.specImageUrlNew;
                                        }
                                        
                                        //If Spec Tech map has specification name
                                        else{
                                            //Setting Condition2 boolean as true for further processing in method
                                            isSpecPresent = true;
                                            //Calling Generic method and getting all details
                                            var recData = this.createSpecInstance(specifications[idx], nucDescription, NimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                            if(recData.specDescObject != undefined){
                                                nucObjectMapByName.set(recData.specTechName,recData.specTechObject); 
                                                var temp = [];
                                                if((nucDescMap.get(specifications[idx].Name) != undefined)){
                                                    temp = nucDescMap.get(specifications[idx].Name);  
                                                }
                                                temp.push(recData.specDescObject);
                                                nucDescMap.set(specifications[idx].Name,temp);
                                            }
                                            nucDescription = recData.specDescription;
                                            NimageURLNew = recData.specImageUrlNew;
                                        }		
                                    }	
                                    
                                    //If Spec values are not present - Create only Spec Object and populate with spec data 
                                    else{
                                        //Setting isOnlySpec boolean as true for further processing in method
                                        isOnlySpec = true;
                                        //Calling Generic method and getting all details	
                                        var recData = this.createSpecInstance(specifications[idx], nucDescription, NimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                        nucObjectMapByName.set(specifications[idx].Name,recData.specTechObject);
                                        nucDescription = recData.specDescription;
                                        NimageURLNew = recData.specImageUrlNew;
                                        if(specifications[idx].PMP_Specification_Id__r){
                                            nucObjectMapByName.delete(specifications[idx].PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name);
                                        }
                                    }
                                }            
                        
                        /* User Story: 	US849478
                         * Added by:    Deepanshu - ONYX 
                         * Description: The purpose for this code is to display PAC FPGA as a part of Included Intel Technologies.
                         */
                        //Checking the parent by using a method to fetch the custom labels 
                        else if (specifications[idx].PMP_Ancestor_Specification_Cd__c != undefined && specifications[idx].PMP_Ancestor_Specification_Cd__c.includes($A.get("$Label.c.PMP_NPP_Intel_FPGA_Platforms")))
                        {
                            //Variables for internal use
                            var isSpecNotPresent = false;
                            var isSpecPresent = false;
                            var isOnlySpec = false;
                            var specsList = [];
                            
                            //Enter only if specification value is selected
                            if(specifications[idx].PMP_Specification_Value_Cd__c != undefined)
                            {
                                //If the Spec Tech Map doesn't have specification Name - from hereon referred to as "isSpecNotPresent"
                                if(!pacObjectMapByName.has(specifications[idx].Name)){
                                    //Setting isSpecNotPresent boolean as true for further processing in method
                                    isSpecNotPresent = true;
                                    //Calling Generic method and getting all details
                                    var recData = this.createSpecInstance(specifications[idx], pacDescription, pacImageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                    if(recData.specDescObject != undefined){
                                        pacObjectMapByName.set(specifications[idx].Name,recData.specTechObject);
                                        specsList.push(recData.specDescObject);
                                        pacDescMap.set(specifications[idx].Name,specsList);
                                    }
                                    pacDescription = recData.specDescription;
                                    pacImageURLNew = recData.specImageUrlNew;
                                }
                                
                                //If Spec Tech map has specification name
                                else{
                                    //Setting Condition2 boolean as true for further processing in method
                                    isSpecPresent = true;
                                    //Calling Generic method and getting all details
                                    var recData = this.createSpecInstance(specifications[idx], pacDescription , pacImageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                    if(recData.specDescObject != undefined){
                                        pacObjectMapByName.set(recData.specTechName,recData.specTechObject); 
                                        var temp = [];
                                        if((pacDescMap.get(specifications[idx].Name) != undefined)){
                                            temp = pacDescMap.get(specifications[idx].Name);  
                                        }
                                        temp.push(recData.specDescObject);
                                        pacDescMap.set(specifications[idx].Name,temp);pacDescription
                                    }
                                    pacDescription = recData.specDescription;
                                    pacImageURLNew = recData.specImageUrlNew;
                                }		
                            }	
                            
                            //If Spec values are not present - Create only Spec Object and populate with spec data 
                            else{
                                //Setting isOnlySpec boolean as true for further processing in method
                                isOnlySpec = true;
                                //Calling Generic method and getting all details	
                                var recData = this.createSpecInstance(specifications[idx], pacDescription, pacImageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                pacObjectMapByName.set(specifications[idx].Name,recData.specTechObject);
                                pacDescription = recData.specDescription;
                                pacImageURLNew = recData.specImageUrlNew;
                                if(specifications[idx].PMP_Specification_Id__r){
                                    pacObjectMapByName.delete(specifications[idx].PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name);
                                }
                            }
                        }
                        
                        /* User Story:  US611446
          * Added by:    Deepanshu - ONYX 
          * Description: The purpose for this code is to display Intel Technologies as a part of Included Intel Technologies through new optimized code.
          */
                        //Checking the parent by using a method to fetch the custom labels 
                                    else if(specifications[idx].PMP_Ancestor_Specification_Cd__c != undefined && specifications[idx].PMP_Ancestor_Specification_Cd__c.includes($A.get("$Label.c.PMP_NPP_IntelTechnologies")))
                                    {
                                        //Variables for internal use
                                        var isSpecNotPresent = false;
                                        var isSpecPresent = false;
                                        var isOnlySpec = false;
                                        var specsList = [];
                                        
                                        //Enter only if specification value is selected
                                        if(specifications[idx].PMP_Specification_Value_Cd__c != undefined)
                                        {
                                            //If the Spec Tech Map doesn't have specification Name - from hereon referred to as "isSpecNotPresent"
                                            if(!intelTechObjectMapByName.has(specifications[idx].Name)){
                                                //Setting isSpecNotPresent boolean as true for further processing in method
                                                isSpecNotPresent = true;
                                                //Calling Generic method and getting all details
                                                var recData = this.createSpecInstance(specifications[idx], intelTechDescription, IimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                                if(recData.specDescObject != undefined){
                                                    intelTechObjectMapByName.set(specifications[idx].Name,recData.specTechObject);
                                                    specsList.push(recData.specDescObject);
                                                    intelTechDescMap.set(specifications[idx].Name,specsList);
                                                }
                                                intelTechDescription = recData.specDescription;
                                                IimageURLNew = recData.specImageUrlNew;
                                            }
                                            
                                            //If Spec Tech map has specification name
                                            else{
                                                //Setting Condition2 boolean as true for further processing in method
                                                isSpecPresent = true;
                                                //Calling Generic method and getting all details
                                                var recData = this.createSpecInstance(specifications[idx], intelTechDescription, IimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                                if(recData.specDescObject != undefined){
                                                    intelTechObjectMapByName.set(recData.specTechName,recData.specTechObject); 
                                                    var temp = [];
                                                    if((intelTechDescMap.get(specifications[idx].Name) != undefined)){
                                                        temp = intelTechDescMap.get(specifications[idx].Name);  
                                                    }
                                                    temp.push(recData.specDescObject);
                                                    intelTechDescMap.set(specifications[idx].Name,temp);
                                                }
                                                intelTechDescription = recData.specDescription;
                                                IimageURLNew = recData.specImageUrlNew;
                                            }		
                                        }	
                                        
                                        //If Spec values are not present - Create only Spec Object and populate with spec data 
                                        else{
                                            //Setting isOnlySpec boolean as true for further processing in method
                                            isOnlySpec = true;
                                            //Calling Generic method and getting all details	
                                            var recData = this.createSpecInstance(specifications[idx], intelTechDescription, IimageURLNew, isSpecNotPresent, isSpecPresent, isOnlySpec);
                                            intelTechObjectMapByName.set(specifications[idx].Name,recData.specTechObject);
                                            intelTechDescription = recData.specDescription;
                                            IimageURLNew = recData.specImageUrlNew;
                                            if(specifications[idx].PMP_Specification_Id__r){
                                                intelTechObjectMapByName.delete(specifications[idx].PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name);
                                            }
                                        }
                                    }              
                    }	
                    
                    if(processorObjectMapByName){
                        for(var specTitle of processorObjectMapByName.keys())
                        {
                            var description =[];
                            if(processorDescMap){
                                description = processorDescMap.get(specTitle);
                            }
                            product.includedIntelTechnologies.push
                            ({
                                specTitle:specTitle,
                                specTitleUrl:processorObjectMapByName.get(specTitle).productUrl, 
                                specValues:description, 
                                specImageUrl:processorObjectMapByName.get(specTitle).imageUrl                               
                            });
                        }
                    } 
                    
                    if(chipsetObjectMapByName){
                        for(var specTitle of chipsetObjectMapByName.keys())
                        {
                            var description =[];
                            if(chipsetDescMap){
                                description = chipsetDescMap.get(specTitle);
                            }
                            product.includedIntelTechnologies.push
                            ({
                                specTitle:specTitle,
                                specTitleUrl:chipsetObjectMapByName.get(specTitle).productUrl, 
                                specValues:description, 
                                specImageUrl:chipsetObjectMapByName.get(specTitle).imageUrl                               
                            });
                        }
                    }
                    
                    if(pacObjectMapByName){
                        for(var specTitle of pacObjectMapByName.keys())
                        {
                            var description =[];
                            if(pacDescMap){
                                description = pacDescMap.get(specTitle);
                            }
                            product.includedIntelTechnologies.push
                            ({
                                specTitle:specTitle,
                                specTitleUrl:pacObjectMapByName.get(specTitle).productUrl, 
                                specValues:description, 
                                specImageUrl:pacObjectMapByName.get(specTitle).imageUrl                               
                            });
                        }
                    }
                    
                    if(fpgaObjectMapByName){
                        for(var specTitle of fpgaObjectMapByName.keys())
                        {
                            var description =[];
                            if(fpgaDescMap){
                                description = fpgaDescMap.get(specTitle);
                            }
                            product.includedIntelTechnologies.push
                            ({
                                specTitle:specTitle,
                                specTitleUrl:fpgaObjectMapByName.get(specTitle).productUrl, 
                                specValues:description, 
                                specImageUrl:fpgaObjectMapByName.get(specTitle).imageUrl                               
                            });
                        }
                    }
                    
                    if(nucObjectMapByName){
                        for(var specTitle of nucObjectMapByName.keys())
                        {
                            var description =[];
                            if(nucDescMap){
                                description = nucDescMap.get(specTitle);
                            }
                            product.includedIntelTechnologies.push
                            ({
                                
                                specTitle:specTitle,
                                specTitleUrl:nucObjectMapByName.get(specTitle).productUrl, 
                                specValues:description, 
                                specImageUrl:nucObjectMapByName.get(specTitle).imageUrl                               
                            });
                        }
                    }
                    
                    if(intelTechObjectMapByName){
                        for(var specTitle of intelTechObjectMapByName.keys())
                        {
                            var description =[];
                            if(intelTechDescMap){
                                description = intelTechDescMap.get(specTitle);
                            }
                            product.includedIntelTechnologies.push
                            ({
                                specTitle:specTitle,
                                specTitleUrl:intelTechObjectMapByName.get(specTitle).productUrl, 
                                specValues:description, 
                                specImageUrl:intelTechObjectMapByName.get(specTitle).imageUrl                               
                            });
                        }
                    }
                    
                    for(var region of regionById.values()){
                        /*if parent of current region is present in the map,push it to the child list*/
                        if(regionChildById.has(region.PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c)){
                            regionChildById.get(region.PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c).push(region); 
                        }
                    }       
                }                     
                
                /*Added By Raj for displaying region and subregion on details page US439862*/
                if(regionChildById){//if region child map is not empty or null
                    for(var regionId of regionChildById.keys()){//iterating over region child map
                        var regionValues = '';
                        if(regionChildById.get(regionId).length == 0){//fetch only those regions which are at leaf node(based on selection)
                            var region = regionById.get(regionId);//fetch the region record from regionById map
                            var ancesCat=region.PMP_Ancestor_Specification_Cd__c.split('|');
                            if(ancesCat.length > 1){//if the region have parent then append parent with ':'
                                for(var ancesIdx=1;ancesIdx<ancesCat.length;ancesIdx++){//iterate over all it's parent and append them
                                    var parent=regionById.get(ancesCat[ancesIdx]);//fetch the parent record from the regionById map
                                    if(parent){//if the parent record is there append the name
                                        regionValues +=parent.Name+' : '; 
                                    }    
                                }                    
                            }
                            regionValues = regionValues + region.Name;//append the region's name 
                        }
                        if(regionValues){//if region values are present,push them to the regions list
                            product.regions.push({value: regionValues});
                        }
                    }
                }
                //commented,will be removed when implemmetation is done
                if(countries){//if countries are selected,iterate over all the countries and append region and sub-region with it
                    for(var country of countries){//iterating over all the selected countries
                        var regionValues = '';
                        var ancesCat = country.PMP_Ancestor_Specification_Cd__c.split('|');//splitting the ancestor to get all the parents
                        if(ancesCat.length > 1){
                            for(var ancesIdx=1; ancesIdx<ancesCat.length; ancesIdx++){
                                var parent=regionById.get(ancesCat[ancesIdx]);//fetch the parent record from the regionById map
                                if(parent){//if the parent record is there append the name
                                    regionValues +=parent.Name+' : '; 
                                }
                            }
                        }
                        //appending region + sub-region + country
                        regionValues = regionValues + country.PMP_Specification_Nm__c + ' : ' + country.PMP_Specification_Value_Cd__c; 
                        if(regionValues){//if region value is not empty, push it to the product regions list
                            product.regions.push({value: regionValues});	
                        }
                    }  
                }
                /*----------------------------------------------------------End----------------------------------------------------------------*/
                //New Resources changes
              if(response.objectData.offeringResources)
              {
                  var offeringResources = response.objectData.offeringResources;
                  product.resources = [];
      
                  for(var idx =0; idx<offeringResources.length;idx++){
                      product.resources.push
                          ({
                              linkUrl : offeringResources[idx].url,
                              title : offeringResources[idx].title, 
                              type : offeringResources[idx].resourceType,
                              description : offeringResources[idx].description,
                              fileSize : offeringResources[idx].fileSize,
                              fileType : offeringResources[idx].fileType,
                              downloadUrl : offeringResources[idx].downloadUrl
                          });               
                  }                                   
              }
                /*if(response.objectData.selectedSpecificationsMap)
                {
                    product.selectedSpecificationsMap = response.objectData.selectedSpecificationsMap;
                    console.log('!!!!Selected specifications map ',response.objectData.selectedSpecificationsMap);
               
                    var tempList = [];
                    tempList.push(catValues);
                   	
                    if(tempList !=''){
                        product.selectedSpecificationsMap.unshift({
                            masterCategory: categoryTitle, 
                            valueList: tempList,
                            category: categoryId}) ; 
                    }
                    console.log('!!!!Product selected specification ',product.selectedSpecificationsMap);
                    catValues = '';         
                    
                    
                     
                    
                }*/
                if(response.objectData.selectedSpecificationsMap)
                {
                    product.selectedSpecificationsMap = response.objectData.selectedSpecificationsMap;
                    var tempListForMetrics = response.objectData.selectedSpecificationsMap;
                    
                    product.selectedQualityMetricsMap = [];
                    
                    var tempList = [];
                    tempList.push(catValues);
                    
                    var qualityMetric = [];
                    
                    for(var i=0; i<tempListForMetrics.length; i++){
                        if((tempListForMetrics[i].masterCategory.includes($A.get("$Label.c.PMP_BoardQualityMetricPIMId"))) || (tempListForMetrics[i].masterCategory.includes($A.get("$Label.c.PMP_IPQualityMetricPIMId")))){
                            tempListForMetrics[i].valueList.forEach(function(item, array) {
                                if(item.split(':')[1] != undefined && (item.split(':')[1].includes($A.get("$Label.c.PMP_Yes")))){
                                    qualityMetric.unshift({
                                        key: item.split(':')[0],
                                        value: item.split(':')[1], 
                                        isYes: true
                                    })
                                }else if(item.split(':')[1] == undefined){
                                    qualityMetric.unshift({
                                        key: item.split(':')[0],
                                        value: $A.get("$Label.c.PMP_Yes"), 
                                        isYes: true
                                    })
                                }else{
                                    qualityMetric.unshift({
                                        key: item.split(':')[0],
                                        value: item.split(':')[1],
                                        isYes: false
                                    })
                                }
                                
                            })
                            
                            if(qualityMetric.length != 0){
                                product.selectedQualityMetricsMap.unshift({
                                    masterCategory: tempListForMetrics[i].masterCategory.split("|")[0],
                                    keyList: qualityMetric}) 
                            }
                       
                            //valueList: valueListQualityMetricsMap
                            //valueList: tempListForMetrics[i].valueList
                        }
                    }
                    
                    if(tempList !=''){
                        product.selectedSpecificationsMap.unshift({
                            masterCategory: categoryTitle, 
                            valueList: tempList,
                            category: categoryId}) ; 
                    }
                    catValues = '';   
                }
                
                // console.log('product desc:'+ product.offeringDetails.PMP_Partner_Offering_Dsc__c);
                //removing <p> and </p>
                /*Outer If Added by raj to avoid error when description is null*/
                //Gireesh
                //console.log('Description in console--',product);
                if(product && product.offeringDetails!=undefined && product.offeringDetails.PMP_Partner_Offering_Dsc__c!=undefined  && product.offeringDetails.PMP_Partner_Offering_Dsc__c != null){
                    //if(product.offeringDetails.PMP_Partner_Offering_Dsc__c != null){
                    var productDescription=product.offeringDetails.PMP_Partner_Offering_Dsc__c;
                    
                   
                    var temporalDivElement = document.createElement("div");
                    temporalDivElement.innerHTML = productDescription;
                    
                    var position;
                    product.introSection=productDescription;
                    //Description Inconsistent - As part of US954461 
                    //if the description field is greater than 250, then 'introSection' will hold 250 words and 'moreSection' will hold the remaining
                    if(productDescription.length>parseInt($A.get("$Label.c.PMP_Dsc_Char_Limit")))
                    { 
                        var doc = new DOMParser().parseFromString(productDescription, 'text/html');
                        var strippedDescription = doc.body.textContent;
                        var length = strippedDescription.substr(0,parseInt($A.get("$Label.c.PMP_Dsc_Char_Limit"))).lastIndexOf(" ");
                        product.introSection = strippedDescription.substr(0,length) + '...';
                        product.moreSection = productDescription;                   
                    }
                    component.set("v.bShowComponent",true);
                    if(product.moreSection==undefined){
                        product.moreSection='';
                    }
                } 
                /*---------------------------END-------------------------------------------------------------------------*/
                component.set("v.product",product);
                /*Added by raj to set isEnhancedPartner as true for enhanced partner*/
                if(component.get("v.product.partnerDetails.benefitType") == 'Solutions Marketplace Enhanced'){
                    component.set("v.isEnhancedPartner", true);
                }
                /*End*/
                
                
                
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            setTimeout($A.getCallback(function() {
                component.set('v.showSpinner',false);
            }), 2000);
        });
        var requestInitiatedTime=new Date().getTime();
        $A.enqueueAction(action);
                } else {
                    window.location.href = $A.get("$Label.c.PMP_Error_Page_URL");
                }
            }
        });
        
        $A.enqueueAction(act);
    } , 
    
    //Added By Shahrukh : US396638 - Setting the notification banner messages dynamically based on status
    notificationBannerMessages:function(component,helper,type,message){
        var notificationData = [
            {
                type: type,  //This will give the symbol on the left hand side of the banner message
                openInBlank: 'false', //To open in a new window
                message: message, //Message on the banner
                
            } 
        ];
        setTimeout($A.getCallback(function() {
            if (!component.get('v.previewMode')) {
                component.set('v.notificationData', notificationData); //Setting up the notification data 
                //component.set('v.loading', false);
            }
        }), 2000);
        
        
    },
    getJsonFromUrl : function () {
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            result[item[0]] = decodeURIComponent(item[1]);
        });
        return result;
    },
    //End of Code - US396638
    
    //US535027 : Redirect to edit offering of newly created offering on click of clone button
    getClonedOfferingDetails : function(component,helper){
        component.set('v.showSpinner',true);
        var offeringId='';
        var language = component.get('v.offeringDisplayLang');
        if(component.get('v.recordId')){
            offeringId = component.get('v.recordId');
        }
        else if (!component.get('v.recordId') && component.get('v.offeringId')){
            offeringId = component.get('v.offeringId');
        }
        
        var action = component.get("c.cloneOfferingDetail");  //calling cloneOfferingDetail method from PMP_offeringDetailsController
        
        
        action.setParams({ "offeringId": offeringId,
                          "language" : language
                         });
        
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(language=='NA'){language= undefined}
                var response = response.getReturnValue();
                response=JSON.parse(response);
                if(response.objectData.clonedRecId){
                    component.find("navigation").navigate({
                        type: 'standard__namedPage',
                        attributes: {
                            "pageName": "offering-edit" 
                        },
                        state: {
                            "recordId": response.objectData.clonedRecId
                            
                        }
                    }, true);
                    component.set('v.showSpinner',false);
                    
                    // window.location = response.objectData.communityURL+'/offering-edit?recordId='+response.objectData.clonedRecId; //navigate to edit offering
                }
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    createSpecInstance : function(specification, recDescription, recImageUrlNew, isSpecNotPresent, isSpecPresent, isOnlySpec)
    {		
        //Intermediate Variables for processing
        var specDescription = '';
        var specImageUrlNew = '';
        
        //creating object variable for recieved spec
        var spec  = new Object();
        
        //Creating Spec description object for storing Product URLs
        if(isSpecNotPresent == true || isSpecPresent == true){
            var specDescriptionObj = new Object();
        }
        
        if(isSpecPresent == true)
        {
            //Assigning specification value in string - spec description
            specDescription = recDescription + '<br/>' + specification.PMP_Specification_Value_Cd__c;
            //Assigning the same string to- spec description object
            specDescriptionObj.description = specification.PMP_Specification_Value_Cd__c;
        }
        
        else if(isSpecNotPresent == true){
            //Assign Spec description specification value to string 
            specDescription = specification.PMP_Specification_Value_Cd__c;  
            //Assigning the same Spec description to Spec description object & spec object 
            specDescriptionObj.description = specDescription;
        }
        
            else{
                specDescription = specification.Name;
            }
        spec.description = specDescription;
        
        if(specification.PMP_Specification_Value_Id__r){
            //Populating Image URL in Spec Object 
            if(specification.PMP_Specification_Value_Id__r.PMP_Image_URL__c){
                spec.imageUrl = specification.PMP_Specification_Value_Id__r.PMP_Image_URL__c;
                specImageUrlNew = specification.PMP_Specification_Value_Id__r.PMP_Image_URL__c;
            }
            
            //Populating Product URL  in Spec Object 
            if(specification.PMP_Specification_Value_Id__r.PMP_Product_URL__c){
                spec.productUrl = specification.PMP_Specification_Value_Id__r.PMP_Product_URL__c;
                specDescriptionObj.productURL = specification.PMP_Specification_Value_Id__r.PMP_Product_URL__c;
            }
        }
        
        //This condition is executed when no spec value is selected
        else
        {
            //Image URL 
            if(specification.PMP_Specification_Id__r.PMP_Image_url__c){
                spec.imageUrl = specification.PMP_Specification_Id__r.PMP_Image_url__c;
                specImageUrlNew = specification.PMP_Specification_Id__r.PMP_Image_url__c;
            } 
            //Product URL 
            if(specification.PMP_Specification_Id__r.PMP_Product_url__c){
                spec.productUrl = specification.PMP_Specification_Id__r.PMP_Product_url__c;
            }  
        }
        
        //if image URL is undefined, then assign the previous image URL to the Spec
        if(spec.imageUrl == undefined){
            if(specification.PMP_Ancestor_Specification_Cd__c.includes($A.get("$Label.c.PMP_NPP_IntelTechnologies")))
            {
                spec.imageUrl = $A.get("$Label.c.PMP_IntelTechImageURL");
            }
            else{
                spec.imageUrl = recImageUrlNew; 
            }
        }
        var sentData = {
            specTechName: specification.Name,
            specTechObject: spec,
            specDescName: specification.Name,
            specDescObject: specDescriptionObj,
            specDescription: specDescription,
            specImageUrlNew: specImageUrlNew
        };
        
        return sentData;
    }
    
})