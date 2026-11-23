import { LightningElement, track } from 'lwc';
import HeaderLabel from '@salesforce/label/c.IPA_AccessDen_Header';
import myResource from '@salesforce/resourceUrl/PMP_Resources';
import HeaderHome from '@salesforce/label/c.IPA_Home_header';
import ContentLabel from '@salesforce/label/c.IPA_AccessDen_txt1';
import ChatLink from '@salesforce/label/c.IPA_Chat_Support';
import RegistrationLink from '@salesforce/label/c.IPA_Registration_Form_link';
import chatLinkText from '@salesforce/label/c.IPA_AccessDen_Text1';
import registerLinkText from '@salesforce/label/c.IPA_AccessDen_Text2';
import loginLink from '@salesforce/label/c.IPA_AccessDen_Text5';
import registerLinkContent from '@salesforce/label/c.IPA_AccessDen_Text6';
import loginURL from '@salesforce/label/c.IPA_AccessDen_Text7';
import chatLinkContent from '@salesforce/label/c.IPA_AccessDen_Text8';
import logInIcon from '@salesforce/resourceUrl/loggedInIcon';
import logScreen from '@salesforce/resourceUrl/loginScreenIcon';
import helpImg from '@salesforce/resourceUrl/helpIconImg';
import completeRegstr from '@salesforce/label/c.Complete_Registration';
import loginto from '@salesforce/label/c.IPA_Login';
import contactUs from '@salesforce/label/c.Contact_Us';
import regLink from '@salesforce/label/c.PRM_IPA_Registration_Form_link_CidaaS';
import chatSupport from '@salesforce/label/c.PRM_IPA_Chat_Support_CiDaaS';
import accDenied from '@salesforce/label/c.PRM_IPA_AccessDen_Text5_CiDaaS';
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
export default class IpaIntelAccessDenied extends LightningElement {
  @track backgroundurl = `${myResource}/images/ipa-homepage-hub-hero-desktop-v4.jpg`;
  loginLogo = logInIcon;
  loginScreen = logScreen;
  helpLogo = helpImg;
  showContent = true;

    label = {
      ContentLabel,
      HeaderLabel,
      HeaderHome,
      chatLinkText,
      loginURL,
      loginLink,
      completeRegstr,
      loginto,
      contactUs
      
      
    };

    chatLinkStr;

    registerLinkStr;

    registrationStr;

    chatStr;

    loginStr;

   

    

    // ******* Functions ********
    /**
     * Called when the element is inserted into the DOM. Used to test if the user has already
     * visited this page in this session.
     *
     * @private
     */
    connectedCallback() {
      var registerLink;

      var register1Link;
  
      var lgnLink;
      
      var chatLink1;

      this.redirectTest();
      const registerStrMatch = this.matchString(registerLinkText);
      const cmpltRegisterStrMatch = this.matchString(registerLinkContent);
      
        registerLink = `<a href=${regLink}>${registerStrMatch}</a>`;
        register1Link = `<a href=${regLink}>${cmpltRegisterStrMatch}</a>`;
      
      
      const chatStrMatch1 = this.matchString(chatLinkContent);
      const loginLink1 = this.matchString(loginURL);
     
         lgnLink = `<a href=${accDenied}>${loginLink1}</a>`;
         chatLink1 = `<a href=${chatSupport}>${chatStrMatch1}</a>`;
      
      
      this.registerLinkStr = this.replaceString(registerLinkText, registerStrMatch, registerLink);
      console.log('string value1'+lgnLink);
      console.log(registerLinkContent);
      console.log(cmpltRegisterStrMatch);
      console.log(register1Link);
      console.log('string'+this.loginStr);
      this.registrationStr = this.replaceString(registerLinkContent, cmpltRegisterStrMatch, register1Link);
      this.chatStr = this.replaceString(chatLinkContent, chatStrMatch1, chatLink1);
      this.loginStr = this.replaceString(loginURL,loginLink1,lgnLink);
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
      return str.replaceAll(`{${replace}}`, replaceWith);
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