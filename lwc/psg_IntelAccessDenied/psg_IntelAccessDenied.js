import { LightningElement, track } from "lwc";
import HeaderLabel from "@salesforce/label/c.PSG_AccessDen_Header"; 
import My_resource from "@salesforce/resourceUrl/PMP_Resources";
import HeaderHome from "@salesforce/label/c.PSG_Home_header"; 
import Sidetxt1Label from "@salesforce/label/c.PSG_AccessDen_Sidetxt1";
import SignInLabel from "@salesforce/label/c.PSG_AccesDen_SignIn";
import LearnMoreLabel from "@salesforce/label/c.PSG_AccessDen_LearnMore"; 
import ContentLabel from "@salesforce/label/c.PSG_AccessDen_txt1"; 
import {
  getCookieInfo,
  getCookieValue,
  getSSOSettings,
  setSSOAttemptCookie,
  whichSite
} from "c/coreIntcSso";

export default class IpaIntelAccessDenied extends LightningElement {
  @track backgroundurl =
    My_resource + "/images/ipa-homepage-hub-hero-desktop-v4.jpg";

  label = {
    ContentLabel,
    HeaderLabel,
    HeaderHome,
    Sidetxt1Label,
    SignInLabel,
    LearnMoreLabel
  };

  showContent = true;

  // ******* Functions ********
  /**
   * Called when the element is inserted into the DOM. Used to test if the user has already
   * visited this page in this session.
   * @private
   */
  connectedCallback() {
    this.redirectTest();
  }

  /**
   * Checks if the user has already been routed to this page. If so, it redirects out
   * so the user does not get stuck in a loop going between Salesforce and the login page.
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
    const loginFlag = ssoSettings.ighf.loginRedirect !== "0";

    //Do not run login when in Builder
    if (window.location.href.indexOf("livepreview") === -1 && loginFlag) {
      // Set the cookie - this will be picked up in the next loop through the page
      setSSOAttemptCookie(site);

      const redirectCookieName = getCookieInfo("AddressCookie", site);
      const redirectURL = getCookieValue(redirectCookieName);

      // Make sure we have a URL to go to
      if (redirectURL !== "") {
        const accessDeniedPage = getCookieInfo("AccessDeniedPage", site);

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