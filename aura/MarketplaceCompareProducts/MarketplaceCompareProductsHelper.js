({})
    
//     addBlankSections: function(component, helper) {
//         var productsToCompare = component.get("v.productsToCompare");
//         var maxProductsCount = component.get("v.maxProducts");
        
//         var productsToAdd = maxProductsCount - productsToCompare.length;
//         console.log(productsToCompare.length, maxProductsCount, productsToAdd);
//         var fillerArray = [];
//         for (var i = 0; i < productsToAdd; i++) {
//             fillerArray.push(i);
//         }
        
//         component.set("v.blankProductsToAdd", fillerArray);
//         // Add Blank Sections to fill up < 4 gap
//     },
//     compareGroupingSections: function(component, helper,sections,productsToCompare) {
//         var groups=[];
//         var labels=[$A.get("$Label.c.PMP_Category"), $A.get("$Label.c.PMP_Create_Offering_Form_STEP2"), $A.get("$Label.c.PMP_Market_Info"), 
//                     $A.get("$Label.c.PMP_Technical_Specs")];
        
//         var groupingSections=[];
        
//         //new group section
//         for(var grpSectionsIndex=0;grpSectionsIndex<labels.length;grpSectionsIndex++){
//             var groupingSection=new Object();
//             var sectionsFinal=[];
//             //groupingSection.label=labels[grpSectionsIndex];
//             if(labels[grpSectionsIndex]==$A.get("$Label.c.PMP_Category")){
//                 groupingSection.groupNames=[$A.get("$Label.c.PMP_Category")];
//                 groupingSection.groupLabel='';
//             }  
//             else if(labels[grpSectionsIndex]==$A.get("$Label.c.PMP_Create_Offering_Form_STEP2")){
//                 groupingSection.groupNames=[$A.get("$Label.c.PMP_Processors"),$A.get("$Label.c.PMP_chipsets"), $A.get("$Label.c.PMP_FPGA"),
//                                             $A.get("$Label.c.PMP_Intel_Technologies"),$A.get("$Label.c.PMP_NUC")];
//                 groupingSection.groupLabel=$A.get("$Label.c.PMP_Create_Offering_Form_STEP2");
                
//             }
            
//                 else if(labels[grpSectionsIndex]==$A.get("$Label.c.PMP_Market_Info")){
//                     groupingSection.groupNames=[$A.get("$Label.c.PMP_Industry"), $A.get("$Label.c.PMP_application"), $A.get("$Label.c.PMP_Availability_and_Pricing"),$A.get("$Label.c.PMP_Geo_Coverage")];
//                     groupingSection.groupLabel=$A.get("$Label.c.PMP_Market_Info");
//                 }
            
//                     else if(labels[grpSectionsIndex]==$A.get("$Label.c.PMP_Technical_Specs"))
//                     {
//                         groupingSection.groupNames=[$A.get("$Label.c.PMP_End_Customer_Type"), $A.get("$Label.c.PMP_Operating_Systems"), $A.get("$Label.c.PMP_Displays"),$A.get("$Label.c.PMP_Battery"), 
//                                                     $A.get("$Label.c.PMP_Dimensions"), $A.get("$Label.c.PMP_Memory"), $A.get("$Label.c.PMP_Storage"),
//                                                     $A.get("$Label.c.PMP_Wireless"),  $A.get("$Label.c.PMP_Devices_and_Interfaces"), $A.get("$Label.c.PMP_Environment"), 
//                                                     $A.get("$Label.c.PMP_Cloud_Services"),
//                                                     $A.get("$Label.c.PMP_Expertise"), $A.get("$Label.c.PMP_Industry_Standards"), 
//                                                     $A.get("$Label.c.PMP_IP_Certification"), $A.get("$Label.c.PMP_IP_License")];  
//                         groupingSection.groupLabel=$A.get("$Label.c.PMP_Technical_Specs");
                        
//                     }
            
//             groupingSection.sections=sectionsFinal;
//             groupingSections.push(groupingSection);
            
//         }
        
        
//         //new group section
//         for(var index=0;index<sections.length;index++){
//             for(var grpSectionsIndex=0;grpSectionsIndex<groupingSections.length;grpSectionsIndex++){
//                 if(groupingSections[grpSectionsIndex].groupNames.length >0 && groupingSections[grpSectionsIndex].groupNames.includes(sections[index].label)){
//                     groupingSections[grpSectionsIndex].sections.push(sections[index]);
//                 }
//             } 
//         }
//         //new group section end
        
//         // UI DATA new group section            
//         var outputGroupingSections = groupingSections.map(function(group) {
            
//             return {
//                 groupLabel: group.groupLabel,
//                 sections: group.sections.map(function(section){
//                     return Object.assign(section, {
//                         dataRows: section.categories.map(function(cat) {
//                             var values = productsToCompare.map(function(product) {
//                                 return product[cat.fieldName];
//                             });
//                             var areDifferent = false;
                            
//                             values.reduce(function(value1, value2) {
//                                 if ((value1 || value2) && value1 != value2) areDifferent = true;
//                                 return value2;
//                             });
//                             return {
//                                 highlight: areDifferent,
//                                 label: cat.label,
//                                 info: cat.infoTooltip,
//                                 data: values
//                             };
//                         })
//                     });
//                 })
//             }
            
//         });
//         component.set("v.sectionGrouping", outputGroupingSections);
//     },
    
    
// })