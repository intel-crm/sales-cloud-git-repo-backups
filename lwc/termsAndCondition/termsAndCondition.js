import { LightningElement, track, wire } from "lwc";
import isLoggedInUserPrimaryContact from "@salesforce/apex/PRM_CompanyProfileController.isLoggedInUserPrimaryContact";
import getMyCompanyLegalAgreemnent from "@salesforce/apex/PRM_CompanyProfileController.getMyCompanyLegalAgreemnent";
import PRM_LA_Error from "@salesforce/label/c.PRM_LA_Error";
import PRM_LA_No_Data from "@salesforce/label/c.PRM_LA_No_Data";
import PRM_LA_Header from "@salesforce/label/c.PRM_LA_Header";
import PRM_LA_Signed_Date from "@salesforce/label/c.PRM_LA_Signed_Date";
import PRM_org_login_URL from "@salesforce/label/c.PRM_org_login_URL";
import PRM_RedirectToOverViewPage from "@salesforce/label/c.PRM_RedirectToOverViewPage";
import PRM_RedirectToPostLaunchNonPrimary from "@salesforce/label/c.PRM_RedirectToPostLaunchNonPrimary";
import IPALegalTermsAndConditionStaticLink from "@salesforce/label/c.IPALegalTermsAndConditionStaticLink";
import getTermsandConditions from "@salesforce/apex/PRM_CompanyProfileController.getTermsandConditions";

import IPASecureHomepageLink from '@salesforce/label/c.IPA_Secure_Homepage_Link';

export default class TermsAndCondition extends LightningElement {
	
	agreements;
	error;
	rowCount = true;
	docList=[];
	openDoc;
	ShowDocList = false;
	formLabels = {
			PRM_LA_Error,
			PRM_LA_No_Data,
			PRM_LA_Header,
			PRM_LA_Signed_Date,
			PRM_org_login_URL,
			PRM_RedirectToOverViewPage,
			PRM_RedirectToPostLaunchNonPrimary,
			IPALegalTermsAndConditionStaticLink
	};	
	isPrimaryContact=false;
	isInternalUser=false;

	connectedCallback(){
		this.termsAndConditions();
	}

	@wire(isLoggedInUserPrimaryContact)
	checkLoggedinUserIsPrimaryContact({data,error}){
			if (data) {
					this.isPrimaryContact=data.isPrimary;
					this.isInternalUser=data.isInternalUser;

			}
			else if(error){
					console.log(error);
			}
	}

	@wire(getMyCompanyLegalAgreemnent)
	myCompanyLegalAgreemnent({ data, error }) {
			if (data) {
					var result = JSON.parse(data);
					this.rowCount = Object.keys(result).length > 0 ? true : false;
					if(this.rowCount<=0){
							if(this.isInternalUser)
							{
								location.replace(IPASecureHomepageLink + "/accessdenied");
							}
							else if(this.isPrimaryContact){
									location.replace(this.formLabels.PRM_RedirectToOverViewPage);
							}else{
									location.replace(this.formLabels.PRM_RedirectToPostLaunchNonPrimary);
							}
					}
					this.agreements = result;
			} else if (error) {
					this.error = error;
			}
	}

	/**
	 * fetching documents of type terms and conditions
	 */
	termsAndConditions(){
		getTermsandConditions().then(response => {
			if(response.length> 0){
				console.log('documents--->',response);
				this.docList=response;
				this.ShowDocList = true;
			}
		})       
		.catch(error => {
			console.log("Error in  saveUploadedDoc-->", error);
		});
	}


	/**
	 * @param {*} event 
	 * Generating link to download Document
	 */
	handleClick(event){
		this.openDoc = PRM_org_login_URL+'sfc/servlet.shepherd/document/download/'+event.target.dataset.name+'?operationContext=S1';	
	}

}