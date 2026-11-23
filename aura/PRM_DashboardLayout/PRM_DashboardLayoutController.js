({
    doInit : function(component, event, helper) {
        
        var checUserAccessToPage = component.get('c.getResponse');
        checUserAccessToPage.setCallback(this, function(response){
            
            var state = response.getState();
            if(state =='SUCCESS'){
                if(response!=null || response!=undefined){
                    
                    var retval = response.getReturnValue();
                    console.log('response -->'+JSON.stringify(retval));
                    var tabPermission = retval.tabAccess;
                    var showPartnerKeyMetricsExtTab = retval.partnerKeyMetricExtLink;
                    var vxDataRecord = retval.renewalContent;
                    
                    console.log('vxdataRecord'+JSON.stringify(vxDataRecord));
                   
                  //  var jsonval = (JSON.stringify(vxDataRecord["dynamiccontent"])).replaceAll();
                    if(vxDataRecord){
                        console.log('VX DATa Map'+vxDataRecord["dynamiccontent"]);
                    	component.set("v.showvx",vxDataRecord["dynamiccontent"]);
                         
                    }
                    console.log('showPartnerKeyMetricsExtTab',showPartnerKeyMetricsExtTab);
                    console.log('retval response'+JSON.stringify(retval));
                    /*if seubscription is missing or t&c is not checked then will direct to onboarding page */
                    if(retval.onBoardingReidrecturl!=null && typeof retval.onBoardingReidrecturl!== 'undefined') {
	                	window.location.href = retval.onBoardingReidrecturl;
                        return;
                    }
                    if(retval.userType =='Partner'  && retval.link!=null && typeof retval.link!== 'undefined'){                        
                        console.log(' base -->'+JSON.stringify(window.location.origin+retval.link));                            
                        window.open(window.location.origin+retval.link,'_self');
                    
                    } else if(retval.userType =='Employee'  && retval.link!=null && typeof retval.link!== 'undefined'){
                       window.open(window.location.origin+retval.link,'_self');
                        
                    }
                    if(retval.loggedInuserType == $A.get("$Label.c.PRM_External_User")){
                        console.log('External user');
                        component.set("v.showPartnerKeyMetricsExtTab",showPartnerKeyMetricsExtTab);
                        component.set("v.showManageStorefrontBtn",true);
                        component.set("v.showManageManagePartnerBtn",false);
                    } else if(retval.loggedInuserType == $A.get("$Label.c.PRM_Internal_User")){
                        console.log('Internal user');
                        component.set("v.showManageManagePartnerBtn",true);
                        component.set("v.showManageStorefrontBtn",false);
                    }
                    console.log('typeof retval.tabAccess',typeof retval.tabAccess);
                    if(tabPermission != null && tabPermission != 'undefined'){
                        for (var key in tabPermission) {
                            if (tabPermission.hasOwnProperty(key)) {
                                console.log(key + "---tabPermission " + tabPermission[key]);
                                if(key == 'showPointsTab'){
                                    console.log('Inside Show Points Tab method');
                                    component.set("v.showPointsTab",tabPermission[key]);  
                                    component.set("v.showPointsTabLocationSection",retval.ptWrapper.showLocationActSection);
                                    component.set("v.showDQFlag",retval.ptWrapper.showDQFlag);
                                }
                                //IPA2.0-TWC729-8064
                                /*if(key == 'showPartnerKeyMetricsTab'){
                                    console.log('Inside Partner Key metric Tab method');
                                    component.set("v.showPartnerKeyMetricsTab",tabPermission[key]); 
                                    //component.set("v.showOfferingKeyMetricsTab",true);                                    
                                }*/
                                /*if(key == 'showPartnerTab'){
                                    console.log('Inside Show Partner Tab method');
                                    component.set("v.showPartnerTab",tabPermission[key]);  
                                }*/
                                if(key == 'showLeadTab'){
                                    console.log('Inside Lead Tab method');
                                    component.set("v.showLeadTab",tabPermission[key]);  
                                }
                                //IPA2.0-TWC729-8064
                                /*if(key == 'showOfferingTab'){
                                    component.set("v.showOfferingTab",tabPermission[key]);  
                                }*/
                                /*if(key == 'showOfferingSection'){
                                    component.set("v.showOfferingSection",tabPermission[key]);  
                                }*/
                                /*if(key == 'showSolutionSection'){
                                    component.set("v.showSolutionSection",tabPermission[key]);  
                                }*/
                                /*if(key == 'showOfferingKeyMetricsTab'){
                                    console.log('Inside Show Offering Key Tab method');
                                    component.set("v.showOfferingKeyMetricsTab",tabPermission[key]);  
                                }*/
                                if(key == 'showSalesTab'){
                                    console.log('Inside Show sales Tab method');
                                    component.set("v.showSalesTab",tabPermission[key]);  
                                }
                                if(key == 'showTrainingTab'){
                                    console.log('Inside Training Tab method');
                                    component.set("v.showTrainingTab",tabPermission[key]);  
                                }
								if(key == 'showAccountActivityTab'){
                                    console.log('Inside Account Activity Tab method');
                                    component.set("v.showAccountActivityTab",tabPermission[key]);  
                                } 
                                if(key == 'showWarrantyTab'){
                                    console.log('Inside Warranty Tab method');
                                    component.set("v.showWarrantyTab",tabPermission[key]);  
                                }
                                /*if(key == 'showRenewalTab'){
                                    //console.log('renewalContent:',retval.renewalContent["content"]);
                                    console.log('showRenewalTab');
                                    component.set("v.showRenewal",tabPermission[key]);
                                    console.log('renewalTab '+tabPermission[key] );
                                    if(retval.renewalContent){
                                    component.set("v.renewalc",retval.renewalContent["content"]);
                                     
                                    }
                                } *///IPA2.0 TWC727-3135
                            }
                        }
                        console.log('retval tab'+JSON.stringify(retval.tabAccess));
                	}
                    component.set("v.showTabs", true);
                    console.log('show tabs',component.get("v.showTabs"));
                    
                }
            }
            if(state =='ERROR'){
                console.log('error'+JSON.stringify(response.getError()));
            }
        });
        
        
        $A.enqueueAction(checUserAccessToPage);
       
        
              
     /*   var actionPDM=component.get('c.isCheckAgreementDetails');
        actionPDM.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State-->'+state);
            if (response.getState() == "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log(' -->'+returnValue+JSON.stringify(returnValue));
                if(returnValue!=null && returnValue == true){
                    window.location.href = 'https://www.intel.com/content/www/us/en/secure/partner-alliance/overview.html';                    
                }
            }  
            if(state =='ERROR'){
                console.log('Error -->'+JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(actionPDM);*/
        
     

        
        window.addEventListener('resize', $A.getCallback(function() {
            if(component.isValid()) {
                var currentScreenSize = window.innerWidth < 768 ? 'mobile' : 'desktop';
                var prevScreenSize = component.get('v.appState.Settings.currentScreenSize');
                if (currentScreenSize != prevScreenSize) {
                    helper.dispatch(component, 'changeSetting', {
                        currentScreenSize: currentScreenSize
                    });
                }
                
                var bpList = [{bp: 'small', maxWidth:768},{bp: 'medium', maxWidth:1024},{bp: 'large', maxWidth:1280},	{bp: 'x-large', maxWidth:10000}	];
                var currentSldsBreakpoint = bpList.find(function(bp){	return (window.innerWidth < bp.maxWidth);	}).bp;
                
                var prevSldsBreakPoint = component.get('v.appState.Settings.currentSldsBreakPoint');
                if (currentSldsBreakpoint != prevSldsBreakPoint) {
                    helper.dispatch(component, 'changeSetting', {
                        currentSldsBreakPoint: currentSldsBreakpoint
                    });
                }
            }
        }));
        
    },
    leadURL: function(component,event,helper){
        console.log('Entered Lead URL',$A.get("$Label.c.PRM_Lead_URL"));
        window.open($A.get("$Label.c.PRM_Lead_URL"));
    },
    offeringURL: function(component,event,helper){
        console.log('Entered Offering URL',$A.get("$Label.c.PRM_Offering_Url"));
        window.open($A.get("$Label.c.PRM_Offering_Url"));
    },
    SolutionURL: function(component,event,helper){
        console.log('Entered Solution URL',$A.get("$Label.c.PSS_Manage_Solution_URL"));
        window.open($A.get("$Label.c.PSS_Manage_Solution_URL"));
    },
    partnerURL: function(component,event,helper){
        console.log('Entered Partner URL',$A.get("$Label.c.PRM_Partner_Url"));
        window.open($A.get("$Label.c.PRM_Partner_Url"));
    },
    storefrontURL: function(component,event,helper){
        console.log('Entered Storefront URL',$A.get("$Label.c.PRM_Storefront_Url"));
        window.open(component.get("v.showPartnerKeyMetricsExtTab"));
    },
    partnerUniversity: function(component,event,helper){
        console.log('Entered partner Unviersity',$A.get("$Label.c.PRM_Partner_University_URL"));
        window.open($A.get("$Label.c.PRM_Partner_University_URL"));
    },
    
    manageMembership:function(component,event,helper){
        console.log('Entered Manage Mem URL',$A.get("$Label.c.PRM_Manage_Mem_Url"));
        window.open($A.get("$Label.c.PRM_Manage_Mem_Url"));
    },
    warrantyURL:function(component,event,helper){
        console.log('Entered Warranty URL',$A.get("$Label.c.PRM_Manage_Warranty_Btn_Link"));
        window.open($A.get("$Label.c.PRM_Manage_Warranty_Btn_Link"));
    },
    pointsURL:function(component,event,helper){
        console.log('Entered Points URL',$A.get("$Label.c.PRM_Points_Btn_Link"));
        window.open($A.get("$Label.c.PRM_Points_Btn_Link"));
    },
    changeFocusBackgroundColor:function(component){
        var cmpTarget = component.find('partnerUnivId');
        $A.util.toggleClass(cmpTarget, 'focus-background-color');
    },

    changeFocusColor:function(component){
        var cmpTarget = component.find('prmDashboard');
        $A.util.toggleClass(cmpTarget, 'focus-color');
    }
    
})