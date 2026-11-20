import { LightningElement, wire, track } from "lwc";
import LOCALE from "@salesforce/i18n/locale";

import getCompanyAndRoleInfo from "@salesforce/apex/PRM_CompanyProfileController.getCompanyAndRoleInfo";
import updateAccountInfo from "@salesforce/apex/PRM_CompanyProfileController.updateAccountInfo";
import saveWhitelistedDomains from "@salesforce/apex/PRM_CompanyProfileController.saveWhitelistedDomains";
import savePartnerAssist from "@salesforce/apex/PRM_CompanyProfileController.savePartnerAssist";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import resourceName from "@salesforce/resourceUrl/PRM_CP_GlobalIcon";
import { loadStyle } from "lightning/platformResourceLoader";
import PointsOptInEligiblePartners from "@salesforce/label/c.PointsOptInEligiblePartners";
import PRM_CompanyInformation from "@salesforce/label/c.PRM_CompanyInformation";
import PRM_ContactInformation from "@salesforce/label/c.PRM_ContactInformation";
import PRM_CompanyName from "@salesforce/label/c.PRM_CompanyName";
import PRM_MailingAddress from "@salesforce/label/c.PRM_MailingAddress";
import PRM_PhysicalAddress from "@salesforce/label/c.PRM_PhysicalAddress";
import PRM_Country from "@salesforce/label/c.PRM_Country";//TWC729-7727
import PRM_Website from "@salesforce/label/c.PRM_Website";
import PRM_Role from "@salesforce/label/c.PRM_Role";
import PRM_BusinessPhone from "@salesforce/label/c.PRM_BusinessPhone";
import PRM_PartnerInformation from "@salesforce/label/c.PRM_PartnerInformation";
import PRM_AccountNumber from "@salesforce/label/c.PRM_AccountNumber";
import PRM_SpecialtyLabel from "@salesforce/label/c.PRM_SpecialtyLabel";
import PRM_Manage from "@salesforce/label/c.PRM_Manage";
import PRM_AcceptableDomains from "@salesforce/label/c.PRM_AcceptableDomains";
import PRM_PointsOptIn from "@salesforce/label/c.PRM_PointsOptIn";
import PRM_Grouping from "@salesforce/label/c.PRM_Grouping";
import PRM_SelectBenefits from "@salesforce/label/c.PRM_SelectBenefits";
import PRM_NDA from "@salesforce/label/c.PRM_NDA";
import PRM_EditPartnerInfo from "@salesforce/label/c.PRM_EditPartnerInfo";
import PRM_AcceptableDomains_Info from "@salesforce/label/c.PRM_AcceptableDomains_Info";
import PRM_AcceptableDomains_Caution from "@salesforce/label/c.PRM_AcceptableDomains_Caution";
import PRM_AcceptableDomains_HelpText from "@salesforce/label/c.PRM_AcceptableDomains_HelpText";
import PRM_ValidDomain_Msg from "@salesforce/label/c.PRM_ValidDomain_Msg";
import PRM_BlacklistedDomain_Msg from "@salesforce/label/c.PRM_BlacklistedDomain_Msg";
import PRM_DuplicateValue_Msg from "@salesforce/label/c.PRM_DuplicateValue_Msg";
import PRM_AccountUpdated_Msg from "@salesforce/label/c.PRM_AccountUpdated_Msg";
import PRM_DomainBlank_Msg from "@salesforce/label/c.PRM_DomainBlank_Msg";
import PRM_MaxDomains_Msg from "@salesforce/label/c.PRM_MaxDomains_Msg";
import PRM_ReleaseInfo from "@salesforce/label/c.PRM_ReleaseInfo";
import PRM_PartnerAssist_Info from "@salesforce/label/c.PRM_PartnerAssist_Info";
import PRM_OptIn from "@salesforce/label/c.PRM_OptIn";
import PRM_Disti1 from "@salesforce/label/c.PRM_Disti1";
import PRM_Disti2 from "@salesforce/label/c.PRM_Disti2";
import PRM_SelectOption from "@salesforce/label/c.PRM_SelectOption";
import PRM_DistiBlank_Msg from "@salesforce/label/c.PRM_DistiBlank_Msg";
import PRM_DistinctDistis_Msg from "@salesforce/label/c.PRM_DistinctDistis_Msg";
import PRM_Remove_ButtonLabel from "@salesforce/label/c.PRM_Remove_ButtonLabel";
import PRM_Save_ButtonLabel from "@salesforce/label/c.PRM_Save_ButtonLabel";
import PRM_Cancel_ButtonLabel from "@salesforce/label/c.PRM_Cancel_ButtonLabel";
import PRM_Edit_ButtonLabel from "@salesforce/label/c.PRM_Edit_ButtonLabel";
import PRM_Add_ButtonLabel from "@salesforce/label/c.PRM_Add_ButtonLabel";
import PRM_AcceptableDomain_MaxLimit from "@salesforce/label/c.PRM_AcceptableDomain_MaxLimit";
import PRM_CP_ManageSpeciality_URL from "@salesforce/label/c.PRM_CP_ManageSpeciality_URL";
import PRM_ContactUSURL from "@salesforce/label/c.PRM_ContactUSURL";
import PRM_ContactUsForUpdatesTxt from "@salesforce/label/c.PRM_ContactUsForUpdatesTxt";
import onBoardingRedirect from "@salesforce/apex/PRM_IPAPartnerOnboarding_CTRL.onBoardingRedirect";
export default class CompanyInfo extends LightningElement {
		@track companyName;
		@track naturalGrouping;
		@track website;
		@track ndaNumber;
		@track phone;
		@track physicalAddressLine1;
		@track physicalAddressLine2;
		@track physicalPostalCode;
		@track physicalCountry;
		@track showPhysicalAddress;
		@track mailingAddressLine1;
		@track mailingAddressLine2;
		@track mailingPostalCode;
		@track mailingCountry;
		@track showMailingAddress;
		@track spetialities = [];
		@track benifits = [];
		@track isEdit = false;
		@track isPrimary = false;
		@track oldPhone;
		@track oldWebsite;
		@track accountId;
		@track partnerRole;
		partnerRoleAPI;
		@track contactId;
		@track responces = [];
		@track cancelResponce = [];
		@track openmodel = false;
		@track isDuplicate = false;
		@track blacklistDomain = [];
		@track isBlacklistDomain = false;
		@track isDomainChange = false;
		@track partnerAssistModal = false;
		@track partnerAssistOption2;
		@track partnerAssistOption1;
		@track isPartnerAssistAvailable = false;
		@track countRecord = 0;
		@track partnerAssistMap = new Map();
		@track lastMap = new Map();
		@track distributers;
		@track partnerAssistArray = [];
		@track removedDisti1;
		@track removedDisti2;
		@track previousDistiIndex1;
		@track previousDistiIndex2;
		@track distributer1 = [];
		@track isSpeciality;
		@track isBenefit;
		@track pointsOptIn;
		@track optinCheckboxDisable = true;
		@track partnerAssistCheckbox = true;
		@track commonSelect = false;
		@track distributerSelectDisable = true;
		@track AccountNumber;
		raiseUIErrorMsg;
		showPointsOptIn = false;

		formLabels = {
				PointsOptInEligiblePartners,
				PRM_CompanyInformation,
				PRM_ContactInformation,
				PRM_CompanyName,
				PRM_MailingAddress,
				PRM_PhysicalAddress,
				PRM_Country,//TWC729-7727
				PRM_Website,
				PRM_Role,
				PRM_BusinessPhone,
				PRM_PartnerInformation,
				PRM_AccountNumber,
				PRM_SpecialtyLabel,
				PRM_Manage,
				PRM_AcceptableDomains,
				PRM_PointsOptIn,
				PRM_Grouping,
				PRM_SelectBenefits,
				PRM_NDA,
				PRM_EditPartnerInfo,
				PRM_AcceptableDomains_Info,
				PRM_AcceptableDomains_Caution,
				PRM_AcceptableDomains_HelpText,
				PRM_ValidDomain_Msg,
				PRM_BlacklistedDomain_Msg,
				PRM_DuplicateValue_Msg,
				PRM_AccountUpdated_Msg,
				PRM_DomainBlank_Msg,
				PRM_MaxDomains_Msg,
				PRM_ReleaseInfo,
				PRM_PartnerAssist_Info,
				PRM_OptIn,
				PRM_Disti1,
				PRM_Disti2,
				PRM_SelectOption,
				PRM_DistiBlank_Msg,
				PRM_DistinctDistis_Msg,
				PRM_Remove_ButtonLabel,
				PRM_Save_ButtonLabel,
				PRM_Cancel_ButtonLabel,
				PRM_Edit_ButtonLabel,
				PRM_Add_ButtonLabel,
				PRM_AcceptableDomain_MaxLimit,
				PRM_CP_ManageSpeciality_URL,
				PRM_ContactUSURL,
				PRM_ContactUsForUpdatesTxt
		};
		@track manageUrl = this.formLabels.PRM_CP_ManageSpeciality_URL;
		@track PartnerAssistInfo = this.formLabels.PRM_PartnerAssist_Info;
		pointsOptInPartners = this.formLabels.PointsOptInEligiblePartners.split(",");
		contactUSURL = this.formLabels.PRM_ContactUSURL.replace("LOCALE", LOCALE);

		constructor() {
				super();
				
				onBoardingRedirect()
						.then(data => {
						if(data) {
								var result = JSON.parse(data);
								if(!result.stepOneCompleted && result.redirectUrl != '') {
										window.location.href = result.redirectUrl;
								}
						}         
				})
						.catch(error => {
						console.log('error message',error);
				});
		}
		//to fetch the data from apex
		@wire(getCompanyAndRoleInfo)
		companyProfileInfo({ data, error }) {
				if (data) {
						var jsonString = JSON.parse(data).CompanyInfo;
						this.partnerRole = jsonString.PartnerRole;
						this.partnerRoleAPI = jsonString.PartnerRoleAPI;
						this.companyName = jsonString.Name;
						this.AccountNumber = jsonString.AccountNumber;
						this.naturalGrouping = jsonString.NaturalGrouping;
						this.website = jsonString.Website;
						this.ndaNumber = jsonString.NDA;
						this.contactId = jsonString.ContactId;
						this.phone = jsonString.Phone;
						this.isPrimary = jsonString.isPrimary;
						/*TWC729-7727
						this.physicalAddressLine1 = jsonString.PhysicalAddress.Street;
						//this.physicalAddressLine2 = jsonString.PhysicalAddress.City + ", " + jsonString.PhysicalAddress.State
						this.physicalAddressLine2 =
								jsonString.PhysicalAddress.City == null && jsonString.PhysicalAddress.State == null
								? null
						: jsonString.PhysicalAddress.City == null
								? jsonString.PhysicalAddress.State
						: jsonString.PhysicalAddress.State == null
								? jsonString.PhysicalAddress.City
						: jsonString.PhysicalAddress.City + ", " + jsonString.PhysicalAddress.State;
						this.physicalPostalCode = jsonString.PhysicalAddress.PostalCode;*/
						this.physicalCountry = jsonString.PhysicalAddress.Country;
						this.showPhysicalAddress =
								jsonString.PhysicalAddress.Street == null &&
								jsonString.PhysicalAddress.City == null &&
								jsonString.PhysicalAddress.State == null &&
								jsonString.PhysicalAddress.PostalCode == null &&
								jsonString.PhysicalAddress.Country == null
								? false
						: true;
						this.accountId = jsonString.AccountId;
						this.mailingAddressLine1 = jsonString.MailingAddress.Street;
						//this.mailingAddressLine2 = jsonString.MailingAddress.City + ", " + jsonString.MailingAddress.State;
						this.mailingAddressLine2 =
								jsonString.MailingAddress.City == null && jsonString.MailingAddress.State == null
								? null
						: jsonString.MailingAddress.City == null
								? jsonString.MailingAddress.State
						: jsonString.MailingAddress.State == null
								? jsonString.MailingAddress.City
						: jsonString.MailingAddress.City + ", " + jsonString.MailingAddress.State;
						this.mailingPostalCode = jsonString.MailingAddress.PostalCode;
						this.mailingCountry = jsonString.MailingAddress.Country;
						this.showMailingAddress =
								jsonString.MailingAddress.Street == null &&
								jsonString.MailingAddress.City == null &&
								jsonString.MailingAddress.State == null &&
								jsonString.MailingAddress.PostalCode == null &&
								jsonString.MailingAddress.Country == null
								? false
						: true;
						this.blacklistDomain = jsonString.BlacklistDomains;
						this.responces = jsonString.WhitelistedDomains;
						this.cancelResponce = [...this.responces];
						this.spetialities = jsonString.Specialties;
						this.isSpeciality = this.spetialities.length > 0 ? true : false;
						this.benifits = jsonString.SelectBenefits;
						this.isBenefit = this.benifits.length > 0 ? true : false;
						this.distributers = jsonString.PartnerAssistConcents.DistributerNames;
						if (jsonString.PartnerAssistConcents.PartnerAssists.length > 0) {
								this.isPartnerAssistAvailable = true;
						}

						for (let i = 0; i < this.distributers.length; i++) {
								let option = {
										label: this.distributers[i],
										value: this.distributers[i]
								};
								this.distributer1 = [...this.distributer1, option];
						}

						this.partnerAssistOption1 = jsonString.PartnerAssistConcents.PartnerAssists[0];
						this.partnerAssistOption2 = jsonString.PartnerAssistConcents.PartnerAssists[1];
						console.log("this.partnerAssistOption1==>" + this.partnerAssistOption1);
						console.log("this.partnerAssistOption2==>" + this.partnerAssistOption2);
						if (this.partnerAssistOption2 !== undefined && this.partnerAssistOption1 !== undefined) {
								console.log("partnerAssistOption==>In If");
								this.partnerAssistCheckbox = !this.partnerAssistOption1.ConsentIndicator && !this.partnerAssistOption2.ConsentIndicator ? false : true;
						} else if (this.partnerAssistOption1 !== undefined && this.partnerAssistOption2 === undefined) {
								console.log("partnerAssistOption==>In else If");
								this.partnerAssistCheckbox = !this.partnerAssistOption1.ConsentIndicator ? false : true;
						} else {
								console.log("partnerAssistOption==>In else");
						}
						this.distributerSelectDisable = this.partnerAssistCheckbox ? false : true;
						this.distributer1.splice(0, 0, {
								label: this.formLabels.PRM_SelectOption,
								value: "Select an Option"
						});

						if (
								this.pointsOptInPartners.find((role) => {
										return role === this.partnerRoleAPI;
								}) != undefined
						) {
								this.showPointsOptIn = true;
						}
						this.pointsOptIn = jsonString.OptInPoints;
				}
				if (error) {
						console.log("error", error);
				}

				
		}

		connectedCallback() {		
				Promise.all([loadStyle(this, resourceName + "/fontello/css/site-global-icons.css")])
						.then((result) => {
						console.log("css loaded");
				})
						.catch((err) => {
						console.log("error" + err);
				});
		}

		get specialityAndBenefit() {
				return this.isSpeciality || this.isBenefit ? true : false;
		}
		//when user click on contact info edit button
		handleContactInfo() {
				this.isEdit = true;
				this.oldPhone = this.phone;
				this.oldWebsite = this.website;
		}

		//on save on contact information edit
		onSave() {
				if (this.oldPhone !== this.phone || this.oldWebsite !== this.website) {
						updateAccountInfo({
								accountId: this.accountId,
								website: this.website,
								phone: this.phone
						})
								.then((result) => {
								this.showToast();
						})
								.catch((error) => {
								console.log("THis is the error: " + error);
						});
				}
				this.isEdit = false;
		}

		//on cancel of website and phone change
		onCancel() {
				//both if is to check weather there is a change in value or not
				if (this.oldPhone !== this.phone) {
						this.phone = this.oldPhone;
				}

				if (this.oldWebsite !== this.website) {
						this.website = this.oldWebsite;
				}
				this.isEdit = false;
		}

		//when user change the website
		websiteOnChange(event) {
				this.website = event.target.value;
		}

		//when user change the phone
		phoneOnChange(event) {
				this.phone = event.target.value;
		}

		//to show toast message when the record is updated
		showToast() {
				const event = new ShowToastEvent({
						message: this.formLabels.PRM_AccountUpdated_Msg,
						variant: "success",
						mode: "dismissable"
				});
				this.dispatchEvent(event);
		}

		showToastWarning() {
				const event = new ShowToastEvent({
						message: this.formLabels.PRM_DistiBlank_Msg,
						variant: "warning",
						mode: "dismissable"
				});
				this.dispatchEvent(event);
		}

		showToastBlankDomain() {
				const event = new ShowToastEvent({
						message: this.formLabels.PRM_DomainBlank_Msg,
						variant: "error",
						mode: "dismissable"
				});
				this.dispatchEvent(event);
		}

		showToastMoreDomain() {
				const event = new ShowToastEvent({
						message: this.formLabels.PRM_MaxDomains_Msg,
						variant: "warning",
						mode: "dismissable"
				});
				this.dispatchEvent(event);
		}

		showToastSelectDiff() {
				const event = new ShowToastEvent({
						message: this.formLabels.PRM_DistinctDistis_Msg,
						variant: "warning",
						mode: "dismissable"
				});
				this.dispatchEvent(event);
		}

		//--------------modal section--------------------

		openmodal() {
				this.openmodel = true;
		}

		//after clicking close button
		closeModal() {
				this.responces.splice(0, this.responces.length);
				this.responces = [...this.cancelResponce];
				this.openmodel = false;
				this.partnerAssistModal = false;
				this.optinCheckboxDisable = true;
				this.lastMap.clear();
				this.partnerAssistArray.splice(0, 2);
		}

		// to save the acceptable domain`
		saveModel() {
				if (this.responces.length > 0) {
						this.lastMap.clear();
						for (let i = 0; i < this.responces.length; i++) {
								this.lastMap.set(this.responces[i].RecordId, this.responces[i].WhiteListName);
						}
				} else {
						this.lastMap.clear();
				}

				let temp = this.template;
				let isPassRegex = true;
				let addButton = temp.querySelector(".add_domain");
				let isBlankValue = false;
				for (let val of this.responces) {
						if (val.WhiteListName.length == 0) {

								isBlankValue = true;
								break;
						}

						if (this.blacklistDomain.includes(val.WhiteListName)) {
								this.isBlacklistDomain = true;
								break;
						}

						if(!this.CheckIsValidDomain(val.WhiteListName)){
								isPassRegex=false;
								break;
						}	
				}
				console.log('isPassRegex',isPassRegex);
				if (isBlankValue && this.isDuplicate) {
						isBlankValue = false;
				}

				if (isBlankValue) {
						this.showToastBlankDomain();
						addButton.disabled = true;
				} else {
						addButton.disabled = false;
				}

				if (!isBlankValue && !this.isDuplicate && !this.isBlacklistDomain && isPassRegex) {
						saveWhitelistedDomains({
								AcctId: this.accountId,
								whitelistedDomain: [...this.lastMap] //converting map to List<List<String>> and passing it to apex
						})
								.then((result) => {
								location.reload(true);
						})
								.catch((error) => {
								console.log("THis is the error: " + JSON.stringify(error));
						});
						this.closeModal();
				}
		}

		handleAcceptDomainChange(event) {
				this.isDomainChange = true;
		}

		handleAcceptDomainBlur(event) {
				let temp = this.template;
				let addButton = temp.querySelector(".add_domain");
				let inputDomain = event.target.value;
				let mySelector = `div[data-val='${event.target.title}']`;
				let selectedRow = this.template.querySelector(mySelector);
				let selectorDiv = `div[data-rec='${event.target.title}']`;
				let selectedDiv = this.template.querySelector(selectorDiv);
				let flag = true;
				if (this.isDomainChange) {
						this.isDomainChange = false;
						let isValid = true;
						if (!this.CheckIsValidDomain(inputDomain)) {
								console.log("check" + inputDomain);
								isValid = false;
								selectedRow.textContent = this.formLabels.PRM_ValidDomain_Msg;
								selectedDiv.style.border = "1px solid red";
								addButton.disabled = true;
						}
						//to check weather domain is blacklisted or not
						else if (this.blacklistDomain.includes(inputDomain)) {
								this.isDuplicate = false;
								this.isBlacklistDomain = true;
								selectedRow.textContent = this.formLabels.PRM_BlacklistedDomain_Msg;
								selectedDiv.style.border = "1px solid red";
								addButton.disabled = true;
						} else {
								if (isValid) {
										selectedRow.innerHTML = "";
										selectedDiv.style.border = "";
								}
								this.isBlacklistDomain = false;
								addButton.disabled = false;
						}

						if (inputDomain !== "") {
								for (let v of this.responces) {
										if (v.WhiteListName === inputDomain) {
												flag = false;
												break;
										}
								}

								//to check duplicacy
								if (flag) {
										this.isDuplicate = false;
										addButton.disabled = false;
										this.responces[event.target.name] = {
												RecordId: event.target.title,
												WhiteListName: event.target.value
										};
								} else {
										this.isDuplicate = true;
										event.target.label = "Duplicate Value";
										addButton.disabled = true;
								}
						} else {
								this.isDuplicate = false;
								this.responces[event.target.name] = {
										RecordId: event.target.title,
										WhiteListName: event.target.value
								};
								addButton.disabled = true;
						}
				}
		}

		//remove the whitelist domain

		removeDomain(event) {
				let temp = this.template;
				if (event.target.name === this.responces.length - 1) {
						let addButton = temp.querySelector(".add_domain");
						addButton.disabled = false;
				}
				this.responces.splice(event.target.name, 1);
		}

		addDomainTextField(event) {
				if (this.responces.length === 0) {
						this.responces.push({
								RecordId: "new" + this.countRecord,
								WhiteListName: ""
						});
						this.countRecord++;
				} else if (this.responces.length > 0) {
						if (this.responces[this.responces.length - 1].WhiteListName !== "" && !this.isBlacklistDomain) {
								event.target.disabled = false;
								if (this.responces.length < PRM_AcceptableDomain_MaxLimit) {
										//change 10 to custom label
										this.responces.push({
												RecordId: "new" + this.countRecord,
												WhiteListName: ""
										});
										this.countRecord++;
								} else {
										this.showToastMoreDomain();
								}
						} else {
								event.target.disabled = true;
						}
				}
				console.log("Responces--" + this.responces);
		}

		//*******************Partner Assist*******************************
		openPartnerAssistModal() {
				this.partnerAssistModal = true;
				this.optinCheckboxDisable = false;
				this.partnerAssistArray[0] = this.partnerAssistOption1.DistributerName;
				if (this.partnerAssistOption2 !== undefined) {
						this.partnerAssistArray[1] = this.partnerAssistOption2.DistributerName;
				}
		}

		onAssistCheckbox(event) {
				this.partnerAssistMap.set(event.target.name, event.target.checked);
		}

		changeHandler1(event) {
				const field = event.target.name;
				if (field === "optionSelect") {
						let val = event.target.value;
						if (val !== "Select an Option") {
								console.log("val1-------->", val);
								this.partnerAssistArray[0] = val;
								if (this.partnerAssistArray[1] === val) {
										this.showToastSelectDiff();
										this.commonSelect = true;
								} else {
										this.partnerAssistArray[0] = val;
										this.commonSelect = false;
								}
						} else if (val === "Select an Option") {
								console.log("val1 --- null");
								this.partnerAssistArray[0] = "";
								this.commonSelect = false;
						}
				}
		}

		changeHandler2(event) {
				const field = event.target.name;
				if (field === "optionSelect") {
						let val = event.target.value;
						if (val !== "Select an Option") {
								console.log("val2-------->", val);
								this.partnerAssistArray[1] = val;
								if (this.partnerAssistArray[0] === val) {
										this.showToastSelectDiff();
										this.commonSelect = true;
								} else {
										this.partnerAssistArray[1] = val;
										this.commonSelect = false;
								}
						} else if (val === "Select an Option") {
								console.log("val2 --- null");
								this.partnerAssistArray[1] = "";
								this.commonSelect = false;
						}
				}
		}

		partnerAssistCheck(event) {
				this.partnerAssistCheckbox = event.target.checked;
				this.distributerSelectDisable = event.target.checked ? false : true;
		}

		savePartAsstModel() {
				console.log("val1 --- " + this.partnerAssistArray[0]);
				console.log("val2 --- " + this.partnerAssistArray[1]);
				if (this.commonSelect !== false) {
						this.showToastSelectDiff();
				} else if (this.partnerAssistArray[0] === "") {
						this.showToastWarning();
				} else if (this.commonSelect === false && this.partnerAssistArray[0] !== "") {
						savePartnerAssist({
								AcctId: this.accountId,
								partnerAssistPrimary: this.partnerAssistArray[0],
								partnerAssistSecoundry: this.partnerAssistArray[1],
								optIn: this.partnerAssistCheckbox,
								ContactId: this.contactId
						})
								.then((result) => {
								location.reload(true);
						})
								.catch((error) => {
								console.log("THis is the error: " + error);
						});
						this.closeModal();
				}
		}
		CheckIsValidDomain(domain) {
				let vsplit = domain.split(".");
				let isValid = true;
				if (domain.length > 80) {
						isValid = false;
				} else if (vsplit.length <= 1) {
						isValid = false;
				}else if(domain.length>1 && (domain.includes("@") || domain.includes(" ") || domain.includes("	"))){
						isValid = false;
				}
				else if (vsplit.length >1){
						vsplit.forEach(function(element) {
								if(element.length<1){
										isValid = false;
										return isValid;
								}
						});
				}
				return isValid;
		}
}