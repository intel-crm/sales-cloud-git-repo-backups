({

    doInit : function(component, Event, Helper){
        component.set('v.offeringDetails',JSON.parse(JSON.stringify(component.get('v.offeringDetails'))));
        var formData= component.get("v.offeringDetails");//form data from the CreateProductsForm Component
        var action=component.get("c.getOfferingDetails");//call server to get offering details
        action.setParams({offeringId: formData.offering.Id});//passing offeringId to get all the related information
        action.setCallback(this, function(response){
            console.log('data---->',JSON.parse(response.getReturnValue()));
            var offeringInfo = JSON.parse(response.getReturnValue());
            //Variable declaration
            var product = [Object];
            var offeringDetails = [];
            var intelTechnologies = [];
            var industries = '';
            var applications = '';
            var countries = '';
            var endCustomerType = '';
            var processors = '';
            var chipsets = '';
            var FPGAs = '';
            var includedIntelTechnologies = '';
            var devicesAndInterfaces = '';
            var environment='';
            var memory = '';
            var operatingSystems = '';
            console.log('outside if');
            //To Do : move all constants to custom labels
            if(offeringInfo.OfferingDetail){//if the offering details entered are not null
                console.log('eventname----->',component.get('v.offeringName'));
                console.log('detailname---->',offeringInfo.OfferingDetail.PMP_Partner_Offering_Nm__c);
                //populating offering Name from the value received from event
                if(component.get('v.offeringName') != null){
                    product.push({categoryLabel : $A.get("$Label.c.PMP_Offering_Name"), value : component.get('v.offeringName')});
                }
                else if(offeringInfo.OfferingDetail.PMP_Partner_Offering_Nm__c != null ){
                    product.push({categoryLabel : $A.get("$Label.c.PMP_Offering_Name"), value : offeringInfo.OfferingDetail.PMP_Partner_Offering_Nm__c});
                }
                if(offeringInfo.OfferingDetail.PMP_Company_Id__c != undefined){
                    offeringDetails.push({label : $A.get("$Label.c.PMP_Offered_By"), value : offeringInfo.OfferingDetail.PMP_Company_Id__r.Name});
                }
                if(offeringInfo.OfferingDetail.PMP_Partner_Offering_Visibility_Nm__c != undefined){
                    offeringDetails.push({label : $A.get("$Label.c.PMP_Offering_Visibility"), value : offeringInfo.OfferingDetail.PMP_Partner_Offering_Visibility_Nm__c});
                }
                if(offeringInfo.OfferingDetail.PMP_Partner_Offering_Start_Dt__c != undefined){
                    offeringDetails.push({label : $A.get("$Label.c.Core_PMP_StartDate"), value : offeringInfo.OfferingDetail.PMP_Partner_Offering_Start_Dt__c});
                }
                if(offeringInfo.OfferingDetail.PMP_Partner_Offering_End_Dt__c != undefined){
                    offeringDetails.push({label : $A.get("$Label.c.Core_PMP_EndDate"), value : offeringInfo.OfferingDetail.PMP_Partner_Offering_End_Dt__c});
                }
               	if(offeringInfo.OfferingDetail.PMP_Partner_Offering_Tag_Line_Txt__c != undefined){
                    offeringDetails.push({label : $A.get("$Label.c.PMP_Tag_Line"), value : offeringInfo.OfferingDetail.PMP_Partner_Offering_Tag_Line_Txt__c});
                }
            }
            
            if(offeringInfo.selectedCategories){//if the selected categories are not null
               //processing all the selected categories and storing it into seperate variables
                for(var category of offeringInfo.selectedCategories){
                    if(category.ancestorId != null){
                        var ancesKey = category.ancestorId.split('|');
                        if(ancesKey.length == 1 && ancesKey[0] == $A.get("$Label.c.PMP_NPP_01_TYPE")){
                           offeringDetails.push({label : $A.get("$Label.c.PMP_Category"), value :category.localName});                           
                        }
                        else if(ancesKey.length == 2 && ancesKey.includes($A.get("$Label.c.PMP_NPP_01_TYPE"))){
                           offeringDetails.push({label : $A.get("$Label.c.PMP_Sub_Category"), value :category.localName});                           
                        }
                        else if(ancesKey.length == 3 && ancesKey.includes($A.get("$Label.c.PMP_NPP_01_TYPE"))){
                           offeringDetails.push({label : $A.get("$Label.c.PMP_Sub_Category_Level2"), value :	category.localName});                            
                        }
                        else if(category.ancestorId === $A.get("$Label.c.PMP_NPP_01_Industry")){
                              industries += category.localName + ', ';  
                        }
                        else if(category.ancestorId === $A.get("$Label.c.PMP_NPP_01_APP")){
                            applications += category.localName + ', ';
                        }                         
                    }                    
                }
                if(industries != ''){//If any industry selected display the label and value
                    offeringDetails.push({label : $A.get("$Label.c.Core_PMP_Industries"), value : industries.substr(0, industries.length-2)});
                }
                if(applications != ''){//If any application selected display label and value
                    offeringDetails.push({label : $A.get("$Label.c.PMP_Applications"), value : applications.substr(0, applications.length-2)});
                }
            }
            
            if(offeringInfo.selectedSpecifications){//if the selected specifications are not null
               //processing all the selected specifications and storing it into seperate variables 
               for(var spec of offeringInfo.selectedSpecifications){
                   if(spec.ancestorId != null){
                       var ancesKey = spec.ancestorId.split('|');
                       if(spec.ancestorId.includes($A.get("$Label.c.PMP_NPP_GeographicCoverage"))){
                           countries += spec.localSpecName + ',';
                       }
                       else if(spec.ancestorId === $A.get("$Label.c.PMP_NPP_Processors") &&
                              spec.localSpecValueName == null){
                           processors += spec.localSpecName + ',';
                       }
                       else if(spec.localSpecValueName != null && 
                               spec.ancestorId != $A.get("$Label.c.PMP_NPP_IntelTechnologies")){
                           intelTechnologies.push({label : spec.localSpecName, value : spec.localSpecValueName});
                       }
                       else if(spec.ancestorId === $A.get("$Label.c.PMP_NPP_Chipsets")){
                           chipsets += spec.localSpecName + ',';    
                       }
                       else if(spec.ancestorId === $A.get("$Label.c.PMP_NPP_FPGA")){
                           FPGAs += spec.localSpecName + ',';    
                       }
                       else if(spec.ancestorId === $A.get("$Label.c.PMP_NPP_IntelTechnologies")){
                          includedIntelTechnologies += spec.localSpecName + ',';    
                       }
                       else if(spec.ancestorId === $A.get("$Label.c.PMP_DevicesandInterfacesLevel1")){
                          devicesAndInterfaces += spec.localSpecName + ',';    
                       }
                       else if(spec.ancestorId === $A.get("$Label.c.PMP_EnvironmentLevel1")){
                          environment += spec.localSpecName + ',';    
                       }
                       else if(spec.ancestorId === $A.get("$Label.c.PMP_MemoryLevel1") && 
                              spec.localSpecValueName == null){
                          memory += spec.localSpecName + ',';    
                       }                        
                   }
                   //if the specification is EndCustomerType store the specification value as value for UI
                   if(spec.specificationId === $A.get("$Label.c.PMP_NPP_EndCustomerType")){
                           endCustomerType += spec.localSpecValueName + ',';
                   }
                   //if the specification is OperationSystems store the specification value as value for UI
                   if(spec.ancestorId === $A.get("$Label.c.PMP_NPP_OperationSystems")){
                           operatingSystems += spec.localSpecName + ',';
                   }                   
                }
                if(countries != ''){//If any Country selected display the label and value
                    offeringDetails.push({label : $A.get("$Label.c.PMP_Country"), value : countries.substr(0, countries.length-1)});
                }
                if(endCustomerType != ''){//If any End Customer Type selected display the label and value
                    offeringDetails.push({label : $A.get("$Label.c.PMP_End_Customer_Type"), value : endCustomerType.substr(0, endCustomerType.length-1)});
                }
                if(processors != ''){//If any Processor selected display the label and value
                    intelTechnologies.push({label : $A.get("$Label.c.PMP_Processors"), value : processors.substr(0, processors.length-1)});
                }
                if(chipsets != ''){//If any Chipsets selected display the label and value
                    intelTechnologies.push({label : $A.get("$Label.c.PMP_chipsets"), value : chipsets.substr(0, chipsets.length-1)});
                }
                if(FPGAs != ''){//If any FPGAs selected display the label and value
                    intelTechnologies.push({label : $A.get("$Label.c.PMP_FPGA"), value : FPGAs.substr(0, FPGAs.length-1)});
                }
                if(includedIntelTechnologies != ''){//If any Included Intel Technologies selected display the label and value
                    intelTechnologies.push({label : $A.get("$Label.c.PMP_Create_Offering_Form_STEP2"), value : includedIntelTechnologies.substr(0, includedIntelTechnologies.length-1)});
                }
                if(devicesAndInterfaces != ''){//If any Devices And Interfaces selected display the label and value
                    intelTechnologies.push({label : $A.get("$Label.c.PMP_Devices_and_Interfaces"), 
                                            value : devicesAndInterfaces.substr(0, devicesAndInterfaces.length-1)});
                }
                if(environment != ''){//If any Environment selected display the label and value
                    intelTechnologies.push({label : $A.get("$Label.c.PMP_Environment"), value : environment.substr(0, environment.length-1)});
                }
                if(memory != ''){//If any Memory selected display the label and value
                    intelTechnologies.push({label : $A.get("$Label.c.PMP_Memory"), value : memory.substr(0, memory.length-1)});
                }
                if(operatingSystems != ''){//If any Operating Systems selected display the label and value
                    intelTechnologies.push({label : $A.get("$Label.c.PMP_Operating_Systems"), value : operatingSystems.substr(0, operatingSystems.length-1)});
                }
            }
            if(offeringDetails.length > 0){//if offering details list is not empty display label and values
                product.push({categoryLabel: $A.get("$Label.c.PMP_Offering_Details"), listing: offeringDetails});
            }
            if(intelTechnologies.length > 0){//if intelTechnologies list is not empty display label and values
                product.push({categoryLabel: $A.get("$Label.c.Core_PMP_Specifications"), listing: intelTechnologies});
            }
            component.set('v.details',product);//set the details object with the product object populated with the selected/entered values
        });
        $A.enqueueAction(action);
    },
    
    handleToggleIsOpen : function(component, event, helper) {
		component.set('v.isOpen', !component.get('v.isOpen'));
	},
    
    handleNameEntered : function(component, event, helper){
        var name=JSON.parse(JSON.stringify(event.getParams("offeringName")));
        component.set("v.offeringName",name.offeringName);
        component.reInit();
    }

})