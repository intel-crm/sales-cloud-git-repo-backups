import { LightningElement, track  } from 'lwc';
import Pricing_contact_intel_Email from '@salesforce/label/c.Pricing_contact_intel_Email';
import Pricing_contact_intel_Email_Sub_Heading from '@salesforce/label/c.Pricing_contact_intel_Email_Sub_Heading';
import Pricing_Request_Support_URL from '@salesforce/label/c.Pricing_Request_Support_URL';
import Pricing_contact_intel_CTA_Email_SubHeading from '@salesforce/label/c.Pricing_contact_intel_CTA_Email_SubHeading';
import Pricing_contact_intel_Heading from '@salesforce/label/c.Pricing_contact_intel_Heading';
import IQR_Contact_us_RequestSupport from '@salesforce/resourceUrl/IQR_Contact_us_RequestSupport';

export default class Pricing_IntelContact extends LightningElement {
    @track contacts;

    label = {
       Pricing_contact_intel_Heading
    };

    contacts = [
        {
            label: Pricing_contact_intel_Email,
            copy: Pricing_contact_intel_Email_Sub_Heading,
            linkUrl: Pricing_Request_Support_URL,
            linkCopy: Pricing_contact_intel_CTA_Email_SubHeading,
            imgUrl: IQR_Contact_us_RequestSupport
        }
    ];
}