import { LightningElement, track } from 'lwc';
//import HeaderLabel from '@salesforce/label/c.IPA_Access_Denied_Header';
import myResource from '@salesforce/resourceUrl/PMP_Resources';
import HeaderHome from '@salesforce/label/c.Sales_Home_header';
//import ContentLabel from '@salesforce/label/c.IPA_AccessDen_Text1';
//import ChatLink from '@salesforce/label/c.IPA_Chat_Support';
//import RegistrationLink from '@salesforce/label/c.FPGA_Registration_link_for_Intel_FPGA_SSLC_Account_Access';
//import chatLinkText from '@salesforce/label/c.IPA_AccessDen_Text1';
import registerLinkText from '@salesforce/label/c.Sales_AccessDen_Text2';
import loginLink from '@salesforce/label/c.Sales_AccessDen_Text3';
import registerLinkContent from '@salesforce/label/c.Sales_AccessDen_Text4';
import loginURL from '@salesforce/label/c.Sales_AccessDen_Text5';
import chatLinkContent from '@salesforce/label/c.Sales_AccessDen_Text6';
import logInIcon from '@salesforce/resourceUrl/loggedInIcon';
import logScreen from '@salesforce/resourceUrl/loginScreenIcon';
import helpImg from '@salesforce/resourceUrl/helpIconImg';
import completeRegstr from '@salesforce/label/c.Sales_Complete_Registration';
//import loginto from '@salesforce/label/c.FPGA_Login';
import contactUs from '@salesforce/label/c.Sales_Contact_Us';
//import isCidaaSEnabled from '@salesforce/label/c.PRM_CiDaaS_Enabled';
import regLink from '@salesforce/label/c.Sales_FPGA_Registration_Link';
import chatSupport from '@salesforce/label/c.Sales_FPGA_Chat_Support_CiDaaS';
import accDenied from '@salesforce/label/c.Sales_HelpDocLink';
import intelEmployeeMsg from '@salesforce/label/c.Sales_TextForIntelEmploye';
import accessDeniedHeader from '@salesforce/label/c.Sales_AccessDeniedHeader';
import registrationMoreInfo from '@salesforce/label/c.Sales_RegistrationMoreInfo';

import {
  getCookieInfo,
  getCookieValue,
  getSSOSettings,
  setSSOAttemptCookie,
  whichSite,
} from 'c/coreIntcSso';

/**
 *
 */
export default class Sales_FPGA_IntelAccessDenied extends LightningElement {
  @track backgroundurl = `${myResource}/images/ipa-homepage-hub-hero-desktop-v4.jpg`;
  loginLogo = logInIcon;
  loginScreen = logScreen;
  helpLogo = helpImg;
    showContent = true;

    label = {
      HeaderHome,
      loginURL,
      loginLink,
      completeRegstr,
      contactUs,
      intelEmployeeMsg,
      accessDeniedHeader,regLink,registrationMoreInfo
      
    };

    chatLinkStr;

    registerLinkStr;

    registrationStr;

    chatStr;

    loginStr;

    registerLink;
    chatLink1;
    lgnLink;
    register1Link;

    // ******* Functions ********
    /**
     * Called when the element is inserted into the DOM. Used to test if the user has already
     * visited this page in this session.
     *
     * @private
     */
    connectedCallback() {
       this.redirectTest();
           //const chatStrMatch = this.matchString(chatLinkText);
      //const chatLink = `<a href=${ChatLink}>${chatStrMatch}</a>`;
      const registerStrMatch = this.matchString(registerLinkText);
      const cmpltRegisterStrMatch = this.matchString(registerLinkContent);
      const chatStrMatch1 = this.matchString(chatLinkContent);
      const loginLink1 = this.matchString(registrationMoreInfo);
      
        this.registerLink = `<a href=${regLink} style="text-decoration:underline;color:blue;">${registerStrMatch}</a>`;
        this.register1Link = `<a href=${regLink} style="text-decoration:underline;color:blue;">${cmpltRegisterStrMatch}</a>`;
        this.lgnLink = `<a href=${accDenied} style="text-decoration:underline;color:blue;">${loginLink1}</a>`;
        this.chatLink1 = `<a href=${chatSupport} style="text-decoration:underline;color:blue;"> ${chatStrMatch1}</a>`;
      
     this.registrationStr = this.replaceString(registerLinkContent, cmpltRegisterStrMatch, this.register1Link);

      //this.registrationStr='www.intel.com';
      //this.chatStr = 'www.intel.com';
      //this.loginStr ='www.intel.com';
      this.chatStr = this.replaceString(chatLinkContent, chatStrMatch1, this.chatLink1);
      this.loginStr = this.replaceString(registrationMoreInfo,loginLink1,this.lgnLink);
      console.log('string'+this.loginStr);
    }

    /**
     *  Check the string and replace {} braces with anchor tag link
     *
     *  @private
     *  @param {string} [str=''] string vaalue to be replaced.
     *  @param {string} [replace=''] replace string.
     *  @param {string} [replaceWith=''] string to be replaced with.
     *  @returns {string} returns string after replacing
     */
    replaceString(str = '', replace = '', replaceWith = '') {
      if (str === '' && replace === '' && replaceWith === '') {
        return '';
      }
      return str.replace(new RegExp(`{${replace}}`, 'gi'), replaceWith);
    }

    /**
     * Fetch the content from {} braces and return the the string
     *
     * @private
     * @param {string} [matchStr=''] string value in which to check the text insied {} braces.
     *
     * @returns {string} string - returns match string inside the curly braces.
     */
    matchString(matchStr = '') {
      if (matchStr === '') {
        return '';
      }
      const stringMatch = matchStr.match(/{([^}]+)}/);
      return stringMatch[1] === '' ? '' : stringMatch[1];
    }

    /**
     * Checks if the user has already been routed to this page. If so, it redirects out
     * so the user does not get stuck in a loop going between Salesforce and the login page.
     *
     * @private
     */
    redirectTest() {
      // Get the site even though this should only be IPA
      const site = whichSite();
      if (!site) {
        return;
      }

      // Exit if no settings returned
      const ssoSettings = getSSOSettings(site);
      if (!ssoSettings) {
        return;
      }

      // Determine if redirecting is enabled
      const loginFlag = ssoSettings.ighf.loginRedirect !== '0';

      // Do not run login when in Builder
      if (window.location.href.indexOf('livepreview') === -1 && loginFlag) {
        // Set the cookie - this will be picked up in the next loop through the page
        setSSOAttemptCookie(site);

        const redirectCookieName = getCookieInfo('AddressCookie', site);
        const redirectURL = getCookieValue(redirectCookieName);

        // Make sure we have a URL to go to
        if (redirectURL !== '') {
          const accessDeniedPage = getCookieInfo('AccessDeniedPage', site);

          // Check if the user has already visited this page in this session
          if (redirectURL.indexOf(accessDeniedPage) === -1) {
          // Yes so get them out of the loop
            this.showContent = false;
            window.location = redirectURL;
          }
        }
      }
    }
}