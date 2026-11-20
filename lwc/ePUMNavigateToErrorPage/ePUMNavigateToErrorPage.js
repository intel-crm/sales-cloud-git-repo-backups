import { LightningElement } from "lwc";
import isLoggedInUserPAOrPAD from "@salesforce/apex/EPUM_SearchContact.isLoggedInUserPAOrPAD";
import TCRedirection from "@salesforce/apex/EPUM_SearchContact.TCRedirection";
import EPUM_IPAUrl from "@salesforce/label/c.EPUM_IPAUrl";
import EPUM_IPAPostLaunch from "@salesforce/label/c.EPUM_IPAPostLaunch";
//import homeOverviewLink from "@salesforce/label/c.PRM_RedirectToOverViewPage";
import EPUM_AccessDeniedExemptionProfile from "@salesforce/label/c.EPUM_AccessDeniedExemptionProfile";

export default class EPUMNavigateToErrorPage extends LightningElement {
  label = {
    EPUM_IPAUrl,
    EPUM_AccessDeniedExemptionProfile,
    //homeOverviewLink,
    EPUM_IPAPostLaunch
  };

  constructor() {
    super();
    // Check Logged in User having partner Admin or Partner Admin Delegate role,if not then navigate to error page
    isLoggedInUserPAOrPAD()
      .then((result) => {
        if (result !== undefined) {
          if (
            !result.isPartnerAdminDelegate &&
            !result.isPartnerAdmin &&
            !this.label.EPUM_AccessDeniedExemptionProfile.includes(
              result.loggedInUserProfile
            )
          ) {
            var url =
              window.location.origin + this.label.EPUM_IPAUrl + "accessdenied";
            window.open(url, "_self");
          }
        }
      })
      .catch((error) => {
        console.log("result error" + JSON.stringify(error));
       // this.isLoading = false;
      });
    /* -----------T&C Redirection- If T&C not accepted navigates to PostLauch Page @ DRACO -28/1/2021------------*/

    TCRedirection()
      .then((result) => {
        console.log("TCRedirection Result" + JSON.stringify(result));
        if (result) {
          if (result == "tandc") {
            //Navigate to home page
            var url =
            window.location.origin + this.label.EPUM_IPAUrl + this.label.EPUM_IPAPostLaunch ;
          window.open(url, "_self");
        //    window.location.href = homeOverviewLink;
            // 'https://www.intel.com/content/www/us/en/secure/partner-alliance/overview.html';
          }
        }
      })
      .catch((error) => {
        console.log("TCRedirection error" + JSON.stringify(error));
        //this.isLoading = false;
      });
    /* -----------------T&C Redirection-DRACO End--------------------------- */
  }
}