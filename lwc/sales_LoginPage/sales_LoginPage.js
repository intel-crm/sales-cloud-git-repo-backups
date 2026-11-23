import { LightningElement } from 'lwc';
import chatSupport from '@salesforce/label/c.Sales_FPGA_Chat_Support_CiDaaS';
import regLink from '@salesforce/label/c.Sales_FPGA_Registration_Link';
import signInURl from '@salesforce/label/c.Sales_SignInURL';
import accDenied from '@salesforce/label/c.Sales_HelpDocLink';
import faqLink from '@salesforce/label/c.Sales_frequentlyAQ';
export default class Sales_LoginPage extends LightningElement {
    label={
        chatSupport,
        regLink,
        signInURl,accDenied,faqLink
    }
}