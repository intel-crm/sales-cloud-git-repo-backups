/** PartnerMessages
 * Data used in the ipaPartnerMessage LWC Component
 * @typedef PartnerMessages
 * @memberof ipaBenefitService
 * @property {string} title the title of the ipa Component
 * @property {ipaBenefitService.PartnerMessage[]} messages the message entries of the component, should be limited to 4
 * @property {Link} viewAllLink the view all messages link of the messages
 */

/** PartnerMessage
 * Data used to each message of the blade
 * @typedef PartnerMessage
 * @memberof ipaBenefitService
 * @property {string} messageId the id of the message
 * @property {string} type the message type: Account/ Event / Direct Message/ Product
 * @property {string} iconType type alert/envelope/none -  Direct Message Type will always be Envelope, Account/ Event / Product can be alert or none
 * @property {string} subject the title of the message
 * @property {string} name the sender name of the message
 * @property {ipaBenefitService.Field[]} fields the fields added before the body of the message https://d.pr/i/gsVqqC
 * @property {string} body the rich text string of the body
 * @property {string} msgDate the date in ISO 8601 format or  YYYY-MM-DD
 * @property {boolean} read the read state of the message
 * @property {Link} replyLink the reply link out for the message
 */

/** Field
 * Data used to represent a blade in the partner benefits page
 * @typedef Field
 * @memberof ipaBenefitService
 * @property {string} label the label of the field
 * @property {string} value the value of the field
 */

import helpers from './helpers/index';
import {textShort} from './helpers/text';


const subject = () => helpers.sample([
    'Qui sint aliqua ullamco incididunt et.',
    'Sunt aliqua id mollit anim minim exercitation est.',
    'Mollit in occaecat sunt proident voluptate eiusmod reprehenderit.',
    'Ipsum esse non irure tempor est culpa pariatur adipisicing .',
    'Voluptate consectetur aliquip quis culpa irure eu nisi duis pariatur ipsum amet.'
])


const body = () => helpers.sample([
    '<p>Sit et <b>bold</b> ipsum consequat mollit. Et in nostrud Lorem cillum quis cillum</p<p>amet non sint velit quis reprehenderit adipisicing. Labore eiusmod consequat sunt pariatur ut eu in qui. Do sit et irure deserunt ea cillum nulla amet eu voluptate. Amet incididunt ut ut cupidatat quis eu non veniam sit proident reprehenderit dolor exercitation.</p><ul><li>Bullet  1</li><li>Bullet  2</li><li>Bullet  3</li><li>Bullet  4</li></ul>',
    '<p>Sunt aliqua id mollit anim minim exercitation est sint velit quis reprehenderit adipisicing. Labore eiusmod consequat sunt pariatur ut eu in qui. Do sit et irure deserunt ea cillum nulla amet eu voluptate. Amet incididunt ut ut cupidatat quis eu non veniam sit proident reprehenderit dolor exercitation.</p>',
    '<p>Mollit in occaecat sunt proident voluptate eiusmod reprehenderitm amet non sint velit quis reprehenderit adipisicing. Labore eiusmod consequat sunt pariatur ut eu in qui. Do sit et irure deserunt ea cillum nulla amet eu voluptate. Amet incididunt ut ut cupidatat quis eu non veniam sit proident reprehenderit dolor exercitation.</p>',
    '<p>Ipsum esse non irure tempor est culpa pariatur adipisicing  illum amet non sint velit quis reprehenderit adipisicing. Labore eiusmod consequat sunt pariatur ut eu in qui. Do sit et irure deserunt ea cillum nulla amet eu voluptate. Amet incididunt ut ut cupidatat quis eu non veniam sit proident reprehenderit dolor exercitation.</p>',
    '<p>Voluptate consectetur aliquip quis culpa irure eu nisi duis pariatur ipsumamet non sint velit quis reprehenderit adipisicing. Labore eiusmod consequat sunt pariatur ut eu in qui. Do sit et irure deserunt ea cillum nulla amet eu voluptate. Amet incididunt ut ut cupidatat quis eu non veniam sit proident reprehenderit dolor exercitation.</p><div style="width: 700px; height: 700px; background: #fcc; text-align: center; font-size: 80px;">This is a test box that occupies 700px x700px dimension for testing</div>',
])

const fields = (index) => {

    let sampleFields = [
        {
            label : 'Name',
            value: textShort()
        },
        {
            label: 'Company',
            value: textShort()
        },
        {
            label: 'Random Field 1',
            value: textShort()
        },
        {
            label: 'Random Field 2',
            value: textShort()
        }
    ];

    return  index>-1  && sampleFields.length > index ? sampleFields[index] : helpers.sample(sampleFields);
}

const getPartnerMessage = (type) => {
    let randomType = helpers.sample(['Account', 'Event', 'Direct Message', 'Product']);

    let messageType = type || randomType;
    let iconType = messageType !== 'Direct Message' ? helpers.sample(['alert']) : 'envelope';
    let fieldsSet =  messageType === 'Direct Message' ? [fields(),fields()] : [];
    let randomDate = helpers.sample(['2020-06-03', '2020-04-03', '2020-03-30', '2020-02-28']);

    return {
        messageId: helpers.id(),
        type: messageType,
        iconType: iconType,
        fields: fieldsSet,
        msgDate: randomDate,
        subject: subject(),
        body: body(),
        read: false,
        replyLink:  {
            label: 'Reply Link',
            externalUrl: '#ReplyLink',
            communityPage: '',
            objectPage: '',
            recordId: ''
        }

    }
}

const partnerMessages = () => {
    return {
        title: 'Recent Messages',
        messages: [
            getPartnerMessage('Account'),
            getPartnerMessage('Event'),
            getPartnerMessage('Direct Message'),
            getPartnerMessage('Product'),
            getPartnerMessage('Product'),
            getPartnerMessage('Product'),
            getPartnerMessage('Product')
        ],
        viewAllLink: {
            label: 'View All Messages',
            externalUrl: '#',
            communityPage: '',
            objectPage: '',
            recordId: ''
        }
    }

}


export const mockPartnerMessages = () => {
    return partnerMessages();
}