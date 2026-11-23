import {track} from 'lwc';
/**
  * Returns a mock version of IPA's BreadcrumbNavigation object.
  * @returns {BreadcrumbNavigation} A mock version of IPA's BreadcrumbNavigation object.
  * @private
  */

 //import getNavigationItems from '@salesforce/apex/PRM_IPABreadcrumbsService_CTRL.getNavigationItems';
 import PRM_Breadcrumb_IPA_Text from '@salesforce/label/c.PRM_Breadcrumb_IPA_Text';
 import PRM_Breadcrumb_IPA_URL from '@salesforce/label/c.PRM_Breadcrumb_IPA_URL';
 import PRM_Breadcrumb_PartnerHome_Text from '@salesforce/label/c.PRM_Breadcrumb_PartnerHome_Text';
 import PRM_Breadcrumb_PartnerHome_URL from '@salesforce/label/c.PRM_Breadcrumb_PartnerHome_URL';
 import PRM_Breadcrumb_SalesEnablementResources from '@salesforce/label/c.PRM_Breadcrumb_SalesEnablementResources';
 import PRM_Breadcrumb_SalesEnablementResources_URL from '@salesforce/label/c.PRM_Breadcrumb_SalesEnablementResources_URL';
 import PRM_Breadcrumb_ViewDashboard_Text from '@salesforce/label/c.PRM_Breadcrumb_ViewDashboard_Text';
 import PRM_Breadcrumb_GetHelp_Text from '@salesforce/label/c.PRM_Breadcrumb_GetHelp_Text';
 import PRM_Breadcrumb_GetHelp_URL from '@salesforce/label/c.PRM_Breadcrumb_GetHelp_URL';
 import PRM_Breadcrumb_PartnerBenefit_Txt from '@salesforce/label/c.PRM_Breadcrumb_PartnerBenefit_Txt';
 import PRM_Breadcrumb_CompanyProfile_Txt from '@salesforce/label/c.PRM_Breadcrumb_CompanyProfile_Txt';
 import PRM_Company_URL from '@salesforce/label/c.PRM_Company_URL';
 import PRM_Breadcrumb_AboutSpecialties_Txt from '@salesforce/label/c.PRM_Breadcrumb_AboutSpecialties_Txt';
 //import PRM_Breadcrumb_Dashboard_URL from '@salesforce/label/c.PRM_Breadcrumb_Dashboard_URL';
 import PRM_Breadcrumb_AboutMembership_Txt from '@salesforce/label/c.PRM_Breadcrumb_AboutMembership_Txt';
 import PRM_Breadcrumb_AboutMembership_URL from '@salesforce/label/c.PRM_Breadcrumb_AboutMembership_URL';
 import PRM_Dashboard_Url from '@salesforce/label/c.PRM_Dashboard_Url';
 import PRM_Breadcrumb_AboutSpecialties_URL from '@salesforce/label/c.PRM_Breadcrumb_AboutSpecialties_URL';
 //import EPUM_ManagePersonnel from '@salesforce/label/c.EPUM_ManagePersonnel';
 //import EPUM_ManagePersonnel_ApiName from '@salesforce/label/c.EPUM_ManagePersonnel_ApiName';

 import PMP_Leads_Heading from '@salesforce/label/c.PMP_Leads_Heading';
 import PRM_IPA_Domain from '@salesforce/label/c.PRM_IPA_Domain';
 import PRM_Leads_Domain from '@salesforce/label/c.PRM_Leads_Domain';
 import PRM_Breadcrumb_PartnerBenefit_URL from '@salesforce/label/c.PRM_Breadcrumb_PartnerBenefit_URL';
 import PRM_Breadcrumb_MyLeads_URL from '@salesforce/label/c.PRM_Breadcrumb_MyLeads_URL';
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
  const manageBenefitsBreadcrumb = createChildBreadcrumb(site, pageUrl, 'PSG', 3, PRM_Breadcrumb_PartnerBenefit_URL, manageBenefitsData, PRM_Breadcrumb_PartnerBenefit_Txt);
  if (site === 'Leads') {
    // Need to add My Leads breadcrumb under Manage Benefits when in the Leads portal
    manageBenefitsBreadcrumb.selected = true;
    const myLeadsBreadcrumb = createChildBreadcrumb(site, pageUrl, 'Leads', 9, PRM_Breadcrumb_MyLeads_URL, manageBenefitsData, PMP_Leads_Heading);
    manageBenefitsBreadcrumb.children = [myLeadsBreadcrumb];
  }
  children.push(manageBenefitsBreadcrumb);

  // View Dashboard
  const dashboardData = {
    "type": "comm__namedPage",
    "attributes": {
      "pageName": "dashboard"
    }
  };
  children.push(createChildBreadcrumb(site, pageUrl, 'PSG', 4, PRM_Dashboard_Url, dashboardData, PRM_Breadcrumb_ViewDashboard_Text));
  
  // Sales Enablement and About Membership
  children.push(createChildBreadcrumb(site, pageUrl, null, 5, PRM_Breadcrumb_SalesEnablementResources_URL, null, PRM_Breadcrumb_SalesEnablementResources, '_blank'));
  children.push(createChildBreadcrumb(site, pageUrl, null, 6, PRM_Breadcrumb_AboutMembership_URL, null, PRM_Breadcrumb_AboutMembership_Txt, '_blank'));

  // Company Profile
  const companyData = {
    "type": "comm__namedPage",
    "attributes": {
      "pageName": "companyprofile"
    }
  };
  children.push(createChildBreadcrumb(site, pageUrl, 'PSG', 7, PRM_Company_URL, companyData, PRM_Breadcrumb_CompanyProfile_Txt));
  
  // Get Help
  children.push(createChildBreadcrumb(site, pageUrl, null, 8, PRM_Breadcrumb_GetHelp_URL, null, PRM_Breadcrumb_GetHelp_Text));

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
  switch (pageUrl) {
    case 'PSG-home':
      if (site === 'PSG' && parentSite === 'PSG' && url === PRM_Breadcrumb_PartnerBenefit_URL) {
        child.selected = true;
      }
      break;
    case 'Leads-home':
      if (site === 'Leads' && parentSite === 'Leads' && url === PRM_Breadcrumb_MyLeads_URL) {
        child.selected = true;
      }
      break;
    default:
      if (url) {
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
    if (site === 'Leads' && parentSite === 'PSG') {
      child.url = PRM_IPA_Domain + url;
    } else if (site === 'PSG' && parentSite === 'Leads') {
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
  if (site !== 'PSG' && site != 'Leads') {
    return;
  }

  let url = window.location.href;
  url = (url.indexOf("?") !== -1) ? url.split("?")[0] : url;
  let home=url.split("/s/");
  if(home[1]==null || home[1]==''){
    url = site + '-home';
  }
  
  return Promise.resolve(getBreadcrumbsData(site, url));
}