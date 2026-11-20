import BaseChatMessage from 'lightningsnapin/baseChatMessage';
import { track,wire,api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import chatMessageStyle from '@salesforce/resourceUrl/chatMessageStyle';
import Sales_stepbystepGuidance from '@salesforce/label/c.Sales_stepbystepGuidance';//sahil added
const DEFAULT_MESSAGE_PREFIX = 'PLAIN_TEXT';
const RICHTEXT_MESSAGE_PREFIX = 'RICH_TEXT';
const YOUTUBE_MESSAGE_PREFIX = 'YOUTUBE';
const IMAGE_MESSAGE_PREFIX = 'IMAGE';
const LWC_MESSAGE_PREFIX = 'COMPONENT';
const LWC_FEEDBACK_COMPONENT = 'FEEDBACK_COMPONENT';
const LWC_DATATABLE_LICENSE_PREFIX = 'LICENSE_DATATABLE';
const URL_MESSAGE_PREFIX = 'URL';
const URL_HOWTO='URL_HOWTO'
const URL_ADMIN = 'ADMIN_URL';
const URL_ALLLICENSE='ALLLICENSE_URL';
const URL_ACTIVE='ACTIVE_URL';
const URL_MENTAINANCE= 'MENTAINANCE_URL';
const URL_CONTACT_SUPPORT_PREFIX = 'SUPPORT_URL';
const URL_ADDSEATS ='ADDSEATS_URL';
const URL_RENEWAL ='RENEWAL_URL';
const URL_INTEL='INTEL_URL';
const URL_DISTRIBUTOR='DISTRIBUTOR_URL'
const URL_HELP ='HELP_URL';
const URL_IPS='IPS_URL';
const URL_30DAYS ='30DAYS_URL';  
const URL_QUARTUS ='QUARTUS_URL';
const URL_MAXPLUS ='MAXPLUS_URL';
const NAVIGATE_MESSAGE_PREFIX = 'NAVIGATE';
const FREQUENTLY_ASKED_QUESTION='FAQ';
const LICENSING_CENTER_USER_GUIDE='LCUG';
const INSTALLATION_AND_LICENSING_SUPPORT_CENTER= 'ILSC';
const CONTACT_CUSTOMER_SUPPORT='CCS';
const SIGN_UP_FREE_EVALUATION_LICENSES='SUFEL';
const SOFTWARE_LICENSING_TROUBLESHOOTER= 'SLT';
const URL_LICENSE_SUPPORT= 'LSUPPORT_URL';
const SUPPORTED_MESSAGE_PREFIX = [DEFAULT_MESSAGE_PREFIX,URL_LICENSE_SUPPORT,URL_INTEL,URL_IPS ,URL_30DAYS,URL_QUARTUS,URL_MAXPLUS,URL_DISTRIBUTOR,URL_HELP,CONTACT_CUSTOMER_SUPPORT,SIGN_UP_FREE_EVALUATION_LICENSES,SOFTWARE_LICENSING_TROUBLESHOOTER,INSTALLATION_AND_LICENSING_SUPPORT_CENTER,LICENSING_CENTER_USER_GUIDE,FREQUENTLY_ASKED_QUESTION, RICHTEXT_MESSAGE_PREFIX, YOUTUBE_MESSAGE_PREFIX, IMAGE_MESSAGE_PREFIX, LWC_MESSAGE_PREFIX, URL_MESSAGE_PREFIX,URL_HOWTO,URL_ADMIN,URL_ALLLICENSE,URL_MENTAINANCE,URL_ACTIVE,URL_CONTACT_SUPPORT_PREFIX,URL_ADDSEATS,URL_RENEWAL, NAVIGATE_MESSAGE_PREFIX,LWC_DATATABLE_LICENSE_PREFIX,];
const OPENGRAPH_API_KEY = 'YOUR_OPENGRAPH_API_KEY';


/**
 * Displays a chat message using the inherited api messageContent and is styled based on the inherited api userType and messageContent api objects passed in from BaseChatMessage.
 */
export default class ChatMessageDefaultUI extends BaseChatMessage {
    messageType = DEFAULT_MESSAGE_PREFIX;
    @track content = '';
    @track chatbotlinks;
    @api activationCode;
    @api serialnoVariable;
    @api selectedSerialNo;
    @api successResponse;
    @api sendactivationcodetochatmsg;
    @api selectedSerialNoForUnlicensed;
    @api successmsg;//get response from hostLWC salesSeachHostInfo
    @api successmsgforunlicensed; //getResponse from salesUnlicsedProducts LWC
    @api item;

    connectedCallback() {
        if (!this.isAgent) {
            return;
        }
        const messageTypePrefixPosition = SUPPORTED_MESSAGE_PREFIX.indexOf(this.messageContent.value.split(':')[0]);
        if (messageTypePrefixPosition > -1) {
            this.messageType = SUPPORTED_MESSAGE_PREFIX[messageTypePrefixPosition];
            console.log('Message Type:'+this.messageType);
        }
        
        var contentValue = (this.messageContent.value.split(this.messageType + ':').length === 1) ? this.messageContent.value : this.messageContent.value.split(this.messageType + ':')[1];
        console.log('contentValue==>'+contentValue);
       /* if(this.successmsg=='You have successfully assigned a new Host!'){
            contentValue = 'You have successfully assigned a new Host!\nEnter 1 to Proceed Further.';
        }else if(this.successmsg!=undefined && this.successmsg!='You have successfully assigned a new Host!'){
            var msg = this.successmsg;
            if(msg.includes('Available rehost Quantity is')){
                contentValue = this.successmsg.concat('\nEnter 2 to Proceed');
            }
            else if(msg.includes('This host is already assigned to')){
                contentValue = this.successmsg.concat('\nEnter 1 to Proceed');;
        }
        }*/
        Promise.all([
            loadStyle(this, chatMessageStyle + '/style.css')
        ]);
        if (this.isPlainText) {
            this.content = contentValue;
        } else if (this.isYoutube) {
            this.content = 'https://www.youtube.com/embed/' + contentValue
        } else if (this.isNavigate) {
            const url = this.extractOriginalUrl(contentValue);
            window.open(url);
            this.content = 'Opening ${url}';
        } else if (this.isImage) {
            this.content = this.extractOriginalUrl(contentValue);
        } else if(this.isLwc) {
            var chars  = contentValue.split(':');
        }
        else if(this.isFeedbackComponent){

        }
        else if(this.isLicenseDatatable){
         
        } else if (this.isUrl||this.isIPSUrl|| this.isURL_30Days|| this.isURL_Quartus||this.isURL_Maxplus||this.isHowto||this.isAdminurl||this.isActiveurl||this.isMentainanceurl||this.isAlllicenseurl|| this.isSupportUrl||this.isDistributorUrl || this.isAddseatsUrl || this.isRenewalUrl ||this.isIntelUrl||this.isHelpUrl ||this.isfrequentlyaskedquestion ||  this.islicensingcenteruserguide || this.isinstallationandlicensingsupportcenter || this.issoftwarelicensingtroubleshooter||this.isfreeorevaluationlicense||this.iscontactcustomersupport || this.isLsupportUrl) {
            console.log('Inside URL');
            const contenttemp = contentValue

            .replace( // innerText or textContent
                /(?:(?:ht|f)tp(?:s?)\:\/\/|~\/|\/)?(?:\w+:\w+@)?((?:(?:[-\w\d{1-3}]+\.)+(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|edu|co\.uk|ac\.uk|it|fr|tv|museum|asia|local|travel|[a-z]{2}))|((\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)(\.(\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)){3}))(?::[\d]{1,5})?(?:(?:(?:\/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?:#(?:[-\w~!$ |\/.,*:;=]|%[a-f\d]{2})*)?/g,
                function(imgUrl) {
                        if(imgUrl.includes('https://') || imgUrl.includes('http://')) {
                            console.log('Inside if else');
                            if(this.isUrl)
                            {
                            return `<a target="_blank" href="${imgUrl}">View computer and license files.</a>`;
                            }
                            else if(this.isURL_30Days){
                                return `<a target="_blank" href="${imgUrl}">Get a free 30 day Trial license</a>`;    
                            }
                            else if(this.isURL_Quartus){
                                return `<a target="_blank" href="${imgUrl}">Get a free Quartus II Web edition</a>`;    
                            }
                            else if(this.isURL_Maxplus){
                                return `<a target="_blank" href="${imgUrl}">Get a free 	Maxplus II license</a>`;    
                            }
                            else if(this.isHowto){
                                return `<a target="_blank" href="${imgUrl}">${Sales_stepbystepGuidance}</a>`;    
                            }
                            else if(this.isAdminurl)
                            {
                            return `<a target="_blank" href="${imgUrl}">Add a new license administrator</a>`;
                            }
                            else if(this.isActiveurl)
                            {
                            return `<a target="_blank" href="${imgUrl}">View my active computers</a>`;
                            }
                            else if(this.isMentainanceurl)
                            {
                            return `<a target="_blank" href="${imgUrl}">View my active maintenance licenses</a>`;
                            }
                            else if(this.isAlllicenseurl)
                            {
                            return `<a target="_blank" href="${imgUrl}">View all licenses</a>`;
                            }
                            else if(this.isSupportUrl)
                            { return `<a target="_blank" href="${imgUrl}">Please contact customer support</a>`;
                            }
                            else if(this.isAddseatsUrl)
                            { return `<a target="_blank" href="${imgUrl}">Add Seat License</a>`;
                            }
                            else if(this.isRenewalUrl)
                            { return `<a target="_blank" href="${imgUrl}">Renewal License</a>`;
                            }
                            else if(this.isIntelUrl)
                            { return `<a target="_blank" href="${imgUrl}">myIntel</a>`;
                            }
                            else if(this.isDistributorUrl)
                            { return `<a target="_blank" href="${imgUrl}">Contact your Distributor</a>`;
                            }
                            else if(this.isHelpUrl)
                            { return `<a target="_blank" href="${imgUrl}">Need help on Evaluation or No-Cost or Legacy or Employee license?</a>`;
                            }
                            else if(this.isIPSUrl)
                            { return `<a target="_blank" href="${imgUrl}">IPS Portal</a>`;
                            }
                            else if(this.isfrequentlyaskedquestion)
                            {
                                return `<a target="_blank" href="${imgUrl}">Frequently asked questions on Licensing</a>`;
 
                            }
                            else if(this.islicensingcenteruserguide)
                            {
                                return `<a target="_blank" href="${imgUrl}">Licensing Center User Guide</a>`;
                            }
                            else if(this.issoftwarelicensingtroubleshooter){
                                return `<a target="_blank" href="${imgUrl}">Software Licensing Troubleshooter</a>`;
                            }
                            else if(this.isinstallationandlicensingsupportcenter)
                            {
                                return `<a target="_blank" href="${imgUrl}">Installation & Licensing Support Center</a>`;
                            }
                            else if(this.isfreeorevaluationlicense)
                            {
                                return `<a target="_blank" href="${imgUrl}">Sign up for Evaluation or No-Cost Licenses</a>`;
                            }
                            else if(this.iscontactcustomersupport)
                            {
                                return `<a target="_blank" href="${imgUrl}">Contact Customer Support</a>`;
                            }
                            else if(this.isLsupportUrl)
                            {
                                return `<a target="_blank" href="${imgUrl}">Click here to extract description of the field</a>`;
                            }
                            

                        }
                    return imgUrl;
                }.bind(this)
            );
        this.content = contenttemp.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '\\"');
        } 
         else {
            console.log('inside else==>'+imgUrl);
            this.content = contentValue
                .replace(/&lt;/g, '<')
                .replace(/&gt;/g, '>')
                .replace(/&quot;/g, '\"')
                .replace(/<a href='mailto:.*?' target='_blank'>(.*?)<\/a>/g, '$1')
                .replace(/<a href='/g, '')
                .replace(/' target='_blank'.*?<\/a>( +)/g, '$1')
                .replace(/' target='_blank'.*?<\/a>.*?<\/a>/g, '');
        }
    }

    extractOriginalUrl(generatedString) {
        const matched = generatedString.match(/<a href.+>(.*?)<\/a>/);
        if (matched.length > 1) {
            return matched[1];
        }
        return generatedString;
    }

    fallback(event) {
        event.target.onerror = null;
        event.target.style.display = 'none';
        event.target.style.height = 0;
    }

    get isAgent() {
        return this.userType === 'agent';
    }

    get isPlainText() {
        return this.messageType === DEFAULT_MESSAGE_PREFIX;
    }

    get isRichText() {
        return this.messageType === RICHTEXT_MESSAGE_PREFIX;
    }

    get isYoutube() {
        return this.messageType === YOUTUBE_MESSAGE_PREFIX;
    }

    get isImage() {
        return this.messageType === IMAGE_MESSAGE_PREFIX;
    }

    get isLwc() {
        return this.messageType === LWC_MESSAGE_PREFIX;
    }

    get isLicenseDatatable(){
        return this.messageType === LWC_DATATABLE_LICENSE_PREFIX;
    }

    get isFeedbackComponent(){
        return this.messageType === LWC_FEEDBACK_COMPONENT;
    }

    get isUrl() {
        return this.messageType === URL_MESSAGE_PREFIX;
    }
    get isHowto() {
        return this.messageType === URL_HOWTO;
    }

    
    get isAdminurl() {
        return this.messageType === URL_ADMIN;
    }get isAlllicenseurl() {
        return this.messageType === URL_ALLLICENSE;
    }
    get isMentainanceurl() {
        return this.messageType === URL_MENTAINANCE;
    }get isActiveurl() {
        return this.messageType === URL_ACTIVE;
    }
   
    get isfrequentlyaskedquestion()
    {
        return this.messageType === FREQUENTLY_ASKED_QUESTION;
    }
    get islicensingcenteruserguide()
    {
        return this.messageType === LICENSING_CENTER_USER_GUIDE;
    }
    get issoftwarelicensingtroubleshooter()
    {
        return this.messageType === SOFTWARE_LICENSING_TROUBLESHOOTER;
    }
    get isinstallationandlicensingsupportcenter()
    {
        return this.messageType === INSTALLATION_AND_LICENSING_SUPPORT_CENTER;
    }
    get isfreeorevaluationlicense()
    {
    return this.messageType === SIGN_UP_FREE_EVALUATION_LICENSES;
    }
    get isSupportUrl(){
        return this.messageType === URL_CONTACT_SUPPORT_PREFIX;
    }
    get isAddseatsUrl(){
        return this.messageType === URL_ADDSEATS;
    }
    get isRenewalUrl(){
        return this.messageType === URL_RENEWAL;
    }
    get isIntelUrl(){
        return this.messageType === URL_INTEL;
    }
    get isDistributorUrl(){
        return this.messageType === URL_DISTRIBUTOR;
    }
    get isHelpUrl(){
        return this.messageType === URL_HELP;
    }
    get iscontactcustomersupport()
    {
        return this.messageType === CONTACT_CUSTOMER_SUPPORT;
    }
    get isURL_30Days(){
        return this.messageType === URL_30DAYS;
    }
    get isURL_Quartus(){
        return this.messageType === URL_QUARTUS;
    }
    get isURL_Maxplus(){
        return this.messageType === URL_MAXPLUS;
    }
    get isNavigate() {
        return this.messageType === NAVIGATE_MESSAGE_PREFIX;
    }
    get isIPSUrl(){
        return this.messageType === URL_IPS;
    }
    get isLsupportUrl(){
        return this.messageType === URL_LICENSE_SUPPORT;
    }
}