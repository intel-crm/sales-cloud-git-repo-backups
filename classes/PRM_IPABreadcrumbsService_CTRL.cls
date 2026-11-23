/***************************************************************************************************************************************
Apex Class Name     : PRM_IPABreadcrumbsService_CTRL
Version             : 1.0
Created Date        : July 2020
Function            : This controller class will load different navigation on Post Launch Onboarding Page on the baisis of type and User Entitlement on UI.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty Sharma                       28th-July-2020              US741878-Enable secondary Nav i.e breadcrumbs for the salesforce portal pages
*************************************************************************************************************************************/

public class PRM_IPABreadcrumbsService_CTRL {
    @AuraEnabled
    public static String getNavigationItems(){
        PRM_IPABreadcrumbsService_Wrapper serviceWrapper = new PRM_IPABreadcrumbsService_Wrapper();
        PRM_IPABreadcrumbsService_Wrapper.cls_breadcrumb breadCrumbs=new PRM_IPABreadcrumbsService_Wrapper.cls_breadcrumb();
        PRM_IPABreadcrumbsService_Wrapper.cls_children childrenWrapper=new PRM_IPABreadcrumbsService_Wrapper.cls_children();
        PRM_IPABreadcrumbsService_Wrapper.Data dataWrapper= new PRM_IPABreadcrumbsService_Wrapper.Data();
        PRM_IPABreadcrumbsService_Wrapper.Attributes attributeWrapper =new PRM_IPABreadcrumbsService_Wrapper.Attributes();
        List<PRM_IPABreadcrumbsService_Wrapper.cls_children> childrenList=new List<PRM_IPABreadcrumbsService_Wrapper.cls_children>();
        System.debug('@@@testinside method');
        breadCrumbs.id=1;
        breadCrumbs.selected=true;
        breadCrumbs.text=System.Label.PRM_Breadcrumb_IPA_Text;
        breadCrumbs.url=System.Label.PRM_Breadcrumb_IPA_URL;
        childrenWrapper.id=2;
        childrenWrapper.text=System.Label.PRM_Breadcrumb_PartnerHome_Text;
        childrenWrapper.url=System.Label.PRM_Breadcrumb_PartnerHome_URL;
        childrenList.add(childrenWrapper);
        childrenWrapper =new PRM_IPABreadcrumbsService_Wrapper.cls_children();
        childrenWrapper.cancelEvent=true;
        childrenWrapper.useCallback=true;
        childrenWrapper.id=3;
        childrenWrapper.text='Partner Benefits';
        dataWrapper.type='comm__namedPage';
        attributeWrapper.pageName='home';
        dataWrapper.attributes=attributeWrapper;
        childrenWrapper.data=dataWrapper;
        
        childrenList.add(childrenWrapper);
        
        childrenWrapper =new PRM_IPABreadcrumbsService_Wrapper.cls_children();
        childrenWrapper.id=4;
        childrenWrapper.text=System.Label.PRM_Breadcrumb_ViewDashboard_Text;
        childrenWrapper.useCallback=true;
        dataWrapper=new PRM_IPABreadcrumbsService_Wrapper.Data();
        attributeWrapper=new PRM_IPABreadcrumbsService_Wrapper.Attributes();
        dataWrapper.type='comm__namedPage';
        attributeWrapper.pageName='dashboard';
        dataWrapper.attributes=attributeWrapper;
        childrenList.add(childrenWrapper);
        
        childrenWrapper =new PRM_IPABreadcrumbsService_Wrapper.cls_children();
        childrenWrapper.id=5;
        childrenWrapper.text=System.Label.PRM_Breadcrumb_SalesEnablementResources;
        childrenWrapper.url=System.Label.PRM_Breadcrumb_SalesEnablementResources_URL;
        childrenWrapper.target='_blank';
        
        childrenList.add(childrenWrapper);
        
        childrenWrapper =new PRM_IPABreadcrumbsService_Wrapper.cls_children();
        dataWrapper=new PRM_IPABreadcrumbsService_Wrapper.Data();
        attributeWrapper=new PRM_IPABreadcrumbsService_Wrapper.Attributes();
        childrenWrapper.id=7;
        childrenWrapper.selected=false;
        childrenWrapper.text='Company Profile';
        childrenWrapper.useCallback=true;
        attributeWrapper.pageName='companyprofile';
        dataWrapper.type='comm__namedPage';
        childrenWrapper.cancelEvent=true;
        dataWrapper.attributes=attributeWrapper;
        childrenWrapper.data=dataWrapper;
        childrenList.add(childrenWrapper);
        
        childrenWrapper =new PRM_IPABreadcrumbsService_Wrapper.cls_children();
        childrenWrapper.id=9;
        childrenWrapper.text=System.Label.PRM_Breadcrumb_GetHelp_Text;
        childrenWrapper.url=System.Label.PRM_Breadcrumb_GetHelp_URL;
        childrenList.add(childrenWrapper);
        breadCrumbs.children.addAll(childrenList);
        serviceWrapper.breadcrumb=breadCrumbs;
        //System.debug('@@@wrapper'+JSON.serialize(serviceWrapper));
        return JSON.serialize(serviceWrapper);
    }    
}