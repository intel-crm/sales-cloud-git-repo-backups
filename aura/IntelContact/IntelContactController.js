({
    doInit : function(component, event, helper) {

        	var locale = $A.get("$Locale.language");

       		

            var mockCategories = {
            title: $A.get("$Label.c.PMP_contact_intel_Heading"),
            listing: [
                { label: $A.get("$Label.c.PMP_contact_intel_Email"), copy: $A.get("$Label.c.PMP_Request_Support_SubHeading"), ctaUrl: $A.get("$Label.c.PMP_Request_Support_URL"), ctaCopy:$A.get("$Label.c.PMP_contact_intel_CTA_Email_SubHeading"), imgUrl:$A.get('$Resource.PMP_Contact_us_RequestSupport')},
                { label: $A.get("$Label.c.PMP_contact_intel_Chat"), copy:$A.get("$Label.c.PMP_contact_intel_Chat_Sub_Heading"), ctaUrl: $A.get("$Label.c.PMP_Chat_URL"), ctaCopy:$A.get("$Label.c.PMP_contact_intel_CTA_Chat_SubHeading"), imgUrl:$A.get('$Resource.PMP_Contact_us_Chat')},
                { label: $A.get("$Label.c.PMP_contact_intel_Phone"), copy:$A.get("$Label.c.PMP_contact_intel_Phone_subheading"), ctaUrl: $A.get("$Label.c.PMP_Phone_URL"), ctaCopy:$A.get("$Label.c.PMP_contact_intel_CTA_Sub_Heading"), imgUrl:$A.get('$Resource.PMP_Contact_us_Phone')},
                
               	]
           }
                
             if($A.get("$SObjectType.CurrentUser.Email") != undefined){
                	component.set('v.listing', mockCategories.listing);
                	component.set('v.title', mockCategories.title);
                }
    
     }
})