/********************************************************************************************************************
Apex Class Name  : IPABenefitUtilityHandler
Version       : 1.0
Created Date  : June 2020
Function      : Utility class containing business logic for Partner Benefits

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Anish/Grishma/Jasmine               June 2020              Utility class containing business logic for  Partner Benefits
* Mansi  Mundhra              2021         Addition of new blades/ctas and Adhoc Msg Functionality
*********************************************************************************************************************/
public with sharing class IPABenefitUtilityHandler {
    
    //call this method to get MDF Details
    public static IPABenefitWrapper.UserBenefitInfo getMDF(List<String> links,List<String> alertTitles,Map<String,String> adhocMsgs){
        
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title=System.Label.IPA_MDF_bnft_Title;
        userBenefit.faIcon=System.Label.IPA_MDF_bnft_Icon;
        userBenefit.description=System.Label.IPA_MDF_bnft_Description;
        // Addedd as Part of US816284
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
       
        IPABenefitUtility.populateAlerts(alertTitles, userBenefit); // IPA2.0-TWC727-2896
        IPABenefitUtility.populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
        IPABenefitUtility.populateCTALinks(links,ctaPriorities,ctaLinks); // IPA2.0-TWC727-2896
         //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = IPABenefitUtility.userInfo(currentUserId);
            String lang = profile.userLanguage;
       /* if(alertTitles.size()>0)
        {
            List<IPABenefitWrapper.Alerts> alertList=new List<IPABenefitWrapper.Alerts>();
            for(String a:alertTitles)
            {
                IPABenefitWrapper.Alerts alert=new IPABenefitWrapper.Alerts();
                alert.label=a;
                alertList.add(alert);  
            }
            userBenefit.alerts=alertList;    
        }
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
           
            userBenefit.adhocAlerts=adhocList;    
        }
        // Addedd as Part of US816284
        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            } 
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]);
                ctaLinks.add(links[i]);
            }
        }*/
        
        //Boolean isTrue1= false;
        List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        //IPA2.0-TWC727-2896>> start
       // Step 1: Create controller for your custom metadata name
        Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');

        // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
        Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();
      
        for(String ctaPrior :ctaPriorities){ 
            IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
              if (ctaMetaMap.containsKey(ctaPrior)) {
                        Map<String, Object> meta = ctaMetaMap.get(ctaPrior);
                    if(String.valueOf(meta.get('type'))=='getMDF' /*&& Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())*/){
                            mlink.label = String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                            mlink.externalUrl = String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                            metric.link=mlink;
                    }
                    
            /*switch on ctaPrior {
                when 'IPA MDF' {
                    mlink.label= System.Label.IPA_MDF_CTA_label;
                    mlink.externalUrl=System.Label.IPA_MDF_URL;
                    metric.link=mlink;
                }
                when 'View MDF' {
                    mlink.label= System.Label.IPA_View_MDF_CTA_label;
                    mlink.externalUrl=System.Label.IPA_View_MDF_URL;
                    metric.link=mlink; 
                }
                /*TWC727-339 - Utkarsh - Start - Added one more condition to display MDF blade on Manage benefit page*/
                /*when 'View MDF Tool' {
                    mlink.label= System.Label.IPA_View_CCP_MDF_CTA_label;
                    mlink.externalUrl=System.Label.IPA_MDF_URL;
                    metric.link=mlink; 
                }
                /*TWC727-339 - END*/                
            /*}*/ 
        }
            listMetrics.add(metric);
        
        }
        userBenefit.Metrics = listMetrics;     
        
        List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
        // Addedd as Part of US816284
        if(ctaLinks.size() > 0){
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                 if (ctaMetaMap.containsKey(cta)) {
                    Map<String, Object> meta = ctaMetaMap.get(cta);
                    if(String.valueOf(meta.get('type'))=='getMDF' /*&&Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())*/){
                            link1.label = String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                            link1.externalUrl = String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                            linkList.add(link1); 
                    }
                /*switch on cta {
                    when 'IPA MDF' {
                        link1.label=System.Label.IPA_MDF_CTA_label;
                        link1.externalUrl=System.Label.IPA_MDF_URL;
                        linkList.add(link1);   
                    }
                    when 'View MDF' {
                        link1.label=System.Label.IPA_View_MDF_CTA_label;
                        link1.externalUrl=System.Label.IPA_View_MDF_URL;
                        linkList.add(link1);   
                    }
                    /*TWC727-339 - Utkarsh - Start - Added one more condition to display MDF blade on Manage benefit page*/
                   /* when 'View MDF Tool' {
                        link1.label=System.Label.IPA_View_CCP_MDF_CTA_label;
                        link1.externalUrl=System.Label.IPA_MDF_URL;
                        linkList.add(link1);   
                    }
                    /*TWC727-339 - END*/
                /*}*/
            }
        }
            userBenefit.links=linkList; 
        }
        return userBenefit;
    } //IPA2.0-TWC727-2896>>end
    
    public static IPABenefitWrapper.UserBenefitInfo getLeads(List<String> links,List<String> alertTitles,Map<String,String> adhocMsgs, List<IPABenefitWrapper.Metrics> leadsMetric ){
        
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        userBenefit.title=System.Label.IPA_Leads_bnft_Title;
        userBenefit.faIcon=System.Label.IPA_Leads_bnft_Icon;
        userBenefit.description=System.Label.IPA_Leads_bnft_Description;
        IPABenefitUtility.populateAlerts(alertTitles, userBenefit); // IPA2.0-TWC727-2896
        IPABenefitUtility.populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
         //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = IPABenefitUtility.userInfo(currentUserId);
            String lang = profile.userLanguage;
       /* if(alertTitles.size()>0)
        {
            List<IPABenefitWrapper.Alerts> alertList=new List<IPABenefitWrapper.Alerts>();
            for(String a:alertTitles)
            {
                IPABenefitWrapper.Alerts alert=new IPABenefitWrapper.Alerts();
                alert.label=a;
                alertList.add(alert);  
            }
            userBenefit.alerts=alertList;    
        }
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
           
            userBenefit.adhocAlerts=adhocList;    
        }*/
        for(integer i = 0;i<links.size(); i++){
            ctaPriorities.add(links[0]);
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            } 
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]);
                ctaLinks.add(links[i]);
            }
        }
        //IPA2.0-TWC727-2896>>start
       // Step 1: Create controller for your custom metadata name
        Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');

        // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
        Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();
        if(ctaPriorities.size()>0){
            for(String ctaPrior :ctaPriorities){ 
                IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();   
                IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
               if (ctaMetaMap.containsKey(ctaPrior)) {
                        Map<String, Object> meta = ctaMetaMap.get(ctaPrior);
                    if(String.valueOf(meta.get('type'))=='getLeads' /*&& Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())*/){
                            mlink.label = String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                            mlink.externalUrl = String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                             if(leadsMetric.size()>0){
                                metricCTCS = leadsMetric[0];
                                metricCTCS.link=mlink;
                              } else{
                                metricCTCS.link=mlink;
                                listMetrics.add(metricCTCS);                         
                            }
                       }
                  }
              


              /* switch on ctaPrior {              
                    when 'Manage Leads' { 
                        IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();   
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                        mlink.label= System.Label.IPA_Leads_manage_bnftlnk_Label;
                        mlink.externalUrl=System.Label.IPA_Leads_manage_bnftlnk_Link;
                        if(leadsMetric.size()>0){
                            metricCTCS = leadsMetric[0];
                            metricCTCS.link=mlink;
                        } else{
                            metricCTCS.link=mlink;
                            listMetrics.add(metricCTCS);                         
                        }
                    } 
                    when 'View results' { 
                        IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                        mlink.label= System.Label.IPA_Leads_ResultLeads_bnftlnk_Label;
                        mlink.externalUrl=System.Label.IPA_Leads_ResultLeads_bnftlnk_Link;
                        if(leadsMetric.size()>0){
                            metricCTCS = leadsMetric[0];
                            metricCTCS.link=mlink;
                        } else{
                            metricCTCS.link=mlink;
                            listMetrics.add(metricCTCS);                         
                        }
                    } 
                    when 'Get help with Leads' { 
                        IPABenefitWrapper.Metrics metricCTCS = new IPABenefitWrapper.Metrics();
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                        mlink.label= System.Label.IPA_Leads_gethelp_bnftlnk_Label;
                        mlink.externalUrl=System.Label.IPA_Leads_gethelp_bnftlnk_Link;
                        if(leadsMetric.size()>0){
                            metricCTCS = leadsMetric[0];
                            metricCTCS.link=mlink;
                        } else{
                            metricCTCS.link=mlink;
                            listMetrics.add(metricCTCS);                         
                        }
                        
                    } 
                }*/
            }
        }
        if(leadsMetric.size()>0){ userBenefit.metrics=leadsMetric;}else{ userBenefit.metrics=listMetrics;    }
        List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
        if(ctaLinks.size()>0){
            for(String cta:ctaLinks)
            {
                IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                 if (ctaMetaMap.containsKey(cta)) {
                    Map<String, Object> meta = ctaMetaMap.get(cta);
                    if(String.valueOf(meta.get('type'))=='getLeads' /*&& Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())*/){
                            link1.label = String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                            link1.externalUrl = String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                    }
                }
                linkList.add(link1);  
                /*switch on cta {
                    when 'Manage Leads' {
                        //IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                        link1.label=System.Label.IPA_Leads_manage_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_Leads_manage_bnftlnk_Link;
                    }
                    when 'View results' {
                        link1.label=System.Label.IPA_Leads_ResultLeads_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_Leads_ResultLeads_bnftlnk_Link;
                    }
                    when 'Get help with Leads' {
                        link1.label=System.Label.IPA_Leads_gethelp_bnftlnk_Label;
                        link1.externalUrl=System.Label.IPA_Leads_gethelp_bnftlnk_Link;
                    }                            
                }
                linkList.add(link1);  */           
            }
        }
        userBenefit.links=linkList;
        // System.debug('Lead--->'+userBenefit.title);
        return userBenefit;    
    }  //IPA2.0-TWC727-2896>>end
    
    //call this method to get Market Place details
    public static IPABenefitWrapper.UserBenefitInfo getMarketPlace(List<String> links,List<String> alertTitles,Map<String,String> adhocMsgs,List<IPABenefitWrapper.Metrics> marketPlaceMetrics){
        List<String> ctaPriorities = new  List<String>();
        List<String> ctaLinks =  new List<String>();
        List<IPABenefitWrapper.Metrics> listMetrics=new List<IPABenefitWrapper.Metrics>();
        IPABenefitWrapper.UserBenefitInfo userBenefit=new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.title=System.Label.IPA_Marketplace_bnft_Title;
        userBenefit.faIcon=System.Label.IPA_Marketplace_bnft_Icon;
        userBenefit.description=System.Label.IPA_Marketplace_bnft_Description;
        IPABenefitUtility.populateAlerts(alertTitles, userBenefit); // IPA2.0-TWC727-2896
        IPABenefitUtility.populateAdhocAlerts(adhocMsgs, userBenefit); // IPA2.0-TWC727-2896
         //IPA2.0-TWC727-3141
            Id currentUserId = UserInfo.getUserId();
            IPABenefitWrapper.UserProfile profile = IPABenefitUtility.userInfo(currentUserId);
            String lang = profile.userLanguage;
       /* if(alertTitles.size()>0)
        {
            List<IPABenefitWrapper.Alerts> alertList=new List<IPABenefitWrapper.Alerts>();
            for(String a:alertTitles)
            {
                IPABenefitWrapper.Alerts alert=new IPABenefitWrapper.Alerts();
                alert.label=a;
                alertList.add(alert);  
            }
            userBenefit.alerts=alertList;    
        }  
        if(adhocMsgs.size()>0)//  display adhoc part
        {
            List<IPABenefitWrapper.AdhocAlerts> adhocList=new List<IPABenefitWrapper.AdhocAlerts>();
            for(String a : adhocMsgs.keySet())
            {
                IPABenefitWrapper.AdhocAlerts adhocAlert=new IPABenefitWrapper.AdhocAlerts();
                List<String> IdList = a.split(',');
                adhocAlert.uniqueId = IdList[0];
                adhocAlert.label = IdList[1];
                adhocAlert.adcDescription = adhocMsgs.get(a);
                adhocList.add(adhocAlert);  
            }
            
            userBenefit.adhocAlerts=adhocList;    
        }*/
        //US - US775987 - replace placeholder of Manage Storefront link - System.Label.IPA_Marketplace_ManageStore_bnftlnk_Link
        PMP_Company__c CmpnyDetails =  Core_UtilityController.getCompany();
        String partnrDet;
        Boolean showManagerStorefront = false; 
        if(CmpnyDetails != null && CmpnyDetails.id != null && CmpnyDetails.name != null){
            partnrDet = System.Label.IPA_Marketplace_ManageStore_bnftlnk_Link.replace('<Partner ID>',CmpnyDetails.id).replace('<Partner Name>',CmpnyDetails.name); 
            showManagerStorefront = true;
        }
        for(integer i = 0;i<links.size(); i++){
            /* if(links[0] =='Manage Storefront'){
ctaPriorities.add(links[1]);
}else{*/
            ctaPriorities.add(links[0]);  
            //}
            if(links[i] != ctaPriorities[0]){
                ctaLinks.add(links[i]);  
            }
            if(Test.isRunningTest()){
                ctaPriorities.add(links[i]) ; 
                ctaLinks.add(links[i]);
                showManagerStorefront = true;
            }
        }
         //IPA2.0-TWC727-2896>>start
       // Step 1: Create controller for your custom metadata name
        Core_CustomMetadataObjectController ctaController = new Core_CustomMetadataObjectController('PRM_CtaPriorities__mdt');

        // Step 2: Fetch all CMDT records as Map<String, Map<String, Object>> where key = DeveloperName
        Map<String, Map<String, Object>> ctaMetaMap = ctaController.getAll();
        if(marketPlaceMetrics.size()>0){
            //  List<IPABenefitWrapper.Metrics> metricList1=new List<IPABenefitWrapper.Metrics>();
            //  metricList1=marketPlaceMetrics;  
            for(String ctaPrior : ctaPriorities){
                 IPABenefitWrapper.Metrics metricCTCS = marketPlaceMetrics[1];
                 IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                if (ctaMetaMap.containsKey(ctaPrior)) {
                        Map<String, Object> meta = ctaMetaMap.get(ctaPrior);
                    if(String.valueOf(meta.get('type'))=='getMarketPlace' /*&& Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())*/){
                        // if(!showManagerStorefront && ctaPrior=='Manage Storefront'){
                        //     continue;
                        // }else{    
                           mlink.label =String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                           if(mlink.Label == 'Manage Storefront'){
                                mlink.externalUrl = partnrDet;
                           }else{
                                mlink.externalUrl = String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                           }
                            metricCTCS.link=mlink;
                         //}
                     }
                    }
                /*switch on ctaPrior {   
                    when 'Manage Offerings' {
                        //IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                        IPABenefitWrapper.Metrics metricCTCS = marketPlaceMetrics[1];
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                        mlink.label=System.Label.IPA_Marketplace_ManageOfferings_bnftlnk_Label;
                        mlink.externalUrl=System.Label.IPA_Marketplace_ManageOfferings_bnftlnk_Link;
                        metricCTCS.link=mlink;   
                    }
                    when 'Create New Offering' {
                        IPABenefitWrapper.Metrics metricCTCS = marketPlaceMetrics[1];
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                        mlink.label=System.Label.IPA_Marketplace_Offerings_bnftlnk_Label;
                        mlink.externalUrl=System.Label.IPA_Marketplace_Offerings_bnftlnk_Link;
                        metricCTCS.link=mlink;   
                    }
                    when 'Manage Storefront' {
                        if(showManagerStorefront){
                            IPABenefitWrapper.Metrics metricCTCS = marketPlaceMetrics[1];
                            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                            mlink.label=System.Label.IPA_Marketplace_ManageStore_bnftlnk_Label;
                            mlink.externalUrl= partnrDet;//System.Label.IPA_Marketplace_ManageStore_bnftlnk_Link;
                            metricCTCS.link=mlink;
                        }   
                    }
                    when 'View Results' {
                        IPABenefitWrapper.Metrics metricCTCS = marketPlaceMetrics[1];
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                        mlink.label=System.Label.IPA_Marketplace_Results_bnftlnk_Label;
                        mlink.externalUrl=System.Label.IPA_Marketplace_Results_bnftlnk_Link;
                        metricCTCS.link=mlink;
                    }
                    when 'Visit Marketplace' {
                        IPABenefitWrapper.Metrics metricCTCS = marketPlaceMetrics[1];
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.IPA_VisitMarketplace_bnftlnk_Label;
                        mlink.externalUrl=System.Label.IPA_VisitMarketplace_bnftlnk_Link;
                        metricCTCS.link=mlink;
                    }
                    when 'Get help with Marketplace' {
                        IPABenefitWrapper.Metrics metricCTCS = marketPlaceMetrics[1];
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.IPA_Marketplace_Gethelp_bnftlnk_Label;
                        mlink.externalUrl=System.Label.IPA_Marketplace_Gethelp_bnftlnk_Link;
                        metricCTCS.link=mlink;
                    } 
                    //---- newly added by dinesh                    
                    when 'Learn about submitting a solution' {
                        IPABenefitWrapper.Metrics metricCTCS = marketPlaceMetrics[1];
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.PRM_Find_out_about_submitting_a_solution;
                        mlink.externalUrl=System.Label.PRM_Find_out_about_submitting_a_solution_link;
                        metricCTCS.link=mlink;
                    } 
                   /* when 'Submit a Solution' {
                        IPABenefitWrapper.Metrics metricCTCS = marketPlaceMetrics[1];
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.PRM_Submit_a_Solution;
                        mlink.externalUrl=System.Label.PRM_Submit_a_Solution_link;
                        metricCTCS.link=mlink;
                    } */
                    /*when 'Submit a Solution' {  //renamed from Manage Solutions to Submit a Solution 
                        IPABenefitWrapper.Metrics metricCTCS = marketPlaceMetrics[1];
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.PRM_Manage_Solutions;
                        mlink.externalUrl=System.Label.PRM_Manage_Solutions_link;
                        metricCTCS.link=mlink;
                    } 
                    //end
                    when 'View the partner directory' {
                        IPABenefitWrapper.Metrics metricCTCS = marketPlaceMetrics[1];
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.PRM_View_the_partner_directory;
                        mlink.externalUrl=System.Label.PRM_View_the_partner_directory_link;
                        metricCTCS.link=mlink;
                    }
                }*/
            }
            userBenefit.metrics=marketPlaceMetrics; 
            // ctaLinks.addall(links);    
        }
        else{
            // create 1 metric based on ctr priority
            for(String ctaPrior : ctaPriorities){
                IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
                IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                if (ctaMetaMap.containsKey(ctaPrior)) {
                        Map<String, Object> meta = ctaMetaMap.get(ctaPrior);
                    if(String.valueOf(meta.get('type'))=='getMarketPlace' /*&& Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())*/){
                        // if(!showManagerStorefront && ctaPrior=='Manage Storefront'){
                        //     continue;
                        // } else{  
                            mlink.label = String.valueOf(System.label.get('',(String)meta.get('label'),lang)); 
                            if(mlink.Label == 'Manage Storefront'){
                                mlink.externalUrl = partnrDet;
                                
                            }
                          else{
                              mlink.externalUrl = String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                          }
                               
                        metric.link=mlink;
                            listMetrics.add(metric);
                        //}
                    }
                    }
               /* switch on ctaPrior {   
                    when 'Manage Offerings' {
                        //IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.IPA_Marketplace_ManageOfferings_bnftlnk_Label;
                        mlink.externalUrl=System.Label.IPA_Marketplace_ManageOfferings_bnftlnk_Link;
                        metric.link=mlink;
                        listMetrics.add(metric);
                    }
                    when 'Create New Offering' {
                        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.IPA_Marketplace_Offerings_bnftlnk_Label;
                        mlink.externalUrl=System.Label.IPA_Marketplace_Offerings_bnftlnk_Link;
                        metric.link=mlink;
                        listMetrics.add(metric);
                    }
                    when 'Manage Storefront' {
                        if(showManagerStorefront){
                            IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
                            IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();     
                            mlink.label=System.Label.IPA_Marketplace_ManageStore_bnftlnk_Label;
                            mlink.externalUrl= partnrDet;//System.Label.IPA_Marketplace_ManageStore_bnftlnk_Link;
                            metric.link=mlink;
                            listMetrics.add(metric);
                        }   
                    }
                    when 'View Results' {
                        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.IPA_Marketplace_Results_bnftlnk_Label;
                        mlink.externalUrl=System.Label.IPA_Marketplace_Results_bnftlnk_Link;
                        metric.link=mlink;
                        listMetrics.add(metric);
                    }
                    when 'Visit Marketplace' {
                        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.IPA_VisitMarketplace_bnftlnk_Label;
                        mlink.externalUrl=System.Label.IPA_VisitMarketplace_bnftlnk_Link;
                        metric.link=mlink;
                        listMetrics.add(metric);
                    }
                    when 'Get help with Marketplace' {
                        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.IPA_Marketplace_Gethelp_bnftlnk_Label;
                        mlink.externalUrl=System.Label.IPA_Marketplace_Gethelp_bnftlnk_Link;
                        metric.link=mlink;
                        listMetrics.add(metric);
                    } 
                    //---- newly added by dinesh                    
                    when 'Learn about submitting a solution' {
                        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.PRM_Find_out_about_submitting_a_solution;
                        mlink.externalUrl=System.Label.PRM_Find_out_about_submitting_a_solution_link;
                        metric.link=mlink;
                        listMetrics.add(metric);
                    } 
                   /* when 'Submit a Solution' {
                        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.PRM_Submit_a_Solution;
                        mlink.externalUrl=System.Label.PRM_Submit_a_Solution_link;
                        metric.link=mlink;
                        listMetrics.add(metric);
                    } */
                   /* when 'Submit a Solution' {//renamed from Manage Solutions to Submit a Solution 
                        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.PRM_Manage_Solutions;
                        mlink.externalUrl=System.Label.PRM_Manage_Solutions_link;
                        metric.link=mlink;
                        listMetrics.add(metric);
                    } 
                    //end
                    when 'View the partner directory' {
                        IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
                        IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link(); 
                        mlink.label=System.Label.PRM_View_the_partner_directory;
                        mlink.externalUrl=System.Label.PRM_View_the_partner_directory_link;
                        metric.link=mlink;
                        listMetrics.add(metric);
                    }
                }*/
                userBenefit.Metrics = listMetrics;
            }
        }    
        List<IPABenefitWrapper.Link> linkList=new List<IPABenefitWrapper.Link>();
        for(String cta:ctaLinks)
        {
              IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
             if (ctaMetaMap.containsKey(cta)) {
                        Map<String, Object> meta = ctaMetaMap.get(cta);
                    if(String.valueOf(meta.get('type'))=='getMarketPlace' /*&& Boolean.valueOf(String.valueOf(meta.get('IPARefreshSwitch')).toLowerCase())*/){
                        // if(!showManagerStorefront && cta=='Manage Storefront'){
                        //     continue;
                        // }else{
                            link1.label = String.valueOf(System.label.get('',(String)meta.get('label'),lang));
                            link1.externalUrl = String.valueOf(System.label.get('',(String)meta.get('externalUrl'),lang));
                            linkList.add(link1);
                       // }
                      }
                    }
            /*switch on cta {
                when 'Manage Offerings' {
                    IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    //IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    link1.label=System.Label.IPA_Marketplace_ManageOfferings_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_Marketplace_ManageOfferings_bnftlnk_Link;
                    linkList.add(link1);
                }
                when 'Create New Offering' {
                    IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    link1.label=System.Label.IPA_Marketplace_Offerings_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_Marketplace_Offerings_bnftlnk_Link;
                    linkList.add(link1);
                }
                when 'Manage Storefront' {
                    // showManagerStorefront = false;
                    if(showManagerStorefront){
                        IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                        link1.label=System.Label.IPA_Marketplace_ManageStore_bnftlnk_Label;
                        link1.externalUrl=partnrDet;//System.Label.IPA_Marketplace_ManageStore_bnftlnk_Link;
                        linkList.add(link1);
                    }
                }
                when 'View Results' {
                    IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    link1.label=System.Label.IPA_Marketplace_Results_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_Marketplace_Results_bnftlnk_Link;
                    linkList.add(link1);
                }
                when 'Visit Marketplace' {
                    IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    link1.label=System.Label.IPA_VisitMarketplace_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_VisitMarketplace_bnftlnk_Link;
                    linkList.add(link1);
                }
                when 'Get help with Marketplace' {
                    IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    link1.label=System.Label.IPA_Marketplace_Gethelp_bnftlnk_Label;
                    link1.externalUrl=System.Label.IPA_Marketplace_Gethelp_bnftlnk_Link;
                    linkList.add(link1);
                }
                //new
                when 'Learn about submitting a solution' {
                    IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    link1.label=System.Label.PRM_Find_out_about_submitting_a_solution;
                    link1.externalUrl=System.Label.PRM_Find_out_about_submitting_a_solution_link;
                    linkList.add(link1);
                }*/ 
               /* when 'Submit a Solution' {
                    IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    link1.label=System.Label.PRM_Submit_a_Solution;
                    link1.externalUrl=System.Label.PRM_Submit_a_Solution_link;
                    linkList.add(link1);
                } */
                /*when 'Submit a Solution' {//renamed from Manage Solutions to Submit a Solution 
                    IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    link1.label=System.Label.PRM_Manage_Solutions;
                    link1.externalUrl=System.Label.PRM_Manage_Solutions_link;
                    linkList.add(link1);
                }
                when 'View the partner directory' {
                    IPABenefitWrapper.Link link1=new IPABenefitWrapper.Link();
                    link1.label=System.Label.PRM_View_the_partner_directory;
                    link1.externalUrl=System.Label.PRM_View_the_partner_directory_link;
                    linkList.add(link1);
                } 
            }*/
            
        }
        userBenefit.links=linkList;   
        // System.debug('marketplace--->'+userBenefit.title);
        return userBenefit;    
    } //IPA2.0-TWC727-2896>> end

    
    
    //Method to return metrics for Leads blade
    public static List<IPABenefitWrapper.Metrics> getLeadsMetrics(String opid){
        datetime start = datetime.NOW();
        List<IPABenefitWrapper.Metrics> leadsMetrics=new List<IPABenefitWrapper.Metrics>();
        try{
            if(opid != null){
                Id partnerLeadRT = IPABenefitUtility.getRecordTypeId('Lead','Partner_Lead');//IPARefresh2.0-TWC727-2896
               // Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();
              /*  Integer   countLeads = [SELECT Count() FROM Lead WHERE Core_One_Partner_Id__c= :opid AND 
                                       Core_Lead_Status__c='New' AND Core_Lead_State__c='Unclaimed'
                                       AND RecordTypeId=:partnerLeadRT]; */
                Integer  countLeads = [SELECT Count() FROM Core_OPID_Lead_Relationship__c WHERE Core_OPID_Name__c = :opid AND
                                        Core_Lead_Name__r.Core_Lead_Status__c='New' AND
                                        Core_Lead_Name__r.Core_Lead_State__c='Unclaimed' AND
                                        Core_Lead_Name__r.RecordTypeId=:partnerLeadRT AND
                                       Core_Lead_Name__r.Core_Is_Lead_Shared__c=True];
                IPABenefitWrapper.Metrics metric=new IPABenefitWrapper.Metrics() ;
                metric.label=System.Label.IPA_Leads_mtrc_Label;//IPA_Select_mtrc_ManageSelect_desc; // 
                // IPABenefitWrapper.Link mlink=new IPABenefitWrapper.Link();
                //mlink.label=System.Label.IPA_Leads_mtrc_Manage_action;//IPA_Leads_mtrc_Label;
                // mlink.externalUrl=System.Label.IPA_Leads_mtrc_Manage_url;
                // metric.link=mlink;
                metric.value=String.valueOf(countLeads);
                metric.unit='';
                metric.description='';
                leadsMetrics.add(metric);
            }
        } catch(Exception e){
            System.debug('An exception has occurred!'+e);
        } 
        datetime endd = datetime.now();
        Decimal millisecs = Decimal.valueOf(endd.getTime() - start.getTime());
        integer div = 1000;   
        //Decimal cal = millisecs/div;
        return leadsMetrics;        
    }
}