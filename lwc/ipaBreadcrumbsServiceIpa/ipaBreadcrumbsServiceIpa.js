import {track} from 'lwc';
/**
  * Returns a mock version of IPA's BreadcrumbNavigation object.
  * @returns {BreadcrumbNavigation} A mock version of IPA's BreadcrumbNavigation object.
  * @private
  */
 import IPA_VisitMarketplace_bnftlnk_Link from '@salesforce/label/c.IPA_VisitMarketplace_bnftlnk_Link';
 import PMP_Breadcrumb_Header from '@salesforce/label/c.PMP_Breadcrumb_Header';
 import PMP_Leads_Heading from '@salesforce/label/c.PMP_Leads_Heading';
 import PRM_Breadcrumb_AboutMembership_Txt from '@salesforce/label/c.PRM_Breadcrumb_AboutMembership_Txt';
 import PRM_Breadcrumb_AboutMembership_URL from '@salesforce/label/c.PRM_Breadcrumb_AboutMembership_URL';
 import PRM_Breadcrumb_GetHelp_Text from '@salesforce/label/c.PRM_Breadcrumb_GetHelp_Text';
 import PRM_Breadcrumb_GetHelp_URL from '@salesforce/label/c.PRM_Breadcrumb_GetHelp_URL';
 import PRM_Breadcrumb_IPA_Text from '@salesforce/label/c.PRM_Breadcrumb_IPA_Text';
 import PRM_Breadcrumb_IPA_URL from '@salesforce/label/c.PRM_Breadcrumb_IPA_URL';
 import PRM_Breadcrumb_SubmitSolutionSecure_URL from '@salesforce/label/c.PRM_Breadcrumb_SubmitSolutionSecure_URL';
 import PRM_Breadcrumb_MarketingStudio_Text from '@salesforce/label/c.PRM_Breadcrumb_MarketingStudio_Text';
 import PRM_Breadcrumb_MarketingStudio_URL from '@salesforce/label/c.PRM_Breadcrumb_MarketingStudio_URL';
 import PRM_Breadcrumb_MyLeads_URL from '@salesforce/label/c.PRM_Breadcrumb_MyLeads_URL';
 import PRM_Breadcrumb_PartnerBenefit_Txt from '@salesforce/label/c.PRM_Breadcrumb_PartnerBenefit_Txt';
 import PRM_Breadcrumb_PartnerBenefit_URL from '@salesforce/label/c.PRM_Breadcrumb_PartnerBenefit_URL';
 import PRM_Breadcrumb_PartnerCommunities_Text from '@salesforce/label/c.PRM_Breadcrumb_PartnerCommunities_Text';
 import PRM_Breadcrumb_PartnerCommunitiesSecure_URL from '@salesforce/label/c.PRM_Breadcrumb_PartnerCommunitiesSecure_URL';
 import PRM_Breadcrumb_PartnerHome_Text from '@salesforce/label/c.PRM_Breadcrumb_PartnerHome_Text';
 import PRM_Breadcrumb_PartnerHome_URL from '@salesforce/label/c.PRM_Breadcrumb_PartnerHome_URL';
 import PRM_Breadcrumb_PartnerUniversity_Text from '@salesforce/label/c.PRM_Breadcrumb_PartnerUniversity_Text';
 import PRM_Breadcrumb_SalesEnablementResources from '@salesforce/label/c.PRM_Breadcrumb_SalesEnablementResources';
 import PRM_Breadcrumb_SalesEnablementResources_URL from '@salesforce/label/c.PRM_Breadcrumb_SalesEnablementResources_URL';
 import PRM_Breadcrumb_ViewDashboard_Text from '@salesforce/label/c.PRM_Breadcrumb_ViewDashboard_Text';
 import PRM_DDRBreadCrumb_Text from '@salesforce/label/c.PRM_DDRBreadCrumb_Text';
 import PRM_Dashboard_Url from '@salesforce/label/c.PRM_Dashboard_Url';
 import PRM_IPA_Domain from '@salesforce/label/c.PRM_IPA_Domain';
 import PRM_Leads_Domain from '@salesforce/label/c.PRM_Leads_Domain';
 import PRM_Manage_Solutions from '@salesforce/label/c.PRM_Manage_Solutions';
 import PRM_Partner_University_URL from '@salesforce/label/c.PRM_Partner_University_URL';
 import PRM_DDRBreadCrumb_URL from '@salesforce/label/c.PRM_DDRBreadCrumb_URL';
 import IPA_DealRegistrationText from '@salesforce/label/c.IPA_DealRegistrationText';
 import IPA_DealRegistrationHomeUrl from '@salesforce/label/c.DealReg_Home_Url';
 import { whichSite } from 'c/coreIntcSso';
 





/**
 * Creates a JSON object representing the breadcrumbs to be displayed.
 * @param {string} site  The site displaying the breadcrumbs ("IPA", "Leads").
 * @param {string} pageUrl  The URL for the page (without querystring parameters).
 * @returns {Object} A JSON object representing the breadcrumbs to be displayed.
 * @public
 */
const getBreadcrumbsData = (site, pageUrl) => {
  // Create an array for the top level children
  const children = [
    {
      "id": 2,
      "selected": false,
      "text": PRM_Breadcrumb_PartnerHome_Text,
      "url": PRM_Breadcrumb_PartnerHome_URL
    }
  ];

  // Manage Benefits
  const manageBenefitsData = {
    "type": "comm__namedPage",
    "attributes": {
      "pageName": "home"
    }
  };
  const manageBenefitsBreadcrumb = createChildBreadcrumb(site, pageUrl, 'IPA', 3, PRM_Breadcrumb_PartnerBenefit_URL,
   manageBenefitsData, PRM_Breadcrumb_PartnerBenefit_Txt);
  if (site === 'Leads') {
    // Need to add My Leads breadcrumb under Manage Benefits when in the Leads portal
    manageBenefitsBreadcrumb.selected = true;
    const myLeadsBreadcrumb = createChildBreadcrumb(site, pageUrl, 'Leads', 9, PRM_Breadcrumb_MyLeads_URL, manageBenefitsData, PMP_Leads_Heading);
    const myDDRPage = createChildBreadcrumb(site, pageUrl, null, 10, PRM_DDRBreadCrumb_URL, null, PRM_DDRBreadCrumb_Text,'_blank');
    const myDealRegPage = createChildBreadcrumb(site, pageUrl, null, 11, IPA_DealRegistrationHomeUrl, null, IPA_DealRegistrationText,'_blank');
    manageBenefitsBreadcrumb.children = [myLeadsBreadcrumb, myDDRPage,myDealRegPage];

  }

  children.push(manageBenefitsBreadcrumb);

  // View Dashboard
  const dashboardData = {
    "type": "comm__namedPage",
    "attributes": {
      "pageName": "dashboard"
    }
  };

 /* const ddrData = {
    "type": "comm__namedPage",
    "attributes": {
      "pageName": "ddr"
    }
  };*/
  children.push(createChildBreadcrumb(site, pageUrl, 'IPA', 4, PRM_Dashboard_Url, dashboardData, PRM_Breadcrumb_ViewDashboard_Text));
  
  // External sites
  /*TWC727-841 - Utkarsh - Changed order as part of the story*/
  children.push(createChildBreadcrumb(site, pageUrl, null, 5, IPA_VisitMarketplace_bnftlnk_Link, null, PMP_Breadcrumb_Header, '_blank'));
  children.push(createChildBreadcrumb(site, pageUrl, null, 6, PRM_Breadcrumb_SalesEnablementResources_URL, null, 
  PRM_Breadcrumb_SalesEnablementResources, '_blank'));
  children.push(createChildBreadcrumb(site, pageUrl, null, 7, PRM_Partner_University_URL, null, PRM_Breadcrumb_PartnerUniversity_Text, '_blank'));
  children.push(createChildBreadcrumb(site, pageUrl, null, 8, PRM_Breadcrumb_MarketingStudio_URL, null, PRM_Breadcrumb_MarketingStudio_Text, '_blank'));
  //children.push(createChildBreadcrumb(site, pageUrl, null, 9, PRM_Breadcrumb_PartnerCommunitiesSecure_URL, null,
   //PRM_Breadcrumb_PartnerCommunities_Text, '_blank')); 
  // children.push(createChildBreadcrumb(site, pageUrl, null, 10, PRM_Breadcrumb_SubmitSolutionSecure_URL, null, PRM_Manage_Solutions, '_blank')); breadcrumb removal
  children.push(createChildBreadcrumb(site, pageUrl, null, 11, PRM_Breadcrumb_AboutMembership_URL, null, PRM_Breadcrumb_AboutMembership_Txt, '_blank'));
  //children.push(createChildBreadcrumb(site, pageUrl, null, 13, PRM_DDRBreadCrumb_URL, null, PRM_DDRBreadCrumb_Text,'_blank'));
  // Get Help
  children.push(createChildBreadcrumb(site, pageUrl, null, 12, PRM_Breadcrumb_GetHelp_URL, null, PRM_Breadcrumb_GetHelp_Text));
  console.log('Children==>' + JSON.stringify(children));
  /*TWC727-841- END*/
  // Create the top level breadcrumb and add the array as its children
  const breadcrumbs = {
    breadcrumb: {
      "id": 1,
      "selected": true,
      "text": PRM_Breadcrumb_IPA_Text,
      "url":PRM_Breadcrumb_IPA_URL,
      "children": children
    }
  };

  return breadcrumbs;
}



/**
 * Creates a JSON object representing the a top-level child breadcrumb.
 * @param {string} site  The site displaying the breadcrumbs ("IPA", "Leads").
 * @param {string} pageUrl  The URL for the page (without querystring parameters).
 * @param {string} parentSite  The site the breadcrumb page resides ("IPA", "Leads").
 * @param {any} id  The ID of the breadcrumb.
 * @param {string} url  The URL for the breadcrumb.
 * @param {Object} data  A data object to be used by the Salesforce navigation API.
 * This will be converted to a URL by the coreIntcBreadcrumbs component.
 * @param {string} text  The text of the breadcrumb.
 * @param {string} target  The target attribute to add to the breadcrumb's anchor tag.
 * @returns {Object} A JSON object representing a top-level child breadcrumb.
 * @public
 */
const createChildBreadcrumb = (site, pageUrl, parentSite, id, url, data, text, target) => {
  // Default properties
  const child = {
    id,
    text,
  };

  // Determine if the user is currently on the page
  console.log('here==>' + pageUrl + 'and' + site + 'and' + url);
  switch (pageUrl) {
    case 'IPA-home':
      if (site === 'IPA' && parentSite === 'IPA' && url === PRM_Breadcrumb_PartnerBenefit_URL) {
        console.log('1');
        child.selected = true;
      }
      break;
    case 'Leads-home':
      if (site === 'Leads' && parentSite === 'Leads' && url === PRM_Breadcrumb_MyLeads_URL) {
        console.log('2');
        child.selected = true;
      }
      break;
    default:
      if (url) {
        console.log('3');
        child.selected = pageUrl.endsWith(url);
      }
  }

  // Add target if it was supplied
  if (target) {
    child.target = target;
  }

  // Check if it is a Salesforce page
  if (data) {
    // Yes so need to add domain when going from IPA to Leads and vice-versa.
    // Also can't use the Salesforce navigation API since going to a different
    // community.
    if (site === 'Leads' && parentSite === 'IPA') {
      child.url = PRM_IPA_Domain + url;
    } else if (site === 'IPA' && parentSite === 'Leads') {
      child.url = PRM_Leads_Domain + url;
    } else {
      // Not switching sites so use Salesforce navigation API
      child.data = {
        "sfData": data
      };
    }
  } else if (url) {
    // Not a Salesforce page so just use URL
    child.url = url;
  }

  return child;
}



/**
  * Returns IPA's BreadcrumbNavigation object within a promise.
  * @returns {Promise} A promise that will resolve with IPA's BreadcrumbNavigation object.
  * @private
  */
export const getIpaBreadcrumbs = () => {
  const site = whichSite();
  if (site !== 'IPA' && site !== 'Leads') {
    return Promise.resolve();
  }

  let url = window.location.href;
  url = (url.indexOf("?") !== -1) ? url.split("?")[0] : url;
  const home=url.split("/s/");
  if(home[1]===null || home[1]===''){
    url = site + '-home';
  }
  
  return Promise.resolve(getBreadcrumbsData(site, url));
}