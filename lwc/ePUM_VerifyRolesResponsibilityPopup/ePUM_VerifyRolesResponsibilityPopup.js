import { LightningElement, wire, track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import availableRoles from '@salesforce/apex/EPUM_ContactEntitlement_Util.getAvailableRoles';
import getLogoUrl from '@salesforce/apex/EPUM_ContactEntitlement_Util.getLogoUrl';
import MEMBER_IMAGES from '@salesforce/resourceUrl/EPUM_MemberLogo';
import GOLD_IMAGES from '@salesforce/resourceUrl/EPUM_GoldLogo';
import TITANIUM_IMAGES from '@salesforce/resourceUrl/EPUM_TitaniumLogo';

//import labels
import EPUM_VerifyrolesandrespTitle from '@salesforce/label/c.EPUM_VerifyrolesandrespTitle';
import EPUM_Responsibilities from '@salesforce/label/c.EPUM_Responsibilities';
import EPUM_Employee from '@salesforce/label/c.EPUM_Employee';
import EPUM_AsThe from '@salesforce/label/c.EPUM_AsThe';
import EPUM_RolesResPopupMsg from '@salesforce/label/c.EPUM_RolesResPopupMsg';
import EPUM_ManagePersonnel from '@salesforce/label/c.EPUM_ManagePersonnel';
import EPUM_Close from '@salesforce/label/c.EPUM_Close';
import EPUM_IPAUrl from '@salesforce/label/c.EPUM_IPAUrl';

export default class EPUM_VerifyRolesResponsibilityPopup extends NavigationMixin(LightningElement) {

    label = {        
        EPUM_VerifyrolesandrespTitle,
        EPUM_Responsibilities,
        EPUM_Employee,
        EPUM_AsThe,
        EPUM_RolesResPopupMsg,
        EPUM_ManagePersonnel,
        EPUM_Close,
        EPUM_IPAUrl
    };



    name;
    @track img;
    managepersonalLink = window.location.origin + this.label.EPUM_IPAUrl + 'manage-personnel';

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.name = data.fields.Name.value;
        }
    }

    openRoles = [];

    @track isModalOpen = false;
    @track roleDesc;
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;

    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        var url = window.location.origin + this.label.EPUM_IPAUrl;
        window.open(url,  "_self"); 
    }

    goToEPUMPage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'manage-personnel'
            }
        });
    }

    @wire(availableRoles)
    availableRoles({ error, data }) {

        if (data) {
            var availRoles = [];
            for (let key in data) {
                var role = data[key];
                var empName = "Open";
                if (role === "PRIMARY") {
                    role = "Partner Admin";
                    empName = this.name + " (You)";
                    this.roleDesc = role;
                    //  roleDesc = "As the Partner Admin for your company's account, you can define the roles and responsibilities of other members of your team.";
                } else if (role === "PRIMCONTDEL") {
                    role = "Partner Admin Delegate";
                    empName = this.name + " (You)";
                    this.roleDesc = role;
                    //  roleDesc ="As the Partner Admin Delegate for your company's account, you can define the roles and responsibilities of other members of your team.";
                }

                availRoles.push({
                    "role": role,
                    "emp": empName
                });
            }
            this.openRoles = availRoles;
        } else {
            console.log("coreEntitlements Error" + JSON.stringify(error));
        }

    }

    @wire(getLogoUrl)
    getLogoUrl({ error, data }) {

        if (data) {
            if (data == 'Member') {
                this.img = MEMBER_IMAGES;
            } else if (data == 'Gold') {
                this.img = GOLD_IMAGES;
            } else if (data == 'Titanium') {
                this.img = TITANIUM_IMAGES;
            }
        } else {
            console.log("coreEntitlements Error" + JSON.stringify(error));
        }

    }
}