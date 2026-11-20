({})

//     doInit : function(component, Event, Helper){
//         component.set('v.offeringDetails',JSON.parse(JSON.stringify(component.get('v.offeringDetails'))));
//         var formData= component.get("v.offeringDetails");//form data from the CreateProductsForm Component
//         var action=component.get("c.getOfferingDetails");//call server to get offering details
//         action.setParams({offeringId: formData.offering.Id});//passing offeringId to get all the related information
//         action.setCallback(this, function(response){
//             console.log('data---->',JSON.parse(response.getReturnValue()));
//             var offeringInfo = JSON.parse(response.getReturnValue());
//             //variable declaration
//             var product = [];
//             var offeringDetails = [];
//             var intelTechnologies = [];
//             var offresources = [];
//             var offaddresources = [];
//             var industries = '';
//             var applications = '';
//             var countries = '';
//             var endCustomerType = '';
//             var processors = '';
//             var graphics = '';
//             var softwarelibrary = '';
//             var aimodeltraining = '';
//             var aifunctionality ='';
//             var cloudservices = '';
//             var topology = '';
//             var deeplearningframework = '';
//             var toolkit = '';
//             var solutionavailability = '';
//             var vpu = '';
//             var chipsets = '';
//             var FPGAs = '';
//             var wireless = '';
//             var includedIntelTechnologies = '';
//             var devicesAndInterfaces = '';
//             var environment='';
//             var memory = '';
//             var operatingSystems = '';
//             var subCategory = '';
//             var subCategoryLevel2 = '';
//             var intelTechMap = {};
//             var fileLabel = $A.get("$Label.c.PMP_FileAssetExt");
//             //To Do : move all constants to custom labels
//             if(offeringInfo.OfferingDetail){//if the offering details entered are not null
//                 console.log('eventname----->',component.get('v.offeringName'));
//                 console.log('detailname---->',offeringInfo.OfferingDetail.PMP_Partner_Offering_Nm__c);
//                 //populating offering Name from the value received from event
//                 if(component.get('v.offeringName') != null){
//                     product.push({categoryLabel : $A.get("$Label.c.PMP_Offering_Name"), value : component.get('v.offeringName')});
//                 }
//                 else if(offeringInfo.OfferingDetail.PMP_Partner_Offering_Nm__c != null ){
//                     product.push({categoryLabel : $A.get("$Label.c.PMP_Offering_Name"), value : offeringInfo.OfferingDetail.PMP_Partner_Offering_Nm__c});
//                 }
//                 if(offeringInfo.OfferingDetail.PMP_Company_Id__c != undefined){
//                     offeringDetails.push({label : $A.get("$Label.c.PMP_Offered_By"), value : offeringInfo.OfferingDetail.PMP_Company_Id__r.Name});
//                 }
//                 if(offeringInfo.OfferingDetail.PMP_Partner_Offering_Visibility_Nm__c != undefined){
//                     offeringDetails.push({label : $A.get("$Label.c.PMP_Offering_Visibility"), value : offeringInfo.OfferingDetail.PMP_Partner_Offering_Visibility_Nm__c});
//                 }
//                 if(offeringInfo.OfferingDetail.PMP_Partner_Offering_Start_Dt__c != undefined){
//                     offeringDetails.push({label : $A.get("$Label.c.Core_PMP_StartDate"), value : offeringInfo.OfferingDetail.PMP_Partner_Offering_Start_Dt__c});
//                 }
//                 if(offeringInfo.OfferingDetail.PMP_Partner_Offering_End_Dt__c != undefined){
//                     offeringDetails.push({label : $A.get("$Label.c.Core_PMP_EndDate"), value : offeringInfo.OfferingDetail.PMP_Partner_Offering_End_Dt__c});
//                 }
//                	if(offeringInfo.OfferingDetail.PMP_Partner_Offering_Tag_Line_Txt__c != undefined){
//                     offeringDetails.push({label : $A.get("$Label.c.PMP_Tag_Line"), value : offeringInfo.OfferingDetail.PMP_Partner_Offering_Tag_Line_Txt__c});
//                 }
//                 if(offeringInfo.OfferingDetail.PMP_Partner_Offering_Dsc__c != undefined){
//                     var desc = offeringInfo.OfferingDetail.PMP_Partner_Offering_Dsc__c;
//                     let strippeddesc = desc.replace(/(<([^>]+)>)/gi, "");
//                     offeringDetails.push({label : $A.get("$Label.c.PMP_Description"), value : strippeddesc});
//                 }
//             }
            
//             if(offeringInfo.selectedCategories){//if the selected categories are not null
//                //processing all the selected categories and storing it into seperate variables
//                 for(var category of offeringInfo.selectedCategories){
//                     if(category.ancestorId != null){
//                         var ancesKey = category.ancestorId.split('|');
//                         if(ancesKey.length == 1 && ancesKey[0] == $A.get("$Label.c.PMP_NPP_01_TYPE")){
//                            offeringDetails.push({label : $A.get("$Label.c.PMP_Category"), value :category.localName});                           
//                         }
//                         else if(ancesKey.length == 2 && ancesKey.includes($A.get("$Label.c.PMP_NPP_01_TYPE"))){
//                                 subCategory += category.localName + ', ';   
//                         }
//                         else if(ancesKey.length == 3 && ancesKey.includes($A.get("$Label.c.PMP_NPP_01_TYPE"))){
//                                subCategoryLevel2 = category.localName;                            
//                         }
//                         else if(category.ancestorId.includes($A.get("$Label.c.PMP_NPP_01_Industry"))){
//                               industries += category.localName + ', ';  
//                         }
//                         else if(category.ancestorId.includes($A.get("$Label.c.PMP_NPP_01_APP"))){
//                             applications += category.localName + ', ';
//                         }                         
//                     }                    
//                 }
//                 if(subCategory != ''){
//                    offeringDetails.push({label : $A.get("$Label.c.PMP_Sub_Category"), value : subCategory.substr(0, subCategory.length-2)}); 
//                 }
//                 if(subCategoryLevel2!=''){
//                     offeringDetails.push({label : $A.get("$Label.c.PMP_Sub_Category_Level2"), value : subCategoryLevel2});
//                 }
//                 if(industries != ''){//If any industry selected display the label and value
//                     offeringDetails.push({label : $A.get("$Label.c.Core_PMP_Industries"), value : industries.substr(0, industries.length-2)});
//                 }
//                 if(applications != ''){//If any application selected display label and value
//                     offeringDetails.push({label : $A.get("$Label.c.PMP_Applications"), value : applications.substr(0, applications.length-2)});
//                 }
                
//             }

//             if(offeringInfo.selectedSpecifications){//if the selected specifications are not null
//                 //processing all the selected specifications and storing it into seperate variables 
//                 for(var spec of offeringInfo.selectedSpecifications){
//                     if(spec.ancestorId != null){
//                         var ancesKey = spec.ancestorId.split('|');
//                         if(spec.ancestorId.includes($A.get("$Label.c.PMP_NPP_GeographicCoverage"))){
//                             if(!spec.localSpecValueName){
//                                  countries += spec.localSpecName + ',';
//                             }else{
//                                  countries += spec.localSpecValueName + ',';
//                             }    
//                         }
//                         else if(spec.ancestorId === $A.get("$Label.c.PMP_NPP_Processors") &&
//                                spec.localSpecValueName == null){
//                             processors += spec.localSpecName + ',';
//                         }
// 			else if(spec.ancestorId === $A.get("$Label.c.PMP_NPP_Graphics") &&
//                            spec.localSpecValueName == null){
//                          graphics += spec.localSpecName + ',';
//                         }
//                          //if the specification is OperationSystems store the specification value as value for UI
//                         else if(spec.ancestorId.includes($A.get("$Label.c.PMP_NPP_OperationSystems"))){
//                            if(spec.localSpecName!=null && spec.localSpecValueName == null) {
//                               operatingSystems += spec.localSpecName + ',';
//                           } else {
//                                 operatingSystems += spec.localSpecValueName + ','; 
//                                 }
//                              }      
//                         else if(spec.ancestorId === $A.get("$Label.c.PMP_NPP_Chipsets")){
//                             chipsets += spec.localSpecName + ',';    
//                         }
//                         else if(spec.ancestorId === $A.get("$Label.c.PMP_NPP_FPGA")){
//                             FPGAs += spec.localSpecName + ',';    
//                         }
//                         else if(spec.ancestorId === $A.get("$Label.c.PMP_NPP_IntelTechnologies")){
//                                  if(intelTechMap[spec.localSpecName]!=null){  
//                                      if(spec.localSpecValueName!=null&&spec.localSpecValueName!=''){ 
//                                          intelTechMap[spec.localSpecName].push(spec.localSpecValueName);
//                                      }
//                                  }
//                                  else{
//                                      let temparr = [];
//                                      intelTechMap[spec.localSpecName] = temparr;
//                                      if(spec.localSpecValueName!=null&&spec.localSpecValueName!=''){
//                                          intelTechMap[spec.localSpecName].push(spec.localSpecValueName);
//                                      }
//                                  }                          
                             
//                         }
//                         else if(spec.ancestorId === $A.get("$Label.c.PMP_DevicesandInterfacesLevel1")){
//                            devicesAndInterfaces += spec.localSpecName + ',';    
//                         }
//                         else if(spec.ancestorId === $A.get("$Label.c.PMP_EnvironmentLevel1")){
//                            environment += spec.localSpecName + ',';    
//                         }
//                         else if(spec.ancestorId === $A.get("$Label.c.PMP_MemoryLevel1") && 
//                                spec.localSpecValueName == null){
//                            memory += spec.localSpecName + ',';    
//                         } else if(spec.ancestorId === $A.get("$Label.c.PMP_AIFunctionalityLevel1")) {
//                            if(spec.localSpecName!=null && spec.localSpecValueName == null) {
//                              aifunctionality += spec.localSpecName + ',';
//                            } else {
//                              aifunctionality += spec.localSpecValueName + ','; 
//                            }
//                         } else if(spec.ancestorId === $A.get("$Label.c.PMP_WirelessLevel1")) {
//                          if(spec.localSpecName!=null && spec.localSpecValueName == null) {
//                            wireless += spec.localSpecName + ',';
//                          } else {
//                              wireless += spec.localSpecValueName + ','; 
//                          }
//                       }
//                        else if(spec.localSpecValueName != null) {
//                                      intelTechnologies.push({label : spec.localSpecName, value : spec.localSpecValueName});
//                         }		 
//                     }
//                     //if the specification is EndCustomerType store the specification value as value for UI
//                     if(spec.specificationId === $A.get("$Label.c.PMP_NPP_EndCustomerType")){
//                             endCustomerType += spec.localSpecValueName + ',';
//                     }  if(spec.specificationId === $A.get("$Label.c.PMP_NPP_VPU")){
//                              vpu += spec.localSpecValueName + ',';
//                     }  if(spec.specificationId === $A.get("$Label.c.PMP_NPP_Topology")){
//                             topology += spec.localSpecValueName + ',';
//                     }  if(spec.specificationId === $A.get("$Label.c.PMP_NPP_Toolkit")){
//                              toolkit += spec.localSpecValueName + ',';
//                     }  if(spec.specificationId === $A.get("$Label.c.PMP_NPP_SolutionAvailability")){
//                              solutionavailability += spec.localSpecValueName + ',';
//                     }  if(spec.specificationId === $A.get("$Label.c.PMP_NPP_SoftwareLibrary")){
//                              softwarelibrary += spec.localSpecValueName + ',';
//                     }  if(spec.specificationId === $A.get("$Label.c.PMP_NPP_DeepLearningFramework")){
//                             deeplearningframework += spec.localSpecValueName + ',';
//                     }  if(spec.specificationId === $A.get("$Label.c.PMP_NPP_AlModelTraining")){
//                             aimodeltraining += spec.localSpecValueName + ',';
//                     }  if(spec.specificationId === $A.get("$Label.c.PMP_NPP_Cloud_Services")){
//                           cloudservices += spec.localSpecValueName + ',';
//                     }             
//                  }
//                  for(let keyValue of Object.entries(intelTechMap).sort()){
//                      if(keyValue[1].length==0){
//                          includedIntelTechnologies = includedIntelTechnologies+ keyValue[0]+',';
//                      } else {    
//                          includedIntelTechnologies = includedIntelTechnologies+ keyValue[0]+','+keyValue[1]+',';
//                      }
//                  }
                 
//                  if(countries != ''){//If any Country selected display the label and value
//                      offeringDetails.push({label : $A.get("$Label.c.PMP_Country"), value : countries.substr(0, countries.length-1)});
//                  }
//                  if(endCustomerType != ''){//If any End Customer Type selected display the label and value
//                      offeringDetails.push({label : $A.get("$Label.c.PMP_End_Customer_Type"), value : endCustomerType.substr(0, endCustomerType.length-1)});
//                  }
//                  if(processors != ''){//If any Processor selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_Processors"), value : processors.substr(0, processors.length-1)});
//                  }
// 		 if(graphics != ''){//If any Graphics selected display the label and value
//                     intelTechnologies.push({label : $A.get("$Label.c.PMP_Graphics"), value : graphics.substr(0, graphics.length-1)});
//                 }
//                  if(chipsets != ''){//If any Chipsets selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_chipsets"), value : chipsets.substr(0, chipsets.length-1)});
//                  }
//                  if(FPGAs != ''){//If any FPGAs selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_FPGA"), value : FPGAs.substr(0, FPGAs.length-1)});
//                  }
//                  if(vpu != ''){//If any vpu selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_VPU"), value : vpu.substr(0, vpu.length-1)});
//                  }
//                  if(topology != ''){//If any topology selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_Topology"), value : topology.substr(0, topology.length-1)});
//                  }
//                  if(toolkit != ''){//If any toolkit selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_Toolkit"), value : toolkit.substr(0, toolkit.length-1)});
//                  }
//                  if(solutionavailability != ''){//If any solutionavailability selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_SolutionAvailability"), value : solutionavailability.substr(0, solutionavailability.length-1)});
//                  }
//                  if(softwarelibrary != ''){//If any softwarelibrary selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_SoftwareLibrary"), value : softwarelibrary.substr(0, softwarelibrary.length-1)});
//                  }
//                  if(deeplearningframework != ''){//If any deeplearningframework selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_DeepLearningFramework"), value : deeplearningframework.substr(0, deeplearningframework.length-1)});
//                  }
//                  if(aimodeltraining != ''){//If any aimodeltraining selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_AlModelTraining"), value : aimodeltraining.substr(0, aimodeltraining.length-1)});
//                  }
//                  if(aifunctionality != ''){//If any aifunctionality selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_AI_Functionality_AI_Training"), value : aifunctionality.substr(0, aifunctionality.length-1)});
//                  }
//                  if(cloudservices != ''){//If any cloudservices selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_Cloud_Services"), value : cloudservices.substr(0, cloudservices.length-1)});
//                  }
//                  if(wireless != ''){//If any wireless selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_Wireless"), value : wireless.substr(0, wireless.length-1)});
//                  }
//                  if(includedIntelTechnologies != ''){//If any Included Intel Technologies selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_Create_Offering_Form_STEP2"), value : includedIntelTechnologies.substr(0, includedIntelTechnologies.length-1)});
//                  }
//                  if(devicesAndInterfaces != ''){//If any Devices And Interfaces selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_Devices_and_Interfaces"), 
//                                              value : devicesAndInterfaces.substr(0, devicesAndInterfaces.length-1)});
//                  }
//                  if(environment != ''){//If any Environment selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_Environment"), value : environment.substr(0, environment.length-1)});
//                  }
//                  if(memory != ''){//If any Memory selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_Memory"), value : memory.substr(0, memory.length-1)});
//                  }
//                  if(operatingSystems != ''){//If any Operating Systems selected display the label and value
//                      intelTechnologies.push({label : $A.get("$Label.c.PMP_Operating_Systems"), value : operatingSystems.substr(0, operatingSystems.length-1)});
//                  }
//              }

//             if(offeringInfo.media){//if the selected resources are not null
//                 //processing all the selected resources and storing it into seperate variables 
//              offresources = offeringInfo.media;
//              if(typeof(offeringInfo.media) !=  "undefined"){
//                 offresources = offresources.map((img, idx) => ({
//                     accountId: img.accountId === null ? null : img.accountId, 
//                     videoId: img.videoId === null ? null : img.videoId,
//                     videoType: img.videoType === null ? null : img.videoType,
//                     title: img.title === null ? null : img.title,
//                     imageUrl: img.imageUrl === null? null : (img.videoId === null ? fileLabel +`${img.imageUrl}?isOptimized=false`:img.imageUrl), 
//                     thumbnailUrl: img.thumbnailUrl === null ? null : fileLabel +`${img.thumbnailUrl || img.imageUrl}?isOptimized=false`,
//                     videoThumbnailUrl: img.videoThumbnailUrl === null ? null : img.videoThumbnailUrl,
//                     description: img.description === null ? null : img.description,
//                     placeholder1920px: img.placeholder1920px === null ? null : img.placeholder1920px,
//                     placeholder246px: img.placeholder246px === null ? null : img.placeholder246px,
//                     altText: img.altText === null ? null : img.altText,
//                     }));
//              }else {
//                 offresources = [];
//              }
//             }
//             if(offeringInfo.offeringResources){
//                if(typeof(offeringInfo.offeringResources)!='undefined'){
//                   offaddresources = offeringInfo.offeringResources;
//                }else{
//                   offaddresources = [];
//                }
//             }
//             if(offeringDetails.length > 0){//if offering details list is not empty display label and values
//                 product.push({categoryLabel: $A.get("$Label.c.PMP_Offering_Details"), listing: offeringDetails});
//             }
//             if(intelTechnologies.length > 0){//if intelTechnologies list is not empty display label and values
//                 product.push({categoryLabel: $A.get("$Label.c.Core_PMP_Specifications"), listing: intelTechnologies});
//             }
//             component.set('v.details',product);//set the details object with the product object populated with the selected/entered values
//             component.set('v.resourcedetails',offresources);
//             component.set('v.addresourcedetails',offaddresources);
//         });
//         $A.enqueueAction(action);
//     },

//     handleModalOpen : function(component, event, helper) {
//           window.setTimeout(() => {
//             document.body.style.overflow = 'auto';
//           }, 20);
//     },
    
//     handleToggleIsOpen : function(component, event, helper) {
// 		component.set('v.isOpen', !component.get('v.isOpen'));
// 	},
    
//     handleNameEntered : function(component, event, helper){
//         var name=JSON.parse(JSON.stringify(event.getParams("offeringName")));
//         component.set("v.offeringName",name.offeringName);
//         component.reInit();
//     }

// })