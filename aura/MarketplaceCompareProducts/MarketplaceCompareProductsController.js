({})
    
//     doInit: function(component, event, helper) {
                
//         // component.set('v.mapStateToAttributes', function(state) {
//             var offeringIds = [];
//             // console.log("onin", JSON.stringify(state));
//             /*for (var prodIndex = 0; prodIndex < state.items.length; prodIndex++) {
//                 //adding all Ids to the list
//                 offeringIds.push(state.items[prodIndex].id);
//             } */
//             //compareCategoryId
//             var items = sessionStorage.getItem('ipaCompareTray-cache');
//             items = items ? JSON.parse(items) : [];
//             offeringIds = items.map((offering) => offering.id);
//             console.log(items, offeringIds)
//             component.set('v.compareTrayItems', items)
//             // //Gireesh US716270: 20-July-2020: changed state.items to currentItems
//             // for (var prodIndex = 0; prodIndex < state.currentItems.length; prodIndex++) {
                
//             //     //get Tier 2 categerory Id
//             //     if(prodIndex==0 && state && state.currentItems && state.currentItems[prodIndex].compareCategoryId){
//             //         component.set("v.secondTierCatId", state.currentItems[prodIndex].compareCategoryId);
//             //     }
                
//             //     //adding all Ids to the list
//             //     offeringIds.push(state.currentItems[prodIndex].id);
//             // }
            
//             var userLangCode = $A.get("$Locale.langLocale");
//             console.log("#g-c-userLangCode", userLangCode);
//             //Get Offerings Details for all the Ids            
//             var params = {
//                 offeringIds: offeringIds,
//                 bEditOffering: false,
//                 bViewOffering: true,
//                 bCompareOffering: true,
//                 langCode: userLangCode,
//                 isPartnerDetails:true
//             };
//             //Dispatch only onInit
//             if(component.get("v.initLoad")){
//                 component.set("v.initLoad",false);     
                
//                 //Gireesh:US716270: using call-server method to fecth directly instead of dispatch
//                 //get Partner details                
                
//                 console.log('--params', params);
//                 var action = component.get("c.fetchOfferingDetails");    
//                 action.setParams(params);
//                 action.setCallback(this, function(response) {
//                     var state = response.getState();
//                     if (state === "SUCCESS") {
//                         var response = response.getReturnValue();
//                         console.log("@CP2",response);
//                         component.set("v.multiplePartnerDetails",response);
//                         console.log('--multiplePartnerDetails--',component.get("v.multiplePartnerDetails"));
//                     }
//                     else if (state === "ERROR") {
//                         var errors = response.getError();
//                         if (errors) {
//                             if (errors[0] && errors[0].message) {
//                                 console.log("Error message: " + 
//                                             errors[0].message);
//                             }
//                         } else {
//                             console.log("Unknown error");
//                         }
//                     }
//                 });
                
//                 $A.enqueueAction(action);
                
//                 //
//                 //
//                 //
//                 //To Fetch Multiple Offering Details
//                 var params2 = {
//                 offeringIds: offeringIds,
//                 bEditOffering: false,
//                 bViewOffering: true,
//                 bCompareOffering: true,
//                 langCode: userLangCode,
//                 isPartnerDetails:false
//             };
//                 var action2 = component.get("c.fetchOfferingDetails");            
//                 action2.setParams(params2);
//                 action2.setCallback(this, function(response) {
//                     var state = response.getState();
//                     if (state === "SUCCESS") {
//                         var response = response.getReturnValue();
//                         console.log("@CP",response);
//                         component.set("v.multipleOfferingDetails",response);
                        
//                     }
//                     else if (state === "ERROR") {
//                         var errors = response.getError();
//                         if (errors) {
//                             if (errors[0] && errors[0].message) {
//                                 console.log("Error message: " + 
//                                             errors[0].message);
//                             }
//                         } else {
//                             console.log("Unknown error");
//                         }
//                     }
//                 });
                
//                 $A.enqueueAction(action2);
                
               
                
//             }
            
//             /*return {                
//                 compareTrayItems: state.items,
//                 multipleOfferingDetails: state.multipleOfferingDetails  
//             };*/
            
//              //Gireesh:US716270:
//             // return {        
                
//             //     compareTrayItems: state.currentItems,                
//             // };
            
            
//         // });
        
//         //component.set('v.addProductLinkSearchParams', { type: 'product'});
//     },
    
//     handlemultipleOfferingDetailsChange: function(component, event, helper) {
        
//         /*component.set('v.mapStateToAttributes', function(state) {
//          console.log("handlemultipleOfferingDetailsChange--", JSON.stringify(state));   
//         }
//         );*/
//          var userLocale = $A.get("$Locale.langLocale"); // logged-In or Guest users language code (if changed via language selector) - Gireesh(US664733)
//         if(userLocale!= null || userLocale!=undefined){
//             userLocale=userLocale.toLowerCase();
//         }
//         console.log("userLocale0", userLocale);
//         var compareTrayItems = component.get('v.compareTrayItems');
//         console.log("compareTrayItems",compareTrayItems);
//         var multipleOfferingDetails = component.get("v.multipleOfferingDetails");
//         var multiplePartnerDetails = component.get("v.multiplePartnerDetails");
		

//         //If multipleOfferingDetails has elements then perform the below operations 
//         if(Object.keys(multipleOfferingDetails) && Object.keys(multipleOfferingDetails).length>0){
//             //create searchParam   
//             //if(compareTrayItems!=undefined && compareTrayItems.length>0)
//              //   helper.handleAddClick(component, event, helper);
              
//             var offeringIds = [];
//             var productsToCompare = [];       
//             for (var prodIndex = 0; prodIndex < compareTrayItems.length; prodIndex++) {
//                 var productsToCompareObj = new Object();
//                 productsToCompareObj.Id = compareTrayItems[prodIndex].id;
//                 productsToCompareObj.Name = compareTrayItems[prodIndex].title;
//                 productsToCompareObj.logo = compareTrayItems[prodIndex].imageUrl;  
               
//                 //adding all Ids to the list
//                 offeringIds.push(compareTrayItems[prodIndex].id);
//                 productsToCompare.push(productsToCompareObj);   
                
//             }       
            
            
//             // COMPARE DATA
            
//             var sections = [];       
            
//             var industryColumField = new Set();
//             var applicationColumField = new Set();
//             var availPriceColumField = new Set();
//             var geoDetailsColumField = new Set();
//             var essentialColumField = new Set();
//             var processorColumField = new Set();
//             var processorSocketedColumnField=new Set();
//             var chipsetColumField = new Set();
//             var fpgaColumField = new Set();
//             var techColumField = new Set();
//             var EndCustomerColumField = new Set();
//             var displayColumField = new Set();
//             var deviceColumField = new Set();
//             var environmentColumField = new Set();
//             var osColumField = new Set();
//             var batteryColumnField = new Set();
//             var dimensionColumnField = new Set();
//             var memoryColumnField = new Set();
//             var storageColumnField = new Set();
//             var wirelessColumnField = new Set();
//             var cloudColumnField = new Set();
//             var nucColumField = new Set(); // Added by Abhishek for Nuc US
//             var expertiseColumnField = new Set();//Added for Expertise[PSG]
//             var industryStandColumnField = new Set();//Added for Industry Standard Certificate
//             var ipCertificateColumnField = new Set();//Added for IP Certificate
//             var ipLicenseColumnField = new Set();//Added for IP License Delivery
            
//             var industryProductsToCompare = [];
//             var applicationProductsToCompare = [];
//             var availPriceProductsToCompare = [];
//             var geoDetailProductsToCompare = [];
//             var EndProductsToCompare = [];
//             var essentialProductsToCompare = [];
//             var processorProductsToCompare = [];
//             var processorSocketedProductsToCompare=[];
//             var chipsetProductsToCompare = [];
//             var fpgaProductsToCompare = [];
//             var techProductsToCompare = [];
//             var customerProductsToCompare = [];
//             var displayProductsToCompare = [];
//             var deviceProductsToCompare = [];
//             var osProductsToCompare = [];
//             var batteryProductsToCompare = [];
//             var dimensionProductsToCompare = [];
//             var memoryProductsToCompare = [];
//             var storageProductsToCompare = [];
//             var wirelessProductsToCompare = [];
//             var cloudProductsToCompare = [];
//             var nucProductsToCompare = []; //Added by Abhishek for Nuc US.
//             var expertiseProductsToCompare = [];//Added for Expertise[PSG]
//             var industryStandsToCompare = [];//Added for Industry Standards
//             var ipCertificateToCompare = [];//Added for IP Certification
//             var ipLicenseToCompare = [];//Added for IP License Delivery
//             /*Added by raj as part of defect fix(DE98862)*/
//             var categoryById = new Map();
//             var categoryChildById = new Map();
//             /*End*/
//             //Accordion 
//             //   
//             var lables = [$A.get("$Label.c.PMP_Category"),$A.get("$Label.c.PMP_Processors"), $A.get("$Label.c.PMP_chipsets"),
//                           $A.get("$Label.c.PMP_FPGA"), $A.get("$Label.c.PMP_Intel_Technologies"), $A.get("$Label.c.PMP_Industry"),
//                           $A.get("$Label.c.PMP_application"), $A.get("$Label.c.PMP_Availability_and_Pricing"),
//                           $A.get("$Label.c.PMP_Geo_Coverage"), $A.get("$Label.c.PMP_End_Customer_Type"), $A.get("$Label.c.PMP_Operating_Systems"),
//                           $A.get("$Label.c.PMP_Devices_and_Interfaces"),
//                           $A.get("$Label.c.PMP_Displays"), $A.get("$Label.c.PMP_Environment"), $A.get("$Label.c.PMP_Battery"),
//                           $A.get("$Label.c.PMP_Dimensions"), $A.get("$Label.c.PMP_Memory"), $A.get("$Label.c.PMP_Storage"),
//                           $A.get("$Label.c.PMP_Wireless"), $A.get("$Label.c.PMP_Cloud_Services"),$A.get("$Label.c.PMP_NUC"),
//                           $A.get("$Label.c.PMP_Expertise"), $A.get("$Label.c.PMP_Industry_Standards"), $A.get("$Label.c.PMP_IP_Certification"), $A.get("$Label.c.PMP_IP_License")
//                          ];
//             //creating accordions with empty categories(Header)
//             for (var secIndex = 0; secIndex < lables.length; secIndex++) 
//             {
//                 var section = new Object();
//                 section.label = lables[secIndex];
//                 section.open = false;
//                 section.categories = [];
//                 sections.push(section);
//             }
            
//             //Iterate for each Offering Ids
//             for (var prodIndex = 0; prodIndex < compareTrayItems.length; prodIndex++) 
//             {   
                
//                 //Get the Offering Details            
//                 var offeringDetails =[];
//                 var productInfo =[];
//                 if(multipleOfferingDetails.offerings[compareTrayItems[prodIndex].id]!=undefined && JSON.parse(multipleOfferingDetails.offerings[compareTrayItems[prodIndex].id]).objectData!=undefined )
//                     offeringDetails=JSON.parse(multipleOfferingDetails.offerings[compareTrayItems[prodIndex].id]).objectData;
//                 	console.log('details--' ,offeringDetails);
//                 //Gireesh:US664733
//                 if(userLocale==null || userLocale==undefined && offeringDetails.userLocale!=null && offeringDetails.userLocale!=undefined){
//                     userLocale = (offeringDetails.userLocale).toLowerCase();
//                 }
//                 console.log("userLocale1", userLocale);
//                 var industryProducts = new Object();
//                 var applicationProducts = new Object();
//                 var typeProducts = new Object();
//                 var availPriceProducts = new Object();
//                 var geoDetailProducts = new Object();
//                 var EndProducts = new Object();
//                 var essentialProducts = new Object();
//                 var processorProducts = new Object();
//                 var processorSocketedProducts=new Object();
//                 var chipsetProducts = new Object();
//                 var fpgaProducts = new Object();
//                 var techProducts = new Object();
//                 var environmentProducts = new Object();
//                 var displayProducts = new Object();
//                 var deviceProducts = new Object();
//                 var osProducts = new Object();
//                 var batteryProducts = new Object();
//                 var dimensionProducts = new Object();
//                 var memoryProducts = new Object();
//                 var storageProducts = new Object();
//                 var wirelessProducts = new Object();
//                 var cloudProducts = new Object();
//                 var nucProducts = new Object(); //Added By Abhishek for NUC
// 				var expertiseProducts = new Object();//Added for Expertise[PSG]
//                 var insdustryStandProd = new Object();//Added for Industry Standard Certificate
//                 var ipCertificateProd = new Object();//Added for IP Certificate
//                 var ipLicenseProd = new Object();//Added for IP License Deliver
                
//                 var excludeList = [];
//                 var excludeHeaderList=[];
//                 let includeHeaderList = new Set();
//                 let processorHasChildList = new Set();
//                 var tempExcludeList = [];
//                 var processorExcludeList = [];
//                 var processorExcludeTempList = [];
//                 var osstring = '';
//                 var osProdSpec = '';
//                 var osValues =[];
//                 var enValues = [];
//                 var wirelessstring = '';
//                 var wirelesprodspec = '';
//                 var displaystring = '';
//                 var displayprodspec = '';
//                 var memorystring = '';
//                 var memoryprodspec = '';
//                 var devicestring = '';
//                 var deviceprodspec = '';
//                 var enString = '';
//                 var envProdSpec = '';
//                 var storageString = '';
//                 var storageprodspec = '';
//                 var repeat = '';
//                 var expertiseSpec = '';//Added for Expertise[PSG]
//                 var expertiseValues = [];//Added for Expertise[PSG]
//                 var expertise = '';//Added for Expertise[PSG]
//                 var catMap=new Map();
//                 var catChildListMap=new Map();
//                 var catChildList=[];
//                 var systemHeaders=[];
//                 var nodesVisited=[];
//                 var regionById = new Map();
//                 var regionChildById = new Map();
//                 var countries = []; //added by raj to display countries with region, as part of spike story
// 				console.log("partner-contact", offeringDetails)
//                 if(offeringDetails.showContactPartner){component.set('v.showContactPartner', true);}
//                 console.log('intelEmp--' +offeringDetails.showContactPartner);
//                 //Iterate Categories
//                 if(offeringDetails.selectedCategories && offeringDetails.selectedCategories.length>0){
//                     for (var catIndex = 0; catIndex < offeringDetails.selectedCategories.length; catIndex++) 
//                     {
//                         //For System, get only top nodes under system
//                         if(offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r!=undefined &&
//                            offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c!=undefined &&
//                            (offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c=="IPA_TYPE_Sys"))
//                         { 
//                             systemHeaders.push(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c);    
//                         }
                        
                        
                        
//                         //Industry and Application exclude list
//                         if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c != undefined &&
//                             ((offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).includes($A.get("$Label.c.PMP_NPP_01_Industry")) ||
//                              (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).includes($A.get("$Label.c.PMP_NPP_01_APP")) ||
//                              (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).includes($A.get("$Label.c.PMP_NPP_01_TYPE")) 
//                             )
//                            ) 
//                         {  
                            

//                             for (var inrIndex = 0; inrIndex < offeringDetails.selectedCategories.length; inrIndex++) 
//                             {  
//                                 if (offeringDetails.selectedCategories[inrIndex].PMP_Ancestor_Category_Cd__c != undefined) 
//                                 {   
                                    
//                                     //Exclude header nodes if child exist
//                                     if(offeringDetails.selectedCategories[inrIndex].PMP_Ancestor_Category_Cd__c.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c))
//                                     {
//                                         excludeHeaderList.push(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c);
//                                     }                            
//                                     //Exclude intermediate nodes but with ancestor length greater than 2
//                                     var innerAncestorKeys = (offeringDetails.selectedCategories[inrIndex].PMP_Ancestor_Category_Cd__c).split("|");
//                                     //add intermediate nodes into exclude list
//                                     if (innerAncestorKeys.length > 2 )
//                                     {
//                                         for (var kLen = 2; kLen < innerAncestorKeys.length; kLen++) 
//                                         {	
//                                             if (!excludeList.includes(innerAncestorKeys[kLen]))
//                                                 excludeList.push(innerAncestorKeys[kLen]);
//                                         }
//                                     }
//                                 }
//                             }
//                         }

//                         //Industry
//                         //Filter all industry data excluding labels
//                         if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c != undefined &&(offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).includes($A.get("$Label.c.PMP_NPP_01_Industry"))) 
//                         {
//                             var ancestorKeys = (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).split("|");
//                             var directParent = "";                    
//                             //Get the direct of the current Category whose ancestor category length greater than 2
//                             if(ancestorKeys.length > 2 && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r!=undefined && 
//                                offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r!=undefined)
//                             {

//                                 directParent=offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name;
//                                 if(userLocale=='zh_cn' && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Chinese_Nm__c !=undefined )
//                                     directParent=offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Chinese_Nm__c;
//                                 else if(userLocale=='ja' && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Japanese_Nm__c !=undefined )
//                                     directParent=offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Japanese_Nm__c;
//                                 console.log('directParent', directParent, userLocale);
//                             }                    
//                             //For all the child nodes of HEADER, concatenate with direct parent   
//                             if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c != $A.get("$Label.c.PMP_NPP_01_Industry")) 
//                             {                        
//                                 //Header PIM category is created as key, so 2nd element is picked from the ancestor PIM cartegory  (PMP_Ancestor_Category_Cd__c)
//                                 //If the Key already exist append the value, otherwise add the key and value  
//                                 if (industryProducts[ancestorKeys[1]] && !excludeList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c)) {
//                                     var prevString = industryProducts[ancestorKeys[1]];
//                                     if (directParent.length > 0)
//                                         prevString = prevString +((prevString.length>0)?"<br/>":"")+directParent + " : " + offeringDetails.selectedCategories[catIndex].Name;
//                                     else
//                                         prevString = prevString +((prevString.length>0)?"<br/>":"")+ offeringDetails.selectedCategories[catIndex].Name;
//                                     industryProducts[ancestorKeys[1]] = prevString;
//                                 } 
//                                 else 
//                                 {                            
//                                     if (!excludeList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c)) 
//                                     {
//                                         if (directParent.length > 0)
//                                             industryProducts[ancestorKeys[1]] = directParent + " : " + offeringDetails.selectedCategories[catIndex].Name;
//                                         else
//                                             industryProducts[ancestorKeys[1]] = offeringDetails.selectedCategories[catIndex].Name;
//                                     }
//                                 }
//                             } 
                            
//                             //Header PIM category is created as key(PMP_Offering_Category_External_Key__c)
//                             else 
//                             {                        
//                                 if(!excludeHeaderList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c))
//                                 {  
//                                     if (industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c]) 
//                                     {
//                                         var prevString = industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c];
//                                         prevString = prevString +  "<br/>"+offeringDetails.selectedCategories[catIndex].Name;
//                                         industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c] = prevString;
//                                     } else 
//                                     {
//                                         industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c] = offeringDetails.selectedCategories[catIndex].Name;
//                                     }
//                                 }
//                             }
                            
//                             //Creating the Header nodes, Categories which are direct decendants of NPP_01_Industry will become the Header node 
//                             if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c != undefined && (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c == $A.get("$Label.c.PMP_NPP_01_Industry"))) 
//                             {
//                                 var industryNameValue = new Object();
//                                 industryNameValue[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c] = offeringDetails.selectedCategories[catIndex].Name;
//                                 Object.assign(industryColumField, industryNameValue); 
//                             }
//                         }
//                         //application
//                         //Filter all Application data excluding labels
//                         else if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c != undefined &&(offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).includes($A.get("$Label.c.PMP_NPP_01_APP"))) 
//                         {
//                             var ancestorKeys = (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).split("|");
//                             var directParent = "";                    
//                             //Get the direct of the current Category whose ancestor category length greater than 2
//                             if(ancestorKeys.length > 2 && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r!=undefined && 
//                                offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r!=undefined)
//                             {

//                                 directParent=offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name;
//                                 if(userLocale=='zh_cn' && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Chinese_Nm__c !=undefined )
//                                     directParent=offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Chinese_Nm__c;
//                                 else if(userLocale=='ja' && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Japanese_Nm__c !=undefined )
//                                     directParent=offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Japanese_Nm__c;
//                                           console.log('directParent1', directParent, userLocale);     
//                             }                    
//                             //For all the child nodes of HEADER, concatenate with direct parent   
//                             if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c != $A.get("$Label.c.PMP_NPP_01_APP")) 
//                             {                        
//                                 //Header PIM category is created as key, so 2nd element is picked from the ancestor PIM cartegory  (PMP_Ancestor_Category_Cd__c)
//                                 //If the Key already exist append the value, otherwise add the key and value  
//                                 if (applicationProducts[ancestorKeys[1]] && !excludeList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c)) {
//                                     var prevString = applicationProducts[ancestorKeys[1]];
//                                     if (directParent.length > 0)
//                                         prevString = prevString +"<br/>"+ directParent + " : " + offeringDetails.selectedCategories[catIndex].Name;
//                                     else
//                                         prevString = prevString +"<br/>"+ offeringDetails.selectedCategories[catIndex].Name;
//                                     applicationProducts[ancestorKeys[1]] = prevString;
//                                 } else 
//                                 {
//                                     if (!excludeList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c)) 
//                                     {
//                                         if (directParent.length > 0)
//                                             applicationProducts[ancestorKeys[1]] = directParent + " : " + offeringDetails.selectedCategories[catIndex].Name;
//                                         else
//                                             applicationProducts[ancestorKeys[1]] = offeringDetails.selectedCategories[catIndex].Name;
//                                     }
//                                 }
//                             } 
//                             //Header PIM category is created as key(PMP_Offering_Category_External_Key__c)
//                             else 
//                             {
//                                 if(!excludeHeaderList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c))
//                                 {  
//                                     if (industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c]) 
//                                     {
                                        
//                                         var prevString = industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c];
//                                         prevString = prevString +((prevString.length>0)?"<br/>":"")+offeringDetails.selectedCategories[j].Name;
//                                         industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c] = prevString;
//                                     } else 
//                                     {
//                                         industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c] = offeringDetails.selectedCategories[catIndex].Name;
//                                     }
//                                 }
//                             }
//                             //Creating the Header nodes, Categories which are direct decendants of NPP_01_Industry will become the Header node 
//                             if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c != undefined && (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c == $A.get("$Label.c.PMP_NPP_01_APP"))) 
//                             {
//                                 var applicationNameValue = new Object();
//                                 applicationNameValue[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c] = offeringDetails.selectedCategories[catIndex].Name;
//                                 Object.assign(applicationColumField, applicationNameValue);                        
//                             }
//                         } 
//                         //new Type
//                             else if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c != undefined &&(offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).includes($A.get("$Label.c.PMP_NPP_01_TYPE"))) 
//                             {
//                                 /*Added as part of defect fix (DE98862)*/
//  								 var catList=[];//to store category's child
//                                     //map<categoryId,categoryObject>,contains categoryId and it's object record
//                                     categoryById.set(offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,offeringDetails.selectedCategories[catIndex]);
//                                     //map<categoryId,List<categoryObject>>,contains categoryId and list of child related to it(Default 0)
//                                     categoryChildById.set(offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,catList);
//                                 /*End*/
//                                 /*var ancestorKeys = (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).split("|");
//                                 var directParent = "";                    
//                                 if (systemHeaders.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c)){
//                                     console.log('!!name-->');
//                                     var prevString = typeProducts[ancestorKeys[1]];
//                                     prevString=offeringDetails.selectedCategories[catIndex].Name;
//                                     typeProducts[ancestorKeys[1]] = prevString;
//                                 }
//                                 console.log('prevString-->', ancestorKeys);
//                                 //Get the direct of the current Category whose ancestor category length greater than 2
//                                 if(ancestorKeys.length >= 2 && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r!=undefined && 
//                                    offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r!=undefined)
//                                 {
//                                     console.log('dp-->', offeringDetails.selectedCategories[catIndex].Name);
//                                     directParent=offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name;
//                                     if(userLocale=='zh_cn' && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Chinese_Nm__c !=undefined )
//                                         directParent=offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Chinese_Nm__c;
//                                     else if(userLocale=='ja' && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Japanese_Nm__c !=undefined )
//                                         directParent=offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Japanese_Nm__c;
//                                                console.log('directParent3', directParent, userLocale);    
//                                 }    
//                                 //For all the child nodes of HEADER, concatenate with direct parent   
//                                 if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c != $A.get("$Label.c.PMP_NPP_01_TYPE")) 
//                                 {                        
//                                     //Header PIM category is created as key,  2nd element is picked from the ancestor PIM cartegory  (PMP_Ancestor_Category_Cd__c) as a key
//                                     //If the Key already exist append the value, otherwise add the key and value  
//                                     if (typeProducts[ancestorKeys[1]] && !excludeList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c)) {
//                                         console.log('Iff-->', directParent);
//                                         var prevString = typeProducts[ancestorKeys[1]];
//                                         if (prevString.length > 0){
//                                             directParent=prevString+" : "+directParent;
//                                             prevString="";
//                                         }
//                                         if (directParent.length > 0)
//                                             prevString = prevString +((prevString.length>0)?"<br/>":"")+ directParent + " : " + offeringDetails.selectedCategories[catIndex].Name;
//                                         else
//                                             prevString = prevString +((prevString.length>0)?"<br/>":"")+ offeringDetails.selectedCategories[catIndex].Name;
//                                         typeProducts[ancestorKeys[1]] = prevString;
//                                     } else 
//                                     {
//                                         //console.log('else-->', directParent);
//                                         //console.log('else EE-->', excludeList); 
//                                         //console.log('else Extrernal-->', offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c);
//                                         if (!excludeList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c)) 
//                                         {
//                                             console.log('inside else if');
//                                             if (directParent.length > 0)
//                                                 typeProducts[ancestorKeys[1]] = directParent + " : " + offeringDetails.selectedCategories[catIndex].Name;
//                                             else
//                                                 typeProducts[ancestorKeys[1]] = offeringDetails.selectedCategories[catIndex].Name;
//                                         }
//                                         console.log('else2-->', typeProducts[ancestorKeys[1]]);
//                                     }
//                                 }
//                                 //Header PIM category is created as key(PMP_Offering_Category_External_Key__c)
//                                 else 
//                                 {
//                                     if(!excludeHeaderList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c))
//                                     {  
//                                         if (typeProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c]) 
//                                         {
                                            
//                                             var prevString = typeProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c];
//                                             prevString = prevString + "<br/>"+offeringDetails.selectedCategories[j].Name;
//                                             typeProducts[offeringDetails.selectedCategories[catIndex].still] = prevString;
//                                         } else 
//                                         {
//                                             typeProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c] = offeringDetails.selectedCategories[catIndex].Name;
//                                         }
//                                     }
//                                 }
//                                 //Creating the Header nodes, Categories which are direct decendants of NPP_01_TYPE will become the Header node 
//                                 if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c != undefined && (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c == $A.get("$Label.c.PMP_NPP_01_TYPE"))) 
//                                 {
//                                     var typeNameValue = new Object();
//                                     typeNameValue[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c] = offeringDetails.selectedCategories[catIndex].Name;
//                                     Object.assign(essentialColumField, typeNameValue);
//                                     console.log('Categories-->', typeNameValue);
//                                 }*/
//                             }
//                         //newType end 
//                     }
//                 }
//                 /*Added as part of defect fix (DE98862)*/
//                 for(var cat of offeringDetails.selectedCategories){
//                     if(cat.PMP_Ancestor_Category_Cd__c){
//                         if(cat.PMP_Ancestor_Category_Cd__c.includes($A.get("$Label.c.PMP_NPP_01_TYPE")) && categoryChildById.has(cat.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c)){
//                             categoryChildById.get(cat.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c).push(cat);
//                         }
//                     }
//                 }
//                 if(categoryChildById){
//                     for(var itr of categoryChildById.keys()){
//                         var productCategories='';
//                         if(categoryChildById.get(itr).length == 0){
//                             //getting only the child nodes which were selected 
//                             var cat=categoryById.get(itr);
//                             var ancesCat=cat.PMP_Ancestor_Category_Cd__c.split('|');
//                             var typeNameValue = new Object();
//                             let gParent = categoryById.get(ancesCat[1]);
//                             typeNameValue[gParent.PMP_Offering_Category_External_Key__c] = gParent.Name;
//                             Object.assign(essentialColumField, typeNameValue);
//                             if(ancesCat.length>2){
//                                 //appending all parent except for the ultimate parent
//                                 for(var ancesIdx=2;ancesIdx<ancesCat.length;ancesIdx++){
//                                     var parent=categoryById.get(ancesCat[ancesIdx]);
//                                     if(parent){
//                                         productCategories += parent.Name + ' : ';
//                                     }    
//                                 }
//                             }
//                             productCategories += cat.Name;
//                             typeProducts[gParent.PMP_Offering_Category_External_Key__c]=productCategories;
//                         } 
//                     }
//                 }
// 				/*End*/
//                 //Specifications
//                 if(offeringDetails.selectedSpecifications && offeringDetails.selectedSpecifications.length>0){
//                     for (var specIndex = 0; specIndex < offeringDetails.selectedSpecifications.length; specIndex++) 
//                     {
                        
//                         //Include List Start
//                         {
//                             //Include  SpecId List for PMP_DevicesandInterfacesLevel1 Specification
//                             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined &&
//                                 (
//                                     (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_DevicesandInterfacesLevel1")) ||
//                                  (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_NPP_Processors"))
//                                  ||
//                                     (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_NPP_Wireless"))
//                                     ||
//                                     (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_NPP_OperationSystems")) 
//                                     ||
//                                     (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_NPP_IntelTechnologies"))
//                                 )
//                                )
                                
//                             {  
//                                 for (var inrIndex = 0; inrIndex < offeringDetails.selectedSpecifications.length; inrIndex++) 
//                                 {  
                                    
                                    
//                                      if (offeringDetails.selectedSpecifications[inrIndex].PMP_Ancestor_Specification_Cd__c != undefined &&
//                                         offeringDetails.selectedSpecifications[inrIndex].PMP_Specification_Value_Cd__c!=undefined &&
//                                         (offeringDetails.selectedSpecifications[inrIndex].PMP_Ancestor_Specification_Cd__c).includes(offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c)
                                        
//                                        ) 
//                                     {   
//                                         console.log('In Intel Technologies-------------');
//                                         //Include nodes if child exist
//                                         includeHeaderList.add(offeringDetails.selectedSpecifications[inrIndex].PMP_Product_Specification_Cd__c);
//                                         console.log('includeHeaderList-------------',includeHeaderList);
//                                         var keys=[];
//                                         if(offeringDetails.selectedSpecifications[inrIndex].PMP_Ancestor_Specification_Cd__c!=undefined)
//                                             keys=offeringDetails.selectedSpecifications[inrIndex].PMP_Ancestor_Specification_Cd__c.split('|');
                                        
//                                         if(keys.length>1){
//                                             includeHeaderList.add(keys[keys.length-1]);
//                                             processorHasChildList.add(keys[keys.length-1]);
//                                         }
//                                     }
//                                 }
//                             }
//                         }
//                         //Include List End

//                         //Availability and Pricing
//                         if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_AvailabilityandPricing"))) 
//                         {
//                             if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c == $A.get("$Label.c.PMP_AvailabilityandPricing")) 
//                             {
//                                 availPriceProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                             }
                            
//                             if(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c === 'NPP_AvailabilityAndPricing_CPP'){
//                                 availPriceProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = 'Y'; 
//                             }
                            
//                             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c == $A.get("$Label.c.PMP_AvailabilityandPricing"))) 
//                             {
//                                 var availPriceNameValue = new Object();
//                                 availPriceNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//                                 Object.assign(availPriceColumField, availPriceNameValue);
//                             }
//                         }
//                         //Geo Details New
//                         else if(offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined &&
//                                 offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c.includes('NPP_GeographicCoverage')
//                                ){
//                             var subRegions = [];//to store sub regions
//                             //storing the region records by product specification Id
//                             regionById.set(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c,offeringDetails.selectedSpecifications[specIndex]);
//                             //setting child list of the region to empty(default 0)
//                             regionChildById.set(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c,subRegions);
//                             //Added by raj as part of spike story
//                             /*if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c != undefined){//storing all the selected countries in a list
//                             	countries.push(offeringDetails.selectedSpecifications[specIndex]);
//                             }*/
//                         }

                        
//                         //End Customer Type
//                             else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c) == $A.get("$Label.c.PMP_NPP_EndCustomerType")) 
//                             {
//                                 EndProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = "Y";
//                                 var endCustomerNameValue = new Object();
//                                 endCustomerNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                                 Object.assign(EndCustomerColumField, endCustomerNameValue);                        
//                             }
                        
                        
//                         //Devices & Interfaces start-Gireesh
                        
// 							else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && 
// 									 (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_DevicesandInterfacesLevel1"))) 
// 							{
								
// 								var keys=offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c.split('|');
// 								//one which includes children 
// 								if(includeHeaderList.has(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)){
// 									// for ones having ancestor length ==1
// 									if(keys.length==1 && offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined){
// 										var prevStr=deviceProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
// 										if(prevStr==undefined)
// 											prevStr="";
// 										deviceProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]=prevStr+((prevStr.length>0)?"<br/>":"")+
// 											offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
										
// 									}
// 									// for ones having ancestor length>1
// 									else if(keys.length>1 && offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined)
// 									{
// 										var prevString="";
// 										if(keys[keys.length-1]){
// 											prevString=deviceProducts[keys[keys.length-1]];
// 											if(prevString==undefined)
// 												prevString=""
// 												deviceProducts[keys[keys.length-1]]=prevString+((prevString.length>0)?"<br/>":"")+offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c+":"+
// 													offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 										}else{
// 											if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined &&
// 											  offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c!=undefined)
// 											deviceProducts[keys[keys.length-1]]=
// 												offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c+":"+
// 												offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 										}
										
// 									}
									
// 								}
// 								//one which has no child
// 								else{
// 									if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c!=undefined)
// 										deviceProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]=
// 											offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c;
// 								}
// 								//Only Header Nodes
// 								if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c == $A.get("$Label.c.PMP_DevicesandInterfacesLevel1"))) 
// 								{
// 									var deviceNameValue = new Object();
// 									deviceNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 									Object.assign(deviceColumField, deviceNameValue);
// 								}
// 							}
					
// 					//Devices & Interfaces  End
                        
                       
                        
//                         //Displays
// 								else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_DisplaysLevel1")))
// 								{
// 									if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined && displayprodspec.includes(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)) 
// 									{
// 										displaystring = displaystring + "<br/>"+offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 									} else 
// 									{
// 										if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined){
// 											displayprodspec = offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c;
// 											displaystring = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 										}
// 									}
// 									displayProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = displaystring;
// 									var displayNameValue = new Object();
// 									displayNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 									Object.assign(displayColumField, displayNameValue);                                
// 								}
//                         //Operation Systems
// 								/*else if (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_OperationSystems") || offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_OperationSystems"))) 
// 								{
// 									if (osProdSpec == offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)
// 									{
// 										if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c){
// 											osValues.push(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c);
// 										}else{
// 											osValues.push(offeringDetails.selectedSpecifications[specIndex].Name);
// 										}    
// 									}
// 									else 
// 									{
// 										osProdSpec = offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c;
// 										osValues =[];
// 										if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c){
// 											osValues.push(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c);
// 										}else{
// 											osValues.push(offeringDetails.selectedSpecifications[specIndex].Name);
// 										}    
// 									}
// 									if(osValues.length > 1 && osValues.includes(offeringDetails.selectedSpecifications[specIndex].Name)){
// 										var index = -1;               
// 										var index = osValues.indexOf(offeringDetails.selectedSpecifications[specIndex].Name);
// 										if (index > -1) 
// 										{
// 											osValues.splice(index, 1);
// 										}
										
// 									}
// 									osstring =osValues.join(', ');                                    
// 									osProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = osstring;
// 									var osNameValue = new Object();
// 									osNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 									Object.assign(osColumField, osNameValue);
//                                 }*/
//                         //OS     
//                         else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_NPP_OperationSystems")))
//                         {
//                             var bCheckParentValue = false;
//                             if(offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != $A.get("$Label.c.PMP_NPP_OperationSystems")) 
//                             {
//                                 var keys = (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).split("|");
//                                 var directParent = "";
//                                 //if the ancestor length is greater than 2, then find the 'Name' of the direct parent
//                                 for(var index = 0; index < offeringDetails.selectedSpecifications.length; index++) 
//                                 {
//                                     if(keys.length > 2) 
//                                     {	
//                                         if(offeringDetails.selectedSpecifications[index].PMP_Product_Specification_Cd__c == keys[keys.length - 1]) 
//                                         {	
//                                             directParent = offeringDetails.selectedSpecifications[index].Name;
//                                             break;
//                                         }
//                                     }
//                                     if (offeringDetails.selectedSpecifications[index].PMP_Specification_Value_Cd__c !== undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_NPP_OperationSystems"))) 
//                                     {
//                                         tempExcludeList.push(offeringDetails.selectedSpecifications[index].Name);
//                                     }                                                                            
//                                 }

//                                 if(osProducts[keys[1]]) 
//                                 {   
//                                     var prevString = osProducts[keys[1]];
//                                     if (directParent.length > 0) 
//                                     {
                                        
//                                         if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c === undefined && !tempExcludeList.includes(offeringDetails.selectedSpecifications[specIndex].Name)){
//                                             prevString = prevString + "<br/>"+ directParent + " : " + offeringDetails.selectedSpecifications[specIndex].Name;
//                                             bCheckParentValue = true;
//                                         }else if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                                             prevString = prevString + "<br/>"+ "<b>" + offeringDetails.selectedSpecifications[specIndex].Name +"</b>"+ " : "+offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                                             bCheckParentValue = true;
//                                         }
//                                     } 
//                                     else 
//                                     {
//                                         if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c === undefined && !tempExcludeList.includes(offeringDetails.selectedSpecifications[specIndex].Name)){
//                                             prevString = prevString +"<br/>" + offeringDetails.selectedSpecifications[specIndex].Name;
//                                             bCheckParentValue = true;
//                                         }
//                                         else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                                             prevString = prevString + "<br/>"+ "<b>" +offeringDetails.selectedSpecifications[specIndex].Name+"</b>" + " : "+ offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                                             bCheckParentValue = true;
//                                         }
//                                     }
//                                     osProducts[keys[1]] = prevString;
//                                 } 
//                                 else 
//                                 {
//                                     if (directParent.length > 0){
//                                         osProducts[keys[1]] = directParent + " : " + offeringDetails.selectedSpecifications[specIndex].Name;
//                                         bCheckParentValue = true;
//                                     }
//                                     else 
//                                     {
//                                         if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c === undefined && !tempExcludeList.includes(offeringDetails.selectedSpecifications[specIndex].Name)){
//                                             osProducts[keys[1]] = offeringDetails.selectedSpecifications[specIndex].Name;
//                                             bCheckParentValue = true;
//                                         }else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                                             osProducts[keys[1]] = "<b>"+offeringDetails.selectedSpecifications[specIndex].Name+"</b>"+ " : " + offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
                                           
//                                             bCheckParentValue = true;
//                                         }
//                                     }
//                                 } 
//                             } 
//                             else 
//                             {
//                                 if (osProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]) {
//                                     var prevString = osProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
//                                     prevString = prevString +"<br/>"+ offeringDetails.selectedSpecifications[specIndex].Name;
//                                     osProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = prevString;
//                                     bCheckParentValue = true;
//                                 }
//                                 else
//                                 {
//                                     console.log('Inside nect blocks of else');
//                                     if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                                         osProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                                     }
//                                     else
//                                     {
//                                         if(!processorHasChildList.has(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c))
//                                         osProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//                                     }
                                    
//                                 }                                                                        
//                             }
                            
//                             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_OperationSystems"))) {
//                                 var osNameValue = new Object();
//                                 if (osNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] != undefined) {
//                                     osNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                                 } else {
//                                     osNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//                                 }
                                
//                                 Object.assign(osColumField, osNameValue);
//                             }
                            
//                         }
//                         //Environment
// 									else if (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && offeringDetails.selectedSpecifications && offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c == $A.get("$Label.c.PMP_EnvironmentLevel1"))
// 									{
// 										if (envProdSpec.includes(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)){
// 											if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c){
// 												enValues.push(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c);
// 											}else{
// 												enValues.push(offeringDetails.selectedSpecifications[specIndex].Name);
// 											}
// 										}
// 										else 
// 										{
// 											envProdSpec = offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c;
// 											enValues = [];
// 											if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c){
// 												enValues.push(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c); 
// 											}else{
// 												enValues.push(offeringDetails.selectedSpecifications[specIndex].Name);
// 											}    
// 										}
// 										if(enValues.length > 1 && enValues.includes(offeringDetails.selectedSpecifications[specIndex].Name)){
// 											var index = -1;               
// 											var index = enValues.indexOf(offeringDetails.selectedSpecifications[specIndex].Name);
// 											if (index > -1) 
// 											{
// 												enValues.splice(index, 1);                                                
// 											}
// 										}                                      
// 										enString =enValues.join('<br/> ');
// 										environmentProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = enString;
// 										var enNameValue = new Object();
// 										enNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 										Object.assign(environmentColumField, enNameValue);
// 									}
//                         //Battery
// 									else if (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && offeringDetails.selectedSpecifications && offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c == $A.get("$Label.c.PMP_BatteryLevel1")) 
// 									{
										
// 										batteryProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 										var batteryNameValue = new Object();
// 										batteryNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 										Object.assign(batteryColumnField, batteryNameValue);  
// 									}
//                         //Dimensions
// 								else if (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && offeringDetails.selectedSpecifications && offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c == $A.get("$Label.c.PMP_DimensionsLevel1")) 
// 								{
// 									if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined)
// 										dimensionProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 									var dimesionNameValue = new Object();
// 									dimesionNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 									Object.assign(dimensionColumnField, dimesionNameValue);                                                
// 								}
// 	//Memory
// 									else if (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && offeringDetails.selectedSpecifications && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c.includes($A.get("$Label.c.PMP_Memory"))) 
// 									{
										
// 										if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined && memoryprodspec.includes(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)) 
// 										{
// 											memorystring = memorystring  +"<br/>"+ offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 										} else 
// 										{
// 											memoryprodspec = offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c;
// 											if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c){
// 												memorystring = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 											}else{
// 												memorystring = offeringDetails.selectedSpecifications[specIndex].Name;
// 											}    
// 										}
										
// 										memoryProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = memorystring;
// 										var memoryNameValue = new Object();
// 										memoryNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 										Object.assign(memoryColumnField, memoryNameValue); 
// 									}
// 	//Storage
// 										else if (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && offeringDetails.selectedSpecifications && offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c == $A.get("$Label.c.PMP_StorageLevel1")) {
// 											if (storageprodspec.includes(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)) 
// 												storageString = storageString  +"<br/>"+ offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 											else {
// 												storageprodspec = offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c;
// 												if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c){
// 													storageString = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 												}else{
// 													storageString = offeringDetails.selectedSpecifications[specIndex].Name;
// 												}    
// 											}
// 											if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c){
// 												storageProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 											}else{
// 												storageProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 											}
// 											var storageNameValue = new Object();
// 											storageNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 											Object.assign(storageColumnField, storageNameValue);
// 										}
                        
                        
//                         //Wireless start-Gireesh
// 										else if ((offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined 
// 												  && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_Wireless"))
// 												 )||
// 												 offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_Wireless")
// 												) 
// 										{
// 											//Selectables directly under Wireless
											
// 											{
// 												if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined &&
// 												   offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && 
// 												   offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_Wireless")
// 												  )
// 												{
// 													wirelessProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c]=
// 														offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 												}
// 											}
											
// 											var keys=[];
// 											if(offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c!=undefined)
// 												keys=offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c.split('|');
// 											//one which includes children 
// 											if(includeHeaderList.has(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)){
// 												// for ones having ancestor length ==1
// 												if(keys.length==1 && offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined){
// 													var prevStr=wirelessProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
// 													if(prevStr==undefined)	prevStr="";
// 													wirelessProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]=prevStr+((prevStr.length>0)?"<br/>":"")+
// 														offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
													
// 												}
// 												// for ones having ancestor length>1
// 												else if(keys.length>1 && offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined)
// 												{
// 													var prevString="";
// 													if(keys[keys.length-1]){
// 														prevString=wirelessProducts[keys[keys.length-1]];
// 														if(prevString==undefined)
// 															prevString=""
// 															if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c!=undefined)
// 																wirelessProducts[keys[keys.length-1]]=prevString+((prevString.length>0)?"<br/>":"")+offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c+":"+
// 																	offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
														
// 													}else{
// 														if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c!=undefined)
// 															wirelessProducts[keys[keys.length-1]]=offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c+":"+
// 																offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 													}
													
// 												}
												
// 											}
// 											//one which has no child
// 											else{
// 												if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c!=undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c!=undefined )
// 												{ wirelessProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]=
// 													offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c;
// 												}
												
// 											}
// 											//Only Header Nodes                                                                   
// 											var wirelessNameValue = new Object();
// 											if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && 
// 												offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c!=undefined &&
// 												offeringDetails.selectedSpecifications[specIndex].Name !=undefined &&
// 												(offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_Wireless"))
// 											   ){
// 												wirelessNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 												Object.assign(wirelessColumnField, wirelessNameValue);
// 											}
// 											if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined &&
// 											   offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && 
// 											   offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_Wireless")
// 											  ){
// 												wirelessNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 												Object.assign(wirelessColumnField, wirelessNameValue);
// 											}
// 										}
// 					//Wireless end

                        
//                         //Cloud
// 										 else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && offeringDetails.selectedSpecifications && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_Cloud_Services")) 
// 										 {
											 
// 											 cloudProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = 'Y';
// 											 var cloudNameValue = new Object();
// 											 cloudNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 											 Object.assign(cloudColumnField, cloudNameValue);   
// 										 }
                        
//                         //processors
// 										 else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined 
// 												  && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_NPP_Processors"))
// 												 && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c!='NPP_Processors_ProcessorSocketed'
// 												 ) 
// 										 {
// 											 var bCheckParentValue = false;
// 											 if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != $A.get("$Label.c.PMP_NPP_Processors")) {
// 												 var keys = (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).split("|");
// 												 console.log('Processors Keys---> ',keys);
//                                                  var directParent = "";
// 												 //duplicateSpecCheck = duplicateSpecCheck + offeringDetails.selectedSpecifications[k].Name;
// 												 //if the ancestor length is greater than 2, then find the 'Name' of the direct parent
// 												 for (var index = 0; index < offeringDetails.selectedSpecifications.length; index++) {
// 													 if (keys.length > 2) {
// 														 if (offeringDetails.selectedSpecifications[index].PMP_Product_Specification_Cd__c == keys[keys.length - 1]) {
// 															 directParent = offeringDetails.selectedSpecifications[index].Name;
// 															 break;
// 														 }
// 													 }
// 													 if (offeringDetails.selectedSpecifications[index].PMP_Specification_Value_Cd__c !== undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_NPP_Processors"))) {
// 														 tempExcludeList.push(offeringDetails.selectedSpecifications[index].Name);
// 													 }                                                                            
// 												 }

// 												 if (processorProducts[keys[1]]) {                                                                            
// 													 var prevString = processorProducts[keys[1]];
// 													 if (directParent.length > 0) {
// 														 if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c === undefined && !tempExcludeList.includes(offeringDetails.selectedSpecifications[specIndex].Name)){
// 															 prevString = prevString + "<br/>"+ directParent + " : " + offeringDetails.selectedSpecifications[specIndex].Name;
// 															 bCheckParentValue = true;
// 														 }else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
// 															 prevString = prevString + "<br/>"+ "<b>" + offeringDetails.selectedSpecifications[specIndex].Name +"</b>"+ " : "+offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;  
// 															 bCheckParentValue = true;
// 														 }
// 													 } else {
// 														 if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c === undefined && !tempExcludeList.includes(offeringDetails.selectedSpecifications[specIndex].Name)){
// 															 prevString = prevString +"<br/>" + offeringDetails.selectedSpecifications[specIndex].Name;
// 															 bCheckParentValue = true;
// 														 }else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
// 															 prevString = prevString + "<br/>"+ "<b>" +offeringDetails.selectedSpecifications[specIndex].Name+"</b>" + " : "+ offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c; 
// 															 bCheckParentValue = true;
// 														 }
// 													 }
// 													 processorProducts[keys[1]] = prevString;
// 												 } else {
// 													 if (directParent.length > 0){
// 														 processorProducts[keys[1]] = directParent + " : " + offeringDetails.selectedSpecifications[specIndex].Name;
// 														 bCheckParentValue = true;
// 													 }else {
// 														 if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c === undefined && !tempExcludeList.includes(offeringDetails.selectedSpecifications[specIndex].Name)){
// 															 processorProducts[keys[1]] = offeringDetails.selectedSpecifications[specIndex].Name;
// 															 bCheckParentValue = true;
// 														 }else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
// 															 processorProducts[keys[1]] = "<b>"+offeringDetails.selectedSpecifications[specIndex].Name+"</b>"+ " : " + offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 															 bCheckParentValue = true;
// 														 }
// 													 }
// 												 } 
// 											 } else {
// 												 if (processorProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]) {
// 													 var prevString = processorProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
// 													 prevString = prevString +"<br/>"+ offeringDetails.selectedSpecifications[specIndex].Name;
// 													 processorProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = prevString;
// 													 bCheckParentValue = true;
// 												 }else{
// 													 if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
// 														 processorProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 													 }else{
// 														 if(!processorHasChildList.has(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c))
// 														 processorProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 													 }
													 
// 												 }                                                                        
// 											 }
											 
// 											 if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_Processors"))) {
// 												 var processorNameValue = new Object();
// 												 if (processorNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] != undefined) {
// 													 processorNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 												 } else {
// 													 processorNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 												 }
												 
// 												 Object.assign(processorColumField, processorNameValue);
// 											 }
											 
// 										 }
// 					//Processor Socketed
// 											 else if (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined 
// 													  && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c=='NPP_Processors_ProcessorSocketed'
// 													 ) 
// 											 {
// 												 processorSocketedProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = 'Y';
// 												 var processorSocketedNameValue = new Object();
// 												 processorSocketedNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 												 Object.assign(processorSocketedColumnField, processorSocketedNameValue);
// 											 }
//                         //Chipset
// 										 else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_NPP_Chipsets"))) {
// 											 if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != $A.get("$Label.c.PMP_NPP_Chipsets")) {                                                                            
// 												 if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined){
// 													 if(chipsetProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]){
// 														 if(chipsetProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]===offeringDetails.selectedSpecifications[specIndex].Name){
// 															 chipsetProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 														 }
// 														 else{
// 															 var prevString = chipsetProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
// 															 chipsetProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = prevString+"<br/>"+offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 														 }
// 													 }else{
// 														 chipsetProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 													 }
// 												 }else{
// 													 chipsetProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 												 }
// 											 }                                                                     
// 											 if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != $A.get("$Label.c.PMP_NPP_Chipsets"))) {
// 												 var chipsetNameValue = new Object();
                                                 
// 												 if (chipsetNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] != undefined) {
                                                     
// 													 chipsetNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 												 } else {
                                                     
// 													 chipsetNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 												 }                                                                            
// 												 Object.assign(chipsetColumField, chipsetNameValue);
// 											 }                                                                        
// 										 }
//                         //FPGA
// 												 else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_NPP_FPGA"))) {
													 
//                                                      if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != $A.get("$Label.c.PMP_NPP_FPGA")) {
// 														 if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined){
// 															 if(fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]){
// 																 if(fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]===offeringDetails.selectedSpecifications[specIndex].Name){
// 																	 fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 																 }
// 																 else{
// 																	 var prevString = fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
// 																	 fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = prevString+ ',' +"<br/>"+offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 																 }
// 															 }else{
// 																 fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 															 }
// 														 }else{
// 															 fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Partner_Product_Specification_Id__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 														 }
// 													 }else{
														 
// 														 fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 													 } 
// 													 if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === $A.get("$Label.c.PMP_NPP_FPGA"))) {
// 														 var fpgaNameValue = new Object();
// 														 if (fpgaNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] != undefined) {
// 															 fpgaNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 														 } else {
// 															 fpgaNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 														 }                                                                                
// 														 Object.assign(fpgaColumField, fpgaNameValue);
// 													 }                                                                           
// 												 }
//                         // Nuc										
// 										else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined &&
//                                                  (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes($A.get("$Label.c.PMP_NPP_NUC"))) {
											
//                                             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != $A.get("$Label.c.PMP_NPP_NUC")) {                                                                            
// 												 if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined){
// 													 if(nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]){
// 														 if(nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]==offeringDetails.selectedSpecifications[specIndex].Name){
// 															 nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 														 }
// 														 else{
// 															 var prevString = nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
// 															 nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = prevString+"<br/>"+offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 														 }
// 													 }else{
// 														 nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
                                                         
// 													 }
// 												 }else if(!nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]){
// 													 nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
												 	
//                                                  }
// 											 }
                                            
// 											 if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined 
//                                                   && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != $A.get("$Label.c.PMP_NPP_NUC"))){
                                                 
// 												 var nucNameValue = new Object();
// 												 if (nucNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] != undefined) {
// 													 nucNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 												 } else {
// 													 nucNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 												 } 
                                                 
// 												 Object.assign(nucColumField, nucNameValue);
// 											 }                                                                        
// 										 }	
//                         //Intel Tech

// 								 else if ((offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined 
// 										   && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_IntelTechnologies"))
// 										  )||
// 										  offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_IntelTechnologies")
// 										 ) 
// 								 {
// 									 //Selectables directly under Wireless
// 									 console.log('offeringDetails-----------',offeringDetails.selectedSpecifications[specIndex]);
									 
// 									 {
// 										 if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined &&
// 											offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && 
// 											offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_IntelTechnologies")
// 										   )
// 										 {
// 											 techProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c]=
// 												 offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                                              console.log('offeringDetails inside techProducts-----------',offeringDetails);
// 										 }
// 									 }
									 
// 									 var keys=[];
// 									 if(offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c!=undefined)
// 										 keys=offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c.split('|');
// 									 //one which includes children 
// 									 if(includeHeaderList.has(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)){
// 										 // for ones having ancestor length ==1
// 										 if(keys.length==1 && offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined){
// 											 var prevStr=techProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
// 											 if(prevStr==undefined)	prevStr="";
// 											 techProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]=prevStr+((prevStr.length>0)?"<br/>":"")+
// 												 offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                                              console.log('offeringDetails with ancestor length==1-----------',offeringDetails);
											 
// 										 }
// 										 // for ones having ancestor length>1
// 										 else if(keys.length>1 && offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined)
// 										 {
// 											 var prevString="";
// 											 if(keys[keys.length-1]){
// 												 prevString=techProducts[keys[keys.length-1]];
//                                                  console.log('offeringDetails inside ancestor >1 within if-----------',offeringDetails);
//                                                  console.log('prevString in ancestor > 1-----'+prevString);
//                                                  console.log('keys in ancestor > 1----------'+keys);
// 												 if(prevString==undefined)
// 													 prevString=""
// 													 if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c!=undefined)
// 														 techProducts[keys[keys.length-1]]=prevString+((prevString.length>0)?"<br/>":"")+offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c+":"+
// 															 offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                                                  console.log('offeringDetails inside ancestor >1-----------',offeringDetails);
												 
// 											 }else{
// 												 if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c!=undefined)
// 													 techProducts[keys[keys.length-1]]=offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c+":"+
// 														 offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                                                  console.log('offeringDetails in else-----------',offeringDetails);
// 											 }
											  
// 										 }
										 
// 									 }
// 									 //one which has no child
// 									 else{
// 										 if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c!=undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c!=undefined )
// 										 { techProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]=
// 											 offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c;
//                                           console.log('offeringDetails with no child-----------',offeringDetails);
// 										 }
										 
// 									 }
// 									 //Only Header Nodes
									 
// 									 var techsNameValue = new Object();
// 									 if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && 
// 										 offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c!=undefined &&
// 										 offeringDetails.selectedSpecifications[specIndex].Name !=undefined &&
// 										 (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_IntelTechnologies"))
// 										){
// 										 techsNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 										 Object.assign(techColumField, techsNameValue);
// 									 }
// 									 if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined &&
// 										offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && 
// 										offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c == $A.get("$Label.c.PMP_NPP_IntelTechnologies")
// 									   ){
// 										 techsNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
// 										 Object.assign(techColumField, techsNameValue);
// 									 }
									 
									 
									 
									 
// 								 }
//                         //Expertise[PSG]
//                                      else if(offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes('ExpertiseLevel1')){
//                                          if (expertiseSpec.includes(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)){
// 											if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c){
// 												expertiseValues.push(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c);
// 											}else{
// 												expertiseValues.push(offeringDetails.selectedSpecifications[specIndex].Name);
// 											}
// 										}
// 										else 
// 										{
// 											expertiseSpec = offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c;
// 											expertiseValues = [];
// 											if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c){
// 												expertiseValues.push(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c); 
// 											}else{
// 												expertiseValues.push(offeringDetails.selectedSpecifications[specIndex].Name);
// 											}    
// 										}
// 										if(expertiseValues.length > 1 && expertiseValues.includes(offeringDetails.selectedSpecifications[specIndex].Name)){
// 											var index = -1;               
// 											var index = expertiseValues.indexOf(offeringDetails.selectedSpecifications[specIndex].Name);
// 											if (index > -1) 
// 											{
// 												expertiseValues.splice(index, 1);                                                
// 											}
// 										}                                      
// 										expertise =expertiseValues.join('<br/> ');
// 										expertiseProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = expertise;
// 										var expertiseNameValue = new Object();
// 										expertiseNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
// 										Object.assign(expertiseColumnField, expertiseNameValue);
//                                      }
//                         //Industry Standards/Certifications
//                             else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c) == 'NPP_Industry_Standards_Certifications'){
//                                 insdustryStandProd[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = "Y";
//                                 var industryStandName = new Object();
//                                 industryStandName[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                                 Object.assign(industryStandColumnField, industryStandName);                        
//                             }
//                         //IP License Delivery
//                             else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c) == 'NPP_IP_License_Delivery_Method'){
//                                 ipLicenseProd[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = "Y";
//                                 var ipLicenseName = new Object();
//                                 ipLicenseName[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                                 Object.assign(ipLicenseColumnField, ipLicenseName);                        
//                             }
//                         //IP Certification
//                             else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c!=undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c != undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c) == 'NPP_IP_Certification'){
//                                 ipCertificateProd[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = "Y";
//                                 var ipCertificateName = new Object();
//                                 ipCertificateName[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                                 Object.assign(ipCertificateColumnField, ipCertificateName);                        
//                             }
	
// 					} 
//                 }
//                 //Added by raj to display countries along with regions as part of spike story
//                 /*if(countries){
//                 	for(var country of countries){
//                      	var regionValues = '';
//                     	var ancesCat = country.PMP_Ancestor_Specification_Cd__c.split('|');//splitting the ancestor to get all the parents
//                         if(ancesCat.length > 1){
//                         	for(var ancesIdx=1; ancesIdx<ancesCat.length; ancesIdx++){
//                             	var parent=regionById.get(ancesCat[ancesIdx]);//fetch the parent record from the regionById map
//                                 if(parent){//if the parent record is there append the name
//                                    var geoDetailsNameValue = new Object();
//                                    geoDetailsNameValue[parent.PMP_Product_Specification_Cd__c] =parent.Name;
//                                    Object.assign(geoDetailsColumField, geoDetailsNameValue); 
//                                 }
//                             }
//                         }
//                         regionValues = country.PMP_Specification_Nm__c + ' : ' + country.PMP_Specification_Value_Cd__c;
//                         if(regionValues!=undefined && parent && parent.PMP_Product_Specification_Cd__c!=undefined && geoDetailProducts[parent.PMP_Product_Specification_Cd__c]!=undefined)
//                                 geoDetailProducts[parent.PMP_Product_Specification_Cd__c]=geoDetailProducts[parent.PMP_Product_Specification_Cd__c]+"<br/>"+regionValues;
//                         else {
//                         	if(regionValues && parent && parent.PMP_Product_Specification_Cd__c)
//                                geoDetailProducts[parent.PMP_Product_Specification_Cd__c]=regionValues;
//                         }
//                     }
//                 }*/
//                 //Geographic Coverage-Gireesh
//                 for(var region of regionById.values()){
//                     /*if parent of current region is present in the map,push it to the child list*/
//                     if(regionChildById.has(region.PMP_Product_Specification_Cd__c)){
//                         regionChildById.get(region.PMP_Product_Specification_Cd__c).push(region); 
//                     }
//                 }
//                 if(regionChildById){//if region child map is not empty or null
//                     for(var regionId of regionChildById.keys()){//iterating over region child map
//                         var regionValues = ''; 
//                         var parent='';
//                         if(regionChildById.get(regionId).length == 1){//fetch only those regions which are at leaf node(based on selection)
//                             var region = regionById.get(regionId);//fetch the region record from regionById map
//                             var ancesCat=region.PMP_Ancestor_Specification_Cd__c.split('|');
//                             if(ancesCat.length > 1){//if the region have parent then append parent with ':'
//                                 for(var ancesIdx=1;ancesIdx<ancesCat.length;ancesIdx++){//iterate over all it's parent and append them
//                                     parent=regionById.get(ancesCat[ancesIdx]);//fetch the parent record from the regionById map
//                                     if(parent){//if the parent record is there append the name
//                                         var geoDetailsNameValue = new Object();
//                                         geoDetailsNameValue[parent.PMP_Product_Specification_Cd__c] =parent.Name;
//                                         Object.assign(geoDetailsColumField, geoDetailsNameValue);
//                                     }    
//                                 }                    
//                             }
                            
//                             regionValues = regionValues + region.Name;//append the region's name 
//                             if(regionValues!=undefined && parent && parent.PMP_Product_Specification_Cd__c!=undefined && geoDetailProducts[parent.PMP_Product_Specification_Cd__c]!=undefined)
//                                 geoDetailProducts[parent.PMP_Product_Specification_Cd__c]=geoDetailProducts[parent.PMP_Product_Specification_Cd__c]+"<br/>"+regionValues;
//                             else {
//                                 if(regionValues && parent && parent.PMP_Product_Specification_Cd__c)
//                                     geoDetailProducts[parent.PMP_Product_Specification_Cd__c]=regionValues;
//                             }
//                         }
                        
//                     }
//                 }
                
//                 industryProductsToCompare.push(industryProducts);
//                 applicationProductsToCompare.push(applicationProducts);
//                 availPriceProductsToCompare.push(availPriceProducts);
//                 geoDetailProductsToCompare.push(geoDetailProducts);
//                 essentialProductsToCompare.push(typeProducts);
//                 processorProductsToCompare.push(processorProducts);
//                 processorSocketedProductsToCompare.push(processorSocketedProducts);
//                 chipsetProductsToCompare.push(chipsetProducts);
//                 fpgaProductsToCompare.push(fpgaProducts);
//                 techProductsToCompare.push(techProducts);                       
//                 EndProductsToCompare.push(EndProducts);
//                 customerProductsToCompare.push(environmentProducts);
//                 displayProductsToCompare.push(displayProducts);
//                 deviceProductsToCompare.push(deviceProducts);
//                 osProductsToCompare.push(osProducts);
//                 batteryProductsToCompare.push(batteryProducts);
//                 dimensionProductsToCompare.push(dimensionProducts);
//                 memoryProductsToCompare.push(memoryProducts);
//                 storageProductsToCompare.push(storageProducts);
//                 wirelessProductsToCompare.push(wirelessProducts);
//                 cloudProductsToCompare.push(cloudProducts);
//                 nucProductsToCompare.push(nucProducts); //Added by Abhishek Nuc
//                 expertiseProductsToCompare.push(expertiseProducts);//Added for Expertise[PSG]
//                 industryStandsToCompare.push(insdustryStandProd);//Added for industry products
//                 ipLicenseToCompare.push(ipLicenseProd);//Added for ip License
//                 ipCertificateToCompare.push(ipCertificateProd);//Added for ip Certificate
                
//             }
            
//             //looping sections to add to columns
//             for (var secIndex = 0; secIndex < sections.length; secIndex++) {
//                 if (sections[secIndex].label == $A.get("$Label.c.PMP_Industry")) {
//                     for (var key in industryColumField) {
//                         var category = new Object();
//                         category.label = industryColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_application")) {
//                     for (var key in applicationColumField) {
//                         var category = new Object();
//                         category.label = applicationColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label ==$A.get("$Label.c.PMP_Availability_and_Pricing")) {
//                     for (var key in availPriceColumField) {
//                         var category = new Object();
//                         category.label = availPriceColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_Geo_Coverage")) {
//                     for (var key in geoDetailsColumField) {
//                         var category = new Object();
//                         category.label = geoDetailsColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_End_Customer_Type")) {
//                     for (var key in EndCustomerColumField) {
//                         var category = new Object();
//                         category.label = EndCustomerColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_Category")) {
//                     for (var key in essentialColumField) {
//                         var category = new Object();
//                         category.label = essentialColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_Processors")) {
//                     //Other processors
//                     for (var key in processorColumField) {
//                         var category = new Object();
//                         category.label = processorColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);   
//                     }
//                     //Processor socketed
//                     for (var key in processorSocketedColumnField) {
//                         var category = new Object();
//                         category.label = processorSocketedColumnField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_chipsets")) {
//                     for (var key in chipsetColumField) {
//                         var category = new Object();
//                         category.label = chipsetColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_FPGA")) {
//                     for (var key in fpgaColumField) {
//                         var category = new Object();
//                         category.label = fpgaColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_Intel_Technologies")) {
//                     for (var key in techColumField) {
//                         var category = new Object();
//                         category.label = techColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_Operating_Systems")) {
//                     for (var key in osColumField) {
//                         var category = new Object();
//                         category.label = osColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_Devices_and_Interfaces")) {
//                     for (var key in deviceColumField) {
//                         var category = new Object();
//                         category.label = deviceColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_Displays")) {
//                     for (var key in displayColumField) {
//                         var category = new Object();
//                         category.label = displayColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_Environment")) {
//                     for (var key in environmentColumField) {
//                         var category = new Object();
//                         category.label = environmentColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_Battery")) {
//                     for (var key in batteryColumnField) {
//                         var category = new Object();
//                         category.label = batteryColumnField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_Dimensions")) {
//                     for (var key in dimensionColumnField) {
//                         var category = new Object();
//                         category.label = dimensionColumnField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_Memory")) {
//                     for (var key in memoryColumnField) {
//                         var category = new Object();
//                         category.label = memoryColumnField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_Storage")) {
//                     for (var key in storageColumnField) {
//                         var category = new Object();
//                         category.label = storageColumnField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_Wireless")) {
//                     for (var key in wirelessColumnField) {
//                         var category = new Object();
//                         category.label = wirelessColumnField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 } else if (sections[secIndex].label == $A.get("$Label.c.PMP_Cloud_Services")) {
//                     for (var key in cloudColumnField) {
//                         var category = new Object();
//                         category.label = cloudColumnField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 }else if (sections[secIndex].label == $A.get("$Label.c.PMP_NUC")) { //Added by Abhishek for Nuc
//                     for (var key in nucColumField) {
//                         var category = new Object();
//                         category.label = nucColumField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 }else if (sections[secIndex].label == 'Expertise') {//Added for Expertise[PSG]
//                     for (var key in expertiseColumnField) {
//                         var category = new Object();
//                         category.label = expertiseColumnField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 }
//                 else if (sections[secIndex].label == 'Industry Standards/Certifications') {//added for industry standards
//                     for (var key in industryStandColumnField) {
//                         var category = new Object();
//                         category.label = industryStandColumnField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 }
//                 else if (sections[secIndex].label == 'IP License Delivery Method') {//added for IP License
//                     for (var key in ipLicenseColumnField) {
//                         var category = new Object();
//                         category.label = ipLicenseColumnField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 }
//                 else if (sections[secIndex].label == 'IP Certification') {//added for IP Certificates
//                     for (var key in ipCertificateColumnField) {
//                         var category = new Object();
//                         category.label = ipCertificateColumnField[key];
//                         category.fieldName = key;
//                         sections[secIndex].categories.push(category);
//                     }
//                 }
//             }
//             //copy data to productsToCompare so that all values will be displayed 
//             for (var itmIndex = 0; itmIndex < compareTrayItems.length; itmIndex++) {
//                 Object.assign(productsToCompare[itmIndex], industryProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], applicationProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], availPriceProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], geoDetailProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], EndProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], essentialProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], processorProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], processorSocketedProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], chipsetProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], fpgaProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], techProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], customerProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], displayProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], deviceProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], osProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], batteryProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], dimensionProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], memoryProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], storageProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], wirelessProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], cloudProductsToCompare[itmIndex]);
//                 Object.assign(productsToCompare[itmIndex], nucProductsToCompare[itmIndex]); //Added by Abhishek for Nuc US.
//                 Object.assign(productsToCompare[itmIndex], expertiseProductsToCompare[itmIndex]);//Added for Expertise[PSG]
//                 Object.assign(productsToCompare[itmIndex], industryStandsToCompare[itmIndex]);//Added for indsutry standards
//                 Object.assign(productsToCompare[itmIndex], ipLicenseToCompare[itmIndex]);//Added for IP License delivery
//                 Object.assign(productsToCompare[itmIndex], ipCertificateToCompare[itmIndex]);//Added for IP Certification
//                 //Assign partner information

//                 if(multiplePartnerDetails && multiplePartnerDetails.productInfo && multiplePartnerDetails.productInfo[compareTrayItems[itmIndex].id]!=undefined)
//                 {
//                     productInfo=multiplePartnerDetails.productInfo[compareTrayItems[itmIndex].id][0];
//                     console.log('productInfo--' ,productInfo);
                    
                    
//                     var partner=new Object();
//                     partner.partner=productInfo.partner;
//                     Object.assign(productsToCompare[itmIndex], partner);
//                     var contactPartnerData = new Object();
//                     contactPartnerData.Data = {
//                         autoPartnerId: productInfo.partner.autoPartnerId,
//                         contactByEmail:  false,
//                         contactByForm:  true,
//                         requestAQuote: true,
//                         offRecId:  productInfo.id,                 
//                         name:  productInfo.partner.name,
//                         oid: productInfo.autoOffId,
//                         title:productInfo.title,
//                         id:productInfo.partner.id,
//                         description:null,
//                         attributes:null,
//                         isGuest:productInfo.isGuest,
//                         leadLangPreference:productInfo.leadLangPreference,
//                         contactPartnerVisible:productInfo.contactPartnerVisible,
                        
//                     };
//                     Object.assign(productsToCompare[itmIndex], contactPartnerData);
                    
//                 }
//             }
            
//             component.set('v.productsToCompare', productsToCompare);
           
//             helper.compareGroupingSections(component, helper,sections,productsToCompare);
//             helper.addBlankSections(component, helper);           
//             component.set('v.loading', false);
//         }
        
//     },
    
//     handleToggleCheckbox: function(component, event, helper) {
        
//         //let swtch = component.find("compare1");
//         //let flag = swtch.get("v.checked");
//         //console.log("handleToggleCheckbox1", flag);
//         var value = event.currentTarget.checked;
       
//         component.set('v.highlightDifferences', value);
//     },
//     handleToggleMobileViewDetails : function(component, event, helper) {
//         component.set('v.mobileViewShowDetails', !component.get('v.mobileViewShowDetails'));
//     },
//     handleRemoveItem : function(component, event, helper) {
//         var data = event.currentTarget.dataset;
//         var index = -1;
//         var loaderIndex = false;
//         var compareTrayItems = component.get('v.compareTrayItems');
        
//         index = compareTrayItems.findIndex(function(element){
//             return element.id === data.id
//         });
//         if (index > -1 && compareTrayItems.length > 1) {
//             if (index != compareTrayItems.length -1) {
//                 component.set('v.loaderIndex', index);
//                 loaderIndex = true;
//             }
			
//             //get the item been clicked to remove
//             var removedItem=compareTrayItems[index];
            
//             //remove the item from the list
//             compareTrayItems.splice(index, 1);            
//             component.set('v.compareTrayItems', compareTrayItems);
            
//             // remove the item from the array using dispatch 
//             //helper.dispatch(component, 'toggleCompareTrayItem', { item: removedItem });

//             helper.dispatch(component, '@COMPARE_TRAY/toggleItem', { item: removedItem });
//             console.log("compare-remove-dispatched");
//             $A.enqueueAction(component.get('c.handlemultipleOfferingDetailsChange'));
            
//             /*component.set('v.mapStateToAttributes', function(state) {
//          console.log("handlemultipleOfferingDetailsChange--", JSON.stringify(state));   
//         }
//         );*/
            
//             helper.addBlankSections(component, helper);
            
//             setTimeout(function(){
                
//                 // remove loader index
//                 if (loaderIndex) {
//                     component.set('v.loaderIndex', -1);
//                 }
//             }, 1000);
            
//         }
        
//     },
    
//     handleClick: function(component, event, helper) {
//       window.history.back(); 
//     },
    
// })