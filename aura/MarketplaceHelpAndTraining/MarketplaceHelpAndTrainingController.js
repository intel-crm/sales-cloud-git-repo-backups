({
    doInit : function(component, event, helper) {
        //component.set('v.loading', true);
        var mockCategories = {
            title: '',
            subtitle: '',
            listing: [],
            CTA: '',
            CTAUrl: null,
            viewAllHeadline: '',
            viewMoreLinkTitle: ''
        }
          var pageType = component.get('v.pageType');
          var userLanguage = $A.get("$Locale.langLocale");
        
        if(userLanguage === 'zh_CN')
        {
         	var publicationGuidelinelink = $A.get("$Label.c.PMP_Help_Training_Content10_ContentURL_zh_CN") ;
        }
         else if(userLanguage === 'ja')
         {
          	var publicationGuidelinelink = $A.get("$Label.c.PMP_Help_Training_Content10_ContentURL_JA");  
         }
             else{
                 	var publicationGuidelinelink = $A.get("$Label.c.PMP_Help_Training_Content10_ContentURL_en_us") ;
             	 }
        
        
        	/*var finalData = [];
        	 console.log('Logged in user ='+$A.get("$SObjectType.CurrentUser.Email"));
                    if($A.get("$SObjectType.CurrentUser.Email") === undefined){
                        console.log('Coming in guest user');
            				 mockCategories.listing = 
                                   { label: $A.get("$Label.c.PMP_Help_Training_Content1_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content1_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content1_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content1_VideoURL"), descriptionLinkTarget: '_new'},                    
                    				finalData.push(mockCategories.listing);
                   		     mockCategories.listing =   
 
									{ label: $A.get("$Label.c.PMP_Help_Training_Content4_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content4_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content4_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content4_VideoURL"), descriptionLinkTarget: '_new'},
                             finalData.push(mockCategories.listing);
                                     
                    }           	
  			    else
					{
                             mockCategories.listing = 
                
                                    { label: $A.get("$Label.c.PMP_Help_Training_Content1_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content1_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content1_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content1_VideoURL"), descriptionLinkTarget: '_new'},
								    finalData.push(mockCategories.listing);
                   		     mockCategories.listing =   
 
									{ label: $A.get("$Label.c.PMP_Help_Training_Content2_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content2_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content2_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content2_VideoURL"), descriptionLinkTarget: '_new'},
                                   finalData.push(mockCategories.listing);
                        
                             mockCategories.listing =
                                     { label: $A.get("$Label.c.PMP_Help_Training_Content3_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content3_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content3_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content3_VideoURL"), descriptionLinkTarget: '_new'},                    
                    			    finalData.push(mockCategories.listing);
                        
                   		     mockCategories.listing =   
 
									{ label: $A.get("$Label.c.PMP_Help_Training_Content4_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content4_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content4_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content4_VideoURL"), descriptionLinkTarget: '_new'},
                              		finalData.push(mockCategories.listing);
                             mockCategories.listing =   
 
									{ label: $A.get("$Label.c.PMP_Help_Training_Content5_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content5_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content5_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content5_VideoURL"), descriptionLinkTarget: '_new'},
                                    finalData.push(mockCategories.listing);
						     mockCategories.listing =   
 
									{ label: $A.get("$Label.c.PMP_Help_Training_Content6_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content6_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content6_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content6_VideoURL"), descriptionLinkTarget: '_new'},
                                    finalData.push(mockCategories.listing);
							 mockCategories.listing =   
 
									{ label: $A.get("$Label.c.PMP_Help_Training_Content7_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content7_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content7_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content7_VideoURL"), descriptionLinkTarget: '_new'},
								    finalData.push(mockCategories.listing);
							 mockCategories.listing =   
 
									{ label: $A.get("$Label.c.PMP_Help_Training_Content8_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content8_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content8_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content8_VideoURL"), descriptionLinkTarget: '_new'},
								    finalData.push(mockCategories.listing); 
                        
                        mockCategories.listing =  
                        { label: $A.get("$Label.c.PMP_Help_Training_Content10_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content10_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content10_Description"), linkIsVideo: false, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_View_MP_Guidelines"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content10_VideoURL"), descriptionLinkTarget: '_new'},
                            
                                 finalData.push(mockCategories.listing);
                        
						     mockCategories.listing =   
 
									{ label: $A.get("$Label.c.PMP_Help_Training_Content9_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content9_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content9_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content9_VideoURL"), descriptionLinkTarget: '_new'},
                            
                                 finalData.push(mockCategories.listing); 
                        
						
                        
	           }
        component.set('v.listing', finalData); */
        
          //Raushan
        
        

        if (pageType === 'marketplacehelp') {
       if($A.get("$SObjectType.CurrentUser.Email") === undefined){
            // Default Help and Training
            mockCategories.title = $A.get("$Label.c.PMP_Help_And_Training"); //'Help & Training For You';
            mockCategories.viewAllHeadline = $A.get("$Label.c.PMP_Help_And_Training");
            mockCategories.viewMoreLinkTitle = $A.get("$Label.c.PMP_Show_More");// show More
            mockCategories.listing = [
                
                    { label: $A.get("$Label.c.PMP_Help_Training_Content1_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content1_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content1_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content1_VideoURL"), descriptionLinkTarget: '_new'},                    
                   	{ label: $A.get("$Label.c.PMP_Help_Training_Content4_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content4_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content4_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content4_VideoURL"), descriptionLinkTarget: '_new'}
                	
 
            ];
        }
            else{
                
                mockCategories.title = $A.get("$Label.c.PMP_Help_And_Training"); //'Help & Training For You';
                mockCategories.viewAllHeadline = $A.get("$Label.c.PMP_Help_And_Training");
            	mockCategories.viewMoreLinkTitle = $A.get("$Label.c.PMP_Show_More");// show More
            	mockCategories.listing = [
                
                    { label: $A.get("$Label.c.PMP_Help_Training_Content1_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content1_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content1_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content1_VideoURL"), descriptionLinkTarget: '_new'},                    
                    { label: $A.get("$Label.c.PMP_Help_Training_Content2_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content2_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content2_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content2_VideoURL"), descriptionLinkTarget: '_new'},
                    { label: $A.get("$Label.c.PMP_Help_Training_Content3_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content3_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content3_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content3_VideoURL"), descriptionLinkTarget: '_new'},
                   	{ label: $A.get("$Label.c.PMP_Help_Training_Content4_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content4_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content4_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content4_VideoURL"), descriptionLinkTarget: '_new'},
                	{ label: $A.get("$Label.c.PMP_Help_Training_Content5_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content5_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content5_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content5_VideoURL"), descriptionLinkTarget: '_new'},
                    { label: $A.get("$Label.c.PMP_Help_Training_Content6_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content6_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content6_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content6_VideoURL"), descriptionLinkTarget: '_new'},
                    { label: $A.get("$Label.c.PMP_Help_Training_Content8_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content8_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content8_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content8_VideoURL"), descriptionLinkTarget: '_new'},
               		{ label: $A.get("$Label.c.PMP_Help_Training_Content7_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content7_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content7_Description"), linkIsVideo: false, descriptionLinkText: $A.get("$Label.c.PMP_Help_Content7_LinkText"), descriptionLink: $A.get("$Label.c.PMP_Help_Content7_URL"), descriptionLinkTarget: '_new'},
                    { label: $A.get("$Label.c.PMP_Help_Training_Content10_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content1_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content10_Description"), linkIsVideo: false, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_View_MP_Guidelines"), descriptionLink: publicationGuidelinelink, descriptionLinkTarget: '_new'},    
                { label: $A.get("$Label.c.PMP_Help_Training_Content9_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content9_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content9_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content9_VideoURL"), descriptionLinkTarget: '_new'}
                
                //uncomment following block of 4 line code once the video URLs are availablle
                //   					{ label: $A.get("$Label.c.PMP_Help_Training_Content4_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content4_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content4_Description")},
                //	{ label: $A.get("$Label.c.PMP_Help_Training_Content5_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content5_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content5_Description")},
               //     { label: $A.get("$Label.c.PMP_Help_Training_Content6_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content6_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content6_Description")},
               //    	{ label: $A.get("$Label.c.PMP_Help_Training_Content8_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content8_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content8_Description")},

           
                
                //		{ label: $A.get("$Label.c.PMP_Help_Training_Content7_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content7_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content7_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content7_VideoURL"), descriptionLinkTarget: '_new'},
 
            ];
                
            }
        }else {
            //marketplacedashboard
            mockCategories = {
                 title: $A.get("$Label.c.PMP_Help_And_Training"),
                //subtitle: 'Discover and make valuable connections with Intel Partners and partner communities.',
                listing: [
                    { label: $A.get("$Label.c.PMP_Help_Training_Content1_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content1_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content1_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content1_VideoURL"), descriptionLinkTarget: '_new'},
                    { label: $A.get("$Label.c.PMP_Help_Training_Content2_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content2_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content2_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content2_VideoURL"), descriptionLinkTarget: '_new'},
                    { label: $A.get("$Label.c.PMP_Help_Training_Content3_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content3_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content3_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content3_VideoURL"), descriptionLinkTarget: '_new'},
                   	{ label: $A.get("$Label.c.PMP_Help_Training_Content4_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content4_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content4_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content4_VideoURL"), descriptionLinkTarget: '_new'},
                	{ label: $A.get("$Label.c.PMP_Help_Training_Content5_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content5_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content5_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content5_VideoURL"), descriptionLinkTarget: '_new'},
                    { label: $A.get("$Label.c.PMP_Help_Training_Content6_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content6_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content6_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content6_VideoURL"), descriptionLinkTarget: '_new'},
                    { label: $A.get("$Label.c.PMP_Help_Training_Content8_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content8_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content8_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content8_VideoURL"), descriptionLinkTarget: '_new'},
               		{ label: $A.get("$Label.c.PMP_Help_Training_Content7_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content7_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content7_Description"), linkIsVideo: false, descriptionLinkText: $A.get("$Label.c.PMP_Help_Content7_LinkText"), descriptionLink: $A.get("$Label.c.PMP_Help_Content7_URL"), descriptionLinkTarget: '_new'},
                    { label: $A.get("$Label.c.PMP_Help_Training_Content9_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content9_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content9_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content9_VideoURL"), descriptionLinkTarget: '_new'}
					
                    
                    
                //uncomment following block of 4 line code once the video URLs are availablle

//                    { label: $A.get("$Label.c.PMP_Help_Training_Content4_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content4_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content4_Description"), linkIsVideo: false, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content4_VideoURL"), descriptionLinkTarget: '_new'},
//                    { label: $A.get("$Label.c.PMP_Help_Training_Content5_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content5_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content5_Description"), linkIsVideo: false, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content5_VideoURL"), descriptionLinkTarget: '_new'},
//                    { label: $A.get("$Label.c.PMP_Help_Training_Content6_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content6_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content6_Description"), linkIsVideo: false, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content6_VideoURL"), descriptionLinkTarget: '_new'},
//                    { label: $A.get("$Label.c.PMP_Help_Training_Content8_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content8_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content8_Description"), linkIsVideo: false, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content8_VideoURL"), descriptionLinkTarget: '_new'}

               //     { label: $A.get("$Label.c.PMP_Help_Training_Content7_Label"), imgUrl: $A.get("$Label.c.PMP_Help_Training_Content7_ImageURL"), description: $A.get("$Label.c.PMP_Help_Training_Content7_Description"), linkIsVideo: true, descriptionLinkText: $A.get("$Label.c.PMP_Help_Training_WatchTheVideo"), descriptionLink: $A.get("$Label.c.PMP_Help_Training_Content7_VideoURL"), descriptionLinkTarget: '_new'},

                ],
                 // Replace values with custom labels - [10/7]
                //CTA: 'All Marketplace help',
                //CTAUrl: '/imp/s/help'
                CTA: $A.get("$Label.c.PMP_All_Marketplace_Help"), 
                CTAUrl: $A.get("$Label.c.PMP_All_Marketplace_Help_URL")
            }
        }
//commented by raushan
	
        
        component.set('v.listing', mockCategories.listing);
        component.set('v.title', mockCategories.title);
        component.set('v.subtitle', mockCategories.subtitle);
        component.set('v.CTA', mockCategories.CTA);
        component.set('v.CTAUrl', mockCategories.CTAUrl);

        component.set('v.viewAllHeadline', mockCategories.viewAllHeadline);
        component.set('v.viewMoreLinkTitle', mockCategories.viewMoreLinkTitle); 
    
    }
})